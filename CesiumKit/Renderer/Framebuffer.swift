//
//  Framebuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

struct FramebufferOptions {
    /**
    * When true, the framebuffer owns its attachments so they will be destroyed when
    * {@link Framebuffer#destroy} is called or when a new attachment is assigned
    * to an attachment point.
    *
    * @type {Boolean}
    * @default true
    *
    * @see Framebuffer#destroy
    */
    let destroyAttachments: Bool = true
}

/**
* @private
*/
class Framebuffer {
    
    private var _framebuffer: GLuint = 0
    
    private var _options = FramebufferOptions()
    
    private var _colorTextures = [GLuint]()

    private var _colorRenderbuffers = [GLuint]()
    
    var activeColorAttachments: [GLuint] {
        get {
            return _activeColorAttachments
        }
    }
    
    private var _activeColorAttachments = [GLuint]()
    
    private var _depthTexture: Texture? = nil
    
    private var _depthRenderBuffer: GLuint = 0
    
    private var _depthRenderbuffer: Buffer? = nil
    
    private var _stencilRenderbuffer: Buffer? = nil
    
    private var _depthStencilTexture: Texture? = nil

    private var _depthStencilRenderbuffer: Buffer? = nil

    
    init (maximumColorAttachments: Int, options: FramebufferOptions = FramebufferOptions()) {
        
        glGenFramebuffers(1, &_framebuffer)
        
        _options = options
    }
        /*
    
    
        /**
        * When true, the framebuffer owns its attachments so they will be destroyed when
        * {@link Framebuffer#destroy} is called or when a new attachment is assigned
        * to an attachment point.
        *
        * @type {Boolean}
        * @default true
        *
        * @see Framebuffer#destroy
        */
        this.destroyAttachments = defaultValue(options.destroyAttachments, true);
        
        // Throw if a texture and renderbuffer are attached to the same point.  This won't
        // cause a WebGL error (because only one will be attached), but is likely a developer error.
        
        //>>includeStart('debug', pragmas.debug);
        if (defined(options.colorTextures) && defined(options.colorRenderbuffers)) {
            throw new DeveloperError('Cannot have both color texture and color renderbuffer attachments.');
        }
        if (defined(options.depthTexture) && defined(options.depthRenderbuffer)) {
            throw new DeveloperError('Cannot have both a depth texture and depth renderbuffer attachment.');
        }
        if (defined(options.depthStencilTexture) && defined(options.depthStencilRenderbuffer)) {
            throw new DeveloperError('Cannot have both a depth-stencil texture and depth-stencil renderbuffer attachment.');
        }
        //>>includeEnd('debug');
        
        // Avoid errors defined in Section 6.5 of the WebGL spec
        var depthAttachment = (defined(options.depthTexture) || defined(options.depthRenderbuffer));
        var depthStencilAttachment = (defined(options.depthStencilTexture) || defined(options.depthStencilRenderbuffer));
        
        //>>includeStart('debug', pragmas.debug);
        if (depthAttachment && depthStencilAttachment) {
            throw new DeveloperError('Cannot have both a depth and depth-stencil attachment.');
        }
        if (defined(options.stencilRenderbuffer) && depthStencilAttachment) {
            throw new DeveloperError('Cannot have both a stencil and depth-stencil attachment.');
        }
        if (depthAttachment && defined(options.stencilRenderbuffer)) {
            throw new DeveloperError('Cannot have both a depth and stencil attachment.');
        }
        //>>includeEnd('debug');
        
        ///////////////////////////////////////////////////////////////////
        
        this._bind();
        
        var texture;
        var renderbuffer;
        var i;
        var length;
        var attachmentEnum;
        
