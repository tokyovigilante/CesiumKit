//
//  TextRenderer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
 * Generates a DrawCommand and VerteArray for the required glyphs of the provided String using
 * a FontAtlas. Based on Objective-C code in Moore (2012).
 */

private struct TextUniforms {
    var modelMatrix: float4x4 = Matrix4.identity.floatRepresentation
    var viewProjectionMatrix: float4x4 = Matrix4.identity.floatRepresentation
    var foregroundColor: float4 = Color().floatRepresentation
}

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
    
    private let _pointSize: Int
    
    private let _rectangle: BoundingRectangle
    
    private var _rs: RenderState! = nil
    
    private var _uniforms = TextUniforms()
    
    init (context: Context, string: String, fontName: String, color: Color, pointSize: Int, rectangle: BoundingRectangle) {
        
        _string = string
        _pointSize = pointSize
        _rectangle = rectangle
        
        _fontAtlas = FontAtlas.fromCache(context, fontName: fontName, pointSize: pointSize)
        
        _uniforms.foregroundColor = color.floatRepresentation
        
        _command.uniformMap = nil
        _command.owner = self
    }
    
    func update (frameState: FrameState) -> DrawCommand? {
       
        if !show {
            return nil
        }
        let context = frameState.context
        
        if _rs == nil || _rs.viewport != _rectangle {
            _rs = RenderState(
                device: context.device,
                viewport : _rectangle
            )
            _command.renderState = _rs
        }

        if _command.vertexArray == nil {
            let meshRect = CGRectMake(CGFloat(_rectangle.x), CGFloat(_rectangle.y), CGFloat(_rectangle.width), CGFloat(_rectangle.height))
            _command.vertexArray = buildMesh(context, string: _string, inRect: meshRect, withFontAtlas: _fontAtlas, atSize: _pointSize)
            
            _command.renderState = _rs
            
            let blendingState = BlendingState(
                enabled: true,
                equationRgb: .Add,
                equationAlpha: .Add,
                functionSourceRgb: .SourceAlpha,
                functionSourceAlpha: .SourceAlpha,
                functionDestinationRgb: .OneMinusSourceAlpha,
                functionDestinationAlpha: .OneMinusSourceAlpha,
                color: nil
            )
            
            _command.pipeline = RenderPipeline.withCompiledShader(
                context,
                shaderSourceName: "TextRenderer",
                compiledMetalVertexName: "text_vertex_shade",
                compiledMetalFragmentName: "text_fragment_shade",
                uniformStructSize: strideof(TextUniforms),
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: context.depthTexture,
                blendingState: blendingState
            )
            
            _command.metalUniformUpdateBlock = { (buffer: Buffer) in
                /*CGSize drawableSize = self.layer.drawableSize;
                
                MBEUniforms uniforms;
                
                vector_float3 translation = { self.textTranslation.x, self.textTranslation.y, 0 };
                vector_float3 scale = { self.textScale, self.textScale, 1 };
                matrix_float4x4 modelMatrix = matrix_multiply(matrix_translation(translation), matrix_scale(scale));
                uniforms.modelMatrix = modelMatrix;
                 
                */
                //matrix_float4x4 projectionMatrix = matrix_orthographic_projection(0, drawableSize.width, 0, drawableSize.height);
                self._uniforms.viewProjectionMatrix = frameState.context.uniformState.viewportOrthographic.floatRepresentation
                
                
                /*uniforms.foregroundColor = MBETextColor;*/
                
                memcpy(buffer.data, &self._uniforms, sizeof(TextUniforms))

                return [self._fontAtlas.texture]
            }
        }
        //frameState.commandList.append(_command)
        return _command
    }
    
    private func buildMesh (context: Context, string: String, inRect rect: CGRect, withFontAtlas fontAtlas: FontAtlas, atSize size: Int) -> VertexArray
    {
        
        let attrString = NSMutableAttributedString(string: string)
        let stringRange = CFRangeMake(0, attrString.length)
        
        let font = CTFontCreateCopyWithAttributes(fontAtlas.parentFont, CGFloat(size), nil, nil)
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font)
        
        let rectPath = CGPathCreateWithRect(rect, nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let frame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, nil)
        
        //let frameGlyphCount: CFIndex = (CTFrameGetLines(frame) as! [CTLine]).reduce(0, combine: { $0 + CTLineGetGlyphCount($1) })
        var frameGlyphCount: CFIndex = 0
        let lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
        
        for line in lines {
            frameGlyphCount += CTLineGetGlyphCount(line)
        }
        
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
            let minT = Float(glyphInfo.bottomRightTexCoord.y)
            let maxT = Float(glyphInfo.topLeftTexCoord.y)
            vertices.appendContentsOf([ minX, maxY, 0, 1, minS, maxT])
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
    
    
    func enumerateGlyphsInFrame (frame: CTFrame, usingBlock block: (glyph: CGGlyph, glyphIndex: Int, glyphBounds: CGRect) -> ()) {
        
        let entire = CFRangeMake(0, 0)
        
        let framePath = CTFrameGetPath(frame)
        let frameBoundingRect = CGPathGetPathBoundingBox(framePath)
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
        
        var lineOriginBuffer = [CGPoint](count: lines.count, repeatedValue: CGPoint())
        CTFrameGetLineOrigins(frame, entire, &lineOriginBuffer)
        
        var glyphIndexInFrame: CFIndex = 0
        
        //UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        //CGContextRef context = UIGraphicsGetCurrentContext();
        
        for (lineIndex, line) in lines.enumerate() {
            let lineOrigin = lineOriginBuffer[lineIndex]
            
            let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
            
            for run in runs {
                
                let glyphCount = CTRunGetGlyphCount(run)
                
                var glyphBuffer = [CGGlyph](count: glyphCount, repeatedValue: 0)
                CTRunGetGlyphs(run, entire, &glyphBuffer);
                
                var positionBuffer = [CGPoint](count: glyphCount, repeatedValue: CGPoint())
                CTRunGetPositions(run, entire, &positionBuffer);
                
                for glyphIndex in 0..<glyphCount {
                    
                    let glyph = glyphBuffer[glyphIndex]
                    let glyphOrigin = positionBuffer[glyphIndex]
                    var glyphRect = CTRunGetImageBounds(run, nil, CFRangeMake(glyphIndex, 1))
                    
                    let boundsTransX = frameBoundingRect.origin.x + lineOrigin.x
                    let boundsTransY = frameBoundingRect.origin.y + lineOrigin.y + glyphOrigin.y
                    let pathTransform = CGAffineTransformMake(1, 0, 0, 1, boundsTransX, boundsTransY)
                    
                    glyphRect = CGRectApplyAffineTransform(glyphRect, pathTransform)
                    
                    block(glyph: glyph, glyphIndex: glyphIndexInFrame, glyphBounds: glyphRect)
                    
                    glyphIndexInFrame += 1
                }
            }
        }
    }
    
}
