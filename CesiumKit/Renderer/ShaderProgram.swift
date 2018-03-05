//
//  ShaderProgram.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import Metal
import GLSLOptimizer
import simd

class ShaderProgram {

    var _logShaderCompilation: Bool = false

    /**
    * GLSL source for the shader program's vertex shader.
    *
    * @memberof ShaderProgram.prototype
    *
    * @type {ShaderSource}
    * @readonly
    */
    let vertexShaderSource: ShaderSource!

    fileprivate let _vertexShaderText: String!

    fileprivate var _vertexShader: GLSLShader!

    fileprivate var _vertexLibrary: MTLLibrary!

    fileprivate var _metalVertexShaderSource: String!

    var metalVertexFunction: MTLFunction!

    fileprivate var _vertexUniforms = [Uniform]()

    /**
    * GLSL source for the shader program's fragment shader.
    *
    * @memberof ShaderProgram.prototype
    *
    * @type {ShaderSource}
    * @readonly
    */
    let fragmentShaderSource: ShaderSource!

    fileprivate let _fragmentShaderText: String!

    fileprivate var _fragmentShader: GLSLShader!

    fileprivate var _fragmentLibrary: MTLLibrary!

    fileprivate var _metalFragmentShaderSource: String!

    var metalFragmentFunction: MTLFunction!

    fileprivate var _fragmentUniforms = [Uniform]()

    fileprivate let _manualUniformStruct: String?

    fileprivate var _samplerUniforms = [UniformSampler]()

    fileprivate var _uniformBufferAlignment: Int = -1

    fileprivate (set) var vertexUniformSize = -1
    fileprivate (set) var fragmentUniformSize = -1

    var uniformCount: Int {
        return _vertexUniforms.count + _fragmentUniforms.count
    }

    var uniformBufferSize: Int {
        return vertexUniformSize + fragmentUniformSize
    }

    let keyword: String

    var numberOfVertexAttributes: Int {
        return vertexAttributes.count
    }

    fileprivate (set) var vertexAttributes: [String: GLSLShaderVariableDescription]!

    var maximumTextureUnitIndex: Int = 0

    //let nativeMetalUniforms: Bool

    static func combineShaders (vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource) -> (vst: String, fst: String, keyword: String) {
        let vst = vss.createCombinedVertexShader()
        let fst = fss.createCombinedFragmentShader()
        let keyword = vst + fst
        return (vst, fst, keyword)
    }

    init(device: MTLDevice, optimizer: GLSLOptimizer, logShaderCompilation: Bool = false, vertexShaderSource vss: ShaderSource, fragmentShaderSource fss: ShaderSource, manualUniformStruct: String? = nil, uniformStructSize: Int? = nil, combinedShaders: (vst: String, fst: String, keyword: String)) {
        _logShaderCompilation = logShaderCompilation
        vertexShaderSource = vss
        fragmentShaderSource = fss
        _manualUniformStruct = manualUniformStruct
        _vertexShaderText = combinedShaders.vst
        _fragmentShaderText = combinedShaders.fst
        keyword = combinedShaders.keyword
        //nativeMetalUniforms = _manualUniformStruct != nil
        initialize(device, optimizer: optimizer)

        if manualUniformStruct != nil {
            guard let uniformStructSize = uniformStructSize else {
                assertionFailure("uniform struct size not provided")
                return
            }
            vertexUniformSize = uniformStructSize
            fragmentUniformSize = 0
        }
    }

    init? (device: MTLDevice, shaderSourceName: String, compiledMetalVertexName vertex: String, compiledMetalFragmentName fragment: String, uniformStructSize: Int, keyword: String) {

        guard let bundle = Bundle(identifier: "com.testtoast.CesiumKit") else {
            logPrint(.error, "Could not find CesiumKit bundle in executable")
            return nil
        }
        guard let libraryPath = bundle.url(forResource: "default", withExtension: "metallib")?.path else {
            logPrint(.error, "Could not find shader source from bundle")
            return nil
        }
        let shaderLibrary: MTLLibrary
        do {
            shaderLibrary = try device.makeLibrary(filepath: libraryPath)
        } catch let error as NSError {
            logPrint(.error, "Could not generate library from compiled shader lib: \(error.localizedDescription)")
            return nil
        }

        guard let metalVertexFunction = shaderLibrary.makeFunction(name: vertex) else {
            logPrint(.error, "No vertex function found for \(vertex)")
            return nil
        }
        self.metalVertexFunction = metalVertexFunction
        guard let metalFragmentFunction = shaderLibrary.makeFunction(name: fragment) else {
            logPrint(.error, "No fragment function found for \(fragment)")
            return nil
        }
        self.metalFragmentFunction = metalFragmentFunction

        vertexUniformSize = uniformStructSize
        fragmentUniformSize = 0

        vertexShaderSource = nil
        _vertexShaderText = nil
        _manualUniformStruct = nil
        fragmentShaderSource = nil
        _fragmentShaderText = nil
        //nativeMetalUniforms = true
        self.keyword = keyword
    }

