//
//  CullingVolume.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* The culling volume defined by planes.
*
* @alias CullingVolume
* @constructor
*
* @param {Cartesian4[]} planes An array of clipping planes.
*/
struct CullingVolume {
    /**
    * Each plane is represented by a Cartesian4 object, where the x, y, and z components
    * define the unit vector normal to the plane, and the w component is the distance of the
    * plane from the origin.
    * @type {Cartesian4[]}
    * @default []
    */
    var planes = [Cartesian4]()
    
    /**
    * Determines whether a bounding volume intersects the culling volume.
    * @memberof CullingVolume
    *
    * @param {Object} boundingVolume The bounding volume whose intersection with the culling volume is to be tested.
    * @returns {Intersect}  Intersect.OUTSIDE, Intersect.INTERSECTING, or Intersect.INSIDE.
    */
    func visibility(boundingVolume: Intersectable) -> Intersect {
        var intersecting = false
        
        for plane in planes {
            var result = boundingVolume.intersect(plane)
            if result == .Outside {
                return result
            } else if result == .Intersecting {
                intersecting = true
            }
        }
        return intersecting ? Intersect.Intersecting : Intersect.Inside
    }
}