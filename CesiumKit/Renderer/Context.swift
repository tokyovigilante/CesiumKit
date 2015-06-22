//
//  Context.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import Metal
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

    var layer: CAMetalLayer
    
    internal let device: MTLDevice!
    
    private let _commandQueue: MTLCommandQueue
    
    private var _drawable: CAMetalDrawable! = nil
    private var _commandBuffer: MTLCommandBuffer! = nil
    private var _commandEncoder: MTLRenderCommandEncoder! = nil

/*    var pipeline: MTLRenderPipelineState
    var uniformBuffer: MTLBuffer
    var depthTexture: MTLTexture
    var depthState: MTLDepthStencilState
    var notMipSamplerState: MTLSamplerState
    var nearestMipSamplerState: MTLSamplerState
    var linearMipSamplerState: MTLSamplerState*/
    
    //private var _commandsExecutedThisFrame = [DrawCommand]()
    
    private var _depthTexture: MTLTexture!
    private var _stencilTexture: MTLTexture!
    
    var maximumTextureSize: Int = 4096
    
    var maximumTextureUnits: Int = 16 // techically maximum sampler state attachment
    
    var allowTextureFilterAnisotropic = true
    
    var textureFilterAnisotropic = true
    
    var maximumTextureFilterAnisotropy = 1
    
    struct glOptions {
        
        var alpha = false
        
        var stencil = false
        
    }
        
    var id: String
    
    var _logShaderCompilation = false
    
    var _pipelineCache: PipelineCache!
    
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
    var defaultFramebuffer: Framebuffer? = nil

    init (layer: CAMetalLayer) {
        
        self.layer = layer
        
        device = MTLCreateSystemDefaultDevice()
        layer.device = device
        layer.pixelFormat = MTLPixelFormat.BGRA8Unorm
        layer.framebufferOnly = true
        
        _commandQueue = device.newCommandQueue()
        
        id = NSUUID().UUIDString
        
        _inflight_semaphore = dispatch_semaphore_create(3)//kInFlightCommandBuffers)

        networkQueue = dispatch_queue_create("com.testtoast.cesiumkit.networkqueue", DISPATCH_QUEUE_CONCURRENT)
        processorQueue = dispatch_queue_create("com.testtoast.cesiumkit.processorqueue", DISPATCH_QUEUE_SERIAL)
        textureLoadQueue = dispatch_queue_create("com.testtoast.CesiumKit.textureLoadQueue", DISPATCH_QUEUE_SERIAL)
        
        networkSemaphore = dispatch_semaphore_create(4)
        
        //antialias = true
       
        pickObjects = Array<AnyObject>()
        nextPickColor = Array<UInt32>(count: 1, repeatedValue: 0)

        _debug = (0, 0)

        var us = UniformState()
        var rs = RenderState()
        
        _defaultRenderState = rs
        uniformState = us
        _currentRenderState = rs
        _defaultPassState = PassState()
        
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
        _currentRenderState.apply(_defaultPassState)
    }
    
    func replaceRenderPipeline(
        pipeline: RenderPipeline?,
        vertexShaderSource vss: ShaderSource,
        fragmentShaderSource fss: ShaderSource,
        vertexDescriptor vd: VertexDescriptor? = nil) -> RenderPipeline? {
            
            if _pipelineCache == nil {
                _pipelineCache = PipelineCache(context: self)
            }
            return _pipelineCache!.replaceRenderPipeline(pipeline, context: self, vertexShaderSource: vss, fragmentShaderSource: fss, vertexDescriptor: vd)
    }
    
    func createRenderPipeline(
        vertexShaderSource vss: ShaderSource,
        fragmentShaderSource fss: ShaderSource,
        vertexDescriptor vd: VertexDescriptor? = nil) -> RenderPipeline {
            
            if _pipelineCache == nil {
                _pipelineCache = PipelineCache(context: self)
            }
            return _pipelineCache.getRenderPipeline(self, vertexShaderSource: vss, fragmentShaderSource: fss, vertexDescriptor: vd)
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
    
    func createVertexArray (#vertexBuffer: Buffer, vertexCount: Int, indexBuffer: Buffer?) -> VertexArray {
        return VertexArray(vertexBuffer: vertexBuffer, vertexCount: vertexCount, indexBuffer: indexBuffer)
        
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
    
    func createDepthTexture() {
        
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.Depth32Float,
            width: Int(width),
            height: Int(height),
            mipmapped: false)
        _depthTexture = device.newTextureWithDescriptor(depthTextureDescriptor)
    }
    
    func createStencilTexture() {
        let stencilTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.Stencil8,
            width: Int(width),
            height: Int(height),
            mipmapped: false)
        _stencilTexture = device.newTextureWithDescriptor(stencilTextureDescriptor)
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
        
        // Allow the renderer to preflight 3 frames on the CPU (using a semapore as a guard) and commit them to the GPU.
        // This semaphore will get signaled once the GPU completes a frame's work via addCompletedHandler callback below,
        // signifying the CPU can go ahead and prepare another frame.
        dispatch_semaphore_wait(_inflight_semaphore, DISPATCH_TIME_FOREVER)
        assert(_drawable == nil, "drawable != nil")
        _drawable = layer.nextDrawable()
        if _drawable == nil {
            println("drawable == nil")
            return false
        }
        //assert(_drawable != nil, "drawable == nil")
        _defaultPassState.passDescriptor = MTLRenderPassDescriptor()
        _defaultPassState.passDescriptor.colorAttachments[0].texture = _drawable.texture
        _defaultPassState.passDescriptor.colorAttachments[0].storeAction = .Store

        _defaultPassState.passDescriptor.depthAttachment.texture = _depthTexture
        _defaultPassState.passDescriptor.stencilAttachment.texture = _stencilTexture
        
        _commandBuffer = _commandQueue.commandBuffer()
        
        // call the view's completion handler which is required by the view since it will signal its semaphore and set up the next buffer
        _commandBuffer.addCompletedHandler { (buffer) in
            // GPU has completed rendering the frame and is done using the contents of any buffers previously encoded on the CPU for that frame.
            // Signal the semaphore and allow the CPU to proceed and construct the next frame.
            dispatch_semaphore_signal(self._inflight_semaphore)
        }
        return true
    }
    
    func createCommandEncoder(passState: PassState? = nil) {
        if _commandEncoder != nil {
            _commandEncoder.endEncoding()
        }
        let passDescriptor = passState?.passDescriptor ?? _defaultPassState.passDescriptor!
        
        let commandEncoder = _commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)
        assert(commandEncoder != nil, "Could not create command encoder")
        _commandEncoder = commandEncoder!
        _commandEncoder.setTriangleFillMode(.Fill)
        _commandEncoder.setFrontFacingWinding(.CounterClockwise)
        _commandEncoder.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(width), height: Double(height), znear: 0.0, zfar: 1.0))
        _commandEncoder.setCullMode(.Back)
    }
    
    func applyRenderState(renderState: RenderState, passState: PassState) {
        var previousState = _currentRenderState
        if previousState.hash != renderState.hash {
            _currentRenderState = renderState
            renderState.partialApply(previousState, passState: passState)
        }
        // else same render state as before so state is already applied.
    }

    func clear(clearCommand: ClearCommand = ClearCommand(), passState: PassState? = nil) {
        
        let passDescriptor = passState?.passDescriptor ?? _defaultPassState.passDescriptor!
        
        var c = clearCommand.color
        var d = clearCommand.depth
        var s = clearCommand.stencil
        
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
    
    func draw(drawCommand: DrawCommand, passState: PassState?, renderState: RenderState? = nil, renderPipeline: RenderPipeline? = nil) {
        
        //_commandsExecutedThisFrame.append(drawCommand)
        
        let activePassState: PassState
        if let pass = drawCommand.pass {
            var commandPassState = _passStates[pass]
            activePassState = commandPassState ?? _defaultPassState
        } else {
            activePassState = _currentPassState ?? _defaultPassState
        }
        if _currentPassState == nil /*|| _currentPassState! != activePassState*/ {
            _currentPassState = activePassState
        }
        // The command's framebuffer takes presidence over the pass' framebuffer, e.g., for off-screen rendering.
        var framebuffer = drawCommand.framebuffer ?? activePassState.framebuffer
        
        beginDraw(framebuffer: framebuffer, drawCommand: drawCommand, passState: activePassState, renderState: renderState, renderPipeline: renderPipeline)
        continueDraw(drawCommand, renderPipeline: renderPipeline)
    }
    
    func beginDraw(framebuffer: Framebuffer? = nil, drawCommand: DrawCommand, passState: PassState, renderState: RenderState?, renderPipeline: RenderPipeline?) {
        
        
        /*var rs = (renderState ?? drawCommand.renderState) ?? _defaultRenderState
        
        if framebuffer != nil && rs.depthTest.enabled {
        assert(framebuffer!.hasDepthAttachment, "The depth test can not be enabled (drawCommand.renderState.depthTest.enabled) because the framebuffer (drawCommand.framebuffer) does not have a depth or depth-stencil renderbuffer.")
        }*/
        let renderPipeline = renderPipeline ?? drawCommand.pipeline!
        _commandEncoder.setRenderPipelineState(renderPipeline.state)
        
        
        //_maxFrameTextureUnitIndex = max(_maxFrameTextureUnitIndex, sp!.maximumTextureUnitIndex)
        
        //applyRenderState(rs, passState: passState)
    }
    
    func continueDraw(drawCommand: DrawCommand, renderPipeline: RenderPipeline?) {
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
            println("invalid textures")
            return
        }
        
        if let indexBuffer = va.indexBuffer {
            let indexType = va.indexType
            offset *= indexBuffer.componentDatatype.elementSize // offset in vertices to offset in bytes
            let indexCount = count ?? va.numberOfIndices
            _commandEncoder.setVertexBuffer(va.vertexBuffer.metalBuffer, offset: 0, atIndex: 0)
            _commandEncoder.setVertexBuffer(bufferParams.buffer.metalBuffer, offset: 0, atIndex: 1)
            
            _commandEncoder.setFragmentBuffer(bufferParams.buffer.metalBuffer, offset: bufferParams.fragmentOffset, atIndex: 1)
            
            for (index, texture) in enumerate(bufferParams.textures) {
                _commandEncoder.setFragmentTexture(texture.metalTexture, atIndex: index)
                _commandEncoder.setFragmentSamplerState(texture.sampler.state, atIndex: index)
            }
            
            _commandEncoder.drawIndexedPrimitives(primitiveType, indexCount: indexCount, indexType: indexType, indexBuffer: indexBuffer.metalBuffer, indexBufferOffset: 0)
        } else {
            count = count ?? va.vertexCount
            /*va!._bind()
            glDrawArrays(GLenum(primitiveType.rawValue), GLint(offset), GLsizei(count!))
            va!._unBind()*/
        }
    }

    func endFrame () {
        _commandEncoder.endEncoding()
        _commandBuffer.presentDrawable(_drawable)
        
        _drawable = nil
        _defaultPassState.passDescriptor = nil
        _currentPassState?.passDescriptor = nil
        
        _commandBuffer.commit()
        _commandEncoder = nil
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
};

