//
//  FontAtlas.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import Metal

final class FontAtlasCache {
    
    // Cache
    private var _cache = [String: FontAtlas]()
    
    /// Create a signed-distance field based font atlas with the specified dimensions.
    /// The supplied font will be resized to fit all available glyphs in the texture.
    init () {
        
        do {
            let atlasFolderURL = LocalStorage.sharedInstance
                .getAppSupportURL()
                .appendingPathComponent("FontAtlases")
            
            let fileManager = FileManager.default
            let atlasJSONPaths = try fileManager.contentsOfDirectory(atPath: atlasFolderURL.path).filter { $0.hasSuffix(".json") }
            
            for path in atlasJSONPaths {
                let atlasJSONString = try String(contentsOf: atlasFolderURL.appendingPathComponent(path))
                let atlasJSON = try JSON.decode(atlasJSONString)
                let atlas = try FontAtlas(fromJSON: atlasJSON)

            }
            /*let jsonURL = atlasFolderURL
             .appendingPathComponent(fontName)
             .appendingPathExtension("json")
             let atlasJSON = try JSON.decode(atlasJSONString)
             _cache[fontName] = atlas
             do {
             // try to decode from JSON
             let atlasFolderURL = LocalStorage.sharedInstance
             .getAppSupportURL()
             .appendingPathComponent("FontAtlases")
             
             let jsonURL = atlasFolderURL
             .appendingPathComponent(fontName)
             .appendingPathExtension("json")
             let atlasJSONString = try String(contentsOf: jsonURL)
             let atlasJSON = try JSON.decode(atlasJSONString)
             let atlas = try FontAtlas(fromJSON: atlasJSON, context: context)
             _cache[fontName] = atlas
             return atlas
             } catch let error as NSError {
             logPrint(.error, "cannot create font atlas from cache: \(error.description)")
             }  catch {
             logPrint(.error, "cannot create font atlas from cache")
             }
             // build from scratch
             let atlas = FontAtlas(context: context, fontName: fontName, pointSize: pointSize)
             
             // add to cache
             _cache[fontName] = atlas
             
             return atlas
             
             return atlas*/
        } catch let error {
            logPrint(.error, "cannot create font atlas from cache: \(error.localizedDescription)")
        }
        // build from scratch
    }

    func createTexture (forAtlas: FontAtlas, context: Context) {
        /*let imageBuffer = Imagebuffer(
            array: _textureData,
            width: _textureSize,
            height: _textureSize,
            bytesPerPixel: 1)
        let source: TextureSource = .buffer(imageBuffer)
        let sampler = Sampler(context: context, wrapS: .clampToZero, wrapT: .clampToZero, mipMagFilter: .linear)
        let options = TextureOptions(
            source: source,
            pixelFormat: .r8Unorm,
            usage: TextureUsage.ShaderRead,
            mipmapped: true,
            sampler: sampler)
        _texture = Texture(context: context, options: options)
        _waitingForMipmaps = true*/
    }
    
    func atlas(forFont fontName: String) -> FontAtlas? {
        
        if let atlas = _cache[fontName] {
            return atlas
        }
        return nil
    }
    
    func loadTexturesIfRequired(frameState: FrameState) {
        
        guard let context = frameState.context else {
            return
        }
        
        for atlas in _cache.values {
            
            switch atlas.loadState {
            case .unloaded:
                atlas.loadState = .loading
                self.createTexture(forAtlas: atlas, context: context)
            case .waitingForMipMaps:
                atlas.loadState = .generatingMipMaps
  //              atlas._texture.generateMipmaps(context: context, completionBlock: { buffer in atlas.ready = true })
            default:
                continue
            }
        }
    }
}

