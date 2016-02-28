//
//  TextRenderer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * Generates a DrawCommand and VerteArray for the required glyphs of the provided String using
 * a FontAtlas. Based on Objective-C code in Moore (2012).
 */

class TextRenderer {
    
    /**
     * Determines if the text is shown.
     *
     * @type {Boolean}
     * @default true
     */
    var show = true
    
    private let _command = DrawCommand()
    
    private let _fontAtlas: FontAtlas
    
    private let _string: String
    
    private let _pointSize: Float
    
    private let _rectangle: BoundingRectangle
    
    init (string: String, fontName: String, color: Color, pointSize: Float, rectangle: BoundingRectangle) {
        
        _string = string
        _pointSize = pointSize
        _rectangle = rectangle
        
        _fontAtlas = FontAtlas.fromCache(fontName: fontName, pointSize: pointSize)
        
        let map = TextRendererUniformMap()
        map.color = color

        _command.uniformMap = map
        _command.owner = self
    }
    
    func update (context: Context, frameState: FrameState) -> DrawCommand? {
       
        if !show {
            return nil
        }
        
        if _command.vertexArray == nil {
            let meshRect = CGRectMake(CGFloat(_rectangle.x), CGFloat(_rectangle.y), CGFloat(_rectangle.width), CGFloat(_rectangle.height))
            _command.vertexArray = buildMesh(context, string: _string, inRect: meshRect, withFontAtlas: _fontAtlas, atSize: _pointSize)
            
            _command.renderState = RenderState(
                device: context.device,
                cullFace: .Front
            )
            
             _command.pipeline = RenderPipeline.withCompiledShader(
                context,
                compiledMetalVertexName: "text_vertex_shade",
                compiledMetalFragmentName: "text_fragment_shade",
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: false
            )
        }
        return _command
    }
    
    private func buildMesh (context: Context, string: String, inRect rect: CGRect, withFontAtlas fontAtlas: FontAtlas, atSize size: Float) -> VertexArray
    {
        
        let attrString = NSMutableAttributedString(string: string)
        let stringRange = CFRangeMake(0, attrString.length)
        
        let font = CTFontCreateCopyWithAttributes(fontAtlas.parentFont, CGFloat(size), nil, nil)
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font)
        
        let rectPath = CGPathCreateWithRect(rect, nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let frame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, nil)
        
        let frameGlyphCount: CFIndex = (CTFrameGetLines(frame) as! [CTLine]).reduce(0, combine: { $0 + CTLineGetGlyphCount($1) })
        //let lines = CTFrameGetLines(frame) as! [CTLine]
        
        /*for line in lines {
         frameGlyphCount += CTLineGetGlyphCount(lineObject)
         }*/
        
        let vertexCount = frameGlyphCount * 4

        var vertices = [Float]()
        var indices = [Int]()
        
        let glyphEnumeratorBlock = { (glyph: CGGlyph, glyphIndex: Int, glyphBounds: CGRect) in
            if Int(glyph) >= fontAtlas.glyphDescriptors.count {
                print("Font atlas has no entry corresponding to glyph \(glyph): Skipping...")
                return
            }
            let glyphInfo = fontAtlas.glyphDescriptors[Int(glyph)]
            let minX = Float(CGRectGetMinX(glyphBounds))
            let maxX = Float(CGRectGetMaxX(glyphBounds))
            let minY = Float(CGRectGetMinY(glyphBounds))
            let maxY = Float(CGRectGetMaxY(glyphBounds))
            let minS = Float(glyphInfo.topLeftTexCoord.x)
            let maxS = Float(glyphInfo.bottomRightTexCoord.x)
            let minT = Float(glyphInfo.topLeftTexCoord.y)
            let maxT = Float(glyphInfo.bottomRightTexCoord.y)
            vertices.appendContentsOf([ minX, maxY, 0, 1, minS, maxT ])
            vertices.appendContentsOf([ minX, minY, 0, 1, minS, minT])
            vertices.appendContentsOf([ maxX, minY, 0, 1, maxS, minT])
            vertices.appendContentsOf([ maxX, maxY, 0, 1, maxS, maxT])
            indices.append(glyphIndex * 4)
            indices.append(glyphIndex * 4 + 1)
            indices.append(glyphIndex * 4 + 2)
            indices.append(glyphIndex * 4 + 2)
            indices.append(glyphIndex * 4 + 3)
            indices.append(glyphIndex * 4)
        }
        enumerateGlyphsInFrame(frame, usingBlock: glyphEnumeratorBlock)
        
