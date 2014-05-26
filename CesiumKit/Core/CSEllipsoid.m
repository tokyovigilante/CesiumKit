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

#import "CSMath.h"

static const Float64 CSEarthEquatorialRadius = 6378137.0;
static const Float64 CSEarthPolarRadius = 6356752.3142451793;

@interface CSEllipsoid ()

@property Float64 centerToleranceSquared;

@end

@implementation CSEllipsoid

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z
{
    self = [super init];
    if (self)
    {
        _radii = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        
        NSAssert(((_radii.x > 0.0) || (_radii.y > 0.0) || (_radii.z > 0.0)), @"Invalid negative ellipsoid");
        _radiiSquared = [_radii multiplyComponents:_radii];
        _radiiFourthPower = [_radiiSquared multiplyComponents:_radiiSquared];
        
        _oneOverRadii = [[CSCartesian3 alloc] initWithX:x == 0.0 ? 0.0 : 1.0 / x
                                                      Y:y == 0.0 ? 0.0 : 1.0 / y
                                                      Z:z == 0.0 ? 0.0 : 1.0 / z];
                         
        _oneOverRadiiSquared = [[CSCartesian3 alloc] initWithX:0.0 ? 0.0 : 1.0 / _radiiSquared.x
                                                             Y:0.0 ? 0.0 : 1.0 / _radiiSquared.y
                                                             Z:0.0 ? 0.0 : 1.0 / _radiiSquared.z];
        
        _minimumRadius = MIN(self.radii.x, MIN(self.radii.y, self.radii.z));
        _maximumRadius = MAX(self.radii.x, MAX(self.radii.y, self.radii.z));
        
        _centerToleranceSquared = CSEpsilon1;
    }
    return self;
}
+(CSEllipsoid *)wgs84Ellipsoid
{
    return [[CSEllipsoid alloc] initWithX:CSEarthEquatorialRadius Y:CSEarthEquatorialRadius Z:CSEarthPolarRadius];
}

+(CSEllipsoid *)unitSphereEllipsoid
{
    return [[CSEllipsoid alloc] initWithX:1.0 Y:1.0 Z:1.0];
}

+(CSEllipsoid *)ellipsoidWithCartesian3:(CSCartesian3 *)cartesian3
{
    NSAssert(cartesian3 != nil, @"no cartesian provided");
    return [[CSEllipsoid alloc] initWithX:cartesian3.x Y:cartesian3.y Z:cartesian3.z];
}

-(CSCartesian3 *)geocentricSurfaceNormal:(CSCartesian3 *)cartesian3
{
    return cartesian3.normalise;
}

-(CSCartesian3 *)geodeticSurfaceNormalCartographic:(CSCartographic *)cartographic
{
    NSAssert(cartographic != nil, @"no cartographic provided");

    Float64 cosLatitude = cos(cartographic.latitude);
    
    return [[CSCartesian3 alloc] initWithX:cosLatitude * cos(cartographic.longitude)
                                         Y:cosLatitude * sin(cartographic.longitude)
                                         Z:sin(cartographic.latitude)].normalise;
}

-(CSCartesian3 *)geodeticSurfaceNormal:(CSCartesian3 *)cartesian3
{
    return [cartesian3 multiplyComponents:self.oneOverRadiiSquared].normalise;
}

-(CSCartesian3 *)cartographicToCartesian:(CSCartographic *)cartographic
{
    //`cartographic is required` is thrown from geodeticSurfaceNormalCartographic.
    CSCartesian3 *n = [self geodeticSurfaceNormalCartographic:cartographic];
    CSCartesian3 *k = [self.radiiSquared multiplyComponents:n];
    
    Float64 gamma = sqrt([n dot:k]);
    k = [k divideByScalar:gamma];
    n = [n multiplyByScalar:cartographic.height];
    
    return [k add:n];
}

-(NSArray *)cartographicArrayToCartesianArray:(NSArray *)cartographicArray
{
    NSAssert(cartographicArray.count > 0, @"Empty vector array");
    
    NSMutableArray *cartesians = [NSMutableArray arrayWithCapacity:cartographicArray.count];
    
    for (CSCartographic *cartographic in cartographicArray)
    {
        [cartesians addObject:[self cartographicToCartesian:cartographic]];
    }
    
    return [NSArray arrayWithArray:cartesians];
}

-(CSCartographic *)cartesianToCartographic:(CSCartesian3 *)cartesian3
{
    CSCartesian3 *p = [self scaleToGeodeticSurface:cartesian3];
    CSCartesian3 *n = [self geodeticSurfaceNormal:p];
    CSCartesian3 *h = [cartesian3 subtract:p];

    return [[CSCartographic alloc] initWithLatitude:asin(n.z)
                                          longitude:atan2(n.y, n.x)
                                             height:[CSMath sign:([h dot:cartesian3])] * h.magnitude];
}

-(NSArray *)cartesianArrayToCartographicArray:(NSArray *)cartesianArray
{
    NSAssert(cartesianArray.count > 0, @"Empty vector array");
    
    NSMutableArray *cartesians = [NSMutableArray arrayWithCapacity:cartesianArray.count];
    
    for (CSCartesian3 *cartesian in cartesianArray)
    {
        [cartesians addObject:[self cartesianToCartographic:cartesian]];
    }
    
    return [NSArray arrayWithArray:cartesians];
}

