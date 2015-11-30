//
//  ScreenSpaceEventType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/03/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

/**
* This enumerated type is for classifying mouse events: down, up, click, double click, move and move while a button is held down.
*
* @namespace
* @alias ScreenSpaceEventType
*/
enum ScreenSpaceEventType: Int {
    /**
    * Represents a mouse left button down event.
    *
    * @type {Number}
    * @constant
    */
    case LeftDown = 0,
    
    /**
    * Represents a mouse left button up event.
    *
    * @type {Number}
    * @constant
    */
    LeftUp,
    
    /**
    * Represents a mouse left click event.
    *
    * @type {Number}
    * @constant
    */
    LeftClick,
    
    /**
    * Represents a mouse left double click event.
    *
    * @type {Number}
    * @constant
    */
    LeftDoubleClick,
    
    /**
    * Represents a mouse left button down event.
    *
    * @type {Number}
    * @constant
    */
    RightDown,
    
    /**
    * Represents a mouse right button up event.
    *
    * @type {Number}
    * @constant
    */
    RightUp,
    
    /**
    * Represents a mouse right click event.
    *
    * @type {Number}
    * @constant
    */
    RightClick,
    
    /**
    * Represents a mouse right double click event.
    *
    * @type {Number}
    * @constant
    */
    RightDoubleClick,
    
    /**
    * Represents a mouse middle button down event.
    *
    * @type {Number}
    * @constant
    */
    MiddleDown,
    
    /**
    * Represents a mouse middle button up event.
    *
    * @type {Number}
    * @constant
    */
    MiddleUp,
    
    /**
    * Represents a mouse middle click event.
    *
    * @type {Number}
    * @constant
    */
    MiddleClick,
    
    /**
    * Represents a mouse middle double click event.
    *
    * @type {Number}
    * @constant
    */
    MiddleDoubleClick,
    
    /**
    * Represents a mouse move event.
    *
    * @type {Number}
    * @constant
    */
    MouseMove,
    
    /**
    * Represents a mouse wheel event.
    *
    * @type {Number}
    * @constant
    */
    Wheel,
    
    /**
    * Represents the start of a two-finger event on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    PinchStart,
    
    /**
    * Represents the end of a two-finger event on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    PinchEnd,
    
    /**
    * Represents a change of a two-finger event on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    PinchMove
}
