//
//  CSGeodetic3D.m
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSCartographic.h"

@implementation CSCartographic

-(id)initWithLatitude:(Float64)latitude longitude:(Float64)longitude height:(Float64)height
{
    self = [super init];
    if (self)
    {
        _latitude = latitude;
        _longitude = longitude;
        _height = height;
    }
    return self;
}

-(id)initWithLatitude:(Float64)latitude longitude:(Float64)longitude
{
    self = [super init];
    if (self)
    {
        _latitude = latitude;
        _longitude = longitude;
        _height = 0.0f;
    }
    return self;
}

-(BOOL)equals:(CSCartographic *)other
{
    return self.latitude == other.latitude && self.longitude == other.longitude && self.height == other.height;
}

@end
