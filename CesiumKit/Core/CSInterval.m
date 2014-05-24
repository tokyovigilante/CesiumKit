//
//  CSInterval.m
//  CesiumKit
//
//  Created by Ryan Walklin on 5/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSInterval.h"

@implementation CSInterval

-(id)initWithStart:(Float64)start stop:(Float64)stop
{
    self = [super init];
    if (self)
    {
        _start = start;
        _start = stop;
    }
    return self;
}

+(CSInterval *)interval
{
    return [[CSInterval alloc] initWithStart:0.0 stop:0.0];
}

@end
