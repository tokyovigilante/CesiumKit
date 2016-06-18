//
//  FontAtlas.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreText
import Metal


// This is the size at which the font atlas will be generated, ideally a large power of two. Even though
// we later downscale the distance field, it's better to render it at as high a resolution as possible in
// order to capture all of the fine details.

// Cache
private var _cache = [String: FontAtlas]()

let MBEFontAtlasSize = 4096

private let FontNameKey = "fontName"
private let PointSizeKey = "pointSize"
private let FontSpreadKey = "spread"
private let GlyphDescriptorsKey = "glyphDescriptors"
private let TextureDataPathKey = "textureDataPath"
private let TextureSizeKey = "textureSize"

/// Errors thrown by FontAtlas functions.
enum FontAtlasError: ErrorProtocol, CustomStringConvertible {
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

final class FontAtlas: JSONEncodable {

    private (set) var parentFont: CTFont
    
    private var _fontPointSize: Int

    private var _spread: Double = 0.0
    
    private let _textureSize: Int
    
    internal var glyphDescriptors = [GlyphDescriptor]()
    
    private var _textureData = [UInt8]()
    
    private (set) var ready = false
    
    private var _waitingForMipmaps = false
    
    var texture: Texture? {
        if !ready {
            return nil
        }
        return _texture
    }
    
    private var _texture: Texture! = nil
    
    private var MBE_GENERATE_DEBUG_ATLAS_IMAGE = true

    /// Create a signed-distance field based font atlas with the specified dimensions.
    /// The supplied font will be resized to fit all available glyphs in the texture.
    private init (context: Context, fontName: String, pointSize: Int, textureSize: Int = MBEFontAtlasSize) {
        parentFont = CTFontCreateWithName(fontName, CGFloat(pointSize), nil)
        _fontPointSize = Int(ceilf(Float(pointSize)))
        _textureSize = textureSize
        _spread = estimatedLineWidthForFont(parentFont) * 0.5
        
        QueueManager.sharedInstance.fontAtlasQueue.async(execute: {
            self.createTextureData()
            self.createTexture(context)
            FontAtlas.writeToFile(self)
        })
    }
    
    internal convenience init (fromJSON json: JSON, context: Context) throws {
        try self.init(fromJSON: json)
        
        QueueManager.sharedInstance.fontAtlasQueue.async(execute: {
            self.createTexture(context)
        })
    }
    
    internal init(fromJSON json: JSON) throws {
        let fontName = try json.getString(FontNameKey)
        _fontPointSize = try json.getInt(PointSizeKey)
        _spread = try json.getDouble(FontSpreadKey)
        
        if _fontPointSize <= 0 || fontName == "" {
            throw FontAtlasError.invalidJSONError(json: json, message: "Invalid persisted font (invalid font name or size)")
        }
        parentFont = CTFontCreateWithName(fontName, CGFloat(_fontPointSize), nil)
        
        glyphDescriptors = try json
            .getArray(GlyphDescriptorsKey)
            .map { try GlyphDescriptor(fromJSON: $0) }
            .sorted { $0.glyphIndex < $1.glyphIndex }
        
        if glyphDescriptors.count <= 0 {
            throw FontAtlasError.invalidJSONError(json: json, message: "Encountered invalid persisted font (no glyph metrics).")
        }
        
        _textureSize = try json.getInt(TextureSizeKey)
               
        let textureDataURL = try! try! try! LocalStorage.sharedInstance.getAppSupportURL().appendingPathComponent("FontAtlases")
            .appendingPathComponent(fontName)
            .appendingPathExtension("textureData")

        let textureData = try Data(contentsOf: textureDataURL, options: [.dataReadingMappedIfSafe])
        if textureData.count <= 0 {
            throw FontAtlasError.invalidTextureDataError(path: textureDataURL.absoluteString, message: "Texture data too short.")
        }
        _textureData = textureData.getUInt8Array()
    }

    internal func toJSON() -> JSON {
        let json = JSON.Object(JSONObject(
            [
                FontNameKey: JSON(stringLiteral: (CTFontCopyPostScriptName(parentFont) as NSString) as String),
                PointSizeKey: JSON(integerLiteral: Int64(_fontPointSize)),
                FontSpreadKey: JSON(floatLiteral: _spread),
                GlyphDescriptorsKey: JSON.Array(ContiguousArray<JSON>(glyphDescriptors.map { $0.toJSON() })),
                TextureSizeKey: JSON(integerLiteral: Int64(_textureSize))
            ]))
        return json
    }
    
