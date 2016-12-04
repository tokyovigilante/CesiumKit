//
//  Cartesian3.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
* A 3D Cartesian point.
* @alias Cartesian3
* @constructor
*
* @param {Number} [x=0.0] The X component.
* @param {Number} [y=0.0] The Y component.
* @param {Number} [z=0.0] The Z component.
*
* @see Cartesian2
* @see Cartesian4
* @see Packable
*/

public struct Cartesian3 {

    fileprivate (set) var simdType: double3
    
    var floatRepresentation: float3 {
        return vector_float(simdType)
    }
    
    public var x: Double {
        get {
            return simdType.x
        }
        set (new) {
            simdType.x = new
        }
    }
    
    public var y: Double {
        get {
            return simdType.y
        }
        set (new) {
            simdType.y = new
        }
    }
    
    public var z: Double {
        get {
            return simdType.z
        }
        set (new) {
            simdType.z = new
        }
    }
    
    public init (x: Double, y: Double, z: Double) {
        simdType = double3(x, y, z)
    }

    public init(_ scalar: Double = 0.0) {
        simdType = double3(scalar)
    }
    
    init(simd: double3) {
        simdType = simd
    }
    
    /**
    * Converts the provided Spherical into Cartesian3 coordinates.
    *
    * @param {Spherical} spherical The Spherical to be converted to Cartesian3.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    internal init(fromSpherical spherical: Spherical) {
        let clock = spherical.clock
        let cone = spherical.cone
        let magnitude = spherical.magnitude
        let radial = magnitude * sin(cone)
        self.init(
            x: radial * cos(clock),
            y: radial * sin(clock),
            z: magnitude * cos(cone)
        )
    }
    
    /**
    * Creates a Cartesian3 instance from an existing Cartesian4.  This simply takes the
    * x, y, and z properties of the Cartesian4 and drops w.
    * @function
    *
    * @param {Cartesian4} cartesian The Cartesian4 instance to create a Cartesian3 instance from.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    init(cartesian4: Cartesian4) {
        self.init(x: cartesian4.x, y: cartesian4.y, z: cartesian4.z)
    }
    
    /**
    * Computes the value of the maximum component for the supplied Cartesian.
    *
    * @param {Cartesian3} cartesian The cartesian to use.
    * @returns {Number} The value of the maximum component.
    */
    func maximumComponent() -> Double {
        return vector_reduce_max(simdType)
    }
    
