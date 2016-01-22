//
//  Matrix.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

protocol MatrixType {
    func equalsEpsilon<T where T: Packable, T: Equatable>(other: T, epsilon: Double) -> Bool
}

extension MatrixType {
    
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
    func equalsEpsilon<T where T: Packable, T: Equatable>(other: T, epsilon: Double) -> Bool {
        /*if self == other {
            return true
        }*/
        let selfArray = (self as! Packable).toArray()
        let otherArray = other.toArray()
        
        for i in selfArray.indices {
            if abs(selfArray[i] - otherArray[i]) > epsilon {
                return false
            }
        }
        return true
    }
}