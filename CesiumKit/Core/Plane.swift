//
//  Plane.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 4/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
* A plane in Hessian Normal Form defined by
* <pre>
* ax + by + cz + d = 0
* </pre>
* where (a, b, c) is the plane's <code>normal</code>, d is the signed
* <code>distance</code> to the plane, and (x, y, z) is any point on
* the plane.
*
* @alias Plane
* @constructor
*
* @param {Cartesian3} normal The plane's normal (normalized).
* @param {Number} distance The shortest distance from the origin to the plane.  The sign of
* <code>distance</code> determines which side of the plane the origin
* is on.  If <code>distance</code> is positive, the origin is in the half-space
* in the direction of the normal; if negative, the origin is in the half-space
* opposite to the normal; if zero, the plane passes through the origin.
*
* @example
* // The plane x=0
* var plane = new Cesium.Plane(Cesium.Cartesian3.UNIT_X, 0.0);
*/
struct Plane {

    /**
    * The plane's normal.
    *
    * @type {Cartesian3}
    */
    let normal: Cartesian3

    /**
    * The shortest distance from the origin to the plane.  The sign of
    * <code>distance</code> determines which side of the plane the origin
    * is on.  If <code>distance</code> is positive, the origin is in the half-space
    * in the direction of the normal; if negative, the origin is in the half-space
    * opposite to the normal; if zero, the plane passes through the origin.
    *
    * @type {Number}
    */
    let distance: Double

    init(normal: Cartesian3, distance: Double) {
        self.normal = normal
        self.distance = distance
    }

    /**
    * Creates a plane from a normal and a point on the plane.
    *
    * @param {Cartesian3} point The point on the plane.
    * @param {Cartesian3} normal The plane's normal (normalized).
    * @param {Plane} [result] The object onto which to store the result.
    * @returns {Plane} A new plane instance or the modified result parameter.
    *
    * @example
    * var point = Cesium.Cartesian3.fromDegrees(-72.0, 40.0);
    * var normal = ellipsoid.geodeticSurfaceNormal(point);
    * var tangentPlane = Cesium.Plane.fromPointNormal(point, normal);
    */
    init (fromPoint point: Cartesian3, normal: Cartesian3) {

        let distance = -normal.dot(point)
        self = Plane(normal: normal, distance: distance)
    }

    /**
    * Creates a plane from the general equation
    *
    * @param {Cartesian4} coefficients The plane's normal (normalized).
    * @param {Plane} [result] The object onto which to store the result.
    * @returns {Plane} A new plane instance or the modified result parameter.
    */
    init (fromCartesian4 coefficients: Cartesian4) {
        normal = Cartesian3(cartesian4: coefficients)
        distance = coefficients.w
    }


    /**
    * Computes the signed shortest distance of a point to a plane.
    * The sign of the distance determines which side of the plane the point
    * is on.  If the distance is positive, the point is in the half-space
    * in the direction of the normal; if negative, the point is in the half-space
    * opposite to the normal; if zero, the plane passes through the point.
    *
    * @param {Plane} plane The plane.
    * @param {Cartesian3} point The point.
    * @returns {Number} The signed shortest distance of the point to the plane.
    */
    func getPointDistance (_ point: Cartesian3) -> Double {
        return normal.dot(point) + distance
    }

    /*
    /**
    * A constant initialized to the XY plane passing through the origin, with normal in positive Z.
    *
    * @type {Plane}
    * @constant
    */
    Plane.ORIGIN_XY_PLANE = freezeObject(new Plane(Cartesian3.UNIT_Z, 0.0));

    /**
    * A constant initialized to the YZ plane passing through the origin, with normal in positive X.
    *
    * @type {Plane}
    * @constant
    */
    Plane.ORIGIN_YZ_PLANE = freezeObject(new Plane(Cartesian3.UNIT_X, 0.0));

    /**
    * A constant initialized to the ZX plane passing through the origin, with normal in positive Y.
    *
    * @type {Plane}
    * @constant
    */
    Plane.ORIGIN_ZX_PLANE = freezeObject(new Plane(Cartesian3.UNIT_Y, 0.0));*/

}
