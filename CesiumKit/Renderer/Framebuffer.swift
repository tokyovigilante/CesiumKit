//
//  Framebuffer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

var defaultFrameBufferObject: GLint? = nil

/**
* @private
*/
class Framebuffer {
    
    struct Options {
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
        var destroyAttachments: Bool
        
        var colorTextures: [Texture]?
        
        var colorRenderbuffers: [Renderbuffer]?
        
        var depthTexture: Texture?
        
        var depthRenderbuffer: Renderbuffer?
        
        var stencilRenderbuffer: Renderbuffer?
        
        var depthStencilTexture: Texture?
        
        var depthStencilRenderbuffer: Renderbuffer?
        
        init (
            destroyAttachments: Bool = true,
            colorTextures: [Texture]? = nil,
            colorRenderbuffers: [Renderbuffer]? = nil,
            depthTexture: Texture? = nil,
            depthRenderbuffer: Renderbuffer? = nil,
            stencilRenderbuffer: Renderbuffer? = nil,
            depthStencilTexture: Texture? = nil,
            depthStencilRenderbuffer: Renderbuffer? = nil) {
                
                self.destroyAttachments = destroyAttachments
                self.colorTextures = colorTextures
                self.colorRenderbuffers = colorRenderbuffers
                self.depthTexture = depthTexture
                self.depthRenderbuffer = depthRenderbuffer
                self.stencilRenderbuffer = stencilRenderbuffer
                self.depthStencilTexture = depthStencilTexture
                self.depthStencilRenderbuffer = depthStencilRenderbuffer
        }
    }
    
    private var _framebuffer: GLuint = 0
    
    var destroyAttachments: Bool
    
    private var _colorTextures: [Texture]? = nil

    private var _colorRenderbuffers: [Renderbuffer]? = nil
    
    var activeColorAttachments: [GLuint] {
        get {
            return _activeColorAttachments
        }
    }
    
    private var _activeColorAttachments = [GLuint]()
    
    private var _depthTexture: Texture? = nil
    
    private var _depthRenderbuffer: Renderbuffer? = nil
    
    private var _stencilRenderbuffer: Renderbuffer? = nil
    
    private var _depthStencilTexture: Texture? = nil

    private var _depthStencilRenderbuffer: Buffer? = nil

    
    init (maximumColorAttachments: GLint, options: Options = Options()) {
        
        glGenFramebuffers(1, &_framebuffer)
        
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
        destroyAttachments = options.destroyAttachments
        
        // Throw if a texture and renderbuffer are attached to the same point.  This won't
        // cause a WebGL error (because only one will be attached), but is likely a developer error.
        assert(!(options.colorTextures != nil && options.colorRenderbuffers != nil), "Cannot have both color texture and color renderbuffer attachments")
        
        assert(!(options.depthTexture != nil && options.depthRenderbuffer != nil), "Cannot have both a depth texture and depth renderbuffer attachment")
        
        assert(!(options.depthStencilTexture != nil && options.depthStencilRenderbuffer != nil), "Cannot have both a depth-stencil texture and depth-stencil renderbuffer attachment")
        
        // Avoid errors defined in Section 6.5 of the WebGL spec
        let depthAttachment = options.depthTexture != nil || options.depthRenderbuffer != nil
        let depthStencilAttachment = options.depthStencilTexture != nil || options.depthStencilRenderbuffer != nil
        
        assert(!(depthAttachment && depthStencilAttachment), "Cannot have both a depth and depth-stencil attachment.")
        
        assert(!(options.stencilRenderbuffer != nil && depthStencilAttachment), "Cannot have both a stencil and depth-stencil attachment.")
    
        assert (!(depthAttachment && options.stencilRenderbuffer != nil), "Cannot have both a depth and stencil attachment.")
        
        ///////////////////////////////////////////////////////////////////
        
        bind()
        
        /*var renderbuffer;*/
        var attachmentEnum: GLenum
        
        if let textures = options.colorTextures {
            
            _colorTextures = [Texture]()
            _activeColorAttachments = [GLuint](count: textures.count, repeatedValue: GLuint(0))

            assert(textures.count <= Int(maximumColorAttachments), "The number of color attachments exceeds the number supported.")
            
            for (i, texture) in enumerate(textures) {
                //assert(texture.pixelFormat.isColorFormat(), "The color-texture pixel-format must be a color format.")
                
                attachmentEnum = GLenum(GL_COLOR_ATTACHMENT0 + i)
                attachTexture(attachmentEnum, texture: texture)
                _activeColorAttachments[i] = attachmentEnum
                _colorTextures!.append(texture)
            }
        }
        // FIXME: Non-color texture framebuffer
        /*
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
        }*/
        
        unbind()
    }
    /*
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
        if defaultFrameBufferObject == nil {
            // save reference to default framebuffer
            var oldFBO: GLint = 0
            glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &oldFBO)
            defaultFrameBufferObject = oldFBO
        }
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _framebuffer)
    }

    func unbind () {
        assert(defaultFrameBufferObject != nil, "Unknown default framebuffer")
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(defaultFrameBufferObject!))
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
    */
    func attachTexture(attachment: GLenum, texture: Texture) {
        
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), attachment, texture.textureTarget, texture.textureName, 0)
    }
    /*
    function attachRenderbuffer(framebuffer, attachment, renderbuffer) {
    var gl = framebuffer._gl;
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, attachment, gl.RENDERBUFFER, renderbuffer._getRenderbuffer());
    }
*/
    deinit {
        glDeleteFramebuffers(1, &_framebuffer)
    }
    /*
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
