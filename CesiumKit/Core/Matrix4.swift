//
//  Matrix4.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/07/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
* A 4x4 matrix, indexable as a column-major order array.
* Constructor parameters are in row-major order for code readability.
* @alias Matrix4
* @constructor
*
* @param {Number} [column0Row0=0.0] The value for column 0, row 0.
* @param {Number} [column1Row0=0.0] The value for column 1, row 0.
* @param {Number} [column2Row0=0.0] The value for column 2, row 0.
* @param {Number} [column3Row0=0.0] The value for column 3, row 0.
* @param {Number} [column0Row1=0.0] The value for column 0, row 1.
* @param {Number} [column1Row1=0.0] The value for column 1, row 1.
* @param {Number} [column2Row1=0.0] The value for column 2, row 1.
* @param {Number} [column3Row1=0.0] The value for column 3, row 1.
* @param {Number} [column0Row2=0.0] The value for column 0, row 2.
* @param {Number} [column1Row2=0.0] The value for column 1, row 2.
* @param {Number} [column2Row2=0.0] The value for column 2, row 2.
* @param {Number} [column3Row2=0.0] The value for column 3, row 2.
* @param {Number} [column0Row3=0.0] The value for column 0, row 3.
* @param {Number} [column1Row3=0.0] The value for column 1, row 3.
* @param {Number} [column2Row3=0.0] The value for column 2, row 3.
* @param {Number} [column3Row3=0.0] The value for column 3, row 3.
*
* @see Matrix4.fromColumnMajorArray
* @see Matrix4.fromRowMajorArray
* @see Matrix4.fromRotationTranslation
* @see Matrix4.fromTranslationQuaternionRotationScale
* @see Matrix4.fromTranslation
* @see Matrix4.fromScale
* @see Matrix4.fromUniformScale
* @see Matrix4.fromCamera
* @see Matrix4.computePerspectiveFieldOfView
* @see Matrix4.computeOrthographicOffCenter
* @see Matrix4.computePerspectiveOffCenter
* @see Matrix4.computeInfinitePerspectiveOffCenter
* @see Matrix4.computeViewportTransformation
* @see Matrix2
* @see Matrix3
* @see Packable
*/
public struct Matrix4 {
    
    fileprivate (set) internal var simdType: double4x4
    
    var floatRepresentation: float4x4 {
        return float4x4([
            vector_float(simdType[0]),
            vector_float(simdType[1]),
            vector_float(simdType[2]),
            vector_float(simdType[3])
        ])
    }
    
    public init(
        _ column0Row0: Double, _ column1Row0: Double, _ column2Row0: Double, _ column3Row0: Double,
        _ column0Row1: Double, _ column1Row1: Double, _ column2Row1: Double, _ column3Row1: Double,
        _ column0Row2: Double, _ column1Row2: Double, _ column2Row2: Double, _ column3Row2: Double,
        _ column0Row3: Double, _ column1Row3: Double, _ column2Row3: Double, _ column3Row3: Double)
    {
        
    simdType = double4x4(rows: [
            double4(column0Row0, column1Row0, column2Row0, column3Row0),
            double4(column0Row1, column1Row1, column2Row1, column3Row1),
            double4(column0Row2, column1Row2, column2Row2, column3Row2),
            double4(column0Row3, column1Row3, column2Row3, column3Row3)
            ])
    }

    public init(grid: [Double]) {
        assert(grid.count >= Matrix4.packedLength(), "invalid grid length")
        self.init(
            grid[0], grid[1], grid[2], grid[3],
            grid[4], grid[5], grid[6], grid[7],
            grid[8], grid[9], grid[10], grid[11],
            grid[12], grid[13], grid[14], grid[15]
        )
    }
    
    public init (simd: double4x4) {
        simdType = simd
    }
    
    public init (_ scalar: Double = 0.0) {
        simdType = double4x4(scalar)
    }
    
    public init (diagonal: double4) {
        simdType = double4x4(diagonal: diagonal)
    }

/*

/**
* Creates a Matrix4 from 16 consecutive elements in an array.
* @function
*
* @param {Number[]} array The array whose 16 consecutive elements correspond to the positions of the matrix.  Assumes column-major order.
* @param {Number} [startingIndex=0] The offset into the array of the first element, which corresponds to first column first row position in the matrix.
* @param {Matrix4} [result] The object onto which to store the result.
* @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
*
* @example
* // Create the Matrix4:
* // [1.0, 2.0, 3.0, 4.0]
* // [1.0, 2.0, 3.0, 4.0]
* // [1.0, 2.0, 3.0, 4.0]
* // [1.0, 2.0, 3.0, 4.0]
*
* var v = [1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 4.0];
* var m = Cesium.Matrix4.fromArray(v);
*
* // Create same Matrix4 with using an offset into an array
* var v2 = [0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 4.0];
* var m2 = Cesium.Matrix4.fromArray(v2, 2);
*/
Matrix4.fromArray = Matrix4.unpack;

/**
* Computes a Matrix4 instance from a column-major order array.
*
* @param {Number[]} values The column-major order array.
* @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
* @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
*/
Matrix4.fromColumnMajorArray = function(values, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(values)) {
        throw new DeveloperError('values is required');
    }
    //>>includeEnd('debug');
    
     assert(grid.count == 16, "Invalid source array")
     self.init(rows: [
     double4(grid[0], grid[1], grid[2], grid[3]),
     double4(grid[4], grid[5], grid[6], grid[7]),
     double4(grid[8], grid[9], grid[10], grid[11]),
     double4(grid[12], grid[13], grid[14], grid[15])
     ])
     }};
*/
    /**
    * Computes a Matrix4 instance from a row-major order array.
    * The resulting matrix will be in column-major order.
    *
    * @param {Number[]} values The row-major order array.
    * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
    * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
    */
    init(rowMajorArray grid: [Double]) {
        self.init(grid: grid)
   }

/**
* Computes a Matrix4 instance from a Matrix3 representing the rotation
* and a Cartesian3 representing the translation.
*
* @param {Matrix3} rotation The upper left portion of the matrix representing the rotation.
* @param {Cartesian3} [translation=Cartesian3.ZERO] The upper right portion of the matrix representing the translation.
* @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
* @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
*/
    init (rotation: Matrix3, translation: Cartesian3 = Cartesian3.zero) {
        self.init(
            rotation[0,0], rotation[1,0], rotation[2,0], translation.x,
            rotation[0,1], rotation[1,1], rotation[2,1], translation.y,
            rotation[0,2], rotation[1,2], rotation[2,2], translation.z,
            0.0,         0.0,         0.0,           1.0
        )
    }
