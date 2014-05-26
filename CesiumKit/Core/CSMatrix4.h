//
//  CSMatrix4.h
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSMatrix3, CSQuarternion, CSCartesian3, CSCartesian4, CSCamera, CSBoundingRectangle;

static const UInt32 Column0Row0 = 0;
static const UInt32 Column0Row1 = 1;
static const UInt32 Column0Row2 = 2;
static const UInt32 Column0Row3 = 3;
static const UInt32 Column1Row0 = 4;
static const UInt32 Column1Row1 = 5;
static const UInt32 Column1Row2 = 6;
static const UInt32 Column1Row3 = 7;
static const UInt32 Column2Row0 = 8;
static const UInt32 Column2Row1 = 9;
static const UInt32 Column2Row2 = 10;
static const UInt32 Column2Row3 = 11;
static const UInt32 Column3Row0 = 12;
static const UInt32 Column3Row1 = 13;
static const UInt32 Column3Row2 = 14;
static const UInt32 Column3Row3 = 15;

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

@interface CSMatrix4 : NSObject <NSCopying>

@property (readonly) NSArray *data;

@property (readonly) UInt32 packedLength;

-(Float64)column0Row0;
-(Float64)column1Row0;
-(Float64)column2Row0;
-(Float64)column3Row0;
-(Float64)column0Row1;
-(Float64)column1Row1;
-(Float64)column2Row1;
-(Float64)column3Row1;
-(Float64)column0Row2;
-(Float64)column1Row2;
-(Float64)column2Row2;
-(Float64)column3Row2;
-(Float64)column0Row3;
-(Float64)column1Row3;
-(Float64)column2Row3;
-(Float64)column3Row3;


-(id)initWithColumn0Row0:(Float64)column0Row0 column1Row0:(Float64)column1Row0 column2Row0:(Float64)column2Row0 column3Row0:(Float64)column3Row0
             column0Row1:(Float64)column1Row0 column1Row1:(Float64)column1Row1 column2Row1:(Float64)column2Row1 column3Row1:(Float64)column3Row1
             column0Row2:(Float64)column2Row0 column1Row2:(Float64)column1Row2 column2Row2:(Float64)column2Row2 column3Row2:(Float64)column3Row2
             column0Row3:(Float64)column3Row0 column1Row3:(Float64)column1Row3 column2Row3:(Float64)column2Row3 column3Row3:(Float64)column3Row3;

/**
 * The number of elements used to pack the object into an array.
 * @Type {Number}
 */

/**
 * Stores the provided instance into the provided array.
 * @memberof Matrix4
 *
 * @param {Matrix4} value The value to pack.
 * @param {Array} array The array to pack into.
 * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
 */
-(void)pack:(Float64 *)array startingIndex:(UInt32)startingIndex;
    
/**
 * Retrieves an instance from a packed array.
 * @memberof Matrix4
 *
 * @param {Array} array The packed array.
 * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
 * @param {Matrix4} [result] The object into which to store the result.
 */
+(CSMatrix4 *)unpack:(Float64 *)array startingIndex:(UInt32)startingIndex;

/**
 * Creates a Matrix4 from 16 consecutive elements in an array.
 * @memberof Matrix4
 *
 * @param {Array} array The array whose 16 consecutive elements correspond to the positions of the matrix.  Assumes column-major order.
 * @param {Number} [startingIndex=0] The offset into the array of the first element, which corresponds to first column first row position in the matrix.
 * @param {Matrix4} [result] The object onto which to store the result.
 *
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
+(CSMatrix4 *)fromArray:(Float64 *)array;

/**
 * Computes a Matrix4 instance from a column-major order array.
 * @memberof Matrix4
 * @function
 *
 * @param {Array} values The column-major order array.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)fromColumnMajorArray:(Float64 *)array;

/**
 * Computes a Matrix4 instance from a row-major order array.
 * The resulting matrix will be in column-major order.
 * @memberof Matrix4
 *
 * @param {Array} values The row-major order array.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)fromRowMajorArray:(Float64 *)array;

/**
 * Computes a Matrix4 instance from a Matrix3 representing the rotation
 * and a Cartesian3 representing the translation.
 * @memberof Matrix4
 *
 * @param {Matrix3} rotation The upper left portion of the matrix representing the rotation.
 * @param {Cartesian3} translation The upper right portion of the matrix representing the translation.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)fromRotation:(CSMatrix3 *)rotation translation:(CSCartesian3 *)translation;

/**
 * Computes a Matrix4 instance from a translation, rotation, and scale (TRS)
 * representation with the rotation represented as a quaternion.
 *
 * @memberof Matrix4
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
+(CSMatrix4 *)fromTranslation:(CSCartesian3 *)translation rotation:(CSQuarternion *)rotation scale:(CSCartesian3 *)scale;

/**
 * Creates a Matrix4 instance from a Cartesian3 representing the translation.
 * @memberof Matrix4
 *
 * @param {Cartesian3} translation The upper right portion of the matrix representing the translation.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 *
 * @see Matrix4.multiplyByTranslation
 */
