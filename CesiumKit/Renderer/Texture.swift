//
//  Texture.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import CoreGraphics
import Metal

private let _colorSpace = CGColorSpaceCreateDeviceRGB()!

private var _defaultSampler: Sampler! = nil

enum TextureSource {
    case Image(CGImageRef)
    case Buffer(Imagebuffer)
    case CubeMap(CubeMapSources)
    
    var width: Int {
        get {
            switch self {
            case .Image(let image):
                return CGImageGetWidth(image)
            case .Buffer(let imagebuffer):
                return imagebuffer.width
            case .CubeMap(let sources):
                return CGImageGetWidth(sources.negativeX)
            }
        }
    }
    
    var height: Int {
        get {
            switch self {
            case .Image(let image):
                return Int(CGImageGetHeight(image))
            case .Buffer(let imagebuffer):
                return imagebuffer.height
            case .CubeMap(let sources):
                return CGImageGetHeight(sources.negativeX)
            }
        }
    }
}

struct TextureOptions {
    
    let source: TextureSource?
    
    let width: Int
    
    let height: Int
    
    let cubeMap: Bool
    
    let pixelFormat: PixelFormat
    
    let flipY: Bool
    
    let premultiplyAlpha: Bool
    
    let usage: TextureUsage
    
    let sampler: Sampler?
    
    init(source: TextureSource? = nil, width: Int? = 0, height: Int? = 0, cubeMap: Bool = false, pixelFormat: PixelFormat = .BGRA8Unorm, flipY: Bool = false, premultiplyAlpha: Bool = true, usage: TextureUsage = .Unknown, sampler: Sampler? = nil) {
        assert (source != nil || (width != nil && height != nil), "Must have texture source or dimensions")
         
        self.source = source
        self.width = source != nil ? source!.width : width!
        self.height = source != nil ? source!.height : height!
        self.cubeMap = cubeMap
        self.pixelFormat = pixelFormat
        self.flipY = flipY
        self.premultiplyAlpha = premultiplyAlpha
        self.usage = usage
        self.sampler = sampler
    }
}

class Texture {
    
    let width: Int
    
    let height: Int
    
    let cubeMap: Bool
    
    let pixelFormat: PixelFormat
    
    var textureFilterAnisotropic = true
    
    var premultiplyAlpha = true
    
    let usage: TextureUsage
    
    var mipmapped: Bool = false

    weak var context: Context?
    
    var metalTexture: MTLTexture!
    
    /**
    * The sampler to use when sampling this texture.
    * Create a sampler by calling {@link Context#createSampler}.  If this
    * parameter is not specified, a default sampler is used.  The default sampler clamps texture
    * coordinates in both directions, uses linear filtering for both magnification and minifcation,
    * and uses a maximum anisotropy of 1.0.
    * @memberof Texture.prototype
    * @type {Object}
    */
    var sampler: Sampler
        
    //var dimensions: Cartesian2

