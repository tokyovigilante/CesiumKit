//
//  Visibility.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* This enumerated type is used in determining to what extent an object, the occludee,
* is visible during horizon culling. An occluder may fully block an occludee, in which case
* it has no visibility, may partially block an occludee from view, or may not block it at all,
* leading to full visibility.
*
* @exports Visibility
*/
enum Visibility: Int {
    /**
    * Represents that no part of an object is visible.
    *
    * @type {Number}
    * @constant
    */
    case None = -1,
    
    /**
    * Represents that part, but not all, of an object is visible
    *
    * @type {Number}
    * @constant
    */
    Partial,
    
    /**
    * Represents that an object is visible in its entirety.
    *
    * @type {Number}
    * @constant
    */
    Full
}