    fileprivate func initialize(_ device: MTLDevice, optimizer: GLSLOptimizer) {

        createMetalProgram(optimizer)
        compileMetalProgram(device)

        findVertexAttributes()
        findUniforms()
        if uniformCount > 0 {
            setUniformBufferAlignment()
            setUniformBufferOffsets()
        } else {
            vertexUniformSize = 0
            fragmentUniformSize = 0
        }
       /* maximumTextureUnitIndex = Int(setSamplerUniforms(uniforms.samplerUniforms))*/
    }

    fileprivate func createMetalProgram(_ optimizer: GLSLOptimizer) {

        _vertexShader = optimizer.optimize(.vertex, shaderSource: _vertexShaderText, manualUniformStruct: _manualUniformStruct, options: 0)
        assert(_vertexShader.status(), _vertexShader.log())
        _metalVertexShaderSource = _vertexShader.output()

        _fragmentShader = optimizer.optimize(.fragment, shaderSource: _fragmentShaderText, manualUniformStruct: _manualUniformStruct, options: 0)
        assert(_fragmentShader.status(), _fragmentShader.log())
        _metalFragmentShaderSource = _fragmentShader.output()
    }

    fileprivate func compileMetalProgram(_ device: MTLDevice) {

        do {
            _vertexLibrary = try device.makeLibrary(source: _metalVertexShaderSource, options: MTLCompileOptions())
            metalVertexFunction = _vertexLibrary.makeFunction(name: "xlatMtlMain")
        } catch let error as NSError {
            logPrint(.debug, _fragmentShaderText)
            logPrint(.debug, _metalFragmentShaderSource)
            logPrint(.error, error.localizedDescription)
            assertionFailure("_vertexLibrary == nil")
        }

        do {
            _fragmentLibrary = try device.makeLibrary(source: _metalFragmentShaderSource, options: nil)
            metalFragmentFunction = _fragmentLibrary.makeFunction(name: "xlatMtlMain")
        } catch let error as NSError {
            logPrint(.debug, _fragmentShaderText)
            logPrint(.debug, _metalFragmentShaderSource)
            logPrint(.error, error.localizedDescription)
            assertionFailure("_fragmentLibrary == nil")
        }
    }

    fileprivate func findVertexAttributes() {
        let attributeCount = _vertexShader.inputCount()

        vertexAttributes = [String: GLSLShaderVariableDescription]()

        for i in 0..<attributeCount {
            let attribute = _vertexShader.inputDescription(i)
            vertexAttributes[attribute.name] = attribute
        }
    }

    fileprivate func uniformType (_ desc: GLSLShaderVariableDescription) -> UniformType {
        if desc.name.hasPrefix("czm_a_") {
            return .automatic
        }
        if desc.name.hasPrefix("czm_f_") {
            return .frustum
        }
        return .manual
    }


    fileprivate func findUniforms() {
        _vertexUniforms = [Uniform]()
        let vertexUniformCount = _vertexShader.uniformCount()
        for i in 0..<vertexUniformCount {
            let desc =  _vertexShader.uniformDescription(i)
            let type = uniformType(desc)

            if type != .manual {
                continue
            }
            _vertexUniforms.append(Uniform.create(desc: desc, type: type))
        }

        _fragmentUniforms = [Uniform]()
        let fragmentUniformCount = _fragmentShader.uniformCount()
        for i in 0..<fragmentUniformCount {
            let desc =  _fragmentShader.uniformDescription(i)

            let type = uniformType(desc)
            if type != .manual {
                continue
            }
            _fragmentUniforms.append(Uniform.create(desc: desc, type: type))
        }

        _samplerUniforms = [UniformSampler]()
        let samplerUniformCount = _fragmentShader.textureCount()
        for i in 0..<samplerUniformCount {
            let desc =  _fragmentShader.textureDescription(i)
            let samplerUniform = Uniform.create(desc: desc, type: .sampler) as! UniformSampler
            samplerUniform.setSampler(Int(i))
            _samplerUniforms.append(samplerUniform)
        }
    }