/*
var scratchTrsRotation = new Matrix3();

/**
* Computes a Matrix4 instance from a translation, rotation, and scale (TRS)
* representation with the rotation represented as a quaternion.
*
* @param {Cartesian3} translation The translation transformation.
* @param {Quaternion} rotation The rotation transformation.
* @param {Cartesian3} scale The non-uniform scale transformation.
* @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
* @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
*
* @example
* result = Cesium.Matrix4.fromTranslationQuaternionRotationScale(
*   new Cesium.Cartesian3(1.0, 2.0, 3.0), // translation
*   Cesium.Quaternion.IDENTITY,           // rotation
*   new Cesium.Cartesian3(7.0, 8.0, 9.0), // scale
*   result);
*/
Matrix4.fromTranslationQuaternionRotationScale = function(translation, rotation, scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(translation)) {
        throw new DeveloperError('translation is required.');
    }
    if (!defined(rotation)) {
        throw new DeveloperError('rotation is required.');
    }
    if (!defined(scale)) {
        throw new DeveloperError('scale is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new Matrix4();
    }
    
    var scaleX = scale.x;
    var scaleY = scale.y;
    var scaleZ = scale.z;
    
    var x2 = rotation.x * rotation.x;
    var xy = rotation.x * rotation.y;
    var xz = rotation.x * rotation.z;
    var xw = rotation.x * rotation.w;
    var y2 = rotation.y * rotation.y;
    var yz = rotation.y * rotation.z;
    var yw = rotation.y * rotation.w;
    var z2 = rotation.z * rotation.z;
    var zw = rotation.z * rotation.w;
    var w2 = rotation.w * rotation.w;
    
    var m00 = x2 - y2 - z2 + w2;
    var m01 = 2.0 * (xy - zw);
    var m02 = 2.0 * (xz + yw);
    
    var m10 = 2.0 * (xy + zw);
    var m11 = -x2 + y2 - z2 + w2;
    var m12 = 2.0 * (yz - xw);
    
    var m20 = 2.0 * (xz - yw);
    var m21 = 2.0 * (yz + xw);
    var m22 = -x2 - y2 + z2 + w2;
    
    result[0]  = m00 * scaleX;
    result[1]  = m10 * scaleX;
    result[2]  = m20 * scaleX;
    result[3]  = 0.0;
    result[4]  = m01 * scaleY;
    result[5]  = m11 * scaleY;
    result[6]  = m21 * scaleY;
    result[7]  = 0.0;
    result[8]  = m02 * scaleZ;
    result[9]  = m12 * scaleZ;
    result[10] = m22 * scaleZ;
    result[11] = 0.0;
    result[12] = translation.x;
    result[13] = translation.y;
    result[14] = translation.z;
    result[15] = 1.0;
    
    return result;
};
*/
/**
* Creates a Matrix4 instance from a Cartesian3 representing the translation.
*
* @param {Cartesian3} translation The upper right portion of the matrix representing the translation.
* @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
* @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
*
* @see Matrix4.multiplyByTranslation
*/
    init (translation: Cartesian3) {
        self.init(rotation: Matrix3.identity, translation: translation)
    }

    /**
     * Computes a Matrix4 instance representing a non-uniform scale.
     *
     * @param {Cartesian3} scale The x, y, and z scale factors.
     * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
     * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
     *
     * @example
     * // Creates
     * //   [7.0, 0.0, 0.0, 0.0]
     * //   [0.0, 8.0, 0.0, 0.0]
     * //   [0.0, 0.0, 9.0, 0.0]
     * //   [0.0, 0.0, 0.0, 1.0]
     * var m = Cesium.Matrix4.fromScale(new Cartesian3(7.0, 8.0, 9.0));
     */
    init (scale: Cartesian3) {
        let diagonal = double4([scale.simdType.x, scale.simdType.y, scale.simdType.z, 1.0])
        self.simdType = double4x4(diagonal: diagonal)
        /*Matrix4(
         scale.x, 0.0,     0.0,     0.0,
         0.0,     scale.y, 0.0,     0.0,
         0.0,     0.0,     scale.z, 0.0,
         0.0,     0.0,     0.0,     1.0);*/
    }
/*
/**
* Computes a Matrix4 instance representing a uniform scale.
*
* @param {Number} scale The uniform scale factor.
* @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
* @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
*
* @example
* // Creates
* //   [2.0, 0.0, 0.0, 0.0]
* //   [0.0, 2.0, 0.0, 0.0]
* //   [0.0, 0.0, 2.0, 0.0]
* //   [0.0, 0.0, 0.0, 1.0]
* var m = Cesium.Matrix4.fromScale(2.0);
*/
Matrix4.fromUniformScale = function(scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof scale !== 'number') {
        throw new DeveloperError('scale is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        return new Matrix4(scale, 0.0,   0.0,   0.0,
            0.0,   scale, 0.0,   0.0,
            0.0,   0.0,   scale, 0.0,
            0.0,   0.0,   0.0,   1.0);
    }
    
    result[0] = scale;
    result[1] = 0.0;
    result[2] = 0.0;
    result[3] = 0.0;
    result[4] = 0.0;
    result[5] = scale;
    result[6] = 0.0;
    result[7] = 0.0;
    result[8] = 0.0;
    result[9] = 0.0;
    result[10] = scale;
    result[11] = 0.0;
    result[12] = 0.0;
    result[13] = 0.0;
    result[14] = 0.0;
    result[15] = 1.0;
    return result;
};

var fromCameraF = new Cartesian3();
var fromCameraS = new Cartesian3();
var fromCameraU = new Cartesian3();

