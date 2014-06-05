//
//  CSBoundingSphere.h
//  CesiumKit
//
//  Created by Ryan Walklin on 24/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

@import Foundation;

#import "CSPackable.h"

@class CSCartesian2, CSCartesian3, CSCartesian4, CSProjection, CSEllipsoid, CSRectangle, CSMatrix4, CSInterval, CSFloat32Array;

/**
 * A bounding sphere with a center and a radius.
 * @alias BoundingSphere
 * @constructor
 *
 * @param {Cartesian3} [center=Cartesian3.ZERO] The center of the bounding sphere.
 * @param {Number} [radius=0.0] The radius of the bounding sphere.
 *
 * @see AxisAlignedBoundingBox
 * @see BoundingRectangle
 * @see Packable
 */
@interface CSBoundingSphere : CSPackable <NSCopying>

/**
 * The center point of the sphere.
 * @type {Cartesian3}
 * @default {@link Cartesian3.ZERO}
 */
@property (readonly) CSCartesian3 *center;

/**
 * The radius of the sphere.
 * @type {Number}
 * @default 0.0
 */
@property (readonly) Float64 radius;

-(instancetype)initWithCenter:(CSCartesian3 *)center radius:(Float64)radius;

/**
 * Computes a tight-fitting bounding sphere enclosing a list of 3D Cartesian points.
 * The bounding sphere is computed by running two algorithms, a naive algorithm and
 * Ritter's algorithm. The smaller of the two spheres is used to ensure a tight fit.
 * @memberof BoundingSphere
 *
 * @param {Cartesian3[]} positions An array of points that the bounding sphere will enclose.  Each point must have <code>x</code>, <code>y</code>, and <code>z</code> properties.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if one was not provided.
 *
 * @see {@link http://blogs.agi.com/insight3d/index.php/2008/02/04/a-bounding/|Bounding Sphere computation article}
 */
+(CSBoundingSphere *)sphereFromPoints:(NSArray *)points;

/**
 * Computes a bounding sphere from an rectangle projected in 2D.
 *
 * @memberof BoundingSphere
 *
 * @param {Rectangle} rectangle The rectangle around which to create a bounding sphere.
 * @param {Object} [projection=GeographicProjection] The projection used to project the rectangle into 2D.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
+(CSBoundingSphere *)sphereFromRectangle2D:(CSRectangle *)rectangle projection:(CSProjection *)projection;

/**
 * Computes a bounding sphere from an rectangle projected in 2D.  The bounding sphere accounts for the
 * object's minimum and maximum heights over the rectangle.
 *
 * @memberof BoundingSphere
 *
 * @param {Rectangle} rectangle The rectangle around which to create a bounding sphere.
 * @param {Object} [projection=GeographicProjection] The projection used to project the rectangle into 2D.
 * @param {Number} [minimumHeight=0.0] The minimum height over the rectangle.
 * @param {Number} [maximumHeight=0.0] The maximum height over the rectangle.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
+(CSBoundingSphere *)sphereFromRectangle2D:(CSRectangle *)rectangle minimumHeight:(Float64)minimumHeight maximumHeight:(Float64)maximumHeight projection:(CSProjection *)projection;


/**
 * Computes a bounding sphere from an rectangle in 3D. The bounding sphere is created using a subsample of points
 * on the ellipsoid and contained in the rectangle. It may not be accurate for all rectangles on all types of ellipsoids.
 * @memberof BoundingSphere
 *
 * @param {Rectangle} rectangle The valid rectangle used to create a bounding sphere.
 * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid used to determine positions of the rectangle.
 * @param {Number} [surfaceHeight=0.0] The height above the surface of the ellipsoid.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
+(CSBoundingSphere *)sphereFromRectangle3D:(CSRectangle *)rectangle ellipsoid:(CSEllipsoid *)ellipsoid surfaceHeight:(Float64)surfaceHeight;

/**
 * Computes a tight-fitting bounding sphere enclosing a list of 3D points, where the points are
 * stored in a flat array in X, Y, Z, order.  The bounding sphere is computed by running two
 * algorithms, a naive algorithm and Ritter's algorithm. The smaller of the two spheres is used to
 * ensure a tight fit.
 *
 * @memberof BoundingSphere
 *
 * @param {Cartesian3[]} positions An array of points that the bounding sphere will enclose.  Each point
 *        is formed from three elements in the array in the order X, Y, Z.
 * @param {Cartesian3} [center=Cartesian3.ZERO] The position to which the positions are relative, which need not be the
 *        origin of the coordinate system.  This is useful when the positions are to be used for
 *        relative-to-center (RTC) rendering.
 * @param {Number} [stride=3] The number of array elements per vertex.  It must be at least 3, but it may
 *        be higher.  Regardless of the value of this parameter, the X coordinate of the first position
 *        is at array index 0, the Y coordinate is at array index 1, and the Z coordinate is at array index
 *        2.  When stride is 3, the X coordinate of the next position then begins at array index 3.  If
 *        the stride is 5, however, two array elements are skipped and the next position begins at array
 *        index 5.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if one was not provided.
 *
 * @see {@link http://blogs.agi.com/insight3d/index.php/2008/02/04/a-bounding/|Bounding Sphere computation article}
 *
 * @example
 * // Compute the bounding sphere from 3 positions, each specified relative to a center.
 * // In addition to the X, Y, and Z coordinates, the points array contains two additional
 * // elements per point which are ignored for the purpose of computing the bounding sphere.
 * var center = new Cesium.Cartesian3(1.0, 2.0, 3.0);
 * var points = [1.0, 2.0, 3.0, 0.1, 0.2,
 *               4.0, 5.0, 6.0, 0.1, 0.2,
 *               7.0, 8.0, 9.0, 0.1, 0.2];
 * var sphere = Cesium.BoundingSphere.fromVertices(points, center, 5);
 */
