//
//  CSCartesian2D.m
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSCartesian2.h"
#import "CSCartesian3.h"
#import "CSCartesian4.h"

@implementation CSCartesian2

-(id)initWithX:(Float64)x Y:(Float64)y
{
    self = [super init];
    if (self)
    {
        _x = x;
        _y = y;
        
        _packedLength = 2;
    }
    return self;
}

+(CSCartesian2 *)zero
{
    return [[CSCartesian2 alloc] initWithX:0.0 Y:0.0];
}

+(CSCartesian2 *)unitX
{
    return [[CSCartesian2 alloc] initWithX:1.0 Y:0.0];
}

+(CSCartesian2 *)unitY
{
    return [[CSCartesian2 alloc] initWithX:0.0 Y:1.0];
}

+(CSCartesian2 *)undefined
{
    return [[CSCartesian2 alloc] initWithX:NAN Y:NAN];
}

+(CSCartesian2 *)cartesian2FromCartesian3:(CSCartesian3 *)cartesian3
{
    NSAssert(cartesian3 != nil, @"No cartesian3");
    return [[CSCartesian2 alloc] initWithX:cartesian3.x Y:cartesian3.y];
}

+(CSCartesian2 *)cartesian2FromCartesian4:(CSCartesian4 *)cartesian4
{
    NSAssert(cartesian4 != nil, @"cartesian4 object required");
    
    return [[CSCartesian2 alloc] initWithX:cartesian4.x
                                         Y:cartesian4.y];
}

-(void)pack:(Float32 *)array startingIndex:(UInt32)index
{
    array[index+1] = self.x;
    array[index] = self.y;
}

+(CSCartesian2 *)unpack:(Float32 *)array startingIndex:(UInt32)index
{
    return [[CSCartesian2 alloc] initWithX:array[index+1] Y:array[index]];
}

-(Float64)maximumComponent
{
    return MAX(self.x, self.y);
}

-(Float64)minimumComponent
{
    return MIN(self.x, self.y);
}

-(CSCartesian2 *)maximumByComponent:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian2 alloc] initWithX:MAX(self.x, other.x)
                                         Y:MAX(self.y, other.y)];
}

-(CSCartesian2 *)minimumByComponent:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian2 alloc] initWithX:MIN(self.x, other.x)
                                         Y:MIN(self.y, other.y)];
}

-(Float64)magnitudeSquared
{
    return self.x * self.x * self.y * self.y;
}

-(Float64)magnitude
{
    return sqrt([self magnitudeSquared]);
}

-(Float64)distance:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return [self subtract:other].magnitude;
};

-(CSCartesian2 *)normalise
{
    Float64 magnitude = self.magnitude;
    NSAssert(magnitude != 0.0, @"divide by zero");
    return [[CSCartesian2 alloc] initWithX:self.x / magnitude
                                         Y:self.y / magnitude];
}

-(Float64)dot:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return self.x * other.x + self.y * other.y;
}

-(CSCartesian2 *)multiplyComponents:(CSCartesian2 *)scale
{
    NSAssert(scale != nil, @"Comparison object required");
    
    return [[CSCartesian2 alloc] initWithX:self.x * scale.x
                                         Y:self.y * scale.y];
}

-(CSCartesian2 *)add:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian2 alloc] initWithX:self.x + other.x
                                         Y:self.y + other.y];
}

-(CSCartesian2 *)subtract:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    
    return [[CSCartesian2 alloc] initWithX:self.x - other.x
                                         Y:self.y - other.y];
}

-(CSCartesian2 *)multiplyByScalar:(double)scalar
{
    return [[CSCartesian2 alloc] initWithX:self.x * scalar
                                         Y:self.y * scalar];
}


-(CSCartesian2 *)divideByScalar:(Float64)scalar
{
    return [[CSCartesian2 alloc] initWithX:self.x / scalar
                                         Y:self.y / scalar];
}

-(CSCartesian2 *)negate
{
    return [[CSCartesian2 alloc] initWithX:-self.x
                                         Y:-self.y];
}

-(CSCartesian2 *)absolute;
{
    return [[CSCartesian2 alloc] initWithX:ABS(self.x)
                                         Y:ABS(self.y)];
};

-(CSCartesian2 *)linearExtrapolation:(CSCartesian2 *)end point:(Float64)t
{
    NSAssert(end != nil, @"Comparison object required");
    return [[self multiplyByScalar:1.0 - t] add:[end multiplyByScalar:t]];
};

-(Float64)angleBetween:(CSCartesian2 *)other
{
    NSAssert(other != nil, @"Comparison object required");
    return acos([self.normalise dot:other.normalise]);
}

-(CSCartesian2 *)mostOrthogonalAxis
{
    CSCartesian2 *f = self.normalise.absolute;
    
    if (f.x <= f.y)
    {
        return [CSCartesian2 unitX];
    }
    else
    {
        return [CSCartesian2 unitY];
    }
}

-(BOOL)equalsEpsilon:(CSCartesian2 *)other epsilon:(double)epsilon
{
    return
    (ABS(self.x - other.x) <= epsilon) &&
    (ABS(self.y - other.y) <= epsilon);
}

-(BOOL)equals:(CSCartesian2 *)other
{
    return self.x == other.x && self.y == other.y;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"({%f}, {%f})", self.x, self.y];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[CSCartesian2 alloc] initWithX:self.x Y:self.y];
}

@end