    fileprivate func setUniformBufferAlignment () {
        var maxAlignment = 0
        for uniform in _vertexUniforms {
            maxAlignment = max(maxAlignment, uniform.dataType.alignment)
        }

        for uniform in _fragmentUniforms {
            maxAlignment = max(maxAlignment, uniform.dataType.alignment)
        }
        _uniformBufferAlignment = maxAlignment
    }

    fileprivate func elementStrideForUniform (_ uniform: Uniform) -> Int {
        return uniform.alignedSize
    }

    fileprivate func paddingRequredForUniform (_ uniform: Uniform, lastOffset: Int) -> Int {

        let currentAlignment = lastOffset % _uniformBufferAlignment
        let requiredAlignment = uniform.dataType.alignment

        if requiredAlignment <= _uniformBufferAlignment - currentAlignment {
            return 0
        } else {
            return _uniformBufferAlignment - currentAlignment
        }
    }

    fileprivate func setUniformBufferOffsets() {

        var offset = 0
        for uniform in _vertexUniforms {
            let padding = paddingRequredForUniform(uniform, lastOffset: offset)
            offset += padding
            uniform.offset = offset
            offset += elementStrideForUniform(uniform)
            //print("\(uniform.name): offset \(uniform.offset)(padding \(padding) stride: \(elementStrideForUniform(uniform)))")
        }
        offset = ((offset + 255) / 256) * 256 // fragment buffer offset must be a multiple of 256
        vertexUniformSize = offset

        for uniform in _fragmentUniforms {
            let padding = paddingRequredForUniform(uniform, lastOffset: offset)
            offset += padding
            uniform.offset = offset
            offset += elementStrideForUniform(uniform)
            //print("\(uniform.name): offset \(uniform.offset)(padding \(padding) stride: \(elementStrideForUniform(uniform)))")
        }

        offset = ((offset + 255) / 256) * 256 // overall buffer size must be a multiple of 256
        assert(offset % _uniformBufferAlignment == 0, "invalid buffer alignment")
        fragmentUniformSize = offset - vertexUniformSize
    }

    func createUniformBufferProvider(_ device: MTLDevice, deallocationBlock: UniformMapDeallocBlock?) -> UniformBufferProvider {
        let provider = UniformBufferProvider(device: device, bufferSize: max(uniformBufferSize, 256), deallocationBlock: deallocationBlock)
        return provider
    }

    //MARK:- Set uniforms

    func setUniforms (_ command: DrawCommand, uniformState: UniformState) -> (fragmentOffset: Int, texturesValid: Bool, textures: [Texture])
    {
        guard let map = command.uniformMap else {
            return (0, true, [Texture]())
        }

        if let map = map as? NativeUniformMap {
            return setNativeUniforms(map, uniformState: uniformState)
        }

        if let map = map as? LegacyUniformMap {
            return setLegacyUniforms(map, uniformState: uniformState)
        }

        return (0, false, [Texture]())
    }

    fileprivate func setNativeUniforms (_ map: NativeUniformMap, uniformState: UniformState) -> (fragmentOffset: Int, texturesValid: Bool, textures: [Texture])
    {
        guard let buffer = map.uniformBufferProvider?.currentBuffer(uniformState.frameState.context.bufferSyncState) else {
            return (0, false, [Texture]())
        }

        let textures = map.uniformUpdateBlock(buffer)
        buffer.signalWriteComplete()
        return (fragmentOffset: 0, texturesValid: true, textures: textures ?? [Texture]())
    }

    func setLegacyUniforms (_ map: LegacyUniformMap, uniformState: UniformState) -> (fragmentOffset: Int, texturesValid: Bool, textures: [Texture]) {

        guard let buffer = map.uniformBufferProvider?.currentBuffer(uniformState.frameState.context.bufferSyncState) else {
            return (0, false, [Texture]())
        }

        for uniform in _vertexUniforms {
            setUniform(uniform, buffer: buffer, map: map, uniformState: uniformState)
        }

        for uniform in _fragmentUniforms {
            setUniform(uniform, buffer: buffer, map: map, uniformState: uniformState)
        }

        buffer.signalWriteComplete()

        var textures = [Texture]()

        var texturesValid = true
        for uniform in _samplerUniforms {
            if let texture = map.textureForUniform(uniform) {
                textures.append(texture)
            } else {
                texturesValid = false
            }
        }

        let fragmentOffset = vertexUniformSize
        return (fragmentOffset: fragmentOffset, texturesValid: texturesValid, textures: textures)

    }

