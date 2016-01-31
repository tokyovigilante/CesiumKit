//
//  VerticalOrigin.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation


/**
 * The vertical location of an origin relative to an object, e.g., a {@link Billboard}.
 * For example, the vertical origin is used to display a billboard above or below (in
 * screen space) of the actual position.
 *
 * @namespace
 * @alias VerticalOrigin
 *
 * @see Billboard#verticalOrigin
 */
public enum VerticalOrigin {
    /**
     * The origin is at the vertical center of the object.
     *
     * @type {Number}
     * @constant
     */
    case Center
    
    /**
     * The origin is at the bottom of the object.
     *
     * @type {Number}
     * @constant
     */
    case Bottom
    
    /**
     * The origin is at the top of the object.
     *
     * @type {Number}
     * @constant
     */
    case Top
}