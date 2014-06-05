//
//  CSBoundingSphere.m
//  CesiumKit
//
//  Created by Ryan Walklin on 24/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSBoundingSphere.h"

#import "CSCartesian3.h"
#import "CSGeographicProjection.h"
#import "CSWebMercatorProjection.h"
#import "CSRectangle.h"
#import "CSFloat32Array.h"
#import "CSEllipsoid.h"

@implementation CSBoundingSphere

-(instancetype)initWithCenter:(CSCartesian3 *)center radius:(Float64)radius
{
    self = [super init];
    if (self)
    {
        if (center == nil)
        {
            _center = CSCartesian3.zero;
        }
        else
        {
            _center = center.copy;
        }
        _radius = radius;
    }
    return self;
}

+(CSBoundingSphere *)sphereFromPoints:(NSArray *)positions
{
    if (!positions || positions.count == 0)
    {
        return [[CSBoundingSphere alloc] initWithCenter:nil radius:0.0];
    }
    
    CSCartesian3 *currentPos = [positions.firstObject copy];
    
    CSCartesian3 *xMin = currentPos.copy;
    CSCartesian3 *yMin = currentPos.copy;
    CSCartesian3 *zMin = currentPos.copy;
    
    CSCartesian3 *xMax = currentPos.copy;
    CSCartesian3 *yMax = currentPos.copy;
    CSCartesian3 *zMax = currentPos.copy;

    for (CSCartesian3 *position in positions)
    {
        Float64 x = position.x;
        Float64 y = position.y;
        Float64 z = position.z;
        
        // Store points containing the the smallest and largest components
        if (x < xMin.x)
        {
            xMin = position.copy;
        }
        
        if (x > xMax.x)
        {
            xMax = position.copy;
        }
        
        if (y < yMin.y)
        {
            yMin = position.copy;
        }
        
        if (y > yMax.y)
        {
            yMax = position.copy;
        }
        
        if (z < zMin.z)
        {
            zMin = position.copy;
        }
        
        if (z > zMax.z)
        {
            zMax = position.copy;
        }

    }
    
    // Compute x-, y-, and z-spans (Squared distances b/n each component's min. and max.).
    Float64 xSpan = [xMax subtract:xMin].magnitudeSquared;
    Float64 ySpan = [yMax subtract:yMin].magnitudeSquared;
    Float64 zSpan = [zMax subtract:zMin].magnitudeSquared;
    
    // Set the diameter endpoints to the largest span.
    CSCartesian3 *diameter1 = [xMin copy];
    CSCartesian3 *diameter2 = [xMax copy];
    Float64 maxSpan = xSpan;
    
    if (ySpan > maxSpan)
    {
        maxSpan = ySpan;
        diameter1 = yMin.copy;
        diameter2 = yMax.copy;
    }
    
    if (zSpan > maxSpan)
    {
        maxSpan = zSpan;
        diameter1 = zMin.copy;
        diameter2 = zMax.copy;
    }
    
    // Calculate the center of the initial sphere found by Ritter's algorithm
    CSCartesian3 *ritterCenter = [[CSCartesian3 alloc] initWithX:(diameter1.x + diameter2.x) * 0.5
                                                               Y:(diameter1.y + diameter2.y) * 0.5
                                                               Z:(diameter1.z + diameter2.z) * 0.5];
    
    // Calculate the radius of the initial sphere found by Ritter's algorithm
    Float64 ritterRadius = sqrt([diameter2 subtract:ritterCenter].magnitudeSquared);
    
    // Find the center of the sphere found using the Naive method.
    CSCartesian3 *minBoxPt = [[CSCartesian3 alloc] initWithX:xMin.x Y:yMin.y Z:zMin.z];
    CSCartesian3 *maxBoxPt = [[CSCartesian3 alloc] initWithX:xMax.x Y:yMaz.y Z:zMax.z];
    
    CSCartesian3 *naiveCenter = [[minBoxPt add:maxBoxPt] multiplyScalar:0.5];
    
    // Begin 2nd pass to find naive radius and modify the ritter sphere.
    Float64 naiveRadius = 0;
    
    for (CSCartesian3 *position in positions)
    {
        // Find the furthest point from the naive center to calculate the naive radius.
        Float64 r = [position subtract:naiveCenter].magnitude;
        if (r > naiveRadius)
        {
            naiveRadius = r;
        }
        
        // Make adjustments to the Ritter Sphere to include all points.
        Float64 oldCenterToPointSquared = [position subtract:ritterCenter].magnitudeSquared;
        
        if (oldCenterToPointSquared > radiusSquared)
        {
            Float64 oldCenterToPoint = sqrt(oldCenterToPointSquared);
            
            // Calculate new radius to include the point that lies outside
            ritterRadius = (ritterRadius + oldCenterToPoint) * 0.5;
            radiusSquared = ritterRadius * ritterRadius;
            // Calculate center of new Ritter sphere
            Float64 oldToNew = oldCenterToPoint - ritterRadius;
            ritterCenter = [[CSCartesian3 alloc] initWithX:(ritterRadius * ritterCenter.x + oldToNew * currentPos.x) / oldCenterToPoint
                                                         Y:(ritterRadius * ritterCenter.y + oldToNew * currentPos.y) / oldCenterToPoint
                                                         Z:(ritterRadius * ritterCenter.z + oldToNew * currentPos.z) / oldCenterToPoint];

        }
    }
                            
    if (ritterRadius < naiveRadius)
    {
        return [[CSBoundingSphere alloc] initWithCenter:[ritterCenter copy] radius:ritterRadius];
    }
    else
    {
        return [[CSBoundingSphere alloc] initWithCenter:[naiveCenter copy] radius:naiveRadius];
    }
}