+(CSBoundingSphere *)sphereFromVertices:(CSFloat32Array *)vertices center:(CSCartesian3 *)center stride:(UInt32)stride;
/**
 * Computes a bounding sphere from the corner points of an axis-aligned bounding box.  The sphere
 * tighly and fully encompases the box.
 *
 * @memberof BoundingSphere
 *
 * @param {Number} [corner] The minimum height over the rectangle.
 * @param {Number} [oppositeCorner] The maximum height over the rectangle.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 *
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 *
 * @example
 * // Create a bounding sphere around the unit cube
 * var sphere = Cesium.BoundingSphere.fromCornerPoints(new Cesium.Cartesian3(-0.5, -0.5, -0.5), new Cesium.Cartesian3(0.5, 0.5, 0.5));
 */
+(CSBoundingSphere *)sphereFromCornerPoint:(CSCartesian3 *)corner oppositeCorner:(CSCartesian3 *)oppositeCorner;

/**
 * Creates a bounding sphere encompassing an ellipsoid.
 *
 * @memberof BoundingSphere
 *
 * @param {Ellipsoid} ellipsoid The ellipsoid around which to create a bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 *
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 *
 * @example
 * var boundingSphere = Cesium.BoundingSphere.fromEllipsoid(ellipsoid);
 */
+(CSBoundingSphere *)sphereFromEllipsoid:(CSEllipsoid *)ellipsoid;

/**
 * Computes a bounding sphere that contains both the left and right bounding spheres.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} left A sphere to enclose in a bounding sphere.
 * @param {BoundingSphere} right A sphere to enclose in a bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
-(CSBoundingSphere *)union:(CSBoundingSphere *)other;

/**
 * Computes a bounding sphere by enlarging the provided sphere to contain the provided point.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere A sphere to expand.
 * @param {Cartesian3} point A point to enclose in a bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
-(CSBoundingSphere *)expand:(CSBoundingSphere *)sphere point:(CSCartesian3 *)point;

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
-(CSBoundingSphere *)intersect:(CSCartesian4 *)plane;

/**
 * Applies a 4x4 affine transformation matrix to a bounding sphere.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to apply the transformation to.
 * @param {Matrix4} transform The transformation matrix to apply to the bounding sphere.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
-(CSBoundingSphere *)transform:(CSMatrix4 *)transform;

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
-(Float64)distanceSquaredTo:(CSCartesian3 *)point;

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
-(CSBoundingSphere *)transformWithoutScale:(CSMatrix4 *)transform;

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
-(CSInterval *)planeDistances:(CSCartesian3 *)position direction:(CSCartesian2 *)direction;

/**
 * Creates a bounding sphere in 2D from a bounding sphere in 3D world coordinates.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} sphere The bounding sphere to transform to 2D.
 * @param {Object} [projection=GeographicProjection] The projection to 2D.
 * @param {BoundingSphere} [result] The object onto which to store the result.
 * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
 */
-(CSBoundingSphere *)projectTo2D:(CSProjection *)projection;

/**
 * Compares the provided BoundingSphere componentwise and returns
 * <code>true</code> if they are equal, <code>false</code> otherwise.
 * @memberof BoundingSphere
 *
 * @param {BoundingSphere} [left] The first BoundingSphere.
 * @param {BoundingSphere} [right] The second BoundingSphere.
 * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
 */
-(BOOL)equals:(CSBoundingSphere *)other;

@end