//////////////////////////////////////////////////////////////////////////////////////////

function computeNumberOfVertices(attribute) {
    return attribute.values.length / attribute.componentsPerAttribute;
}

function computeAttributeSizeInBytes(attribute) {
    return ComponentDatatype.getSizeInBytes(attribute.componentDatatype) * attribute.componentsPerAttribute;
}

function interleaveAttributes(attributes) {
    var j;
    var name;
    var attribute;
    
    // Extract attribute names.
    var names = [];
    for (name in attributes) {
        // Attribute needs to have per-vertex values; not a constant value for all vertices.
        if (attributes.hasOwnProperty(name) &&
            defined(attributes[name]) &&
            defined(attributes[name].values)) {
                names.push(name);
                
                if (attributes[name].componentDatatype === ComponentDatatype.DOUBLE) {
                    attributes[name].componentDatatype = ComponentDatatype.FLOAT;
                    attributes[name].values = ComponentDatatype.createTypedArray(ComponentDatatype.FLOAT, attributes[name].values);
                }
        }
    }
    
    // Validation.  Compute number of vertices.
    var numberOfVertices;
    var namesLength = names.length;
    
    if (namesLength > 0) {
        numberOfVertices = computeNumberOfVertices(attributes[names[0]]);
        
        for (j = 1; j < namesLength; ++j) {
            var currentNumberOfVertices = computeNumberOfVertices(attributes[names[j]]);
            
            if (currentNumberOfVertices !== numberOfVertices) {
                throw new RuntimeError(
                    'Each attribute list must have the same number of vertices.  ' +
                    'Attribute ' + names[j] + ' has a different number of vertices ' +
                    '(' + currentNumberOfVertices.toString() + ')' +
                    ' than attribute ' + names[0] +
                    ' (' + numberOfVertices.toString() + ').');
            }
        }
    }
    
    // Sort attributes by the size of their components.  From left to right, a vertex stores floats, shorts, and then bytes.
    names.sort(function(left, right) {
        return ComponentDatatype.getSizeInBytes(attributes[right].componentDatatype) - ComponentDatatype.getSizeInBytes(attributes[left].componentDatatype);
        });
    
    // Compute sizes and strides.
    var vertexSizeInBytes = 0;
    var offsetsInBytes = {};
    
    for (j = 0; j < namesLength; ++j) {
        name = names[j];
        attribute = attributes[name];
        
        offsetsInBytes[name] = vertexSizeInBytes;
        vertexSizeInBytes += computeAttributeSizeInBytes(attribute);
    }
    
    if (vertexSizeInBytes > 0) {
        // Pad each vertex to be a multiple of the largest component datatype so each
        // attribute can be addressed using typed arrays.
        var maxComponentSizeInBytes = ComponentDatatype.getSizeInBytes(attributes[names[0]].componentDatatype); // Sorted large to small
        var remainder = vertexSizeInBytes % maxComponentSizeInBytes;
        if (remainder !== 0) {
            vertexSizeInBytes += (maxComponentSizeInBytes - remainder);
        }
        
        // Total vertex buffer size in bytes, including per-vertex padding.
        var vertexBufferSizeInBytes = numberOfVertices * vertexSizeInBytes;
        
        // Create array for interleaved vertices.  Each attribute has a different view (pointer) into the array.
        var buffer = new ArrayBuffer(vertexBufferSizeInBytes);
        var views = {};
        
        for (j = 0; j < namesLength; ++j) {
            name = names[j];
            var sizeInBytes = ComponentDatatype.getSizeInBytes(attributes[name].componentDatatype);
            
            views[name] = {
                pointer : ComponentDatatype.createTypedArray(attributes[name].componentDatatype, buffer),
                index : offsetsInBytes[name] / sizeInBytes, // Offset in ComponentType
                strideInComponentType : vertexSizeInBytes / sizeInBytes
            };
        }
        
        // Copy attributes into one interleaved array.
        // PERFORMANCE_IDEA:  Can we optimize these loops?
        for (j = 0; j < numberOfVertices; ++j) {
            for ( var n = 0; n < namesLength; ++n) {
                name = names[n];
                attribute = attributes[name];
                var values = attribute.values;
                var view = views[name];
                var pointer = view.pointer;
                
                var numberOfComponents = attribute.componentsPerAttribute;
                for ( var k = 0; k < numberOfComponents; ++k) {
                    pointer[view.index + k] = values[(j * numberOfComponents) + k];
                }
                
                view.index += view.strideInComponentType;
            }
        }
        
        return {
            buffer : buffer,
            offsetsInBytes : offsetsInBytes,
            vertexSizeInBytes : vertexSizeInBytes
        };
    }
    
    // No attributes to interleave.
    return undefined;
}
*/
/**
* Creates a vertex array from a geometry.  A geometry contains vertex attributes and optional index data
* in system memory, whereas a vertex array contains vertex buffers and an optional index buffer in WebGL
* memory for use with rendering.
* <br /><br />
* The <code>geometry</code> argument should use the standard layout like the geometry returned by {@link BoxGeometry}.
* <br /><br />
* <code>options</code> can have four properties:
* <ul>
*   <li><code>geometry</code>:  The source geometry containing data used to create the vertex array.</li>
*   <li><code>attributeLocations</code>:  An object that maps geometry attribute names to vertex shader attribute locations.</li>
*   <li><code>bufferUsage</code>:  The expected usage pattern of the vertex array's buffers.  On some WebGL implementations, this can significantly affect performance.  See {@link BufferUsage}.  Default: <code>BufferUsage.DYNAMIC_DRAW</code>.</li>
*   <li><code>interleave</code>:  Determines if all attributes are interleaved in a single vertex buffer or if each attribute is stored in a separate vertex buffer.  Default: <code>false</code>.</li>
* </ul>
* <br />
* If <code>options</code> is not specified or the <code>geometry</code> contains no data, the returned vertex array is empty.
*
* @memberof Context
*
* @param {Object} [options] An object defining the geometry, attribute indices, buffer usage, and vertex layout used to create the vertex array.
*
* @exception {RuntimeError} Each attribute list must have the same number of vertices.
* @exception {DeveloperError} The geometry must have zero or one index lists.
* @exception {DeveloperError} Index n is used by more than one attribute.
*
* @see Context#createVertexArray
* @see Context#createVertexBuffer
* @see Context#createIndexBuffer
* @see GeometryPipeline.createAttributeLocations
* @see ShaderProgram
*
* @example
* // Example 1. Creates a vertex array for rendering a box.  The default dynamic draw
* // usage is used for the created vertex and index buffer.  The attributes are not
* // interleaved by default.
* var geometry = new BoxGeometry();
* var va = context.createVertexArrayFromGeometry({
*     geometry           : geometry,
*     attributeLocations : GeometryPipeline.createAttributeLocations(geometry),
* });
*
* ////////////////////////////////////////////////////////////////////////////////
*
* // Example 2. Creates a vertex array with interleaved attributes in a
* // single vertex buffer.  The vertex and index buffer have static draw usage.
* var va = context.createVertexArrayFromGeometry({
*     geometry           : geometry,
*     attributeLocations : GeometryPipeline.createAttributeLocations(geometry),
*     bufferUsage        : BufferUsage.STATIC_DRAW,
*     interleave         : true
* });
*
* ////////////////////////////////////////////////////////////////////////////////
*
* // Example 3.  When the caller destroys the vertex array, it also destroys the
* // attached vertex buffer(s) and index buffer.
* va = va.destroy();
*/
    /*
    func createVertexArrayFromGeometry (
        #geometry: Geometry,
        attributeLocations: [String: Int],
        interleave: Bool = false) -> VertexArray {
            
            
            // fIXME: CreatedVAAtributes
            //var createdVAAttributes = options.vertexArrayAttributes;
            
            var name: String
            var attribute: GeometryAttribute
            var vertexBuffer: Buffer? = nil
            var vaAttributes = [VertexAttributes]()//var vaAttributes = (defined(createdVAAttributes)) ? createdVAAttributes : [];
            var attributes = geometry.attributes
            
            if interleave {
                // Use a single vertex buffer with interleaved vertices.
                /*var interleavedAttributes = interleaveAttributes(attributes)
                if (defined(interleavedAttributes)) {
                vertexBuffer = this.createVertexBuffer(interleavedAttributes.buffer, bufferUsage);
                var offsetsInBytes = interleavedAttributes.offsetsInBytes;
                var strideInBytes = interleavedAttributes.vertexSizeInBytes;
                
                for (name in attributes) {
                if (attributes.hasOwnProperty(name) && defined(attributes[name])) {
                attribute = attributes[name];
                
                if (defined(attribute.values)) {
                // Common case: per-vertex attributes
                vaAttributes.push({
                index : attributeLocations[name],
                vertexBuffer : vertexBuffer,
                componentDatatype : attribute.componentDatatype,
                componentsPerAttribute : attribute.componentsPerAttribute,
                normalize : attribute.normalize,
                offsetInBytes : offsetsInBytes[name],
                strideInBytes : strideInBytes
                });
                } else {
                // Constant attribute for all vertices
                vaAttributes.push({
                index : attributeLocations[name],
                value : attribute.value,
                componentDatatype : attribute.componentDatatype,
                normalize : attribute.normalize
                });
                }
                }
                }
                }*/
            } else {
                // One vertex buffer per attribute.
                for i in 0...5 {
                    if let attribute = attributes[i] {
                        
                        var componentDatatype = attribute.componentDatatype
                        if (componentDatatype == ComponentDatatype.Float64) {
                            componentDatatype = ComponentDatatype.Float32
                        }
                        
                        vertexBuffer = attribute.buffer/*createBuffer(array: UnsafeMutablePointer<Void>(attribute.values!.data().bytes), componentDatatype: componentDatatype, sizeInBytes: attribute.values!.sizeInBytes)*/
                        
                        vaAttributes.append(VertexAttributes(
                            index: attributeLocations[attributes.name(i)]!,
                            vertexBuffer: vertexBuffer!,
                            componentsPerAttribute: attribute.componentsPerAttribute,
                            componentDatatype: componentDatatype,
                            normalize: attribute.normalize))
                    }
                }
            }
            
            var indexBuffer: Buffer? = nil
            if geometry.indices != nil {
                /*if geometry.computeNumberOfVertices() > Math.SixtyFourKilobytes && elementIndexUint == true {
                    
                    indexBuffer = createIndexBuffer(
                        // FIXME: combine datatype
                        array: SerializedType.fromIntArray(geometry.indices!, datatype: .UnsignedInt),
                        indexDatatype: IndexDatatype.UnsignedInt)
                } else {
                    indexBuffer = createIndexBuffer(
                        array: SerializedType.fromIntArray(geometry.indices!, datatype: .UnsignedShort),
                        indexDatatype: IndexDatatype.UnsignedShort)
                }*/
            }
            return createVertexArray(vaAttributes, indexBuffer: indexBuffer)
    }*/
