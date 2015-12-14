//
//  QuadtreeOccluders.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* A set of occluders that can be used to test quadtree tiles for occlusion.
*
* @alias QuadtreeOccluders
* @constructor
* @private
*
* @param {Ellipsoid} [options.ellipsoid=Ellipsoid.WGS84] The ellipsoid that potentially occludes tiles.
*/
class QuadtreeOccluders {
    
    /**
    * Gets the {@link EllipsoidalOccluder} that can be used to determine if a point is
    * occluded by an {@link Ellipsoid}.
    * @type {EllipsoidalOccluder}
    * @memberof QuadtreeOccluders.prototype
    */
    let ellipsoid: EllipsoidalOccluder
    
    init(ellipsoid: Ellipsoid, cameraPosition: Cartesian3 = Cartesian3.zero) {
        self.ellipsoid = EllipsoidalOccluder(ellipsoid: ellipsoid, cameraPosition: cameraPosition)
    }
}
