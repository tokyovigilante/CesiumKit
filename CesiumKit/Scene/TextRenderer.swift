//
//  TextRenderer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import simd

private struct TextUniformStruct: UniformStruct {
    var modelMatrix: float4x4 = Matrix4.identity.floatRepresentation
    var viewProjectionMatrix: float4x4 = Matrix4.identity.floatRepresentation
    var foregroundColor: float4 = Color().floatRepresentation
}

class TextUniformMap: NativeUniformMap {
    
    //FIXME: color etc here
    var modelMatrix: Matrix4 {
        get {
            return Matrix4(simd: double4x4([
                vector_double(_uniformStruct.modelMatrix[0]),
                vector_double(_uniformStruct.modelMatrix[1]),
                vector_double(_uniformStruct.modelMatrix[2]),
                vector_double(_uniformStruct.modelMatrix[3])
                ]))
        }
        set {
            _uniformStruct.modelMatrix = newValue.floatRepresentation
        }
    }
    
    var viewProjectionMatrix: Matrix4 {
        get {
            return Matrix4(simd: double4x4([
                vector_double(_uniformStruct.viewProjectionMatrix[0]),
                vector_double(_uniformStruct.viewProjectionMatrix[1]),
                vector_double(_uniformStruct.viewProjectionMatrix[2]),
                vector_double(_uniformStruct.viewProjectionMatrix[3])
                ]))
        }
        set {
            _uniformStruct.viewProjectionMatrix = newValue.floatRepresentation
        }
    }
    
    var foregroundColor: Color {
        get {
            return Color(simd: vector_double(_uniformStruct.foregroundColor))
        }
        set {
            _uniformStruct.foregroundColor = newValue.floatRepresentation
        }
    }
    
    var uniformBufferProvider: UniformBufferProvider! = nil
    
    private var _fontAtlasTexture: Texture! = nil

    private var _uniformStruct = TextUniformStruct()
    
    // compiled shader doesn't need to generate struct at runtime
    let uniformDescriptors: [UniformDescriptor] = []
    
    private (set) var uniformUpdateBlock: UniformUpdateBlock! = nil
    
    init () {
        uniformUpdateBlock = { buffer in
            buffer.write(from: &self._uniformStruct, length: sizeof(TextUniformStruct))
            return [self._fontAtlasTexture!]
        }
    }
}


/**
 * Generates a DrawCommand and VerteArray for the required glyphs of the provided String using
 * a FontAtlas. Based on Objective-C code from [Moore (2015)](http://metalbyexample.com/rendering-text-in-metal-with-signed-distance-fields/).
 */
public class TextRenderer: Primitive {
   
    public var color: Color

    public var string: String {
        didSet {
            _updateMesh = true
        }
    }
    
    public var viewportRect: Cartesian4 {
        didSet {
            _updateMetrics = true
        }
    }
    
    public var pointSize: Int {
        didSet {
            _updateMesh = true
        }
    }
    
    private var _updateMesh: Bool = true
    private var _updateMetrics: Bool = false
    
    public private (set) var meshSize: Cartesian2 = Cartesian2()

    private let _command = DrawCommand()
    
    private var _fontAtlas: FontAtlas! = nil
    
    let fontName: String
    
    private var _rs: RenderState! = nil
    
    private let _offscreenTarget: Bool
    
    private let _blendingState: BlendingState
    
    private let _attributes = [
        // attribute vec4 position;
        VertexAttributes(
            buffer: nil,
            bufferIndex: VertexDescriptorFirstBufferOffset,
            index: 0,
            format: .Float4,
            offset: 0,
            size: 16,
            normalize: false),
        // attribute vec2 textureCoordinates;
        VertexAttributes(
            buffer: nil,
            bufferIndex: VertexDescriptorFirstBufferOffset,
            index: 1,
            format: .Float2,
            offset: 16,
            size: 8,
            normalize: false)
    ]
    
