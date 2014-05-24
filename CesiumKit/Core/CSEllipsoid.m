//
//  CSEllipsoid.m
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe
//

#import "CSEllipsoid.h"

#import "CSCartesian3.h"
#import "CSCartographic.h"

static const Float64 CSEarthEquatorialRadius = 6378137.0;
static const Float64 CSEarthPolarRadius = 6356752.314245;

@interface CSEllipsoid ()

@property CSCartesian3 *radiiFourthPower;

@end

@implementation CSEllipsoid

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z
{
    self = [super init];
    if (self)
    {
        _radii = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        
        NSAssert(((_radii.x > 0.0) || (_radii.y > 0.0) || (_radii.z > 0.0)), @"Invalid negative ellipsoid");
        
        _radiiSquared = [[CSCartesian3 alloc] initWithX:_radii.x * _radii.x
                                                      Y:_radii.y * _radii.y
                                                      Z:_radii.z * _radii.z];
        _radiiFourthPower = [[CSCartesian3 alloc] initWithX:_radiiSquared.x * _radiiSquared.x
                                                          Y:_radiiSquared.y * _radiiSquared.y
                                                          Z:_radiiSquared.z * _radii.z];
        _oneOverRadiiSquared = [[CSCartesian3 alloc] initWithX:1.0 / _radiiSquared.x
                                                             Y:1.0 / _radiiSquared.y
                                                             Z:1.0 / _radiiSquared.z];
    }
    return self;
}
+(CSEllipsoid *)wgs84Ellipsoid
{
    return [[CSEllipsoid alloc] initWithX:CSEarthEquatorialRadius Y:CSEarthEquatorialRadius Z:CSEarthPolarRadius];
}

+(CSEllipsoid *)scaledwgs4ScaledEllipsoid
{
    return [[CSEllipsoid alloc] initWithX:1.0 Y:1.0 Z:6356752.314245 / 6378137.0];
}

+(CSEllipsoid *)unitSphereEllipsoid
{
    return [[CSEllipsoid alloc] initWithX:1.0 Y:1.0 Z:1.0];
}

+(CSEllipsoid *)ellipsoidWithCartesian3:(CSCartesian3 *)cartesian3
{
    return [[CSEllipsoid alloc] initWithX:cartesian3.x Y:cartesian3.y Z:cartesian3.z];
}

-(CSCartesian3 *)centricSurfaceNormal:(CSCartesian3 *)positionOnEllipsoid
{
    return positionOnEllipsoid.normalise;
}

-(CSCartesian3 *)geodeticSurfaceNormalForPosition:(CSCartesian3 *)positionOnEllipsoid
{
    return [positionOnEllipsoid multiplyComponents:self.oneOverRadiiSquared.normalise];
}

-(CSCartesian3 *)geodeticSurfaceNormalForGeodetic3D:(CSCartographic *)cartographic
{
    Float64 cosLatitude = cos(cartographic.latitude);
    
    return [[CSCartesian3 alloc] initWithX:cosLatitude * cos(cartographic.longitude)
                                       Y:cosLatitude * sin(cartographic.longitude)
                                       Z:sin(cartographic.latitude)];
}

-(Float64)minimumRadius
{
    return MIN(self.radii.x, MIN(self.radii.y, self.radii.z));
}

-(Float64)maximumRadius
{
    return MAX(self.radii.x, MAX(self.radii.y, self.radii.z));
}

