//
//  CSQuarternion.m
//  CesiumKit
//
//  Created by Ryan on 11/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSQuarternion.h"

#import "CSCartesian3.h"

#import "CSMath.h"

@implementation CSQuarternion

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z W:(Float64)w
{
    self = [super init];
    if (self)
    {
        _x = x;
        _y = y;
        _z = z;
        _w = w;
        
        _packedLength = 4;
        _packedInterpolationLength = 3;
    }
    return self;
}

+(CSQuarternion *)zero
{
    return [[CSQuarternion alloc] initWithX:0.0 Y:0.0 Z:0.0 W:0.0];
}

+(CSQuarternion *)identity
{
    return [[CSQuarternion alloc] initWithX:0.0 Y:0.0 Z:0.0 W:1.0];
}

+(CSQuarternion *)quarternionWithAxis:(CSCartesian3 *)axis angle:(Float64)angle
{
    NSAssert(axis != nil, @"Angle must be given");
    
    Float64 halfAngle = angle / 2.0;
    Float64 s = sin(halfAngle);
    
    CSCartesian3 *fromAxisAngleScratch = axis.normalise;
    
    return [[CSQuarternion alloc] initWithX:fromAxisAngleScratch.x * s
                                          Y:fromAxisAngleScratch.y * s
                                          Z:fromAxisAngleScratch.z * s
                                          W:cos(halfAngle)];
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
+(CSQuarternion *)quarternionWithRotationMatrix:(CSMatrix3 *)matrix
{
#warning need matrix3
    NSAssert(0 == 1, @"not implemented");
    /*
    var fromRotationMatrixNext = [1, 2, 0];
    var fromRotationMatrixQuat = new Array(3);
    
    //>>includeStart('debug', pragmas.debug);
    if (!defined(matrix)) {
        throw new DeveloperError('matrix is required.');
    }
    //>>includeEnd('debug');
    
    var root;
    var x;
    var y;
    var z;
    var w;
    
    var m00 = matrix[Matrix3.COLUMN0ROW0];
    var m11 = matrix[Matrix3.COLUMN1ROW1];
    var m22 = matrix[Matrix3.COLUMN2ROW2];
    var trace = m00 + m11 + m22;
    
    if (trace > 0.0) {
        // |w| > 1/2, may as well choose w > 1/2
        root = Math.sqrt(trace + 1.0); // 2w
        w = 0.5 * root;
        root = 0.5 / root; // 1/(4w)
        
        x = (matrix[Matrix3.COLUMN1ROW2] - matrix[Matrix3.COLUMN2ROW1]) * root;
        y = (matrix[Matrix3.COLUMN2ROW0] - matrix[Matrix3.COLUMN0ROW2]) * root;
        z = (matrix[Matrix3.COLUMN0ROW1] - matrix[Matrix3.COLUMN1ROW0]) * root;
    } else {
        // |w| <= 1/2
        var next = fromRotationMatrixNext;
        
        var i = 0;
        if (m11 > m00) {
            i = 1;
        }
        if (m22 > m00 && m22 > m11) {
            i = 2;
        }
        var j = next[i];
        var k = next[j];
        
        root = Math.sqrt(matrix[Matrix3.getElementIndex(i, i)] - matrix[Matrix3.getElementIndex(j, j)] - matrix[Matrix3.getElementIndex(k, k)] + 1.0);
        
        var quat = fromRotationMatrixQuat;
        quat[i] = 0.5 * root;
        root = 0.5 / root;
        w = (matrix[Matrix3.getElementIndex(k, j)] - matrix[Matrix3.getElementIndex(j, k)]) * root;
        quat[j] = (matrix[Matrix3.getElementIndex(j, i)] + matrix[Matrix3.getElementIndex(i, j)]) * root;
        quat[k] = (matrix[Matrix3.getElementIndex(k, i)] + matrix[Matrix3.getElementIndex(i, k)]) * root;
        
        x = -quat[0];
        y = -quat[1];
        z = -quat[2];
    }
    
    if (!defined(result)) {
        return new Quaternion(x, y, z, w);
    }
    result.x = x;
    result.y = y;
    result.z = z;
    result.w = w;
    return result;
     */
    return [CSQuarternion zero];
}

/*
var sampledQuaternionAxis = new Cartesian3();
var sampledQuaternionRotation = new Cartesian3();
var sampledQuaternionTempQuaternion = new Quaternion();
var sampledQuaternionQuaternion0 = new Quaternion();
var sampledQuaternionQuaternion0Conjugate = new Quaternion();

*/
 
-(void)pack:(void *)array startingIndex:(UInt32)startingIndex
{
    NSAssert(0 == 1, @"not implemented");

#warning pack
   /* Quaternion.pack = function(value, array, startingIndex) {
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
    };*/
}

+(CSQuarternion *)unpack:(void *)array startingIndex:(UInt32)startingIndex
{
#warning unpack
    NSAssert(0 == 1, @"not implemented");

    return [CSQuarternion zero];
}
/*
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
};*/


/*
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
};*/

-(CSQuarternion *)conjugate
{
    return [[CSQuarternion alloc] initWithX:-self.x Y:-self.y Z:-self.x W:self.w];
}

-(Float64)magnitudeSquared
{
    return self.x * self.x * self.y * self.y * self.z * self.z * self.w * self.w;
    
}

-(Float64)magnitude
{
    return sqrt(self.magnitudeSquared);
}

-(CSQuarternion *)normalise
{
    Float64 magnitude = self.magnitude;
    NSAssert(magnitude != 0.0, @"divide by zero");
    return [[CSQuarternion alloc] initWithX:self.x / magnitude
                                         Y:self.y / magnitude
                                         Z:self.z / magnitude
                                         W:self.w / magnitude];
}

-(CSQuarternion *)inverse
{
    Float64 magnitudeSquared = self.magnitudeSquared;
    NSAssert(magnitudeSquared != 0.0, @"divide by zero");
    
    return [self multiplyByScalar:(1.0 / self.magnitudeSquared)];
}

-(CSQuarternion *)add:(CSQuarternion *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSQuarternion alloc] initWithX:self.x + other.x
                                         Y:self.y + other.y
                                         Z:self.z + other.z
                                         W:self.w + other.w];
}