+(CSBoundingSphere *)sphereFromRectangle2D:(CSRectangle *)rectangle projection:(CSProjection *)projection
{
    return [CSBoundingSphere sphereFromRectangle2D:rectangle minimumHeight:0.0 maximumHeight:0.0 projection:projection];
}

+(CSBoundingSphere *)sphereFromRectangle2D:(CSRectangle *)rectangle minimumHeight:(Float64)minimumHeight maximumHeight:(Float64)maximumHeight projection:(CSProjection *)projection
{
    if (!rectangle)
    {
        return [[CSBoundingSphere alloc] initWithCenter:[CSCartesian3 zero] radius:0.0];
    }
    
    if (!projection)
    {
        projection = [[CSGeographicProjection alloc] initWithEllipsoid:nil];
    }
    
    Rectangle.getSouthwest(rectangle, fromRectangle2DSouthwest);
    fromRectangle2DSouthwest.height = minimumHeight;
    Rectangle.getNortheast(rectangle, fromRectangle2DNortheast);
    fromRectangle2DNortheast.height = maximumHeight;
    
    var lowerLeft = projection.project(fromRectangle2DSouthwest, fromRectangle2DLowerLeft);
    var upperRight = projection.project(fromRectangle2DNortheast, fromRectangle2DUpperRight);
    
    var width = upperRight.x - lowerLeft.x;
    var height = upperRight.y - lowerLeft.y;
    var elevation = upperRight.z - lowerLeft.z;
    
    result.radius = Math.sqrt(width * width + height * height + elevation * elevation) * 0.5;
    var center = result.center;
    center.x = lowerLeft.x + width * 0.5;
    center.y = lowerLeft.y + height * 0.5;
    center.z = lowerLeft.z + elevation * 0.5;
    return result;
    
}

+(CSBoundingSphere *)sphereFromRectangle3D:(CSRectangle *)rectangle ellipsoid:(CSEllipsoid *)ellipsoid surfaceHeight:(Float64)surfaceHeight
{
    if (!ellipsoid)
    {
        ellipsoid = [CSEllipsoid wgs84Ellipsoid];
    }
    
    NSArray *positions;
    if (rectangle)
    {
        positions = [rectangle subsample:ellipsoid surfaceHeight:surfaceHeight];
    }
    
    return [CSBoundingSphere sphereFromPoints:positions];
}

