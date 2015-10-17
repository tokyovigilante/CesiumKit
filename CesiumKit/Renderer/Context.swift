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
    
    //private var _depthTexture: MTLTexture!
    //private var _stencilTexture: MTLTexture!
    
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
        _defaultPassState = PassState()
        _defaultPassState.context = self
        
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
    
    /**
    * Creates a Metal GPU buffer. If an allocated memory region is passed in, it will be
    * copied to the buffer and can be released (or automatically released via ARC)
    */
    func createBuffer(array: UnsafePointer<Void> = nil, componentDatatype: ComponentDatatype, sizeInBytes: Int) -> Buffer {
        return Buffer(device: device, array: array, componentDatatype: componentDatatype, sizeInBytes: sizeInBytes)
    }
    
    func createUniformBufferProvider(capacity: Int, sizeInBytes: Int) -> UniformBufferProvider {
        return UniformBufferProvider(device: self.device, capacity: capacity, sizeInBytes: sizeInBytes)
    }
    
    /**
    * Creates a vertex array, which defines the attributes making up a vertex, and contains an optional index buffer
    * to select vertices for rendering.  Attributes are defined using object literals as shown in Example 1 below.
    *
    * @memberof Context
    *
    * @param {Object[]} [attributes] An optional array of attributes.
    * @param {IndexBuffer} [indexBuffer] An optional index buffer.
    *
    * @returns {VertexArray} The vertex array, ready for use with drawing.
    *
    * @exception {DeveloperError} Attribute must have a <code>vertexBuffer</code>.
    * @exception {DeveloperError} Attribute must have a <code>componentsPerAttribute</code>.
    * @exception {DeveloperError} Attribute must have a valid <code>componentDatatype</code> or not specify it.
    * @exception {DeveloperError} Attribute must have a <code>strideInBytes</code> less than or equal to 255 or not specify it.
    * @exception {DeveloperError} Index n is used by more than one attribute.
    *
    * @see Context#createVertexArrayFromGeometry
    * @see Context#createVertexBuffer
    * @see Context#createIndexBuffer
    * @see Context#draw
    *
    * @example
    * // Example 1. Create a vertex array with vertices made up of three floating point
    * // values, e.g., a position, from a single vertex buffer.  No index buffer is used.
    * var positionBuffer = context.createVertexBuffer(12, BufferUsage.STATIC_DRAW);
    * var attributes = [
    *     {
    *         index                  : 0,
    *         enabled                : true,
    *         vertexBuffer           : positionBuffer,
    *         componentsPerAttribute : 3,
    *         componentDatatype      : ComponentDatatype.FLOAT,
    *         normalize              : false,
    *         offsetInBytes          : 0,
    *         strideInBytes          : 0 // tightly packed
    *     }
    * ];
    * var va = context.createVertexArray(attributes);
    *
    * ////////////////////////////////////////////////////////////////////////////////
    *
    * // Example 2. Create a vertex array with vertices from two different vertex buffers.
    * // Each vertex has a three-component position and three-component normal.
    * var positionBuffer = context.createVertexBuffer(12, BufferUsage.STATIC_DRAW);
    * var normalBuffer = context.createVertexBuffer(12, BufferUsage.STATIC_DRAW);
    * var attributes = [
    *     {
    *         index                  : 0,
    *         vertexBuffer           : positionBuffer,
    *         componentsPerAttribute : 3,
    *         componentDatatype      : ComponentDatatype.FLOAT
    *     },
    *     {
    *         index                  : 1,
    *         vertexBuffer           : normalBuffer,
    *         componentsPerAttribute : 3,
    *         componentDatatype      : ComponentDatatype.FLOAT
    *     }
    * ];
    * var va = context.createVertexArray(attributes);
    *
    * ////////////////////////////////////////////////////////////////////////////////
    *
    * // Example 3. Creates the same vertex layout as Example 2 using a single
    * // vertex buffer, instead of two.
    * var buffer = context.createVertexBuffer(24, BufferUsage.STATIC_DRAW);
    * var attributes = [
    *     {
    *         vertexBuffer           : buffer,
    *         componentsPerAttribute : 3,
    *         componentDatatype      : ComponentDatatype.FLOAT,
    *         offsetInBytes          : 0,
    *         strideInBytes          : 24
    *     },
    *     {
    *         vertexBuffer           : buffer,
    *         componentsPerAttribute : 3,
    *         componentDatatype      : ComponentDatatype.FLOAT,
    *         normalize              : true,
    *         offsetInBytes          : 12,
    *         strideInBytes          : 24
    *     }
    * ];
    * var va = context.createVertexArray(attributes);
    */
    
    func createVertexArray (buffers: [Buffer], vertexAttributes: [VertexAttributes], vertexCount: Int, indexBuffer: Buffer?) -> VertexArray {
        return VertexArray(buffers: buffers, attributes: vertexAttributes, vertexCount: vertexCount, indexBuffer: indexBuffer)
        
    }
    /**
    * options.source can be {@link ImageData}, {@link Image}, {@link Canvas}, or {@link Video}.
    *
    * @exception {RuntimeError} When options.pixelFormat is DEPTH_COMPONENT or DEPTH_STENCIL, this WebGL implementation must support WEBGL_depth_texture.
    * @exception {RuntimeError} When options.pixelDatatype is FLOAT, this WebGL implementation must support the OES_texture_float extension.
    * @exception {DeveloperError} options requires a source field to create an initialized texture or width and height fields to create a blank texture.
    * @exception {DeveloperError} Width must be greater than zero.
    * @exception {DeveloperError} Width must be less than or equal to the maximum texture size.
    * @exception {DeveloperError} Height must be greater than zero.
    * @exception {DeveloperError} Height must be less than or equal to the maximum texture size.
    * @exception {DeveloperError} Invalid options.pixelFormat.
    * @exception {DeveloperError} Invalid options.pixelDatatype.
    * @exception {DeveloperError} When options.pixelFormat is DEPTH_COMPONENT, options.pixelDatatype must be UNSIGNED_SHORT or UNSIGNED_INT.
    * @exception {DeveloperError} When options.pixelFormat is DEPTH_STENCIL, options.pixelDatatype must be UNSIGNED_INT_24_8_WEBGL.
    * @exception {DeveloperError} When options.pixelFormat is DEPTH_COMPONENT or DEPTH_STENCIL, source cannot be provided.
    *
    * @see Context#createTexture2DFromFramebuffer
    * @see Context#createCubeMap
    * @see Context#createSampler
    */
    func createTexture2D(options: TextureOptions) -> Texture {
        return Texture(context: self, options: options)
    }
    /*
    /**
    * Creates a texture, and copies a subimage of the framebuffer to it.  When called without arguments,
    * the texture is the same width and height as the framebuffer and contains its contents.
    *
    * @memberof Context
    *
    * @param {PixelFormat} [pixelFormat=PixelFormat.RGB] The texture's internal pixel format.
    * @param {Number} [framebufferXOffset=0] An offset in the x direction in the framebuffer where copying begins from.
    * @param {Number} [framebufferYOffset=0] An offset in the y direction in the framebuffer where copying begins from.
    * @param {Number} [width=canvas.clientWidth] The width of the texture in texels.
    * @param {Number} [height=canvas.clientHeight] The height of the texture in texels.
    * @param {Framebuffer} [framebuffer=defaultFramebuffer] The framebuffer from which to create the texture.  If this
    *        parameter is not specified, the default framebuffer is used.
    *
    * @returns {Texture} A texture with contents from the framebuffer.
    *
    * @exception {DeveloperError} Invalid pixelFormat.
    * @exception {DeveloperError} pixelFormat cannot be DEPTH_COMPONENT or DEPTH_STENCIL.
    * @exception {DeveloperError} framebufferXOffset must be greater than or equal to zero.
    * @exception {DeveloperError} framebufferYOffset must be greater than or equal to zero.
    * @exception {DeveloperError} framebufferXOffset + width must be less than or equal to canvas.clientWidth.
    * @exception {DeveloperError} framebufferYOffset + height must be less than or equal to canvas.clientHeight.
    *
    * @see Context#createTexture2D
    * @see Context#createCubeMap
    * @see Context#createSampler
    *
    * @example
    * // Create a texture with the contents of the framebuffer.
    * var t = context.createTexture2DFromFramebuffer();
    */
    Context.prototype.createTexture2DFromFramebuffer = function(pixelFormat, framebufferXOffset, framebufferYOffset, width, height, framebuffer) {
    var gl = this._gl;
    
    pixelFormat = defaultValue(pixelFormat, PixelFormat.RGB);
    framebufferXOffset = defaultValue(framebufferXOffset, 0);
    framebufferYOffset = defaultValue(framebufferYOffset, 0);
    width = defaultValue(width, gl.drawingBufferWidth);
    height = defaultValue(height, gl.drawingBufferHeight);
    
    //>>includeStart('debug', pragmas.debug);
    if (!PixelFormat.validate(pixelFormat)) {
    throw new DeveloperError('Invalid pixelFormat.');
    }
    
    if (PixelFormat.isDepthFormat(pixelFormat)) {
    throw new DeveloperError('pixelFormat cannot be DEPTH_COMPONENT or DEPTH_STENCIL.');
    }
    
    if (framebufferXOffset < 0) {
    throw new DeveloperError('framebufferXOffset must be greater than or equal to zero.');
    }
    
    if (framebufferYOffset < 0) {
    throw new DeveloperError('framebufferYOffset must be greater than or equal to zero.');
    }
    
    if (framebufferXOffset + width > gl.drawingBufferWidth) {
    throw new DeveloperError('framebufferXOffset + width must be less than or equal to drawingBufferWidth');
    }
    
    if (framebufferYOffset + height > gl.drawingBufferHeight) {
    throw new DeveloperError('framebufferYOffset + height must be less than or equal to drawingBufferHeight.');
    }
    //>>includeEnd('debug');
    
    var texture = new Texture(this, {
    width : width,
    height : height,
    pixelFormat : pixelFormat,
    source : {
    framebuffer : defined(framebuffer) ? framebuffer : this.defaultFramebuffer,
    xOffset : framebufferXOffset,
    yOffset : framebufferYOffset,
    width : width,
    height : height
    }
    });
    
    return texture;
    };
    */
    /**
    * options.source can be {@link ImageData}, {@link Image}, {@link Canvas}, or {@link Video}.
    *
    * @memberof Context
    *
    * @returns {CubeMap} The newly created cube map.
    *
    * @exception {RuntimeError} When options.pixelDatatype is FLOAT, this WebGL implementation must support the OES_texture_float extension.
    * @exception {DeveloperError} options.source requires positiveX, negativeX, positiveY, negativeY, positiveZ, and negativeZ faces.
    * @exception {DeveloperError} Each face in options.sources must have the same width and height.
    * @exception {DeveloperError} options requires a source field to create an initialized cube map or width and height fields to create a blank cube map.
    * @exception {DeveloperError} Width must equal height.
    * @exception {DeveloperError} Width and height must be greater than zero.
    * @exception {DeveloperError} Width and height must be less than or equal to the maximum cube map size.
    * @exception {DeveloperError} Invalid options.pixelFormat.
    * @exception {DeveloperError} options.pixelFormat cannot be DEPTH_COMPONENT or DEPTH_STENCIL.
    * @exception {DeveloperError} Invalid options.pixelDatatype.
    *
    * @see Context#createTexture2D
    * @see Context#createTexture2DFromFramebuffer
    * @see Context#createSampler
    */
    
    func createCubeMap (faces: [Imagebuffer]?, width: Int?, height: Int?/*, pixelDatatype: PixelDatatype?*/) -> CubeMap? {
        // FIXME: cubemap
        /*
        Context.prototype.createCubeMap = function(options) {
        options = defaultValue(options, defaultValue.EMPTY_OBJECT);
        
        var source = options.source;
        var width;
        var height;
        
        if (defined(source)) {
        var faces = [source.positiveX, source.negativeX, source.positiveY, source.negativeY, source.positiveZ, source.negativeZ];
        
        //>>includeStart('debug', pragmas.debug);
        if (!faces[0] || !faces[1] || !faces[2] || !faces[3] || !faces[4] || !faces[5]) {
        throw new DeveloperError('options.source requires positiveX, negativeX, positiveY, negativeY, positiveZ, and negativeZ faces.');
        }
        //>>includeEnd('debug');
        
        width = faces[0].width;
        height = faces[0].height;
        
        //>>includeStart('debug', pragmas.debug);
        for ( var i = 1; i < 6; ++i) {
        if ((Number(faces[i].width) !== width) || (Number(faces[i].height) !== height)) {
        throw new DeveloperError('Each face in options.source must have the same width and height.');
        }
        }
        //>>includeEnd('debug');
        } else {
        width = options.width;
        height = options.height;
        }
        
        var size = width;
        var pixelFormat = defaultValue(options.pixelFormat, PixelFormat.RGBA);
        var pixelDatatype = defaultValue(options.pixelDatatype, PixelDatatype.UNSIGNED_BYTE);
        
        //>>includeStart('debug', pragmas.debug);
        if (!defined(width) || !defined(height)) {
        throw new DeveloperError('options requires a source field to create an initialized cube map or width and height fields to create a blank cube map.');
        }
        
        if (width !== height) {
        throw new DeveloperError('Width must equal height.');
        }
        
        if (size <= 0) {
        throw new DeveloperError('Width and height must be greater than zero.');
        }
        
        if (size > this._maximumCubeMapSize) {
        throw new DeveloperError('Width and height must be less than or equal to the maximum cube map size (' + this._maximumCubeMapSize + ').  Check maximumCubeMapSize.');
        }
        
        if (!PixelFormat.validate(pixelFormat)) {
        throw new DeveloperError('Invalid options.pixelFormat.');
        }
        
        if (PixelFormat.isDepthFormat(pixelFormat)) {
        throw new DeveloperError('options.pixelFormat cannot be DEPTH_COMPONENT or DEPTH_STENCIL.');
        }
        
        if (!PixelDatatype.validate(pixelDatatype)) {
        throw new DeveloperError('Invalid options.pixelDatatype.');
        }
        //>>includeEnd('debug');
        
        if ((pixelDatatype === PixelDatatype.FLOAT) && !this.floatingPointTexture) {
        throw new RuntimeError('When options.pixelDatatype is FLOAT, this WebGL implementation must support the OES_texture_float extension.');
        }
        
        // Use premultiplied alpha for opaque textures should perform better on Chrome:
        // http://media.tojicode.com/webglCamp4/#20
        var preMultiplyAlpha = options.preMultiplyAlpha || ((pixelFormat === PixelFormat.RGB) || (pixelFormat === PixelFormat.LUMINANCE));
        var flipY = defaultValue(options.flipY, true);
        
        var gl = this._gl;
        var textureTarget = gl.TEXTURE_CUBE_MAP;
        var texture = gl.createTexture();
        
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(textureTarget, texture);
        
        function createFace(target, sourceFace) {
        if (sourceFace.arrayBufferView) {
        gl.texImage2D(target, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, sourceFace.arrayBufferView);
        } else {
        gl.texImage2D(target, 0, pixelFormat, pixelFormat, pixelDatatype, sourceFace);
        }
        }
        
        if (defined(source)) {
        gl.pixelStorei(_gl._UNPACK_ALIGNMENT, 4);
        gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, preMultiplyAlpha);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, flipY);
        
        createFace(gl.TEXTURE_CUBE_MAP_POSITIVE_X, source.positiveX);
        createFace(gl.TEXTURE_CUBE_MAP_NEGATIVE_X, source.negativeX);
        createFace(gl.TEXTURE_CUBE_MAP_POSITIVE_Y, source.positiveY);
        createFace(gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, source.negativeY);
        createFace(gl.TEXTURE_CUBE_MAP_POSITIVE_Z, source.positiveZ);
        createFace(gl.TEXTURE_CUBE_MAP_NEGATIVE_Z, source.negativeZ);
        } else {
        gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, null);
        gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_X, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, null);
        gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_Y, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, null);
        gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, null);
        gl.texImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_Z, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, null);
        gl.texImage2D(gl.TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, pixelFormat, size, size, 0, pixelFormat, pixelDatatype, null);
        }
        gl.bindTexture(textureTarget, null);
        
        return new CubeMap(gl, this._textureFilterAnisotropic, textureTarget, texture, pixelFormat, pixelDatatype, size, preMultiplyAlpha, flipY);
        */
        return nil
    }
        
    /*
    Context.prototype.createRenderbuffer = function(options) {
    var gl = this._gl;
    
    options = defaultValue(options, defaultValue.EMPTY_OBJECT);
    var format = defaultValue(options.format, RenderbufferFormat.RGBA4);
    var width = defined(options.width) ? options.width : gl.drawingBufferWidth;
    var height = defined(options.height) ? options.height : gl.drawingBufferHeight;
    
    //>>includeStart('debug', pragmas.debug);
    if (!RenderbufferFormat.validate(format)) {
    throw new DeveloperError('Invalid format.');
    }
    
    if (width <= 0) {
    throw new DeveloperError('Width must be greater than zero.');
    }
    
    if (width > this.maximumRenderbufferSize) {
    throw new DeveloperError('Width must be less than or equal to the maximum renderbuffer size (' + this.maximumRenderbufferSize + ').  Check maximumRenderbufferSize.');
    }
    
    if (height <= 0) {
    throw new DeveloperError('Height must be greater than zero.');
    }
    
    if (height > this.maximumRenderbufferSize) {
    throw new DeveloperError('Height must be less than or equal to the maximum renderbuffer size (' + this.maximumRenderbufferSize + ').  Check maximumRenderbufferSize.');
    }
    //>>includeEnd('debug');
    
    return new Renderbuffer(gl, format, width, height);
    };
    
    var nextRenderStateId = 0;
    var renderStateCache = {};
    */
    
    
    
    func beginFrame() -> Bool {
        
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
        _defaultPassState.passDescriptor = MTLRenderPassDescriptor()
        _defaultPassState.passDescriptor.colorAttachments[0].texture = _drawable.texture
        //_defaultPassState.passDescriptor.colorAttachments[0].storeAction = .Store
        
        //_defaultPassState.passDescriptor.depthAttachment.texture = _depthTexture
        //_defaultPassState.passDescriptor.stencilAttachment.texture = _stencilTexture
        
        _commandBuffer = _commandQueue.commandBuffer()
        
        // call the view's completion handler which is required by the view since it will signal its semaphore and set up the next buffer
        _commandBuffer.addCompletedHandler { (buffer) in
            // GPU has completed rendering the frame and is done using the contents of any buffers previously encoded on the CPU for that frame.
            // Signal the semaphore and allow the CPU to proceed and construct the next frame.
            dispatch_semaphore_signal(self._inflight_semaphore)
        }
        return true
    }
    
    func createRenderPass(passState: PassState? = nil, clearCommand: ClearCommand?) -> RenderPass {
        let passState = passState ?? _defaultPassState
        let pass = RenderPass(context: self, buffer: _commandBuffer, passState: passState, clearCommand: clearCommand)
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
            colorAttachment.clearColor = c
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
        
        
        /*var rs = (renderState ?? drawCommand.renderState) ?? _defaultRenderState
        
        if framebuffer != nil && rs.depthTest.enabled {
        assert(framebuffer!.hasDepthAttachment, "The depth test can not be enabled (drawCommand.renderState.depthTest.enabled) because the framebuffer (drawCommand.framebuffer) does not have a depth or depth-stencil renderbuffer.")
        }*/
        let commandEncoder = renderPass.commandEncoder
        let renderPipeline = renderPipeline ?? drawCommand.pipeline!

        commandEncoder.setRenderPipelineState(renderPipeline.state)
        
        
        //_maxFrameTextureUnitIndex = max(_maxFrameTextureUnitIndex, sp!.maximumTextureUnitIndex)
        
        //applyRenderState(rs, passState: passState)
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
        let bufferParams = renderPipeline.setUniforms(drawCommand, context: self, uniformState: uniformState)
        
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
            
            for attribute in va.attributes {
                commandEncoder.setVertexBuffer(va.vertexBuffers[attribute.bufferIndex].metalBuffer, offset: attribute.offset, atIndex: attribute.index)
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
                    buffer: Buffer(device: device, array: [-1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0], componentDatatype: .Float32, sizeInBytes: 32)
                ), // position
                st: GeometryAttribute(
                    componentDatatype: .Float32,
                    componentsPerAttribute: 2,
                    buffer: Buffer(device: device, array: [0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0], componentDatatype: .Float32, sizeInBytes: 32)
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
