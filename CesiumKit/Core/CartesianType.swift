//
//  CartesianType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import simd

/*protocol CartArithmeticType {}

extension Cartesian2: CartArithmeticType {}
extension Cartesian3: CartArithmeticType {}
extension Cartesian4: CartArithmeticType {}*/

protocol CartesianType {
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Double) -> Self
    prefix func -(cartesian: Self) -> Self
    
    func dot(other: Self) -> Double
    func multiplyComponents(other: Self) -> Self
    
    func multiplyByScalar(scalar: Double) -> Self
    func divideByScalar(scalar: Double) -> Cartesian3
    
    func add(other: Self) -> Self
    func subtract(other: Self) -> Self
    
    func negate() -> Self
}

extension CartesianType {
    
    /**
     * Computes the componentwise product of two Cartesians.
     *
     * @param {Cartesian3} left The first Cartesian.
     * @param {Cartesian3} right The second Cartesian.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
     */
    func multiplyComponents(other: Self) -> Self {
        return self * other
    }
    
    /**
     * Multiplies the provided Cartesian componentwise by the provided scalar.
     *
     * @param {Cartesian3} cartesian The Cartesian to be scaled.
     * @param {Number} scalar The scalar to multiply with.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
     */
    func multiplyByScalar(scalar: Double) -> Self {
        return self * scalar
    }
    
    /**
     * Divides the provided Cartesian componentwise by the provided scalar.
     *
     * @param {Cartesian3} cartesian The Cartesian to be divided.
     * @param {Number} scalar The scalar to divide by.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
     */
    func divideByScalar(scalar: Double) -> Self {
        return multiplyByScalar(1.0/scalar)
    }
    
    /**
     * Computes the componentwise sum of two Cartesians.
     *
     * @param {Cartesian3} left The first Cartesian.
     * @param {Cartesian3} right The second Cartesian.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
     */
    func add(other: Self) -> Self {
        return self + other
    }
    
    /**
     * Computes the componentwise difference of two Cartesians.
     *
     * @param {Cartesian3} left The first Cartesian.
     * @param {Cartesian3} right The second Cartesian.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
     */
    func subtract(other: Self) -> Self {
        return self - other
    }
    
    /**
     * Negates the provided Cartesian.
     *
     * @param {Cartesian3} cartesian The Cartesian to be negated.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
     */
    func negate() -> Self {
        return -self
    }
    
    
}