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
                simd_double(_uniformStruct.modelMatrix[0]),
                simd_double(_uniformStruct.modelMatrix[1]),
                simd_double(_uniformStruct.modelMatrix[2]),
                simd_double(_uniformStruct.modelMatrix[3])
                ]))
        }
        set {
            _uniformStruct.modelMatrix = newValue.floatRepresentation
        }
    }
    
    var viewProjectionMatrix: Matrix4 {
        get {
            return Matrix4(simd: double4x4([
                simd_double(_uniformStruct.viewProjectionMatrix[0]),
                simd_double(_uniformStruct.viewProjectionMatrix[1]),
                simd_double(_uniformStruct.viewProjectionMatrix[2]),
                simd_double(_uniformStruct.viewProjectionMatrix[3])
                ]))
        }
        set {
            _uniformStruct.viewProjectionMatrix = newValue.floatRepresentation
        }
    }
    
    var foregroundColor: Color {
        get {
            return Color(simd: simd_double(_uniformStruct.foregroundColor))
        }
        set {
            _uniformStruct.foregroundColor = newValue.floatRepresentation
        }
    }
    
    var uniformBufferProvider: UniformBufferProvider! = nil
    
    fileprivate var _fontAtlasTexture: Texture! = nil

    fileprivate var _uniformStruct = TextUniformStruct()
    
    // compiled shader doesn't need to generate struct at runtime
    let uniformDescriptors: [UniformDescriptor] = []
    
    lazy var uniformUpdateBlock: UniformUpdateBlock = { buffer in
        buffer.write(from: &self._uniformStruct, length: MemoryLayout<TextUniformStruct>.size)
        return [self._fontAtlasTexture!]
    }

}


/**
 * Generates a DrawCommand and VerteArray for the required glyphs of the provided String using
 * a FontAtlas. Based on Objective-C code from [Moore (2015)](http://metalbyexample.com/rendering-text-in-metal-with-signed-distance-fields/).
 */
open class TextRenderer: Primitive {
   
    open var color: Color

    open var string: String {
        didSet {
            _updateMesh = true
        }
    }
    
    open var viewportRect: Cartesian4 {
        didSet {
            _updateMetrics = true
        }
    }
    
    open var pointSize: Int {
        didSet {
            _updateMesh = true
        }
    }
    
    fileprivate var _updateMesh: Bool = true
    fileprivate var _updateMetrics: Bool = false
    
    open fileprivate (set) var meshSize: Cartesian2 = Cartesian2()

    fileprivate let _command = DrawCommand()
    
    fileprivate var _fontAtlas: FontAtlas! = nil
    
    let fontName: String
    
    //private var _rs: RenderState! = nil
    
    fileprivate let _offscreenTarget: Bool
    
    fileprivate let _blendingState: BlendingState
    
    fileprivate let _attributes = [
        // attribute vec4 position;
        VertexAttributes(
            buffer: nil,
            bufferIndex: VertexDescriptorFirstBufferOffset,
            index: 0,
            format: .float4,
            offset: 0,
            size: 16,
            normalize: false),
        // attribute vec2 textureCoordinates;
        VertexAttributes(
            buffer: nil,
            bufferIndex: VertexDescriptorFirstBufferOffset,
            index: 1,
            format: .float2,
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
            equationRgb: .add,
            equationAlpha: .add,
            functionSourceRgb: .sourceAlpha,
            functionSourceAlpha: .sourceAlpha,
            functionDestinationRgb: .oneMinusSourceAlpha,
            functionDestinationAlpha: .oneMinusSourceAlpha,
            color: nil
        )
        _command.pass = .overlayText
        _command.uniformMap = TextUniformMap()

        super.init()
        
        let meshCGSize = computeSize()
        meshSize = Cartesian2(x: Double(meshCGSize.width), y: Double(meshCGSize.height))
        
        _command.owner = self
    }
    
