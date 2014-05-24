//
//  CSFrameState.m
//  CesiumKit
//
//  Created by Ryan Walklin on 5/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSFrameState.h"

#import "CSWebMercatorProjection.h"

@implementation CSFrameState

-(id)init
{
    self = [super init];
    if (self)
    {
        _sceneIs3D = YES;
        _frameNumber = 0;
        _time = 0;
        _projection = [[CSWebMercatorProjection alloc] initWithEllipsoid:nil]; // WGS84
        _camera = nil;
        _cullingVolume = nil;
        _renderPass = NO;
        _pickPass = NO;
        _afterRender = [NSMutableArray array];
    }
    return self;
}

@end
