//
//  Matrix2.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/03/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
 * A 2x2 matrix, indexable as a column-major order array.
 * Constructor parameters are in row-major order for code readability.
 * @alias Matrix2
 * @constructor
 *
 * @param {Number} [column0Row0=0.0] The value for column 0, row 0.
 * @param {Number} [column1Row0=0.0] The value for column 1, row 0.
 * @param {Number} [column0Row1=0.0] The value for column 0, row 1.
 * @param {Number} [column1Row1=0.0] The value for column 1, row 1.
 *
 * @see Matrix2.fromColumnMajorArray
 * @see Matrix2.fromRowMajorArray
 * @see Matrix2.fromScale
 * @see Matrix2.fromUniformScale
 * @see Matrix3
 * @see Matrix4
 */
public struct Matrix2 {
    
    fileprivate (set) internal var simdType: double2x2
    
    var floatRepresentation: float2x2 {
        return float2x2([
            vector_float(simdType[0]),
            vector_float(simdType[1]),
        ])
    }
    
    public init(
        _ column0Row0: Double, _ column1Row0: Double,
        _ column0Row1: Double, _ column1Row1: Double) {
        
        simdType = double2x2(rows: [
            double2(column0Row0, column1Row0),
            double2(column0Row1, column1Row1)
        ])
    }
    