+(CSBoundingSphere *)sphereFromVertices:(CSFloat32Array *)vertices center:(CSCartesian3 *)center stride:(UInt32)stride
{
    if (!vertices || vertices.length == 0)
    {
        return [[CSBoundingSphere alloc] initWithCenter:CSCartesian3.zero radius:0.0];
    }
    
    if (!center)
    {
        center = CSCartesian3.zero;
    }
    NSAssert(stride >= 3, @"stride must be 3 or greater");
    
    CSCartesian3 *currentPos = [[CSCartesian3 alloc] initWithX:vertices[0] + center.x
                                                             Y:vertices[1] + center.y
                                                             Z:vertices[2] + center.z];

    
    CSCartesian3 xMin = currentPos.copy;
    CSCartesian3 yMin = currentPos.copy;
    CSCartesian3 zMin = currentPos.copy;
    
    CSCartesian3 xMax = currentPos.copy;
    CSCartesian3 yMax = currentPos.copy;
    CSCartesian3 zMax = currentPos.copy;
    
    UInt32 numElements = positions.length;
    for (var i = 0; i < numElements; i += stride)
    {
        Float64 x = positions[i] + center.x;
        Float64 y = positions[i + 1] + center.y;
        Float64 z = positions[i + 2] + center.z;
        
        // Store points containing the the smallest and largest components
        if (x < xMin.x)
        {
            xMin = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        }
        
        if (x > xMax.x)
        {
            xMax = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        }
        
        if (y < yMin.y)
        {
            yMin = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        }
        
        if (y > yMax.y)
        {
            yMax = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        }
        
        if (z < zMin.z)
        {
            zMin = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        }
        
        if (z > zMax.z)
        {
            zMax = [[CSCartesian3 alloc] initWithX:x Y:y Z:z];
        }
    }
    
    // Compute x-, y-, and z-spans (Squared distances b/n each component's min. and max.).
    Float64 xSpan = [xMax subtract:xMin].magnitudeSquared;
    Float64 ySpan = [yMax subtract:yMin].magnitudeSquared;
    Float64 zSpan = [zMax subtract:zMin].magnitudeSquared;
    
    // Set the diameter endpoints to the largest span.
    CSCartesian3 *diameter1 = [xMin copy];
    CSCartesian3 *diameter2 = [xMax copy];
    Float64 maxSpan = xSpan;
    
    if (ySpan > maxSpan)
    {
        maxSpan = ySpan;
        diameter1 = yMin.copy;
        diameter2 = yMax.copy;
    }
    
    if (zSpan > maxSpan)
    {
        maxSpan = zSpan;
        diameter1 = zMin.copy;
        diameter2 = zMax.copy;
    }
    
    // Calculate the center of the initial sphere found by Ritter's algorithm
    var ritterCenter = fromPointsRitterCenter;
    ritterCenter.x = (diameter1.x + diameter2.x) * 0.5;
    ritterCenter.y = (diameter1.y + diameter2.y) * 0.5;
    ritterCenter.z = (diameter1.z + diameter2.z) * 0.5;
    
    // Calculate the center of the initial sphere found by Ritter's algorithm
    CSCartesian3 *ritterCenter = [[CSCartesian3 alloc] initWithX:(diameter1.x + diameter2.x) * 0.5
                                                               Y:(diameter1.y + diameter2.y) * 0.5
                                                               Z:(diameter1.z + diameter2.z) * 0.5];
    
    // Calculate the radius of the initial sphere found by Ritter's algorithm
    Float64 ritterRadius = sqrt([diameter2 subtract:ritterCenter].magnitudeSquared);
    
    // Find the center of the sphere found using the Naive method.
    CSCartesian3 *minBoxPt = [[CSCartesian3 alloc] initWithX:xMin.x Y:yMin.y Z:zMin.z];
    CSCartesian3 *maxBoxPt = [[CSCartesian3 alloc] initWithX:xMax.x Y:yMaz.y Z:zMax.z];
    
    CSCartesian3 *naiveCenter = [[minBoxPt add:maxBoxPt] multiplyScalar:0.5];
    
    // Begin 2nd pass to find naive radius and modify the ritter sphere.
    Float64 naiveRadius = 0;

    for (i = 0; i < numElements; i += stride)
    {
        currentPos = [[CSCartesian3 alloc] initWithX:vertices[i] + center.x
                                                   Y:vertices[i+1] + center.y
                                                   Z:vertices[i+2] + center.z];
        
        // Find the furthest point from the naive center to calculate the naive radius.
        Float64 r = [currentPos subtract:naiveCenter].magnitude;
        if (r > naiveRadius)
        {
            naiveRadius = r;
        }
        
        // Make adjustments to the Ritter Sphere to include all points.
        Float64 oldCenterToPointSquared = [currentPos subtract:ritterCenter].magnitudeSquared;
        
        if (oldCenterToPointSquared > radiusSquared)
        {
            Float64 oldCenterToPoint = sqrt(oldCenterToPointSquared);
            
            // Calculate new radius to include the point that lies outside
            ritterRadius = (ritterRadius + oldCenterToPoint) * 0.5;
            radiusSquared = ritterRadius * ritterRadius;
            // Calculate center of new Ritter sphere
            Float64 oldToNew = oldCenterToPoint - ritterRadius;
            ritterCenter = [[CSCartesian3 alloc] initWithX:(ritterRadius * ritterCenter.x + oldToNew * currentPos.x) / oldCenterToPoint
                                                         Y:(ritterRadius * ritterCenter.y + oldToNew * currentPos.y) / oldCenterToPoint
                                                         Z:(ritterRadius * ritterCenter.z + oldToNew * currentPos.z) / oldCenterToPoint];
            
        }
    }
    
    if (ritterRadius < naiveRadius)
    {
        return [[CSBoundingSphere alloc] initWithCenter:[ritterCenter copy] radius:ritterRadius];
    }
    else
    {
        return [[CSBoundingSphere alloc] initWithCenter:[naiveCenter copy] radius:naiveRadius];
    }
}

