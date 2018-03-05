//
//  Context.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import MetalKit
import QuartzCore.CAMetalLayer


/**
* @private
*/

class Context {

    fileprivate var _debug: (
    renderCountThisFrame: Int,
    renderCount: Int
    )

    /*var renderQueue: dispatch_queue_t {
    get {
    return view.renderQueue
    }
    }*/

    fileprivate let _inflight_semaphore: DispatchSemaphore

    fileprivate (set) var bufferSyncState: BufferSyncState = .zero

    fileprivate var _lastFrameDrawCommands = Array<[DrawCommand]>(repeating: [DrawCommand](), count: 3)

    let view: MTKView

    internal let device: MTLDevice!

    fileprivate let _commandQueue: MTLCommandQueue

    fileprivate var _drawable: CAMetalDrawable! = nil
    fileprivate var _commandBuffer: MTLCommandBuffer! = nil

    var limits: ContextLimits

    fileprivate (set) var depthTexture: Bool = true

    var allowTextureFilterAnisotropic: Bool = true

    var textureFilterAnisotropic: Bool = true

    struct glOptions {

        var alpha = false

        var stencil = false

    }

    var id: String

    var _logShaderCompilation = false

    let pipelineCache: PipelineCache!

    fileprivate var _clearColor: MTLClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)

    fileprivate var _clearDepth: Double = 0.0
    fileprivate var _clearStencil: UInt32 = 0

    fileprivate var _currentRenderState: RenderState
    fileprivate let _defaultRenderState: RenderState

    fileprivate var _currentPassState: PassState? = nil
    fileprivate let _defaultPassState: PassState

    fileprivate var _passStates = [Pass: PassState]()

    var uniformState: UniformState
    fileprivate let _automaticUniformBufferProvider: UniformBufferProvider

    fileprivate var _frustumUniformBufferProviderPool = [UniformBufferProvider]()
    fileprivate (set) var wholeFrustumUniformBufferProvider: UniformBufferProvider! = nil
    fileprivate (set) var frontFrustumUniformBufferProvider: UniformBufferProvider! = nil

    /**
    * A 1x1 RGBA texture initialized to [255, 255, 255, 255].  This can
    * be used as a placeholder texture while other textures are downloaded.
    * @memberof Context.prototype
    * @type {Texture}
    */
    /*lazy var defaultTexture: Texture = {
    var imageBuffer = Imagebuffer(width: 1, height: 1, arrayBufferView: [255, 255, 255, 255])
    var source = TextureSource.ImageBuffer(imageBuffer)
    //var options = TextureOptions(source: source, width: nil, height: nil, pixelFormat: .RGBA, pixelDatatype: .UnsignedByte, flipY: false, premultiplyAlpha: true)
    return self.createTexture2D(options)
    }()*/

    /**
    * A cube map, where each face is a 1x1 RGBA texture initialized to
    * [255, 255, 255, 255].  This can be used as a placeholder cube map while
    * other cube maps are downloaded.
    * @memberof Context.prototype
    * @type {CubeMap}
    */
    //FIXME: cubemap
    /*var _defaultCubeMap: CubeMap?
    var defaultCubeMap: CubeMap {
    get {
    if !_defaultCubeMap {
    this._defaultCubeMap = this.createCubeMap(faces: [CubeMapFaceInfo](count: 6, repeatedValue: CubeMapFaceInfo(width: 1, height : 1, arrayBufferView: [255, 255, 255, 255])))
    }
    return _defaultCubeMap!

    }
    }*/

    /**
    * A cache of objects tied to this context.  Just before the Context is destroyed,
    * <code>destroy</code> will be invoked on each object in this object literal that has
    * such a method.  This is useful for caching any objects that might otherwise
    * be stored globally, except they're tied to a particular context, and to manage
    * their lifetime.
    *
    * @private
    * @type {Object}
    */
    var cache = [String: Any]()


    /**
    * The drawingBufferHeight of the underlying GL context.
    * @memberof Context.prototype
    * @type {Number}
    */

    var height: Int = 0
    /**
    * The drawingBufferWidth of the underlying GL context.
    * @memberof Context.prototype
    * @type {Number}
    */
    var width: Int = 0

    var cachedState: RenderState? = nil

    fileprivate var _maxFrameTextureUnitIndex = 0

    var pickObjects: [AnyObject]

    var nextPickColor: [UInt32]

    /**
    * Gets an object representing the currently bound framebuffer.
    * This represents the associated MTKView's drawable.
    * @type {Object}
    */
    let defaultFramebuffer: Framebuffer

    init (view: MTKView) {

        self.view = view

        device = view.device!
        limits = ContextLimits(device: device)

        logPrint(.info, "Metal device: " + (device.name ?? "Unknown"))
        #if os(OSX)
            logPrint(.info, "- Low power: " + (device.isLowPower ? "Yes" : "No"))
            logPrint(.info, "- Headless: " + (device.isHeadless ? "Yes" : "No"))
        #endif

        _commandQueue = device.makeCommandQueue()

        pipelineCache = PipelineCache(device: device)
        id = UUID().uuidString

        _inflight_semaphore = DispatchSemaphore(value: 3)//kInFlightCommandBuffers)

        //antialias = true

        pickObjects = Array<AnyObject>()
        nextPickColor = Array<UInt32>(repeating: 0, count: 1)

        _debug = (0, 0)

        let us = UniformState()
        let rs = RenderState(device: device)

        _defaultRenderState = rs
        uniformState = us
        _automaticUniformBufferProvider = UniformBufferProvider(device: device, bufferSize: MemoryLayout<AutomaticUniformBufferLayout>.stride, deallocationBlock: nil)
        _currentRenderState = rs
        defaultFramebuffer = Framebuffer(maximumColorAttachments: 1)
        _defaultPassState = PassState()
        _defaultPassState.context = self
        pipelineCache.context = self

        wholeFrustumUniformBufferProvider = getFrustumUniformBufferProvider()

        /**
        * @example
        * {
        *   webgl : {
        *     alpha : false,
        *     depth : true,
        *     stencil : false,
        *     antialias : true,
        *     premultipliedAlpha : true,
        *     preserveDrawingBuffer : false
        *     failIfMajorPerformanceCaveat : true
        *   },
        *   allowTextureFilterAnisotropic : true
        * }
        */
        //this.options = options;
        //_currentRenderState.apply(_defaultPassState)

        width = Int(view.drawableSize.width)
        height = Int(view.drawableSize.height)
    }

    /**
    * Creates a compiled MTLSamplerState from a MTLSamplerDescriptor. These should generally be cached.
    */
    func createSamplerState (_ descriptor: MTLSamplerDescriptor) -> MTLSamplerState {
        return device.makeSamplerState(descriptor: descriptor)
    }

    func updateDrawable () -> Bool {
        // Allow the renderer to preflight 3 frames on the CPU (using a semaphore as a guard) and commit them to the GPU.
        // This semaphore will get signaled once the GPU completes a frame's work via addCompletedHandler callback below,
        // signifying the CPU can go ahead and prepare another frame.
        _ = _inflight_semaphore.wait(timeout: DispatchTime.distantFuture)
        assert(_drawable == nil, "drawable != nil")
        _drawable = view.currentDrawable
        if _drawable == nil {
            logPrint(.error, "drawable == nil")
            _inflight_semaphore.signal()
            return false
        }
        defaultFramebuffer.updateFromDrawable(context: self, drawable: _drawable, depthStencil: depthTexture ? view.depthStencilTexture : nil)
        return true
    }

    func beginFrame() {
        self._lastFrameDrawCommands[bufferSyncState.rawValue].removeAll()

        _commandBuffer = _commandQueue.makeCommandBuffer()

        _commandBuffer.addCompletedHandler { buffer in
            // Signal the semaphore and allow the CPU to proceed and construct the next frame.
            self._inflight_semaphore.signal()
        }

        let automaticUniformBuffer = _automaticUniformBufferProvider.currentBuffer(bufferSyncState)
        uniformState.setAutomaticUniforms(automaticUniformBuffer)
        automaticUniformBuffer.signalWriteComplete()

        //updateDrawable()
    }

    func createRenderPass(_ passState: PassState? = nil) -> RenderPass {
        let passState = passState ?? _defaultPassState
        let pass = RenderPass(context: self, buffer: _commandBuffer, passState: passState, defaultFramebuffer: defaultFramebuffer)
        return pass
    }

    func completeRenderPass(_ pass: RenderPass) {
        pass.complete()
    }

    func applyRenderState(_ pass: RenderPass, renderState: RenderState, passState: PassState) {
        pass.apply(renderState: renderState)
    }

    func createBlitCommandEncoder (_ completionHandler: MTLCommandBufferHandler? = nil) -> MTLBlitCommandEncoder {
        if let completionHandler = completionHandler {
            _commandBuffer.addCompletedHandler(completionHandler)
        }
        return _commandBuffer.makeBlitCommandEncoder()
    }

    func completeBlitPass (_ encoder: MTLBlitCommandEncoder) {
        encoder.endEncoding()
    }

    func getFrustumUniformBufferProvider () -> UniformBufferProvider {
        if _frustumUniformBufferProviderPool.isEmpty {
            return UniformBufferProvider(device: device, bufferSize: MemoryLayout<FrustumUniformBufferLayout>.stride, deallocationBlock: { provider in
                    self._frustumUniformBufferProviderPool.append(provider)
                }
            )
        }
        return _frustumUniformBufferProviderPool.removeLast()
    }

    func returnFrustumUniformBufferProvider (_ provider: UniformBufferProvider) {
    }

    func clear(_ clearCommand: ClearCommand, passState: PassState? = nil) {

        let framebuffer = clearCommand.framebuffer ?? passState?.framebuffer ?? defaultFramebuffer

        let passDescriptor = framebuffer.renderPassDescriptor

        let c = clearCommand.color
        let d = clearCommand.depth
        let s = clearCommand.stencil

        let colorAttachment = passDescriptor.colorAttachments[0]
        if let c = c {
            colorAttachment?.loadAction = .clear
            colorAttachment?.storeAction = .store
            colorAttachment?.clearColor = MTLClearColorMake(c.red, c.green, c.blue, c.alpha)
        } else {
            colorAttachment?.loadAction = .load
            colorAttachment?.storeAction = .store
        }

        let depthAttachment = passDescriptor.depthAttachment
        if let d = d {
            depthAttachment?.loadAction = .clear
            depthAttachment?.storeAction = .dontCare
            depthAttachment?.clearDepth = d
        } else {
            depthAttachment?.loadAction = .dontCare
            depthAttachment?.storeAction = .dontCare
        }

        let stencilAttachment = passDescriptor.stencilAttachment
        if let s = s {
            stencilAttachment?.loadAction = .clear
            stencilAttachment?.storeAction = .store
            stencilAttachment?.clearStencil = s
        } else {
            stencilAttachment?.loadAction = .dontCare
            stencilAttachment?.storeAction = .dontCare

        }
    }

    func draw(_ command: DrawCommand, renderPass: RenderPass, frustumUniformBuffer: Buffer? = nil) {
        _lastFrameDrawCommands[bufferSyncState.rawValue].append(command)
        beginDraw(command, renderPass: renderPass)
        continueDraw(command, renderPass: renderPass, frustumUniformBuffer: frustumUniformBuffer)
    }

    func beginDraw(_ command: DrawCommand, renderPass: RenderPass) {
        let rs = command.renderState ?? _defaultRenderState

        let commandEncoder = renderPass.commandEncoder

        guard let renderPipeline = command.pipeline else {
            assertionFailure("no render pipeline set")
            return
        }

        commandEncoder.setRenderPipelineState(renderPipeline.state)

        applyRenderState(renderPass, renderState: rs, passState: renderPass.passState)
    }

    func continueDraw(_ command: DrawCommand, renderPass: RenderPass, frustumUniformBuffer: Buffer? = nil) {
        let primitiveType = command.primitiveType

        assert(command.vertexArray != nil, "drawCommand.vertexArray is required")
        let va = command.vertexArray!
        var offset = command.offset
        var count = command.count

        assert(offset >= 0, "drawCommand.offset must be omitted or greater than or equal to zero")
        assert(count == nil || count! >= 0, "drawCommand.count must be omitted or greater than or equal to zero")

        uniformState.model = command.modelMatrix ?? Matrix4.identity

        guard let renderPipeline = command.pipeline else {
            assertionFailure("no render pipeline set")
            return
        }

        let bufferParams = renderPipeline.setUniforms(command, device: device, uniformState: uniformState)

        // Don't render unless any textures required are available
        if !bufferParams.texturesValid {
            logPrint(.error, "invalid textures")
            return
        }
        let commandEncoder = renderPass.commandEncoder

        if let indexBuffer = va.indexBuffer {
            let indexType = va.indexBuffer!.componentDatatype.toMTLIndexType()
            offset *= indexBuffer.componentDatatype.elementSize // offset in vertices to offset in bytes
            guard let indexCount = count ?? va.indexCount else {
                assertionFailure("index count not provided for indexed primitive")
                return
            }

            // automatic uniforms
            commandEncoder.setVertexBuffer(_automaticUniformBufferProvider.currentBuffer(bufferSyncState).metalBuffer, offset: 0, at: 0)

            // frustum uniforms
            commandEncoder.setVertexBuffer(frustumUniformBuffer?.metalBuffer, offset: 0, at: 1)

            // manual uniforms
            if let uniformBuffer = command.uniformMap?.uniformBufferProvider?.currentBuffer(bufferSyncState) {
                commandEncoder.setVertexBuffer(uniformBuffer.metalBuffer, offset: 0, at: 2)
            }

            for attribute in va.attributes {
                if let buffer = attribute.buffer {
                    commandEncoder.setVertexBuffer(buffer.metalBuffer, offset: 0, at: attribute.bufferIndex)
                }
            }

            // automatic uniforms
            commandEncoder.setFragmentBuffer(_automaticUniformBufferProvider.currentBuffer(bufferSyncState).metalBuffer, offset: 0, at: 0)

            // frustum uniforms
            commandEncoder.setFragmentBuffer(frustumUniformBuffer?.metalBuffer, offset: 0, at: 1)

            // manual uniforms
            if let uniformBuffer = command.uniformMap?.uniformBufferProvider?.currentBuffer(bufferSyncState) {
                commandEncoder.setFragmentBuffer(uniformBuffer.metalBuffer, offset: bufferParams.fragmentOffset, at: 2)
            }

            for (index, texture) in bufferParams.textures.enumerated() {
                commandEncoder.setFragmentTexture(texture.metalTexture, at: index)
                commandEncoder.setFragmentSamplerState(texture.sampler.state, at: index)
            }

            commandEncoder.drawIndexedPrimitives(type: primitiveType, indexCount: indexCount, indexType: indexType, indexBuffer: indexBuffer.metalBuffer, indexBufferOffset: 0)
        } else {
            count = count ?? va.vertexCount
            /*va!._bind()
            glDrawArrays(GLenum(primitiveType.rawValue), GLint(offset), GLsizei(count!))
            va!._unBind()*/
        }
    }

    func endFrame () {
        _commandBuffer.present(_drawable)
        _commandBuffer.commit()

        _drawable = nil
        defaultFramebuffer.clearDrawable()

        _commandBuffer = nil
        /*
        var
        buffers = scratchBackBufferArray;
        if (this.drawBuffers) {
        this._drawBuffers.drawBuffersWEBGL(scratchBackBufferArray);
        }*/
        bufferSyncState = bufferSyncState.advance()

        _maxFrameTextureUnitIndex = 0
        _debug.renderCountThisFrame = 0
    }
    /*
    Context.prototype.readPixels = function(readState) {
    var gl = this._gl;

    readState = readState || {};
    var x = Math.max(readState.x || 0, 0);
    var y = Math.max(readState.y || 0, 0);
    var width = readState.width || gl.drawingBufferWidth;
    var height = readState.height || gl.drawingBufferHeight;
    var framebuffer = readState.framebuffer;

    //>>includeStart('debug', pragmas.debug);
    if (width <= 0) {
    throw new DeveloperError('readState.width must be greater than zero.');
    }

    if (height <= 0) {
    throw new DeveloperError('readState.height must be greater than zero.');
    }
    //>>includeEnd('debug');

    var pixels = new Uint8Array(4 * width * height);

    bindFramebuffer(this, framebuffer);

    gl.readPixels(x, y, width, height, gl.RGBA, gl.UNSIGNED_BYTE, pixels);

    return pixels;
    };*/

    fileprivate let viewportQuadAttributeLocations = [
        "position" : 0,
        "textureCoordinates": 1
    ]

    func getViewportQuadVertexArray () -> VertexArray {
        // Per-context cache for viewport quads

        if let vertexArray = cache["viewportQuad_vertexArray"] as? VertexArray {
            return vertexArray
        }

        let geometry = Geometry(
            attributes: GeometryAttributes(
                position: GeometryAttribute(
                    componentDatatype: .float32,
                    componentsPerAttribute: 2,
                    values: Buffer(
                        device: device,
                        array: [
                            -1.0, -1.0,
                            1.0, -1.0,
                            1.0, 1.0,
                            -1.0, 1.0
                        ].map({ Float($0)}),
                        componentDatatype: .float32,
                        sizeInBytes: 8 * MemoryLayout<Float>.stride
                    )
                ), // position
                st: GeometryAttribute(
                    componentDatatype: .float32,
                    componentsPerAttribute: 2,
                    values: Buffer(
                        device: device,
                        array: [ // Flipped for Metal texture coordinates (top-left  = (0, 0))
                            0.0, 1.0,
                            1.0, 1.0,
                            1.0, 0.0,
                            0.0, 0.0].map({ Float($0)}),
                        componentDatatype: .float32,
                        sizeInBytes: 8 * MemoryLayout<Float>.stride
                    )
                )
            ), // textureCoordinates
            indices: [0, 1, 2, 0, 2, 3]
            )

        let vertexArray = VertexArray(
            fromGeometry: geometry,
            context: self,
            attributeLocations: viewportQuadAttributeLocations,
            interleave : true
        )

        cache["viewportQuad_vertexArray"] = vertexArray

        return vertexArray
    }

    func createViewportQuadCommand (fragmentShaderSource fss: ShaderSource, overrides: ViewportQuadOverrides? = nil, depthStencil: Bool = true, blendingState: BlendingState? = nil) -> DrawCommand
    {

        let vertexArray = getViewportQuadVertexArray()
        let command = DrawCommand(
            vertexArray: vertexArray,
            uniformMap: overrides?.uniformMap,
            renderState: overrides?.renderState,
            renderPipeline: RenderPipeline.fromCache(
                context: self,
                vertexShaderSource: ShaderSource(sources: [Shaders["ViewportQuadVS"]!]),
                fragmentShaderSource: fss,
                vertexDescriptor: VertexDescriptor(attributes: vertexArray.attributes),
                depthStencil: depthStencil,
                blendingState: blendingState
            ),
            owner: self
        )
        return command
    }

    /*
    Context.prototype.createPickFramebuffer = function() {
    return new PickFramebuffer(this);
    };

    /**
    * Gets the object associated with a pick color.
    *
    * @memberof Context
    *
    * @param {Color} pickColor The pick color.
    *
    * @returns {Object} The object associated with the pick color, or undefined if no object is associated with that color.
    *
    * @example
    * var object = context.getObjectByPickColor(pickColor);
    *
    * @see Context#createPickId
    */
    Context.prototype.getObjectByPickColor = function(pickColor) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(pickColor)) {
    throw new DeveloperError('pickColor is required.');
    }
    //>>includeEnd('debug');

    return this._pickObjects[pickColor.toRgba()];
    };

    function PickId(pickObjects, key, color) {
    this._pickObjects = pickObjects;
    this.key = key;
    this.color = color;
    }

    defineProperties(PickId.prototype, {
    object : {
    get : function() {
    return this._pickObjects[this.key];
    },
    set : function(value) {
    this._pickObjects[this.key] = value;
    }
    }
    });

    PickId.prototype.destroy = function() {
    delete this._pickObjects[this.key];
    return undefined;
    };

    /**
    * Creates a unique ID associated with the input object for use with color-buffer picking.
    * The ID has an RGBA color value unique to this context.  You must call destroy()
    * on the pick ID when destroying the input object.
    *
    * @memberof Context
    *
    * @param {Object} object The object to associate with the pick ID.
    *
    * @returns {Object} A PickId object with a <code>color</code> property.
    *
    * @exception {RuntimeError} Out of unique Pick IDs.
    *
    * @see Context#getObjectByPickColor
    *
    * @example
    * this._pickId = context.createPickId({
    *   primitive : this,
    *   id : this.id
    * });
    */
    Context.prototype.createPickId = function(object) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(object)) {
    throw new DeveloperError('object is required.');
    }
    //>>includeEnd('debug');

    // the increment and assignment have to be separate statements to
    // actually detect overflow in the Uint32 value
    ++this._nextPickColor[0];
    var key = this._nextPickColor[0];
    if (key === 0) {
    // In case of overflow
    throw new RuntimeError('Out of unique Pick IDs.');
    }

    this._pickObjects[key] = object;
    return new PickId(this._pickObjects, key, Color.fromRgba(key));
    };

    Context.prototype.isDestroyed = function() {
    return false;
    };
    */
    deinit {
        /*
        // Destroy all objects in the cache that have a destroy method.
        var cache = this.cache;
        for (var property in cache) {
        if (cache.hasOwnProperty(property)) {
        var propertyValue = cache[property];
        if (defined(propertyValue.destroy)) {
        propertyValue.destroy();
        }
        }
        }
        this._shaderCache = this._shaderCache.destroy();
        this._defaultTexture = this._defaultTexture && this._defaultTexture.destroy();
        this._defaultCubeMap = this._defaultCubeMap && this._defaultCubeMap.destroy();
        }
        */
    }


}
