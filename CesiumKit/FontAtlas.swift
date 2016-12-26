//
//  FontAtlas.swift
//  AtlasGenerator
//
//  Created by Ryan Walklin on 25/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

import Foundation

// Cache
private var _cache = [String: FontAtlas]()

private let FontNameKey = "name"
private let GlyphDescriptorsKey = "descriptors"
private let TextureDataPathKey = "textureData"
private let TextureSizeKey = "textureSize"

/// Errors thrown by FontAtlas functions.
enum FontAtlasError: Error, CustomStringConvertible {
    /// Thrown when the provided JSON is invalid.
    /// - Parameter json: The provided JSON.
    /// - Parameter message: Optional error message.
    case invalidJSONError(json: JSON, message: String?)
    
    /// Thrown when texture data cannot be loaded from file.
    /// Parameter path: The texture data path.
    /// - Parameter message: Optional error message.
    case invalidTextureDataError(path: String, message: String?)
    
    var description: String {
        switch self {
        case let .invalidJSONError(json, message): return "Invalid JSON - \(message): \(JSON.encodeAsString(json))"
        case let .invalidTextureDataError(path, message): return "Invalid texture data - \(message): path \(path)"
        }
    }
}

enum AtlasLoadState {
    case unloaded
    case loading
    case loaded
    case waitingForMipMaps
    case generatingMipMaps
    case ready
}

final class FontAtlas: JSONEncodable {
    
    let fontName: String
    
    let glyphDescriptors: [GlyphDescriptor]
    
    let textureSize: Int
        
    let textureDataPath: String
    
    let textureData: Data
    
    var texture: Texture? = nil
    
    var loadState: AtlasLoadState = .unloaded
    
    /// Create a signed-distance field based font atlas with the specified dimensions.
    /// The supplied font will be resized to fit all available glyphs in the texture.
    init (fontName: String, glyphDescriptors: [GlyphDescriptor], textureSize: Int, textureDataPath: String, textureData: Data) {
        self.fontName = fontName
        self.glyphDescriptors = glyphDescriptors
        self.textureSize = textureSize
        self.textureDataPath = textureDataPath
        self.textureData = textureData
    }

    init(fromJSON json: JSON) throws {
        let fontName = try json.getString(FontNameKey)
        
        if fontName == "" {
            throw FontAtlasError.invalidJSONError(json: json, message: "Invalid persisted font name")
        }
        
        let font = CTFontCreateWithName(fontName as CFString?, 32, nil)
        let createdFontName = CTFontCopyPostScriptName(font) as String

        if fontName != createdFontName {
            throw FontAtlasError.invalidJSONError(json: json, message: "Atlas font not available on system")
        }
        self.fontName = fontName
        
        glyphDescriptors = try json
            .getArray(GlyphDescriptorsKey)
            .map { try GlyphDescriptor(fromJSON: $0) }
            .sorted { $0.glyphIndex < $1.glyphIndex }
        
        if glyphDescriptors.count <= 0 {
            throw FontAtlasError.invalidJSONError(json: json, message: "Invalid persisted font (no glyph metrics).")
        }
        
        textureSize = try json.getInt(TextureSizeKey)
        
        textureDataPath = try json.getString(TextureDataPathKey)
        let textureDataURL = URL(fileURLWithPath: textureDataPath)
        
        let textureData = try Data(contentsOf: textureDataURL, options: [.mappedIfSafe])
        if textureData.count <= 0 {
            throw FontAtlasError.invalidTextureDataError(path: textureDataURL.absoluteString, message: "Texture data too short.")
        }
        self.textureData = textureData
    }
    
    internal func toJSON() -> JSON {
        let json = JSON.object(JSONObject(
            [
                FontNameKey: JSON(stringLiteral: fontName),
                TextureSizeKey: JSON(integerLiteral: Int64(textureSize)),
                TextureDataPathKey: JSON(stringLiteral: textureDataPath),
                GlyphDescriptorsKey: JSON.array(ContiguousArray<JSON>(glyphDescriptors.map { $0.toJSON() }))
            ]))
        return json
    }
    

}