+(CSMatrix4 *)fromTranslation:(CSCartesian3 *)translation;

/**
 * Computes a Matrix4 instance representing a non-uniform scale.
 * @memberof Matrix4
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
+(CSMatrix4 *)fromScale:(CSCartesian3 *)scale;

/**
 * Computes a Matrix4 instance representing a uniform scale.
 * @memberof Matrix4
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
+(CSMatrix4 *)fromUniformScale:(CSCartesian3 *)scale;

/**
 * Computes a Matrix4 instance from a Camera.
 * @memberof Matrix4
 *
 * @param {Camera} camera The camera to use.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)fromCamera:(CSCamera *)camera;

/**
 * Computes a Matrix4 instance representing a perspective transformation matrix.
 * @memberof Matrix4
 *
 * @param {Number} fovY The field of view along the Y axis in radians.
 * @param {Number} aspectRatio The aspect ratio.
 * @param {Number} near The distance to the near plane in meters.
 * @param {Number} far The distance to the far plane in meters.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 *
 * @exception {DeveloperError} fovY must be in [0, PI).
 * @exception {DeveloperError} aspectRatio must be greater than zero.
 * @exception {DeveloperError} near must be greater than zero.
 * @exception {DeveloperError} far must be greater than zero.
 */
+(CSMatrix4 *)computePerspectiveFieldOfView:(Float64)fovY aspectRatio:(Float64)aspectRatio near:(Float64)near far:(Float64)far;

/**
 * Computes a Matrix4 instance representing an orthographic transformation matrix.
 * @memberof Matrix4
 *
 * @param {Number} left The number of meters to the left of the camera that will be in view.
 * @param {Number} right The number of meters to the right of the camera that will be in view.
 * @param {Number} bottom The number of meters below of the camera that will be in view.
 * @param {Number} top The number of meters above of the camera that will be in view.
 * @param {Number} near The distance to the near plane in meters.
 * @param {Number} far The distance to the far plane in meters.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)computeOrthographicOffCenter:(Float64)left right:(Float64)right bottom:(Float64)bottom top:(Float64)top near:(Float64)near far:(Float64)far;

/**
 * Computes a Matrix4 instance representing an off center perspective transformation.
 * @memberof Matrix4
 *
 * @param {Number} left The number of meters to the left of the camera that will be in view.
 * @param {Number} right The number of meters to the right of the camera that will be in view.
 * @param {Number} bottom The number of meters below of the camera that will be in view.
 * @param {Number} top The number of meters above of the camera that will be in view.
 * @param {Number} near The distance to the near plane in meters.
 * @param {Number} far The distance to the far plane in meters.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)computePerspectiveOffCenter:(Float64)left right:(Float64)right bottom:(Float64)bottom top:(Float64)top near:(Float64)near far:(Float64)far;

/**
 * Computes a Matrix4 instance representing an infinite off center perspective transformation.
 * @memberof Matrix4
 *
 * @param {Number} left The number of meters to the left of the camera that will be in view.
 * @param {Number} right The number of meters to the right of the camera that will be in view.
 * @param {Number} bottom The number of meters below of the camera that will be in view.
 * @param {Number} top The number of meters above of the camera that will be in view.
 * @param {Number} near The distance to the near plane in meters.
 * @param {Number} far The distance to the far plane in meters.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 */
+(CSMatrix4 *)computeInfinitePerspectiveOffCenter:(Float64)left right:(Float64)right bottom:(Float64)bottom top:(Float64)top near:(Float64)near far:(Float64)far;

