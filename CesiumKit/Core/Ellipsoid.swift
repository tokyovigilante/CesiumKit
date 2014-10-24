//
//  Ellipsoid.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A quadratic surface defined in Cartesian coordinates by the equation
* <code>(x / a)^2 + (y / b)^2 + (z / c)^2 = 1</code>.  Primarily used
* by Cesium to represent the shape of planetary bodies.
*
* Rather than constructing this object directly, one of the provided
* constants is normally used.
* @alias Ellipsoid
* @constructor
* @immutable
*
* @param {Number} [x=0] The radius in the x direction.
* @param {Number} [y=0] The radius in the y direction.
* @param {Number} [z=0] The radius in the z direction.
*
* @exception {DeveloperError} All radii components must be greater than or equal to zero.
*
* @see Ellipsoid.fromCartesian3
* @see Ellipsoid.WGS84
* @see Ellipsoid.UNIT_SPHERE
*/

let EarthEquatorialRadius: Double = 6378137.0
let EarthPolarRadius: Double = 6356752.3142451793

public struct Ellipsoid {
    let x: Double = 0.0
    let y: Double = 0.0
    let z: Double = 0.0
    
    let radii: Cartesian3
    let radiiSquared: Cartesian3
    let radiiToTheFourth: Cartesian3
    let oneOverRadii: Cartesian3
    let oneOverRadiiSquared: Cartesian3
    
    let minimumRadius: Double
    let maximumRadius: Double
    let centerToleranceSquared: Double = Math.Epsilon1
    
