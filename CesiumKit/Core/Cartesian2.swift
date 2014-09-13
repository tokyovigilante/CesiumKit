//
//  Cartesian2.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A 2D Cartesian point.
* @alias Cartesian2
* @constructor
*
* @param {Number} [x=0.0] The X component.
* @param {Number} [y=0.0] The Y component.
*
* @see Cartesian3
* @see Cartesian4
* @see Packable
*/
struct Cartesian2: Packable, Equatable {
    /**
    * The Y component.
    * @type {Number}
    * @default 0.0
    */
    var x: Double = 0.0
    
    /**
    * The X component.
    * @type {Number}
    * @default 0.0
    */
    var y: Double = 0.0
    
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    //static let packedLength: Int = 2
    
    init(x: Double = 0.0, y: Double = 0.0) {
        self.x = x
        self.y = y
    }
    
    /**
    * Creates a Cartesian2 instance from an existing Cartesian3.  This simply takes the
    * x and y properties of the Cartesian3 and drops z.
    * @function
    *
    * @param {Cartesian3} cartesian The Cartesian3 instance to create a Cartesian2 instance from.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    init(fromCartesian3 cartesian3: Cartesian3) {
        x = cartesian3.x
        y = cartesian3.y
    }
    
    /**
    * Creates a Cartesian2 instance from an existing Cartesian4.  This simply takes the
    * x and y properties of the Cartesian4 and drops z and w.
    * @function
    *
    * @param {Cartesian4} cartesian The Cartesian4 instance to create a Cartesian2 instance from.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    init(fromCartesian4 cartesian4: Cartesian4) {
        x = cartesian4.x
        y = cartesian4.y
    }
    
    /**
    * Stores the provided instance into the provided array.
    *
    * @param {Cartesian2} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    func pack(inout array: [ComponentDatatype], startingIndex: Int = 0) {
        
        if array.count < startingIndex - 2 {//Int(Cartesian2.packedLength) {
            array.append(ComponentDatatype.Float(Float(x)))
            array.append(ComponentDatatype.Float(Float(y)))
        }
        else {
            array[startingIndex] = ComponentDatatype.Float(Float(x))
            array[startingIndex+1] = ComponentDatatype.Float(Float(y))

        }
    }
    
    
    
    /**
    * Retrieves an instance from a packed array.
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Cartesian2} [result] The object into which to store the result.
    */
    static func unpack(array: [ComponentDatatype], startingIndex: Int = 0) -> Cartesian2 {
        assert((startingIndex + /*Cartesian2.packedLength*/2 <= array.count), "Invalid starting index")
        var x = 0.0, y = 0.0
        switch array[startingIndex] {
        case .Float(let component):
            x = Double(component)
        default:
            assert(false, "Invalid type")
        }
        switch array[startingIndex+1] {
        case .Float(let component):
            y = Double(component)
        default:
            assert(false, "Invalid type")
        }
        return Cartesian2(x: x, y: y)
    }
    
    /**
    * Creates a Cartesian2 from two consecutive elements in an array.
    * @function
    *
    * @param {Number[]} array The array whose two consecutive elements correspond to the x and y components, respectively.
    * @param {Number} [startingIndex=0] The offset into the array of the first element, which corresponds to the x component.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    *
    * @example
    * // Create a Cartesian2 with (1.0, 2.0)
    * var v = [1.0, 2.0];
    * var p = Cesium.Cartesian2.fromArray(v);
    *
    * // Create a Cartesian2 with (1.0, 2.0) using an offset into an array
    * var v2 = [0.0, 0.0, 1.0, 2.0];
    * var p2 = Cesium.Cartesian2.fromArray(v2, 2);
    */
    static func fromArray(array: [ComponentDatatype]) -> Packable {
        return Cartesian2.unpack(array)
    }
    
    /**
    * Computes the value of the maximum component for the supplied Cartesian.
    *
    * @param {Cartesian2} cartesian The cartesian to use.
    * @returns {Number} The value of the maximum component.
    */
    func maximumComponent() -> Double {
        return max(x, y)
    }
    
