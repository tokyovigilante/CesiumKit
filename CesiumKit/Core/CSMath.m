//
//  CSMath.m
//  CesiumKit
//
//  Created by Ryan Walklin on 18/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSMath.h"

@implementation CSMath

+(UInt32)sign:(Float64)value
{
    if (value > 0) {
        return 1;
    }
    if (value < 0) {
        return -1;
    }
    return 0;
}

+(Float64)clampValue:(Float64)value min:(Float64)min max:(Float64)max
{
    return value < min ? min : value > max ? max : value;
}

+(Float64)toRadians:(Float64)degrees
{
    return degrees * M_PI / 180.0;
}

+(Float64)toDegrees:(Float64)radians;
{
    return radians * 180.0 / M_PI;
}

@end
