//
//  CSRay.m
//  CesiumKit
//
//  Created by Ryan Walklin on 10/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSRay.h"

#import "Cartesian3.h"

@implementation CSRay

-(id)initWithOrigin:(Cartesian3 *)origin direction:(Cartesian3 *)direction
{
    self = [super init];
    if (self)
    {
        if (direction)
        {
            _direction = direction.normalise;
        }
        else
        {
            _direction = Cartesian3.zero;
        }
        if (origin)
        {
            _origin = origin.copy;
        }
        else
        {
            _origin = Cartesian3.zero;
        }

    }
    return self;
}

-(Cartesian3 *)getPoint:(Float64)t
{
    return [self.origin add:[self.direction multiplyByScalar:t]];
}

@end

