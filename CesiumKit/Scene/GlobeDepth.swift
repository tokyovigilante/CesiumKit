//
//  GlobeDepth.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

class GlobeDepth {

    private var _colorTextureProvider: TextureProvider? = nil
    private var _depthStencilTextureProvider: TextureProvider? = nil
    private var _globeDepthTextureProvider: TextureProvider? = nil

    private (set) var framebuffer: Framebuffer? = nil
    private var _copyDepthFramebuffer: Framebuffer? = nil
    
    private var _clearColorCommand: ClearCommand? = nil
    private var _copyColorCommand: ClearCommand? = nil
    private var _copyDepthCommand: ClearCommand? = nil

/*
this._debugGlobeDepthViewportCommand = undefined;
};

function executeDebugGlobeDepth(globeDepth, context, passState) {
if (!defined(globeDepth._debugGlobeDepthViewportCommand)) {
var fs =
'uniform sampler2D u_texture;\n' +
'varying vec2 v_textureCoordinates;\n' +
'void main()\n' +
'{\n' +
'    float z_window = czm_unpackDepth(texture2D(u_texture, v_textureCoordinates));\n' +
'    float n_range = czm_depthRange.near;\n' +
'    float f_range = czm_depthRange.far;\n' +
'    float z_ndc = (2.0 * z_window - n_range - f_range) / (f_range - n_range);\n' +
'    float scale = pow(z_ndc * 0.5 + 0.5, 8.0);\n' +
'    gl_FragColor = vec4(mix(vec3(0.0), vec3(1.0), scale), 1.0);\n' +
'}\n';

globeDepth._debugGlobeDepthViewportCommand = context.createViewportQuadCommand(fs, {
uniformMap : {
u_texture : function() {
return globeDepth._globeDepthTexture;
}
},
owner : globeDepth
});
}

globeDepth._debugGlobeDepthViewportCommand.execute(context, passState);
}
*/
    func destroyTextures() {
        _colorTextureProvider = nil
        _depthStencilTextureProvider = nil
        _globeDepthTextureProvider = nil
    }

func destroyFramebuffers() {
    framebuffer = nil
    _copyDepthFramebuffer = nil
}
/*
function createTextures(globeDepth, context, width, height) {
globeDepth._colorTexture = new Texture({
context : context,
width : width,
height : height,
pixelFormat : PixelFormat.RGBA,
pixelDatatype : PixelDatatype.UNSIGNED_BYTE
});

globeDepth._depthStencilTexture = new Texture({
context : context,
width : width,
height : height,
pixelFormat : PixelFormat.DEPTH_STENCIL,
pixelDatatype : PixelDatatype.UNSIGNED_INT_24_8_WEBGL
});

globeDepth._globeDepthTexture = new Texture({
context : context,
width : width,
height : height,
pixelFormat : PixelFormat.RGBA,
pixelDatatype : PixelDatatype.UNSIGNED_BYTE
});
}
*/
    func createFramebuffers(context: Context, width: Int, height: Int) {
        destroyTextures()
        destroyFramebuffers()
        /*
        createTextures(globeDepth, context, width, height);
        
        globeDepth.framebuffer = new Framebuffer({
            context : context,
            colorTextures : [globeDepth._colorTexture],
            depthStencilTexture : globeDepth._depthStencilTexture,
            destroyAttachments : false
        });
        
        globeDepth._copyDepthFramebuffer = new Framebuffer({
            context : context,
            colorTextures : [globeDepth._globeDepthTexture],
            destroyAttachments : false
        });*/
    }

    func updateFramebuffers(context: Context) {
        let width = Int(context.width)
        let height = Int(context.height)
        
        let textureChanged = _colorTexture == nil || _colorTexture!.width != width || _colorTexture!.height != height
        if framebuffer == nil || textureChanged {
            createFramebuffers(context, width: width, height: height)
        } else {
            advanceFramebufferTextures()
        }
    }
    
    func advanceFramebufferTextures () {
        
    }
/*
function updateCopyCommands(globeDepth, context) {
if (!defined(globeDepth._copyDepthCommand)) {
var fs =
'uniform sampler2D u_texture;\n' +
'varying vec2 v_textureCoordinates;\n' +
'void main()\n' +
'{\n' +
'    gl_FragColor = czm_packDepth(texture2D(u_texture, v_textureCoordinates).r);\n' +
'}\n';
globeDepth._copyDepthCommand = context.createViewportQuadCommand(fs, {
renderState : RenderState.fromCache(),
uniformMap : {
u_texture : function() {
return globeDepth._depthStencilTexture;
}
},
owner : globeDepth
});
}

globeDepth._copyDepthCommand.framebuffer = globeDepth._copyDepthFramebuffer;

if (!defined(globeDepth._copyColorCommand)) {
globeDepth._copyColorCommand = context.createViewportQuadCommand(PassThrough, {
renderState : RenderState.fromCache(),
uniformMap : {
u_texture : function() {
return globeDepth._colorTexture;
}
},
owner : globeDepth
});
}

if (!defined(globeDepth._clearColorCommand)) {
globeDepth._clearColorCommand = new ClearCommand({
color : new Color(0.0, 0.0, 0.0, 0.0),
stencil : 0.0,
owner : globeDepth
});
}

globeDepth._clearColorCommand.framebuffer = globeDepth.framebuffer;
}

GlobeDepth.prototype.executeDebugGlobeDepth = function(context, passState) {
executeDebugGlobeDepth(this, context, passState);
};*/

    func update (context: Context) {

        updateFramebuffers(context)
        //updateCopyCommands(this, context);
        //context.uniformState.globeDepthTexture = undefined;
    }

    func executeCopyDepth (context: Context, passState: PassState) {
        /*if (defined(this._copyDepthCommand)) {
            this._copyDepthCommand.execute(context, passState);
            context.uniformState.globeDepthTexture = this._globeDepthTexture;
        }*/
    }


    func executeCopyColor (context: Context, passState: PassState) {
        /*if (defined(this._copyColorCommand)) {
            this._copyColorCommand.execute(context, passState);
        }*/
    }
    
    func clear (context: Context, passState: PassState, clearColor: Cartesian4) {
        if _clearColorCommand != nil {
            var clear = _clearColorCommand!
            clear.color = clearColor
            clear.execute(context, passState: passState)
        }
    }
/*
GlobeDepth.prototype.isDestroyed = function() {
return false;
};

GlobeDepth.prototype.destroy = function() {
destroyTextures(this);
destroyFramebuffers(this);

if (defined(this._copyColorCommand)) {
this._copyColorCommand.shaderProgram = this._copyColorCommand.shaderProgram.destroy();
}

if (defined(this._copyDepthCommand)) {
this._copyDepthCommand.shaderProgram = this._copyDepthCommand.shaderProgram.destroy();
}

var command = this._debugGlobeDepthViewportCommand;
if (defined(command)) {
command.shaderProgram = command.shaderProgram.destroy();
}

return destroyObject(this);
};

return GlobeDepth;
});*/
}