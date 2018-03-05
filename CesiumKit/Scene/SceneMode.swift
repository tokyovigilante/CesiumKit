//
//  SceneMode.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Indicates if the scene is viewed in 3D, 2D, or 2.5D Columbus view.
*
* @exports SceneMode
*
* @see Scene#mode
*/
public enum SceneMode: Int {
    /**
    * 2D mode.  The map is viewed top-down with an orthographic projection.
    *
    * @type {Number}
    * @constant
    */
    case scene2D,

    /**
    * Columbus View mode.  A 2.5D perspective view where the map is laid out
    * flat and objects with non-zero height are drawn above it.
    *
    * @type {Number}
    * @constant
    */
    columbusView,

    /**
    * 3D mode.  A traditional 3D perspective view of the globe.
    *
    * @type {Number}
    * @constant
    */
    scene3D,

    /**
    * Morphing between mode, e.g., 3D to 2D.
    *
    * @type {Number}
    * @constant
    */
    morphing

    /**
    * Returns the morph time for the given scene mode
    * @param {SceneMode} value The scene mode
    * @returns {Number} The morph time
    */
    var morphTime: Double? {
        switch self {
        case .scene3D:
            return 1.0
        case .morphing:
            return nil
        default:
            return 0.0
        }

    }

}