/**
* Computes a Matrix4 instance from a Camera.
*
* @param {Camera} camera The camera to use.
* @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
* @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
*/
Matrix4.fromCamera = function(camera, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(camera)) {
        throw new DeveloperError('camera is required.');
    }
    //>>includeEnd('debug');
    
    var eye = camera.eye;
    var target = camera.target;
    var up = camera.up;
    
    //>>includeStart('debug', pragmas.debug);
    if (!defined(eye)) {
        throw new DeveloperError('camera.eye is required.');
    }
    if (!defined(target)) {
        throw new DeveloperError('camera.target is required.');
    }
    if (!defined(up)) {
        throw new DeveloperError('camera.up is required.');
    }
    //>>includeEnd('debug');
    
    Cartesian3.normalize(Cartesian3.subtract(target, eye, fromCameraF), fromCameraF);
    Cartesian3.normalize(Cartesian3.cross(fromCameraF, up, fromCameraS), fromCameraS);
    Cartesian3.normalize(Cartesian3.cross(fromCameraS, fromCameraF, fromCameraU), fromCameraU);
    
    var sX = fromCameraS.x;
    var sY = fromCameraS.y;
    var sZ = fromCameraS.z;
    var fX = fromCameraF.x;
    var fY = fromCameraF.y;
    var fZ = fromCameraF.z;
    var uX = fromCameraU.x;
    var uY = fromCameraU.y;
    var uZ = fromCameraU.z;
    var eyeX = eye.x;
    var eyeY = eye.y;
    var eyeZ = eye.z;
    var t0 = sX * -eyeX + sY * -eyeY+ sZ * -eyeZ;
    var t1 = uX * -eyeX + uY * -eyeY+ uZ * -eyeZ;
    var t2 = fX * eyeX + fY * eyeY + fZ * eyeZ;
    
    //The code below this comment is an optimized
    //version of the commented lines.
    //Rather that create two matrices and then multiply,
    //we just bake in the multiplcation as part of creation.
    //var rotation = new Matrix4(
    //                sX,  sY,  sZ, 0.0,
    //                uX,  uY,  uZ, 0.0,
    //               -fX, -fY, -fZ, 0.0,
    //                0.0,  0.0,  0.0, 1.0);
    //var translation = new Matrix4(
    //                1.0, 0.0, 0.0, -eye.x,
    //                0.0, 1.0, 0.0, -eye.y,
    //                0.0, 0.0, 1.0, -eye.z,
    //                0.0, 0.0, 0.0, 1.0);
    //return rotation.multiply(translation);
    if (!defined(result)) {
        return new Matrix4(
            sX,   sY,  sZ, t0,
            uX,   uY,  uZ, t1,
            -fX,  -fY, -fZ, t2,
            0.0, 0.0, 0.0, 1.0);
    }
    result[0] = sX;
    result[1] = uX;
    result[2] = -fX;
    result[3] = 0.0;
    result[4] = sY;
    result[5] = uY;
    result[6] = -fY;
    result[7] = 0.0;
    result[8] = sZ;
    result[9] = uZ;
    result[10] = -fZ;
    result[11] = 0.0;
    result[12] = t0;
    result[13] = t1;
    result[14] = t2;
    result[15] = 1.0;
    return result;
    
};
     */
    public subscript (column: Int) -> Cartesian4 {
        return Cartesian4(simd: simdType[column])
    }
    /// Access to individual elements.
    public subscript (column: Int, row: Int) -> Double {
        return simdType[column][row]
    }
    /*
/**
* Computes a Matrix4 instance representing a perspective transformation matrix.
*
* @param {Number} fovY The field of view along the Y axis in radians.
* @param {Number} aspectRatio The aspect ratio.
* @param {Number} near The distance to the near plane in meters.
* @param {Number} far The distance to the far plane in meters.
* @param {Matrix4} result The object in which the result will be stored.
* @returns The modified result parameter.
*
* @exception {DeveloperError} fovY must be in [0, PI).
* @exception {DeveloperError} aspectRatio must be greater than zero.
* @exception {DeveloperError} near must be greater than zero.
* @exception {DeveloperError} far must be greater than zero.
*/
Matrix4.computePerspectiveFieldOfView = function(fovY, aspectRatio, near, far, result) {
    //>>includeStart('debug', pragmas.debug);
    if (fovY <= 0.0 || fovY > Math.PI) {
        throw new DeveloperError('fovY must be in [0, PI).');
    }
    if (aspectRatio <= 0.0) {
        throw new DeveloperError('aspectRatio must be greater than zero.');
    }
    if (near <= 0.0) {
        throw new DeveloperError('near must be greater than zero.');
    }
    if (far <= 0.0) {
        throw new DeveloperError('far must be greater than zero.');
    }
    if (!defined(result)) {
        throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    var bottom = Math.tan(fovY * 0.5);
    
    var column1Row1 = 1.0 / bottom;
    var column0Row0 = column1Row1 / aspectRatio;
    var column2Row2 = (far + near) / (near - far);
    var column3Row2 = (2.0 * far * near) / (near - far);
    
    result[0] = column0Row0;
    result[1] = 0.0;
    result[2] = 0.0;
    result[3] = 0.0;
    result[4] = 0.0;
    result[5] = column1Row1;
    result[6] = 0.0;
    result[7] = 0.0;
    result[8] = 0.0;
    result[9] = 0.0;
    result[10] = column2Row2;
    result[11] = -1.0;
    result[12] = 0.0;
    result[13] = 0.0;
    result[14] = column3Row2;
    result[15] = 0.0;
    return result;
};
*/
    /**
    * Computes a Matrix4 instance representing an orthographic transformation matrix.
    *
    * @param {Number} left The number of meters to the left of the camera that will be in view.
    * @param {Number} right The number of meters to the right of the camera that will be in view.
    * @param {Number} bottom The number of meters below of the camera that will be in view.
    * @param {Number} top The number of meters above of the camera that will be in view.
    * @param {Number} near The distance to the near plane in meters.
    * @param {Number} far The distance to the far plane in meters.
    * @param {Matrix4} result The object in which the result will be stored.
    * @returns The modified result parameter.
    */
    static func computeOrthographicOffCenter (left: Double, right: Double, bottom: Double, top: Double, near: Double = 0.0, far: Double = 1.0) -> Matrix4 {
        
        // Converted to Metal NDC coordinates - z: [0-1]
        // https://msdn.microsoft.com/en-us/library/windows/desktop/bb205348(v=vs.85).aspx
        
        let a = 2.0 / (right - left)
        let b = 2.0 / (top - bottom)
        let c = 1.0 / (far - near)
        
        let tx = (right + left) / (left - right)
        let ty = (top + bottom) / (bottom - top)
        let tz = near / (far - near)
        
        return Matrix4(
            a, 0.0, 0.0, tx,
            0.0, b, 0.0, ty,
            0.0, 0.0, c, tz,
            0.0, 0.0, 0.0, 1.0)
    }

    /**
    * Computes a Matrix4 instance representing an off center perspective transformation.
    *
    * @param {Number} left The number of meters to the left of the camera that will be in view.
    * @param {Number} right The number of meters to the right of the camera that will be in view.
    * @param {Number} bottom The number of meters below of the camera that will be in view.
    * @param {Number} top The number of meters above of the camera that will be in view.
    * @param {Number} near The distance to the near plane in meters.
    * @param {Number} far The distance to the far plane in meters.
    * @param {Matrix4} result The object in which the result will be stored.
    * @returns The modified result parameter.
    */
    static func computePerspectiveOffCenter (left: Double, right: Double, bottom: Double, top: Double, near: Double, far: Double) -> Matrix4 {
        // Converted to Metal NDC coordinates - z: [0-1]
        // https://msdn.microsoft.com/en-us/library/windows/desktop/bb205354(v=vs.85).aspx
        
        let column0Row0 = 2.0 * near / (right - left) // w
        let column1Row1 = 2.0 * near / (top - bottom) // h
        let column2Row0 = (left + right) / (right - left)
        let column2Row1 = (top + bottom) / (top - bottom)
        let column2Row2 = far / (near - far) // Q
        let column3Row2 = near * far / (near - far)
                
        return Matrix4(
            column0Row0, 0.0, column2Row0, 0.0,
            0.0, column1Row1, column2Row1, 0.0,
            0.0, 0.0, column2Row2, column3Row2,
            0.0, 0.0, -1.0, 0.0)
    }
    
    /**
    * Computes a Matrix4 instance representing an infinite off center perspective transformation.
    *
    * @param {Number} left The number of meters to the left of the camera that will be in view.
    * @param {Number} right The number of meters to the right of the camera that will be in view.
    * @param {Number} bottom The number of meters below of the camera that will be in view.
    * @param {Number} top The number of meters above of the camera that will be in view.
    * @param {Number} near The distance to the near plane in meters.
    * @param {Matrix4} result The object in which the result will be stored.
    * @returns The modified result parameter.
    */
    static func computeInfinitePerspectiveOffCenter (left: Double, right: Double, bottom: Double, top: Double, near: Double) -> Matrix4 {
        //assertionFailure("not updated for metal NDC")
        let column0Row0 = 2.0 * near / (right - left)
        let column1Row1 = 2.0 * near / (top - bottom)
        let column2Row0 = (right + left) / (right - left)
        let column2Row1 = (top + bottom) / (top - bottom)
        let column2Row2 = -1.0
        let column2Row3 = -1.0
        let column3Row2 = -2.0 * near
        
        return Matrix4(
            column0Row0, 0.0, column2Row0, 0.0,
            0.0, column1Row1, column2Row1, 0.0,
            0.0, 0.0, column2Row2, column3Row2,
            0.0, 0.0, column2Row3, 0.0)
    }

    /**
    * Computes a Matrix4 instance that transforms from normalized device coordinates to window coordinates.
    *
    * @param {Object}[viewport = { x : 0.0, y : 0.0, width : 0.0, height : 0.0 }] The viewport's corners as shown in Example 1.
    * @param {Number}[nearDepthRange=0.0] The near plane distance in window coordinates.
    * @param {Number}[farDepthRange=1.0] The far plane distance in window coordinates.
    * @param {Matrix4} result The object in which the result will be stored.
    * @returns The modified result parameter.
    *
    * @example
    * // Example 1.  Create viewport transformation using an explicit viewport and depth range.
    * var m = Cesium.Matrix4.computeViewportTransformation({
    *     x : 0.0,
    *     y : 0.0,
    *     width : 1024.0,
    *     height : 768.0
    * }, 0.0, 1.0);
    *
    * @example
    * // Example 2.  Create viewport transformation using the context's viewport.
    * var m = Cesium.Matrix4.computeViewportTransformation(context.getViewport());
    */
    internal static func computeViewportTransformation (_ viewport: Cartesian4, nearDepthRange: Double = 0.0, farDepthRange: Double = 1.0) -> Matrix4 {
        
        let x = viewport.x
        let y = viewport.y
        let width = viewport.width
        let height = viewport.height
        
        let halfWidth = width * 0.5
        let halfHeight = height * 0.5
        let halfDepth = (farDepthRange - nearDepthRange) * 0.5
        
        let column0Row0 = halfWidth
        let column1Row1 = halfHeight
        let column2Row2 = halfDepth
        let column3Row0 = x + halfWidth
        let column3Row1 = y + halfHeight
        let column3Row2 = nearDepthRange + halfDepth
        let column3Row3 = 1.0
        return Matrix4(
            column0Row0, 0.0, 0.0, column3Row0,
            0.0, column1Row1, 0.0, column3Row1,
            0.0, 0.0, column2Row2, column3Row2,
            0.0, 0.0, 0.0, column3Row3
        )
    }

/*
/**
* Computes the array index of the element at the provided row and column.
*
* @param {Number} row The zero-based index of the row.
* @param {Number} column The zero-based index of the column.
* @returns {Number} The index of the element at the provided row and column.
*
* @exception {DeveloperError} row must be 0, 1, 2, or 3.
* @exception {DeveloperError} column must be 0, 1, 2, or 3.
*
* @example
* var myMatrix = new Cesium.Matrix4();
* var column1Row0Index = Cesium.Matrix4.getElementIndex(1, 0);
* var column1Row0 = myMatrix[column1Row0Index]
* myMatrix[column1Row0Index] = 10.0;
*/
Matrix4.getElementIndex = function(column, row) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof row !== 'number' || row < 0 || row > 3) {
        throw new DeveloperError('row must be 0, 1, 2, or 3.');
    }
    if (typeof column !== 'number' || column < 0 || column > 3) {
        throw new DeveloperError('column must be 0, 1, 2, or 3.');
    }
    //>>includeEnd('debug');
    
    return column * 4 + row;
};
*/
    /**
    * Retrieves a copy of the matrix column at the provided index as a Cartesian4 instance.
    *
    * @param {Matrix4} matrix The matrix to use.
    * @param {Number} index The zero-based index of the column to retrieve.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0, 1, 2, or 3.
    *
    * @example
    * //returns a Cartesian4 instance with values from the specified column
    * // m = [10.0, 11.0, 12.0, 13.0]
    * //     [14.0, 15.0, 16.0, 17.0]
    * //     [18.0, 19.0, 20.0, 21.0]
    * //     [22.0, 23.0, 24.0, 25.0]
    *
    * //Example 1: Creates an instance of Cartesian
    * var a = Cesium.Matrix4.getColumn(m, 2);
    *
    * @example
    * //Example 2: Sets values for Cartesian instance
    * var a = new Cesium.Cartesian4();
    * Cesium.Matrix4.getColumn(m, 2, a);
    *
    * // a.x = 12.0; a.y = 16.0; a.z = 20.0; a.w = 24.0;
    */
    func getColumn (_ index: Int) -> Cartesian4 {
        assert(index >= 0 && index <= 3, "index must be 0, 1, 2, or 3.")
        return Cartesian4(simd: simdType[index])
        
    }

    /**
     * Computes a new matrix that replaces the specified column in the provided matrix with the provided Cartesian4 instance.
     *
     * @param {Matrix4} matrix The matrix to use.
     * @param {Number} index The zero-based index of the column to set.
     * @param {Cartesian4} cartesian The Cartesian whose values will be assigned to the specified column.
     * @returns {Matrix4} The modified result parameter.
     *
     * @exception {DeveloperError} index must be 0, 1, 2, or 3.
     *
     * @example
     * //creates a new Matrix4 instance with new column values from the Cartesian4 instance
     * // m = [10.0, 11.0, 12.0, 13.0]
     * //     [14.0, 15.0, 16.0, 17.0]
     * //     [18.0, 19.0, 20.0, 21.0]
     * //     [22.0, 23.0, 24.0, 25.0]
     *
     * var a = Cesium.Matrix4.setColumn(m, 2, new Cartesian4(99.0, 98.0, 97.0, 96.0));
     *
     * // m remains the same
     * // a = [10.0, 11.0, 99.0, 13.0]
     * //     [14.0, 15.0, 98.0, 17.0]
     * //     [18.0, 19.0, 97.0, 21.0]
     * //     [22.0, 23.0, 96.0, 25.0]
     */
    func setColumn (_ index: Int, cartesian: Cartesian4) -> Matrix4 {
        
        assert(index >= 0 && index <= 3, "index must be 0, 1, 2, or 3.")
        var result = simdType
        result[index] = double4(cartesian.x, cartesian.y, cartesian.z, cartesian.w)
        return Matrix4(simd: result)
    }

    /**
    * Computes a new matrix that replaces the translation in the rightmost column of the provided
    * matrix with the provided translation.  This assumes the matrix is an affine transformation
    *
    * @param {Matrix4} matrix The matrix to use.
    * @param {Cartesian3} translation The translation that replaces the translation of the provided matrix.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Matrix4} The modified result parameter.
    */
    func setTranslation (_ translation: Cartesian3) -> Matrix4 {
        var result = simdType
        result[3] = double4(translation.x, translation.y, translation.z, simdType[3].w)
        return Matrix4(simd: result)
    }
    
    /**
    * Retrieves a copy of the matrix row at the provided index as a Cartesian4 instance.
    *
    * @param {Matrix4} matrix The matrix to use.
    * @param {Number} index The zero-based index of the row to retrieve.
    * @param {Cartesian4} result The object onto which to store the result.
    * @returns {Cartesian4} The modified result parameter.
    *
    * @exception {DeveloperError} index must be 0, 1, 2, or 3.
    *
    * @example
    * //returns a Cartesian4 instance with values from the specified column
    * // m = [10.0, 11.0, 12.0, 13.0]
    * //     [14.0, 15.0, 16.0, 17.0]
    * //     [18.0, 19.0, 20.0, 21.0]
    * //     [22.0, 23.0, 24.0, 25.0]
    *
    * //Example 1: Returns an instance of Cartesian
    * var a = Cesium.Matrix4.getRow(m, 2);
    *
    * @example
    * //Example 2: Sets values for a Cartesian instance
    * var a = new Cesium.Cartesian4();
    * Cesium.Matrix4.getRow(m, 2, a);
    *
    * // a.x = 18.0; a.y = 19.0; a.z = 20.0; a.w = 21.0;
    */
    func row (_ index: Int) -> Cartesian4 {
        assert(index >= 0 && index <= 3, "index must be 0, 1, 2, or 3.")
        return Cartesian4(
            x: self[0, index],
            y: self[1, index],
            z: self[2, index],
            w: self[3, index]
        )
    }
    
    /**
     * Computes the product of two matrices.
     *
     * @param {MatrixType} self The first matrix.
     * @param {MatrixType} other The second matrix.
     * @returns {MatrixType} The modified result parameter.
     */
    func multiply(_ other: Matrix4) -> Matrix4 {
        return Matrix4(simd: simdType * other.simdType)
    }
    
    func negate() -> Matrix4 {
        return Matrix4(simd: -simdType)
    }
    
    func transpose () -> Matrix4 {
        return Matrix4(simd: simdType.transpose)
    }
    
    /**
     * Compares this matrix to the provided matrix componentwise and returns
     * <code>true</code> if they are equal, <code>false</code> otherwise.
     *
     * @param {MatrixType} [right] The right hand side matrix.
     * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
     */
    func equals(_ other: Matrix4) -> Bool {
        return matrix_equal(simdType.cmatrix, other.simdType.cmatrix)
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
    func equalsEpsilon(_ other: Matrix4, epsilon: Double) -> Bool {
        return matrix_almost_equal_elements(self.simdType.cmatrix, other.simdType.cmatrix, epsilon)
    }
    
/*
/**
* Computes a new matrix that replaces the specified row in the provided matrix with the provided Cartesian4 instance.
*
* @param {Matrix4} matrix The matrix to use.
* @param {Number} index The zero-based index of the row to set.
* @param {Cartesian4} cartesian The Cartesian whose values will be assigned to the specified row.
* @param {Cartesian4} result The object onto which to store the result.
* @returns {Matrix4} The modified result parameter.
*
* @exception {DeveloperError} index must be 0, 1, 2, or 3.
*
* @example
* //create a new Matrix4 instance with new row values from the Cartesian4 instance
* // m = [10.0, 11.0, 12.0, 13.0]
* //     [14.0, 15.0, 16.0, 17.0]
* //     [18.0, 19.0, 20.0, 21.0]
* //     [22.0, 23.0, 24.0, 25.0]
*
* var a = Cesium.Matrix4.setRow(m, 2, new Cartesian4(99.0, 98.0, 97.0, 96.0));
*
* // m remains the same
* // a = [10.0, 11.0, 12.0, 13.0]
* //     [14.0, 15.0, 16.0, 17.0]
* //     [99.0, 98.0, 97.0, 96.0]
* //     [22.0, 23.0, 24.0, 25.0]
*/
Matrix4.setRow = function(matrix, index, cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
        throw new DeveloperError('matrix is required');
    }
    if (!defined(cartesian)) {
        throw new DeveloperError('cartesian is required');
    }
    if (typeof index !== 'number' || index < 0 || index > 3) {
        throw new DeveloperError('index must be 0, 1, 2, or 3.');
    }
    if (!defined(result)) {
        throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result = Matrix4.clone(matrix, result);
    result[index] = cartesian.x;
    result[index + 4] = cartesian.y;
    result[index + 8] = cartesian.z;
    result[index + 12] = cartesian.w;
    return result;
};

var scratchColumn = new Cartesian3();

/**
* Extracts the non-uniform scale assuming the matrix is an affine transformation.
*
* @param {Matrix4} matrix The matrix.
* @param {Cartesian3} result The object onto which to store the result.
* @returns {Cartesian3} The modified result parameter
*/
Matrix4.getScale = function(matrix, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
        throw new DeveloperError('matrix is required.');
    }
    if (!defined(result)) {
        throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    result.x = Cartesian3.magnitude(Cartesian3.fromElements(matrix[0], matrix[1], matrix[2], scratchColumn));
    result.y = Cartesian3.magnitude(Cartesian3.fromElements(matrix[4], matrix[5], matrix[6], scratchColumn));
    result.z = Cartesian3.magnitude(Cartesian3.fromElements(matrix[8], matrix[9], matrix[10], scratchColumn));
    return result;
};

var scratchScale = new Cartesian3();

/**
* Computes the maximum scale assuming the matrix is an affine transformation.
* The maximum scale is the maximum length of the column vectors in the upper-left
* 3x3 matrix.
*
* @param {Matrix4} matrix The matrix.
* @returns {Number} The maximum scale.
*/
Matrix4.getMaximumScale = function(matrix) {
    Matrix4.getScale(matrix, scratchScale);
    return Cartesian3.maximumComponent(scratchScale);
};
*/
    /**
     * Computes the product of two matrices assuming the matrices are
     * affine transformation matrices, where the upper left 3x3 elements
     * are a rotation matrix, and the upper three elements in the fourth
     * column are the translation.  The bottom row is assumed to be [0, 0, 0, 1].
     * The matrix is not verified to be in the proper form.
     * This method is faster than computing the product for general 4x4
     * matrices using {@link Matrix4.multiply}.
     *
     * @param {Matrix4} left The first matrix.
     * @param {Matrix4} right The second matrix.
     * @param {Matrix4} result The object onto which to store the result.
     * @returns {Matrix4} The modified result parameter.
     *
     * @example
     * var m1 = new Cesium.Matrix4(1.0, 6.0, 7.0, 0.0, 2.0, 5.0, 8.0, 0.0, 3.0, 4.0, 9.0, 0.0, 0.0, 0.0, 0.0, 1.0];
     * var m2 = Cesium.Transforms.eastNorthUpToFixedFrame(new Cesium.Cartesian3(1.0, 1.0, 1.0));
     * var m3 = Cesium.Matrix4.multiplyTransformation(m1, m2);
     */
    /*func multiplyTransformation (other: Matrix4) -> Matrix4 {
        
        let this0 = _grid[0]
        let this1 = _grid[1]
        let this2 = _grid[2]
        let this4 = _grid[4]
        let this5 = _grid[5]
        let this6 = _grid[6]
        let this8 = _grid[8]
        let this9 = _grid[9]
        let this10 = _grid[10]
        let this12 = _grid[12]
        let this13 = _grid[13]
        let this14 = _grid[14]
        
        let other0 = other[0]
        let other1 = other[1]
        let other2 = other[2]
        let other4 = other[4]
        let other5 = other[5]
        let other6 = other[6]
        let other8 = other[8]
        let other9 = other[9]
        let other10 = other[10]
        let other12 = other[12]
        let other13 = other[13]
        let other14 = other[14]
        
        let column0Row0 = this0 * other0 + this4 * other1 + this8 * other2
        let column0Row1 = this1 * other0 + this5 * other1 + this9 * other2
        let column0Row2 = this2 * other0 + this6 * other1 + this10 * other2
        
        let column1Row0 = this0 * other4 + this4 * other5 + this8 * other6
        let column1Row1 = this1 * other4 + this5 * other5 + this9 * other6
        let column1Row2 = this2 * other4 + this6 * other5 + this10 * other6
        
        let column2Row0 = this0 * other8 + this4 * other9 + this8 * other10
        let column2Row1 = this1 * other8 + this5 * other9 + this9 * other10
        let column2Row2 = this2 * other8 + this6 * other9 + this10 * other10
        
        let column3Row0 = this0 * other12 + this4 * other13 + this8 * other14 + this12
        let column3Row1 = this1 * other12 + this5 * other13 + this9 * other14 + this13
        let column3Row2 = this2 * other12 + this6 * other13 + this10 * other14 + this14
        
        return Matrix4(
            column0Row0, column1Row0, column2Row0, column3Row0,
            column0Row1, column1Row1, column2Row1, column3Row1,
            column0Row2, column1Row2, column2Row2, column3Row2,
            0.0, 0.0, 0.0, 1.0
        )
    }*/
/*
/**
* Multiplies a transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
    * by a 3x3 rotation matrix.  This is an optimization
    * for <code>Matrix4.multiply(m, Matrix4.fromRotationTranslation(rotation), m);</code> with less allocations and arithmetic operations.
    *
    * @param {Matrix4} matrix The matrix on the left-hand side.
    * @param {Matrix3} rotation The 3x3 rotation matrix on the right-hand side.
    * @param {Matrix4} result The object onto which to store the result.
    * @returns {Matrix4} The modified result parameter.
    *
    * @example
    * // Instead of Cesium.Matrix4.multiply(m, Cesium.Matrix4.fromRotationTranslation(rotation), m);
    * Cesium.Matrix4.multiplyByMatrix3(m, rotation, m);
    */
    Matrix4.multiplyByMatrix3 = function(matrix, rotation, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
    throw new DeveloperError('matrix is required');
    }
    if (!defined(rotation)) {
    throw new DeveloperError('rotation is required');
    }
    if (!defined(result)) {
    throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    var left0 = matrix[0];
    var left1 = matrix[1];
    var left2 = matrix[2];
    var left4 = matrix[4];
    var left5 = matrix[5];
    var left6 = matrix[6];
    var left8 = matrix[8];
    var left9 = matrix[9];
    var left10 = matrix[10];
    
    var right0 = rotation[0];
    var right1 = rotation[1];
    var right2 = rotation[2];
    var right4 = rotation[3];
    var right5 = rotation[4];
    var right6 = rotation[5];
    var right8 = rotation[6];
    var right9 = rotation[7];
    var right10 = rotation[8];
    
    var column0Row0 = left0 * right0 + left4 * right1 + left8 * right2;
    var column0Row1 = left1 * right0 + left5 * right1 + left9 * right2;
    var column0Row2 = left2 * right0 + left6 * right1 + left10 * right2;
    
    var column1Row0 = left0 * right4 + left4 * right5 + left8 * right6;
    var column1Row1 = left1 * right4 + left5 * right5 + left9 * right6;
    var column1Row2 = left2 * right4 + left6 * right5 + left10 * right6;
    
    var column2Row0 = left0 * right8 + left4 * right9 + left8 * right10;
    var column2Row1 = left1 * right8 + left5 * right9 + left9 * right10;
    var column2Row2 = left2 * right8 + left6 * right9 + left10 * right10;
    
    result[0] = column0Row0;
    result[1] = column0Row1;
    result[2] = column0Row2;
    result[3] = 0.0;
    result[4] = column1Row0;
    result[5] = column1Row1;
    result[6] = column1Row2;
    result[7] = 0.0;
    result[8] = column2Row0;
    result[9] = column2Row1;
    result[10] = column2Row2;
    result[11] = 0.0;
    result[12] = matrix[12];
    result[13] = matrix[13];
    result[14] = matrix[14];
    result[15] = matrix[15];
    return result;
    };
    
    /**
    * Multiplies an affine transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
    * by an implicit non-uniform scale matrix.  This is an optimization
    * for <code>Matrix4.multiply(m, Matrix4.fromUniformScale(scale), m);</code>, where
    * <code>m</code> must be an affine matrix.
    * This function performs fewer allocations and arithmetic operations.
*
* @param {Matrix4} matrix The matrix on the left-hand side.
* @param {Cartesian3} translation The translation on the right-hand side.
* @param {Matrix4} result The object onto which to store the result.
* @returns {Matrix4} The modified result parameter.
*
* @example
* // Instead of Cesium.Matrix4.multiply(m, Cesium.Matrix4.fromTranslation(position), m);
* Cesium.Matrix4.multiplyByTranslation(m, position, m);
*/
Matrix4.multiplyByTranslation = function(matrix, translation, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
        throw new DeveloperError('matrix is required');
    }
    if (!defined(translation)) {
        throw new DeveloperError('translation is required');
    }
    if (!defined(result)) {
        throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    var x = translation.x;
    var y = translation.y;
    var z = translation.z;
    
    var tx = (x * matrix[0]) + (y * matrix[4]) + (z * matrix[8]) + matrix[12];
    var ty = (x * matrix[1]) + (y * matrix[5]) + (z * matrix[9]) + matrix[13];
    var tz = (x * matrix[2]) + (y * matrix[6]) + (z * matrix[10]) + matrix[14];
    
    result[0] = matrix[0];
    result[1] = matrix[1];
    result[2] = matrix[2];
    result[3] = matrix[3];
    result[4] = matrix[4];
    result[5] = matrix[5];
    result[6] = matrix[6];
    result[7] = matrix[7];
    result[8] = matrix[8];
    result[9] = matrix[9];
    result[10] = matrix[10];
    result[11] = matrix[11];
    result[12] = tx;
    result[13] = ty;
    result[14] = tz;
    result[15] = matrix[15];
    return result;
};

var uniformScaleScratch = new Cartesian3();

/**
* Multiplies a transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
* by an implicit uniform scale matrix.  This is an optimization
* for <code>Matrix4.multiply(m, Matrix4.fromUniformScale(scale), m);</code> with less allocations and arithmetic operations.
*
* @param {Matrix4} matrix The matrix on the left-hand side.
* @param {Number} scale The uniform scale on the right-hand side.
* @param {Matrix4} result The object onto which to store the result.
* @returns {Matrix4} The modified result parameter.
*
* @see Matrix4.fromUniformScale
* @see Matrix4.multiplyByScale
*
* @example
* // Instead of Cesium.Matrix4.multiply(m, Cesium.Matrix4.fromUniformScale(scale), m);
* Cesium.Matrix4.multiplyByUniformScale(m, scale, m);
*/
Matrix4.multiplyByUniformScale = function(matrix, scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
        throw new DeveloperError('matrix is required');
    }
    if (typeof scale !== 'number') {
        throw new DeveloperError('scale is required');
    }
    if (!defined(result)) {
        throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    uniformScaleScratch.x = scale;
    uniformScaleScratch.y = scale;
    uniformScaleScratch.z = scale;
    return Matrix4.multiplyByScale(matrix, uniformScaleScratch, result);
};

/**
* Multiplies a transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
* by an implicit non-uniform scale matrix.  This is an optimization
* for <code>Matrix4.multiply(m, Matrix4.fromScale(scale), m);</code> with less allocations and arithmetic operations.
*
* @param {Matrix4} matrix The matrix on the left-hand side.
* @param {Cartesian3} scale The non-uniform scale on the right-hand side.
* @param {Matrix4} result The object onto which to store the result.
* @returns {Matrix4} The modified result parameter.
*
* @see Matrix4.fromScale
* @see Matrix4.multiplyByUniformScale
*
* @example
* // Instead of Cesium.Matrix4.multiply(m, Cesium.Matrix4.fromScale(scale), m);
* Cesium.Matrix4.multiplyByUniformScale(m, scale, m);
*/
Matrix4.multiplyByScale = function(matrix, scale, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
        throw new DeveloperError('matrix is required');
    }
    if (!defined(scale)) {
        throw new DeveloperError('scale is required');
    }
    if (!defined(result)) {
        throw new DeveloperError('result is required,');
    }
    //>>includeEnd('debug');
    
    var scaleX = scale.x;
    var scaleY = scale.y;
    var scaleZ = scale.z;
    
    // Faster than Cartesian3.equals
    if ((scaleX === 1.0) && (scaleY === 1.0) && (scaleZ === 1.0)) {
        return Matrix4.clone(matrix, result);
    }
    
    result[0] = scaleX * matrix[0];
    result[1] = scaleX * matrix[1];
    result[2] = scaleX * matrix[2];
    result[3] = 0.0;
    result[4] = scaleY * matrix[4];
    result[5] = scaleY * matrix[5];
    result[6] = scaleY * matrix[6];
    result[7] = 0.0;
    result[8] = scaleZ * matrix[8];
    result[9] = scaleZ * matrix[9];
    result[10] = scaleZ * matrix[10];
    result[11] = 0.0;
    result[12] = matrix[12];
    result[13] = matrix[13];
    result[14] = matrix[14];
    result[15] = 1.0;
    return result;
};
    */

     /**
     * Computes the product of a matrix and a column vector.
     *
     * @param {Matrix4} matrix The matrix.
     * @param {Cartesian4} cartesian The vector.
     * @param {Cartesian4} result The object onto which to store the result.
     * @returns {Cartesian4} The modified result parameter.
     */
    func multiplyByVector(_ cartesian: Cartesian4) -> Cartesian4 {
        return Cartesian4(simd: self.simdType * cartesian.simdType)
    }

    /**
    * Computes the product of a matrix and a {@link Cartesian3}.  This is equivalent to calling {@link Matrix4.multiplyByVector}
    * with a {@link Cartesian4} with a <code>w</code> component of zero.
    *
    * @param {Matrix4} matrix The matrix.
    * @param {Cartesian3} cartesian The point.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter.
    *
    * @example
    * var p = new Cesium.Cartesian3(1.0, 2.0, 3.0);
    * Cesium.Matrix4.multiplyByPointAsVector(matrix, p, result);
    * // A shortcut for
    * //   Cartesian3 p = ...
    * //   Cesium.Matrix4.multiplyByVector(matrix, new Cesium.Cartesian4(p.x, p.y, p.z, 0.0), result);
    */
    func multiplyByPointAsVector (_ cartesian: Cartesian3) -> Cartesian3 {
        let vector = simdType * double4(cartesian.x, cartesian.y, cartesian.z, 0.0)
        return Cartesian3(x: vector.x, y: vector.y, z: vector.z)
    }

    /**
     * Computes the product of a matrix and a {@link Cartesian3}. This is equivalent to calling {@link Matrix4.multiplyByVector}
     * with a {@link Cartesian4} with a <code>w</code> component of 1, but returns a {@link Cartesian3} instead of a {@link Cartesian4}.
     *
     * @param {Matrix4} matrix The matrix.
     * @param {Cartesian3} cartesian The point.
     * @param {Cartesian3} result The object onto which to store the result.
     * @returns {Cartesian3} The modified result parameter.
     *
     * @example
     * var p = new Cesium.Cartesian3(1.0, 2.0, 3.0);
     * Cesium.Matrix4.multiplyByPoint(matrix, p, result);
     */
    func multiplyByPoint (_ cartesian: Cartesian3) -> Cartesian3 {
        let vector = simdType * double4(cartesian.x, cartesian.y, cartesian.z, 1.0)
        return Cartesian3(x: vector.x, y: vector.y, z: vector.z)
    }
    /*
    /**
    * Computes the product of a matrix and a scalar.
    *
    * @param {Matrix4} matrix The matrix.
    * @param {Number} scalar The number to multiply by.
    * @param {Matrix4} result The object onto which to store the result.
    * @returns {Matrix4} The modified result parameter.
    *
    * @example
    * //create a Matrix4 instance which is a scaled version of the supplied Matrix4
    * // m = [10.0, 11.0, 12.0, 13.0]
    * //     [14.0, 15.0, 16.0, 17.0]
    * //     [18.0, 19.0, 20.0, 21.0]
    * //     [22.0, 23.0, 24.0, 25.0]
    *
    * var a = Cesium.Matrix4.multiplyByScalar(m, -2);
    *
    * // m remains the same
    * // a = [-20.0, -22.0, -24.0, -26.0]
    * //     [-28.0, -30.0, -32.0, -34.0]
    * //     [-36.0, -38.0, -40.0, -42.0]
    * //     [-44.0, -46.0, -48.0, -50.0]
    */
