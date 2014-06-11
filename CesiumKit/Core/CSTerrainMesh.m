//
//  CSTerrainMesh.m
//  CesiumKit
//
//  Created by Ryan Walklin on 2/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSTerrainMesh.h"

@implementation CSTerrainMesh

-(instancetype) initWithCenter:(Cartesian3 *)center
                      vertices:(CSFloat32Array *)vertices
                       indices:(CSUInt16Array *)indices
                 minimumHeight:(Float64)minimumHeight
                 maximumHeight:(Float64)maximumHeight
              boundingSphere3D:(CSBoundingSphere *)boundingSphere3D
    occludeePointInScaledSpace:(Cartesian3 *)occludeePointInScaledSpace
{
    self = [super init];
    if (self)
    {
        NSAssert(center != nil, @"center required");
        NSAssert(vertices != nil, @"vertices required");
        NSAssert(indices != nil, @"indices required");
        NSAssert(boundingSphere3D != nil, @"boundingSphere3D required");
        NSAssert(occludeePointInScaledSpace != nil, @"occludeePointInScaledSpace required");

        _center = center;
        _vertices = vertices;
        _indices = indices;
        _minimumHeight = minimumHeight;
        _maximumHeight = maximumHeight;
        _boundingSphere3D = boundingSphere3D;
        _occludeePointInScaledSpace = occludeePointInScaledSpace;
    }
    return self;
}

@end
