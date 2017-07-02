//
//  OffscreenQuadPrimitive
//  CesiumKit
//
//  Created by Ryan Walklin on 12/03/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/** A render-to-texture primitive allowing multiple draw commands.
 Most useful for creating HUDs and other UI.
 */
open class OffscreenQuadPrimitive: Primitive {
    
    let height, width: Int
    
    fileprivate weak var _context: Context!
    
    fileprivate var _text = [TextRenderer]()
    
    fileprivate var _textCommands = [DrawCommand]()
    
    fileprivate var _rectangles = [DrawCommand]()
    
    fileprivate let _passState: PassState
    
    fileprivate let _clearCommand = ClearCommand(
        color: Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    )
    
    init (context: Context, width: Int, height: Int) {
        _context = context
        self.width = width
        self.height = height
        
        let options = TextureOptions(
            width: width,
            height: height,
            premultiplyAlpha: false,
            usage: [.ShaderRead, .RenderTarget])
        
        let texture = Texture(context: context, options: options)
        
        let framebuffer = Framebuffer(
            maximumColorAttachments: context.limits.maximumColorAttachments,
            colorTextures: [texture]
        )
        _passState = PassState()
        _passState.context = context
        _passState.framebuffer = framebuffer
    }
    
    open func addString (_ string: String, fontName: String, color: Color, pointSize: Int, rectangle: Cartesian4) -> Int {
        let text = TextRenderer(string: string, fontName: fontName, color: color, pointSize: pointSize, viewportRect: rectangle, offscreenTarget: true)
        _text.append(text)
        return _text.count-1
    }

    open func updateString (_ index: Int, newText: String) {
        
    }
    
    open func addRectangle (_ bounds: Cartesian4, material: Material) -> Int {
        
        let rs = RenderState(
            device: _context.device,
            viewport : bounds
        )
        
        let overrides = ViewportQuadOverrides(
            renderState: rs,
            uniformMap: material.uniformMap,
            owner: self
        )
        let fs = ShaderSource(
            sources: [material.shaderSource, Shaders["ViewportQuadFS"]].flatMap { $0 }
        )
        let command = _context.createViewportQuadCommand(
            fragmentShaderSource: fs,
            overrides: overrides,
            depthStencil: false,
            blendingState: nil)
        
        _rectangles.append(command)
        
        return _rectangles.count-1
    }

    
    override func update (_ frameState: inout FrameState) {
        
        _textCommands.removeAll()
        
        for text in _text {
            text.update(&frameState)
        }
    }
    
    /**
     * Executes the draw command.
     *
     * @param {Context} context The renderer context in which to draw.
     * @param {RenderPass} [renderPass] The render pass this command is part of.
     * @param {RenderState} [renderState] The render state that will override the render state of the command.
     * @param {RenderPipeline} [renderPipeline] The render pipeline that will override the shader program of the command.
     */
    func execute(_ context: Context) {
        
        guard let renderPass = context.createRenderPass(_passState) else {
            return
        }
        _clearCommand.execute(context, passState: _passState)
        for command in _rectangles {
            command.execute(context, renderPass: renderPass)
        }
        
        for command in _textCommands {
            command.execute(context, renderPass: renderPass)
        }
        renderPass.complete()
    }
    
}