    /**
    * Computes the value of the minimum component for the supplied Cartesian.
    *
    * @param {Cartesian3} cartesian The cartesian to use.
    * @returns {Number} The value of the minimum component.
    */
    func minimumComponent() -> Double {
        return vector_reduce_min(simdType)
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
    *
    * @param {Cartesian3} first A cartesian to compare.
    * @param {Cartesian3} second A cartesian to compare.
    * @param {Cartesian3} [result] The object into which to store the result.
    * @returns {Cartesian3} A cartesian with the minimum components.
    */
    func minimumByComponent(_ other: Cartesian3) -> Cartesian3 {
        return Cartesian3(simd: vector_min(simdType, other.simdType))
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
    *
    * @param {Cartesian3} first A cartesian to compare.
    * @param {Cartesian3} second A cartesian to compare.
    * @param {Cartesian3} [result] The object into which to store the result.
    * @returns {Cartesian3} A cartesian with the maximum components.
    */
    func maximumByComponent(_ other: Cartesian3) -> Cartesian3 {
        return Cartesian3(simd: vector_max(simdType, other.simdType))
    }
    
    /**
    * Computes the provided Cartesian's squared magnitude.
    *
    * @param {Cartesian3} cartesian The Cartesian instance whose squared magnitude is to be computed.
    * @returns {Number} The squared magnitude.
    */
    public var magnitudeSquared: Double {
        return length_squared(simdType)
    }
    
    /**
    * Computes the Cartesian's magnitude (length).
    *
    * @param {Cartesian3} cartesian The Cartesian instance whose magnitude is to be computed.
    * @returns {Number} The magnitude.
    */
    public var magnitude: Double {
        return length(simdType)
    }
    
    /**
    * Computes the distance between two points.
    *
    * @param {Cartesian3} left The first point to compute the distance from.
    * @param {Cartesian3} right The second point to compute the distance to.
    * @returns {Number} The distance between two points.
    *
    * @example
    * // Returns 1.0
    * var d = Cesium.Cartesian3.distance(new Cesium.Cartesian3(1.0, 0.0, 0.0), new Cesium.Cartesian3(2.0, 0.0, 0.0));
    */
    func distance(_ other: Cartesian3) -> Double {
        return simd.distance(simdType, other.simdType)
    }
    
    /**
    * Computes the squared distance between two points.  Comparing squared distances
    * using this function is more efficient than comparing distances using {@link Cartesian3#distance}.
    *
    * @param {Cartesian3} left The first point to compute the distance from.
    * @param {Cartesian3} right The second point to compute the distance to.
    * @returns {Number} The distance between two points.
    *
    * @example
    * // Returns 4.0, not 2.0
    * var d = Cesium.Cartesian3.distance(new Cesium.Cartesian3(1.0, 0.0, 0.0), new Cesium.Cartesian3(3.0, 0.0, 0.0));
    */
    func distanceSquared(_ other: Cartesian3) -> Double {
        return distance_squared(simdType, other.simdType)
    }

    /** Computes the normalized form of the supplied Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian to be normalized.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    
    public func normalize() -> Cartesian3 {
        return Cartesian3(simd: simd.normalize(simdType))
    }
    
    /**
    * Computes the dot (scalar) product of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @returns {Number} The dot product.
    */
    public func dot(_ other: Cartesian3) -> Double {
        return simd.dot(simdType, other.simdType)
    }
    
    public func multiplyComponents(_ other: Cartesian3) -> Cartesian3 {
        return Cartesian3(simd: simdType * other.simdType)
    }
    
    /**
     * Computes the componentwise sum of two Cartesians.
     *
     * @param {Cartesian4} left The first Cartesian.
     * @param {Cartesian4} right The second Cartesian.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func add(_ other: Cartesian3) -> Cartesian3 {
        return Cartesian3(simd: simdType + other.simdType)
    }
    
    /**
     * Computes the componentwise difference of two Cartesians.
     *
     * @param {Cartesian4} left The first Cartesian.
     * @param {Cartesian4} right The second Cartesian.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func subtract(_ other: Cartesian3) -> Cartesian3 {
        return Cartesian3(simd: simdType - other.simdType)
    }
    
    /**
     * Multiplies the provided Cartesian componentwise by the provided scalar.
     *
     * @param {Cartesian4} cartesian The Cartesian to be scaled.
     * @param {Number} scalar The scalar to multiply with.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func multiplyBy (scalar: Double) -> Cartesian3 {
        return Cartesian3(simd: simdType * scalar)
    }
    
    /**
     * Divides the provided Cartesian componentwise by the provided scalar.
     *
     * @param {Cartesian4} cartesian The Cartesian to be divided.
     * @param {Number} scalar The scalar to divide by.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func divideBy (scalar: Double) -> Cartesian3 {
        return Cartesian3(simd: simdType * (1/scalar))
    }
    
    /**
     * Negates the provided Cartesian.
     *
     * @param {Cartesian3} cartesian The Cartesian to be negated.
     * @param {Cartesian3} result The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter.
     */
    func negate () -> Cartesian3 {
        return Cartesian3(simd: -simdType)
    }

    /**
    * Computes the absolute value of the provided Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian whose absolute value is to be computed.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func absolute() -> Cartesian3 {
        return Cartesian3(simd: vector_abs(simdType))
    }
    
    /**
    * Computes the linear interpolation or extrapolation at t using the provided cartesians.
    *
    * @param {Cartesian3} start The value corresponding to t at 0.0.
    * @param {Cartesian3} end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func lerp(_ end: Cartesian3, t: Double) -> Cartesian3 {
        return Cartesian3(simd: mix(simdType, end.simdType, t: t))
    }
    
    /**
    * Returns the angle, in radians, between the provided Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @returns {Number} The angle between the Cartesians.
    */
    func angle(between other: Cartesian3) -> Double {
        let cosine = self.normalize().dot(other.normalize())
        let sine = self.normalize().cross(other.normalize()).magnitude
        return atan2(sine, cosine)
    }
    
    /**
    * Returns the axis that is most orthogonal to the provided Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian on which to find the most orthogonal axis.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The most orthogonal axis.
    */
    func mostOrthogonalAxis() -> Cartesian3 {
        
        let f = normalize().absolute();
        var result: Cartesian3
        
        if (f.x <= f.y) {
            if (f.x <= f.z) {
                result = Cartesian3.unitX
            } else {
                result = Cartesian3.unitZ
            }
        } else {
            if (f.y <= f.z) {
                result = Cartesian3.unitY
            } else {
                result = Cartesian3.unitZ
            }
        }
        
        return result;
    }
    
    func equals (array: [Float], offset: Int) -> Bool {
        return Float(x) == array[offset] &&
            Float(y) == array[offset + 1] &&
            Float(z) == array[offset + 2]
    }
    
    /**
    * Compares the provided Cartesians componentwise and returns
    * <code>true</code> if they pass an absolute or relative tolerance test,
    * <code>false</code> otherwise.
    *
    * @param {Cartesian3} [left] The first Cartesian.
    * @param {Cartesian3} [right] The second Cartesian.
    * @param {Number} relativeEpsilon The relative epsilon tolerance to use for equality testing.
    * @param {Number} [absoluteEpsilon=relativeEpsilon] The absolute epsilon tolerance to use for equality testing.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    func equalsEpsilon(_ other: Cartesian3, relativeEpsilon: Double, absoluteEpsilon: Double? = nil) -> Bool {
        return self == other ||
            (Math.equalsEpsilon(self.x, other.x, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon) &&
                Math.equalsEpsilon(self.y, other.y, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon) &&
                Math.equalsEpsilon(self.z, other.z, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon))
    }
    
    /**
    * Computes the cross (outer) product of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The cross product.
    */
    public func cross(_ other: Cartesian3) -> Cartesian3 {
        return Cartesian3(simd: simd.cross(simdType, other.simdType))
    }
    
    /**
    * Returns a Cartesian3 position from longitude and latitude values given in degrees.
    *
    * @param {Number} longitude The longitude, in degrees
    * @param {Number} latitude The latitude, in degrees
    * @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The position
    *
    * @example
    * var position = Cartesian3.fromDegrees(-115.0, 37.0);
    */
    public static func fromDegrees(longitude: Double, latitude: Double, height: Double = 0.0, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) -> Cartesian3 {
        
        let lon = Math.toRadians(longitude)
        let lat = Math.toRadians(latitude)
        return Cartesian3.fromRadians(longitude: lon, latitude: lat, height: height, ellipsoid: ellipsoid)
    }
    
    /**
    * Returns a Cartesian3 position from longitude and latitude values given in radians.
    *
    * @param {Number} longitude The longitude, in radians
    * @param {Number} latitude The latitude, in radians
    * @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The position
    *
    * @example
    * var position = Cartesian3.fromRadians(-2.007, 0.645);
    */
    static func fromRadians(longitude: Double, latitude: Double, height: Double = 0.0, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) -> Cartesian3 {
        
        let cosLatitude = cos(latitude);
        let n = Cartesian3(x: cosLatitude * cos(longitude), y: cosLatitude * sin(longitude), z: sin(latitude)).normalize()
        let k = n.multiplyComponents(ellipsoid.radiiSquared)
        let gamma = sqrt(n.dot(k))
        
        return k.divideBy(scalar: gamma).add(n.multiplyBy(scalar: height))
    }
    
    /**
    * Returns an array of Cartesian3 positions given an array of longitude and latitude values given in degrees.
    *
    * @param {Number[]} coordinates A list of longitude and latitude values. Values alternate [longitude, latitude, longitude, latitude...].
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the coordinates lie.
    * @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
    * @returns {Cartesian3[]} The array of positions.
    *
    * @example
    * var positions = Cartesian3.fromDegreesArray([-115.0, 37.0, -107.0, 33.0]);
    */
    static func fromDegreesArray(_ coordinates: [Double], ellipsoid: Ellipsoid) -> [Cartesian3] {
        
        var pos = [Double]()
        for coordinate in coordinates {
            pos.append(Math.toRadians(coordinate))
        }
        
        return Cartesian3.fromRadiansArray(pos, ellipsoid: ellipsoid)
    }
    
    /**
    * Returns an array of Cartesian3 positions given an array of longitude and latitude values given in radians.
    *
    * @param {Number[]} coordinates A list of longitude and latitude values. Values alternate [longitude, latitude, longitude, latitude...].
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the coordinates lie.
    * @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
    * @returns {Cartesian3[]} The array of positions.
    *
    * @example
    * var positions = Cartesian3.fromRadiansArray([-2.007, 0.645, -1.867, .575]);
    */
    static func fromRadiansArray(_ coordinates: [Double], ellipsoid: Ellipsoid) -> [Cartesian3] {
        
        assert(coordinates.count <= 2 && coordinates.count % 2 == 0, "must have even number of positions")
        
        var cartesians = [Cartesian3]()
        for i in stride(from: 0, to: coordinates.count, by: 2) {
            cartesians.append(Cartesian3.fromRadians(longitude: coordinates[i], latitude: coordinates[i+1], height: 0, ellipsoid: ellipsoid))
        }
        return cartesians
    }
    
    /**
    * Returns an array of Cartesian3 positions given an array of longitude, latitude and height values where longitude and latitude are given in degrees.
    *
    * @param {Number[]} coordinates A list of longitude, latitude and height values. Values alternate [longitude, latitude, height,, longitude, latitude, height...].
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
    * @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
    * @returns {Cartesian3[]} The array of positions.
    *
    * @example
    * var positions = Cartesian3.fromDegreesArrayHeights([-115.0, 37.0, 100000.0, -107.0, 33.0, 150000.0]);
    */
    static func fromDegreesArrayHeights(_ coordinates: [Double], ellipsoid: Ellipsoid) -> [Cartesian3] {
        
        var pos = [Double]()
        for i in stride(from: 0, to: coordinates.count, by: 3) {
            pos.append(Math.toRadians(coordinates[i]))
            pos.append(Math.toRadians(coordinates[i+1]))
            pos.append((coordinates[i+2]))
        }
        
        return Cartesian3.fromRadiansArrayHeights(pos, ellipsoid: ellipsoid)
    }
    
    /**
    * Returns an array of Cartesian3 positions given an array of longitude, latitude and height values where longitude and latitude are given in radians.
    *
    * @param {Number[]} coordinates A list of longitude, latitude and height values. Values alternate [longitude, latitude, height,, longitude, latitude, height...].
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
    * @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
    * @returns {Cartesian3[]} The array of positions.
    *
    * @example
    * var positions = Cartesian3.fromradiansArrayHeights([-2.007, 0.645, 100000.0, -1.867, .575, 150000.0]);
    */
    static func fromRadiansArrayHeights(_ coordinates: [Double], ellipsoid: Ellipsoid) -> [Cartesian3] {
        
        assert(coordinates.count <= 3 && coordinates.count % 3 == 0, "must have %3=0 number of positions")
        
        var cartesians = [Cartesian3]()
        for i in stride(from: 0, to: coordinates.count, by: 3) {
            cartesians.append(Cartesian3.fromRadians(longitude: coordinates[i], latitude: coordinates[i+1], height: coordinates[i+2], ellipsoid: ellipsoid))
        }
        return cartesians
    }
    /**
    * An immutable Cartesian3 instance initialized to (0.0, 0.0, 0.0).
    *
    * @type {Cartesian3}
    * @constant
    */
    
    public static let zero = Cartesian3()
    
    /**
    * An immutable Cartesian3 instance initialized to (1.0, 0.0, 0.0).
    *
    * @type {Cartesian3}
    * @constant
    */
    public static let unitX = Cartesian3(x: 1.0, y: 0.0, z: 0.0)
    
    /**
    * An immutable Cartesian3 instance initialized to (0.0, 1.0, 0.0).
    *
    * @type {Cartesian3}
    * @constant
    */
    public static let unitY = Cartesian3(x: 0.0, y: 1.0, z: 0.0)
    
    /**
    * An immutable Cartesian3 instance initialized to (0.0, 0.0, 1.0).
    *
    * @type {Cartesian3}
    * @constant
    */
    public static let unitZ = Cartesian3(x: 0.0, y: 0.0, z: 1.0)
}

extension Cartesian3: Packable {
    
    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    static func packedLength() -> Int {
        return 3
    }
    
    
    init(array: [Double], startingIndex: Int = 0) {
        self.init()
        assert(checkPackedArrayLength(array, startingIndex: startingIndex), "Invalid packed array length")
        self.x = array[startingIndex]
        self.y = array[startingIndex+1]
        self.z = array[startingIndex+2]
        /*array.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Double>) in
            memcpy(&self, pointer.baseAddress, Cartesian3.packedLength() * strideof(Double))
        }*/
    }
    
    func toArray() -> [Double] {
        return [self.x, self.y, self.z]
    }
}

extension Cartesian3: CustomStringConvertible {
    public var description: String {
        return String(describing: simdType)
    }
}

extension Cartesian3: Equatable {}

/**
* Compares the provided Cartesians componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {Cartesian3} [left] The first Cartesian.
* @param {Cartesian3} [right] The second Cartesian.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
public func == (left: Cartesian3, right: Cartesian3) -> Bool {
    return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
}

extension Cartesian3: Offset {
    
    public var offset: Cartesian3 {
        return self
    }
    
}