    public init (string: String, fontName: String, color: Color, pointSize: Int, viewportRect: Cartesian4, offscreenTarget: Bool = false) {
        
        self.string = string
        self.fontName = fontName
        self.color = color
        self.pointSize = pointSize
        self.viewportRect = viewportRect
        _offscreenTarget = offscreenTarget
        _blendingState = BlendingState(
            enabled: true,
            equationRgb: .Add,
            equationAlpha: .Add,
            functionSourceRgb: .SourceAlpha,
            functionSourceAlpha: .SourceAlpha,
            functionDestinationRgb: .OneMinusSourceAlpha,
            functionDestinationAlpha: .OneMinusSourceAlpha,
            color: nil
        )
        _command.pass = .OverlayText
        _command.uniformMap = TextUniformMap()

        super.init()
        
        let meshCGSize = computeSize()
        meshSize = Cartesian2(x: Double(meshCGSize.width), y: Double(meshCGSize.height))
        
        _command.owner = self
    }
    
    override func update (inout frameState: FrameState) {
       
        let context = frameState.context

        if _fontAtlas == nil {
            _fontAtlas = FontAtlas.fromCache(context, fontName: fontName, pointSize: pointSize)
        }
        
        guard let map = _command.uniformMap as? TextUniformMap else {
            return
        }
        
        if !show || !_fontAtlas.ready {
            return
        }

        map._fontAtlasTexture = _fontAtlas.texture

        if _command.pipeline == nil {
            _command.pipeline = RenderPipeline.withCompiledShader(
                context,
                shaderSourceName: "TextRenderer",
                compiledMetalVertexName: "text_vertex_shade",
                compiledMetalFragmentName: "text_fragment_shade",
                uniformStructSize: strideof(TextUniformStruct),
                vertexDescriptor: VertexDescriptor(attributes: _attributes),
                depthStencil: _offscreenTarget ? false : context.depthTexture,
                blendingState: _blendingState
            )
            map.uniformBufferProvider = _command.pipeline!.shaderProgram.createUniformBufferProvider(context.device, deallocationBlock: nil)
        }
        
        if _rs == nil || _updateMesh {
            
            _updateMetrics = true
            
            let renderRectangle: Cartesian4
            
            let meshCGSize = computeSize()
            meshSize = Cartesian2(x: Double(meshCGSize.width), y: Double(meshCGSize.height))
            
            _rs = RenderState(
                device: context.device,
                viewport: viewportRect
            )
            
            _command.renderState = _rs

            let meshRect = CGRect(x: 0, y: 0, width: meshCGSize.width, height: meshCGSize.height)
            _command.vertexArray = buildMesh(context, string: string, inRect: meshRect, withFontAtlas: _fontAtlas, atSize: Int(Double(pointSize)))
            
            _updateMesh = false
        }
        
        if _updateMetrics {
            map.viewProjectionMatrix = Matrix4.computeOrthographicOffCenter(left: 0, right: viewportRect.width, bottom: 0, top: viewportRect.height)
            _updateMetrics = false
        }
        
        map.foregroundColor = color
        
        
        frameState.commandList.append(_command)
    }

    private func computeSize () -> CGSize {
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), string)
        let font = CTFontCreateWithName(fontName, CGFloat(pointSize), nil)
        let stringRange = CFRangeMake(0, CFAttributedStringGetLength(attrString))
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        var fitRange = CFRangeMake(0, 0)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSizeMake(CGFloat.max, CGFloat.max), &fitRange)
        
        assert(stringRange == fitRange, "Core Text layout failed")
        return textSize
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

        return VertexArray(attributes: attributes, vertexCount: vertexCount, indexBuffer: indexBuffer, indexCount: indices.count)
    }
    
    private func enumerateGlyphsInFrame (frame: CTFrame, usingBlock block: (glyph: CGGlyph, glyphIndex: Int, glyphBounds: CGRect) -> ()) {
        
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
