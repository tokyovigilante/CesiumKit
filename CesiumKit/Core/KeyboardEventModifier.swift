//
//  KeyboardEventModifier.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/03/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//


/**
* This enumerated type is for representing keyboard modifiers. These are keys
* that are held down in addition to other event types.
*
* @namespace
* @alias KeyboardEventModifier
*/
public enum KeyboardEventModifier: Int  {
    /**
    * Represents the shift key being held down.
    *
    * @type {Number}
    * @constant
    */
    case shift = 0,
    
    /**
    * Represents the control key being held down.
    *
    * @type {Number}
    * @constant
    */
    ctrl,
    
    /**
    * Represents the alt key being held down.
    *
    * @type {Number}
    * @constant
    */
    alt
}
