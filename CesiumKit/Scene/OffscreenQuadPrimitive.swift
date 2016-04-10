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
public class OffscreenQuadPrimitive: Primitive {
    
    let height, width: Int
    
    private weak var _context: Context!
    
    private var _text = [TextRenderer]()
    
    private var _textCommands = [DrawCommand]()
    
    private var _rectangles = [DrawCommand]()
    
    private let _passState: PassState
    
    private let _clearCommand = ClearCommand(
        color: Color(fromRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
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
    
    public func addString (string: String, fontName: String, color: Color, pointSize: Int, rectangle: Cartesian4) -> Int {
        let text = TextRenderer(context: _context, string: string, fontName: fontName, color: color, pointSize: pointSize, rectangle: rectangle, offscreenTarget: true)
        _text.append(text)
        return _text.count-1
    }

    public func updateString (index: Int, newText: String) {
        
    }
    
    public func addRectangle (bounds: Cartesian4, material: Material) -> Int {
        
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

    
    override func update (inout frameState: FrameState) {
        
        _textCommands.removeAll()
        
        _textCommands = _text.flatMap { $0.update(frameState) }
    }
    
    /**
     * Executes the draw command.
     *
     * @param {Context} context The renderer context in which to draw.
     * @param {RenderPass} [renderPass] The render pass this command is part of.
     * @param {RenderState} [renderState] The render state that will override the render state of the command.
     * @param {RenderPipeline} [renderPipeline] The render pipeline that will override the shader program of the command.
     */
    func execute(context: Context) {
        
        let renderPass = context.createRenderPass(_passState)
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
