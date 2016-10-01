//
//  Cartesian4.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
* A 4D Cartesian point.
* @alias Cartesian4
* @constructor
*
* @param {Number} [x=0.0] The X component.
* @param {Number} [y=0.0] The Y component.
* @param {Number} [z=0.0] The Z component.
* @param {Number} [w=0.0] The W component.
*
* @see Cartesian2
* @see Cartesian3
* @see Packable
*/
public struct Cartesian4 {
    
    fileprivate (set) internal var simdType: double4
    
    var floatRepresentation: float4 {
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
    
    public var w: Double {
        get {
            return simdType.w
        }
        set (new) {
            simdType.w = new
        }
    }

    public var red: Double { return x }
    public var green: Double { return y }
    public var blue: Double { return z }
    public var alpha: Double { return w }
    
    public var width: Double {
        get {
            return z
        }
        set {
            z = newValue
        }
    }
    
    public var height: Double {
        get {
            return w
        }
        set {
            w = newValue
        }
    }
    
    public init (x: Double, y: Double, z: Double, w: Double) {
        simdType = double4(x, y, z, w)
    }
    
    public init (x: Double, y: Double, width: Double, height: Double) {
        simdType = double4(x, y, width, height)
    }
    
    public init(_ scalar: Double = 0.0) {
        simdType = double4(scalar)
    }
    
    /**
    * Creates a Cartesian4 instance from a {@link Color}. <code>red</code>, <code>green</code>, <code>blue</code>,
    * and <code>alpha</code> map to <code>x</code>, <code>y</code>, <code>z</code>, and <code>w</code>, respectively.
    *
    * @param {Color} color The source color.
    * @param {Cartesian4} [result] The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
    */
    public init (red: Double, green: Double, blue: Double, alpha: Double) {
        self.init(x: red, y: green, z: blue, w: alpha)
    }
    
    init (simd: double4) {
        simdType = simd
    }
    
    /**
    * Computes the value of the maximum component for the supplied Cartesian.
    *
    * @param {Cartesian4} cartesian The cartesian to use.
    * @returns {Number} The value of the maximum component.
    */
    public func maximumComponent() -> Double {
        return vector_reduce_max(simdType)
    }
    
    /**
    * Computes the value of the minimum component for the supplied Cartesian.
    *
    * @param {Cartesian4} cartesian The cartesian to use.
    * @returns {Number} The value of the minimum component.
    */
    public func minimumComponent() -> Double {
        return vector_reduce_min(simdType)
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
    *
    * @param {Cartesian4} first A cartesian to compare.
    * @param {Cartesian4} second A cartesian to compare.
    * @param {Cartesian4} result The object into which to store the result.
    * @returns {Cartesian4} A cartesian with the minimum components.
    */
    public func minimumByComponent(_ other: Cartesian4) -> Cartesian4 {
        return Cartesian4(simd: vector_min(simdType, other.simdType))
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
    *
    * @param {Cartesian4} first A cartesian to compare.
    * @param {Cartesian4} second A cartesian to compare.
    * @param {Cartesian4} result The object into which to store the result.
    * @returns {Cartesian4} A cartesian with the maximum components.
    */
    public func maximumByComponent(_ other: Cartesian4) -> Cartesian4 {
        return Cartesian4(simd: vector_max(simdType, other.simdType))
    }
    
    /**
    * Computes the provided Cartesian's squared magnitude.
    *
    * @param {Cartesian4} cartesian The Cartesian instance whose squared magnitude is to be computed.
    * @returns {Number} The squared magnitude.
    */
    public func magnitudeSquared() -> Double {
        return length_squared(simdType)//x * x + y * y + z * z + w * w
    }
    
    /**
    * Computes the Cartesian's magnitude (length).
    *
    * @param {Cartesian4} cartesian The Cartesian instance whose magnitude is to be computed.
    * @returns {Number} The magnitude.
    */
    public func magnitude() -> Double {
        return length(simdType)
    }
    
    /**
    * Computes the 4-space distance between two points.
    *
    * @param {Cartesian4} left The first point to compute the distance from.
    * @param {Cartesian4} right The second point to compute the distance to.
    * @returns {Number} The distance between two points.
    *
    * @example
    * // Returns 1.0
    * var d = Cesium.Cartesian4.distance(
    * new Cesium.Cartesian4(1.0, 0.0, 0.0, 0.0),
    * new Cesium.Cartesian4(2.0, 0.0, 0.0, 0.0));
    */
    public func distance(_ other: Cartesian4) -> Double {
        return simd.distance(simdType, other.simdType)
    }
    
    /**
    * Computes the squared distance between two points.  Comparing squared distances
    * using this function is more efficient than comparing distances using {@link Cartesian4#distance}.
    *
    * @param {Cartesian4} left The first point to compute the distance from.
    * @param {Cartesian4} right The second point to compute the distance to.
    * @returns {Number} The distance between two points.
    *
    * @example
    * // Returns 4.0, not 2.0
    * var d = Cesium.Cartesian4.distance(
    *   new Cesium.Cartesian4(1.0, 0.0, 0.0, 0.0),
    *   new Cesium.Cartesian4(3.0, 0.0, 0.0, 0.0));
    */
    public func distanceSquared (_ other: Cartesian4) -> Double {
        return distance_squared(simdType, other.simdType)
    }
    
    /**
    * Computes the normalized form of the supplied Cartesian.
    *
    * @param {Cartesian4} cartesian The Cartesian to be normalized.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    public func normalize() -> Cartesian4 {
        return Cartesian4(simd: simd.normalize(simdType))
    }
    
    /**
    * Computes the dot (scalar) product of two Cartesians.
    *
    * @param {Cartesian4} left The first Cartesian.
    * @param {Cartesian4} right The second Cartesian.
    * @returns {Number} The dot product.
    */
    public func dot(_ other: Cartesian4) -> Double {
        return simd.dot(simdType, other.simdType)
    }
    
    /**
     * Computes the componentwise product of two Cartesians.
     *
     * @param {Cartesian4} left The first Cartesian.
     * @param {Cartesian4} right The second Cartesian.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func multiplyComponents(_ other: Cartesian4) -> Cartesian4 {
        return Cartesian4(simd: simdType * other.simdType)
    }

    /**
     * Computes the componentwise sum of two Cartesians.
     *
     * @param {Cartesian4} left The first Cartesian.
     * @param {Cartesian4} right The second Cartesian.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func add(_ other: Cartesian4) -> Cartesian4 {
        return Cartesian4(simd: simdType + other.simdType)
    }
    
    /**
     * Computes the componentwise difference of two Cartesians.
     *
     * @param {Cartesian4} left The first Cartesian.
     * @param {Cartesian4} right The second Cartesian.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func subtract(_ other: Cartesian4) -> Cartesian4 {
        return Cartesian4(simd: simdType - other.simdType)
    }

    /**
     * Multiplies the provided Cartesian componentwise by the provided scalar.
     *
     * @param {Cartesian4} cartesian The Cartesian to be scaled.
     * @param {Number} scalar The scalar to multiply with.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func multiplyByScalar (_ scalar: Double) -> Cartesian4 {
        return Cartesian4(simd: simdType * scalar)
    }
    
    /**
     * Divides the provided Cartesian componentwise by the provided scalar.
     *
     * @param {Cartesian4} cartesian The Cartesian to be divided.
     * @param {Number} scalar The scalar to divide by.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    public func divideByScalar (_ scalar: Double) -> Cartesian4 {
        return Cartesian4(simd: simdType * (1/scalar))
    }
    
    /**
     * Negates the provided Cartesian.
     *
     * @param {Cartesian4} cartesian The Cartesian to be negated.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    func negate () -> Cartesian4 {
        return Cartesian4(simd: -simdType)
    }
    
    /**
     * Computes the absolute value of the provided Cartesian.
     *
     * @param {Cartesian4} cartesian The Cartesian whose absolute value is to be computed.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    func absolute() -> Cartesian4 {
        return Cartesian4(simd: vector_abs(simdType))
    }
    
    /**
    * Computes the linear interpolation or extrapolation at t using the provided cartesians.
    *
    * @param {Cartesian4} start The value corresponding to t at 0.0.
    * @param {Cartesian4}end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func lerp(_ end: Cartesian4, t: Double) -> Cartesian4 {
        return Cartesian4(simd: mix(simdType, end.simdType, t: t))
    }
    
    /**
    * Returns the axis that is most orthogonal to the provided Cartesian.
    *
    * @param {Cartesian4} cartesian The Cartesian on which to find the most orthogonal axis.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The most orthogonal axis.
    */
    func mostOrthogonalAxis() -> Cartesian4 {
        
        let f = normalize().absolute()
        var result: Cartesian4
        
        if (f.x <= f.y) {
            if (f.x <= f.z) {
                if (f.x <= f.w) {
                    result = Cartesian4.unitX
                } else {
                    result = Cartesian4.unitW
                }
            } else if (f.z <= f.w) {
                result = Cartesian4.unitZ
            } else {
                result = Cartesian4.unitW
            }
        } else if (f.y <= f.z) {
            if (f.y <= f.w) {
                result = Cartesian4.unitY
            } else {
                result = Cartesian4.unitW
            }
        } else if (f.z <= f.w) {
            result = Cartesian4.unitZ
        } else {
            result = Cartesian4.unitW
        }
        return result
    }
    
    func equalsArray (_ array: [Float], offset: Int) -> Bool {
        return Float(x) == array[offset] &&
            Float(y) == array[offset + 1] &&
            Float(z) == array[offset + 2] &&
            Float(w) == array[offset + 3]
    }
    
    /**
    * Compares the provided Cartesians componentwise and returns
    * <code>true</code> if they pass an absolute or relative tolerance test,    
    * <code>false</code> otherwise.
    *
    * @param {Cartesian4} [left] The first Cartesian.
    * @param {Cartesian4} [right] The second Cartesian.
    * @param {Number} relativeEpsilon The relative epsilon tolerance to use for equality testing.
    * @param {Number} [absoluteEpsilon=relativeEpsilon] The absolute epsilon tolerance to use for equality testing.    
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    func equalsEpsilon(_ other: Cartesian4, relativeEpsilon: Double, absoluteEpsilon: Double) -> Bool {
        return self == other ||
            (Math.equalsEpsilon(self.x, other.x, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon) &&
            Math.equalsEpsilon(self.y, other.y, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon) &&
            Math.equalsEpsilon(self.z, other.z, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon) &&
            Math.equalsEpsilon(self.w, other.w, relativeEpsilon: relativeEpsilon, absoluteEpsilon: absoluteEpsilon))
    }
    
    /**
    * An immutable Cartesian4 instance initialized to (0.0, 0.0, 0.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static let zero = Cartesian4()
    
    /**
    * An immutable Cartesian4 instance initialized to (1.0, 0.0, 0.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static let unitX = Cartesian4(x: 1.0, y: 0.0, z: 0.0, w: 0.0)

    /**
    * An immutable Cartesian4 instance initialized to (0.0, 1.0, 0.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static let unitY = Cartesian4(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
    
    /**
    * An immutable Cartesian4 instance initialized to (0.0, 0.0, 1.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static let unitZ = Cartesian4(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
    
    /**
    * An immutable Cartesian4 instance initialized to (0.0, 0.0, 0.0, 1.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static let unitW = Cartesian4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
}

extension Cartesian4: Packable {
    
    static func packedLength () -> Int {
        return 4
    }
    
    init(array: [Double], startingIndex: Int = 0) {
        self.init()
        assert(checkPackedArrayLength(array, startingIndex: startingIndex), "Invalid packed array length")
        self.x = array[startingIndex]
        self.y = array[startingIndex+1]
        self.z = array[startingIndex+2]
        self.w = array[startingIndex+3]
        /*array.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Double>) in
            memcpy(&self, pointer.baseAddress, Cartesian4.packedLength() * strideof(Double))
        }*/
    }
}

extension Cartesian4: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "x: \(x), y: \(y), z: \(z), w: \(w)"
    }
}

extension Cartesian4 {
    
    public func contains(_ point: Cartesian2) -> Bool {
        if x < point.x &&
            x + width > point.x &&
            y < point.y &&
            y + height > point.y {
            return true
        }
        return false
    }
    
}

extension Cartesian4: Equatable {}

/**
* Compares the provided Cartesians componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {Cartesian4} [left] The first Cartesian.
* @param {Cartesian4} [right] The second Cartesian.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
public func == (left: Cartesian4, right: Cartesian4) -> Bool {
    return (left.x == right.x) && (left.y == right.y) && (left.z == right.z) && (left.w == right.w)
}


