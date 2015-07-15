//
//  Cartesian4.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

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
// FIXME: Packable
public struct Cartesian4: Packable, Equatable, CustomStringConvertible {
    /**
    * The X component.
    * @type {Number}
    * @default 0.0
    */
    var x: Double = 0.0
    
    /**
    * The Y component.
    * @type {Number}
    * @default 0.0
    */
    var y: Double = 0.0
    
    /**
    * The Z component.
    * @type {Number}
    * @default 0.0
    */
    var z: Double = 0.0
    
    /**
    * The W component.
    * @type {Number}
    * @default 0.0
    */
    var w: Double = 0.0
    
    public var description: String {
        return "(\(x), \(y), \(z), \(w))"
    }
    
    var red: Double {
        get {
            return x
        }
    }
    
    var green: Double {
        get {
            return y
        }
    }
    
    var blue: Double {
        get {
            return z
        }
    }
    
    var alpha: Double {
        get {
            return w
        }
    }
    
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    static let packedLength: Int = 4
    
    
    init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0, w: Double = 0.0) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    /**
    * Creates a Cartesian4 instance from a {@link Color}. <code>red</code>, <code>green</code>, <code>blue</code>,
    * and <code>alpha</code> map to <code>x</code>, <code>y</code>, <code>z</code>, and <code>w</code>, respectively.
    *
    * @param {Color} color The source color.
    * @param {Cartesian4} [result] The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
    */
    static func fromColor (red red: Double, green: Double, blue: Double, alpha: Double) -> Cartesian4 {
        return Cartesian4(x: red, y: green, z: blue, w: alpha)
    }
    
    /**
    * Stores the provided instance into the provided array.
    *
    * @param {Cartesian4} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    func pack(inout array: [Float], startingIndex: Int) {
        assert(array.count - startingIndex >= Cartesian4.packedLength, "Array too short")
        array[startingIndex] = Float(x)
        array[startingIndex+1] = Float(y)
        array[startingIndex+2] = Float(z)
        array[startingIndex+3] = Float(w)
    }
    
    /**
    * Retrieves an instance from a packed array.
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Cartesian4} [result] The object into which to store the result.
    */
    static func unpack(array: [Float], startingIndex: Int = 0) -> Cartesian4 {
        assert(startingIndex + Cartesian4.packedLength <= array.count, "Invalid starting index")
        
        return Cartesian4(
            x: Double(array[startingIndex]),
            y: Double(array[startingIndex+1]),
            z: Double(array[startingIndex+2]),
            w: Double(array[startingIndex+3]))
    }
    
    /**
    * Creates a Cartesian4 from four consecutive elements in an array.
    * @function
    *
    * @param {Number[]} array The array whose four consecutive elements correspond to the x, y, z, and w components, respectively.
    * @param {Number} [startingIndex=0] The offset into the array of the first element, which corresponds to the x component.
    * @param {Cartesian4} [result] The object onto which to store the result.
    * @returns {Cartesian4}  The modified result parameter or a new Cartesian4 instance if one was not provided.
    *
    * @example
    * // Create a Cartesian4 with (1.0, 2.0, 3.0, 4.0)
    * var v = [1.0, 2.0, 3.0, 4.0];
    * var p = Cesium.Cartesian4.fromArray(v);
    *
    * // Create a Cartesian4 with (1.0, 2.0, 3.0, 4.0) using an offset into an array
    * var v2 = [0.0, 0.0, 1.0, 2.0, 3.0, 4.0];
    * var p2 = Cesium.Cartesian4.fromArray(v2, 2);
    */
    static func fromArray(array: [Float]) -> Cartesian4 {
        return Cartesian4.unpack(array)
    }
    
    /**
    * Computes the value of the maximum component for the supplied Cartesian.
    *
    * @param {Cartesian4} cartesian The cartesian to use.
    * @returns {Number} The value of the maximum component.
    */
    func maximumComponent() -> Double {
        return max(x, y, z, w)
    }
    
    /**
    * Computes the value of the minimum component for the supplied Cartesian.
    *
    * @param {Cartesian4} cartesian The cartesian to use.
    * @returns {Number} The value of the minimum component.
    */
    func minimumComponent() -> Double {
        return min(x, y, z, w)
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
    *
    * @param {Cartesian4} first A cartesian to compare.
    * @param {Cartesian4} second A cartesian to compare.
    * @param {Cartesian4} result The object into which to store the result.
    * @returns {Cartesian4} A cartesian with the minimum components.
    */
    func minimumByComponent(other: Cartesian4) -> Cartesian4 {
        return Cartesian4(x: min(x, other.x), y: min(y, other.y), z: min(y, other.y), w: min(w, other.w))
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
    *
    * @param {Cartesian4} first A cartesian to compare.
    * @param {Cartesian4} second A cartesian to compare.
    * @param {Cartesian4} result The object into which to store the result.
    * @returns {Cartesian4} A cartesian with the maximum components.
    */
    func maximumByComponent(other: Cartesian4) -> Cartesian4 {
        return Cartesian4(x: max(x, other.x), y: max(y, other.y), z: max(y, other.y), w: max(w, other.w))
    }
    
    /**
    * Computes the provided Cartesian's squared magnitude.
    *
    * @param {Cartesian4} cartesian The Cartesian instance whose squared magnitude is to be computed.
    * @returns {Number} The squared magnitude.
    */
    func magnitudeSquared() -> Double {
        return x * x + y * y + z * z + w * w
    }
    
    /**
    * Computes the Cartesian's magnitude (length).
    *
    * @param {Cartesian4} cartesian The Cartesian instance whose magnitude is to be computed.
    * @returns {Number} The magnitude.
    */
    func magnitude() -> Double {
        return sqrt(magnitudeSquared())
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
    func distance(other: Cartesian4) -> Double {
        return subtract(other).magnitude()
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
    func distanceSquared (other: Cartesian4) -> Double {
        return self.subtract(other).magnitudeSquared()
    }
    
    /**
    * Computes the normalized form of the supplied Cartesian.
    *
    * @param {Cartesian4} cartesian The Cartesian to be normalized.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func normalize() -> Cartesian4 {
        let magnitude = self.magnitude();
        return Cartesian4(x: x / magnitude, y: y / magnitude, z: z / magnitude, w: w / magnitude)
    }
    
    /**
    * Computes the dot (scalar) product of two Cartesians.
    *
    * @param {Cartesian4} left The first Cartesian.
    * @param {Cartesian4} right The second Cartesian.
    * @returns {Number} The dot product.
    */
    func dot(other: Cartesian4) -> Double {
        return x * other.x + y * other.y + z * other.z + w * other.w
    }
    
    /**
    * Computes the componentwise product of two Cartesians.
    *
    * @param {Cartesian4} left The first Cartesian.
    * @param {Cartesian4} right The second Cartesian.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func multiplyComponents(other: Cartesian4) -> Cartesian4 {
        return Cartesian4(x: x * other.x, y: y * other.y, z: z * other.z, w: w * other.w)
    }
    
    /**
    * Computes the componentwise sum of two Cartesians.
    *
    * @param {Cartesian4} left The first Cartesian.
    * @param {Cartesian4} right The second Cartesian.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func add(other: Cartesian4) -> Cartesian4 {
        return Cartesian4(x: x + other.x, y: y + other.y, z: z + other.z, w: w + other.w)
    }
    
    /**
    * Computes the componentwise difference of two Cartesians.
    *
    * @param {Cartesian4} left The first Cartesian.
    * @param {Cartesian4} right The second Cartesian.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func subtract(other: Cartesian4) -> Cartesian4 {
        return Cartesian4(x: x - other.x, y: y - other.y, z: z - other.z, w: w - other.w)
    }
    
    /**
    * Multiplies the provided Cartesian componentwise by the provided scalar.
    *
    * @param {Cartesian4} cartesian The Cartesian to be scaled.
    * @param {Number} scalar The scalar to multiply with.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func multiplyByScalar(scalar: Double) -> Cartesian4 {
        return  Cartesian4(x: x * scalar, y: y * scalar, z: z * scalar, w: w * scalar)
    }
    
    /**
    * Divides the provided Cartesian componentwise by the provided scalar.
    *
    * @param {Cartesian4} cartesian The Cartesian to be divided.
    * @param {Number} scalar The scalar to divide by.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func divideByScalar(scalar: Double) -> Cartesian4 {
        return  Cartesian4(x: x / scalar, y: y / scalar, z: z / scalar, w: w / scalar)
    }
    
    /**
    * Negates the provided Cartesian.
    *
    * @param {Cartesian4} cartesian The Cartesian to be negated.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func negate() -> Cartesian4 {
        return Cartesian4(x: -x, y: -y, z: -z, w: -w)
    }
    
    /**
    * Computes the absolute value of the provided Cartesian.
    *
    * @param {Cartesian4} cartesian The Cartesian whose absolute value is to be computed.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    */
    func absolute() -> Cartesian4 {
        return Cartesian4(x: abs(x), y: abs(y), z: abs(z), w: abs(w))
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
    func lerp(end: Cartesian4, t: Double) -> Cartesian4 {
        return multiplyByScalar(1.0 - t).add(end.multiplyByScalar(t));
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
                    result = Cartesian4.unitX()
                } else {
                    result = Cartesian4.unitW()
                }
            } else if (f.z <= f.w) {
                result = Cartesian4.unitZ()
            } else {
                result = Cartesian4.unitW()
            }
        } else if (f.y <= f.z) {
            if (f.y <= f.w) {
                result = Cartesian4.unitY()
            } else {
                result = Cartesian4.unitW()
            }
        } else if (f.z <= f.w) {
            result = Cartesian4.unitZ()
        } else {
            result = Cartesian4.unitW()
        }
        return result;
    }
    
    func equalsArray (array: [Float], offset: Int) -> Bool {
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
    func equalsEpsilon(other: Cartesian4, relativeEpsilon: Double, absoluteEpsilon: Double) -> Bool {
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
    static func zero() -> Cartesian4 {
        return Cartesian4(x: 0.0, y: 0.0, z: 0.0, w: 0.0)
    }
    /**
    * An immutable Cartesian4 instance initialized to (1.0, 0.0, 0.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static func unitX() -> Cartesian4 {
        return Cartesian4(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
    }
    /**
    * An immutable Cartesian4 instance initialized to (0.0, 1.0, 0.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static func unitY() -> Cartesian4 {
        return Cartesian4(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
    }
    /**
    * An immutable Cartesian4 instance initialized to (0.0, 0.0, 1.0, 0.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static func unitZ() -> Cartesian4 {
        return Cartesian4(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
    }
    
    /**
    * An immutable Cartesian4 instance initialized to (0.0, 0.0, 0.0, 1.0).
    *
    * @type {Cartesian4}
    * @constant
    */
    static func unitW() -> Cartesian4 {
        return Cartesian4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
    }
}



/**
* Compares the provided Cartesians componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {Cartesian4} [left] The first Cartesian.
* @param {Cartesian4} [right] The second Cartesian.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
public func == (left: Cartesian4, right: Cartesian4) -> Bool {
    return (left.x == right.x &&
        left.y == right.y &&
        left.z == right.z &&
        left.w == right.w)
}


