//
//  Quarternion.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A set of 4-dimensional coordinates used to represent rotation in 3-dimensional space.
* @alias Quaternion
* @constructor
*
* @param {Number} [x=0.0] The X component.
* @param {Number} [y=0.0] The Y component.
* @param {Number} [z=0.0] The Z component.
* @param {Number} [w=0.0] The W component.
*
* @see PackableForInterpolation
*/
struct Quaternion {
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
    
    init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0, w: Double = 0.0) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    /**
    * Computes a quaternion representing a rotation around an axis.
    * @memberof Quaternion
    *
    * @param {Cartesian3} axis The axis of rotation.
    * @param {Number} angle The angle in radians to rotate around the axis.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    init(fromAxis axis: Cartesian3, angle: Double) {
        var halfAngle = angle / 2.0
        var s = sin(halfAngle)
        var normAxis = axis.normalize()
        
        self.x = normAxis.x * s
        self.y = normAxis.y * s
        self.z = normAxis.z * s
        self.w = cos(halfAngle)
    }
    
    /**
    * Computes a Quaternion from the provided Matrix3 instance.
    * @memberof Quaternion
    *
    * @param {Matrix3} matrix The rotation matrix.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    *
    * @see Matrix3.fromQuaternion
    */
    init(fromRotationMatrix matrix: Matrix3) {
        
        var m00 = matrix[0, 0]
        var m11 = matrix[1, 1]
        var m22 = matrix[2, 2]
        
        var trace = m00 + m11 + m22
        
        var root: Double
        
        if (trace > 0.0) {
            // |w| > 1/2, may as well choose w > 1/2
            root = sqrt(trace + 1.0) // 2w
            w = 0.5 * root
            root = 0.5 / root // 1/(4w)
            
            x = (matrix[1, 2] - matrix[2, 1]) * root
            y = (matrix[2, 0] - matrix[0, 2]) * root
            z = (matrix[0, 1] - matrix[1, 0]) * root
        }
        else {
            // |w| <= 1/2
            var next = [1, 2, 0]
            var quat = Array(count: 3, repeatedValue: 0.0)
            
            var i = 0
            if (m11 > m00) {
                i = 1
            }
            if (m22 > m00 && m22 > m11) {
                i = 2
            }
            var j = next[i]
            var k = next[j]
            
            root = sqrt(matrix[i, i] - matrix[j, j] - matrix[k, k] + 1.0)
            
            quat[i] = 0.5 * root
            root = 0.5 / root
            self.w = (matrix[k, j] - matrix[j, k]) * root
            quat[j] = (matrix[j, i] + matrix[i, j]) * root
            quat[k] = (matrix[k, i] + matrix[i, k]) * root
            
            x = -quat[0]
            y = -quat[1]
            z = -quat[2]
        }
    }
    
    /**
    * Computes a rotation from the given heading, pitch and roll angles. Heading is the rotation about the
    * negative z axis. Pitch is the rotation about the negative y axis. Roll is the rotation about
    * the positive x axis.
    *
    * @param {Number} heading The heading angle in radians.
    * @param {Number} pitch The pitch angle in radians.
    * @param {Number} roll The roll angle in radians.
    * @param {Quaternion} result The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if none was provided.
    */
    init(fromHeading heading: Double, pitch: Double, roll: Double) {

        let HPRQuaternion =
            Quaternion(fromAxis: Cartesian3.unitZ(), angle: -heading) * // heading
            Quaternion(fromAxis: Cartesian3.unitY(), angle: -pitch) * // pitch
            Quaternion(fromAxis: Cartesian3.unitX(), angle: roll) // roll
        
        self.init(x: HPRQuaternion.x, y: HPRQuaternion.y, z: HPRQuaternion.z, w: HPRQuaternion.w)
    }

    /*
    var sampledQuaternionAxis = new Cartesian3();
    var sampledQuaternionRotation = new Cartesian3();
    var sampledQuaternionTempQuaternion = new Quaternion();
    var sampledQuaternionQuaternion0 = new Quaternion();
    var sampledQuaternionQuaternion0Conjugate = new Quaternion();
    
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    Quaternion.packedLength = 4;
    
    /**
    * Stores the provided instance into the provided array.
    * @memberof Quaternion
    *
    * @param {Quaternion} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    Quaternion.pack = function(value, array, startingIndex) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(value)) {
    throw new DeveloperError('value is required');
    }
    
    if (!defined(array)) {
    throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    array[startingIndex++] = value.x;
    array[startingIndex++] = value.y;
    array[startingIndex++] = value.z;
    array[startingIndex] = value.w;
    };
    
    /**
    * Retrieves an instance from a packed array.
    * @memberof Quaternion
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Quaternion} [result] The object into which to store the result.
    */
    Quaternion.unpack = function(array, startingIndex, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(array)) {
    throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    if (!defined(result)) {
    result = new Quaternion();
    }
    result.x = array[startingIndex];
    result.y = array[startingIndex + 1];
    result.z = array[startingIndex + 2];
    result.w = array[startingIndex + 3];
    return result;
    };
    
    /**
    * The number of elements used to store the object into an array in its interpolatable form.
    * @type {Number}
    */
    Quaternion.packedInterpolationLength = 3;
    
    /**
    * Converts a packed array into a form suitable for interpolation.
    * @memberof Quaternion
    *
    * @param {Number[]} packedArray The packed array.
    * @param {Number} [startingIndex=0] The index of the first element to be converted.
    * @param {Number} [lastIndex=packedArray.length] The index of the last element to be converted.
    * @param {Number[]} [result] The object into which to store the result.
    */
    Quaternion.convertPackedArrayForInterpolation = function(packedArray, startingIndex, lastIndex, result) {
    Quaternion.unpack(packedArray, lastIndex * 4, sampledQuaternionQuaternion0Conjugate);
    Quaternion.conjugate(sampledQuaternionQuaternion0Conjugate, sampledQuaternionQuaternion0Conjugate);
    
    for (var i = 0, len = lastIndex - startingIndex + 1; i < len; i++) {
    var offset = i * 3;
    Quaternion.unpack(packedArray, (startingIndex + i) * 4, sampledQuaternionTempQuaternion);
    
    Quaternion.multiply(sampledQuaternionTempQuaternion, sampledQuaternionQuaternion0Conjugate, sampledQuaternionTempQuaternion);
    
    if (sampledQuaternionTempQuaternion.w < 0) {
    Quaternion.negate(sampledQuaternionTempQuaternion, sampledQuaternionTempQuaternion);
    }
    
    Quaternion.getAxis(sampledQuaternionTempQuaternion, sampledQuaternionAxis);
    var angle = Quaternion.getAngle(sampledQuaternionTempQuaternion);
    result[offset] = sampledQuaternionAxis.x * angle;
    result[offset + 1] = sampledQuaternionAxis.y * angle;
    result[offset + 2] = sampledQuaternionAxis.z * angle;
    }
    };
    
    /**
    * Retrieves an instance from a packed array converted with {@link convertPackedArrayForInterpolation}.
    * @memberof Quaternion
    *
    * @param {Number[]} array The original packed array.
    * @param {Number[]} sourceArray The converted array.
    * @param {Number} [startingIndex=0] The startingIndex used to convert the array.
    * @param {Number} [lastIndex=packedArray.length] The lastIndex used to convert the array.
    * @param {Quaternion} [result] The object into which to store the result.
    */
    Quaternion.unpackInterpolationResult = function(array, sourceArray, firstIndex, lastIndex, result) {
    if (!defined(result)) {
    result = new Quaternion();
    }
    Cartesian3.fromArray(array, 0, sampledQuaternionRotation);
    var magnitude = Cartesian3.magnitude(sampledQuaternionRotation);
    
    Quaternion.unpack(sourceArray, lastIndex * 4, sampledQuaternionQuaternion0);
    
    if (magnitude === 0) {
    Quaternion.clone(Quaternion.IDENTITY, sampledQuaternionTempQuaternion);
    } else {
    Quaternion.fromAxisAngle(sampledQuaternionRotation, magnitude, sampledQuaternionTempQuaternion);
    }
    
    return Quaternion.multiply(sampledQuaternionTempQuaternion, sampledQuaternionQuaternion0, result);
    };
    
    /**
    * Duplicates a Quaternion instance.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to duplicate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided. (Returns undefined if quaternion is undefined)
    */
    Quaternion.clone = function(quaternion, result) {
    if (!defined(quaternion)) {
    return undefined;
    }
    
    if (!defined(result)) {
    return new Quaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
    }
    
    result.x = quaternion.x;
    result.y = quaternion.y;
    result.z = quaternion.z;
    result.w = quaternion.w;
    return result;
    };
    */
    /**
    * Computes the conjugate of the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to conjugate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    func conjugate () -> Quaternion {
        return Quaternion(x: -x, y: -y, z: -z, w: w)
    }
    
    /**
    * Computes magnitude squared for the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to conjugate.
    * @returns {Number} The magnitude squared.
    */
    func magnitudeSquared () -> Double {
        // FIXME: Compiler
        let x2: Double = x*x
        let y2: Double = y*y
        let z2: Double = z*z
        let w2: Double = w*w
        return  x2 + y2 + z2 + w2
        //return x*x + y*y + z*z + w*w
    }
    
    /**
    * Computes magnitude for the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to conjugate.
    * @returns {Number} The magnitude.
    */
    func magnitude () -> Double {
        return sqrt(magnitudeSquared())
    }
    
    /**
    * Computes the normalized form of the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to normalize.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    func normalize () -> Quaternion {
        let inverseMagnitude: Double = 1.0 / magnitude()
        return Quaternion(
            x: x * inverseMagnitude,
            y: y * inverseMagnitude,
            z: z * inverseMagnitude,
            w: w * inverseMagnitude
        )
    }
    
    /**
    * Computes the inverse of the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to normalize.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    
    func inverse () -> Quaternion {
        let result = conjugate()
        return multiplyByScalar(1.0 / magnitudeSquared())
    }
    /*
    /**
    * Computes the componentwise sum of two quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} left The first quaternion.
    * @param {Quaternion} right The second quaternion.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    Quaternion.add = function(left, right, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(left)) {
    throw new DeveloperError('left is required');
    }
    if (!defined(right)) {
    throw new DeveloperError('right is required');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Quaternion(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w);
    }
    result.x = left.x + right.x;
    result.y = left.y + right.y;
    result.z = left.z + right.z;
    result.w = left.w + right.w;
    return result;
    };
    
    /**
    * Computes the componentwise difference of two quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} left The first quaternion.
    * @param {Quaternion} right The second quaternion.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    Quaternion.subtract = function(left, right, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(left)) {
    throw new DeveloperError('left is required');
    }
    if (!defined(right)) {
    throw new DeveloperError('right is required');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Quaternion(left.x - right.x, left.y - right.y, left.z - right.z, left.w - right.w);
    }
    result.x = left.x - right.x;
    result.y = left.y - right.y;
    result.z = left.z - right.z;
    result.w = left.w - right.w;
    return result;
    };
    
    /**
    * Negates the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to be negated.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    Quaternion.negate = function(quaternion, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(quaternion)) {
    throw new DeveloperError('quaternion is required');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Quaternion(-quaternion.x, -quaternion.y, -quaternion.z, -quaternion.w);
    }
    result.x = -quaternion.x;
    result.y = -quaternion.y;
    result.z = -quaternion.z;
    result.w = -quaternion.w;
    return result;
    };
    
    /**
    * Computes the dot (scalar) product of two quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} left The first quaternion.
    * @param {Quaternion} right The second quaternion.
    * @returns {Number} The dot product.
    */
    Quaternion.dot = function(left, right) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(left)) {
    throw new DeveloperError('left is required');
    }
    if (!defined(right)) {
    throw new DeveloperError('right is required');
    }
    //>>includeEnd('debug');
    
    return left.x * right.x + left.y * right.y + left.z * right.z + left.w * right.w;
    };
    */
    /**
    * Computes the product of two quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} left The first quaternion.
    * @param {Quaternion} right The second quaternion.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    func multiply (other: Quaternion) -> Quaternion {
        
        let selfX = self.x
        let selfY = self.y
        let selfZ = self.z
        let selfW = self.w
        
        let otherX = other.x
        let otherY = other.y
        let otherZ = other.z
        let otherW = other.w
        
        let x = selfW * otherX + selfX * otherW + selfY * otherZ - selfZ * otherY
        let y = selfW * otherY - selfX * otherZ + selfY * otherW + selfZ * otherX
        let z = selfW * otherZ + selfX * otherY - selfY * otherX + selfZ * otherW
        let w = selfW * otherW - selfX * otherX - selfY * otherY - selfZ * otherZ
        
        return Quaternion(x: x, y: y, z: z, w: w)
    }
    
    /**
    * Multiplies the provided quaternion componentwise by the provided scalar.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to be scaled.
    * @param {Number} scalar The scalar to multiply with.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    func multiplyByScalar (scalar: Double) -> Quaternion {
        return Quaternion(x: x * scalar, y: y * scalar, z: z * scalar, w: w * scalar)
    }
    
    /*
    /**
    * Divides the provided quaternion componentwise by the provided scalar.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to be divided.
    * @param {Number} scalar The scalar to divide by.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    Quaternion.divideByScalar = function(quaternion, scalar, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(quaternion)) {
    throw new DeveloperError('quaternion is required');
    }
    if (typeof scalar !== 'number') {
    throw new DeveloperError('scalar is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    return new Quaternion(quaternion.x / scalar, quaternion.y / scalar, quaternion.z / scalar, quaternion.w / scalar);
    }
    result.x = quaternion.x / scalar;
    result.y = quaternion.y / scalar;
    result.z = quaternion.z / scalar;
    result.w = quaternion.w / scalar;
    return result;
    };
    
    /**
    * Computes the axis of rotation of the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to use.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    Quaternion.getAxis = function(quaternion, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(quaternion)) {
    throw new DeveloperError('quaternion is required');
    }
    //>>includeEnd('debug');
    
    var w = quaternion.w;
    if (Math.abs(w - 1.0) < CesiumMath.EPSILON6) {
    if (!defined(result)) {
    return new Cartesian3();
    }
    result.x = result.y = result.z = 0;
    return result;
    }
    
    var scalar = 1.0 / Math.sqrt(1.0 - (w * w));
    if (!defined(result)) {
    return new Cartesian3(quaternion.x * scalar, quaternion.y * scalar, quaternion.z * scalar);
    }
    result.x = quaternion.x * scalar;
    result.y = quaternion.y * scalar;
    result.z = quaternion.z * scalar;
    return result;
    };
    
    /**
    * Computes the angle of rotation of the provided quaternion.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The quaternion to use.
    * @returns {Number} The angle of rotation.
    */
    Quaternion.getAngle = function(quaternion) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(quaternion)) {
    throw new DeveloperError('quaternion is required');
    }
    //>>includeEnd('debug');
    
    if (Math.abs(quaternion.w - 1.0) < CesiumMath.EPSILON6) {
    return 0.0;
    }
    return 2.0 * Math.acos(quaternion.w);
    };
    
    var lerpScratch;
    /**
    * Computes the linear interpolation or extrapolation at t using the provided quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} start The value corresponding to t at 0.0.
    * @param {Quaternion} end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    Quaternion.lerp = function(start, end, t, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(start)) {
    throw new DeveloperError('start is required.');
    }
    if (!defined(end)) {
    throw new DeveloperError('end is required.');
    }
    if (typeof t !== 'number') {
    throw new DeveloperError('t is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    lerpScratch = Quaternion.multiplyByScalar(end, t, lerpScratch);
    result = Quaternion.multiplyByScalar(start, 1.0 - t, result);
    return Quaternion.add(lerpScratch, result, result);
    };
    
    var slerpEndNegated;
    var slerpScaledP;
    var slerpScaledR;
    /**
    * Computes the spherical linear interpolation or extrapolation at t using the provided quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} start The value corresponding to t at 0.0.
    * @param {Quaternion} end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    *
    * @see Quaternion#fastSlerp
    */
    Quaternion.slerp = function(start, end, t, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(start)) {
    throw new DeveloperError('start is required.');
    }
    if (!defined(end)) {
    throw new DeveloperError('end is required.');
    }
    if (typeof t !== 'number') {
    throw new DeveloperError('t is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    var dot = Quaternion.dot(start, end);
    
    // The angle between start must be acute. Since q and -q represent
    // the same rotation, negate q to get the acute angle.
    var r = end;
    if (dot < 0.0) {
    dot = -dot;
    r = slerpEndNegated = Quaternion.negate(end, slerpEndNegated);
    }
    
    // dot > 0, as the dot product approaches 1, the angle between the
    // quaternions vanishes. use linear interpolation.
    if (1.0 - dot < CesiumMath.EPSILON6) {
    return Quaternion.lerp(start, r, t, result);
    }
    
    var theta = Math.acos(dot);
    slerpScaledP = Quaternion.multiplyByScalar(start, Math.sin((1 - t) * theta), slerpScaledP);
    slerpScaledR = Quaternion.multiplyByScalar(r, Math.sin(t * theta), slerpScaledR);
    result = Quaternion.add(slerpScaledP, slerpScaledR, result);
    return Quaternion.multiplyByScalar(result, 1.0 / Math.sin(theta), result);
    };
    
    /**
    * The logarithmic quaternion function.
    * @memberof Quaternion
    *
    * @param {Quaternion} quaternion The unit quaternion.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new instance if one was not provided.
    */
    Quaternion.log = function(quaternion, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(quaternion)) {
    throw new DeveloperError('quaternion is required.');
    }
    //>>includeEnd('debug');
    
    var theta = Math.acos(CesiumMath.clamp(quaternion.w, -1.0, 1.0));
    var thetaOverSinTheta = 0.0;
    
    if (theta !== 0.0) {
    thetaOverSinTheta = theta / Math.sin(theta);
    }
    
    if (!defined(result)) {
    result = new Cartesian3();
    }
    
    return Cartesian3.multiplyByScalar(quaternion, thetaOverSinTheta, result);
    };
    
    /**
    * The exponential quaternion function.
    * @memberof Quaternion
    *
    * @param {Cartesian3} cartesian The cartesian.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new instance if one was not provided.
    */
    Quaternion.exp = function(cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    var theta = Cartesian3.magnitude(cartesian);
    var sinThetaOverTheta = 0.0;
    
    if (theta !== 0.0) {
    sinThetaOverTheta = Math.sin(theta) / theta;
    }
    
    if (!defined(result)) {
    result = new Quaternion();
    }
    
    result.x = cartesian.x * sinThetaOverTheta;
    result.y = cartesian.y * sinThetaOverTheta;
    result.z = cartesian.z * sinThetaOverTheta;
    result.w = Math.cos(theta);
    
    return result;
    };
    
    var squadScratchCartesian0 = new Cartesian3();
    var squadScratchCartesian1 = new Cartesian3();
    var squadScratchQuaternion0 = new Quaternion();
    var squadScratchQuaternion1 = new Quaternion();
    
    /**
    * Computes an inner quadrangle point.
    * <p>This will compute quaternions that ensure a squad curve is C<sup>1</sup>.</p>
    * @memberof Quaternion
    *
    * @param {Quaternion} q0 The first quaternion.
    * @param {Quaternion} q1 The second quaternion.
    * @param {Quaternion} q2 The third quaternion.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new instance if none was provided.
    *
    * @see Quaternion#squad
    */
    Quaternion.innerQuadrangle = function(q0, q1, q2, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(q0) || !defined(q1) || !defined(q2)) {
    throw new DeveloperError('q0, q1, and q2 are required.');
    }
    //>>includeEnd('debug');
    
    var qInv = Quaternion.conjugate(q1, squadScratchQuaternion0);
    Quaternion.multiply(qInv, q2, squadScratchQuaternion1);
    var cart0 = Quaternion.log(squadScratchQuaternion1, squadScratchCartesian0);
    
    Quaternion.multiply(qInv, q0, squadScratchQuaternion1);
    var cart1 = Quaternion.log(squadScratchQuaternion1, squadScratchCartesian1);
    
    Cartesian3.add(cart0, cart1, cart0);
    Cartesian3.multiplyByScalar(cart0, 0.25, cart0);
    Cartesian3.negate(cart0, cart0);
    Quaternion.exp(cart0, squadScratchQuaternion0);
    
    return Quaternion.multiply(q1, squadScratchQuaternion0, result);
    };
    
    /**
    * Computes the spherical quadrangle interpolation between quaternions.
    * @memberof Quaternion
    *
    * @param {Quaternion} q0 The first quaternion.
    * @param {Quaternion} q1 The second quaternion.
    * @param {Quaternion} s0 The first inner quadrangle.
    * @param {Quaternion} s1 The second inner quadrangle.
    * @param {Number} t The time in [0,1] used to interpolate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new instance if none was provided.
    *
    * @see Quaternion#innerQuadrangle
    *
    * @example
    * // 1. compute the squad interpolation between two quaternions on a curve
    * var s0 = Cesium.Quaternion.innerQuadrangle(quaternions[i - 1], quaternions[i], quaternions[i + 1]);
    * var s1 = Cesium.Quaternion.innerQuadrangle(quaternions[i], quaternions[i + 1], quaternions[i + 2]);
    * var q = Cesium.Quaternion.squad(quaternions[i], quaternions[i + 1], s0, s1, t);
    *
    * // 2. compute the squad interpolation as above but where the first quaternion is a end point.
    * var s1 = Cesium.Quaternion.innerQuadrangle(quaternions[0], quaternions[1], quaternions[2]);
    * var q = Cesium.Quaternion.squad(quaternions[0], quaternions[1], quaternions[0], s1, t);
    */
    Quaternion.squad = function(q0, q1, s0, s1, t, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(q0) || !defined(q1) || !defined(s0) || !defined(s1)) {
    throw new DeveloperError('q0, q1, s0, and s1 are required.');
    }
    
    if (typeof t !== 'number') {
    throw new DeveloperError('t is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    var slerp0 = Quaternion.slerp(q0, q1, t, squadScratchQuaternion0);
    var slerp1 = Quaternion.slerp(s0, s1, t, squadScratchQuaternion1);
    return Quaternion.slerp(slerp0, slerp1, 2.0 * t * (1.0 - t), result);
    };
    
    var fastSlerpScratchQuaternion = new Quaternion();
    var opmu = 1.90110745351730037;
    var u = FeatureDetection.supportsTypedArrays() ? new Float32Array(8) : [];
    var v = FeatureDetection.supportsTypedArrays() ? new Float32Array(8) : [];
    var bT = FeatureDetection.supportsTypedArrays() ? new Float32Array(8) : [];
    var bD = FeatureDetection.supportsTypedArrays() ? new Float32Array(8) : [];
    
    for (var i = 0; i < 7; ++i) {
    var s = i + 1.0;
    var t = 2.0 * s + 1.0;
    u[i] = 1.0 / (s * t);
    v[i] = s / t;
    }
    
    u[7] = opmu / (8.0 * 17.0);
    v[7] = opmu * 8.0 / 17.0;
    
    /**
    * Computes the spherical linear interpolation or extrapolation at t using the provided quaternions.
    * This implementation is faster than {@link Quaternion#slerp}, but is only accurate up to 10<sup>-6</sup>.
    * @memberof Quaternion
    *
    * @param {Quaternion} start The value corresponding to t at 0.0.
    * @param {Quaternion} end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    *
    * @see Quaternion#slerp
    */
    Quaternion.fastSlerp = function(start, end, t, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(start)) {
    throw new DeveloperError('start is required.');
    }
    
    if (!defined(end)) {
    throw new DeveloperError('end is required.');
    }
    
    if (typeof t !== 'number') {
    throw new DeveloperError('t is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
    result = new Quaternion();
    }
    
    var x = Quaternion.dot(start, end);
    
    var sign;
    if (x >= 0) {
    sign = 1.0;
    } else {
    sign = -1.0;
    x = -x;
    }
    
    var xm1 = x - 1.0;
    var d = 1.0 - t;
    var sqrT = t * t;
    var sqrD = d * d;
    
    for (var i = 7; i >= 0; --i) {
    bT[i] = (u[i] * sqrT - v[i]) * xm1;
    bD[i] = (u[i] * sqrD - v[i]) * xm1;
    }
    
    var cT = sign * t * (
    1.0 + bT[0] * (1.0 + bT[1] * (1.0 + bT[2] * (1.0 + bT[3] * (
    1.0 + bT[4] * (1.0 + bT[5] * (1.0 + bT[6] * (1.0 + bT[7]))))))));
    var cD = d * (
    1.0 + bD[0] * (1.0 + bD[1] * (1.0 + bD[2] * (1.0 + bD[3] * (
    1.0 + bD[4] * (1.0 + bD[5] * (1.0 + bD[6] * (1.0 + bD[7]))))))));
    
    var temp = Quaternion.multiplyByScalar(start, cD, fastSlerpScratchQuaternion);
    Quaternion.multiplyByScalar(end, cT, result);
    return Quaternion.add(temp, result, result);
    };
    
    /**
    * Computes the spherical quadrangle interpolation between quaternions.
    * An implementation that is faster than {@link Quaternion#squad}, but less accurate.
    * @memberof Quaternion
    *
    * @param {Quaternion} q0 The first quaternion.
    * @param {Quaternion} q1 The second quaternion.
    * @param {Quaternion} s0 The first inner quadrangle.
    * @param {Quaternion} s1 The second inner quadrangle.
    * @param {Number} t The time in [0,1] used to interpolate.
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new instance if none was provided.
    *
    * @see Quaternion#squad
    */
    Quaternion.fastSquad = function(q0, q1, s0, s1, t, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(q0) || !defined(q1) || !defined(s0) || !defined(s1)) {
    throw new DeveloperError('q0, q1, s0, and s1 are required.');
    }
    
    if (typeof t !== 'number') {
    throw new DeveloperError('t is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    var slerp0 = Quaternion.fastSlerp(q0, q1, t, squadScratchQuaternion0);
    var slerp1 = Quaternion.fastSlerp(s0, s1, t, squadScratchQuaternion1);
    return Quaternion.fastSlerp(slerp0, slerp1, 2.0 * t * (1.0 - t), result);
    };
    
    /**
    * Compares the provided quaternions componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    * @memberof Quaternion
    *
    * @param {Quaternion} [left] The first quaternion.
    * @param {Quaternion} [right] The second quaternion.
    * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
    */
    Quaternion.equals = function(left, right) {
    return (left === right) ||
    ((defined(left)) &&
    (defined(right)) &&
    (left.x === right.x) &&
    (left.y === right.y) &&
    (left.z === right.z) &&
    (left.w === right.w));
    };
    
    /**
    * Compares the provided quaternions componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    * @memberof Quaternion
    *
    * @param {Quaternion} [left] The first quaternion.
    * @param {Quaternion} [right] The second quaternion.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    Quaternion.equalsEpsilon = function(left, right, epsilon) {
    //>>includeStart('debug', pragmas.debug);
    if (typeof epsilon !== 'number') {
    throw new DeveloperError('epsilon is required and must be a number.');
    }
    //>>includeEnd('debug');
    
    return (left === right) ||
    ((defined(left)) &&
    (defined(right)) &&
    (Math.abs(left.x - right.x) <= epsilon) &&
    (Math.abs(left.y - right.y) <= epsilon) &&
    (Math.abs(left.z - right.z) <= epsilon) &&
    (Math.abs(left.w - right.w) <= epsilon));
    };
    
    /**
    * An immutable Quaternion instance initialized to (0.0, 0.0, 0.0, 0.0).
    * @memberof Quaternion
    */
    Quaternion.ZERO = freezeObject(new Quaternion(0.0, 0.0, 0.0, 0.0));
    
    /**
    * An immutable Quaternion instance initialized to (0.0, 0.0, 0.0, 1.0).
    * @memberof Quaternion
    */
    Quaternion.IDENTITY = freezeObject(new Quaternion(0.0, 0.0, 0.0, 1.0));
    
    /**
    * Duplicates this Quaternion instance.
    * @memberof Quaternion
    *
    * @param {Quaternion} [result] The object onto which to store the result.
    * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
    */
    Quaternion.prototype.clone = function(result) {
    return Quaternion.clone(this, result);
    };
    
    /**
    * Compares this and the provided quaternion componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    * @memberof Quaternion
    *
    * @param {Quaternion} [right] The right hand side quaternion.
    * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
    */
    Quaternion.prototype.equals = function(right) {
    return Quaternion.equals(this, right);
    };
    
    /**
    * Compares this and the provided quaternion componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    * @memberof Quaternion
    *
    * @param {Quaternion} [right] The right hand side quaternion.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    Quaternion.prototype.equalsEpsilon = function(right, epsilon) {
    return Quaternion.equalsEpsilon(this, right, epsilon);
    };
    
    /**
    * Returns a string representing this quaternion in the format (x, y, z, w).
    * @memberof Quaternion
    *
    * @returns {String} A string representing this Quaternion.
    */
    Quaternion.prototype.toStrin    g = function() {
    return '(' + this.x + ', ' + this.y + ', ' + this.z + ', ' + this.w + ')';
    };
    */
}

/**
* Computes the product of two quaternions. Applies rotation in reference frame order - 
* i.e. lhs then rhs
* @memberof Quaternion
*
* @param {Quaternion} left The first quaternion.
* @param {Quaternion} right The second quaternion.
* @param {Quaternion} [result] The object onto which to store the result.
* @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided.
*/
func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    return rhs.multiply(lhs)
}