/**
 * Computes a Matrix4 instance that transforms from normalized device coordinates to window coordinates.
 * @memberof Matrix4
 *
 * @param {Object}[viewport = { x : 0.0, y : 0.0, width : 0.0, height : 0.0 }] The viewport's corners as shown in Example 1.
 * @param {Number}[nearDepthRange = 0.0] The near plane distance in window coordinates.
 * @param {Number}[farDepthRange = 1.0] The far plane distance in window coordinates.
 * @param {Matrix4} [result] The object in which the result will be stored, if undefined a new instance will be created.
 * @returns The modified result parameter, or a new Matrix4 instance if one was not provided.
 *
 * @see czm_viewportTransformation
 * @see Context#getViewport
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
 * // Example 2.  Create viewport transformation using the context's viewport.
 * var m = Cesium.Matrix4.computeViewportTransformation(context.getViewport());
 */
+(CSMatrix4 *)computeViewportTransformation:(CSBoundingRectangle *)viewport nearDepthRange:(Float64)nearDepthRange farDepthRange:(Float64)farDepthRange;

/**
 * Computes an Array from the provided Matrix4 instance.
 * The array will be in column-major order.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use..
 * @param {Array} [result] The Array onto which to store the result.
 * @returns {Array} The modified Array parameter or a new Array instance if one was not provided.
 *
 * @example
 * //create an array from an instance of Matrix4
 * // m = [10.0, 14.0, 18.0, 22.0]
 * //     [11.0, 15.0, 19.0, 23.0]
 * //     [12.0, 16.0, 20.0, 24.0]
 * //     [13.0, 17.0, 21.0, 25.0]
 * var a = Cesium.Matrix4.toArray(m);
 *
 * // m remains the same
 * //creates a = [10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0]
 */
-(NSArray *)toArray;

/**
 * Computes the array index of the element at the provided row and column.
 * @memberof Matrix4
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
-(Float64)getElementForColumn:(UInt32)column row:(UInt32)row;

/**
 * Retrieves a copy of the matrix column at the provided index as a Cartesian4 instance.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use.
 * @param {Number} index The zero-based index of the column to retrieve.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 *
 * @exception {DeveloperError} index must be 0, 1, 2, or 3.
 *
 * @see Cartesian4
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
 * //Example 2: Sets values for Cartesian instance
 * var a = new Cesium.Cartesian4();
 * Cesium.Matrix4.getColumn(m, 2, a);
 *
 * // a.x = 12.0; a.y = 16.0; a.z = 20.0; a.w = 24.0;
 */
-(CSCartesian4 *)getColumn:(UInt32)column;

/**
 * Computes a new matrix that replaces the specified column in the provided matrix with the provided Cartesian4 instance.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use.
 * @param {Number} index The zero-based index of the column to set.
 * @param {Cartesian4} cartesian The Cartesian whose values will be assigned to the specified column.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @exception {DeveloperError} index must be 0, 1, 2, or 3.
 *
 * @see Cartesian4
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
-(CSMatrix4 *)replaceColumn:(UInt32)column withCartesian4:(CSCartesian4 *)cartesian4;

/**
 * Retrieves a copy of the matrix row at the provided index as a Cartesian4 instance.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use.
 * @param {Number} index The zero-based index of the row to retrieve.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 *
 * @exception {DeveloperError} index must be 0, 1, 2, or 3.
 *
 * @see Cartesian4
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
 * //Example 1: Sets values for a Cartesian instance
 * var a = new Cartesian4();
 * Cesium.Matrix4.getRow(m, 2, a);
 *
 * // a.x = 18.0; a.y = 19.0; a.z = 20.0; a.w = 21.0;
 */
-(CSCartesian4 *)getRow:(UInt32)row;

/**
 * Computes a new matrix that replaces the specified row in the provided matrix with the provided Cartesian4 instance.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use.
 * @param {Number} index The zero-based index of the row to set.
 * @param {Cartesian4} cartesian The Cartesian whose values will be assigned to the specified row.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @exception {DeveloperError} index must be 0, 1, 2, or 3.
 *
 * @see Cartesian4
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
-(CSMatrix4 *)replaceRow:(UInt32)row withCartesian4:(CSCartesian4 *)cartesian4;

/**
 * Extracts the non-uniform scale assuming the matrix is an affine transformation.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSCartesian3 *)getScale;

/**
 * Computes the maximum scale assuming the matrix is an affine transformation.
 * The maximum scale is the maximum length of the column vectors in the upper-left
 * 3x3 matrix.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix.
 * @returns {Number} The maximum scale.
 */
-(Float64)getMaximumScale;

/**
 * Computes the product of two matrices.
 * @memberof Matrix4
 *
 * @param {Matrix4} left The first matrix.
 * @param {Matrix4} right The second matrix.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 */