    public init (fromSIMD simd: double2x2) {
        simdType = simd
    }
/*

    
    /**
    * Creates a Matrix2 instance from a row-major order array.
    * The resulting matrix will be in column-major order.
    *
    * @param {Number[]} values The row-major order array.
    * @param {Matrix2} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns {Matrix2} The modified result parameter, or a new Matrix2 instance if one was not provided.
    */
    Matrix2.fromRowMajorArray = function(values, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(values)) {
    throw new DeveloperError('values is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix2(values[0], values[1],
    values[2], values[3]);
    }
    result[0] = values[0];
    result[1] = values[2];
    result[2] = values[1];
    result[3] = values[3];
    return result;
    };
    
    /**
    * Computes a Matrix2 instance representing a non-uniform scale.
    *
    * @param {Cartesian2} scale The x and y scale factors.
    * @param {Matrix2} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns {Matrix2} The modified result parameter, or a new Matrix2 instance if one was not provided.
    *
    * @example
    * // Creates
    * //   [7.0, 0.0]
    * //   [0.0, 8.0]
    * var m = Cesium.Matrix2.fromScale(new Cesium.Cartesian2(7.0, 8.0));
    */
    Matrix2.fromScale = function(scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(scale)) {
    throw new DeveloperError('scale is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix2(
    scale.x, 0.0,
    0.0,     scale.y);
    }
    
    result[0] = scale.x;
    result[1] = 0.0;
    result[2] = 0.0;
    result[3] = scale.y;
    return result;
    };
    
    /**
    * Computes a Matrix2 instance representing a uniform scale.
    *
    * @param {Number} scale The uniform scale factor.
    * @param {Matrix2} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns {Matrix2} The modified result parameter, or a new Matrix2 instance if one was not provided.
    *
    * @example
    * // Creates
    * //   [2.0, 0.0]
    * //   [0.0, 2.0]
    * var m = Cesium.Matrix2.fromUniformScale(2.0);
    */
    Matrix2.fromUniformScale = function(scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof scale !== 'number') {
    throw new DeveloperError('scale is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix2(
    scale, 0.0,
    0.0,   scale);
    }
    
    result[0] = scale;
    result[1] = 0.0;
    result[2] = 0.0;
    result[3] = scale;
    return result;
    };
    
    /**
    * Creates a rotation matrix.
    *
    * @param {Number} angle The angle, in radians, of the rotation.  Positive angles are counterclockwise.
    * @param {Matrix2} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns {Matrix2} The modified result parameter, or a new Matrix2 instance if one was not provided.
    *
    * @example
    * // Rotate a point 45 degrees counterclockwise.
    * var p = new Cesium.Cartesian2(5, 6);
    * var m = Cesium.Matrix2.fromRotation(Cesium.Math.toRadians(45.0));
    * var rotated = Cesium.Matrix2.multiplyByVector(m, p, new Cesium.Cartesian2());
    */
    Matrix2.fromRotation = function(angle, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(angle)) {
    throw new DeveloperError('angle is required.');
    }
    //>>includeEnd('debug');
    
    var cosAngle = Math.cos(angle);
    var sinAngle = Math.sin(angle);
    
    if (!defined(result)) {
    return new Matrix2(
    cosAngle, -sinAngle,
    sinAngle, cosAngle);
    }
    result[0] = cosAngle;
    result[1] = sinAngle;
    result[2] = -sinAngle;
    result[3] = cosAngle;
    return result;
    };
     
    /**
    * Retrieves a copy of the matrix column at the provided index as a Cartesian2 instance.
    *
    * @param {Matrix2} matrix The matrix to use.
    * @param {Number} index The zero-based index of the column to retrieve.
    * @param {Cartesian2} result The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0 or 1.
    */
    Matrix2.getColumn = function(matrix, index, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required.');
    }
    if (typeof index !== 'number' || index < 0 || index > 1) {
    throw new DeveloperError('index must be 0 or 1.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    var startIndex = index * 2;
    var x = matrix[startIndex];
    var y = matrix[startIndex + 1];
    
    result.x = x;
    result.y = y;
    return result;
    };
    
    /**
    * Computes a new matrix that replaces the specified column in the provided matrix with the provided Cartesian2 instance.
    *
    * @param {Matrix2} matrix The matrix to use.
    * @param {Number} index The zero-based index of the column to set.
    * @param {Cartesian2} cartesian The Cartesian whose values will be assigned to the specified column.
    * @param {Cartesian2} result The object onto which to store the result.
    * @returns {Matrix2} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0 or 1.
    */
    Matrix2.setColumn = function(matrix, index, cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required');
    }
    if (typeof index !== 'number' || index < 0 || index > 1) {
    throw new DeveloperError('index must be 0 or 1.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    result = Matrix2.clone(matrix, result);
    var startIndex = index * 2;
    result[startIndex] = cartesian.x;
    result[startIndex + 1] = cartesian.y;
    return result;
    };
    
    /**
    * Retrieves a copy of the matrix row at the provided index as a Cartesian2 instance.
    *
    * @param {Matrix2} matrix The matrix to use.
    * @param {Number} index The zero-based index of the row to retrieve.
    * @param {Cartesian2} result The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0 or 1.
    */
    Matrix2.getRow = function(matrix, index, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required.');
    }
    if (typeof index !== 'number' || index < 0 || index > 1) {
    throw new DeveloperError('index must be 0 or 1.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    var x = matrix[index];
    var y = matrix[index + 2];
    
    result.x = x;
    result.y = y;
    return result;
    };
    
    /**
    * Computes a new matrix that replaces the specified row in the provided matrix with the provided Cartesian2 instance.
    *
    * @param {Matrix2} matrix The matrix to use.
    * @param {Number} index The zero-based index of the row to set.
    * @param {Cartesian2} cartesian The Cartesian whose values will be assigned to the specified row.
    * @param {Matrix2} result The object onto which to store the result.
    * @returns {Matrix2} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0 or 1.
    */
    Matrix2.setRow = function(matrix, index, cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required');
    }
    if (typeof index !== 'number' || index < 0 || index > 1) {
    throw new DeveloperError('index must be 0 or 1.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    result = Matrix2.clone(matrix, result);
    result[index] = cartesian.x;
    result[index + 2] = cartesian.y;
    return result;
    };
    
    var scratchColumn = new Cartesian2();
    
    /**
    * Extracts the non-uniform scale assuming the matrix is an affine transformation.
    *
    * @param {Matrix2} matrix The matrix.
    * @param {Cartesian2} result The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter.
    */
    Matrix2.getScale = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    result.x = Cartesian2.magnitude(Cartesian2.fromElements(matrix[0], matrix[1], scratchColumn));
    result.y = Cartesian2.magnitude(Cartesian2.fromElements(matrix[2], matrix[3], scratchColumn));
    return result;
    };
    
    var scratchScale = new Cartesian2();
    
    /**
    * Computes the maximum scale assuming the matrix is an affine transformation.
    * The maximum scale is the maximum length of the column vectors.
    *
    * @param {Matrix2} matrix The matrix.
    * @returns {Number} The maximum scale.
    */
    Matrix2.getMaximumScale = function(matrix) {
    Matrix2.getScale(matrix, scratchScale);
    return Cartesian2.maximumComponent(scratchScale);
    };
     
    /**
    * Computes the product of a matrix times a (non-uniform) scale, as if the scale were a scale matrix.
    *
    * @param {Matrix2} matrix The matrix on the left-hand side.
    * @param {Cartesian2} scale The non-uniform scale on the right-hand side.
    * @param {Matrix2} result The object onto which to store the result.
    * @returns {Matrix2} The modified result parameter.
    *
    * @see Matrix2.fromScale
    * @see Matrix2.multiplyByUniformScale
    *
    * @example
    * // Instead of Cesium.Matrix2.multiply(m, Cesium.Matrix2.fromScale(scale), m);
    * Cesium.Matrix2.multiplyByScale(m, scale, m);
    */
    Matrix2.multiplyByScale = function(matrix, scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(scale)) {
    throw new DeveloperError('scale is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    result[0] = matrix[0] * scale.x;
    result[1] = matrix[1] * scale.x;
    result[2] = matrix[2] * scale.y;
    result[3] = matrix[3] * scale.y;
    return result;
    };
        
    /**
    * Computes the transpose of the provided matrix.
    *
    * @param {Matrix2} matrix The matrix to transpose.
    * @param {Matrix2} result The object onto which to store the result.
    * @returns {Matrix2} The modified result parameter.
    */
    Matrix2.transpose = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    var column0Row0 = matrix[0];
    var column0Row1 = matrix[2];
    var column1Row0 = matrix[1];
    var column1Row1 = matrix[3];
    
    result[0] = column0Row0;
    result[1] = column0Row1;
    result[2] = column1Row0;
    result[3] = column1Row1;
    return result;
    };
    
    /**
    * Computes a matrix, which contains the absolute (unsigned) values of the provided matrix's elements.
    *
    * @param {Matrix2} matrix The matrix with signed elements.
    * @param {Matrix2} result The object onto which to store the result.
    * @returns {Matrix2} The modified result parameter.
    */
    Matrix2.abs = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required');
    }
    //>>includeEnd('debug');
    
    result[0] = Math.abs(matrix[0]);
    result[1] = Math.abs(matrix[1]);
    result[2] = Math.abs(matrix[2]);
    result[3] = Math.abs(matrix[3]);
    
    return result;
    };
    */
    /**
    * Computes the product of two matrices.
    *
    * @param {MatrixType} self The first matrix.
    * @param {MatrixType} other The second matrix.
    * @returns {MatrixType} The modified result parameter.
    */
    func multiply(_ other: Matrix2) -> Matrix2 {
        return Matrix2(fromSIMD: simdType * other.simdType)
    }
    
    func negate() -> Matrix2 {
        return Matrix2(fromSIMD: -simdType)
    }
    
    /**
    * Compares this matrix to the provided matrix componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {MatrixType} [right] The right hand side matrix.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    func equals(_ other: Matrix2) -> Bool {
        return matrix_equal(simdType.cmatrix, other.simdType.cmatrix)
        //return matrix_equal(simdType, other.simdType)
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
    func equalsEpsilon(_ other: Matrix2, epsilon: Double) -> Bool {
        return matrix_almost_equal_elements(simdType.cmatrix, other.simdType.cmatrix, epsilon)
    }
/*
    
    /**
    * @private
    */
    Matrix2.equalsArray = function(matrix, array, offset) {
    return matrix[0] === array[offset] &&
    matrix[1] === array[offset + 1] &&
    matrix[2] === array[offset + 2] &&
    matrix[3] === array[offset + 3];
    };
    
    /**
    * Compares the provided matrices componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    *
    * @param {Matrix2} [left] The first matrix.
    * @param {Matrix2} [right] The second matrix.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    Matrix2.equalsEpsilon = function(left, right, epsilon) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof epsilon !== 'number') {
    throw new DeveloperError('epsilon must be a number');
    }
    //>>includeEnd('debug');
    
    return (left === right) ||
    (defined(left) &&
    defined(right) &&
    Math.abs(left[0] - right[0]) <= epsilon &&
    Math.abs(left[1] - right[1]) <= epsilon &&
    Math.abs(left[2] - right[2]) <= epsilon &&
    Math.abs(left[3] - right[3]) <= epsilon);
    };
    
    /**
    * An immutable Matrix2 instance initialized to the identity matrix.
    *
    * @type {Matrix2}
    * @constant
    */
    Matrix2.IDENTITY = freezeObject(new Matrix2(1.0, 0.0,
    0.0, 1.0));
    
    /**
    * An immutable Matrix2 instance initialized to the zero matrix.
    *
    * @type {Matrix2}
    * @constant
    */
    Matrix2.ZERO = freezeObject(new Matrix2(0.0, 0.0,
    0.0, 0.0));

        /**
    * Compares this matrix to the provided matrix componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {Matrix2} [right] The right hand side matrix.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    Matrix2.prototype.equals = function(right) {
    return Matrix2.equals(this, right);
    };
    
    /**
    * Compares this matrix to the provided matrix componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    *
    * @param {Matrix2} [right] The right hand side matrix.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if they are within the provided epsilon, <code>false</code> otherwise.
    */
    Matrix2.prototype.equalsEpsilon = function(right, epsilon) {
    return Matrix2.equalsEpsilon(this, right, epsilon);
    };
    
    /**
    * Creates a string representing this Matrix with each row being
    * on a separate line and in the format '(column0, column1)'.
    *
    * @returns {String} A string representing the provided Matrix with each row being on a separate line and in the format '(column0, column1)'.
    */
    Matrix2.prototype.toString = function() {
    return '(' + this[0] + ', ' + this[2] + ')\n' +
    '(' + this[1] + ', ' + this[3] + ')';
    };
    
    return Matrix2;
    });


