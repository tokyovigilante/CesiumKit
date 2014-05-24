//
//  CSRay.m
//  CesiumKit
//
//  Created by Ryan Walklin on 10/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSRay.h"

#import "CSCartesian3.h"

@implementation CSRay

-(id)initWithOrigin:(CSCartesian3 *)origin direction:(CSCartesian3 *)direction
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
            _direction = CSCartesian3.zero;
        }
        if (origin)
        {
            _origin = origin.copy;
        }
        else
        {
            _origin = CSCartesian3.zero;
        }

    }
    return self;
}

-(CSCartesian3 *)getPoint:(Float64)t
{
    return [self.origin add:[self.direction multiplyByScalar:t]];
}

@end

