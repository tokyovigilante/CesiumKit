//
//  HeightReference.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 12/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Represents the position relative to the terrain.
 *
 * @namespace
 * @alias HeightReference
 */
enum HeightReference {
    
    /**
    * The position is absolute.
    * @type {Number}
    * @constant
    */
    case none
    
    /**
    * The position is clamped to the terrain.
    * @type {Number}
    * @constant
    */
    case clampToGround
    
    /**
    * The position height is the height above the terrain.
    * @type {Number}
    * @constant
    */
    case relativeToGround
    
}