-(CSCartesian3 *)scaleToGeodeticSurface:(CSCartesian3 *)cartesian
{
    Float64 positionX = cartesian.x;
    Float64 positionY = cartesian.y;
    Float64 positionZ = cartesian.z;
    
    Float64 oneOverRadiiX = self.oneOverRadii.x;
    Float64 oneOverRadiiY = self.oneOverRadii.y;
    Float64 oneOverRadiiZ = self.oneOverRadii.z;
    
    Float64 x2 = positionX * positionX * oneOverRadiiX * oneOverRadiiX;
    Float64 y2 = positionY * positionY * oneOverRadiiY * oneOverRadiiY;
    Float64 z2 = positionZ * positionZ * oneOverRadiiZ * oneOverRadiiZ;
    
    // Compute the squared ellipsoid norm.
    Float64 squaredNorm = x2 + y2 + z2;
    Float64 ratio = sqrt(1.0 / squaredNorm);
    
    // As an initial approximation, assume that the radial intersection is the projection point.
    CSCartesian3 *intersection = [cartesian multiplyByScalar:ratio];
    
    //* If the position is near the center, the iteration will not converge.
    if (squaredNorm < self.centerToleranceSquared)
    {
        return intersection;
    }
    
    Float64 oneOverRadiiSquaredX = self.oneOverRadiiSquared.x;
    Float64 oneOverRadiiSquaredY = self.oneOverRadiiSquared.y;
    Float64 oneOverRadiiSquaredZ = self.oneOverRadiiSquared.z;
    
    // Use the gradient at the intersection point in place of the true unit normal.
    // The difference in magnitude will be absorbed in the multiplier.
    CSCartesian3 *gradient = [[CSCartesian3 alloc] initWithX:intersection.x * oneOverRadiiSquaredX * 2.0
                                                           Y:intersection.y * oneOverRadiiSquaredY * 2.0
                                                           Z:intersection.z * oneOverRadiiSquaredZ * 2.0];
    
    // Compute the initial guess at the normal vector multiplier, lambda.
    Float64 lambda = (1.0 - ratio) * cartesian.magnitude / (0.5 * gradient.magnitude);
    Float64 correction = 0.0;
    
    Float64 func;
    Float64 denominator;
    Float64 xMultiplier;
    Float64 yMultiplier;
    Float64 zMultiplier;
    Float64 xMultiplier2;
    Float64 yMultiplier2;
    Float64 zMultiplier2;
    Float64 xMultiplier3;
    Float64 yMultiplier3;
    Float64 zMultiplier3;
    
    do {
        lambda -= correction;
        
        xMultiplier = 1.0 / (1.0 + lambda * oneOverRadiiSquaredX);
        yMultiplier = 1.0 / (1.0 + lambda * oneOverRadiiSquaredY);
        zMultiplier = 1.0 / (1.0 + lambda * oneOverRadiiSquaredZ);
        
        xMultiplier2 = xMultiplier * xMultiplier;
        yMultiplier2 = yMultiplier * yMultiplier;
        zMultiplier2 = zMultiplier * zMultiplier;
        
        xMultiplier3 = xMultiplier2 * xMultiplier;
        yMultiplier3 = yMultiplier2 * yMultiplier;
        zMultiplier3 = zMultiplier2 * zMultiplier;
        
        func = x2 * xMultiplier2 + y2 * yMultiplier2 + z2 * zMultiplier2 - 1.0;
        
        // "denominator" here refers to the use of this expression in the velocity and acceleration
        // computations in the sections to follow.
        denominator = x2 * xMultiplier3 * oneOverRadiiSquaredX + y2 * yMultiplier3 * oneOverRadiiSquaredY + z2 * zMultiplier3 * oneOverRadiiSquaredZ;
        
        Float64 derivative = -2.0 * denominator;
        
        correction = func / derivative;
    } while (abs(func) > CSEpsilon12);
    
    
    return [[CSCartesian3 alloc] initWithX:positionX * xMultiplier
                                         Y:positionY * yMultiplier
                                         Z:positionZ * zMultiplier];

}

-(CSCartesian3 *)scaleToGeocentricSurface:(CSCartesian3 *)position
{
    double beta = 1.0 / sqrt((position.x * position.x) * self.oneOverRadiiSquared.x +
                             (position.y * position.y) * self.oneOverRadiiSquared.y +
                             (position.z * position.z) * self.oneOverRadiiSquared.z);
    
    return [position multiplyByScalar:beta];
}

-(CSCartesian3 *)transformPositionToScaledSpace:(CSCartesian3 *)position
{
    return [position multiplyComponents:self.oneOverRadii];

}

-(BOOL)equals:(CSEllipsoid *)other
{
    NSAssert(other != nil, @"Nil comparison object");
    return [self.radii equals:other.radii];
}

/**
 * Duplicates an Ellipsoid instance.
 *
 * @memberof Ellipsoid
 *
 * @param {Ellipsoid} ellipsoid The ellipsoid to duplicate.
 * @param {Ellipsoid} [result] The object onto which to store the result, or undefined if a new
 *                    instance should be created.
 * @returns {Ellipsoid} The cloned Ellipsoid. (Returns undefined if ellipsoid is undefined)
 */
-(instancetype)copyWithZone:(NSZone *)zone
{
    return [[CSEllipsoid alloc] initWithX:self.radii.x Y:self.radii.y Z:self.radii.z];
}

@end
