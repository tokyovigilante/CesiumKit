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
    
    private var _fbo: Framebuffer? = nil
    private var _command: DrawCommand? = nil
    
    private var _clearCommand: ClearCommand
    
    init () {
        _clearCommand = ClearCommand(
            color : Cartesian4(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
            depth : 1.0
        )
        _clearCommand.owner = self
    }

    func update (context: Context) {
        let width = context.width
        let height = context.height
        
        let textureChanged = _texture == nil || _texture!.width != width || _texture!.height != height
        if textureChanged {
            _depthTexture = nil
            
            _texture = Texture(
                context: context,
                options: TextureOptions(
                    width: width,
                    height: height,
                    usage: [.ShaderRead, .RenderTarget])
                )
            
            if context.depthTexture {
                _depthTexture = Texture(
                    context: context,
                    options: TextureOptions(
                    width: width,
                    height: height,
                    pixelFormat: .Depth32FloatStencil8,
                    usage: .RenderTarget)
                )
            }
        }
        
        if _fbo == nil || textureChanged {
            
            _fbo = Framebuffer(
                maximumColorAttachments: 1,
                colorTextures : [_texture!],
                depthTexture : _depthTexture
            )
        }
        
        if _command == nil {
            var overrides = ViewportQuadOverrides()
            overrides.renderState =  RenderState(device: context.device)
            overrides.owner = self
            _command = context.createViewportQuadCommand(
                fragmentShaderSource: ShaderSource(sources: [Shaders["FXAAFS"]!]),
                overrides: overrides
            )
        }
        
        if textureChanged {
            let uniformMap = FXAAUniformMap()
            uniformMap.texture = _texture
            uniformMap.step = Cartesian2(x: 1.0 / Double(_texture!.width), y: 1.0 / Double(_texture!.height))
            uniformMap.uniformBufferProvider = _command!.pipeline!.shaderProgram.createUniformBufferProvider(context.device, deallocationBlock: nil)
            _command!.uniformMap = uniformMap
        }
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

private struct FXAAUniformStruct: UniformStruct {
    var step = float2()
}

class FXAAUniformMap: NativeUniformMap {
    
    var step: Cartesian2 {
        get {
            return Cartesian2(simd: vector_double(_uniformStruct.step))
        }
        set {
            _uniformStruct.step = newValue.floatRepresentation
        }
    }
    
    var texture : Texture?
    
    var uniformBufferProvider: UniformBufferProvider! = nil
    
    private var _uniformStruct = FXAAUniformStruct()
    
    var uniformDescriptors: [UniformDescriptor] = [
        UniformDescriptor(name: "u_step", type: .FloatVec2, count: 1)
    ]
    
    private (set) var uniformUpdateBlock: UniformUpdateBlock! = nil
    
    init () {
        uniformUpdateBlock = { buffer in
            memcpy(buffer.data, &self._uniformStruct, sizeof(FXAAUniformStruct))
            return [self.texture!]
        }
    }
}