    init(context: Context, options: TextureOptions) {

        let source = options.source
        
        if source == nil {
            width = options.width
            height = options.height
        } else {
            width = source!.width
            height = source!.height
        }
        
        cubeMap = options.cubeMap
        pixelFormat = options.pixelFormat
        
        // Use premultiplied alpha for opaque textures should perform better on Chrome:
        // http://media.tojicode.com/webglCamp4/#20*/
        premultiplyAlpha = options.premultiplyAlpha || options.pixelFormat == .RGBA8Unorm || options.pixelFormat == .BGRA8Unorm || options.pixelFormat == .R8Unorm
        
        usage = options.usage
        //var mipmapped = Math.isPowerOfTwo(width) && Math.isPowerOfTwo(height)
        mipmapped = false
        
        if _defaultSampler == nil {
            _defaultSampler = Sampler(context: context)
        }
        self.sampler = _defaultSampler ?? _defaultSampler

        assert(width > 0, "Width must be greater than zero.")
        assert(width <= context.limits.maximumTextureSize, "Width must be less than or equal to the maximum texture size: \(context.limits.maximumTextureSize)")
        assert(self.height > 0, "Height must be greater than zero.")
        assert(self.height <= context.limits.maximumTextureSize, "Width must be less than or equal to the maximum texture size: \(context.limits.maximumTextureSize)")
        
        /*
        if self.pixelFormat == PixelFormat.DepthComponent && (self.pixelDatatype != PixelDatatype.UnsignedShort && self.pixelDatatype != PixelDatatype.UnsignedInt) {
            assert(true, "When options.pixelFormat is DEPTH_COMPONENT, options.pixelDatatype must be UNSIGNED_SHORT or UNSIGNED_INT.")
        }
        if self.pixelFormat == PixelFormat.DepthStencil && self.pixelDatatype != PixelDatatype.UnsignedInt24_8 {
            assert(true, "When options.pixelFormat is DEPTH_STENCIL, options.pixelDatatype must be UNSIGNED_INT_24_8_WEBGL")
        }
        if self.pixelDatatype == PixelDatatype.Float && !context.floatingPointTexture {
            assert(true, "When options.pixelDatatype is FLOAT, this WebGL implementation must support the OES_texture_float extension.  Check context.floatingPointTexture.")
        }
        
        if self.pixelFormat.isDepthFormat() {
            assert(source == nil, "When options.pixelFormat is DEPTH_COMPONENT or DEPTH_STENCIL, source cannot be provided.")
            assert(context.depthTexture, "When options.pixelFormat is DEPTH_COMPONENT or DEPTH_STENCIL, this WebGL implementation must support WEBGL_depth_texture.  Check context.depthTexture")
        }
        */
        
        let flipY = options.flipY
        
        // FIXME: mipmapping
        let textureDescriptor: MTLTextureDescriptor
        if cubeMap {
            textureDescriptor = MTLTextureDescriptor.textureCubeDescriptorWithPixelFormat(pixelFormat.toMetal(), size: width, mipmapped: false)
        } else {
            textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(pixelFormat.toMetal(),
                width: width, height: height, mipmapped: false/*mipmapped*/)
        }
        textureDescriptor.usage = usage.toMetal()
        
        if pixelFormat == .Depth32Float || pixelFormat == .Depth32FloatStencil8 || pixelFormat == .Stencil8 || textureDescriptor.sampleCount > 1 {
            textureDescriptor.storageMode = .Private
        }
        #if os(OSX)
            if pixelFormat == .Depth32FloatStencil8 {
                textureDescriptor.storageMode = .Private
            }
        #endif
        metalTexture = context.device.newTextureWithDescriptor(textureDescriptor)
        
         if let source = source {
            switch source {
            case .Buffer(let imagebuffer):
                // Source: typed array
                let region = MTLRegionMake2D(0, 0, imagebuffer.width, imagebuffer.height)
                metalTexture.replaceRegion(region, mipmapLevel: 0, withBytes: imagebuffer.array, bytesPerRow: imagebuffer.width * strideofValue(imagebuffer.array.first!))
            case .Image(let imageRef): // From http://stackoverflow.com/questions/14362868/convert-an-uiimage-in-a-texture
                
                let textureData = imageRef.renderToPixelArray(
                    colorSpace: _colorSpace,
                    premultiplyAlpha: premultiplyAlpha,
                    flipY: flipY
                )
                // Copy to texture
                let region = MTLRegionMake2D(0, 0, width, height)
                metalTexture.replaceRegion(region, mipmapLevel: 0, withBytes: textureData.array, bytesPerRow: textureData.bytesPerRow)
            case .CubeMap(let sources):

                let region = MTLRegionMake2D(0, 0, width, height)

                for slice in 0..<6 {
                    let textureData = sources.sources[slice].renderToPixelArray(
                        colorSpace: _colorSpace,
                        premultiplyAlpha: premultiplyAlpha,
                        flipY: flipY
                    )
                    // Copy to texture
                    metalTexture.replaceRegion(
                        region,
                        mipmapLevel: 0,
                        slice: slice,
                        withBytes: textureData.array,
                        bytesPerRow: textureData.bytesPerRow,
                        bytesPerImage: textureData.bytesPerRow * height
                    )
                }
            }
            
        }
        self.context = context
        self.textureFilterAnisotropic = context.textureFilterAnisotropic
    }
    