-(CSMatrix4 *)multiply:(CSMatrix4 *)other;

/**
 * Computes the product of two matrices assuming the matrices are
 * affine transformation matrices, where the upper left 3x3 elements
 * are a rotation matrix, and the upper three elements in the fourth
 * column are the translation.  The bottom row is assumed to be [0, 0, 0, 1].
 * The matrix is not verified to be in the proper form.
 * This method is faster than computing the product for general 4x4
 * matrices using {@link #multiply}.
 * @memberof Matrix4
 *
 * @param {Matrix4} left The first matrix.
 * @param {Matrix4} right The second matrix.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @example
 * var m1 = new Cesium.Matrix4(1.0, 6.0, 7.0, 0.0, 2.0, 5.0, 8.0, 0.0, 3.0, 4.0, 9.0, 0.0, 0.0, 0.0, 0.0, 1.0];
 * var m2 = Cesium.Transforms.eastNorthUpToFixedFrame(new Cesium.Cartesian3(1.0, 1.0, 1.0));
 * var m3 = Cesium.Matrix4.multiplyTransformation(m1, m2);
 */
-(CSMatrix4 *)multiplyTransformation:(CSMatrix4 *)other;

/**
 * Multiplies a transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
 * by an implicit translation matrix defined by a {@link Cartesian3}.  This is an optimization
 * for <code>Matrix4.multiply(m, Matrix4.fromTranslation(position), m);</code> with less allocations and arithmetic operations.
 *
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix on the left-hand side.
 * @param {Cartesian3} translation The translation on the right-hand side.
 * @param {Matrix4} [result] The object onto which to store the result.
 *
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @see Matrix4.fromTranslation
 *
 * @example
 * // Instead of Matrix4.multiply(m, Cesium.Matrix4.fromTranslation(position), m);
 * Cesium.Matrix4.multiplyByTranslation(m, position, m);
 */
-(CSMatrix4 *)multiplyByTranslation:(CSCartesian3 *)cartesian3;

/**
 * Multiplies a transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
 * by an implicit uniform scale matrix.  This is an optimization
 * for <code>Matrix4.multiply(m, Matrix4.fromUniformScale(scale), m);</code> with less allocations and arithmetic operations.
 *
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix on the left-hand side.
 * @param {Number} scale The uniform scale on the right-hand side.
 * @param {Matrix4} [result] The object onto which to store the result.
 *
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @see Matrix4.fromUniformScale
 * @see Matrix4.multiplyByScale
 *
 * @example
 * // Instead of Matrix4.multiply(m, Cesium.Matrix4.fromUniformScale(scale), m);
 * Cesium.Matrix4.multiplyByUniformScale(m, scale, m);
 */
-(CSMatrix4 *)multiplyByUniformScale:(Float64)scale;

/**
 * Multiplies a transformation matrix (with a bottom row of <code>[0.0, 0.0, 0.0, 1.0]</code>)
 * by an implicit non-uniform scale matrix.  This is an optimization
 * for <code>Matrix4.multiply(m, Matrix4.fromScale(scale), m);</code> with less allocations and arithmetic operations.
 *
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix on the left-hand side.
 * @param {Cartesian3} scale The non-uniform scale on the right-hand side.
 * @param {Matrix4} [result] The object onto which to store the result.
 *
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @see Matrix4.fromScale
 * @see Matrix4.multiplyByUniformScale
 *
 * @example
 * // Instead of Matrix4.multiply(m, Cesium.Matrix4.fromScale(scale), m);
 * Cesium.Matrix4.multiplyByUniformScale(m, scale, m);
 */
-(CSMatrix4 *)multiplyByScale:(CSCartesian3 *)scale;

/**
 * Computes the product of a matrix and a column vector.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix.
 * @param {Cartesian4} cartesian The vector.
 * @param {Cartesian4} [result] The object onto which to store the result.
 * @returns {Cartesian4} The modified result parameter or a new Cartesian4 instance if one was not provided.
 */
-(CSMatrix4 *)multiplyByVector:(CSCartesian4 *)scale;

/**
 * Computes the product of a matrix and a {@link Cartesian3}.  This is equivalent to calling {@link Matrix4.multiplyByVector}
 * with a {@link Cartesian4} with a <code>w</code> component of zero.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix.
 * @param {Cartesian3} cartesian The point.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 *
 * @example
 * var p = new Cesium.Cartesian3(1.0, 2.0, 3.0);
 * Cesium.Matrix4.multiplyByPointAsVector(matrix, p, result);
 * // A shortcut for
 * //   Cartesian3 p = ...
 * //   Cesium.Matrix4.multiplyByVector(matrix, new Cesium.Cartesian4(p.x, p.y, p.z, 0.0), result);
 */