    override func update (_ frameState: inout FrameState) {
       
        guard let context = frameState.context else {
            return
        }

        if _fontAtlas == nil {
            _fontAtlas = FontAtlas.fromCache(context, fontName: fontName, pointSize: pointSize)
        }
        
        guard let map = _command.uniformMap as? TextUniformMap else {
            return
        }
        
        if !show || !_fontAtlas.ready || string == "" {
            return
        }

        map._fontAtlasTexture = _fontAtlas.texture

        if _command.pipeline == nil {
            _command.pipeline = RenderPipeline.withCompiledShader(
                context,
                shaderSourceName: "TextRenderer",
                compiledMetalVertexName: "text_vertex_shade",
                compiledMetalFragmentName: "text_fragment_shade",
                uniformStructSize: MemoryLayout<TextUniformStruct>.stride,
                vertexDescriptor: VertexDescriptor(attributes: _attributes),
                depthStencil: _offscreenTarget ? false : context.depthTexture,
                blendingState: _blendingState
            )
            map.uniformBufferProvider = _command.pipeline!.shaderProgram.createUniformBufferProvider(context.device, deallocationBlock: nil)
        }
        
        if _command.renderState == nil || _updateMesh {
            
            _updateMetrics = true
                        
            let meshCGSize = computeSize()
            meshSize = Cartesian2(x: Double(meshCGSize.width), y: Double(meshCGSize.height))
            
            let meshRect = CGRect(x: 0, y: 0, width: meshCGSize.width, height: meshCGSize.height)
            _command.vertexArray = buildMesh(context, string: string, inRect: meshRect, withFontAtlas: _fontAtlas, atSize: Int(Double(pointSize)))
            
            _updateMesh = false
        }
        
        if _updateMetrics {
            map.viewProjectionMatrix = Matrix4.computeOrthographicOffCenter(left: 0, right: viewportRect.width, bottom: 0, top: viewportRect.height)
            
            _command.renderState = RenderState(
                device: context.device,
                viewport: viewportRect
            )
            _updateMetrics = false
        }
        
        map.foregroundColor = color
        
        frameState.commandList.append(_command)
    }

