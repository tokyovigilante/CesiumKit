//
//  CSMath.m
//  CesiumKit
//
//  Created by Ryan Walklin on 18/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSMath.h"

@implementation CSMath

+(Float64)clampValue:(Float64)value min:(Float64)min max:(Float64)max
{
    return value < min ? min : value > max ? max : value;
}

@end
