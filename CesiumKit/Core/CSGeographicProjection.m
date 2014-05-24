//
//  CSGeographicProjection.m
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSProjection+Private.h"
#import "CSGeographicProjection.h"

#import "CSCartesian3.h"
#import "CSCartographic.h"

@implementation CSGeographicProjection

-(CSCartesian3 *)project:(CSCartographic *)cartographic
{
    // Actually this is the special case of equidistant cylindrical called the plate carree
    return [[CSCartesian3 alloc] initWithX:cartographic.longitude * self.semimajorAxis
                                         Y:cartographic.latitude * self.semimajorAxis
                                         Z:cartographic.height];
}

-(CSCartographic *)unproject:(CSCartesian3 *)cartesian3
{
    return [[CSCartographic alloc] initWithLatitude:cartesian3.y * self.oneOverSemimajorAxis
                                          longitude:cartesian3.x * self.oneOverSemimajorAxis
                                             height:cartesian3.z];
}

@end