-(CSCartesian3 *)multiplyByPointAsVector:(CSCartesian3 *)point;

/**
 * Computes the product of a matrix and a {@link Cartesian3}. This is equivalent to calling {@link Matrix4.multiplyByVector}
 * with a {@link Cartesian4} with a <code>w</code> component of 1, but returns a {@link Cartesian3} instead of a {@link Cartesian4}.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix.
 * @param {Cartesian3} cartesian The point.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 *
 * @example
 * var p = new Cesium.Cartesian3(1.0, 2.0, 3.0);
 * Cesium.Matrix4.multiplyByPoint(matrix, p, result);
 */
-(CSCartesian3 *)multiplyByPoint:(CSCartesian3 *)point;

/**
 * Computes the product of a matrix and a scalar.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix.
 * @param {Number} scalar The number to multiply by.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Cartesian4 instance if one was not provided.
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
-(CSMatrix4 *)multiplyByScalar:(Float64)scalar;

/**
 * Computes a negated copy of the provided matrix.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to negate.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @example
 * //create a new Matrix4 instance which is a negation of a Matrix4
 * // m = [10.0, 11.0, 12.0, 13.0]
 * //     [14.0, 15.0, 16.0, 17.0]
 * //     [18.0, 19.0, 20.0, 21.0]
 * //     [22.0, 23.0, 24.0, 25.0]
 *
 * var a = Cesium.Matrix4.negate(m);
 *
 * // m remains the same
 * // a = [-10.0, -11.0, -12.0, -13.0]
 * //     [-14.0, -15.0, -16.0, -17.0]
 * //     [-18.0, -19.0, -20.0, -21.0]
 * //     [-22.0, -23.0, -24.0, -25.0]
 */
-(CSMatrix4 *)negate;

/**
 * Computes the transpose of the provided matrix.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to transpose.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *
 * @example
 * //returns transpose of a Matrix4
 * // m = [10.0, 11.0, 12.0, 13.0]
 * //     [14.0, 15.0, 16.0, 17.0]
 * //     [18.0, 19.0, 20.0, 21.0]
 * //     [22.0, 23.0, 24.0, 25.0]
 *
 * var a = Cesium.Matrix4.negate(m);
 *
 * // m remains the same
 * // a = [10.0, 14.0, 18.0, 22.0]
 * //     [11.0, 15.0, 19.0, 23.0]
 * //     [12.0, 16.0, 20.0, 24.0]
 * //     [13.0, 17.0, 21.0, 25.0]
 */
-(CSMatrix4 *)transpose;

/**
 * Computes a matrix, which contains the absolute (unsigned) values of the provided matrix's elements.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix with signed elements.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 */
-(CSMatrix4 *)absolute;

/**
 * Compares the provided matrices componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Matrix4
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
-(BOOL)equal:(CSMatrix4 *)other;

/**
 * Compares the provided matrices componentwise and returns
 * <code>true</code> if they are within the provided epsilon,
 * <code>false</code> otherwise.
 * @memberof Matrix4
 *
 * @param {Matrix4} [left] The first matrix.
 * @param {Matrix4} [right] The second matrix.
 * @param {Number} epsilon The epsilon to use for equality testing.
 * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
 *
 * @example
 * //compares two Matrix4 instances
 *
 * // a = [10.5, 14.5, 18.5, 22.5]
 * //     [11.5, 15.5, 19.5, 23.5]
 * //     [12.5, 16.5, 20.5, 24.5]
 * //     [13.5, 17.5, 21.5, 25.5]
 *
 * // b = [10.0, 14.0, 18.0, 22.0]
 * //     [11.0, 15.0, 19.0, 23.0]
 * //     [12.0, 16.0, 20.0, 24.0]
 * //     [13.0, 17.0, 21.0, 25.0]
 *
 * if(Cesium.Matrix4.equalsEpsilon(a,b,0.1)){
 *      console.log("Difference between both the matrices is less than 0.1");
 * } else {
 *      console.log("Difference between both the matrices is not less than 0.1");
 * }
 *
 * //Prints "Difference between both the matrices is not less than 0.1" on the console
 */