    open func computeSize (constrainingTo width: Double? = nil) -> CGSize {
        
        let constrainedWidth = width ?? viewportRect.width
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), string as CFString!)
        let font = CTFontCreateWithName(fontName as CFString, CGFloat(pointSize), nil)
        let stringRange = CFRangeMake(0, CFAttributedStringGetLength(attrString))
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString!)
        var fitRange = CFRangeMake(0, 0)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: CGFloat(constrainedWidth), height: CGFloat.greatestFiniteMagnitude), &fitRange)
        
        assert(stringRange == fitRange, "Core Text layout failed")
        return textSize
    }
    
    fileprivate func buildMesh (_ context: Context, string: String, inRect rect: CGRect, withFontAtlas fontAtlas: FontAtlas, atSize size: Int) -> VertexArray?
    {
        let attrString = NSMutableAttributedString(string: string)
        let stringRange = CFRangeMake(0, attrString.length)
        
        let font = CTFontCreateCopyWithAttributes(fontAtlas.parentFont, CGFloat(size), nil, nil)
        
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font)
        
        let rectPath = CGPath(rect: rect, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let frame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, nil)
        
        let frameGlyphCount: CFIndex = ((CTFrameGetLines(frame) as NSArray) as! [CTLine]).reduce(0, { $0 + CTLineGetGlyphCount($1) })
        
        let vertexCount = frameGlyphCount * 4

        var vertices = [Float]()
        var indices = [Int]()
        
        let glyphEnumeratorBlock = { (glyph: CGGlyph, glyphIndex: Int, glyphBounds: CGRect) -> Bool in
            guard let glyphInfo = fontAtlas.glyphDescriptors[glyph] else {
                logPrint(.debug, "Font atlas has no entry corresponding to glyph \(glyph): Skipping...")
                return false
            }
            let minX = Float(glyphBounds.minX)
            let maxX = Float(glyphBounds.maxX)
            let minY = Float(glyphBounds.minY)
            let maxY = Float(glyphBounds.maxY)
            let minS = Float(glyphInfo.tl.x)
            let maxS = Float(glyphInfo.br.x)
            let minT = Float(glyphInfo.br.y)
            let maxT = Float(glyphInfo.tl.y)
            vertices.append(contentsOf: [minX, maxY, 0, 1, minS, maxT])
            vertices.append(contentsOf: [minX, minY, 0, 1, minS, minT])
            vertices.append(contentsOf: [maxX, minY, 0, 1, maxS, minT])
            vertices.append(contentsOf: [maxX, maxY, 0, 1, maxS, maxT])
            indices.append(glyphIndex * 4)
            indices.append(glyphIndex * 4 + 1)
            indices.append(glyphIndex * 4 + 2)
            indices.append(glyphIndex * 4 + 2)
            indices.append(glyphIndex * 4 + 3)
            indices.append(glyphIndex * 4)
            
            return true
        }
        enumerateGlyphsInFrame(frame, usingBlock: glyphEnumeratorBlock)
        
        guard let vertexBuffer = Buffer(device: context.device, array: &vertices, componentDatatype: .float32, sizeInBytes: vertices.sizeInBytes) else {
            logPrint(.critical, "Cannot create Buffer")
            return nil
        }
        vertexBuffer.metalBuffer.label =  "Text Mesh Vertices"
        
        let indexBuffer: Buffer
        if indices.count < Math.SixtyFourKilobytes {
            let indicesShort = indices.map { UInt16($0) }
            guard let shortBuffer = Buffer(
                device: context.device,
                array: indicesShort,
                componentDatatype: ComponentDatatype.unsignedShort,
                sizeInBytes: indicesShort.sizeInBytes) else {
                    logPrint(.critical, "Cannot create Buffer")
                    return nil
            }
            indexBuffer = shortBuffer
        } else {
            let indicesInt = indices.map({ UInt32($0) })
            guard let longBuffer = Buffer(
                device: context.device,
                array: indicesInt,
                componentDatatype: ComponentDatatype.unsignedInt,
                sizeInBytes: indicesInt.sizeInBytes) else {
                    logPrint(.critical, "Cannot create Buffer")
                    return nil
            }
            indexBuffer = longBuffer
        }
        indexBuffer.metalBuffer.label = "Text Mesh Indices"
        
        var attributes = _attributes
        attributes[0].buffer = vertexBuffer

        return VertexArray(attributes: attributes, vertexCount: vertexCount, indexBuffer: indexBuffer, indexCount: indices.count)
    }
    
    fileprivate func enumerateGlyphsInFrame (_ frame: CTFrame, usingBlock addGlyph: (_ glyph: CGGlyph, _ glyphIndex: Int, _ glyphBounds: CGRect) -> Bool) {
        
        let entire = CFRangeMake(0, 0)
        
        let framePath = CTFrameGetPath(frame)
        let frameBoundingRect = framePath.boundingBoxOfPath
        
        let lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
        
        var lineOriginBuffer = [CGPoint](repeating: CGPoint(), count: lines.count)
        CTFrameGetLineOrigins(frame, entire, &lineOriginBuffer)
        
        var glyphIndexInFrame: CFIndex = 0
        
        for (lineIndex, line) in lines.enumerated() {
            let lineOrigin = lineOriginBuffer[lineIndex]
            
            let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
            
            for run in runs {
                
                let glyphCount = CTRunGetGlyphCount(run)
                
                var glyphBuffer = [CGGlyph](repeating: 0, count: glyphCount)
                CTRunGetGlyphs(run, entire, &glyphBuffer);
                
                var positionBuffer = [CGPoint](repeating: CGPoint(), count: glyphCount)
                CTRunGetPositions(run, entire, &positionBuffer);
                
                for glyphIndex in 0..<glyphCount {
                    
                    let glyph = glyphBuffer[glyphIndex]
                    let glyphOrigin = positionBuffer[glyphIndex]
                    var glyphRect = CTRunGetImageBounds(run, nil, CFRangeMake(glyphIndex, 1))
                    
                    let boundsTransX = frameBoundingRect.origin.x + lineOrigin.x
                    let boundsTransY = frameBoundingRect.origin.y + lineOrigin.y + glyphOrigin.y
                    let pathTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: boundsTransX, ty: boundsTransY)
                    
                    glyphRect = glyphRect.applying(pathTransform)
                    
                    let added = addGlyph(glyph, glyphIndexInFrame, glyphRect)
                    if added {
                        glyphIndexInFrame += 1
                    }
                }
            }
        }
    }
    
}