// takes two double pointers, returns number of intersections,
-(UInt32)intersections:(CSCartesian3 *)origin direction:(CSCartesian3 *)direction first:(Float64 *)first second:(Float64 *)second
{
    CSCartesian3 *directionNormalised = direction.normalise;
    
    // By laborious algebraic manipulation....
    Float64 a = directionNormalised.x * directionNormalised.x * _oneOverRadiiSquared.x +
    directionNormalised.y * directionNormalised.y * _oneOverRadiiSquared.y +
    directionNormalised.z * directionNormalised.z * _oneOverRadiiSquared.z;
    Float64 b = 2.0 *
    (origin.x * directionNormalised.x * _oneOverRadiiSquared.x +
     origin.y * directionNormalised.y * _oneOverRadiiSquared.y +
     origin.z * directionNormalised.z * _oneOverRadiiSquared.z);
    Float64 c = origin.x * origin.x * _oneOverRadiiSquared.x +
    origin.y * origin.y * _oneOverRadiiSquared.y +
    origin.z * origin.z * _oneOverRadiiSquared.z - 1.0;
    
    // Solve the quadratic equation: ax^2 + bx + c = 0.
    // Algorithm is from Wikipedia's "Quadratic equation" topic, and Wikipedia credits
    // Numerical Recipes in C, section 5.6: "Quadratic and Cubic Equations"
    Float64 discriminant = b * b - 4 * a * c;
    if (discriminant < 0.0)
    {
        // no intersections
        *first = NAN;
        *second = NAN;
        return 0;
    }
    else if (discriminant == 0.0)
    {
        // one intersection at a tangent point
        *first = -0.5 * b / a ;
        *second = NAN;
        return 1;
    }
    
    Float64 t = -0.5 * (b + (b > 0.0 ? 1.0 : -1.0) * sqrt(discriminant));
    Float64 root1 = t / a;
    Float64 root2 = c / t;
    
    // Two intersections - return the smallest first.
    if (root1 < root2)
    {
        *first = root1;
        *second = root2;
    }
    else
    {
        *first = root2;
        *second = root1;
    }
    return 2;
}
#warning fix ellipsoid
/*
-(CSCartesian3 *)vector3DfromGeodetic2D:(CSGeodetic2D *)geodetic2D
{
    return [self vector3DfromGeodetic3D:[[CSGeodetic3D alloc] initWithGeodetic2D:geodetic2D height:0.0]];
}

-(CSCartesian3 *)vector3DfromGeodetic3D:(CSGeodetic3D *)geodetic3D
{
    CSCartesian3 *n = [self geodeticSurfaceNormalForGeodetic3D:geodetic3D];
    CSCartesian3 *k = [self.radiiSquared multiplyComponents:n];
    Float64 gamma = sqrt((k.x * n.x) +
                        (k.y * n.y) +
                        (k.z * n.z));
    
    CSCartesian3 *rSurface = [k divideScalar:gamma];
    return [rSurface add:[n multiplyScalar:geodetic3D.height]];
}*/

-(NSArray *)geodetic2DArrayFromPositionArray:(NSArray *)positionArray
{
    NSAssert(positionArray.count > 0, @"Empty vector array");
    
    NSMutableArray *geodetics = [NSMutableArray arrayWithCapacity:positionArray.count];
    
    for (CSCartesian3 *position in positionArray)
    {
        [geodetics addObject:[self geodetic2DFromPosition:position]];
    }
    
    return [NSArray arrayWithArray:geodetics];
}

-(NSArray *)geodetic3DArrayFromPositionArray:(NSArray *)positionArray
{
    NSAssert(positionArray.count > 0, @"Empty vector array");
    
    NSMutableArray *geodetics = [NSMutableArray arrayWithCapacity:positionArray.count];
    
    for (CSCartesian3 *position in positionArray)
    {
        [geodetics addObject:[self geodetic3DFromPosition:position]];
    }
    
    return [NSArray arrayWithArray:geodetics];

}
#warning fix ellipsoid
/*
-(CSGeodetic2D *)geodetic2DFromPosition:(CSCartesian3 *)position
{
    CSCartesian3 *n = [self geodeticSurfaceNormalForPosition:position];
    return [[CSGeodetic2D alloc] initWithLatitude:asin(n.z / n.magnitude)
                                        longitude:atan2(n.y, n.x)];
}

-(CSGeodetic3D *)geodetic3DFromPosition:(CSCartesian3 *)position
{
    CSCartesian3 *p = [self scaleToGeodeticSurface:position];
    CSCartesian3 *h = [position subtract:p];
    
    Float64 heightIntermed = [h dot:position];
    Float64 height = (heightIntermed > 0) - (heightIntermed < 0) * h.magnitude;
    
    return [[CSGeodetic3D alloc] initWithGeodetic2D:[self geodetic2DFromPosition:p] height:height];
}*/

