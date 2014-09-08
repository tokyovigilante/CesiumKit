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
    * The current mode of the scene.
    * @type {SceneMode}
    * @default {@link SceneMode.SCENE3D}
    */
    var mode = SceneMode.Scene3D
    
    /**
    * The current morph transition time between 2D/Columbus View and 3D,
    * with 0.0 being 2D or Columbus View and 1.0 being 3D.
    *
    * @type {Number}
    */
    var morphTime: Double = SceneMode.Scene3D.morphTime()!
    
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
    var time: JulianDate? = nil
    
    /**
    * The map projection to use in 2D and Columbus View modes.
    *
    * @type {MapProjection}
    * @default undefined
    */
    var projection: Projection? = nil
    
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
    //this.creditDisplay = creditDisplay;
    
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
}