    init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) {
        assert(x >= 0.0 && y >= 0.0 && z >= 0.0, "All radii components must be greater than or equal to zero.")
        
        radii = Cartesian3(x: x, y: y, z: z);
        radiiSquared = radii.multiplyComponents(radii)
        radiiToTheFourth = radiiSquared.multiplyComponents(radiiSquared)
        oneOverRadii = Cartesian3(
            x: x == 0 ? 0.0 : 1.0 / x,
            y: y == 0 ? 0.0 : 1.0 / y,
            z: z == 0 ? 0.0 : 1.0 / z)
        oneOverRadiiSquared = Cartesian3(
            x: x == 0 ? 0.0 : 1.0 / (x * x),
            y: y == 0 ? 0.0 : 1.0 / (y * y),
            z: z == 0 ? 0.0 : 1.0 / (z * z))
        
        
        minimumRadius = min(x, y, z)
        maximumRadius = max(x, y, z)
    }
    
    /**
    * Computes an Ellipsoid from a Cartesian specifying the radii in x, y, and z directions.
    *
    * @param {Cartesian3} [radii=Cartesian3.ZERO] The ellipsoid's radius in the x, y, and z directions.
    * @returns {Ellipsoid} A new Ellipsoid instance.
    *
    * @exception {DeveloperError} All radii components must be greater than or equal to zero.
    *
    * @see Ellipsoid.WGS84
    * @see Ellipsoid.UNIT_SPHERE
    */
    static func fromCartesian3(cartesian: Cartesian3?) -> Ellipsoid {
        
        if let actualCartesian = cartesian {
            return Ellipsoid(x: actualCartesian.x, y: actualCartesian.y, z: actualCartesian.z)
        }
        return Ellipsoid()
    }
    
    /**
    * An Ellipsoid instance initialized to the WGS84 standard.
    *
    * @type {Ellipsoid}
    * @constant
    */
    static func wgs84() -> Ellipsoid {
        return Ellipsoid(x: EarthEquatorialRadius, y: EarthEquatorialRadius, z: EarthPolarRadius)
    }
    
    /**
    * An Ellipsoid instance initialized to radii of (1.0, 1.0, 1.0).
    *
    * @type {Ellipsoid}
    * @constant
    */
    static func unitSphere() -> Ellipsoid {
        return Ellipsoid(x: 1.0, y: 1.0, z: 1.0)
    }
    
    /**
    * Computes the unit vector directed from the center of this ellipsoid toward the provided Cartesian position.
    * @function
    *
    * @param {Cartesian3} cartesian The Cartesian for which to to determine the geocentric normal.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
    */
    func geocentricSurfaceNormal(cartesian: Cartesian3) -> Cartesian3 {
        return cartesian.normalize()
    }
    
    /**
    * Computes the normal of the plane tangent to the surface of the ellipsoid at the provided position.
    *
    * @param {Cartographic} cartographic The cartographic position for which to to determine the geodetic normal.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
    */
    func geodeticSurfaceNormalCartographic(cartographic: Cartographic) -> Cartesian3 {
        var longitude = cartographic.longitude
        var latitude = cartographic.latitude
        var cosLatitude = cos(latitude);
        
        return Cartesian3(
            x: cosLatitude * cos(longitude),
            y: cosLatitude * sin(longitude),
            z: sin(latitude))
            .normalize()
    }
    
    /**
    * Computes the normal of the plane tangent to the surface of the ellipsoid at the provided position.
    *
    * @param {Cartesian3} cartesian The Cartesian position for which to to determine the surface normal.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
    */
    func geodeticSurfaceNormal(cartesian: Cartesian3) -> Cartesian3 {
        return cartesian.multiplyComponents(oneOverRadiiSquared).normalize();
    }
    
    /**
    * Converts the provided cartographic to Cartesian representation.
    *
    * @param {Cartographic} cartographic The cartographic position.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
    *
    * @example
    * //Create a Cartographic and determine it's Cartesian representation on a WGS84 ellipsoid.
    * var position = new Cesium.Cartographic(Cesium.Math.toRadians(21), Cesium.Math.toRadians(78), 5000);
    * var cartesianPosition = Cesium.Ellipsoid.WGS84.cartographicToCartesian(position);
    */
    func cartographicToCartesian(cartographic: Cartographic) -> Cartesian3 {
        var n = geodeticSurfaceNormalCartographic(cartographic)
        var k = n.multiplyComponents(radiiSquared)
        
        var gamma = sqrt(n.dot(k))
        k.divideByScalar(gamma)
        n.multiplyByScalar(cartographic.height)
        
        return k.add(n)
    }
    
    /**
    * Converts the provided array of cartographics to an array of Cartesians.
    *
    * @param {Cartographic[]} cartographics An array of cartographic positions.
    * @param {Cartesian3[]} [result] The object onto which to store the result.
    * @returns {Cartesian3[]} The modified result parameter or a new Array instance if none was provided.
    *
    * @example
    * //Convert an array of Cartographics and determine their Cartesian representation on a WGS84 ellipsoid.
    * var positions = [new Cesium.Cartographic(Cesium.Math.toRadians(21), Cesium.Math.toRadians(78), 0),
    *                  new Cesium.Cartographic(Cesium.Math.toRadians(21.321), Cesium.Math.toRadians(78.123), 100),
    *                  new Cesium.Cartographic(Cesium.Math.toRadians(21.645), Cesium.Math.toRadians(78.456), 250)
    * var cartesianPositions = Cesium.Ellipsoid.WGS84.cartographicArrayToCartesianArray(positions);
    */
    func cartographicArrayToCartesianArray(cartographics: [Cartographic]) -> [Cartesian3] {
        
        var cartesians = [Cartesian3]()
        
        for cartographic in cartographics {
            cartesians.append(cartographicToCartesian(cartographic))
        }
        return cartesians
    }
    
    /**
    * Converts the provided cartesian to cartographic representation.
    * The cartesian is undefined at the center of the ellipsoid.
    *
    * @param {Cartesian3} cartesian The Cartesian position to convert to cartographic representation.
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter, new Cartographic instance if none was provided, or undefined if the cartesian is at the center of the ellipsoid.
    *
    * @example
    * //Create a Cartesian and determine it's Cartographic representation on a WGS84 ellipsoid.
    * var position = new Cesium.Cartesian(17832.12, 83234.52, 952313.73);
    * var cartographicPosition = Cesium.Ellipsoid.WGS84.cartesianToCartographic(position);
    */
    
    func cartesianToCartographic(cartesian: Cartesian3) -> Cartographic? {
        
        var p = scaleToGeodeticSurface(cartesian)
        if p == nil {
            return nil
        }
        
        var n = geodeticSurfaceNormal(p!)
        var h = cartesian.subtract(p!)
        
        var longitude = atan2(n.y, n.x)
        var latitude = asin(n.z)
        
        var height = Double(Math.sign(h.dot(cartesian))) * h.magnitude()
        
        return Cartographic(longitude: longitude, latitude: latitude, height: height)
        
    }
    
    /**
    * Converts the provided array of cartesians to an array of cartographics.
    *
    * @param {Cartesian3[]} cartesians An array of Cartesian positions.
    * @param {Cartographic[]} [result] The object onto which to store the result.
    * @returns {Cartographic[]} The modified result parameter or a new Array instance if none was provided.
    *
    * @example
    * //Create an array of Cartesians and determine their Cartographic representation on a WGS84 ellipsoid.
    * var positions = [new Cesium.Cartesian3(17832.12, 83234.52, 952313.73),
    *                  new Cesium.Cartesian3(17832.13, 83234.53, 952313.73),
    *                  new Cesium.Cartesian3(17832.14, 83234.54, 952313.73)]
    * var cartographicPositions = Cesium.Ellipsoid.WGS84.cartesianArrayToCartographicArray(positions);
    */
    func cartesianArrayToCartographicArray(cartesians: [Cartesian3]) -> [Cartographic] {
        
        var cartographics = [Cartographic]()
        
        for cartesian in cartesians {
            if let cartographic = cartesianToCartographic(cartesian) {
                cartographics.append(cartographic)
            }
        }
        return cartographics
    }
    
    /**
    * Scales the provided Cartesian position along the geodetic surface normal
    * so that it is on the surface of this ellipsoid.  If the position is
    * at the center of the ellipsoid, this function returns undefined.
    *
    * @param {Cartesian3} cartesian The Cartesian position to scale.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter, a new Cartesian3 instance if none was provided, or undefined if the position is at the center.
    */
    func scaleToGeodeticSurface(cartesian: Cartesian3) -> Cartesian3? {
        
        var positionX = cartesian.x
        var positionY = cartesian.y
        var positionZ = cartesian.z
        
        var oneOverRadiiX = oneOverRadii.x
        var oneOverRadiiY = oneOverRadii.y
        var oneOverRadiiZ = oneOverRadii.z
        
        var x2 = positionX * positionX * oneOverRadiiX * oneOverRadiiX
        var y2 = positionY * positionY * oneOverRadiiY * oneOverRadiiY
        var z2 = positionZ * positionZ * oneOverRadiiZ * oneOverRadiiZ
        
        // Compute the squared ellipsoid norm.
        var squaredNorm = x2 + y2 + z2
        var ratio = sqrt(1.0 / squaredNorm)
        
        // As an initial approximation, assume that the radial intersection is the projection point.
        var intersection = cartesian.multiplyByScalar(ratio)
        
        //* If the position is near the center, the iteration will not converge.
        if (squaredNorm < centerToleranceSquared) {
            return ratio.isInfinite ? nil : intersection
        }
        
        var oneOverRadiiSquaredX = oneOverRadiiSquared.x
        var oneOverRadiiSquaredY = oneOverRadiiSquared.y
        var oneOverRadiiSquaredZ = oneOverRadiiSquared.z
        
        // Use the gradient at the intersection point in place of the true unit normal.
        // The difference in magnitude will be absorbed in the multiplier.
        var gradient = Cartesian3();
        gradient.x = intersection.x * oneOverRadiiSquaredX * 2.0
        gradient.y = intersection.y * oneOverRadiiSquaredY * 2.0
        gradient.z = intersection.z * oneOverRadiiSquaredZ * 2.0
        
        // Compute the initial guess at the normal vector multiplier, lambda.
        var lambda = (1.0 - ratio) * cartesian.magnitude() / (0.5 * gradient.magnitude())
        var correction = 0.0
        
        var funcMultiplier: Double
        var denominator: Double
        var xMultiplier: Double
        var yMultiplier: Double
        var zMultiplier: Double
        var xMultiplier2: Double
        var yMultiplier2: Double
        var zMultiplier2: Double
        var xMultiplier3: Double
        var yMultiplier3: Double
        var zMultiplier3: Double
        
        do {
            lambda -= correction
            
            xMultiplier = 1.0 / (1.0 + lambda * oneOverRadiiSquaredX)
            yMultiplier = 1.0 / (1.0 + lambda * oneOverRadiiSquaredY)
            zMultiplier = 1.0 / (1.0 + lambda * oneOverRadiiSquaredZ)
            
            xMultiplier2 = xMultiplier * xMultiplier
            yMultiplier2 = yMultiplier * yMultiplier
            zMultiplier2 = zMultiplier * zMultiplier
            
            xMultiplier3 = xMultiplier2 * xMultiplier
            yMultiplier3 = yMultiplier2 * yMultiplier
            zMultiplier3 = zMultiplier2 * zMultiplier
            
            funcMultiplier = x2 * xMultiplier2 + y2 * yMultiplier2 + z2 * zMultiplier2 - 1.0
            
            // "denominator" here refers to the use of this expression in the velocity and acceleration
            // computations in the sections to follow.
            denominator = x2 * xMultiplier3 * oneOverRadiiSquaredX + y2 * yMultiplier3 * oneOverRadiiSquaredY + z2 * zMultiplier3 * oneOverRadiiSquaredZ
            
            var derivative = -2.0 * denominator
            
            correction = funcMultiplier / derivative
        } while (abs(funcMultiplier) > Math.Epsilon12)
        
        return Cartesian3(x: positionX * xMultiplier, y: positionY * yMultiplier, z: positionZ * zMultiplier)
    }
    
    /**
    * Scales the provided Cartesian position along the geocentric surface normal
    * so that it is on the surface of this ellipsoid.
    *
    * @param {Cartesian3} cartesian The Cartesian position to scale.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
    */
    func scaleToGeocentricSurface(cartesian: Cartesian3) ->Cartesian3 {
        
        let positionX = cartesian.x
        let positionY = cartesian.y
        let positionZ = cartesian.z
        
        var betaSquared = positionX * positionX * oneOverRadiiSquared.x +
            positionY * positionY * oneOverRadiiSquared.y +
            positionZ * positionZ * oneOverRadiiSquared.z
        var beta = 1.0 / sqrt(betaSquared)
        
        return cartesian.multiplyByScalar(beta)
    }
    
    /**
    * Transforms a Cartesian X, Y, Z position to the ellipsoid-scaled space by multiplying
    * its components by the result of {@link Ellipsoid#oneOverRadii}.
    *
    * @param {Cartesian3} position The position to transform.
    * @param {Cartesian3} [result] The position to which to copy the result, or undefined to create and
    *        return a new instance.
    * @returns {Cartesian3} The position expressed in the scaled space.  The returned instance is the
    *          one passed as the result parameter if it is not undefined, or a new instance of it is.
    */
    func transformPositionToScaledSpace(position: Cartesian3) -> Cartesian3 {
        return position.multiplyComponents(oneOverRadii)
    }
    
    /**
    * Transforms a Cartesian X, Y, Z position from the ellipsoid-scaled space by multiplying
    * its components by the result of {@link Ellipsoid#radii}.
    *
    * @param {Cartesian3} position The position to transform.
    * @param {Cartesian3} [result] The position to which to copy the result, or undefined to create and
    *        return a new instance.
    * @returns {Cartesian3} The position expressed in the unscaled space.  The returned instance is the
    *          one passed as the result parameter if it is not undefined, or a new instance of it is.
    */
    func transformPositionFromScaledSpace(position: Cartesian3) -> Cartesian3 {
        return position.multiplyComponents(radii)
    }
    
    /**
    * Compares this Ellipsoid against the provided Ellipsoid componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {Ellipsoid} [right] The other Ellipsoid.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    /*    @infix func == (left: Ellipsoid, right: Ellipsoid) -> Bool {
    return (left.radii == right.radii
    }*/
    
    
    /**
    * Creates a string representing this Ellipsoid in the format '(radii.x, radii.y, radii.z)'.
    *
    * @returns {String} A string representing this ellipsoid in the format '(radii.x, radii.y, radii.z)'.
    */
    func toString() -> String {
        return radii.toString()
    }
    
}