    private func estimatedGlyphSizeForFont (_ font: CTFont) -> CGSize {
    
        let exemplarString = "{ǺOJMQYZa@jmqyw"
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), exemplarString)
        
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString!)
        var fitRange = CFRange()
        let exemplarStringSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), &fitRange)

        let averageGlyphWidth = CGFloat(ceilf(Float(exemplarStringSize.width) / Float(CFAttributedStringGetLength(attrString))))
        let maxGlyphHeight = CGFloat(ceilf(Float(exemplarStringSize.height)))
    
        return CGSize(width: averageGlyphWidth, height: maxGlyphHeight)
    }
    
    private func estimatedLineWidthForFont (_ font: CTFont) -> Double {
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), "!")
        
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString!)
        var fitRange = CFRangeMake(0, 0)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), &fitRange)
        
        return ceil(Double(textSize.width))
    }
    
    private func isLikelyToFitInAtlasRect (_ rect: CGRect, forFont font: CTFont, atSize size: Int) -> Bool {
        
        let textureArea = Double(rect.size.width * rect.size.height)
        let trialFont = CTFontCreateCopyWithAttributes(parentFont, CGFloat(size), nil, nil)
        let fontGlyphCount = CTFontGetGlyphCount(trialFont)
        let glyphMargin = estimatedLineWidthForFont(trialFont)
        let averageGlyphSize = estimatedGlyphSizeForFont(trialFont)
        let estimatedGlyphTotalArea = (Double(averageGlyphSize.width) + glyphMargin) * (Double(averageGlyphSize.height) + glyphMargin) * Double(fontGlyphCount)
        return estimatedGlyphTotalArea < textureArea
    }
    
    private func pointSizeThatFits (forFont font: CTFont, inAtlasRect rect: CGRect) -> Int {
        
        var fittedSize = Int(CTFontGetSize(font))
     
        while isLikelyToFitInAtlasRect(rect, forFont: font, atSize: fittedSize) {
            fittedSize += 1
        }
        while isLikelyToFitInAtlasRect(rect, forFont: font, atSize: fittedSize) {
            fittedSize -= 1
        }
        return fittedSize
    }
    
    private func createAtlasForFont (_ font: CTFont, width: Int, height: Int) -> [UInt8] {
        
        var imageData = [UInt8](repeating: 0, count: width * height)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let alphaInfo = CGImageAlphaInfo.none
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        
        let context = CGContext(data: &imageData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue)
        
        // Turn off antialiasing so we only get fully-on or fully-off pixels.
        // This implicitly disables subpixel antialiasing and hinting.
        context?.setAllowsAntialiasing(false)
        
        // Flip context coordinate space so y increases downward
        context?.translate(x: 0, y: CGFloat(height))
        context?.scale(x: 1, y: -1)
        
        let fWidth = CGFloat(width)
        let fHeight = CGFloat(height)
        
        // Fill the context with an opaque black color
        context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        context?.fill(CGRect(x: 0, y: 0, width: fWidth, height: fHeight))
        
        _fontPointSize = pointSizeThatFits(forFont: font, inAtlasRect: CGRect(x: 0, y: 0, width: fWidth, height: fHeight))
        parentFont = CTFontCreateCopyWithAttributes(parentFont, CGFloat(_fontPointSize), nil, nil)

        let fontGlyphCount = CTFontGetGlyphCount(parentFont)
        
        let glyphMargin = CGFloat(estimatedLineWidthForFont(parentFont))
        
        // Set fill color so that glyphs are solid white
        context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        glyphDescriptors.removeAll()
        
        let fontAscent = CTFontGetAscent(parentFont)
        let fontDescent = CTFontGetDescent(parentFont)
        
        var origin = CGPoint(x: 0, y: fontAscent)
        var maxYCoordForLine: CGFloat = -1
        
        for glyph in 0..<UInt16(fontGlyphCount) {
            
            var boundingRect = CGRect()
            CTFontGetBoundingRectsForGlyphs(parentFont, CTFontOrientation.horizontal, [glyph], &boundingRect, 1)
            
            if (origin.x + boundingRect.maxX + glyphMargin > fWidth) {
                origin.x = 0
                origin.y = maxYCoordForLine + glyphMargin + fontDescent
                maxYCoordForLine = -1
            }
            
            if origin.y + boundingRect.maxY > maxYCoordForLine {
                maxYCoordForLine = origin.y + boundingRect.maxY
            }
            
            let glyphOriginX = origin.x - boundingRect.origin.x + (glyphMargin * 0.5)
            let glyphOriginY = origin.y + (glyphMargin * 0.5)
            
            var glyphTransform = CGAffineTransformMake(1, 0, 0, -1, glyphOriginX, glyphOriginY)
            
            let path = CTFontCreatePathForGlyph(parentFont, glyph, &glyphTransform)
            context?.addPath(path!)
            context?.fillPath()
            
            var glyphPathBoundingRect = path?.boundingBoxOfPath
        
            // The null rect (i.e., the bounding rect of an empty path) is problematic
            // because it has its origin at (+inf, +inf); we fix that up here
            if ((glyphPathBoundingRect?.equalTo(CGRect.null)) != nil) {
                glyphPathBoundingRect = CGRect.zero
            }
            
            let texCoordLeft = (glyphPathBoundingRect?.origin.x)! / fWidth
            let texCoordRight = ((glyphPathBoundingRect?.origin.x)! + (glyphPathBoundingRect?.size.width)!) / fWidth
            let texCoordTop = (glyphPathBoundingRect?.origin.y)! / fHeight
            let texCoordBottom = ((glyphPathBoundingRect?.origin.y)! + (glyphPathBoundingRect?.size.height)!) / fHeight
            
            let descriptor = GlyphDescriptor(
                glyphIndex: glyph,
                topLeftTexCoord: CGPoint(x: texCoordLeft, y: texCoordTop),
                bottomRightTexCoord: CGPoint(x: texCoordRight, y: texCoordBottom)
            )
            glyphDescriptors.append(descriptor)
            
            origin.x += boundingRect.width + glyphMargin
        }
        
        /*if MBE_GENERATE_DEBUG_ATLAS_IMAGE {
            guard let contextImage = CGBitmapContextCreateImage(context) else {
                assertionFailure("Could not create debug font atlas image")
                return [UInt8]()
            }
            // Break here to view the generated font atlas bitmap
            let fontImage = NSImage(CGImage: contextImage, size: NSSize(width: fWidth, height: fHeight))
            print(fontImage)
            //UIImage *fontImage = [UIImage imageWithCGImage:contextImage];
        }*/
        return imageData
    }
    
    /// Compute signed-distance field for an 8-bpp grayscale image (values greater than 127 are considered "on")
    /// For details of this algorithm, see "The 'dead reckoning' signed distance transform" [Grevera 2004]
    private func createSignedDistanceField(grayscaleImage imageData: [UInt8], width: Int, height: Int) -> [Float] {
        
        assert(width > 0 && height > 0, "invalid glyph atlas dimensions")
        
        struct IntPoint { let x: Int; let y: Int }
        
        let maxDist = hypotf(Float(width), Float(height))
        let distUnit: Float = 1.0
        let distDiag = sqrtf(2.0)

        // Initialization phase: set all distances to "infinity"; zero out nearest boundary point map
        var distanceMap = [Float](repeating: maxDist, count: width * height) // distance to nearest boundary point map
        var boundaryPointMap = [IntPoint](repeating: IntPoint(x: 0, y: 0), count: width * height) // nearest boundary point map
        
        // Some helpers for manipulating the above arrays
        func image(_ x: Int, _ y: Int) -> Bool { return imageData[y * width + x] > 0x7f }
        func distance(_ x: Int, _ y: Int) -> Float { return distanceMap[y * width + x] }
        func nearestpt(_ x: Int, _ y: Int) -> IntPoint { return boundaryPointMap[y * width + x] }
        func setDistance(_ x: Int, _ y: Int, distance: Float) { distanceMap[y * width + x] = distance }
        func setNearestpt(_ x: Int, _ y: Int, point: IntPoint) { boundaryPointMap[y * width + x] = point }
        
        // Immediate interior/exterior phase: mark all points along the boundary as such
        for y in 1..<(height-1) {
            for x in 1..<(width-1) {
                let inside = image(x, y)
                if image(x - 1, y) != inside ||
                   image(x + 1, y) != inside ||
                   image(x, y - 1) != inside ||
                   image(x, y + 1) != inside {
                    
                    setDistance(x, y, distance: 0)
                    setNearestpt(x, y, point: IntPoint(x: x, y: y))
                }
            }
        }
        
        // Forward dead-reckoning pass
        for y in 1..<(height-2) {
            for x in 1..<(width-2) {
                if distance(x - 1, y - 1) + distDiag < distance(x, y) {
                    setNearestpt(x, y, point: nearestpt(x - 1, y - 1))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
                if distance(x, y - 1) + distUnit < distance(x, y) {
                    setNearestpt(x, y, point: nearestpt(x, y - 1))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
                if distance(x + 1, y - 1) + distDiag < distance(x, y) {
                    setNearestpt(x, y, point: nearestpt(x + 1, y - 1))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
                if (distance(x - 1, y) + distUnit < distance(x, y)) {
                    setNearestpt(x, y, point: nearestpt(x - 1, y))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
            }
        }
        
        // Backward dead-reckoning pass
        for y in stride(from: (height-2), through: 1, by: 1) {
            for x in stride(from: (width-2), through: 1, by: 1) {
                if distance(x + 1, y) + distUnit < distance(x, y) {
                    setNearestpt(x, y, point: nearestpt(x + 1, y))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
                if distance(x - 1, y + 1) + distDiag < distance(x, y) {
                    setNearestpt(x, y, point: nearestpt(x - 1, y + 1))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
                if distance(x, y + 1) + distUnit < distance(x, y) {
                    setNearestpt(x, y, point: nearestpt(x, y + 1))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
                if (distance(x + 1, y + 1) + distDiag < distance(x, y)) {
                    setNearestpt(x, y, point: nearestpt(x + 1, y + 1))
                    let nearest = nearestpt(x, y)
                    setDistance(x, y, distance: hypot(Float(x - nearest.x), Float(y - nearest.y)))
                }
            }
        }
        
        // Interior distance negation pass; distances outside the figure are considered negative
        for y in 0..<height {
            for x in 0..<width {
                if !image(x, y) {
                    setDistance(x, y, distance: -distance(x, y))
                }
            }
        }
        return distanceMap
    }
    
    private func createResampledData (distanceField inData: [Float], width: Int, height: Int, scaleFactor: Int) -> [Float] {
        
        assert(width % scaleFactor == 0 && height % scaleFactor == 0, "Scale factor does not evenly divide width and height of source distance field")
        
        let scaledWidth = width / scaleFactor
        let scaledHeight = height / scaleFactor
        var outData = [Float](repeating: 0.0, count: scaledWidth * scaledHeight)
        
        for y in 0.stride(to: height, by: scaleFactor) {
            
            for x in 0.stride(to: width, by: scaleFactor) {
                var accum: Float = 0.0
                for ky in 0..<scaleFactor {
                    
                    for kx in 0..<scaleFactor {
                        accum += inData[(y + ky) * width + (x + kx)]
                    }
                }
                accum = accum / Float(scaleFactor * scaleFactor)
                
                outData[(y / scaleFactor) * scaledWidth + (x / scaleFactor)] = accum
            }
        }
        
        return outData
    }
    
    private func createQuantizedDistanceField(distanceField inData: [Float], width: Int, height: Int, normalizationFactor: Double) -> [UInt8] {
        
        /*return inData.map {
         let clampDist = fmax(-normalizationFactor, fmin($0, normalizationFactor))
         let scaledDist = clampDist / normalizationFactor
         return UInt8((scaledDist + 1) / 2) * UInt8.max
         }*/
        var outData = [UInt8](repeating: 0, count: width * height)
        for y in 0..<height {
            for x in 0..<width {
                let dist = inData[y * width + x]
                let clampDist = max(-normalizationFactor, min(Double(dist), normalizationFactor))
                let scaledDist = Double(clampDist) / normalizationFactor
                let value = ((scaledDist + 1) / 2) * Double(UInt8.max)
                outData[y * width + x] = UInt8(UInt16(value))
            }
        }
        return outData
    }
    
    private func createTextureData () {
        assert(MBEFontAtlasSize >= _textureSize, "Requested font atlas texture size (\(MBEFontAtlasSize)) must be smaller than intermediate texture size (\(_textureSize))")
    
        assert(MBEFontAtlasSize % _textureSize == 0, "Requested font atlas texture size (\(MBEFontAtlasSize)) does not evenly divide intermediate texture size (\(_textureSize))")
        
        // Generate an atlas image for the font, resizing if necessary to fit in the specified size.
        let atlasData = createAtlasForFont(parentFont, width: MBEFontAtlasSize, height: MBEFontAtlasSize)
        
        let scaleFactor = MBEFontAtlasSize / _textureSize
        
        // Create the signed-distance field representation of the font atlas from the rasterized glyph image.
        let distanceField = createSignedDistanceField(
            grayscaleImage: atlasData,
            width: MBEFontAtlasSize,
            height:MBEFontAtlasSize
        )
    
        // Downsample the signed-distance field to the expected texture resolution
        let scaledField = createResampledData(
            distanceField: distanceField,
            width: MBEFontAtlasSize,
            height: MBEFontAtlasSize,
            scaleFactor: scaleFactor
        )
        
        let spread = estimatedLineWidthForFont(parentFont) * 0.5
        
        // Quantize the downsampled distance field into an 8-bit grayscale array suitable for use as a texture
        _textureData = createQuantizedDistanceField(
            distanceField: scaledField,
            width: _textureSize,
            height: _textureSize,
            normalizationFactor: spread
        )
    }
    
    func createTexture (_ context: Context) {
        let imageBuffer = Imagebuffer(
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
        _waitingForMipmaps = true
    }
        
    class func fromCache(_ context: Context, fontName: String, pointSize: Int) -> FontAtlas {
        
        if let atlas = _cache[fontName] {
            return atlas
        }
        // try to decode from JSON
        let atlasFolderURL = try! LocalStorage.sharedInstance.getAppSupportURL().appendingPathComponent("FontAtlases")
        
        let jsonURL = try! try! atlasFolderURL?
            .appendingPathComponent(fontName)
            .appendingPathExtension("json")
        if let atlasJSONData = try? Data(contentsOf: jsonURL) {
            do {
                let atlasJSON = try JSON.decode(atlasJSONData)
                let atlas = try FontAtlas(fromJSON: atlasJSON, context: context)
                _cache[fontName] = atlas
                return atlas
            } catch let error as NSError {
                print("cannot create font atlas from cache: \(error.description)")
            }
        }
        // build from scratch
        let atlas = FontAtlas(context: context, fontName: fontName, pointSize: pointSize)

        // add to cache 
        _cache[fontName] = atlas

        return atlas
    }
    
    class func writeToFile (_ atlas: FontAtlas) {
        // encode and save
        let atlasFolderURL = try! LocalStorage.sharedInstance.getAppSupportURL().appendingPathComponent("FontAtlases")
        let fontName = CTFontCopyPostScriptName(atlas.parentFont) as String
        let jsonURL = try! try! atlasFolderURL?
            .appendingPathComponent(fontName)
            .appendingPathExtension("json")
        
        do {
            try FileManager.default().createDirectory(at: atlasFolderURL!, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("cannot create directory at URL: \(atlasFolderURL): \(error.localizedDescription)")
        }
        
        let atlasJSON = atlas.toJSON().object!
        
        let textureDataURL = try! try! atlasFolderURL?
            .appendingPathComponent(fontName)
            .appendingPathExtension("textureData")
        
        do {
            try JSON
                .encodeAsString(JSON.Object(atlasJSON))
                .write(to: jsonURL, atomically: true, encoding: String.Encoding.utf8)
            try Data
                .fromUInt8Array(atlas._textureData)
                .write(to: textureDataURL, options: [])
        } catch let error as NSError {
            print("Atlas cache write failed: \(error.localizedDescription)")
        }
    }
    
    class func generateMipmapsIfRequired (_ context: Context) {
        for atlas in _cache.values {
            if atlas._waitingForMipmaps {
                atlas._waitingForMipmaps = false
                atlas._texture.generateMipmaps(context, completionBlock: { buffer in atlas.ready = true })
            }
        }
    }
}
 