+(CSBoundingSphere *)sphereFromCornerPoint:(CSCartesian3 *)corner oppositeCorner:(CSCartesian3 *)oppositeCorner
{
    CSCartesian3 *center = [[corner add:oppositeCorner] multiplyByScalar:0.5];
    return [[CSBoundingSphere alloc] initWithCenter:center radius:[center distance:oppositeCorner]];
}

+(CSBoundingSphere *)sphereFromEllipsoid:(CSEllipsoid *)ellipsoid
{
    NSAssert(ellipsoid != nil, @"ellipsoid is required");
    
    return [[CSBoundingSphere alloc] initWithCenter:CSCartesian3.zero radius:ellipsoid.maximumRadius];
}

/**
 * The number of elements used to pack the object into an array.
 * @type {Number}
 */
//BoundingSphere.packedLength = 4;

/**
 * Stores the provided instance into the provided array.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} value The value to pack.
 * @param {Number[]} array The array to pack into.
 * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
 */
//-(void *)pack:(UInt32)startingIndex;

/**
 * Retrieves an instance from a packed array.
 * @memberof BoundingSphere
 *
 * @param {Number[]} array The packed array.
 * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
 * @param {Cartesian3} [result] The object into which to store the result.
 */
//+(CSBoundingSphere *)unpack:(void *)array startingIndex:(UInt32)startingIndex;

-(CSBoundingSphere *)union:(CSBoundingSphere *)other
{
    
}

-(CSBoundingSphere *)expand:(CSCartesian3 *)point
{
    NSAssert(point != nil, @"point is required");
    
    Float64 radius = [point subtract:self.center].magnitude;
    
    return [[CSBoundingSphere alloc] initWithCenter:self.center radius:MAX(self.radius, radius)];
}

