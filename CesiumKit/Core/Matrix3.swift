//
//  Matrix3.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 8/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
* A 3x3 matrix, indexable as a column-major order array.
* Constructor parameters are in row-major order for code readability.
* @alias Matrix3
* @constructor
*
* @param {Number} [column0Row0=0.0] The value for column 0, row 0.
* @param {Number} [column1Row0=0.0] The value for column 1, row 0.
* @param {Number} [column2Row0=0.0] The value for column 2, row 0.
* @param {Number} [column0Row1=0.0] The value for column 0, row 1.
* @param {Number} [column1Row1=0.0] The value for column 1, row 1.
* @param {Number} [column2Row1=0.0] The value for column 2, row 1.
* @param {Number} [column0Row2=0.0] The value for column 0, row 2.
* @param {Number} [column1Row2=0.0] The value for column 1, row 2.
* @param {Number} [column2Row2=0.0] The value for column 2, row 2.
*
* @see Matrix3.fromColumnMajorArray
* @see Matrix3.fromRowMajorArray
* @see Matrix3.fromQuaternion
* @see Matrix3.fromScale
* @see Matrix3.fromUniformScale
* @see Matrix2
* @see Matrix4
*/

public typealias Matrix3 = double3x3

extension Matrix3: Packable {
    
    public static func packedLength() -> Int {
        return 9
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
    init(fromArray array: [Double], startingIndex: Int = 0) {
        self.init()
        assert(checkPackedArrayLength(array, startingIndex: startingIndex), "Invalid packed array length")
        array.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Double>) in
            memcpy(&self, pointer.baseAddress, Matrix3.packedLength() * strideof(Double))
        }
    }
    
}

public extension Matrix3 {
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    
    public init(_ column0Row0: Double, _ column1Row0: Double, _ column2Row0: Double,
        _ column0Row1: Double, _ column1Row1: Double, _ column2Row1: Double,
        _ column0Row2: Double, _ column1Row2: Double, _ column2Row2: Double) {
            
            self.init(rows: [
                double3(column0Row0, column1Row0, column2Row0),
                double3(column0Row1, column1Row1, column2Row1),
                double3(column0Row2, column1Row2, column2Row2),
            ])

    }
    
    public init(grid: [Double]) {
        assert(grid.count == Matrix3.packedLength(), "invalid grid length")
        self.init(rows: [
            double3(grid[0], grid[3], grid[6]),
            double3(grid[1], grid[4], grid[7]),
            double3(grid[2], grid[5], grid[8]),
            ])
    }
    
    /**
    * Computes a 3x3 rotation matrix from the provided quaternion.
    *
    * @param {Quaternion} quaternion the quaternion to use.
    * @returns {Matrix3} The 3x3 rotation matrix from this quaternion.
    */
    public init(fromQuaternion quaternion: Quaternion) {
        
        let x2 = quaternion.x * quaternion.x
        let xy = quaternion.x * quaternion.y
        let xz = quaternion.x * quaternion.z
        let xw = quaternion.x * quaternion.w
        let y2 = quaternion.y * quaternion.y
        let yz = quaternion.y * quaternion.z
        let yw = quaternion.y * quaternion.w
        let z2 = quaternion.z * quaternion.z
        let zw = quaternion.z * quaternion.w
        let w2 = quaternion.w * quaternion.w
        
        let m00 = x2 - y2 - z2 + w2
        let m01 = 2.0 * (xy - zw)
        let m02 = 2.0 * (xz + yw)
        
        let m10 = 2.0 * (xy + zw)
        let m11 = -x2 + y2 - z2 + w2
        let m12 = 2.0 * (yz - xw)
        
        let m20 = 2.0 * (xz - yw)
        let m21 = 2.0 * (yz + xw)
        let m22 = -x2 - y2 + z2 + w2
        
        self.init(rows: [
            double3(m00, m01, m02),
            double3(m10, m11, m12),
            double3(m20, m21, m22),
            ])
    }
    
