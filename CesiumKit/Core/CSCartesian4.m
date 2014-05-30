//
//  CSCartesian4.m
//  CesiumKit
//
//  Created by Ryan Walklin on 4/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSCartesian4.h"

@implementation CSCartesian4

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
    }
    return self;
}

+(CSCartesian4 *)zero
{
    return [[CSCartesian4 alloc] initWithX:0.0 Y:0.0 Z:0.0 W:0.0];
}

+(CSCartesian4 *)unitX
{
    return [[CSCartesian4 alloc] initWithX:1.0 Y:0.0 Z:0.0 W:0.0];
}

+(CSCartesian4 *)unitY
{
    return [[CSCartesian4 alloc] initWithX:0.0 Y:1.0 Z:0.0 W:0.0];
}

+(CSCartesian4 *)unitZ
{
    return [[CSCartesian4 alloc] initWithX:0.0 Y:0.0 Z:1.0 W:0.0];
}

+(CSCartesian4 *)unitW
{
    return [[CSCartesian4 alloc] initWithX:0.0 Y:0.0 Z:0.0 W:1.0];
}

+(CSCartesian4 *)cartesian4WithRed:(Float64)r green:(Float64)g blue:(Float64)b alpha:(Float64)a
{
    return [[CSCartesian4 alloc] initWithX:r Y:g Z:b W:a];
}

-(void)pack:(Float32 *)array startingIndex:(UInt32)index
{
    UInt32 nextIndex = index;
    NSAssert(array != nil, @"Nil array");
    array[nextIndex++] = self.x;
    array[nextIndex++] = self.y;
    array[nextIndex++] = self.z;
    array[nextIndex] = self.w;
}

+(CSCartesian4 *)unpack:(Float32 *)array startingIndex:(UInt32)index
{
    NSAssert(array != nil, @"Nil array");
    UInt32 nextIndex = index;
    return [[CSCartesian4 alloc] initWithX:array[nextIndex]
                                         Y:array[nextIndex+1]
                                         Z:array[nextIndex+2]
                                         W:array[nextIndex+3]];
}

+(CSCartesian4 *)cartesian4WithArray:(Float64 *)array
{
    NSAssert(array != nil, @"Nil array");
    return [[CSCartesian4 alloc] initWithX:array[0]
                                         Y:array[1]
                                         Z:array[2]
                                         W:array[3]];
}

-(Float64)maximumComponent
{
    return MAX(MAX(MAX(self.x, self.y), self.z), self.w);
}

-(Float64)minimumComponent
{
    return MIN(MIN(MIN(self.x, self.y), self.z), self.w);
}

-(CSCartesian4 *)maximumByComponent:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian4 alloc] initWithX:MAX(self.x, other.x)
                                         Y:MAX(self.y, other.y)
                                         Z:MAX(self.z, other.z)
                                         W:MAX(self.w, other.w)];
}
-(CSCartesian4 *)minimumByComponent:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian4 alloc] initWithX:MIN(self.x, other.x)
                                         Y:MIN(self.y, other.y)
                                         Z:MIN(self.z, other.z)
                                         W:MIN(self.w, other.w)];
}

-(Float64)magnitudeSquared
{
    return self.x * self.x * self.y * self.y * self.z * self.z * self.w * self.w;

}

-(Float64)magnitude
{
    return sqrt(self.magnitudeSquared);
}

-(Float64)distance:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return [self subtract:other].magnitude;
}

-(CSCartesian4 *)normalise
{
    Float64 magnitude = self.magnitude;
    NSAssert(magnitude != 0.0, @"divide by zero");
    return [[CSCartesian4 alloc] initWithX:self.x / magnitude
                                         Y:self.y / magnitude
                                         Z:self.z / magnitude
                                         W:self.w / magnitude];
}

-(Float64)dot:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
}

-(CSCartesian4 *)multiplyComponents:(CSCartesian4 *)other;
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian4 alloc] initWithX:self.x * other.x
                                         Y:self.y * other.y
                                         Z:self.z * other.z
                                         W:self.w * other.w];
}

-(CSCartesian4 *)add:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian4 alloc] initWithX:self.x + other.x
                                         Y:self.y + other.y
                                         Z:self.z + other.z
                                         W:self.w + other.w];
}

-(CSCartesian4 *)subtract:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");

    return [[CSCartesian4 alloc] initWithX:self.x - other.x
                                         Y:self.y - other.y
                                         Z:self.z - other.z
                                         W:self.w - other.w];
}

-(CSCartesian4 *)multiplyByScalar:(Float64)scalar
{
    return [[CSCartesian4 alloc] initWithX:self.x * scalar
                                         Y:self.y * scalar
                                         Z:self.z * scalar
                                         W:self.w * scalar];
}

-(CSCartesian4 *)divideByScalar:(Float64)scalar
{
    return [[CSCartesian4 alloc] initWithX:self.x / scalar
                                         Y:self.y / scalar
                                         Z:self.z / scalar
                                         W:self.w / scalar];
}

-(CSCartesian4 *)negate
{
    return [[CSCartesian4 alloc] initWithX:-self.x
                                         Y:-self.y
                                         Z:-self.z
                                         W:-self.w];
}

-(CSCartesian4 *)absolute
{
    return [[CSCartesian4 alloc] initWithX:ABS(self.x)
                                         Y:ABS(self.y)
                                         Z:ABS(self.z)
                                         W:ABS(self.w)];
}

-(CSCartesian4 *)linearExtrapolation:(CSCartesian4 *)end point:(Float64)t
{
    NSAssert(end != nil, @"Comparison object required");
    return [[self multiplyByScalar:1.0 - t] add:[end multiplyByScalar:t]];
}

-(CSCartesian4 *)mostOrthogonalAxis
{
    CSCartesian4 *f = self.normalise.absolute;
    CSCartesian4 *result;
    if (f.x <= f.y)
    {
        if (f.x <= f.z)
        {
            if (f.x <= f.w)
            {
                result = [CSCartesian4 unitX];
            }
            else
            {
                result = [CSCartesian4 unitW];
            }
        }
        else if (f.z <= f.w)
        {
            result = [CSCartesian4 unitZ];
        }
        else
        {
            result = [CSCartesian4 unitW];
        }
    }
    else if (f.y <= f.z)
    {
        if (f.y <= f.w)
        {
            result = [CSCartesian4 unitY];
        }
        else
        {
            result = [CSCartesian4 unitW];
        }
    }
    else if (f.z <= f.w)
    {
        result = [CSCartesian4 unitZ];
    }
    else
    {
        result = [CSCartesian4 unitW];
    }
    return result;
}

-(BOOL)equals:(CSCartesian4 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return self.x == other.x && self.y == other.y && self.z == other.z && self.w == other.w;
}

-(BOOL)equalsEpsilon:(CSCartesian4 *)other epsilon:(double)epsilon
{
    NSAssert(other != nil, @"Comparison object required");

    return (ABS(self.x - other.x) <= epsilon) && (ABS(self.y - other.y) <= epsilon) && (ABS(self.z - other.z) <= epsilon) && (ABS(self.w - other.w) <= epsilon);
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"({%f}, {%f}, {%f}, {%f})", self.x, self.y, self.z, self.w];

}

-(id)copyWithZone:(NSZone *)zone
{
    return [[CSCartesian4 alloc] initWithX:self.x Y:self.y Z:self.z W:self.w];
}

@end;