-(CSBoundingSphere *)intersect:(CSCartesian4 *)plane
{
    
}

-(CSBoundingSphere *)transform:(CSMatrix4 *)transform
{
    
}

-(Float64)distanceSquaredTo:(CSCartesian3 *)point
{
    
}

-(CSBoundingSphere *)transformWithoutScale:(CSMatrix4 *)transform
{
    
}

-(CSInterval *)planeDistances:(CSCartesian3 *)position direction:(CSCartesian2 *)direction
{
    
}

-(CSBoundingSphere *)projectTo2D:(CSProjection *)projection
{
    
}

-(BOOL)equals:(CSBoundingSphere *)other
{
    return ([self.center equals:other.center] &&
            self.radius == other.radius;
}


/**
 * Duplicates a BoundingSphere instance.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to duplicate.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided. (Returns undefined if sphere is undefined)
 */
BoundingSphere.clone = function(sphere, result) {
    if (!defined(sphere)) {
        return undefined;
    }
    
    if (!defined(result)) {
        return new BoundingSphere(sphere.center, sphere.radius);
    }
    
    result.center = Cartesian3.clone(sphere.center, result.center);
    result.radius = sphere.radius;
    return result;
};

var unionScratch = new Cartesian3();
var unionScratchCenter = new Cartesian3();
/**
 * Computes a bounding sphere that contains both the left and right bounding spheres.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} left A sphere to enclose in a bounding sphere.
 * @param {BoundingSphere} right A sphere to enclose in a bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
BoundingSphere.union = function(left, right, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(left)) {
        throw new DeveloperError('left is required.');
    }
    
    if (!defined(right)) {
        throw new DeveloperError('right is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    var leftCenter = left.center;
    var rightCenter = right.center;
    
    Cartesian3.add(leftCenter, rightCenter, unionScratchCenter);
    var center = Cartesian3.multiplyByScalar(unionScratchCenter, 0.5, unionScratchCenter);
    
    var radius1 = Cartesian3.magnitude(Cartesian3.subtract(leftCenter, center, unionScratch)) + left.radius;
    var radius2 = Cartesian3.magnitude(Cartesian3.subtract(rightCenter, center, unionScratch)) + right.radius;
    
    result.radius = Math.max(radius1, radius2);
    Cartesian3.clone(center, result.center);
    
    return result;
};

/**
 * Determines which side of a plane a sphere is located.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to test.
 * @param {Cartesian4} plane The coefficients of the plane in the for ax + by + cz + d = 0
 *                           where the coefficients a, b, c, and d are the components x, y, z,
 *                           and w of the {@link Cartesian4}, respectively.
 * @returns {Intersect} {@link Intersect.INSIDE} if the entire sphere is on the side of the plane
 *                      the normal is pointing, {@link Intersect.OUTSIDE} if the entire sphere is
 *                      on the opposite side, and {@link Intersect.INTERSECTING} if the sphere
 *                      intersects the plane.
 */
BoundingSphere.intersect = function(sphere, plane) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(plane)) {
        throw new DeveloperError('plane is required.');
    }
    //>>includeEnd('debug');
    
    var center = sphere.center;
    var radius = sphere.radius;
    var distanceToPlane = Cartesian3.dot(plane, center) + plane.w;
    
    if (distanceToPlane < -radius) {
        // The center point is negative side of the plane normal
        return Intersect.OUTSIDE;
    } else if (distanceToPlane < radius) {
        // The center point is positive side of the plane, but radius extends beyond it; partial overlap
        return Intersect.INTERSECTING;
    }
    return Intersect.INSIDE;
};

