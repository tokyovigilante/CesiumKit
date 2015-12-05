//
//  GlobeDepth.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

class GlobeDepth {

    private var _colorTextureProvider: TextureProvider! = nil
    private var _depthStencilTextureProvider: TextureProvider! = nil
    private var _globeDepthTextureProvider: TextureProvider! = nil

    let framebuffer = Framebuffer(maximumColorAttachments: 1)
    private let _copyDepthFramebuffer = Framebuffer(maximumColorAttachments: 0)
    
    private var _clearColorCommand: ClearCommand
    private var _copyColorCommand: ClearCommand? = nil
    private var _copyDepthCommand: ClearCommand? = nil
    
    init () {
        _clearColorCommand = ClearCommand(
            color: Cartesian4(fromRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
            stencil: 0
        )
        _clearColorCommand.owner = self
        
    }

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

    func createTextures(context: Context, width: Int, height: Int) {
        _colorTextureProvider = TextureProvider(context: context, capacity: 3, options: TextureOptions(
            width : width,
            height : height,
            pixelFormat: .BGRA8Unorm)
        )
        
        _depthStencilTextureProvider = TextureProvider(context: context, capacity: 3, options: TextureOptions(
            width : width,
            height : height,
            pixelFormat : .Depth32Float_Stencil8)
        )
        
        _globeDepthTextureProvider = TextureProvider(context: context, capacity: 3, options: TextureOptions(
            width : width,
            height : height,
            pixelFormat : .RGBA8Unorm)
        )
    }

    func updateFramebuffers(context: Context) {
        let width = Int(context.width)
        let height = Int(context.height)
        
        let textureChanged = _colorTextureProvider == nil || _colorTextureProvider.width != width || _colorTextureProvider.height != height
        if textureChanged {
            destroyTextures()
            createTextures(context, width: width, height: height)
        }
        assert(_colorTextureProvider != nil, "_colorTextureProvider == nil")
        assert(_depthStencilTextureProvider != nil, "_depthStencilTextureProvider == nil")
        assert(_globeDepthTextureProvider != nil, "_globeDepthTextureProvider == nil")

        let depthStencilTexture = _depthStencilTextureProvider.nextTexture()
        framebuffer.update(
            colorTextures: [_colorTextureProvider.nextTexture()],
            depthTexture: depthStencilTexture,
            stencilTexture: depthStencilTexture)
        _copyDepthFramebuffer.update(
            colorTextures: [_globeDepthTextureProvider.nextTexture()],
            depthTexture: nil,
            stencilTexture: nil)
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

globeDepth._clearColorCommand.framebuffer = globeDepth.framebuffer;
}

GlobeDepth.prototype.executeDebugGlobeDepth = function(context, passState) {
executeDebugGlobeDepth(this, context, passState);
};*/

    func update (context: Context) {

        updateFramebuffers(context)
        //updateCopyCommands(this, context);
    }

    func executeCopyDepth (context: Context, passState: PassState) {
        /*if (defined(this._copyDepthCommand)) {
            this._copyDepthCommand.execute(context, passState);
            context.uniformState.globeDepthTexture = this._globeDepthTexture;
        }*/
    }


    func executeCopyColor (context: Context, passState: PassState) {
        // FIXME create abstract blit class
        let origin = MTLOriginMake(0, 0, 0)
        let size = MTLSizeMake(_colorTextureProvider.width, _colorTextureProvider.height, 1)
        let blitEncoder = context.createBlitCommandEncoder()
        blitEncoder.copyFromTexture(framebuffer.colorTextures![0].metalTexture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: origin,
            sourceSize: size,
            toTexture: passState.framebuffer.colorTextures![0].metalTexture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: origin)
        context.completeBlitPass(blitEncoder)
    }
    
    func clear (context: Context, passState: PassState, clearColor: Cartesian4) {
        _clearColorCommand.color = clearColor
        _clearColorCommand.execute(context, passState: passState)
    }
    
}