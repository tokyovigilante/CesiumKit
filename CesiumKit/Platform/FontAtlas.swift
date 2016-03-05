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

// FIXME: Debug
import AppKit

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
enum FontAtlasError: ErrorType, CustomStringConvertible {
    /// Thrown when the provided JSON is invalid.
    /// - Parameter json: The provided JSON.
    /// - Parameter message: Optional error message.
    case InvalidJSONError(json: JSON, message: String?)

    /// Thrown when texture data cannot be loaded from file.
    /// Parameter path: The texture data path.
    /// - Parameter message: Optional error message.
    case InvalidTextureDataError(path: String, message: String?)
    
    var description: String {
        switch self {
            case let .InvalidJSONError(json, message): return "Invalid JSON - \(message): \(JSON.encodeAsString(json))"
            case let .InvalidTextureDataError(path, message): return "Invalid texture data - \(message): path \(path)"
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
    
    private (set) var texture: Texture! = nil
    
    private var MBE_GENERATE_DEBUG_ATLAS_IMAGE = true

    /// Create a signed-distance field based font atlas with the specified dimensions.
    /// The supplied font will be resized to fit all available glyphs in the texture.
    private init (context: Context, fontName: String, pointSize: Int, textureSize: Int = MBEFontAtlasSize) {
        parentFont = CTFontCreateWithName(fontName, CGFloat(pointSize), nil)
        _fontPointSize = Int(ceilf(Float(pointSize)))
        _textureSize = textureSize
        _spread = estimatedLineWidthForFont(parentFont) * 0.5
        createTextureData()
        createTexture(context)
    }
    
    internal convenience init (fromJSON json: JSON, context: Context) throws {
        try self.init(fromJSON: json)
        createTexture(context)
    }
    
    internal init(fromJSON json: JSON) throws {
        let fontName = try json.getString(FontNameKey)
        _fontPointSize = try json.getInt(PointSizeKey)
        _spread = try json.getDouble(FontSpreadKey)
        
        if _fontPointSize <= 0 || fontName == "" {
            throw FontAtlasError.InvalidJSONError(json: json, message: "Invalid persisted font (invalid font name or size)")
        }
        parentFont = CTFontCreateWithName(fontName, CGFloat(_fontPointSize), nil)
        
        glyphDescriptors = try json
            .getArray(GlyphDescriptorsKey)
            .map { try GlyphDescriptor(fromJSON: $0) }
            .sort { $0.glyphIndex < $1.glyphIndex }
        
        if glyphDescriptors.count <= 0 {
            throw FontAtlasError.InvalidJSONError(json: json, message: "Encountered invalid persisted font (no glyph metrics).")
        }
        
        _textureSize = try json.getInt(TextureSizeKey)
        let textureDataPath = try json.getString(TextureDataPathKey)
        
        guard let textureData = NSData(contentsOfFile: textureDataPath) else {
            throw FontAtlasError.InvalidTextureDataError(path: textureDataPath, message: "No texture data at path.")
        }
        if textureData.length <= 0 {
            throw FontAtlasError.InvalidTextureDataError(path: textureDataPath, message: "Texture data too short.")
        }
        _textureData = textureData.getUInt8Array()
    }
/*

    - (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.parentFont.fontName forKey:MBEFontNameKey];
    [aCoder encodeFloat:self.fontPointSize forKey:MBEFontSizeKey];
    [aCoder encodeFloat:self.spread forKey:MBEFontSpreadKey];
    [aCoder encodeObject:self.textureData forKey:MBETextureDataKey];
    [aCoder encodeInt64:self.textureSize forKey:MBETextureWidthKey];
    [aCoder encodeInt64:self.textureSize forKey:MBETextureHeightKey];
    [aCoder encodeObject:self.glyphDescriptors forKey:MBEGlyphDescriptorsKey];
    }
    
    + (BOOL)supportsSecureCoding
        {
            return YES;
        }*/
    
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
    
    private func estimatedGlyphSizeForFont (font: CTFont) -> CGSize {
    
        let exemplarString = "{ǺOJMQYZa@jmqyw"
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), exemplarString)
        
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        var fitRange = CFRange()
        let exemplarStringSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSizeMake(CGFloat.max, CGFloat.max), &fitRange)

        let averageGlyphWidth = CGFloat(ceilf(Float(exemplarStringSize.width) / Float(CFAttributedStringGetLength(attrString))))
        let maxGlyphHeight = CGFloat(ceilf(Float(exemplarStringSize.height)))
    