Matrix4.multiplyByScalar = function(matrix, scalar, result) {
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
    result[9] = matrix[9] * scalar;
    result[10] = matrix[10] * scalar;
    result[11] = matrix[11] * scalar;
    result[12] = matrix[12] * scalar;
    result[13] = matrix[13] * scalar;
    result[14] = matrix[14] * scalar;
    result[15] = matrix[15] * scalar;
    return result;
};

     /**
* Computes a matrix, which contains the absolute (unsigned) values of the provided matrix's elements.
*
* @param {Matrix4} matrix The matrix with signed elements.
* @param {Matrix4} result The object onto which to store the result.
* @returns {Matrix4} The modified result parameter.
*/
Matrix4.abs = function(matrix, result) {
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
    result[9] = Math.abs(matrix[9]);
    result[10] = Math.abs(matrix[10]);
    result[11] = Math.abs(matrix[11]);
    result[12] = Math.abs(matrix[12]);
    result[13] = Math.abs(matrix[13]);
    result[14] = Math.abs(matrix[14]);
    result[15] = Math.abs(matrix[15]);
    
    return result;
};
*/

    
    /**
    * Gets the translation portion of the provided matrix, assuming the matrix is a affine transformation matrix.
    *
    * @param {Matrix4} matrix The matrix to use.
    * @param {Cartesian3} result The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter.
    */
    var translation: Cartesian3 {
        let column3 = simdType[3]
        return Cartesian3(x: column3.x, y: column3.y, z: column3.z)
    }

    /**
    * Gets the upper left 3x3 rotation matrix of the provided matrix, assuming the matrix is a affine transformation matrix.
    *
    * @param {Matrix4} matrix The matrix to use.
    * @param {Matrix3} result The object onto which to store the result.
    * @returns {Matrix3} The modified result parameter.
    *
    * @example
    * // returns a Matrix3 instance from a Matrix4 instance
    *
    * // m = [10.0, 14.0, 18.0, 22.0]
    * //     [11.0, 15.0, 19.0, 23.0]
    * //     [12.0, 16.0, 20.0, 24.0]
    * //     [13.0, 17.0, 21.0, 25.0]
    *
    * var b = new Cesium.Matrix3();
    * Cesium.Matrix4.getRotation(m,b);
    *
    * // b = [10.0, 14.0, 18.0]
    * //     [11.0, 15.0, 19.0]
    * //     [12.0, 16.0, 20.0]
    */
    var rotation: Matrix3 {
        let column0 = simdType[0]
        let column1 = simdType[1]
        let column2 = simdType[2]
        
        return Matrix3(
            column0.x, column1.x, column2.x,
            column0.y, column1.y, column2.y,
            column0.z, column1.z, column2.z)
    }
    
    var inverse: Matrix4 {
        // Special case for a zero scale matrix that can occur, for example,
        // when a model's node has a [0, 0, 0] scale.
        if rotation.equalsEpsilon(Matrix3.zero, epsilon: Math.Epsilon7) && self[3] == Cartesian4.unitW {
            
            return Matrix4(simd: double4x4([
                double4(),
                double4(),
                double4(),
                double4(self[3,0], self[3,1], self[3,2], 1.0)])
            )
            /*result[0] = 0.0;
            result[1] = 0.0;
            result[2] = 0.0;
            result[3] = 0.0;
            result[4] = 0.0;
            result[5] = 0.0;
            result[6] = 0.0;
            result[7] = 0.0;
            result[8] = 0.0;
            result[9] = 0.0;
            result[10] = 0.0;
            result[11] = 0.0;
            result[12] = -matrix[12];
            result[13] = -matrix[13];
            result[14] = -matrix[14];
            result[15] = 1.0;
            return result;*/
        }
        return Matrix4(simd: simdType.inverse)
    }
    
    /**
    * An immutable Matrix4 instance initialized to the identity matrix.
    *
    * @type {Matrix4}
    * @constant
    */
    static let identity = Matrix4(1.0)
    
    static let zero = Matrix4()

    /**
    * @private
    */
    func equalsArray (_ array: [Float], offset: Int) -> Bool {
        let other = Matrix4.unpack(array, startingIndex: offset)
        return self == other
    }
    
}

