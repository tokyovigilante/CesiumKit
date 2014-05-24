//
//  CSWebMercatorProjection.m
//  CesiumKit
//
//  Created by Ryan Walklin on 5/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSProjection+Private.h"
#import "CSWebMercatorProjection.h"

#import "CSEllipsoid.h"
#import "CSCartesian3.h"
#import "CSCartographic.h"

@implementation CSWebMercatorProjection

-(Float64)mercatorAngleToGeodeticLatitude:(Float64)angle
{
    return M_PI_2 - (2.0 * atan(exp(-angle)));
}

-(Float64)geodeticLatitudeToMercatorAngle:(Float64)latitude
{
    // Clamp the latitude coordinate to the valid Mercator bounds.
    if (latitude > self.maximumLatitude)
    {
        latitude = self.maximumLatitude;
    }
    else if (latitude < -self.maximumLatitude)
    {
        latitude = -self.maximumLatitude;
    }
    Float64 sinLatitude = sin(latitude);
    return 0.5 * log((1.0 + sinLatitude) / (1.0 - sinLatitude));
}

-(Float64)maximumLatitude
{
    return [self mercatorAngleToGeodeticLatitude:M_PI];
}

-(CSCartesian3 *)project:(CSCartographic *)cartographic
{
    return [[CSCartesian3 alloc] initWithX:cartographic.longitude * self.semimajorAxis
                                         Y:[self geodeticLatitudeToMercatorAngle:cartographic.latitude] * self.semimajorAxis
                                         Z:cartographic.height];
}

-(CSCartographic *)unproject:(CSCartesian3 *)cartesian3
{
    return [[CSCartographic alloc] initWithLatitude:[self mercatorAngleToGeodeticLatitude:(cartesian3.y * self.oneOverSemimajorAxis)]
                                          longitude:cartesian3.x * self.oneOverSemimajorAxis
                                             height:cartesian3.z];
}

@end

