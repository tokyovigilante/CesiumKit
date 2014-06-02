//
//  CSEllipsoidalOccluder.h
//  CesiumKit
//
//  Created by Ryan on 3/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

@import Foundation;

@class CSEllipsoid, CSCartesian3, CSFloat32Array, CSRectangle;

/**
 * Determine whether or not other objects are visible or hidden behind the visible horizon defined by
 * an {@link Ellipsoid} and a camera position.  The ellipsoid is assumed to be located at the
 * origin of the coordinate system.  This class uses the algorithm described in the
 * {@link http://cesiumjs.org/2013/04/25/Horizon-culling/|Horizon Culling} blog post.
 *
 * @alias EllipsoidalOccluder
 *
 * @param {Ellipsoid} ellipsoid The ellipsoid to use as an occluder.
 * @param {Cartesian3} [cameraPosition] The coordinate of the viewer/camera.  If this parameter is not
 *        specified, {@link EllipsoidalOccluder#cameraPosition} must be called before
 *        testing visibility.
 *
 * @constructor
 *
 * @example
 * // Construct an ellipsoidal occluder with radii 1.0, 1.1, and 0.9.
 * var cameraPosition = new Cesium.Cartesian3(5.0, 6.0, 7.0);
 * var occluderEllipsoid = new Cesium.Ellipsoid(1.0, 1.1, 0.9);
 * var occluder = new Cesium.EllipsoidalOccluder(occluderEllipsoid, cameraPosition);
 */
@interface CSEllipsoidalOccluder : NSObject

@property (readonly) CSEllipsoid *ellipsoid;
@property (nonatomic) CSCartesian3 *cameraPosition;

-(instancetype)initWithEllipsoid:(CSEllipsoid)ellipsoid cameraPosition:(CSCartesian3 *)cameraPosition;

/**
 * Determines whether or not a point, the <code>occludee</code>, is hidden from view by the occluder.
 *
 * @memberof EllipsoidalOccluder
 *
 * @param {Cartesian3} occludee The point to test for visibility.
 *
 * @returns {Boolean} <code>true</code> if the occludee is visible; otherwise <code>false</code>.
 *
 * @example
 * var cameraPosition = new Cesium.Cartesian3(0, 0, 2.5);
 * var ellipsoid = new Cesium.Ellipsoid(1.0, 1.1, 0.9);
 * var occluder = new Cesium.EllipsoidalOccluder(ellipsoid, cameraPosition);
 * var point = new Cesium.Cartesian3(0, -3, -3);
 * occluder.isPointVisible(point); //returns true
 */
-(BOOL)isPointVisible:(CSCartesian3 *)occludee;

    
/**
 * Determines whether or not a point expressed in the ellipsoid scaled space, is hidden from view by the
 * occluder.  To transform a Cartesian X, Y, Z position in the coordinate system aligned with the ellipsoid
 * into the scaled space, call {@link Ellipsoid#transformPositionToScaledSpace}.
 *
 * @memberof EllipsoidalOccluder
 *
 * @param {Cartesian3} occludeeScaledSpacePosition The point to test for visibility, represented in the scaled space.
 *
 * @returns {Boolean} <code>true</code> if the occludee is visible; otherwise <code>false</code>.
 *
 * @example
 * var cameraPosition = new Cesium.Cartesian3(0, 0, 2.5);
 * var ellipsoid = new Cesium.Ellipsoid(1.0, 1.1, 0.9);
 * var occluder = new Cesium.EllipsoidalOccluder(ellipsoid, cameraPosition);
 * var point = new Cesium.Cartesian3(0, -3, -3);
 * var scaledSpacePoint = ellipsoid.transformPositionToScaledSpace(point);
 * occluder.isScaledSpacePointVisible(scaledSpacePoint); //returns true
 */
-(BOOL)isScaledSpacePointVisible:(CSCartesian3 *)occludeeScaledSpacePosition;

/**
 * Computes a point that can be used for horizon culling from a list of positions.  If the point is below
 * the horizon, all of the positions are guaranteed to be below the horizon as well.  The returned point
 * is expressed in the ellipsoid-scaled space and is suitable for use with
 * {@link EllipsoidalOccluder#isScaledSpacePointVisible}.
 *
 * @param {Cartesian3} directionToPoint The direction that the computed point will lie along.
 *                     A reasonable direction to use is the direction from the center of the ellipsoid to
 *                     the center of the bounding sphere computed from the positions.  The direction need not
 *                     be normalized.
 * @param {Cartesian3[]} positions The positions from which to compute the horizon culling point.  The positions
 *                       must be expressed in a reference frame centered at the ellipsoid and aligned with the
 *                       ellipsoid's axes.
 * @param {Cartesian3} [result] The instance on which to store the result instead of allocating a new instance.
 * @returns {Cartesian3} The computed horizon culling point, expressed in the ellipsoid-scaled space.
 */
-(CSCartesian3 *)computeHorizonCullingPoint:(CSCartesian3 *)directionToPoint positions:(NSArray *)positions;

/**
 * Computes a point that can be used for horizon culling from a list of positions.  If the point is below
 * the horizon, all of the positions are guaranteed to be below the horizon as well.  The returned point
 * is expressed in the ellipsoid-scaled space and is suitable for use with
 * {@link EllipsoidalOccluder#isScaledSpacePointVisible}.
 *
 * @param {Cartesian3} directionToPoint The direction that the computed point will lie along.
 *                     A reasonable direction to use is the direction from the center of the ellipsoid to
 *                     the center of the bounding sphere computed from the positions.  The direction need not
 *                     be normalized.
 * @param {Number[]} vertices  The vertices from which to compute the horizon culling point.  The positions
 *                   must be expressed in a reference frame centered at the ellipsoid and aligned with the
 *                   ellipsoid's axes.
 * @param {Number} [stride=3]
 * @param {Cartesian3} [center=Cartesian3.ZERO]
 * @param {Cartesian3} [result] The instance on which to store the result instead of allocating a new instance.
 * @returns {Cartesian3} The computed horizon culling point, expressed in the ellipsoid-scaled space.
 */
-(CSCartesian3 *)computeHorizonCullingPointFromVertices:(CSCartesian3 *)directionToPoint positions:(CSFloat32Array *)positions stride:(UInt32)stride center:(CSCartesian3 *)center;


/**
 * Computes a point that can be used for horizon culling of an rectangle.  If the point is below
 * the horizon, the ellipsoid-conforming rectangle is guaranteed to be below the horizon as well.
 * The returned point is expressed in the ellipsoid-scaled space and is suitable for use with
 * {@link EllipsoidalOccluder#isScaledSpacePointVisible}.
 *
 * @param {Rectangle} rectangle The rectangle for which to compute the horizon culling point.
 * @param {Ellipsoid} ellipsoid The ellipsoid on which the rectangle is defined.  This may be different from
 *                    the ellipsoid used by this instance for occlusion testing.
 * @param {Cartesian3} [result] The instance on which to store the result instead of allocating a new instance.
 * @returns {Cartesian3} The computed horizon culling point, expressed in the ellipsoid-scaled space.
 */
-(CSCartesian3 *)computeHorizonCullingPointFromRectangle:(CSRectangle *)rectangle ellipsoid:(CSEllipsoid *)ellipsoid;

@end
