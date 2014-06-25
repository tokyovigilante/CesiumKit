//
//  Ray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Represents a ray that extends infinitely from the provided origin in the provided direction.
* @alias Ray
* @constructor
*
* @param {Cartesian3} [origin=Cartesian3.ZERO] The origin of the ray.
* @param {Cartesian3} [direction=Cartesian3.ZERO] The direction of the ray.
*/

struct Ray {
    /**
    * The origin of the ray.
    * @type {Cartesian3}
    * @default {@link Cartesian3.ZERO}
    */
    var origin: Cartesian3
    
    /**
    * The direction of the ray.
    * @type {Cartesian3}
    */
    var direction: Cartesian3
    
    init(origin: Cartesian3 = Cartesian3.zero(), direction: Cartesian3 = Cartesian3.zero()) {
        
        if direction == Cartesian3.zero() {
            self.direction = direction.normalize()
        }
        else {
            self.direction = direction
        }
        self.origin = origin
    }
    
    /**
    * Computes the point along the ray given by r(t) = o + t*d,
    * where o is the origin of the ray and d is the direction.
    *
    * @param {Number} t A scalar value.
    * @param {Cartesian3} [result] The object in which the result will be stored.
    * @returns The modified result parameter, or a new instance if none was provided.
    *
    * @example
    * //Get the first intersection point of a ray and an ellipsoid.
    * var intersection = Cesium.IntersectionTests.rayEllipsoid(ray, ellipsoid);
    * var point = Ray.getPoint(ray, intersection.start);
    */
    func getPoint(t: Double) -> Cartesian3 {
        return direction.multiplyByScalar(t).add(origin)
    }
    
}