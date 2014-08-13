//
//  CSEllipsoidGeometry.h
//  CesiumKit
//
//  Created by Ryan Walklin on 22/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSGeometry;

@interface CSEllipsoidGeometry : NSObject

/**
 * A description of an ellipsoid centered at the origin.
 *
 * @alias EllipsoidGeometry
 * @constructor
 *
 * @param {Cartesian3} [options.radii=Cartesian3(1.0, 1.0, 1.0)] The radii of the ellipsoid in the x, y, and z directions.
 * @param {Number} [options.stackPartitions=64] The number of times to partition the ellipsoid into stacks.
 * @param {Number} [options.slicePartitions=64] The number of times to partition the ellipsoid into radial slices.
 * @param {VertexFormat} [options.vertexFormat=VertexFormat.DEFAULT] The vertex attributes to be computed.
 *
 * @exception {DeveloperError} options.slicePartitions cannot be less than three.
 * @exception {DeveloperError} options.stackPartitions cannot be less than three.
 *
 * @see EllipsoidGeometry#createGeometry
 *
 * @example
 * var ellipsoid = new Cesium.EllipsoidGeometry({
 *   vertexFormat : Cesium.VertexFormat.POSITION_ONLY,
 *   radii : new Cesium.Cartesian3(1000000.0, 500000.0, 500000.0)
 * });
 * var geometry = Cesium.EllipsoidGeometry.createGeometry(ellipsoid);
 */

@property (readonly) NSDictionary *options;

-(instancetype)initWithOptions:(NSDictionary *)options;
/**
 * Computes the geometric representation of an ellipsoid, including its vertices, indices, and a bounding sphere.
 * @memberof EllipsoidGeometry
 *
 * @param {EllipsoidGeometry} ellipsoidGeometry A description of the ellipsoid.
 * @returns {Geometry} The computed vertices and indices.
 */
-(CSGeometry *)createGeometry;

@end