        let vertexBuffer = Buffer(device: context.device, array: &vertices, componentDatatype: .Float32, sizeInBytes: vertices.sizeInBytes)
        vertexBuffer.metalBuffer.label =  "Text Mesh Vertices"
        // FIXME geometry with > 64k indices
        
        let indexBuffer: Buffer
        if indices.count < Math.SixtyFourKilobytes {
            let indicesShort = indices.map({ UInt16($0) })
            indexBuffer = Buffer(
                device: context.device,
                array: indicesShort,
                componentDatatype: ComponentDatatype.UnsignedShort,
                sizeInBytes: indicesShort.sizeInBytes)
        } else {
            let indicesInt = indices.map({ UInt32($0) })
            indexBuffer = Buffer(
                device: context.device,
                array: indicesInt,
                componentDatatype: ComponentDatatype.UnsignedInt,
                sizeInBytes: indicesInt.sizeInBytes)
        }
        indexBuffer.metalBuffer.label = "Text Mesh Indices"
        
        let attributes = [
            // attribute vec4 position;
            VertexAttributes(
                buffer: vertexBuffer,
                bufferIndex: 1,
                index: 0,
                format: .Float4,
                offset: 0,
                size: 16,
                normalize: false),
            // attribute vec2 textureCoordinates;
            VertexAttributes(
                buffer: nil,
                bufferIndex: 1,
                index: 1,
                format: .Float2,
                offset: 16,
                size: 8,
                normalize: false)
        ]

        return VertexArray(attributes: attributes, vertexCount: vertexCount, indexBuffer: indexBuffer)
    }
    
}

private class TextRendererUniformMap: UniformMap {
    
    private var color = Color()
    
    let uniforms: [String: UniformFunc] = [
                                              
        "u_color": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! TextRendererUniformMap).color.simdType], sizeof(Float))
        }
    ]
    
}


func enumerateGlyphsInFrame (frame: CTFrame, usingBlock: (glyph: CGGlyph, glyphIndex: Int, glyphBounds: CGRect) -> ()) {
    /*if (!block)
    return;
    
    CFRange entire = CFRangeMake(0, 0);
    
    CGPathRef framePath = CTFrameGetPath(frame);
    CGRect frameBoundingRect = CGPathGetPathBoundingBox(framePath);
    
    NSArray *lines = (__bridge id)CTFrameGetLines(frame);
    
    CGPoint *lineOriginBuffer = malloc(lines.count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frame, entire, lineOriginBuffer);
    
    __block CFIndex glyphIndexInFrame = 0;
    
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [lines enumerateObjectsUsingBlock:^(id lineObject, NSUInteger lineIndex, BOOL *stop) {
        CTLineRef line = (__bridge CTLineRef)lineObject;
        CGPoint lineOrigin = lineOriginBuffer[lineIndex];
        
        NSArray *runs = (__bridge id)CTLineGetGlyphRuns(line);
        [runs enumerateObjectsUsingBlock:^(id runObject, NSUInteger rangeIndex, BOOL *stop) {
        CTRunRef run = (__bridge CTRunRef)runObject;
        
        size_t glyphCount = CTRunGetGlyphCount(run);
        
        CGGlyph *glyphBuffer = malloc(glyphCount * sizeof(CGGlyph));
        CTRunGetGlyphs(run, entire, glyphBuffer);
        
        CGPoint *positionBuffer = malloc(glyphCount * sizeof(CGPoint));
        CTRunGetPositions(run, entire, positionBuffer);
        
        for (size_t glyphIndex = 0; glyphIndex < glyphCount; ++glyphIndex)
        {
        CGGlyph glyph = glyphBuffer[glyphIndex];
        CGPoint glyphOrigin = positionBuffer[glyphIndex];
        CGRect glyphRect = CTRunGetImageBounds(run, context, CFRangeMake(glyphIndex, 1));
        CGFloat boundsTransX = frameBoundingRect.origin.x + lineOrigin.x;
        CGFloat boundsTransY = CGRectGetHeight(frameBoundingRect) + frameBoundingRect.origin.y - lineOrigin.y + glyphOrigin.y;
        CGAffineTransform pathTransform = CGAffineTransformMake(1, 0, 0, -1, boundsTransX, boundsTransY);
        glyphRect = CGRectApplyAffineTransform(glyphRect, pathTransform);
        block(glyph, glyphIndexInFrame, glyphRect);
        
        ++glyphIndexInFrame;
        }
        
        free(positionBuffer);
        free(glyphBuffer);
        }];
        }];
    
    UIGraphicsEndImageContext();*/
}