/**
 * Applies a 4x4 affine transformation matrix to a bounding sphere.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to apply the transformation to.
 * @param {Matrix4} transform The transformation matrix to apply to the bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
BoundingSphere.transform = function(sphere, transform, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(transform)) {
        throw new DeveloperError('transform is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    result.center = Matrix4.multiplyByPoint(transform, sphere.center, result.center);
    result.radius = Matrix4.getMaximumScale(transform) * sphere.radius;
    
    return result;
};

var distanceSquaredToScratch = new Cartesian3();

/**
 * Computes the estimated distance squared from the closest point on a bounding sphere to a point.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The sphere.
 * @param {Cartesian3} cartesian The point
 * @returns {Number} The estimated distance squared from the bounding sphere to the point.
 *
 * @example
 * // Sort bounding spheres from back to front
 * spheres.sort(function(a, b) {
 *     return BoundingSphere.distanceSquaredTo(b, camera.positionWC) - BoundingSphere.distanceSquaredTo(a, camera.positionWC);
 * });
 */
BoundingSphere.distanceSquaredTo = function(sphere, cartesian) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    if (!defined(cartesian)) {
        throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    var diff = Cartesian3.subtract(sphere.center, cartesian, distanceSquaredToScratch);
    return Cartesian3.magnitudeSquared(diff) - sphere.radius * sphere.radius;
};

/**
 * Applies a 4x4 affine transformation matrix to a bounding sphere where there is no scale
 * The transformation matrix is not verified to have a uniform scale of 1.
 * This method is faster than computing the general bounding sphere transform using {@link BoundingSphere.transform}.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to apply the transformation to.
 * @param {Matrix4} transform The transformation matrix to apply to the bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 *
 * @example
 * var modelMatrix = Cesium.Transforms.eastNorthUpToFixedFrame(positionOnEllipsoid);
 * var boundingSphere = new Cesium.BoundingSphere();
 * var newBoundingSphere = Cesium.BoundingSphere.transformWithoutScale(boundingSphere, modelMatrix);
 */