        if (defined(options.colorTextures)) {
            var textures = options.colorTextures;
            length = this._colorTextures.length = this._activeColorAttachments.length = textures.length;
            
            //>>includeStart('debug', pragmas.debug);
            if (length > maximumColorAttachments) {
                throw new DeveloperError('The number of color attachments exceeds the number supported.');
            }
            //>>includeEnd('debug');
            
            for (i = 0; i < length; ++i) {
                texture = textures[i];
                
                //>>includeStart('debug', pragmas.debug);
                if (!PixelFormat.isColorFormat(texture.pixelFormat)) {
                    throw new DeveloperError('The color-texture pixel-format must be a color format.');
                }
                //>>includeEnd('debug');
                
                attachmentEnum = this._gl.COLOR_ATTACHMENT0 + i;
                attachTexture(this, attachmentEnum, texture);
                this._activeColorAttachments[i] = attachmentEnum;
                this._colorTextures[i] = texture;
            }
        }
        
        if (defined(options.colorRenderbuffers)) {
            var renderbuffers = options.colorRenderbuffers;
            length = this._colorRenderbuffers.length = this._activeColorAttachments.length = renderbuffers.length;
            
            //>>includeStart('debug', pragmas.debug);
            if (length > maximumColorAttachments) {
                throw new DeveloperError('The number of color attachments exceeds the number supported.');
            }
            //>>includeEnd('debug');
            
            for (i = 0; i < length; ++i) {
                renderbuffer = renderbuffers[i];
                attachmentEnum = this._gl.COLOR_ATTACHMENT0 + i;
                attachRenderbuffer(this, attachmentEnum, renderbuffer);
                this._activeColorAttachments[i] = attachmentEnum;
                this._colorRenderbuffers[i] = renderbuffer;
            }
        }
        
        if (defined(options.depthTexture)) {
            texture = options.depthTexture;
            
            //>>includeStart('debug', pragmas.debug);
            if (texture.pixelFormat !== PixelFormat.DEPTH_COMPONENT) {
                throw new DeveloperError('The depth-texture pixel-format must be DEPTH_COMPONENT.');
            }
            //>>includeEnd('debug');
            
            attachTexture(this, this._gl.DEPTH_ATTACHMENT, texture);
            this._depthTexture = texture;
        }
        
        if (defined(options.depthRenderbuffer)) {
            renderbuffer = options.depthRenderbuffer;
            attachRenderbuffer(this, this._gl.DEPTH_ATTACHMENT, renderbuffer);
            this._depthRenderbuffer = renderbuffer;
        }
        
        if (defined(options.stencilRenderbuffer)) {
            renderbuffer = options.stencilRenderbuffer;
            attachRenderbuffer(this, this._gl.STENCIL_ATTACHMENT, renderbuffer);
            this._stencilRenderbuffer = renderbuffer;
        }
        
        if (defined(options.depthStencilTexture)) {
            texture = options.depthStencilTexture;
            
            //>>includeStart('debug', pragmas.debug);
            if (texture.pixelFormat !== PixelFormat.DEPTH_STENCIL) {
                throw new DeveloperError('The depth-stencil pixel-format must be DEPTH_STENCIL.');
            }
            //>>includeEnd('debug');
            
            attachTexture(this, this._gl.DEPTH_STENCIL_ATTACHMENT, texture);
            this._depthStencilTexture = texture;
        }
        
        if (defined(options.depthStencilRenderbuffer)) {
            renderbuffer = options.depthStencilRenderbuffer;
            attachRenderbuffer(this, this._gl.DEPTH_STENCIL_ATTACHMENT, renderbuffer);
            this._depthStencilRenderbuffer = renderbuffer;
        }
        
