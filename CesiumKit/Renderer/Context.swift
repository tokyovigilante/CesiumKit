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
    
    private var _debug: (
    renderCountThisFrame: Int,
    renderCount: Int
    )
    
    /*var renderQueue: dispatch_queue_t {
    get {
    return view.renderQueue
    }
    }*/
    let networkQueue: dispatch_queue_t
    let networkSemaphore: dispatch_semaphore_t
    
    let processorQueue: dispatch_queue_t
    let textureLoadQueue: dispatch_queue_t
    
    private let _inflight_semaphore: dispatch_semaphore_t
    
    let view: MTKView
    
    internal let device: MTLDevice!
    
    private let _commandQueue: MTLCommandQueue
    
    private var _drawable: CAMetalDrawable! = nil
    private var _commandBuffer: MTLCommandBuffer! = nil
    
    var limits: ContextLimits
    
    //private var _commandsExecutedThisFrame = [DrawCommand]()
    
    private (set) var depthTexture: Bool = true
    
    var allowTextureFilterAnisotropic = true
    
    var textureFilterAnisotropic = true
    
    struct glOptions {
        
        var alpha = false
        
        var stencil = false
        
    }
    
    var id: String
    
    var _logShaderCompilation = false
    
    let pipelineCache: PipelineCache!
    
    private var _clearColor: MTLClearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0)
    
    private var _clearDepth: Double = 0.0
    private var _clearStencil: UInt32 = 0
    
    private var _currentRenderState: RenderState
    private let _defaultRenderState: RenderState
    
    private var _currentPassState: PassState? = nil
    private var _defaultPassState: PassState
    
    private var _passStates = [Pass: PassState]()
    
    var uniformState: UniformState
    
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
    var cache = [String: AnyObject]()
    
    
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
    
    private var _maxFrameTextureUnitIndex = 0
    
    var pickObjects: [AnyObject]
    
    var nextPickColor: [UInt32]
    
    /**
    * Gets an object representing the currently bound framebuffer.  While this instance is not an actual
    * {@link Framebuffer}, it is used to represent the default framebuffer in calls to
    * {@link Context.createTexture2DFromFramebuffer}.
    * @type {Object}
    */
    //var defaultFramebuffer: Framebuffer? = nil
    
    init (view: MTKView) {
        
        self.view = view
        
        device = view.device!
        limits = ContextLimits(device: device)
        
        print("Metal device: " + (device.name ?? "Unknown"))
        #if os(OSX)
            print("- Low power: " + (device.lowPower ? "Yes" : "No"))
            print("- Headless: " + (device.headless ? "Yes" : "No"))
        #endif
        
        _commandQueue = device.newCommandQueue()
        
        pipelineCache = PipelineCache(device: device)
        
        id = NSUUID().UUIDString
        
        _inflight_semaphore = dispatch_semaphore_create(4)//kInFlightCommandBuffers)
        
        networkQueue = dispatch_queue_create("com.testtoast.cesiumkit.networkqueue", DISPATCH_QUEUE_SERIAL)
        processorQueue = dispatch_queue_create("com.testtoast.cesiumkit.processorqueue", DISPATCH_QUEUE_SERIAL)
        textureLoadQueue = dispatch_queue_create("com.testtoast.CesiumKit.textureLoadQueue", DISPATCH_QUEUE_SERIAL)
        
        networkSemaphore = dispatch_semaphore_create(4)
        
        //antialias = true
        
        pickObjects = Array<AnyObject>()
        nextPickColor = Array<UInt32>(count: 1, repeatedValue: 0)
        
        _debug = (0, 0)
        
        let us = UniformState()
        let rs = RenderState()
        
        _defaultRenderState = rs
        uniformState = us
        _currentRenderState = rs
        _defaultPassState = PassState(context: self)
        //_defaultPassState.context = self
        
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
    func createSamplerState (descriptor: MTLSamplerDescriptor) -> MTLSamplerState {
        return device.newSamplerStateWithDescriptor(descriptor)
    }
    
    func beginFrame(passState: PassState) -> Bool {
        
        // Allow the renderer to preflight 3 frames on the CPU (using a semaphore as a guard) and commit them to the GPU.
        // This semaphore will get signaled once the GPU completes a frame's work via addCompletedHandler callback below,
        // signifying the CPU can go ahead and prepare another frame.
        dispatch_semaphore_wait(_inflight_semaphore, DISPATCH_TIME_FOREVER)
        assert(_drawable == nil, "drawable != nil")
        _drawable = view.currentDrawable
        if _drawable == nil {
            print("drawable == nil")
            dispatch_semaphore_signal(_inflight_semaphore)
            return false
        }
        //assert(_drawable != nil, "drawable == nil")
        passState.passDescriptor = MTLRenderPassDescriptor()
        passState.passDescriptor.colorAttachments[0].texture = _drawable.texture
        passState.passDescriptor.colorAttachments[0].storeAction = .Store
        
        if depthTexture {
            let ds = view.depthStencilTexture
            passState.passDescriptor.depthAttachment.texture = ds//view.depthStencilTexture
            passState.passDescriptor.stencilAttachment.texture = ds//view.depthStencilTexture
        }
        
        _commandBuffer = _commandQueue.commandBuffer()
        
        // call the view's completion handler which is required by the view since it will signal its semaphore and set up the next buffer
        _commandBuffer.addCompletedHandler { (buffer) in
            // GPU has completed rendering the frame and is done using the contents of any buffers previously encoded on the CPU for that frame.
            // Signal the semaphore and allow the CPU to proceed and construct the next frame.
            dispatch_semaphore_signal(self._inflight_semaphore)
        }
        return true
    }
    
    func createRenderPass(passState: PassState? = nil/*, clearCommands: [ClearCommand]?*/) -> RenderPass {
        let passState = passState ?? _defaultPassState
        let pass = RenderPass(context: self, buffer: _commandBuffer, passState: passState/*, clearCommands: clearCommands*/)
        return pass
    }
    
    func completeRenderPass(pass: RenderPass) {
        pass.complete()
    }
    
    func applyRenderState(pass: RenderPass, renderState: RenderState, passState: PassState) {
        pass.applyRenderState(renderState)
    }
    
    func clear(clearCommand: ClearCommand, passState: PassState? = nil) {
        
        let passState = passState ?? _defaultPassState
        let passDescriptor = passState.passDescriptor
        
        let c = clearCommand.color
        let d = clearCommand.depth
        let s = clearCommand.stencil
        
        let colorAttachment = passDescriptor.colorAttachments[0]
        if let c = c {
            colorAttachment.loadAction = .Clear
            colorAttachment.storeAction = .Store
            colorAttachment.clearColor = MTLClearColorMake(c.red, c.green, c.blue, c.alpha)
        } else {
            colorAttachment.loadAction = .DontCare
            colorAttachment.storeAction = .DontCare
            
        }
        
        let depthAttachment = passDescriptor.depthAttachment
        if let d = d {
            depthAttachment.loadAction = .Clear
            depthAttachment.storeAction = .DontCare
            depthAttachment.clearDepth = d
        } else {
            depthAttachment.loadAction = .DontCare
            depthAttachment.storeAction = .DontCare
        }
        
        let stencilAttachment = passDescriptor.stencilAttachment
        if let s = s {
            stencilAttachment.loadAction = .Clear
            stencilAttachment.storeAction = .Store
            stencilAttachment.clearStencil = s
        } else {
            stencilAttachment.loadAction = .DontCare
            stencilAttachment.storeAction = .DontCare
        }
    }
    
    func draw(drawCommand: DrawCommand, renderPass: RenderPass, renderPipeline: RenderPipeline? = nil) {
        
        //_commandsExecutedThisFrame.append(drawCommand)
        /*
        let activePassState: PassState
        if let pass = drawCommand.pass {
            let commandPassState = _passStates[pass]
            activePassState = commandPassState ?? _defaultPassState
        } else {
            activePassState = _currentPassState ?? _defaultPassState
        }
        if _currentPassState == nil /*|| _currentPassState! != activePassState*/ {
            _currentPassState = activePassState
        }*/
        // The command's framebuffer takes presidence over the pass' framebuffer, e.g., for off-screen rendering.
        
        beginDraw(drawCommand, renderPass: renderPass, renderPipeline: renderPipeline)
        continueDraw(drawCommand, renderPass: renderPass, renderPipeline: renderPipeline)
    }
    
    func beginDraw(drawCommand: DrawCommand, renderPass: RenderPass, renderPipeline: RenderPipeline?) {
        
        
        let rs = /*(renderPass.pa ??*/ drawCommand.renderState/*)*/ ?? _defaultRenderState
        
        /*if framebuffer != nil && rs.depthTest.enabled {
        assert(framebuffer!.hasDepthAttachment, "The depth test can not be enabled (drawCommand.renderState.depthTest.enabled) because the framebuffer (drawCommand.framebuffer) does not have a depth or depth-stencil renderbuffer.")
        }*/
        let commandEncoder = renderPass.commandEncoder
        let renderPipeline = renderPipeline ?? drawCommand.pipeline!

        commandEncoder.setRenderPipelineState(renderPipeline.state)
        
        
        //_maxFrameTextureUnitIndex = max(_maxFrameTextureUnitIndex, sp!.maximumTextureUnitIndex)

        applyRenderState(renderPass, renderState: rs, passState: renderPass.passState)
    }
    
    func continueDraw(drawCommand: DrawCommand, renderPass: RenderPass, renderPipeline: RenderPipeline?) {
        let primitiveType = drawCommand.primitiveType
        
        assert(drawCommand.vertexArray != nil, "drawCommand.vertexArray is required")
        let va = drawCommand.vertexArray!
        var offset = drawCommand.offset
        var count = drawCommand.count
        
        assert(offset >= 0, "drawCommand.offset must be omitted or greater than or equal to zero")
        assert(count == nil || count! >= 0, "drawCommand.count must be omitted or greater than or equal to zero")
        
        
        uniformState.model = drawCommand.modelMatrix ?? Matrix4.identity()
        
        let renderPipeline = renderPipeline ?? drawCommand.pipeline!
        let bufferParams = renderPipeline.setUniforms(drawCommand, device: device, uniformState: uniformState)
        
        // Don't render unless any textures required are available
        if !bufferParams.texturesValid {
            print("invalid textures")
            return
        }
        let commandEncoder = renderPass.commandEncoder
        
        if let indexBuffer = va.indexBuffer {
            let indexType = va.indexType
            offset *= indexBuffer.componentDatatype.elementSize // offset in vertices to offset in bytes
            let indexCount = count ?? va.numberOfIndices
            
            commandEncoder.setVertexBuffer(bufferParams.buffer.metalBuffer, offset: 0, atIndex: 0)
            
            for (i, buffer) in va.vertexBuffers.enumerate() {
                commandEncoder.setVertexBuffer(buffer.metalBuffer, offset: 0, atIndex: i+1)
            }
            
            commandEncoder.setFragmentBuffer(bufferParams.buffer.metalBuffer, offset: bufferParams.fragmentOffset, atIndex: 0)
            
            for (index, texture) in bufferParams.textures.enumerate() {
                commandEncoder.setFragmentTexture(texture.metalTexture, atIndex: index)
                commandEncoder.setFragmentSamplerState(texture.sampler.state, atIndex: index)
            }
            commandEncoder.drawIndexedPrimitives(primitiveType, indexCount: indexCount, indexType: indexType, indexBuffer: indexBuffer.metalBuffer, indexBufferOffset: 0)
        } else {
            count = count ?? va.vertexCount
            /*va!._bind()
            glDrawArrays(GLenum(primitiveType.rawValue), GLint(offset), GLsizei(count!))
            va!._unBind()*/
        }
    }
    
    func endFrame () {

        _commandBuffer.presentDrawable(_drawable)
        _commandBuffer.commit()
        
        _drawable = nil
        _defaultPassState.passDescriptor = nil
        _currentPassState?.passDescriptor = nil
        
        _commandBuffer = nil
        /*
        var
        buffers = scratchBackBufferArray;
        if (this.drawBuffers) {
        this._drawBuffers.drawBuffersWEBGL(scratchBackBufferArray);
        }*/
        
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
    
    func getViewportQuadVertexArray () -> VertexArray {
        // Per-context cache for viewport quads
        
        if let vertexArray = cache["viewportQuad_vertexArray"] as? VertexArray {
            return vertexArray
        }
        
        let geometry = Geometry(
            attributes: GeometryAttributes(
                position: GeometryAttribute(
                    componentDatatype: .Float32,
                    componentsPerAttribute: 2,
                    buffer: Buffer(device: device, array: UnsafePointer<Void>([-1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0]), componentDatatype: .Float32, sizeInBytes: 32)
                ), // position
                st: GeometryAttribute(
                    componentDatatype: .Float32,
                    componentsPerAttribute: 2,
                    buffer: Buffer(device: device, array: UnsafePointer<Void>([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]), componentDatatype: .Float32, sizeInBytes: 32)
                )), // textureCoordinates
            indices: [0, 1, 2, 0, 2, 3]
            )
        
        let vertexArray = VertexArray(
            fromGeometry: geometry,
            interleave : true
        )
    
        cache["viewportQuad_vertexArray"] = vertexArray
        
        return vertexArray
    }

    func createViewportQuadCommand (fragmentShaderSource: ShaderSource, overrides: AnyObject) {
/*overrides = defaultValue(overrides, defaultValue.EMPTY_OBJECT);

return new DrawCommand({
vertexArray : this.getViewportQuadVertexArray(),
primitiveType : PrimitiveType.TRIANGLES,
renderState : overrides.renderState,
shaderProgram : ShaderProgram.fromCache({
context : this,
vertexShaderSource : ViewportQuadVS,
fragmentShaderSource : fragmentShaderSource,
attributeLocations : viewportQuadAttributeLocations
}),
uniformMap : overrides.uniformMap,
owner : overrides.owner,
framebuffer : overrides.framebuffer)*/
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
