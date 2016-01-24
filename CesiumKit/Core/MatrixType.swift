//
//  Matrix.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

protocol MatrixType {
    
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self

    // Negate
    prefix func -(matrix: Self) -> Self
        
    func equals(other: Self) -> Bool

    func equalsEpsilon(other: Self, epsilon: Double) -> Bool
    
    func multiply (other: Self) -> Self
    
}

protocol ArithmeticType {}

extension Matrix2 : ArithmeticType {}
extension Matrix3 : ArithmeticType {}
extension Matrix4 : ArithmeticType {}

extension MatrixType {
    
    /**
     * Computes the product of two matrices.
     *
     * @param {MatrixType} self The first matrix.
     * @param {MatrixType} other The second matrix.
     * @returns {MatrixType} The modified result parameter.
     */
    func multiply(other: Self) -> Self {
        return self * other
    }
    
    func negate() -> Self {
        return -self
    }

    /**
     * Compares this matrix to the provided matrix componentwise and returns
     * <code>true</code> if they are equal, <code>false</code> otherwise.
     *
     * @param {MatrixType} [right] The right hand side matrix.
     * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
     */
    func equals(other: Self) -> Bool {
        return memcmp([self], [other], sizeof(Self)) == 0
    }
    
    /**
     * Compares the provided matrices componentwise and returns
     * <code>true</code> if they are within the provided epsilon,
     * <code>false</code> otherwise.
     *
     * @param {MatrixType} [left] The first matrix.
     * @param {MatrixType} [right] The second matrix.
     * @param {Number} epsilon The epsilon to use for equality testing.
     * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
     */
    func equalsEpsilon(other: Self, epsilon: Double) -> Bool {
        if self.equals(other) {
            return true
        }
        let selfArray = (self as! Packable).toArray()
        let otherArray = (other as! Packable).toArray()
        
        for i in selfArray.indices {
            if abs(selfArray[i] - otherArray[i]) > epsilon {
                return false
            }
        }
        return true
    }
}