    init (fromMatrix4 matrix: Matrix4) {
        let m4col0 = matrix[0]
        let m4col1 = matrix[1]
        let m4col2 = matrix[2]
        
        self.init([
            double3(m4col0.x, m4col0.y, m4col0.z),
            double3(m4col0.w, m4col1.x, m4col1.y),
            double3(m4col1.z, m4col1.w, m4col2.x)
        ])
    }
    
    /*
    /**
    * Creates a Matrix3 instance from a column-major order array.
    *
    * @param {Number[]} values The column-major order array.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    */
    Matrix3.fromColumnMajorArray = function(values, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(values)) {
    throw new DeveloperError('values parameter is required');
    }
    //>>includeEnd('debug');
    
    return Matrix3.clone(values, result);
    };
    
    /**
    * Creates a Matrix3 instance from a row-major order array.
    * The resulting matrix will be in column-major order.
    *
    * @param {Number[]} values The row-major order array.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    */
    Matrix3.fromRowMajorArray = function(values, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(values)) {
    throw new DeveloperError('values is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix3(values[0], values[1], values[2],
    values[3], values[4], values[5],
    values[6], values[7], values[8]);
    }
    result[0] = values[0];
    result[1] = values[3];
    result[2] = values[6];
    result[3] = values[1];
    result[4] = values[4];
    result[5] = values[7];
    result[6] = values[2];
    result[7] = values[5];
    result[8] = values[8];
    return result;
    };
    
    /**
    * Computes a Matrix3 instance representing a non-uniform scale.
    *
    * @param {Cartesian3} scale The x, y, and z scale factors.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    *
    * @example
    * // Creates
    * //   [7.0, 0.0, 0.0]
    * //   [0.0, 8.0, 0.0]
    * //   [0.0, 0.0, 9.0]
    * var m = Cesium.Matrix3.fromScale(new Cesium.Cartesian3(7.0, 8.0, 9.0));
    */
    Matrix3.fromScale = function(scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(scale)) {
    throw new DeveloperError('scale is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix3(
    scale.x, 0.0,     0.0,
    0.0,     scale.y, 0.0,
    0.0,     0.0,     scale.z);
    }
    
    result[0] = scale.x;
    result[1] = 0.0;
    result[2] = 0.0;
    result[3] = 0.0;
    result[4] = scale.y;
    result[5] = 0.0;
    result[6] = 0.0;
    result[7] = 0.0;
    result[8] = scale.z;
    return result;
    };
    
    /**
    * Computes a Matrix3 instance representing a uniform scale.
    *
    * @param {Number} scale The uniform scale factor.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    *
    * @example
    * // Creates
    * //   [2.0, 0.0, 0.0]
    * //   [0.0, 2.0, 0.0]
    * //   [0.0, 0.0, 2.0]
    * var m = Cesium.Matrix3.fromUniformScale(2.0);
    */
    Matrix3.fromUniformScale = function(scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof scale !== 'number') {
    throw new DeveloperError('scale is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix3(
    scale, 0.0,   0.0,
    0.0,   scale, 0.0,
    0.0,   0.0,   scale);
    }
    
    result[0] = scale;
    result[1] = 0.0;
    result[2] = 0.0;
    result[3] = 0.0;
    result[4] = scale;
    result[5] = 0.0;
    result[6] = 0.0;
    result[7] = 0.0;
    result[8] = scale;
    return result;
    };
    
    /**
    * Computes a Matrix3 instance representing the cross product equivalent matrix of a Cartesian3 vector.
    *
    * @param {Cartesian3} the vector on the left hand side of the cross product operation.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    *
    * @example
    * // Creates
    * //   [0.0, -9.0,  8.0]
    * //   [9.0,  0.0, -7.0]
    * //   [-8.0, 7.0,  0.0]
    * var m = Cesium.Matrix3.fromCrossProduct(new Cesium.Cartesian3(7.0, 8.0, 9.0));
    */
    Matrix3.fromCrossProduct = function(vector, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(vector)) {
    throw new DeveloperError('vector is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Matrix3(
    0.0, -vector.z,  vector.y,
    vector.z,       0.0, -vector.x,
    -vector.y,  vector.x,       0.0);
    }
    
    result[0] = 0.0;
    result[1] = vector.z;
    result[2] = -vector.y;
    result[3] = -vector.z;
    result[4] = 0.0;
    result[5] = vector.x;
    result[6] = vector.y;
    result[7] = -vector.x;
    result[8] = 0.0;
    return result;
    };
    */
    /**
    * Creates a rotation matrix around the x-axis.
    *
    * @param {Number} angle The angle, in radians, of the rotation.  Positive angles are counterclockwise.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    *
    * @example
    * // Rotate a point 45 degrees counterclockwise around the x-axis.
    * var p = new Cesium.Cartesian3(5, 6, 7);
    * var m = Cesium.Matrix3.fromRotationX(Cesium.Math.toRadians(45.0));
    * var rotated = Cesium.Matrix3.multiplyByVector(m, p);
    */
    init (fromRotationX angle: Double) {
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        
        self.init(rows: [
            double3(1.0, 0.0, 0.0),
            double3(0.0, cosAngle, -sinAngle),
            double3(0.0, sinAngle, cosAngle)
            ])
    }
    
    /**
    * Creates a rotation matrix around the y-axis.
    *
    * @param {Number} angle The angle, in radians, of the rotation.  Positive angles are counterclockwise.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    *
    * @example
    * // Rotate a point 45 degrees counterclockwise around the y-axis.
    * var p = new Cesium.Cartesian3(5, 6, 7);
    * var m = Cesium.Matrix3.fromRotationY(Cesium.Math.toRadians(45.0));
    * var rotated = Cesium.Matrix3.multiplyByVector(m, p);
    */
    init (fromRotationY angle: Double) {
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        
        self.init(rows: [
            double3(cosAngle, 0.0, sinAngle),
            double3(0.0, 1.0, 0.0),
            double3(-sinAngle, 0.0, cosAngle)
        ])
    }
    
    /**
    * Creates a rotation matrix around the z-axis.
    *
    * @param {Number} angle The angle, in radians, of the rotation.  Positive angles are counterclockwise.
    * @param {Matrix3} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix3 instance if one was not provided.
    *
    * @example
    * // Rotate a point 45 degrees counterclockwise around the z-axis.
    * var p = new Cesium.Cartesian3(5, 6, 7);
    * var m = Cesium.Matrix3.fromRotationZ(Cesium.Math.toRadians(45.0));
    * var rotated = Cesium.Matrix3.multiplyByVector(m, p);
    */
    init (fromRotationZ angle: Double) {
        let cosAngle: Double = cos(angle)
        let sinAngle: Double = sin(angle)
        
        self.init(rows: [
            double3(cosAngle, -sinAngle, 0.0),
            double3(sinAngle, cosAngle, 0.0),
            double3(0.0, 0.0, 1.0)
        ])
    }
    

    
    /*
    /**
    * Computes the array index of the element at the provided row and column.
    *
    * @param {Number} row The zero-based index of the row.
    * @param {Number} column The zero-based index of the column.
    * @returns {Number} The index of the element at the provided row and column.
    *
    * @exception {DeveloperError} row must be 0, 1, or 2.
    * @exception {DeveloperError} column must be 0, 1, or 2.
    *
    * @example
    * var myMatrix = new Cesium.Matrix3();
    * var column1Row0Index = Cesium.Matrix3.getElementIndex(1, 0);
    * var column1Row0 = myMatrix[column1Row0Index]
    * myMatrix[column1Row0Index] = 10.0;
    */
    Matrix3.getElementIndex = function(column, row) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof row !== 'number' || row < 0 || row > 2) {
    throw new DeveloperError('row must be 0, 1, or 2.');
    }
    if (typeof column !== 'number' || column < 0 || column > 2) {
    throw new DeveloperError('column must be 0, 1, or 2.');
    }
    //>>includeEnd('debug');
    
    return column * 3 + row;
    };
    */
    /**
    * Retrieves a copy of the matrix column at the provided index as a Cartesian3 instance.
    *
    * @param {Matrix3} matrix The matrix to use.
    * @param {Number} index The zero-based index of the column to retrieve.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0, 1, or 2.
    */
    func column (index: Int) -> Cartesian3 {
        assert(index >= 0 && index <= 2, "index must be 0, 1, or 2.")
        //return self[index]
        var result = self[index]
        return Cartesian3(x: result.x, y: result.y, z: result.z)
    }
    
    /**
    * Computes a new matrix that replaces the specified column in the provided matrix with the provided Cartesian3 instance.
    *
    * @param {Matrix3} matrix The matrix to use.
    * @param {Number} index The zero-based index of the column to set.
    * @param {Cartesian3} cartesian The Cartesian whose values will be assigned to the specified column.
    * @returns {Matrix3} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0, 1, or 2.
    */
    func setColumn (index: Int, cartesian: Cartesian3) -> Matrix3 {
    
        assert(index >= 0 && index <= 2, "index must be 0, 1, or 2.")
        var result = self
        //result[index] = cartesian
        result[index] = double3(cartesian.x, cartesian.y, cartesian.z)
        return result
    }
    /*
    /**
    * Retrieves a copy of the matrix row at the provided index as a Cartesian3 instance.
    *
    * @param {Matrix3} matrix The matrix to use.
    * @param {Number} index The zero-based index of the row to retrieve.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0, 1, or 2.
    */
    Matrix3.getRow = function(matrix, index, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required.');
    }
    if (typeof index !== 'number' || index < 0 || index > 2) {
    throw new DeveloperError('index must be 0, 1, or 2.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    var x = matrix[index];
    var y = matrix[index + 3];
    var z = matrix[index + 6];
    
    result.x = x;
    result.y = y;
    result.z = z;
    return result;
    };
    
    /**
    * Computes a new matrix that replaces the specified row in the provided matrix with the provided Cartesian3 instance.
    *
    * @param {Matrix3} matrix The matrix to use.
    * @param {Number} index The zero-based index of the row to set.
    * @param {Cartesian3} cartesian The Cartesian whose values will be assigned to the specified row.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0, 1, or 2.
    */
    Matrix3.setRow = function(matrix, index, cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required');
    }
    if (typeof index !== 'number' || index < 0 || index > 2) {
    throw new DeveloperError('index must be 0, 1, or 2.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result = Matrix3.clone(matrix, result);
    result[index] = cartesian.x;
    result[index + 3] = cartesian.y;
    result[index + 6] = cartesian.z;
    return result;
    };
    
    var scratchColumn = new Cartesian3();
    
    /**
    * Extracts the non-uniform scale assuming the matrix is an affine transformation.
    *
    * @param {Matrix3} matrix The matrix.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter.
    */
    Matrix3.getScale = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required.');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result.x = Cartesian3.magnitude(Cartesian3.fromElements(matrix[0], matrix[1], matrix[2], scratchColumn));
    result.y = Cartesian3.magnitude(Cartesian3.fromElements(matrix[3], matrix[4], matrix[5], scratchColumn));
    result.z = Cartesian3.magnitude(Cartesian3.fromElements(matrix[6], matrix[7], matrix[8], scratchColumn));
    return result;
    };
    
    var scratchScale = new Cartesian3();
    
    /**
    * Computes the maximum scale assuming the matrix is an affine transformation.
    * The maximum scale is the maximum length of the column vectors.
    *
    * @param {Matrix3} matrix The matrix.
    * @returns {Number} The maximum scale.
    */
    Matrix3.getMaximumScale = function(matrix) {
    Matrix3.getScale(matrix, scratchScale);
    return Cartesian3.maximumComponent(scratchScale);
    };
    */
    /**
    * Computes the product of two matrices.
    *
    * @param {Matrix3} left The first matrix.
    * @param {Matrix3} right The second matrix.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    func multiply (other: Matrix3) -> Matrix3 {
        return self * other
    }
    /*
    /**
    * Computes the sum of two matrices.
    *
    * @param {Matrix3} left The first matrix.
    * @param {Matrix3} right The second matrix.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    Matrix3.add = function(left, right, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(left)) {
    throw new DeveloperError('left is required');
    }
    if (!defined(right)) {
    throw new DeveloperError('right is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result[0] = left[0] + right[0];
    result[1] = left[1] + right[1];
    result[2] = left[2] + right[2];
    result[3] = left[3] + right[3];
    result[4] = left[4] + right[4];
    result[5] = left[5] + right[5];
    result[6] = left[6] + right[6];
    result[7] = left[7] + right[7];
    result[8] = left[8] + right[8];
    return result;
    };
    
    /**
    * Computes the difference of two matrices.
    *
    * @param {Matrix3} left The first matrix.
    * @param {Matrix3} right The second matrix.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    Matrix3.subtract = function(left, right, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(left)) {
    throw new DeveloperError('left is required');
    }
    if (!defined(right)) {
    throw new DeveloperError('right is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result[0] = left[0] - right[0];
    result[1] = left[1] - right[1];
    result[2] = left[2] - right[2];
    result[3] = left[3] - right[3];
    result[4] = left[4] - right[4];
    result[5] = left[5] - right[5];
    result[6] = left[6] - right[6];
    result[7] = left[7] - right[7];
    result[8] = left[8] - right[8];
    return result;
    };
    */
    /**
    * Computes the product of a matrix and a column vector.
    *
    * @param {Matrix3} matrix The matrix.
    * @param {Cartesian3} cartesian The column.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter.
    */
    public func multiplyByVector (cartesian: Cartesian3) -> Cartesian3 {
        //return self * cartesian
        let result = self * double3(cartesian.x, cartesian.y, cartesian.z)
        return Cartesian3(x: result.x, y: result.y, z: result.z)
    }
    /*
    /**
    * Computes the product of a matrix and a scalar.
    *
    * @param {Matrix3} matrix The matrix.
    * @param {Number} scalar The number to multiply by.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    Matrix3.multiplyByScalar = function(matrix, scalar, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (typeof scalar !== 'number') {
    throw new DeveloperError('scalar must be a number');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result[0] = matrix[0] * scalar;
    result[1] = matrix[1] * scalar;
    result[2] = matrix[2] * scalar;
    result[3] = matrix[3] * scalar;
    result[4] = matrix[4] * scalar;
    result[5] = matrix[5] * scalar;
    result[6] = matrix[6] * scalar;
    result[7] = matrix[7] * scalar;
    result[8] = matrix[8] * scalar;
    return result;
    };
    */
    /**
    * Computes the product of a matrix times a (non-uniform) scale, as if the scale were a scale matrix.
    *
    * @param {Matrix3} matrix The matrix on the left-hand side.
    * @param {Cartesian3} scale The non-uniform scale on the right-hand side.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    *
    * @see Matrix3.fromScale
    * @see Matrix3.multiplyByUniformScale
    *
    * @example
    * // Instead of Cesium.Matrix3.multiply(m, Cesium.Matrix3.fromScale(scale), m);
    * Cesium.Matrix3.multiplyByScale(m, scale, m);
    */
    func multiplyByScale (scale: Cartesian3) -> Matrix3 {
        let packedLength = Matrix3.packedLength()
        var grid = [Double](count: packedLength, repeatedValue: 0.0)
        grid.withUnsafeMutableBufferPointer { (inout pointer: UnsafeMutableBufferPointer<Double>) in
            memcpy(pointer.baseAddress, [self], packedLength * strideof(Double))
        }
        grid[0] = grid[0] * scale.x
        grid[1] = grid[1] * scale.x
        grid[2] = grid[2] * scale.x
        grid[3] = grid[3] * scale.y
        grid[4] = grid[4] * scale.y
        grid[5] = grid[5] * scale.y
        grid[6] = grid[6] * scale.z
        grid[7] = grid[7] * scale.z
        grid[8] = grid[8] * scale.z
        return Matrix3(fromArray: grid)
    }
    /*
    /**
    * Creates a negated copy of the provided matrix.
    *
    * @param {Matrix3} matrix The matrix to negate.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    Matrix3.negate = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result[0] = -matrix[0];
    result[1] = -matrix[1];
    result[2] = -matrix[2];
    result[3] = -matrix[3];
    result[4] = -matrix[4];
    result[5] = -matrix[5];
    result[6] = -matrix[6];
    result[7] = -matrix[7];
    result[8] = -matrix[8];
    return result;
    };
    */
    /**
    * Computes the transpose of the provided matrix.
    *
    * @param {Matrix3} matrix The matrix to transpose.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    /*var transpose -> Matrix3 {
        return self.transpose
        /*return Matrix3(
            _grid[0], _grid[1], _grid[2],
            _grid[3], _grid[4], _grid[5],
            _grid[6], _grid[7], _grid[8])*/
    }*/
    /*
    function computeFrobeniusNorm(matrix) {
    var norm = 0.0;
    for (var i = 0; i < 9; ++i) {
    var temp = matrix[i];
    norm += temp * temp;
    }
    
    return Math.sqrt(norm);
    }
    
    var rowVal = [1, 0, 0];
    var colVal = [2, 2, 1];
    
    function offDiagonalFrobeniusNorm(matrix) {
    // Computes the "off-diagonal" Frobenius norm.
    // Assumes matrix is symmetric.
    
    var norm = 0.0;
    for (var i = 0; i < 3; ++i) {
    var temp = matrix[Matrix3.getElementIndex(colVal[i], rowVal[i])];
    norm += 2.0 * temp * temp;
    }
    
    return Math.sqrt(norm);
    }
    
    function shurDecomposition(matrix, result) {
    // This routine was created based upon Matrix Computations, 3rd ed., by Golub and Van Loan,
    // section 8.4.2 The 2by2 Symmetric Schur Decomposition.
    //
    // The routine takes a matrix, which is assumed to be symmetric, and
    // finds the largest off-diagonal term, and then creates
    // a matrix (result) which can be used to help reduce it
    
    var tolerance = CesiumMath.EPSILON15;
    
    var maxDiagonal = 0.0;
    var rotAxis = 1;
    
    // find pivot (rotAxis) based on max diagonal of matrix
    for (var i = 0; i < 3; ++i) {
    var temp = Math.abs(matrix[Matrix3.getElementIndex(colVal[i], rowVal[i])]);
    if (temp > maxDiagonal) {
    rotAxis = i;
    maxDiagonal = temp;
    }
    }
    
    var c = 1.0;
    var s = 0.0;
    
    var p = rowVal[rotAxis];
    var q = colVal[rotAxis];
    
    if (Math.abs(matrix[Matrix3.getElementIndex(q, p)]) > tolerance) {
    var qq = matrix[Matrix3.getElementIndex(q, q)];
    var pp = matrix[Matrix3.getElementIndex(p, p)];
    var qp = matrix[Matrix3.getElementIndex(q, p)];
    
    var tau = (qq - pp) / 2.0 / qp;
    var t;
    
    if (tau < 0.0) {
    t = -1.0 / (-tau + Math.sqrt(1.0 + tau * tau));
    } else {
    t = 1.0 / (tau + Math.sqrt(1.0 + tau * tau));
    }
    
    c = 1.0 / Math.sqrt(1.0 + t * t);
    s = t * c;
    }
    
    result = Matrix3.clone(Matrix3.IDENTITY, result);
    
    result[Matrix3.getElementIndex(p, p)] = result[Matrix3.getElementIndex(q, q)] = c;
    result[Matrix3.getElementIndex(q, p)] = s;
    result[Matrix3.getElementIndex(p, q)] = -s;
    
    return result;
    }
    
    var jMatrix = new Matrix3();
    var jMatrixTranspose = new Matrix3();
    
    /**
    * Computes the eigenvectors and eigenvalues of a symmetric matrix.
    * <p>
    * Returns a diagonal matrix and unitary matrix such that:
    * <code>matrix = unitary matrix * diagonal matrix * transpose(unitary matrix)</code>
    * </p>
    * <p>
    * The values along the diagonal of the diagonal matrix are the eigenvalues. The columns
    * of the unitary matrix are the corresponding eigenvectors.
    * </p>
    *
    * @param {Matrix3} matrix The matrix to decompose into diagonal and unitary matrix. Expected to be symmetric.
    * @param {Object} [result] An object with unitary and diagonal properties which are matrices onto which to store the result.
    * @returns {Object} An object with unitary and diagonal properties which are the unitary and diagonal matrices, respectively.
    *
    * @example
    * var a = //... symetric matrix
    * var result = {
    *     unitary : new Cesium.Matrix3(),
    *     diagonal : new Cesium.Matrix3()
    * };
    * Cesium.Matrix3.computeEigenDecomposition(a, result);
    *
    * var unitaryTranspose = Cesium.Matrix3.transpose(result.unitary);
    * var b = Cesium.Matrix3.multiply(result.unitary, result.diagonal);
    * Cesium.Matrix3.multiply(b, unitaryTranspose, b); // b is now equal to a
    *
    * var lambda = Cesium.Matrix3.getColumn(result.diagonal, 0).x;  // first eigenvalue
    * var v = Cesium.Matrix3.getColumn(result.unitary, 0);          // first eigenvector
    * var c = Cesium.Cartesian3.multiplyByScalar(v, lambda, new Cartesian3());        // equal to Cesium.Matrix3.multiplyByVector(a, v)
    */
    Matrix3.computeEigenDecomposition = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required.');
    }
    //>>includeEnd('debug');
    
    // This routine was created based upon Matrix Computations, 3rd ed., by Golub and Van Loan,
    // section 8.4.3 The Classical Jacobi Algorithm
    
    var tolerance = CesiumMath.EPSILON20;
    var maxSweeps = 10;
    
    var count = 0;
    var sweep = 0;
    
    if (!defined(result)) {
    result = {};
    }
    
    var unitaryMatrix = result.unitary = Matrix3.clone(Matrix3.IDENTITY, result.unitary);
    var diagMatrix = result.diagonal = Matrix3.clone(matrix, result.diagonal);
    
    var epsilon = tolerance * computeFrobeniusNorm(diagMatrix);
    
    while (sweep < maxSweeps && offDiagonalFrobeniusNorm(diagMatrix) > epsilon) {
    shurDecomposition(diagMatrix, jMatrix);
    Matrix3.transpose(jMatrix, jMatrixTranspose);
    Matrix3.multiply(diagMatrix, jMatrix, diagMatrix);
    Matrix3.multiply(jMatrixTranspose, diagMatrix, diagMatrix);
    Matrix3.multiply(unitaryMatrix, jMatrix, unitaryMatrix);
    
    if (++count > 2) {
    ++sweep;
    count = 0;
    }
    }
    
    return result;
    };
    
    /**
    * Computes a matrix, which contains the absolute (unsigned) values of the provided matrix's elements.
    *
    * @param {Matrix3} matrix The matrix with signed elements.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    */
    Matrix3.abs = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result[0] = Math.abs(matrix[0]);
    result[1] = Math.abs(matrix[1]);
    result[2] = Math.abs(matrix[2]);
    result[3] = Math.abs(matrix[3]);
    result[4] = Math.abs(matrix[4]);
    result[5] = Math.abs(matrix[5]);
    result[6] = Math.abs(matrix[6]);
    result[7] = Math.abs(matrix[7]);
    result[8] = Math.abs(matrix[8]);
    
    return result;
    };
    
*/
    
    /**
    * An immutable Matrix3 instance initialized to the identity matrix.
    *
    * @type {Matrix3}
    * @constant
    */
    public static let identity = Matrix3(1.0)

    
    /**
    * An immutable Matrix3 instance initialized to the zero matrix.
    *
    * @type {Matrix3}
    * @constant
    */
    public static let zero = Matrix3()

}

extension Matrix3: MatrixType {}

extension Matrix3: Equatable {}

public func == (left: Matrix3, right: Matrix3) -> Bool {
    return left.equals(right)
}