    func setUniform (_ uniform: Uniform, buffer: Buffer, map: LegacyUniformMap, uniformState: UniformState) {

        // "...each column of a matrix has the alignment of its vector component." https://developer.apple.com/library/ios/documentation/Metal/Reference/MetalShadingLanguageGuide/data-types/data-types.html#//apple_ref/doc/uid/TP40014364-CH2-SW15

        //"It seems that protocol values provide 24 bytes of storage. If the underlying value fits within 24 bytes, it's stored inline, otherwise it's automatically spilled to the heap." https://www.mikeash.com/pyblog/friday-qa-2014-08-01-exploring-swift-memory-layout-part-ii.html

        switch uniform.type {

        case .automatic:
            assertionFailure("should not be setting automatic uniforms here")
            return
        case .frustum:
            assertionFailure("should not be setting frustum uniforms here")
            return
        case .manual:
            guard let index = uniform.mapIndex else {
                guard let index = map.indexForUniform(uniform.name) else {
                    assertionFailure("uniform not found for \(uniform.name)")
                    return
                }
                uniform.mapIndex = index
                let uniformFunc = map.uniform(index)
                uniformFunc(map, buffer, uniform.offset)
                break
            }
            let uniformFunc = map.uniform(index)
            uniformFunc(map, buffer, uniform.offset)

        case .sampler:
            assertionFailure("Sampler not valid for setUniform")
            return
        }
    }


    /**
    * Creates a GLSL shader source string by sending the input through three stages:
    * <ul>
    *   <li>A series of <code>#define</code> statements are created from <code>options.defines</code>.</li>
    *   <li>GLSL snippets in <code>options.sources</code> are combined with line numbers preserved using <code>#line</code>.</li>
    *   <li>
    *     Modifies the source for use with color-buffer picking if <code>options.pickColorQualifier</code> is defined.
    *     The returned fragment shader source sets <code>gl_FragColor</code> to a new <code>vec4</code> uniform or varying,
    *     <code>czm_pickColor</code>, but still discards if the original fragment shader discards or outputs an alpha of 0.0.
    *     This allows correct picking when a material contains transparent parts.
    *   </li>
    * </ul>
    *
    * @exports createShaderSource
    *
    * @param {Object} [options] Object with the following properties:
    * @param {String[]} [options.defines] An array of strings to combine containing GLSL identifiers to <code>#define</code>.
    * @param {String[]} [options.sources] An array of strings to combine containing GLSL code for the shader.
    * @param {String} [options.pickColorQualifier] The GLSL qualifier, <code>uniform</code> or <code>varying</code>, for the input <code>czm_pickColor</code>.  When defined, a pick fragment shader is generated.
    * @returns {String} The generated GLSL shader source.
    *
    * @exception {DeveloperError} options.pickColorQualifier must be 'uniform' or 'varying'.
    *
    * @example
    * // 1. Prepend #defines to a shader
    * var source = Cesium.createShaderSource({
    *   defines : ['WHITE'],
    *   sources : ['void main() { \n#ifdef WHITE\n gl_FragColor = vec4(1.0); \n#else\n gl_FragColor = vec4(0.0); \n#endif\n }']
    * });
    *
    * // 2. Modify a fragment shader for picking
    * var source = createShaderSource({
    *   sources : ['void main() { gl_FragColor = vec4(1.0); }'],
    *   pickColorQualifier : 'uniform'
    * });
    *
    * @private
    */

    class func createShaderSource(_ defines: [String], sources: [String], pickColorQualifier: String? = nil) -> String {

        assert(pickColorQualifier == nil || pickColorQualifier == "uniform" || pickColorQualifier == "varying", "options.pickColorQualifier must be 'uniform' or 'varying'")

        var source = ""
        //var i
        //var length;

        // Stage 1.  Prepend #defines for uber-shaders
        for define in defines {
            source += "#define " + define + "\n"
        }

        // Stage 2.  Combine shader sources, generally for pseudo-polymorphism, e.g., czm_getMaterial.
        for shaderSource in sources {
            // #line needs to be on its own line.
            source += "\n#line 0\n" + shaderSource
        }


        // Stage 3.  Replace main() for picked if desired.
        if pickColorQualifier != nil {
            /*var renamedFS = source//.replace(/void\s+main\s*\(\s*(?:void)?\s*\)/g, "void czm_old_main()")
            var pickMain =
            pickColorQualifier + " vec4 czm_pickColor; \n" +
            "void main() \n" +
            "{ \n" +
            "    czm_old_main(); \n" +
            "    if (gl_FragColor.a == 0.0) { \n" +
            "        discard; \n" +
            "    } \n" +
            "    gl_FragColor = czm_pickColor; \n" +
            "}"

            source = renamedFS + "\n" + pickMain*/
        }

        return source
    }

}
