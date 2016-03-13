//
//  TextRenderer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import simd

private struct TextUniforms {
    var modelMatrix: float4x4 = Matrix4.identity.floatRepresentation
    var viewProjectionMatrix: float4x4 = Matrix4.identity.floatRepresentation
    var foregroundColor: float4 = Color().floatRepresentation
}

/**
 * Generates a DrawCommand and VerteArray for the required glyphs of the provided String using
 * a FontAtlas. Based on Objective-C code from [Moore (2015)](http://metalbyexample.com/rendering-text-in-metal-with-signed-distance-fields/).
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
    
    var string: String
    
    private var _string: String = " "
    
    var rectangle: BoundingRectangle
    
    private var _rectangle = BoundingRectangle(x: Double.infinity, y: Double.infinity, width: Double.infinity, height: Double.infinity)
    
    private let _pointSize: Int
    
    private var _rs: RenderState! = nil
    
    private var _uniforms = TextUniforms()
    
    private let _attributes = [
        // attribute vec4 position;
        VertexAttributes(
            buffer: nil,
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
    
    init (context: Context, string: String, fontName: String, color: Color, pointSize: Int, rectangle: BoundingRectangle) {
        
        self.string = string
        _pointSize = pointSize
        self.rectangle = rectangle
        
        _fontAtlas = FontAtlas.fromCache(context, fontName: fontName, pointSize: pointSize)
        
        _uniforms.foregroundColor = color.floatRepresentation
        
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
            vertexDescriptor: VertexDescriptor(attributes: _attributes),
            depthStencil: context.depthTexture,
            blendingState: blendingState
        )
        
        _command.metalUniformUpdateBlock = { buffer in
            self._uniforms.viewProjectionMatrix = context.uniformState.viewportOrthographic.floatRepresentation
            /*uniforms.foregroundColor = MBETextColor;*/
            
            memcpy(buffer.data, &self._uniforms, sizeof(TextUniforms))
            
            return [self._fontAtlas.texture].flatMap( { $0 })
        }
        
        _command.uniformMap = nil
        _command.owner = self
    }
    
    func update (frameState: FrameState) -> DrawCommand? {
       
        if !show || !_fontAtlas.ready {
            return nil
        }
        let context = frameState.context
        
        if _rs == nil || _rectangle != rectangle {
            _rs = RenderState(
                device: context.device,
                viewport: rectangle
            )
            _rectangle = rectangle
            _command.renderState = _rs
            _command.vertexArray = nil
        }

        if _command.vertexArray == nil || string != _string {
            let meshRect = CGRect(x: CGFloat(rectangle.x), y: CGFloat(rectangle.y), width: CGFloat(rectangle.width), height: CGFloat(rectangle.height))
            _command.vertexArray = buildMesh(context, string: string, inRect: meshRect, withFontAtlas: _fontAtlas, atSize: _pointSize)
            
            _string = string
        }
        
        //frameState.commandList.append(_command)
        return _command
    }
    
    private func buildMesh (context: Context, string: String, inRect rect: CGRect, withFontAtlas fontAtlas: FontAtlas, atSize size: Int) -> VertexArray
    {
        
        let attrString = NSMutableAttributedString(string: string)
        let stringRange = CFRangeMake(0, attrString.length)
        
        //let features = CTFontCopyFeatures(font) as NSArray?
        //let settings = CTFontCopyFeatureSettings(font) as NSArray?
        //print(features)
        //print(settings)
        /*let descriptor = CTFontCopyFontDescriptor(fontAtlas.parentFont)
        
        let monspacedFontDict = ([kNumberSpacingType: kMonospacedNumbersSelector] as NSDictionary) as CFDictionary
        let monspacedTextDict = ([kTextSpacingType: kMonospacedTextSelector] as NSDictionary) as CFDictionary

        let featureArray = [monspacedFontDict, monspacedTextDict] as NSArray
        
        let attributeDict = ([(kCTFontFeatureSettingsAttribute as NSString): featureArray] as NSDictionary) as CFDictionary
        
        let newDescriptor = CTFontDescriptorCreateWithAttributes(attributeDict)

        let font = CTFontCreateCopyWithAttributes(fontAtlas.parentFont, CGFloat(size), nil, newDescriptor)*/
        let font = CTFontCreateCopyWithAttributes(fontAtlas.parentFont, CGFloat(size), nil, nil)

        
        let features = CTFontCopyFeatures(font) as NSArray?
        let settings = CTFontCopyFeatureSettings(font) as NSArray?
        
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font)
        
        let rectPath = CGPathCreateWithRect(rect, nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let frame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, nil)
        
        let frameGlyphCount: CFIndex = ((CTFrameGetLines(frame) as NSArray) as! [CTLine]).reduce(0, combine: { $0 + CTLineGetGlyphCount($1) })
        
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
        
        var attributes = _attributes
        attributes[0].buffer = vertexBuffer

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
