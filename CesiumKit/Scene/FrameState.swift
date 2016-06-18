//
//  FrameState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* State information about the current frame.  An instance of this class
* is provided to update functions.
*
* @param {CreditDisplay} creditDisplay Handles adding and removing credits from an HTML element
*
* @alias FrameState
* @constructor
*/
struct FrameState {
    
    /**
     * The rendering context.
     * @type {Context}
     */
    weak var context: Context!
    
    /**
    * The current mode of the scene.
    * @type {SceneMode}
    * @default {@link SceneMode.SCENE3D}
    */
    var mode = SceneMode.scene3D
    
    /**
    * An array of rendering commands.
    * @type {Command[]}
    */
    var commandList = [Command]()
    
    /**
    * The current morph transition time between 2D/Columbus View and 3D,
    * with 0.0 being 2D or Columbus View and 1.0 being 3D.
    *
    * @type {Number}
    */
    var morphTime: Double = SceneMode.scene3D.morphTime ?? 0.0
    
    /**
    * The current frame number.
    *
    * @type {Number}
    * @default 0
    */
    var frameNumber = 0
    
    /**
    * The scene's current time.
    *
    * @type {JulianDate}
    * @default undefined
    */
    var time: JulianDate! = nil
    
    /**
    * The map projection to use in 2D and Columbus View modes.
    *
    * @type {MapProjection}
    * @default undefined
    */
    var mapProjection: MapProjection = GeographicProjection()
    
    /**
    * The current camera.
    * @type {Camera}
    * @default undefined
    */
    var camera: Camera? = nil
    
    /**
    * The culling volume.
    * @type {CullingVolume}
    * @default undefined
    */
    var cullingVolume: CullingVolume? = nil
    
    /**
    * The current occluder.
    * @type {Occluder}
    * @default undefined
    */
    var occluder: Occluder? = nil

    struct Passes {
        /**
        * <code>true</code> if the primitive should update for a render pass, <code>false</code> otherwise.
        * @type {Boolean}
        * @default false
        */
        var render = false
        /**
        * <code>true</code> if the primitive should update for a picking pass, <code>false</code> otherwise.
        * @type {Boolean}
        * @default false
        */
        var pick = false
    }
    
    var passes: Passes = Passes()
    
    /**
    * The credit display.
    * @type {CreditDisplay}
    */
    var creditDisplay = CreditDisplay()
    
    /**
    * An array of functions to be called at the end of the frame.  This array
    * will be cleared after each frame.
    * <p>
    * This allows queueing up events in <code>update</code> functions and
    * firing them at a time when the subscribers are free to change the
    * scene state, e.g., manipulate the camera, instead of firing events
    * directly in <code>update</code> functions.
    * </p>
    *
    * @type {Function[]}
    *
    * @example
    * frameState.afterRender.push(function() {
    *   // take some action, raise an event, etc.
    * });
    */
    var afterRender: Array<() -> ()> = Array<() -> ()>()
    
    
    /**
    * Gets whether or not to optimized for 3D only.
    * @type {Boolean}
    * @default false
    */
    var scene3DOnly = false
    
    var fog: (enabled: Bool, density: Double, sse: Double) = (
        /**
        * <code>true</code> if fog is enabled, <code>false</code> otherwise.
        * @type {Boolean}
        * @default false
        */
        false,
        /**
        * A positive number used to mix the color and fog color based on camera distance.
        * @type {Number}
        * @default undefined
        */
        Double.nan,
        /**
        * A scalar used to modify the screen space error of geometry partially in fog.
        * @type {Number}
        * @default undefined
        */
        Double.nan
    )
    
    /**
    * A scalar used to exaggerate the terrain.
    * @type {Number}
    */
    var terrainExaggeration = 1.0

}


