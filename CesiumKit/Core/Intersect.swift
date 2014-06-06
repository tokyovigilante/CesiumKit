//
//  Intersect.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* This enumerated type is used in determining where, relative to the frustum, an
* object is located. The object can either be fully contained within the frustum (INSIDE),
* partially inside the frustum and partially outside (INTERSECTING), or somwhere entirely
* outside of the frustum's 6 planes (OUTSIDE).
*
* @exports Intersect
*/
enum Intersect: Int {
    case
    /**
    * Represents that an object is not contained within the frustum.
    *
    * @type {Number}
    * @constant
    */
    Outside = -1,
    /**
    * Represents that an object intersects one of the frustum's planes.
    *
    * @type {Number}
    * @constant
    */
    Intersecting,
    /**
    * Represents that an object is fully within the frustum.
    *
    * @type {Number}
    * @constant
    */
    Inside
}

