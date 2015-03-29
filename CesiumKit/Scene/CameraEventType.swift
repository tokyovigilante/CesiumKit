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
    case LeftDrag = 0,
    
    /**
    *  A right mouse button press followed by moving the mouse and releasing the button.
    *
    * @type {Number}
    * @constant
    */
    RightDrag,
    
    /**
    *  A middle mouse button press followed by moving the mouse and releasing the button.
    *
    * @type {Number}
    * @constant
    */
    MiddleDrag,
    
    /**
    * Scrolling the middle mouse button.
    *
    * @type {Number}
    * @constant
    */
    Wheel,
    
    /**
    * A two-finger touch on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    Pinch,
    
    COUNT
}