    init (context: Context, metalTexture: MTLTexture, sampler: Sampler? = nil) {
        self.context = context
        self.metalTexture = metalTexture
        self.width = metalTexture.width
        self.height = metalTexture.height
        self.cubeMap = metalTexture.textureType == .TypeCube
        self.pixelFormat = PixelFormat(rawValue: metalTexture.pixelFormat.rawValue) ?? .Invalid
        self.textureFilterAnisotropic = true
        self.usage = TextureUsage(rawValue: metalTexture.usage.rawValue)
        self.premultiplyAlpha = true
        if _defaultSampler == nil {
            _defaultSampler = Sampler(context: context)
        }
        self.sampler = sampler ?? _defaultSampler
    }
    /*
     
    /**
    * Copy new image data into this texture, from a source {@link ImageData}, {@link Image}, {@link Canvas}, or {@link Video}.
    * or an object with width, height, and arrayBufferView properties.
    *
    * @param {Object} source The source {@link ImageData}, {@link Image}, {@link Canvas}, or {@link Video},
    *                        or an object with width, height, and arrayBufferView properties.
    * @param {Number} [xOffset=0] The offset in the x direction within the texture to copy into.
    * @param {Number} [yOffset=0] The offset in the y direction within the texture to copy into.
    *
    * @exception {DeveloperError} Cannot call copyFrom when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.
    * @exception {DeveloperError} xOffset must be greater than or equal to zero.
    * @exception {DeveloperError} yOffset must be greater than or equal to zero.
    * @exception {DeveloperError} xOffset + source.width must be less than or equal to width.
    * @exception {DeveloperError} yOffset + source.height must be less than or equal to height.
    * @exception {DeveloperError} This texture was destroyed, i.e., destroy() was called.
    *
    * @example
    * texture.copyFrom({
    *   width : 1,
    *   height : 1,
    *   arrayBufferView : new Uint8Array([255, 0, 0, 255])
    * });
    */
    Texture.prototype.copyFrom = function(source, xOffset, yOffset) {
    xOffset = defaultValue(xOffset, 0);
    yOffset = defaultValue(yOffset, 0);
    
    //>>includeStart('debug', pragmas.debug);
    if (!defined(source)) {
    throw new DeveloperError('source is required.');
    }
    if (PixelFormat.isDepthFormat(this._pixelFormat)) {
    throw new DeveloperError('Cannot call copyFrom when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.');
    }
    if (xOffset < 0) {
    throw new DeveloperError('xOffset must be greater than or equal to zero.');
    }
    if (yOffset < 0) {
    throw new DeveloperError('yOffset must be greater than or equal to zero.');
    }
    if (xOffset +  source.width > this._width) {
    throw new DeveloperError('xOffset + source.width must be less than or equal to width.');
    }
    if (yOffset + source.height > this._height) {
    throw new DeveloperError('yOffset + source.height must be less than or equal to height.');
    }
    //>>includeEnd('debug');
    
    // Internet Explorer 11.0.8 is apparently unable to upload a texture to a non-zero
    // yOffset when the pipeline is configured to FLIP_Y.  So do the flip manually.
    if (FeatureDetection.isInternetExplorer() && yOffset !== 0 && this._flipY) {
    var texture = new Texture(this._context, {
    source : source,
    flipY : true,
    pixelFormat : this._pixelFormat,
    pixelDatatype : this._pixelDatatype,
    preMultiplyAlpha : this._preMultiplyAlpha
    });
    
    var framebuffer = this._context.createFramebuffer({
    colorTextures : [texture]
    });
    framebuffer._bind();
    this.copyFromFramebuffer(xOffset, yOffset, 0, 0, texture.width, texture.height);
    framebuffer._unBind();
    framebuffer.destroy();
    
    return;
    }
    
    var gl = this._context._gl;
    var target = this._textureTarget;
    
    // TODO: gl.pixelStorei(gl._UNPACK_ALIGNMENT, 4);
    gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, this._preMultiplyAlpha);
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, this._flipY);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(target, this._texture);
    
    if (source.arrayBufferView) {
    gl.texSubImage2D(target, 0, xOffset, yOffset,  source.width, source.height, this._pixelFormat, this._pixelDatatype, source.arrayBufferView);
    } else {
    gl.texSubImage2D(target, 0, xOffset, yOffset, this._pixelFormat, this._pixelDatatype, source);
    }
    
    gl.bindTexture(target, null);
    };
    
    /**
    * @param {Number} [xOffset=0] The offset in the x direction within the texture to copy into.
    * @param {Number} [yOffset=0] The offset in the y direction within the texture to copy into.
    * @param {Number} [framebufferXOffset=0] optional
    * @param {Number} [framebufferYOffset=0] optional
    * @param {Number} [width=width] optional
    * @param {Number} [height=height] optional
    *
    * @exception {DeveloperError} Cannot call copyFromFramebuffer when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.
    * @exception {DeveloperError} Cannot call copyFromFramebuffer when the texture pixel data type is FLOAT.
    * @exception {DeveloperError} This texture was destroyed, i.e., destroy() was called.
    * @exception {DeveloperError} xOffset must be greater than or equal to zero.
    * @exception {DeveloperError} yOffset must be greater than or equal to zero.
    * @exception {DeveloperError} framebufferXOffset must be greater than or equal to zero.
    * @exception {DeveloperError} framebufferYOffset must be greater than or equal to zero.
    * @exception {DeveloperError} xOffset + width must be less than or equal to width.
    * @exception {DeveloperError} yOffset + height must be less than or equal to height.
    */
    Texture.prototype.copyFromFramebuffer = function(xOffset, yOffset, framebufferXOffset, framebufferYOffset, width, height) {
    xOffset = defaultValue(xOffset, 0);
    yOffset = defaultValue(yOffset, 0);
    framebufferXOffset = defaultValue(framebufferXOffset, 0);
    framebufferYOffset = defaultValue(framebufferYOffset, 0);
    width = defaultValue(width, this._width);
    height = defaultValue(height, this._height);
    
    //>>includeStart('debug', pragmas.debug);
    if (PixelFormat.isDepthFormat(this._pixelFormat)) {
    throw new DeveloperError('Cannot call copyFromFramebuffer when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.');
    }
    if (this._pixelDatatype === PixelDatatype.FLOAT) {
    throw new DeveloperError('Cannot call copyFromFramebuffer when the texture pixel data type is FLOAT.');
    }
    if (xOffset < 0) {
    throw new DeveloperError('xOffset must be greater than or equal to zero.');
    }
    if (yOffset < 0) {
    throw new DeveloperError('yOffset must be greater than or equal to zero.');
    }
    if (framebufferXOffset < 0) {
    throw new DeveloperError('framebufferXOffset must be greater than or equal to zero.');
    }
    if (framebufferYOffset < 0) {
    throw new DeveloperError('framebufferYOffset must be greater than or equal to zero.');
    }
    if (xOffset + width > this._width) {
    throw new DeveloperError('xOffset + width must be less than or equal to width.');
    }
    if (yOffset + height > this._height) {
    throw new DeveloperError('yOffset + height must be less than or equal to height.');
    }
    //>>includeEnd('debug');
    
    var gl = this._context._gl;
    var target = this._textureTarget;
    
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(target, this._texture);
    gl.copyTexSubImage2D(target, 0, xOffset, yOffset, framebufferXOffset, framebufferYOffset, width, height);
    gl.bindTexture(target, null);
    };
    */
    /**
    * @param {MipmapHint} [hint=MipmapHint.DONT_CARE] optional.
    *
    * @exception {DeveloperError} Cannot call generateMipmap when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.
    * @exception {DeveloperError} hint is invalid.
    * @exception {DeveloperError} This texture's width must be a power of two to call generateMipmap().
    * @exception {DeveloperError} This texture's height must be a power of two to call generateMipmap().
    * @exception {DeveloperError} This texture was destroyed, i.e., destroy() was called.
    */
    func generateMipmaps () {

        
        //assert(!pixelFormat.isDepthFormat(), "Cannot call generateMipmap when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.")
        
        assert(mipmapped, "mipmapping must be enabled during texture creation")
        
        /*glHint(GLenum(GL_GENERATE_MIPMAP_HINT), hint.toGL())
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(textureTarget, textureName)
        glGenerateMipmap(textureTarget)
        glBindTexture(textureTarget, 0)*/
    }

}