        this._unBind();
    };
    
    defineProperties(Framebuffer.prototype, {
    /**
    * The status of the framebuffer. If the status is not WebGLRenderingContext.COMPLETE,
    * a {@link DeveloperError} will be thrown when attempting to render to the framebuffer.
    * @memberof Framebuffer.prototype
    * @type {Number}
    */
    status : {
    get : function() {
    this._bind();
    var status = this._gl.checkFramebufferStatus(this._gl.FRAMEBUFFER);
    this._unBind();
    return status;
    }
    },
    numberOfColorAttachments : {
    get : function() {
    return this._activeColorAttachments.length;
    }
    },
    depthTexture: {
    get : function() {
    return this._depthTexture;
    }
    },
    depthRenderbuffer: {
    get : function() {
    return this._depthRenderbuffer;
    }
    },
    stencilRenderbuffer : {
    get : function() {
    return this._stencilRenderbuffer;
    }
    },
    depthStencilTexture : {
    get : function() {
    return this._depthStencilTexture;
    }
    },
    depthStencilRenderbuffer : {
    get : function() {
    return this._depthStencilRenderbuffer;
    }
    },
    */
    /**
    * True if the framebuffer has a depth attachment.  Depth attachments include
    * depth and depth-stencil textures, and depth and depth-stencil renderbuffers.  When
    * rendering to a framebuffer, a depth attachment is required for the depth test to have effect.
    * @memberof Framebuffer.prototype
    * @type {Boolean}
    */
    var hasDepthAttachment: Bool {
        get {
            return _depthTexture != nil || _depthRenderbuffer != nil || _depthStencilTexture != nil || _depthStencilRenderbuffer != nil
        }
    }
    

    func bind() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(_framebuffer))
    }

    func unbind () {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }
    
    /*
    Framebuffer.prototype._getActiveColorAttachments = function() {
    return this._activeColorAttachments;
    };
    
    Framebuffer.prototype.getColorTexture = function(index) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(index) || index < 0 || index >= this._colorTextures.length) {
    throw new DeveloperError('index is required, must be greater than or equal to zero and must be less than the number of color attachments.');
}
//>>includeEnd('debug');

return this._colorTextures[index];
};

Framebuffer.prototype.getColorRenderbuffer = function(index) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(index) || index < 0 || index >= this._colorRenderbuffers.length) {
        throw new DeveloperError('index is required, must be greater than or equal to zero and must be less than the number of color attachments.');
    }
    //>>includeEnd('debug');
    
    return this._colorRenderbuffers[index];
};

Framebuffer.prototype.isDestroyed = function() {
    return false;
};
    
    function attachTexture(framebuffer, attachment, texture) {
    var gl = framebuffer._gl;
    gl.framebufferTexture2D(gl.FRAMEBUFFER, attachment, texture._target, texture._texture, 0);
    }
    
    function attachRenderbuffer(framebuffer, attachment, renderbuffer) {
    var gl = framebuffer._gl;
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, attachment, gl.RENDERBUFFER, renderbuffer._getRenderbuffer());
    }

Framebuffer.prototype.destroy = function() {
    if (this.destroyAttachments) {
        // If the color texture is a cube map face, it is owned by the cube map, and will not be destroyed.
        var i = 0;
        var textures = this._colorTextures;
        var length = textures.length;
        for (; i < length; ++i) {
            var texture = textures[i];
            if (defined(texture)) {
                texture.destroy();
            }
        }
        
        var renderbuffers = this._colorRenderbuffers;
        length = renderbuffers.length;
        for (i = 0; i < length; ++i) {
            var renderbuffer = renderbuffers[i];
            if (defined(renderbuffer)) {
                renderbuffer.destroy();
            }
        }
        
        this._depthTexture = this._depthTexture && this._depthTexture.destroy();
        this._depthRenderbuffer = this._depthRenderbuffer && this._depthRenderbuffer.destroy();
        this._stencilRenderbuffer = this._stencilRenderbuffer && this._stencilRenderbuffer.destroy();
        this._depthStencilTexture = this._depthStencilTexture && this._depthStencilTexture.destroy();
        this._depthStencilRenderbuffer = this._depthStencilRenderbuffer && this._depthStencilRenderbuffer.destroy();
    }
    
    this._gl.deleteFramebuffer(this._framebuffer);
    return destroyObject(this);
};
    

return Framebuffer;
});*/
}