/*
var viewportQuadAttributeLocations = {
    position : 0,
    textureCoordAndEncodedNormals : 1
};

Context.prototype.createViewportQuadCommand = function(fragmentShaderSource, overrides) {
    // Per-context cache for viewport quads
    var vertexArray = this.cache.viewportQuad_vertexArray;
    
    if (!defined(vertexArray)) {
        var geometry = new Geometry({
            attributes : {
                position : new GeometryAttribute({
                componentDatatype : ComponentDatatype.FLOAT,
                componentsPerAttribute : 2,
                values : [
                -1.0, -1.0,
                1.0, -1.0,
                1.0,  1.0,
                -1.0,  1.0
                ]
                }),
                
                textureCoordAndEncodedNormals : new GeometryAttribute({
                componentDatatype : ComponentDatatype.FLOAT,
                componentsPerAttribute : 2,
                values : [
                0.0, 0.0,
                1.0, 0.0,
                1.0, 1.0,
                0.0, 1.0
                ]
                })
            },
            // Workaround Internet Explorer 11.0.8 lack of TRIANGLE_FAN
            indices : new Uint16Array([0, 1, 2, 0, 2, 3]),
            primitiveType : PrimitiveType.TRIANGLES
            });
        
        vertexArray = this.createVertexArrayFromGeometry({
            geometry : geometry,
            attributeLocations : {
                position : 0,
                textureCoordAndEncodedNormals : 1
            },
            bufferUsage : BufferUsage.STATIC_DRAW,
            interleave : true
            });
        
        this.cache.viewportQuad_vertexArray = vertexArray;
    }
    
    overrides = defaultValue(overrides, defaultValue.EMPTY_OBJECT);
    
    return new DrawCommand({
        vertexArray : vertexArray,
        primitiveType : PrimitiveType.TRIANGLES,
        renderState : overrides.renderState,
        shaderProgram : this.createShaderProgram(ViewportQuadVS, fragmentShaderSource, viewportQuadAttributeLocations),
        uniformMap : overrides.uniformMap,
        owner : overrides.owner,
        framebuffer : overrides.framebuffer
        });
};

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
