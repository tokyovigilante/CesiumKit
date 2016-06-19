//
//  ViewportQuad.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
* A viewport aligned quad.
*
* @alias ViewportQuad
* @constructor
*
* @param {BoundingRectangle} [rectangle] The {@link BoundingRectangle} defining the quad's position within the viewport.
* @param {Material} [material] The {@link Material} defining the surface appearance of the viewport quad.
*
* @example
* var viewportQuad = new Cesium.ViewportQuad(new Cesium.BoundingRectangle(0, 0, 80, 40));
* viewportQuad.material.uniforms.color = new Cesium.Color(1.0, 0.0, 0.0, 1.0);
*/
public class ViewportQuad: Primitive {
        
    /**
     * The BoundingRectangle defining the quad's position within the viewport.
     *
     * @type {BoundingRectangle}
     *
     * @example
     * viewportQuad.rectangle = new Cesium.BoundingRectangle(0, 0, 80, 40);
     */
    public var rectangle: Cartesian4
    
    /**
     * The surface appearance of the viewport quad.  This can be one of several built-in {@link Material} objects or a custom material, scripted with
     * {@link https://github.com/AnalyticalGraphicsInc/cesium/wiki/Fabric|Fabric}.
     * <p>
     * The default material is <code>Material.ColorType</code>.
     * </p>
     *
     * @type Material
     *
     * @example
     * // 1. Change the color of the default material to yellow
     * viewportQuad.material.uniforms.color = new Cesium.Color(1.0, 1.0, 0.0, 1.0);
     *
     * // 2. Change material to horizontal stripes
     * viewportQuad.material = Cesium.Material.fromType(Cesium.Material.StripeType);
     *
     * @see {@link https://github.com/AnalyticalGraphicsInc/cesium/wiki/Fabric|Fabric}
     */
    var material: Material
    
    private var _material: Material! = nil
    
    private var _overlayCommand: DrawCommand! = nil
    
    private var _rs: RenderState! = nil
    
    public init (rectangle: Cartesian4, material: Material = Material(fromType: ColorMaterialType(fabric: ColorFabricDescription(), source: nil))) {
        self.rectangle = rectangle
        self.material = material
    }
    
    /**
    * Called when {@link Viewer} or {@link CesiumWidget} render the scene to
    * get the draw commands needed to render this primitive.
    * <p>
    * Do not call this function directly.  This is documented just to
    * list the exceptions that may be propagated when the scene is rendered:
    * </p>
    *
    * @exception {DeveloperError} this.material must be defined.
    * @exception {DeveloperError} this.rectangle must be defined.
    */
    override func update (_ frameState: inout FrameState) {
        if !show {
            return
        }
        guard let context = frameState.context else {
            return
        }

        if _rs == nil || _rs.viewport! != rectangle {
            _rs = RenderState(
                device: context.device,
                viewport : rectangle
            )
            if let overlayCommand = _overlayCommand {
                overlayCommand.renderState = _rs
            }
        }
        
        if !frameState.passes.render {
            return
        }
        
        if _material !== material || _overlayCommand == nil {
            // Recompile shader when material changes
            _material = material
            
            let fs = ShaderSource(
                sources: [_material.shaderSource, Shaders["ViewportQuadFS"]].flatMap { $0 }
            )
            _overlayCommand = context.createViewportQuadCommand(
                fragmentShaderSource: fs,
                overrides: ViewportQuadOverrides(
                    renderState: _rs,
                    uniformMap: _material.uniformMap,
                    owner: self
                ),
                depthStencil: context.depthTexture,
                blendingState: BlendingState.AlphaBlend()
            )
            
            _overlayCommand.pass = .overlay
            
            if let map = _overlayCommand.uniformMap {
                map.uniformBufferProvider = _overlayCommand.pipeline!.shaderProgram.createUniformBufferProvider(context.device, deallocationBlock: nil)
            }
        }
        
        _material.update(context)
        
        _overlayCommand.uniformMap = _material.uniformMap
        
        frameState.commandList.append(_overlayCommand)
        
    }
    
}

struct ViewportQuadOverrides {
    
    var renderState: RenderState? = nil
    
    var uniformMap: UniformMap? = nil
    
    var owner: AnyObject? = nil
}


