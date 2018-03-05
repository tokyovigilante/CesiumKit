//
//  CameraEventType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/03/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

/**
* Enumerates the available input for interacting with the camera.
*
* @namespace
* @alias CameraEventType
*/
enum CameraEventType: Int {
    /**
    * A left mouse button press followed by moving the mouse and releasing the button.
    *
    * @type {Number}
    * @constant
    */
    case leftDrag = 0,

    /**
    *  A right mouse button press followed by moving the mouse and releasing the button.
    *
    * @type {Number}
    * @constant
    */
    rightDrag,

    /**
    *  A middle mouse button press followed by moving the mouse and releasing the button.
    *
    * @type {Number}
    * @constant
    */
    middleDrag,

    /**
    * Scrolling the middle mouse button.
    *
    * @type {Number}
    * @constant
    */
    wheel,

    /**
    * A possibly (multi)-finger drag on a touch surface
    *
    * @type {Number}
    * @constant
    */
    pan,

    /**
    * A two-finger touch on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    pinch,

    count
}
