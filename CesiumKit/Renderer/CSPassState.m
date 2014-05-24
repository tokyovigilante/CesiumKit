//
//  CSPassState.m
//  CesiumKit
//
//  Created by Ryan Walklin on 6/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSPassState.h"

@implementation CSPassState

-(id)initWithContext:(CSContext *)context
{
    self = [super init];
    if (self)
    {
        NSAssert(context != nil, @"Nil context");
        _context = context;
    }
    return self;
}

@end