-(BOOL)equals:(CSMatrix4 *)other epsilon:(Float64)epsilon;

/**
 * Gets the translation portion of the provided matrix, assuming the matrix is a affine transformation matrix.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use.
 * @param {Cartesian3} [result] The object onto which to store the result.
 * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 *
 * @see Cartesian3
 */
-(CSCartesian3 *)getTranslation;

/**
 * Gets the upper left 3x3 rotation matrix of the provided matrix, assuming the matrix is a affine transformation matrix.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to use.
 * @param {Matrix3} [result] The object onto which to store the result.
 * @returns {Matrix3} The modified result parameter or a new Cartesian3 instance if one was not provided.
 *
 * @see Matrix3
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
-(CSMatrix3 *)getRotation;

/**
 * Computes the inverse of the provided matrix using Cramers Rule.
 * If the determinant is zero, the matrix can not be inverted, and an exception is thrown.
 * If the matrix is an affine transformation matrix, it is more efficient
 * to invert it with {@link #inverseTransformation}.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to invert.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Cartesian3 instance if one was not provided.
 *
 * @exception {RuntimeError} matrix is not invertible because its determinate is zero.
 */
-(CSMatrix4 *)inverse;

/**
 * Computes the inverse of the provided matrix assuming it is
 * an affine transformation matrix, where the upper left 3x3 elements
 * are a rotation matrix, and the upper three elements in the fourth
 * column are the translation.  The bottom row is assumed to be [0, 0, 0, 1].
 * The matrix is not verified to be in the proper form.
 * This method is faster than computing the inverse for a general 4x4
 * matrix using {@link #inverse}.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to invert.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Cartesian3 instance if one was not provided.
 */
-(CSMatrix4 *)inverseTransformation;

/**
 * An immutable Matrix4 instance initialized to the identity matrix.
 * @memberof Matrix4
 */
/*Matrix4.IDENTITY = freezeObject(new Matrix4(1.0, 0.0, 0.0, 0.0,
                                            0.0, 1.0, 0.0, 0.0,
                                            0.0, 0.0, 1.0, 0.0,
                                            0.0, 0.0, 0.0, 1.0));*/



/**
 * Duplicates the provided Matrix4 instance.
 * @memberof Matrix4
 *
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided.
 *//*
Matrix4.prototype.clone = function(result) {
    return Matrix4.clone(this, result);
};

/**
 * Compares this matrix to the provided matrix componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof Matrix4
 *
 * @param {Matrix4} [right] The right hand side matrix.
 * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
 */
/*Matrix4.prototype.equals = function(right) {
    return Matrix4.equals(this, right);
};

/**
 * Compares this matrix to the provided matrix componentwise and returns
 * <code>true</code> if they are within the provided epsilon,
 * <code>false</code> otherwise.
 * @memberof Matrix4
 *
 * @param {Matrix4} [right] The right hand side matrix.
 * @param {Number} epsilon The epsilon to use for equality testing.
 * @returns {Boolean} <code>true</code> if they are within the provided epsilon, <code>false</code> otherwise.
 */
/*Matrix4.prototype.equalsEpsilon = function(right, epsilon) {
    return Matrix4.equalsEpsilon(this, right, epsilon);
};

/**
 * Computes a string representing this Matrix with each row being
 * on a separate line and in the format '(column0, column1, column2, column3)'.
 * @memberof Matrix4
 *
 * @returns {String} A string representing the provided Matrix with each row being on a separate line and in the format '(column0, column1, column2, column3)'.
 */
/*Matrix4.prototype.toString = function() {
    return '(' + this[0] + ', ' + this[4] + ', ' + this[8] + ', ' + this[12] +')\n' +
    '(' + this[1] + ', ' + this[5] + ', ' + this[9] + ', ' + this[13] +')\n' +
    '(' + this[2] + ', ' + this[6] + ', ' + this[10] + ', ' + this[14] +')\n' +
    '(' + this[3] + ', ' + this[7] + ', ' + this[11] + ', ' + this[15] +')';
};

/**
 * Duplicates a Matrix4 instance.
 * @memberof Matrix4
 *
 * @param {Matrix4} matrix The matrix to duplicate.
 * @param {Matrix4} [result] The object onto which to store the result.
 * @returns {Matrix4} The modified result parameter or a new Matrix4 instance if one was not provided. (Returns undefined if matrix is undefined)
 */
-(id)copyWithZone:(NSZone *)zone;

@end
