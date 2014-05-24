//
//  CSVector3.m
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//



#import "CSCartesian3.h"

#import "CSCartesian2.h"
#import "CSCartesian4.h"
#import "CSSpherical.h"

@implementation CSCartesian3

+(CSCartesian3 *)zero
{
    return [[CSCartesian3 alloc] initWithX:0.0 Y:0.0 Z:0.0];
}

+(CSCartesian3 *)unitX
{
    return [[CSCartesian3 alloc] initWithX:1.0 Y:0.0 Z:0.0];
}

+(CSCartesian3 *)unitY
{
    return [[CSCartesian3 alloc] initWithX:0.0 Y:1.0 Z:0.0];
}

+(CSCartesian3 *)unitZ
{
    return [[CSCartesian3 alloc] initWithX:0.0 Y:0.0 Z:1.0];
}

+(CSCartesian3 *)undefined
{
    return [[CSCartesian3 alloc] initWithX:NAN Y:NAN Z:NAN];
}

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z
{
    self = [super init];
    if (self)
    {
        _x = x;
        _y = y;
        _z = z;
        
        _packedLength = 3;
    }
    return self;
}

+(CSCartesian3 *)cartesian3FromSpherical:(CSSpherical *)spherical
{
    NSAssert(spherical != nil, @"spherical object required");
    
    Float64 clock = spherical.clock;
    Float64 cone = spherical.cone;
    Float64 magnitude = spherical.magnitude;
    Float64 radial = magnitude * sin(cone);
    return [[CSCartesian3 alloc] initWithX:radial * cos(clock)
                                         Y:radial * sin(clock)
                                         Z:magnitude * cos(cone)];
}

+(CSCartesian3 *)cartesian3FromCartesian4:(CSCartesian4 *)cartesian4
{
    NSAssert(cartesian4 != nil, @"cartesian4 object required");

    return [[CSCartesian3 alloc] initWithX:cartesian4.x
                                         Y:cartesian4.y
                                         Z:cartesian4.z];
}

/*    Cartesian3.pack = function(value, array, startingIndex) {
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
 array[startingIndex] = value.z;
 };
 
 /**
 * Retrieves an instance from a packed array.
 * @memberof Cartesian3
 *
 * @param {Array} array The packed array.
 * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
 * @param {Cartesian3} [result] The object into which to store the result.
 
Cartesian3.unpack = function(array, startingIndex, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(array)) {
        throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    if (!defined(result)) {
        result = new Cartesian3();
    }
    result.x = array[startingIndex++];
    result.y = array[startingIndex++];
    result.z = array[startingIndex];
    return result;
};*/

-(CSCartesian2 *)xy
{
    return [[CSCartesian2 alloc] initWithX:self.x Y:self.y];
}

-(Float64)magnitudeSquared
{
    return self.x * self.x * self.y * self.y * self.z * self.z;
}

-(Float64)magnitude
{
    return sqrt([self magnitudeSquared]);
}

-(BOOL)isUndefined
{
    return self.x == NAN;
}

-(CSCartesian3 *)normalise
{
    Float64 magnitude = self.magnitude;
    NSAssert(magnitude != 0.0, @"divide by zero");
    return [[CSCartesian3 alloc] initWithX:self.x / magnitude
                                       Y:self.y / magnitude
                                       Z:self.z / magnitude];
}

-(CSCartesian3 *)cross:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");

    return [[CSCartesian3 alloc] initWithX:self.y * other.z - self.z * other.y
                                       Y:self.z * other.x - self.x * other.z
                                       Z:self.x * other.y - self.y * other.x];
}

-(Float64)dot:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");

    return self.x * other.x + self.y * other.y + self.z * other.z;
}

-(CSCartesian3 *)add:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");

    return [[CSCartesian3 alloc] initWithX:self.x + other.x
                                       Y:self.y + other.y
                                       Z:self.z + other.z];
}

-(CSCartesian3 *)subtract:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");

    return [[CSCartesian3 alloc] initWithX:self.x - other.x
                                       Y:self.y - other.y
                                       Z:self.z - other.z];
}

-(CSCartesian3 *)multiplyByScalar:(double)scalar
{
    return [[CSCartesian3 alloc] initWithX:self.x * scalar
                                       Y:self.y * scalar
                                       Z:self.z * scalar];
}

