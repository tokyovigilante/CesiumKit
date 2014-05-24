//
//  CSSpherical.m
//  CesiumKit
//
//  Created by Ryan Walklin on 4/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSSpherical.h"

#import "CSCartesian3.h"

@implementation CSSpherical


-(id)initWithClock:(Float64)clock cone:(Float64)cone magnitude:(Float64)magnitude
{
    self = [super init];
    if (self)
    {
        _clock = clock;
        _cone = cone;
        _magnitude = magnitude;
    }
    return self;
}

+(CSSpherical *)sphericalFromCartesian3:(CSCartesian3 *)cartesian3
{
    NSAssert(cartesian3 != nil, @"Cartesian3 is required");
    
    Float64 x = cartesian3.x;
    Float64 y = cartesian3.y;
    Float64 z = cartesian3.z;
    
    Float64 radialSquared = x * x + y * y;
    
    return [[CSSpherical alloc] initWithClock:atan2(y, x)
                                         cone:atan2(sqrt(radialSquared), z)
                                    magnitude:sqrt(radialSquared + z * z)];
}


-(CSSpherical *)normalise
{
    return [[CSSpherical alloc] initWithClock:self.clock
                                         cone:self.cone
                                    magnitude:1.0];
}

/**
 * Returns YES if the  spherical is equal to the second spherical, NO otherwise.
 * @memberof Spherical
 *
 * @param {Spherical} other The second Spherical to be compared.
 *
 */
-(BOOL)equals:(CSSpherical *)other
{
    if (!other)
    {
        return NO;
    }
    return (self.clock == other.clock &&
            self.cone == other.cone &&
            self.magnitude == other.magnitude);
}


-(BOOL)equals:(CSSpherical *)other epsilon:(Float64)epsilon
{
    if (!other)
    {
        return NO;
    }
    return (ABS(self.clock - other.clock) <= epsilon &&
            ABS(self.cone - other.cone) <= epsilon &&
            ABS(self.magnitude - other.magnitude) <= epsilon);
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f, %f)", self.clock, self.cone, self.magnitude];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[CSSpherical alloc] initWithClock:self.clock cone:self.cone magnitude:self.magnitude];
}

@end