    /**
    * Computes the value of the minimum component for the supplied Cartesian.
    *
    * @param {Cartesian2} cartesian The cartesian to use.
    * @returns {Number} The value of the minimum component.
    */
    func minimumComponent() -> Double {
        return min(x, y)
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
    *
    * @param {Cartesian2} first A cartesian to compare.
    * @param {Cartesian2} second A cartesian to compare.
    * @param {Cartesian2} [result] The object into which to store the result.
    * @returns {Cartesian2} A cartesian with the minimum components.
    */
    func minimumByComponent(other: Cartesian2) -> Cartesian2 {
        return Cartesian2(x: min(x, other.x), y: min(y, other.y))
    }
    
    /**
    * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
    *
    * @param {Cartesian2} first A cartesian to compare.
    * @param {Cartesian2} second A cartesian to compare.
    * @param {Cartesian2} [result] The object into which to store the result.
    * @returns {Cartesian2} A cartesian with the maximum components.
    */
    func maximumByComponent(other: Cartesian2) -> Cartesian2 {
        return Cartesian2(x: max(x, other.x), y: max(y, other.y))
    }
    /**
    * Computes the provided Cartesian's squared magnitude.
    *
    * @param {Cartesian2} cartesian The Cartesian instance whose squared magnitude is to be computed.
    * @returns {Number} The squared magnitude.
    */
    func magnitudeSquared() -> Double {
        return x * x + y * y;
    }
    
    /**
    * Computes the Cartesian's magnitude (length).
    *
    * @param {Cartesian2} cartesian The Cartesian instance whose magnitude is to be computed.
    * @returns {Number} The magnitude.
    */
    func magnitude() -> Double {
        return sqrt(magnitudeSquared());
    }
    
    
    /**
    * Computes the distance between two points
    *
    * @param {Cartesian2} left The first point to compute the distance from.
    * @param {Cartesian2} right The second point to compute the distance to.
    * @returns {Number} The distance between two points.
    *
    * @example
    * // Returns 1.0
    * var d = Cesium.Cartesian2.distance(new Cesium.Cartesian2(1.0, 0.0), new Cesium.Cartesian2(2.0, 0.0));
    */
    func distance(other: Cartesian2) -> Double {
        return subtract(other).magnitude()
    }
    
    /**
    * Computes the normalized form of the supplied Cartesian.
    *
    * @param {Cartesian2} cartesian The Cartesian to be normalized.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func normalize() -> Cartesian2 {
        var magnitude = self.magnitude();
        return Cartesian2(x: x / magnitude, y: y / magnitude)
    }
    
    /**
    * Computes the dot (scalar) product of two Cartesians.
    *
    * @param {Cartesian2} left The first Cartesian.
    * @param {Cartesian2} right The second Cartesian.
    * @returns {Number} The dot product.
    */
    func dot(other: Cartesian2) -> Double {
        
        return x * other.x + y * other.y;
    }
    
    /**
    * Computes the componentwise product of two Cartesians.
    *
    * @param {Cartesian2} left The first Cartesian.
    * @param {Cartesian2} right The second Cartesian.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func multiplyComponents(other: Cartesian2) -> Cartesian2 {
        return Cartesian2(x: x * other.x, y: y * other.y);
    }
    
    /**
    * Computes the componentwise sum of two Cartesians.
    *
    * @param {Cartesian2} left The first Cartesian.
    * @param {Cartesian2} right The second Cartesian.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func add(other: Cartesian2) -> Cartesian2 {
        return Cartesian2(x: x + other.x, y: y + other.y);
    }
    
    /**
    * Computes the componentwise difference of two Cartesians.
    *
    * @param {Cartesian2} left The first Cartesian.
    * @param {Cartesian2} right The second Cartesian.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func subtract(other: Cartesian2) -> Cartesian2 {
        return Cartesian2(x: x - other.x, y: y - other.y);
    }
    
    /**
    * Multiplies the provided Cartesian componentwise by the provided scalar.
    *
    * @param {Cartesian2} cartesian The Cartesian to be scaled.
    * @param {Number} scalar The scalar to multiply with.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func multiplyByScalar(scalar: Double) -> Cartesian2 {
        return  Cartesian2(x: x * scalar, y: y * scalar);
    }
    
    /**
    * Divides the provided Cartesian componentwise by the provided scalar.
    *
    * @param {Cartesian2} cartesian The Cartesian to be divided.
    * @param {Number} scalar The scalar to divide by.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func divideByScalar(scalar: Double) -> Cartesian2 {
        return  Cartesian2(x: x / scalar, y: y / scalar);
    }
    
    /**
    * Negates the provided Cartesian.
    *
    * @param {Cartesian2} cartesian The Cartesian to be negated.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func negate() -> Cartesian3 {
        return Cartesian3(x: -x, y: -y)
    }
    
    /**
    * Computes the absolute value of the provided Cartesian.
    *
    * @param {Cartesian2} cartesian The Cartesian whose absolute value is to be computed.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func absolute() -> Cartesian2 {
        return Cartesian2(x: abs(x), y: abs(y))
    }
    
    /**
    * Computes the linear interpolation or extrapolation at t using the provided cartesians.
    *
    * @param {Cartesian2} start The value corresponding to t at 0.0.
    * @param {Cartesian2} end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.
    */
    func lerp(end: Cartesian2, t: Double) -> Cartesian2 {
        return multiplyByScalar(1.0 - t).add(end.multiplyByScalar(t));
    }
    
    /**
    * Returns the angle, in radians, between the provided Cartesians.
    *
    * @param {Cartesian2} left The first Cartesian.
    * @param {Cartesian2} right The second Cartesian.
    * @returns {Number} The angle between the Cartesians.
    */
    func angleBetween(other: Cartesian2) -> Double {
        return Math.acosClamped(normalize().dot(other.normalize()))
    }
    
    /**
    * Returns the axis that is most orthogonal to the provided Cartesian.
    *
    * @param {Cartesian2} cartesian The Cartesian on which to find the most orthogonal axis.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The most orthogonal axis.
    */
    func mostOrthogonalAxis() -> Cartesian2 {
        
        let f = normalize().absolute();
        var result: Cartesian2
        
        if (f.x <= f.y) {
            result = Cartesian2.unitX()
        } else {
            result = Cartesian2.unitY()
        }
        return result;
    }
    
    /**
    * Compares the provided Cartesians componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    *
    * @param {Cartesian2} [left] The first Cartesian.
    * @param {Cartesian2} [right] The second Cartesian.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    func equalsEpsilon(other: Cartesian2, epsilon: Double) -> Bool {
        return (abs(x - other.x) <= epsilon) && (abs(y - other.y) <= epsilon)
    }
    
    /**
    * An immutable Cartesian2 instance initialized to (0.0, 0.0).
    *
    * @type {Cartesian2}
    * @constant
    */
    static func zero() -> Cartesian2 {
        return Cartesian2(x: 0.0, y: 0.0)
    }
    /**
    * An immutable Cartesian2 instance initialized to (1.0, 0.0).
    *
    * @type {Cartesian2}
    * @constant
    */
    static func unitX() -> Cartesian2 {
        return Cartesian2(x: 1.0, y: 0.0)
    }
    /**
    * An immutable Cartesian2 instance initialized to (0.0, 1.0).
    *
    * @type {Cartesian2}
    * @constant
    */
    static func unitY() -> Cartesian2 {
        return Cartesian2(x: 1.0, y: 0.0)
    }
    
    /**
    * Creates a string representing this Cartesian in the format '(x, y)'.
    *
    * @returns {String} A string representing the provided Cartesian in the format '(x, y)'.
    */
    func toString() -> String {
        return "(\(x), \(y))"
    }
}

/**
* Compares the provided Cartesians componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {Cartesian2} [left] The first Cartesian.
* @param {Cartesian2} [right] The second Cartesian.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
func == (left: Cartesian2, right: Cartesian2) -> Bool {
    return (left.x == right.x) && (left.y == right.y)
}


