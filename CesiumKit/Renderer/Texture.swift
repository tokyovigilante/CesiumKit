//
//  Texture.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

struct TextureOptions {
    
    struct Source {
        var width: Int? = nil
        var height: Int? = nil
        
        var arrayBufferView: [UInt8]?
        var frameBuffer: Framebuffer?
    }
    
    var source: Source?
    
    var width: Int? = nil

    var height: Int? = nil
    
    var pixelFormat: PixelFormat = PixelFormat.RGBA
    
    var pixelDatatype: PixelDatatype = PixelDatatype.UnsignedByte
    
    var flipY: Bool = true
    
    var premultiplyAlpha = true
}



class Texture {
    
    var width: Int
    
    var height: Int
    
    var pixelFormat: PixelFormat
    
    var pixelDatatype: PixelDatatype
    
    var options: TextureOptions
    
    var textureFilterAnisotropic = true
    
    weak var context: Context?
    
    init(context: Context, options: TextureOptions) {
        
        self.options = options
        
        var source = options.source
        
        self.width = options.source ? options.source!.width! : options.width!
        self.height = options.source ? options.source!.width! : options.width!
        
        self.pixelFormat = options.pixelFormat

        self.pixelDatatype = options.pixelDatatype
        
        assert(self.width > 0, "Width must be greater than zero.")
        assert(self.width <= Int(context.maximumTextureSize), "Width must be less than or equal to the maximum texture size" + context.maximumTextureSize)
        assert(self.height > 0, "Height must be greater than zero.")
        assert(self.height <= Int(context.maximumTextureSize), "Width must be less than or equal to the maximum texture size" + context.maximumTextureSize)

        if self.pixelFormat == PixelFormat.DepthComponent && (self.pixelDatatype != PixelDatatype.UnsignedShort && self.pixelDatatype != PixelDatatype.UnsignedInt) {
            assert(true, "When options.pixelFormat is DEPTH_COMPONENT, options.pixelDatatype must be UNSIGNED_SHORT or UNSIGNED_INT.")
        }
        if self.pixelFormat == PixelFormat.DepthStencil && self.pixelDatatype != PixelDatatype.UnsignedInt24_8 {
            assert(true, "When options.pixelFormat is DEPTH_STENCIL, options.pixelDatatype must be UNSIGNED_INT_24_8_WEBGL")
        }
        if self.pixelDatatype == PixelDatatype.Float && !context.floatingPointTexture {
            assert(true, "When options.pixelDatatype is FLOAT, this WebGL implementation must support the OES_texture_float extension.  Check context.floatingPointTexture.")∫
        }
        
        if self.pixelFormat.isDepthFormat() {
            //>>includeStart('debug', pragmas.debug);
            if source {
                assert(true, "When options.pixelFormat is DEPTH_COMPONENT or DEPTH_STENCIL, source cannot be provided.")
            }
            //>>includeEnd('debug');
            
            if (!context.depthTexture) {
                assert(true, "When options.pixelFormat is DEPTH_COMPONENT or DEPTH_STENCIL, this WebGL implementation must support WEBGL_depth_texture.  Check context.depthTexture")
            }
        }
        
        // Use premultiplied alpha for opaque textures should perform better on Chrome:
        // http://media.tojicode.com/webglCamp4/#20
        var preMultiplyAlpha = options.preMultiplyAlpha || self.pixelFormat === PixelFormat.RGB || self.pixelFormat == PixelFormat.Luminance
        var flipY = options.flipY
        
        var textureName: GLuint = 0
        glGenTextures(1, &textureName)
        
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, textureName)
        
        if (defined(source)) {
            // TODO: _gl.pixelStorei(_gl._UNPACK_ALIGNMENT, 4);
            //glPixelStorei(GL_UNPACK, <#param: GLint#>)
            //gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, preMultiplyAlpha);
            //gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, flipY);
            
            if source.arrayBufferView {
                // Source: typed array
                glTexImage2D(GL_TEXTURE_2D, 0, pixelFormat, GLsizei(width), GLsizei(height), 0, pixelFormat, pixelDatatype, &source!.arrayBufferView!)
            } else if (defined(source.framebuffer)) {
                // Source: framebuffer
                if (source.framebuffer != context.defaultFramebuffer) {
                    source.framebuffer.bind()
                }
                
                glCopyTexImage2D(textureTarget, 0, pixelFormat, source.xOffset, source.yOffset, width, height, 0)
                
                if (source.framebuffer != context.defaultFramebuffer) {
                    source.framebuffer.unbind()
                }
            } /*else {
                // Source: ImageData, HTMLImageElement, HTMLCanvasElement, or HTMLVideoElement
                gl.texImage2D(textureTarget, 0, pixelFormat, pixelFormat, pixelDatatype, source);
            }*/
        } else {
            gl.texImage2D(textureTarget, 0, pixelFormat, width, height, 0, pixelFormat, pixelDatatype, 0)
        }
        gl.bindTexture(textureTarget, null)
        
        self.context = context
        self.textureFilterAnisotropic = context.textureFilterAnisotropic
        this._textureTarget = textureTarget
        this._texture = texture
        this._pixelFormat = pixelFormat
        this._pixelDatatype = pixelDatatype
        this._width = width
        this._height = height
        this._dimensions = Cartesian2(width, height)
        this._preMultiplyAlpha = preMultiplyAlpha
        this._flipY = flipY
        this._sampler = undefined
        