extension Matrix4: Packable {
    
    var length: Int {
        return Matrix4.packedLength()
    }
    
    static func packedLength () -> Int {
        return 16
    }
    
    init(array: [Double], startingIndex: Int = 0) {
        self.init()
        assert(checkPackedArrayLength(array, startingIndex: startingIndex), "Invalid packed array length")
        _ = array.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Double>) in
            memcpy(&self, pointer.baseAddress, Matrix4.packedLength() * MemoryLayout<Double>.stride)
        }
    }
    
}

extension Matrix4: Equatable {}

/**
* Compares the provided matrices componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {Matrix4} [left] The first matrix.
* @param {Matrix4} [right] The second matrix.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*
* @example
* //compares two Matrix4 instances
*
* // a = [10.0, 14.0, 18.0, 22.0]
* //     [11.0, 15.0, 19.0, 23.0]
* //     [12.0, 16.0, 20.0, 24.0]
* //     [13.0, 17.0, 21.0, 25.0]
*
* // b = [10.0, 14.0, 18.0, 22.0]
* //     [11.0, 15.0, 19.0, 23.0]
* //     [12.0, 16.0, 20.0, 24.0]
* //     [13.0, 17.0, 21.0, 25.0]
*
* if(Cesium.Matrix4.equals(a,b)) {
*      console.log("Both matrices are equal");
* } else {
*      console.log("They are not equal");
* }
*
* //Prints "Both matrices are equal" on the console
*/
public func == (left: Matrix4, right: Matrix4) -> Bool {
    return left.equals(right)
}

