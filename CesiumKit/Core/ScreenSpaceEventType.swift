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
    case leftDown = 0,
    
    /**
    * Represents a mouse left button up event.
    *
    * @type {Number}
    * @constant
    */
    leftUp,
    
    /**
    * Represents a mouse left click event.
    *
    * @type {Number}
    * @constant
    */
    leftClick,
    
    /**
    * Represents a mouse left double click event.
    *
    * @type {Number}
    * @constant
    */
    leftDoubleClick,
    
    /**
    * Represents a mouse left button down event.
    *
    * @type {Number}
    * @constant
    */
    rightDown,
    
    /**
    * Represents a mouse right button up event.
    *
    * @type {Number}
    * @constant
    */
    rightUp,
    
    /**
    * Represents a mouse right click event.
    *
    * @type {Number}
    * @constant
    */
    rightClick,
    
    /**
    * Represents a mouse right double click event.
    *
    * @type {Number}
    * @constant
    */
    rightDoubleClick,
    
    /**
    * Represents a mouse middle button down event.
    *
    * @type {Number}
    * @constant
    */
    middleDown,
    
    /**
    * Represents a mouse middle button up event.
    *
    * @type {Number}
    * @constant
    */
    middleUp,
    
    /**
    * Represents a mouse middle click event.
    *
    * @type {Number}
    * @constant
    */
    middleClick,
    
    /**
    * Represents a mouse middle double click event.
    *
    * @type {Number}
    * @constant
    */
    middleDoubleClick,
    
    /**
    * Represents a mouse move event.
    *
    * @type {Number}
    * @constant
    */
    mouseMove,
    
    /**
    * Represents a mouse wheel event.
    *
    * @type {Number}
    * @constant
    */
    wheel,
    
    /**
    * Represents the start of a two-finger event on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    pinchStart,
    
    /**
    * Represents the end of a two-finger event on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    pinchEnd,
    
    /**
    * Represents a change of a two-finger event on a touch surface.
    *
    * @type {Number}
    * @constant
    */
    pinchMove
}