        this.sampler = undefined;

    }
    /*
    defineProperties(Texture.prototype, {
    /**
    * The sampler to use when sampling this texture.
    * Create a sampler by calling {@link Context#createSampler}.  If this
    * parameter is not specified, a default sampler is used.  The default sampler clamps texture
    * coordinates in both directions, uses linear filtering for both magnification and minifcation,
    * and uses a maximum anisotropy of 1.0.
    * @memberof Texture.prototype
    * @type {Object}
    */
    sampler : {
    get : function() {
    return this._sampler;
    },
    set : function(sampler) {
    var samplerDefined = true;
    if (!defined(sampler)) {
    samplerDefined = false;
    var minFilter = TextureMinificationFilter.LINEAR;
    var magFilter = TextureMagnificationFilter.LINEAR;
    if (this._pixelDatatype === PixelDatatype.FLOAT) {
    minFilter = TextureMinificationFilter.NEAREST;
    magFilter = TextureMagnificationFilter.NEAREST;
    }
    
    sampler = {
    wrapS : TextureWrap.CLAMP_TO_EDGE,
    wrapT : TextureWrap.CLAMP_TO_EDGE,
    minificationFilter : minFilter,
    magnificationFilter : magFilter,
    maximumAnisotropy : 1.0
    };
    }
    
    if (this._pixelDatatype === PixelDatatype.FLOAT) {
    if (sampler.minificationFilter !== TextureMinificationFilter.NEAREST &&
    sampler.minificationFilter !== TextureMinificationFilter.NEAREST_MIPMAP_NEAREST) {
    throw new DeveloperError('Only NEAREST and NEAREST_MIPMAP_NEAREST minification filters are supported for floating point textures.');
}

if (sampler.magnificationFilter !== TextureMagnificationFilter.NEAREST) {
    throw new DeveloperError('Only the NEAREST magnification filter is supported for floating point textures.');
}
}

var gl = this._context._gl;
var target = this._textureTarget;

gl.activeTexture(gl.TEXTURE0);
gl.bindTexture(target, this._texture);
gl.texParameteri(target, gl.TEXTURE_MIN_FILTER, sampler.minificationFilter);
gl.texParameteri(target, gl.TEXTURE_MAG_FILTER, sampler.magnificationFilter);

gl.texParameteri(target, gl.TEXTURE_WRAP_S, sampler.wrapS);
gl.texParameteri(target, gl.TEXTURE_WRAP_T, sampler.wrapT);
if (defined(this._textureFilterAnisotropic)) {
    gl.texParameteri(target, this._textureFilterAnisotropic.TEXTURE_MAX_ANISOTROPY_EXT, sampler.maximumAnisotropy);
}
gl.bindTexture(target, null);

this._sampler = !samplerDefined ? undefined : {
    wrapS : sampler.wrapS,
    wrapT : sampler.wrapT,
    minificationFilter : sampler.minificationFilter,
    magnificationFilter : sampler.magnificationFilter,
    maximumAnisotropy : sampler.maximumAnisotropy
};
}
},
pixelFormat : {
    get : function() {
        return this._pixelFormat;
    }
},
pixelDatatype : {
    get : function() {
        return this._pixelDatatype;
    }
},
dimensions : {
    get : function() {
        return this._dimensions;
    }
},
preMultiplyAlpha : {
    get : function() {
        return this._preMultiplyAlpha;
    }
},
flipY : {
    get : function() {
        return this._flipY;
    }
},
width : {
    get : function() {
        return this._width;
    }
},
height : {
    get : function() {
        return this._height;
    }
},
_target : {
    get : function() {
        return this._textureTarget;
    }
}
});

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

/**
* @param {MipmapHint} [hint=MipmapHint.DONT_CARE] optional.
*
* @exception {DeveloperError} Cannot call generateMipmap when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.
* @exception {DeveloperError} hint is invalid.
* @exception {DeveloperError} This texture's width must be a power of two to call generateMipmap().
* @exception {DeveloperError} This texture's height must be a power of two to call generateMipmap().
* @exception {DeveloperError} This texture was destroyed, i.e., destroy() was called.
*/
Texture.prototype.generateMipmap = function(hint) {
    hint = defaultValue(hint, MipmapHint.DONT_CARE);
    
        //>>includeStart('debug', pragmas.debug);
        if (PixelFormat.isDepthFormat(this._pixelFormat)) {
            throw new DeveloperError('Cannot call generateMipmap when the texture pixel format is DEPTH_COMPONENT or DEPTH_STENCIL.');
        }
        if (this._width > 1 && !CesiumMath.isPowerOfTwo(this._width)) {
            throw new DeveloperError('width must be a power of two to call generateMipmap().');
        }
        if (this._height > 1 && !CesiumMath.isPowerOfTwo(this._height)) {
            throw new DeveloperError('height must be a power of two to call generateMipmap().');
        }
        if (!MipmapHint.validate(hint)) {
            throw new DeveloperError('hint is invalid.');
        }
        //>>includeEnd('debug');

        var gl = this._context._gl;
        var target = this._textureTarget;

        gl.hint(gl.GENERATE_MIPMAP_HINT, hint);
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(target, this._texture);
        gl.generateMipmap(target);
        gl.bindTexture(target, null);
    };

    Texture.prototype.isDestroyed = function() {
        return false;
    };

    Texture.prototype.destroy = function() {
        this._context._gl.deleteTexture(this._texture);
        return destroyObject(this);
    };

    return Texture;*/
}