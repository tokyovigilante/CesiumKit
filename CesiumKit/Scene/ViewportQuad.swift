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
    var rectangle: BoundingRectangle
    
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
    
    private var _material: Material? = nil
    
    private var _overlayCommand: DrawCommand? = nil
    
    private var _rs: RenderState? = nil
    
    public init (rectangle: BoundingRectangle = BoundingRectangle(), material: Material = Material(fromType: .Color(ColorFabricDescription(color: Color(1.0, 1.0, 1.0, 1.0)))))
    {
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
    func update (frameState: FrameState) {
        if !show {
            return
        }
        
    var rs = _rs
    /*if rs == nil || !BoundingRectangle.equals(rs.viewport, this.rectangle)) {
    this._rs = RenderState.fromCache({
    blending : BlendingState.ALPHA_BLEND,
    viewport : this.rectangle
    });
    }
    
    var pass = frameState.passes;
    if (pass.render) {
    if (this._material !== this.material || !defined(this._overlayCommand)) {
    // Recompile shader when material changes
    this._material = this.material;
    
    if (defined(this._overlayCommand)) {
    this._overlayCommand.shaderProgram.destroy();
    }
    
    var fs = new ShaderSource({
    sources : [this._material.shaderSource, ViewportQuadFS]
    });
    this._overlayCommand = context.createViewportQuadCommand(fs, {
    renderState : this._rs,
    uniformMap : this._material._uniforms,
    owner : this
    });
    this._overlayCommand.pass = Pass.OVERLAY;
    }
    
    this._material.update(context);
    
    this._overlayCommand.uniformMap = this._material._uniforms;
    commandList.push(this._overlayCommand);
    }
    };
    
    /**
    * Returns true if this object was destroyed; otherwise, false.
    * <br /><br />
    * If this object was destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
    *
    * @returns {Boolean} True if this object was destroyed; otherwise, false.
    *
    * @see ViewportQuad#destroy
    */
    ViewportQuad.prototype.isDestroyed = function() {
    return false;*/
    }
    
}

struct ViewportQuadOverrides {
    
    var renderState: RenderState? = nil
    
    var uniformMap: UniformMap? = nil

    var framebuffer: Framebuffer? = nil
    
    var owner: AnyObject? = nil
}