BoundingSphere.transformWithoutScale = function(sphere, transform, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(transform)) {
        throw new DeveloperError('transform is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    result.center = Matrix4.multiplyByPoint(transform, sphere.center, result.center);
    result.radius = sphere.radius;
    
    return result;
};

var scratchCartesian3 = new Cartesian3();
/**
 * The distances calculated by the vector from the center of the bounding sphere to position projected onto direction
 * plus/minus the radius of the bounding sphere.
 * <br>
 * If you imagine the infinite number of planes with normal direction, this computes the smallest distance to the
 * closest and farthest planes from position that intersect the bounding sphere.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to calculate the distance to.
 * @param {Cartesian3} position The position to calculate the distance from.
 * @param {Cartesian3} direction The direction from position.
 * @param {Cartesian2} [result] A Cartesian2 to store the nearest and farthest distances.
 * @returns {Interval} The nearest and farthest distances on the bounding sphere from position in direction.
 */
BoundingSphere.getPlaneDistances = function(sphere, position, direction, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(position)) {
        throw new DeveloperError('position is required.');
    }
    
    if (!defined(direction)) {
        throw new DeveloperError('direction is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new Interval();
    }
    
    var toCenter = Cartesian3.subtract(sphere.center, position, scratchCartesian3);
    var proj = Cartesian3.multiplyByScalar(direction, Cartesian3.dot(direction, toCenter), scratchCartesian3);
    var mag = Cartesian3.magnitude(proj);
    
    result.start = mag - sphere.radius;
    result.stop = mag + sphere.radius;
    return result;
};

var projectTo2DNormalScratch = new Cartesian3();
var projectTo2DEastScratch = new Cartesian3();
var projectTo2DNorthScratch = new Cartesian3();
var projectTo2DWestScratch = new Cartesian3();
var projectTo2DSouthScratch = new Cartesian3();
var projectTo2DCartographicScratch = new Cartographic();
var projectTo2DPositionsScratch = new Array(8);
for (var n = 0; n < 8; ++n) {
    projectTo2DPositionsScratch[n] = new Cartesian3();
}
var projectTo2DProjection = new GeographicProjection();
/**
 * Creates a bounding sphere in 2D from a bounding sphere in 3D world coordinates.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to transform to 2D.
 * @param {Object} [projection=GeographicProjection] The projection to 2D.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
BoundingSphere.projectTo2D = function(sphere, projection, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    //>>includeEnd('debug');
    
    projection = defaultValue(projection, projectTo2DProjection);
    
    var ellipsoid = projection.ellipsoid;
    var center = sphere.center;
    var radius = sphere.radius;
    
    var normal = ellipsoid.geodeticSurfaceNormal(center, projectTo2DNormalScratch);
    var east = Cartesian3.cross(Cartesian3.UNIT_Z, normal, projectTo2DEastScratch);
    Cartesian3.normalize(east, east);
    var north = Cartesian3.cross(normal, east, projectTo2DNorthScratch);
    Cartesian3.normalize(north, north);
    
    Cartesian3.multiplyByScalar(normal, radius, normal);
    Cartesian3.multiplyByScalar(north, radius, north);
    Cartesian3.multiplyByScalar(east, radius, east);
    
    var south = Cartesian3.negate(north, projectTo2DSouthScratch);
    var west = Cartesian3.negate(east, projectTo2DWestScratch);
    
    var positions = projectTo2DPositionsScratch;
    
    // top NE corner
    var corner = positions[0];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, east, corner);
    
    // top NW corner
    corner = positions[1];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, west, corner);
    
    // top SW corner
    corner = positions[2];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, west, corner);
    
    // top SE corner
    corner = positions[3];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, east, corner);
    
    Cartesian3.negate(normal, normal);
    
    // bottom NE corner
    corner = positions[4];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, east, corner);
    
    // bottom NW corner
    corner = positions[5];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, west, corner);
    
    // bottom SW corner
    corner = positions[6];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, west, corner);
    
    // bottom SE corner
    corner = positions[7];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, east, corner);
    
    var length = positions.length;
    for (var i = 0; i < length; ++i) {
        var position = positions[i];
        Cartesian3.add(center, position, position);
        var cartographic = ellipsoid.cartesianToCartographic(position, projectTo2DCartographicScratch);
        projection.project(cartographic, position);
    }
    
    result = BoundingSphere.fromPoints(positions, result);
    
    // swizzle center components
    center = result.center;
    var x = center.x;
    var y = center.y;
    var z = center.z;
    center.x = z;
    center.y = x;
    center.z = y;
    
    return result;
};

/**
 * Compares the provided BoundingSphere componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} [left] The first BoundingSphere.
 * @param {BoundingSphere} [right] The second BoundingSphere.
 * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
 */
BoundingSphere.equals = function(left, right) {
    return (left === right) ||
    ((defined(left)) &&
     (defined(right)) &&
     Cartesian3.equals(left.center, right.center) &&
     left.radius === right.radius);
};

/**
 * Determines which side of a plane the sphere is located.
 * @memberof BoundingSphere
 *
 * @param {Cartesian4} plane The coefficients of the plane in the for ax + by + cz + d = 0
 *                           where the coefficients a, b, c, and d are the components x, y, z,
 *                           and w of the {@link Cartesian4}, respectively.
 * @returns {Intersect} {@link Intersect.INSIDE} if the entire sphere is on the side of the plane
 *                      the normal is pointing, {@link Intersect.OUTSIDE} if the entire sphere is
 *                      on the opposite side, and {@link Intersect.INTERSECTING} if the sphere
 *                      intersects the plane.
 */
BoundingSphere.prototype.intersect = function(plane) {
    return BoundingSphere.intersect(this, plane);
};

/**
 * Compares this BoundingSphere against the provided BoundingSphere componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} [right] The right hand side BoundingSphere.
 * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
 */
BoundingSphere.prototype.equals = function(right) {
    return BoundingSphere.equals(this, right);
};

/**
 * Duplicates this BoundingSphere instance.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
-(instancetype)copyWithZone:(NSZone *)zone
{
    
}


@end