-(CSQuarternion *)subtract:(CSQuarternion *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSQuarternion alloc] initWithX:self.x - other.x
                                         Y:self.y - other.y
                                         Z:self.z - other.z
                                         W:self.w - other.w];
}

-(CSQuarternion *)negate
{
    return [[CSQuarternion alloc] initWithX:-self.x
                                          Y:-self.y
                                          Z:-self.z
                                          W:-self.w];
}

-(Float64)dot:(CSQuarternion *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
}

-(CSQuarternion *)multiply:(CSQuarternion *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSQuarternion alloc] initWithX:self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y
                                          Y:self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x
                                          Z:self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w
                                          W:self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z];
}

-(CSQuarternion *)multiplyByScalar:(Float64)scalar
{
    return [[CSQuarternion alloc] initWithX:self.x * scalar
                                          Y:self.y * scalar
                                          Z:self.z * scalar
                                          W:self.w * scalar];
}

-(CSQuarternion *)divideByScalar:(Float64)scalar
{
    return [[CSQuarternion alloc] initWithX:self.x / scalar
                                          Y:self.y / scalar
                                          Z:self.z / scalar
                                          W:self.w / scalar];
}

-(CSCartesian3 *)getAxis
{
    if (abs(self.w - 1.0) < CSEpsilon6)
    {
        return [CSCartesian3 zero];
    }
    Float64 scalar = 1.0 / sqrt(1.0 - (self.w * self.w));
    
    return [[CSCartesian3 alloc] initWithX:self.x * scalar
                                         Y:self.y * scalar
                                         Z:self.z * scalar];
}