-(CSCartesian3 *)multiplyComponents:(CSCartesian3 *)scale
{
    NSAssert(scale != nil, @"Comparison object required");

    return [[CSCartesian3 alloc] initWithX:self.x * scale.x
                                       Y:self.y * scale.y
                                       Z:self.z * scale.z];
}

-(CSCartesian3 *)divideScalar:(Float64)scalar
{
    return [[CSCartesian3 alloc] initWithX:self.x / scalar
                                       Y:self.y / scalar
                                       Z:self.z / scalar];
}

-(CSCartesian3 *)negate
{
    return [[CSCartesian3 alloc] initWithX:-self.x
                                         Y:-self.y
                                         Z:-self.z];
}

-(CSCartesian3 *)absolute;
{
    return [[CSCartesian3 alloc] initWithX:ABS(self.x)
                                         Y:ABS(self.y)
                                         Z:ABS(self.z)];
};

-(Float64)maximumComponent
{
    return MAX(MAX(self.x, self.y), self.z);
}

-(Float64)minimumComponent
{
    return MIN(MIN(self.x, self.y), self.z);
}

-(CSCartesian3 *)maximumByComponent:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian3 alloc] initWithX:MAX(self.x, other.x)
                                         Y:MAX(self.y, other.y)
                                         Z:MAX(self.z, other.z)];
}

-(CSCartesian3 *)minimumByComponent:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian3 alloc] initWithX:MIN(self.x, other.x)
                                         Y:MIN(self.y, other.y)
                                         Z:MIN(self.z, other.z)];
}

-(Float64)distance:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return [self subtract:other].magnitude;
}

-(CSCartesian3 *)linearExtrapolation:(CSCartesian3 *)other point:(Float64)t
{
    NSAssert(other != nil, @"Comparison object required");
    return [[self multiplyByScalar:1.0 - t] add:[other multiplyByScalar:t]];
};

-(CSCartesian3 *)mostOrthogonalAxis
{
    double x = ABS(self.x);
    double y = ABS(self.y);
    double z = ABS(self.z);

    if ((x < y) && (x < z))
    {
        return [CSCartesian3 unitX];
    }
    else if ((y < x) && (y < z))
    {
        return [CSCartesian3 unitY];
    }
    else
    {
        return [CSCartesian3 unitZ];
    }
}

-(Float64)angleBetween:(CSCartesian3 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return atan2([self cross:other.normalise].magnitude, [self.normalise dot:other.normalise]);
}

-(CSCartesian3 *)rotateAroundAxis:(CSCartesian3 *)axis theta:(double)theta
{
    double u = axis.x;
    double v = axis.y;
    double w = axis.z;
    
    double cosTheta = cos(theta);
    double sinTheta = sin(theta);
    
    double ms = axis.magnitudeSquared;
    double m = sqrt(ms);
    
    return [[CSCartesian3 alloc] initWithX:((u * (u * self.x + v * self.y + w * self.z)) +
                                          (((self.x * (v * v + w * w)) - (u * (v * self.y + w * self.z))) * cosTheta) +
                                          (m * ((-w * self.y) + (v * self.z)) * sinTheta)) / ms
                                       Y:((v * (u * self.x + v * self.y + w * self.z)) +
                                          (((self.y * (u * u + w * w)) - (v * (u * self.x + w * self.z))) * cosTheta) +
                                          (m * ((w * _x) - (u * _z)) * sinTheta)) / ms
                                       Z:((w * (u * self.x + v * self.y + w * self.z)) +
                                          (((self.z * (u * u + v * v)) - (w * (u * self.x + v * self.y))) * cosTheta) +
                                          (m * (-(v * self.x) + (u * self.y)) * sinTheta)) / ms];
}

-(BOOL)equalsEpsilon:(CSCartesian3 *)other epsilon:(double)epsilon
{
    return
    (ABS(self.x - other.x) <= epsilon) &&
    (ABS(self.y - other.y) <= epsilon) &&
    (ABS(self.z - other.z) <= epsilon);
}

-(BOOL)equals:(CSCartesian3 *)other
{
    return self.x == other.x && self.y == other.y && self.z == other.z;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"({%f}, {%f}, {%f})", self.x, self.y, self.z];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[CSCartesian3 alloc] initWithX:self.x Y:self.y Z:self.z];
}

@end