-(CSCartesian3 *)scaleToGeodeticSurface:(CSCartesian3 *)position
{
    double beta = 1.0 / sqrt((position.x * position.x) * self.oneOverRadiiSquared.x +
                             (position.y * position.y) * self.oneOverRadiiSquared.y +
                             (position.z * position.z) * self.oneOverRadiiSquared.z);
    
    double n = [[CSCartesian3 alloc] initWithX:beta * position.x * self.oneOverRadiiSquared.x
                                           Y:beta * position.y * self.oneOverRadiiSquared.y
                                           Z:beta * position.z * self.oneOverRadiiSquared.z].magnitude;
    
    double alpha = (1.0 - beta) * (position.magnitude / n);
    
    double x2 = position.x * position.x;
    double y2 = position.y * position.y;
    double z2 = position.z * position.z;
    
    double da = 0.0;
    double db = 0.0;
    double dc = 0.0;
    
    double s = 0.0;
    double dSdA = 1.0;
    
    do
    {
        alpha -= (s / dSdA);
        
        da = 1.0 + (alpha * self.oneOverRadiiSquared.x);
        db = 1.0 + (alpha * self.oneOverRadiiSquared.y);
        dc = 1.0 + (alpha * self.oneOverRadiiSquared.z);
        
        double da2 = da * da;
        double db2 = db * db;
        double dc2 = dc * dc;
        
        double da3 = da * da2;
        double db3 = db * db2;
        double dc3 = dc * dc2;
        
        s = x2 / (self.radiiSquared.x * da2) +
        y2 / (self.radiiSquared.y * db2) +
        z2 / (self.radiiSquared.z * dc2) - 1.0;
        
        dSdA = -2.0 *
        (x2 / (self.radiiFourthPower.x * da3) +
         y2 / (self.radiiFourthPower.y * db3) +
         z2 / (self.radiiFourthPower.z * dc3));
    }
    while (ABS(s) > 1e-10);
    
    return [[CSCartesian3 alloc] initWithX:position.x / da
                                       Y:position.y / db
                                       Z:position.z / dc];
}

-(CSCartesian3 *)scaleToGeocentricSurface:(CSCartesian3 *)position
{
    double beta = 1.0 / sqrt((position.x * position.x) * self.oneOverRadiiSquared.x +
                             (position.y * position.y) * self.oneOverRadiiSquared.y +
                             (position.z * position.z) * self.oneOverRadiiSquared.z);
    
    return [position multiplyByScalar:beta];
}

-(NSArray *)computeCurve:(CSCartesian3 *)start stop:(CSCartesian3 *)stop granularity:(Float64)granularity
{
    NSAssert(granularity <= 0.0, @"Granularity must be greater than zero.");

    CSCartesian3 *normal = [start cross:stop].normalise;
    Float64 theta = [start angleBetween:stop];
    UInt32 n = MAX((UInt32)(theta / granularity) - 1, 0);
    
    NSMutableArray *positionArray = [NSMutableArray arrayWithCapacity:2 + n];

    [positionArray addObject:start];
    
    for (int i=1; i <= n; i++)
    {
        Float64 phi = i * granularity;
        [positionArray addObject:[self scaleToGeocentricSurface:[start rotateAroundAxis:normal theta:phi]]];
    }
    
    [positionArray addObject:stop];
    
    return [NSArray arrayWithArray:positionArray];
}

@end