*/
}

extension Matrix2: Packable {
    
    var length: Int {
        return Matrix2.packedLength()
    }
    
    public static func packedLength() -> Int {
        return 4
    }
    
    /**
     * Creates a Matrix3 from 9 consecutive elements in an array.
     *
     * @param {Number[]} array The array whose 9 consecutive elements correspond to the positions of the matrix.  Assumes column-major order.
     * @param {Number} [startingIndex=0] The offset into the array of the first element, which corresponds to first column first row position in the matrix.
     * @param {Matrix3} [result] The object onto which to store the result.
     * @returns {Matrix3} The modified result parameter or a new Matrix3 instance if one was not provided.
     *
     * @example
     * // Create the Matrix3:
     * // [1.0, 2.0, 3.0]
     * // [1.0, 2.0, 3.0]
     * // [1.0, 2.0, 3.0]
     *
     * var v = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0];
     * var m = Cesium.Matrix3.fromArray(v);
     *
     * // Create same Matrix3 with using an offset into an array
     * var v2 = [0.0, 0.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0];
     * var m2 = Cesium.Matrix3.fromArray(v2, 2);
     */
    init (array: [Double], startingIndex: Int = 0) {
        self.init(
            array[startingIndex+0], array[startingIndex+2],
            array[startingIndex+1], array[startingIndex+3]
        )
    }
    
    func toArray() -> [Double] {
        let col0 = simdType[0]
        let col1 = simdType[1]
        return [
            col0.x, col0.y,
            col1.x, col1.y
        ]
    }
    
}

extension Matrix2: Equatable {}

public func == (left: Matrix2, right: Matrix2) -> Bool {
    return left.equals(right)
}


