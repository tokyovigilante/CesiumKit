//
//  HorizontalOrigin.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * The horizontal location of an origin relative to an object, e.g., a {@link Billboard}.
 * For example, the horizontal origin is used to display a billboard to the left or right (in
 * screen space) of the actual position.
 *
 * @namespace
 * @alias HorizontalOrigin
 *
 * @see Billboard#horizontalOrigin
 */

public enum HorizontalOrigin {
    /**
     * The origin is at the horizontal center of the object.
     *
     * @type {Number}
     * @constant
     */
    case Center
    
    /**
     * The origin is on the left side of the object.
     *
     * @type {Number}
     * @constant
     */
    case Left
    /**
     * The origin is on the right side of the object.
     *
     * @type {Number}
     * @constant
     */
    case Right
}
