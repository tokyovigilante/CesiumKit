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

public struct Ellipsoid: Equatable {
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
    init (radii: Cartesian3) {
        self.init(x: radii.x, y: radii.y, z: radii.z)
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
    func geocentricSurfaceNormal(_ cartesian: Cartesian3) -> Cartesian3 {
        return cartesian.normalize()
    }

    /**
    * Computes the normal of the plane tangent to the surface of the ellipsoid at the provided position.
    *
    * @param {Cartographic} cartographic The cartographic position for which to to determine the geodetic normal.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if none was provided.
    */
    func geodeticSurfaceNormalCartographic(_ cartographic: Cartographic) -> Cartesian3 {
        let longitude = cartographic.longitude
        let latitude = cartographic.latitude
        let cosLatitude = cos(latitude)

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
    func geodeticSurfaceNormal(_ cartesian: Cartesian3) -> Cartesian3 {
        return cartesian.multiplyComponents(oneOverRadiiSquared).normalize()
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
    public func cartographicToCartesian(_ cartographic: Cartographic) -> Cartesian3 {
        var n = geodeticSurfaceNormalCartographic(cartographic)
        var k = radiiSquared.multiplyComponents(n)

        let gamma = sqrt(n.dot(k))
        k = k.divideBy(scalar: gamma)
        n = n.multiplyBy(scalar: cartographic.height)

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
    *                  new Cesium.Cartographic(Cesium.Math.toRadians(21.645), Cesium.Math.toRadians(78.456), 250)];
    * var cartesianPositions = Cesium.Ellipsoid.WGS84.cartographicArrayToCartesianArray(positions);
    */
    func cartographicArrayToCartesianArray(_ cartographics: [Cartographic]) -> [Cartesian3] {
        return cartographics.map({ cartographicToCartesian($0) })
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
    * //Create a Cartesian and determine its Cartographic representation on a WGS84 ellipsoid.
    * var position = new Cesium.Cartesian3(17832.12, 83234.52, 952313.73);
    * var cartographicPosition = Cesium.Ellipsoid.WGS84.cartesianToCartographic(position);
    */

    public func cartesianToCartographic(_ cartesian: Cartesian3) -> Cartographic? {

        guard let p = scaleToGeodeticSurface(cartesian) else {
            //logPrint(level: .warning, "Invalid cartesian provided for projection: \(cartesian.description)")
            return nil
        }

        let n = geodeticSurfaceNormal(p)
        let h = cartesian.subtract(p)

        let longitude = atan2(n.y, n.x)
        let latitude = asin(n.z)

        let height = Double(Math.sign(h.dot(cartesian))) * h.magnitude

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
    func cartesianArrayToCartographicArray(_ cartesians: [Cartesian3]) -> [Cartographic] {
        return cartesians.flatMap({ cartesianToCartographic($0) })
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
    func scaleToGeodeticSurface(_ cartesian: Cartesian3) -> Cartesian3? {

        let positionX = cartesian.x
        let positionY = cartesian.y
        let positionZ = cartesian.z

        let oneOverRadiiX = oneOverRadii.x
        let oneOverRadiiY = oneOverRadii.y
        let oneOverRadiiZ = oneOverRadii.z

        let x2 = positionX * positionX * oneOverRadiiX * oneOverRadiiX
        let y2 = positionY * positionY * oneOverRadiiY * oneOverRadiiY
        let z2 = positionZ * positionZ * oneOverRadiiZ * oneOverRadiiZ

        // Compute the squared ellipsoid norm.
        let squaredNorm = x2 + y2 + z2
        let ratio = sqrt(1.0 / squaredNorm)

        // As an initial approximation, assume that the radial intersection is the projection point.
        let intersection = cartesian.multiplyBy(scalar: ratio)

        //* If the position is near the center, the iteration will not converge.
        if (squaredNorm < centerToleranceSquared) {
            return ratio.isInfinite ? nil : intersection
        }

        let oneOverRadiiSquaredX = oneOverRadiiSquared.x
        let oneOverRadiiSquaredY = oneOverRadiiSquared.y
        let oneOverRadiiSquaredZ = oneOverRadiiSquared.z

        // Use the gradient at the intersection point in place of the true unit normal.
        // The difference in magnitude will be absorbed in the multiplier.
        var gradient = Cartesian3();
        gradient.x = intersection.x * oneOverRadiiSquaredX * 2.0
        gradient.y = intersection.y * oneOverRadiiSquaredY * 2.0
        gradient.z = intersection.z * oneOverRadiiSquaredZ * 2.0

        // Compute the initial guess at the normal vector multiplier, lambda.
        var lambda = (1.0 - ratio) * cartesian.magnitude / (0.5 * gradient.magnitude)
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

        repeat {
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

            let derivative = -2.0 * denominator

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
    func scaleToGeocentricSurface(_ cartesian: Cartesian3) ->Cartesian3 {

        let positionX = cartesian.x
        let positionY = cartesian.y
        let positionZ = cartesian.z

        let betaSquared = positionX * positionX * oneOverRadiiSquared.x +
            positionY * positionY * oneOverRadiiSquared.y +
            positionZ * positionZ * oneOverRadiiSquared.z
        let beta = 1.0 / sqrt(betaSquared)

        return cartesian.multiplyBy(scalar: beta)
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
    func transformPositionToScaledSpace(_ position: Cartesian3) -> Cartesian3 {
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
    func transformPositionFromScaledSpace(_ position: Cartesian3) -> Cartesian3 {
        return position.multiplyComponents(radii)
    }


    /**
    * Creates a string representing this Ellipsoid in the format '(radii.x, radii.y, radii.z)'.
    *
    * @returns {String} A string representing this ellipsoid in the format '(radii.x, radii.y, radii.z)'.
    */
    func toString() -> String {
        return radii.simdType.debugDescription
    }

}

extension Ellipsoid: Packable {
    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    static func packedLength () -> Int {
        return Cartesian3.packedLength()
    }

    init(array: [Double], startingIndex: Int = 0) {
        assert(array.count - startingIndex >= Ellipsoid.packedLength(), "Invalid packed array length")
        let radii = Cartesian3(array: array, startingIndex: startingIndex)
        /*array.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Double>) in
            memcpy(&radii, pointer.baseAddress,  Cartesian3.packedLength() * strideof(Double))
        }*/
        self.init(radii: radii)
    }

    /**
     * Stores the provided instance into the provided array.
     * @function
     *
     * @param {Number[]} array The array to pack into.
     * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
     */

    func pack (_ array: inout [Float], startingIndex: Int = 0) {
        radii.pack(&array, startingIndex: startingIndex)
    }

}

/**
 * Compares this Ellipsoid against the provided Ellipsoid componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 *
 * @param {Ellipsoid} [right] The other Ellipsoid.
 * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
 */
public func == (left: Ellipsoid, right: Ellipsoid) -> Bool {
    return (left.radii == right.radii)
}
