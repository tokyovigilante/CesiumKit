//
//  FXAA.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import MetalKit

class FXAA {
    /**
    * @private
    */
    private var _texture: Texture? = nil
    private var _depthTexture: Texture? = nil
    //var _depthRenderbuffer = undefined;
    
    private var _fbo: Framebuffer? = nil
    private var _command: DrawCommand? = nil
    
    private var _clearCommand: ClearCommand
    
    init () {
        _clearCommand = ClearCommand(
            color : Cartesian4(fromRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
            depth : 1.0
        )
        _clearCommand.owner = self
    }

    func update (context: Context) {
        let width = context.width
        let height = context.height
        
        var fxaaTexture = _texture
        let textureChanged = _texture == nil || _texture!.width != width || _texture!.height != height
        if textureChanged {
            _depthTexture = nil
            //this._depthRenderbuffer = this._depthRenderbuffer && this._depthRenderbuffer.destroy();
            
            _texture = Texture(
                context: context,
                options: TextureOptions(
                    width: width,
                    height: height,
                    usage: .RenderTarget)
                )
            
            if context.depthTexture {
                _depthTexture = Texture(
                    context: context,
                    options: TextureOptions(
                    width: width,
                    height: height,
                    pixelFormat: .Depth32Float,
                    usage: .RenderTarget)
                )
            } /*else {
                this._depthRenderbuffer = new Renderbuffer({
                    context : context,
                    width : width,
                    height : height,
                    format : RenderbufferFormat.DEPTH_COMPONENT16
                });
            }*/
        }
        
        if _fbo == nil || textureChanged {
            /*
            _fbo = new Framebuffer({
                context : context,
                colorTextures : [this._texture],
                depthTexture : this._depthTexture,
                depthRenderbuffer : this._depthRenderbuffer,
                destroyAttachments : false
            });*/
        }
        /*
        if (!defined(this._command)) {
            this._command = context.createViewportQuadCommand(FXAAFS, {
                renderState : RenderState.fromCache(),
                owner : this
            });
        }*/
        /*
        if (textureChanged) {
            var that = this;
            var step = new Cartesian2(1.0 / this._texture.width, 1.0 / this._texture.height);
            this._command.uniformMap = {
                u_texture : function() {
                    return that._texture;
                },
                u_step : function() {
                    return step;
                }
            };
        }*/
    }

    func execute (context: Context, renderPass: RenderPass) {
        _command!.execute(context, renderPass: renderPass)
    }
    
    func clear (context: Context, passState: PassState, clearColor: Cartesian4) {
        let framebuffer = passState.framebuffer
        
        passState.framebuffer = _fbo
        _clearCommand.color = clearColor
        _clearCommand.execute(context, passState: passState)
        
        passState.framebuffer = framebuffer
    }
    
    
    func getColorFramebuffer() -> Framebuffer? {
        return _fbo
    }

}