        return CGSizeMake(averageGlyphWidth, maxGlyphHeight)
    }
    
    private func estimatedLineWidthForFont (font: CTFont) -> Double {
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), "!")
        
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        var fitRange = CFRangeMake(0, 0)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSizeMake(CGFloat.max, CGFloat.max), &fitRange)

        return ceil(Double(textSize.width))
    }
    
    private func isLikelyToFitInAtlasRect (rect: CGRect, forFont font: CTFont, atSize size: Int) -> Bool {
        
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
    
    private func createAtlasForFont (font: CTFont, width: Int, height: Int) -> [UInt8] {
        
        var imageData = [UInt8](count: width * height, repeatedValue: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let alphaInfo = CGImageAlphaInfo.None
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        
        let context = CGBitmapContextCreate(&imageData,
        width,
        height,
        8,
        width,
        colorSpace,
        bitmapInfo.rawValue)
        
        // Turn off antialiasing so we only get fully-on or fully-off pixels.
        // This implicitly disables subpixel antialiasing and hinting.
        CGContextSetAllowsAntialiasing(context, false)
        
        // Flip context coordinate space so y increases downward
        CGContextTranslateCTM(context, 0, CGFloat(height))
        CGContextScaleCTM(context, 1, -1)
        
        let fWidth = CGFloat(width)
        let fHeight = CGFloat(height)
        
        // Fill the context with an opaque black color
        CGContextSetRGBFillColor(context, 0, 0, 0, 1)
        CGContextFillRect(context, CGRectMake(0, 0, fWidth, fHeight))
        
        _fontPointSize = pointSizeThatFits(forFont: font, inAtlasRect: CGRectMake(0, 0, fWidth, fHeight))
        parentFont = CTFontCreateCopyWithAttributes(parentFont, CGFloat(_fontPointSize), nil, nil)

        let fontGlyphCount = CTFontGetGlyphCount(parentFont)
        
        let glyphMargin = CGFloat(estimatedLineWidthForFont(parentFont))
        
        // Set fill color so that glyphs are solid white
        CGContextSetRGBFillColor(context, 1, 1, 1, 1)
        
        glyphDescriptors.removeAll()
        
        let fontAscent = CTFontGetAscent(parentFont)
        let fontDescent = CTFontGetDescent(parentFont)
        
        var origin = CGPointMake(0, fontAscent)
        var maxYCoordForLine: CGFloat = -1
        
        for glyph in 0..<UInt16(fontGlyphCount) {
            
            var boundingRect = CGRect()
            CTFontGetBoundingRectsForGlyphs(parentFont, CTFontOrientation.Horizontal, [glyph], &boundingRect, 1)
            
            if (origin.x + CGRectGetMaxX(boundingRect) + glyphMargin > fWidth) {
                origin.x = 0
                origin.y = maxYCoordForLine + glyphMargin + fontDescent
                maxYCoordForLine = -1
            }
            
            if origin.y + CGRectGetMaxY(boundingRect) > maxYCoordForLine {
                maxYCoordForLine = origin.y + CGRectGetMaxY(boundingRect)
            }
            
            let glyphOriginX = origin.x - boundingRect.origin.x + (glyphMargin * 0.5)
            let glyphOriginY = origin.y + (glyphMargin * 0.5)
            
            var glyphTransform = CGAffineTransformMake(1, 0, 0, -1, glyphOriginX, glyphOriginY)
            
            let path = CTFontCreatePathForGlyph(parentFont, glyph, &glyphTransform)
            CGContextAddPath(context, path)
            CGContextFillPath(context)
            
            var glyphPathBoundingRect = CGPathGetPathBoundingBox(path)
        
            // The null rect (i.e., the bounding rect of an empty path) is problematic
            // because it has its origin at (+inf, +inf); we fix that up here
            if CGRectEqualToRect(glyphPathBoundingRect, CGRectNull) {
                glyphPathBoundingRect = CGRectZero
            }
            
            let texCoordLeft = glyphPathBoundingRect.origin.x / fWidth
            let texCoordRight = (glyphPathBoundingRect.origin.x + glyphPathBoundingRect.size.width) / fWidth
            let texCoordTop = (glyphPathBoundingRect.origin.y) / fHeight
            let texCoordBottom = (glyphPathBoundingRect.origin.y + glyphPathBoundingRect.size.height) / fHeight
            
            let descriptor = GlyphDescriptor(
                glyphIndex: glyph,
                topLeftTexCoord: CGPointMake(texCoordLeft, texCoordTop),
                bottomRightTexCoord: CGPointMake(texCoordRight, texCoordBottom)
            )
            glyphDescriptors.append(descriptor)
            
            origin.x += CGRectGetWidth(boundingRect) + glyphMargin
        }
        
        if MBE_GENERATE_DEBUG_ATLAS_IMAGE {
            guard let contextImage = CGBitmapContextCreateImage(context) else {
                assertionFailure("Could not create debug font atlas image")
                return [UInt8]()
            }
            // Break here to view the generated font atlas bitmap
            let fontImage = NSImage(CGImage: contextImage, size: NSSize(width: fWidth, height: fHeight))
            print(fontImage)
            //UIImage *fontImage = [UIImage imageWithCGImage:contextImage];
        }
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
        var distanceMap = [Float](count: width * height, repeatedValue: maxDist) // distance to nearest boundary point map
        var boundaryPointMap = [IntPoint](count: width * height, repeatedValue: IntPoint(x: 0, y: 0)) // nearest boundary point map
        
        // Some helpers for manipulating the above arrays
        func image(x: Int, _ y: Int) -> Bool { return imageData[y * width + x] > 0x7f }
        func distance(x: Int, _ y: Int) -> Float { return distanceMap[y * width + x] }
        func nearestpt(x: Int, _ y: Int) -> IntPoint { return boundaryPointMap[y * width + x] }
        func setDistance(x: Int, _ y: Int, distance: Float) { distanceMap[y * width + x] = distance }
        func setNearestpt(x: Int, _ y: Int, point: IntPoint) { boundaryPointMap[y * width + x] = point }
        
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
        for y in (height-2).stride(through: 1, by: 1) {
            for x in (width-2).stride(through: 1, by: 1) {
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
        var outData = [Float](count: scaledWidth * scaledHeight, repeatedValue: 0.0)
        
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
        var outData = [UInt8](count: width * height, repeatedValue: 0)
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
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let alphaInfo = CGImageAlphaInfo.None
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        
        let bufferLength = _textureSize * _textureSize * 4
        let provider = CGDataProviderCreateWithData(nil, _textureData, bufferLength, nil)
        let bitsPerComponent = 8
        let bitsPerPixel = 8
        let renderingIntent =  CGColorRenderingIntent.RenderingIntentDefault
        
        let iref = CGImageCreate(_textureSize,
                                 _textureSize,
                                 bitsPerComponent,
                                 bitsPerPixel,
                                 _textureSize,
                                 colorSpace,
                                 bitmapInfo,
                                 provider,   // data provider
            nil,       // decode
            true,        // should interpolate
            renderingIntent)
        
        let image = NSImage(CGImage: iref!, size:NSMakeSize(CGFloat(_textureSize), CGFloat(_textureSize)))
        print(image)
    }
    
    func createTexture (context: Context) {
        let imageBuffer = Imagebuffer(
            array: _textureData,
            width: _textureSize,
            height: _textureSize,
            bytesPerPixel: 1)
        let source: TextureSource = .Buffer(imageBuffer)
        let sampler = Sampler(context: context, wrapS: .ClampToZero, wrapT: .ClampToZero)
        let options = TextureOptions(
            source: source,
            pixelFormat: .R8Unorm,
            usage: TextureUsage.ShaderRead,
            sampler: sampler)
        texture = Texture(context: context, options: options)
    }
    
    class func fromCache(context: Context, fontName: String, pointSize: Int) -> FontAtlas {
        let cacheName = "\(fontName)"
        
        if let atlas = _cache[cacheName] {
            return atlas
        }
        
        // try to decode from JSON
        let atlasFolder = LocalStorage.sharedInstance.getDocumentFolder() + "/FontAtlases"
        
        let jsonPath = atlasFolder + "/\(cacheName).json"
        if let atlasJSONData = NSData(contentsOfFile: jsonPath) {
            do {
                let atlasJSON = try JSON.decode(atlasJSONData)
                return try FontAtlas(fromJSON: atlasJSON, context: context)
            } catch let error as NSError {
                print("cannot create font atlas from cache: \(error.localizedDescription)")
            }
        }
        // build from scratch
        let atlas = FontAtlas(context: context, fontName: fontName, pointSize: pointSize)

        // add to cache 
        _cache[cacheName] = atlas

        // encode and save
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(atlasFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("cannot create directory at path: \(atlasFolder): \(error.localizedDescription)")
        }

        var atlasJSON = atlas.toJSON().object!
        
        let textureDataPath = atlasFolder + "/\(cacheName).textureData"
        atlasJSON[TextureDataPathKey] = JSON(stringLiteral: textureDataPath)
        
        do {
            try JSON
                .encodeAsString(JSON.Object(atlasJSON))
                .writeToFile(jsonPath, atomically: true, encoding: NSUTF8StringEncoding)
            if NSData
                .fromUInt8Array(atlas._textureData)
                .writeToFile(textureDataPath, atomically: true) == false {
                throw FontAtlasError.InvalidTextureDataError(path: textureDataPath, message: "Cannot write texture data to file")
            }
        } catch let error as NSError {
            print("cannot write json to cache: \(error.localizedDescription)")
        }
        return atlas
    }
}
 