-(Float64)getAngle
{
    if (abs(self.w - 1.0) < CSEpsilon6)
    {
        return 0.0;
    }
    return 2.0  * acos(self.w);
}

-(CSQuarternion *)linearExtrapolation:(CSQuarternion *)end point:(Float64)t
{
    NSAssert(end != nil, @"Comparison object required");

    return [[self multiplyByScalar:1.0 - t] add:[end multiplyByScalar:t]];
}

-(CSQuarternion *)sphericalLinearExtrapolation:(CSQuarternion *)end point:(Float64)t
{
    NSAssert(end != nil, @"Comparison object required");

    Float64 dot = [self dot:end];
    
    // The angle between start must be acute. Since q and -q represent
    // the same rotation, negate q to get the acute angle.
    CSQuarternion *r = [end copy];
    
    if (dot < 0.0)
    {
        dot = -dot;
        r = [end negate];
    }

    // dot > 0, as the dot product approaches 1, the angle between the
    // quaternions vanishes. use linear interpolation.
    if (1.0 - dot < CSEpsilon6)
    {
        return [self linearExtrapolation:r point:t];
    }
    
    Float64 theta = acos(dot);
    CSQuarternion *slerpScaledP = [self multiplyByScalar:sin((1.0 -t) * theta)];
    CSQuarternion *slerpScaledR = [r multiplyByScalar:sin(t * theta)];

    return [[slerpScaledP add:slerpScaledR] multiplyByScalar:1.0 / sin(theta)];
}

-(CSCartesian3 *)log
{
    Float64 theta = acos([CSMath clampValue:self.w min:-1.0 max:1.0]);
    Float64 thetaOverSinTheta = 0.0;
    
    if (theta != 0.0)
    {
        thetaOverSinTheta = theta / sin(theta);
    }
#warning invalid
    return [[CSCartesian3 unitX] multiplyByScalar:thetaOverSinTheta];
    /*
    if (!defined(result)) {
        result = new Cartesian3();
    }
    
    return Cartesian3.multiplyByScalar(quaternion, thetaOverSinTheta, result);*/
}

-(CSQuarternion *)exp:(CSCartesian3 *)cartesian3
{
    NSAssert(cartesian3 != nil, @"cartesian3 object required");

    Float64 theta = cartesian3.magnitude;
    Float64 sinThetaOverTheta = 0.0;
    
    if (theta != 0.0)
    {
        sinThetaOverTheta = sin(theta) / theta;
    }
    
    return [[CSQuarternion alloc] initWithX:cartesian3.x * sinThetaOverTheta
                                          Y:cartesian3.y * sinThetaOverTheta
                                          Z:cartesian3.z * sinThetaOverTheta
                                          W:cos(theta)];
}
/*
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
 *
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
 *
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
 *
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
 *
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
};*/

-(BOOL)equals:(CSQuarternion *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return self.x == other.x && self.y == other.y && self.z == other.z && self.w == other.w;
}

-(BOOL)equals:(CSQuarternion *)other epsilon:(double)epsilon
{
    NSAssert(other != nil, @"Comparison object required");
    
    return (ABS(self.x - other.x) <= epsilon) && (ABS(self.y - other.y) <= epsilon) && (ABS(self.z - other.z) <= epsilon) && (ABS(self.w - other.w) <= epsilon);
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f, %f, %f)", self.x, self.y, self.z, self.w];
}

/**
 * Duplicates a Quaternion instance.
 * @memberof Quaternion
 *
 * @param {Quaternion} quaternion The quaternion to duplicate.
 * @param {Quaternion} [result] The object onto which to store the result.
 * @returns {Quaternion} The modified result parameter or a new Quaternion instance if one was not provided. (Returns undefined if quaternion is undefined)
 */
-(id)copyWithZone:(NSZone *)zone
{
    return [[CSQuarternion alloc] initWithX:self.x Y:self.y Z:self.z W:self.w];
}

@end
