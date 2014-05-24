//
//  CSVertexFormat.h
//  CesiumKit
//
//  Created by Ryan Walklin on 22/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

/**
 * A vertex format defines what attributes make up a vertex.  A VertexFormat can be provided
 * to a {@link Geometry} to request that certain properties be computed, e.g., just position,
 * position and normal, etc.
 *
 * @param {Object} [options=undefined] An object with boolean properties corresponding to VertexFormat properties as shown in the code example.
 *
 * @alias VertexFormat
 * @constructor
 *
 * @example
 * // Create a vertex format with position and 2D texture coordinate attributes.
 * var format = new Cesium.VertexFormat({
 *   position : true,
 *   st : true
 * });
 *
 * @see Geometry#attributes
 */
@interface CSVertexFormat : NSObject

/**
 * When <code>true</code>, the vertex has a 3D position attribute.
 * <p>
 * 64-bit floating-point (for precision).  3 components per attribute.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property (readonly) BOOL position;

/**
 * When <code>true</code>, the vertex has a normal attribute (normalized), which is commonly used for lighting.
 * <p>
 * 32-bit floating-point.  3 components per attribute.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property (readonly) BOOL normal;

/**
 * When <code>true</code>, the vertex has a 2D texture coordinate attribute.
 * <p>
 * 32-bit floating-point.  2 components per attribute
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property (readonly) BOOL st;

/**
 * When <code>true</code>, the vertex has a binormal attribute (normalized), which is used for tangent-space effects like bump mapping.
 * <p>
 * 32-bit floating-point.  3 components per attribute.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property (readonly) BOOL binormal;

/**
 * When <code>true</code>, the vertex has a tangent attribute (normalized), which is used for tangent-space effects like bump mapping.
 * <p>
 * 32-bit floating-point.  3 components per attribute.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property (readonly) BOOL tangent;

-(instancetype)initWithOptions:(NSDictionary *)options;

/**
 * An immutable vertex format with only a position attribute.
 *
 * @memberof VertexFormat
 *
 * @see VertexFormat#position
 */
+(CSVertexFormat *)positionOnly;

/**
 * An immutable vertex format with position and normal attributes.
 * This is compatible with per-instance color appearances like {@link PerInstanceColorAppearance}.
 *
 * @memberof VertexFormat
 *
 * @see VertexFormat#position
 * @see VertexFormat#normal
 */
+(CSVertexFormat *)positionAndNormal;

/**
 * An immutable vertex format with position, normal, and st attributes.
 * This is compatible with {@link MaterialAppearance} when {@link MaterialAppearance#materialSupport}
 * is <code>TEXTURED/code>.
 *
 * @memberof VertexFormat
 *
 * @see VertexFormat#position
 * @see VertexFormat#normal
 * @see VertexFormat#st
 */
+(CSVertexFormat *)positionNormalAndST;

/**
 * An immutable vertex format with position and st attributes.
 * This is compatible with {@link EllipsoidSurfaceAppearance}.
 *
 * @memberof VertexFormat
 *
 * @see VertexFormat#position
 * @see VertexFormat#st
 */
+(CSVertexFormat *)positionAndST;

/**
 * An immutable vertex format with all well-known attributes: position, normal, st, binormal, and tangent.
 *
 * @memberof VertexFormat
 *
 * @see VertexFormat#position
 * @see VertexFormat#normal
 * @see VertexFormat#st
 * @see VertexFormat#binormal
 * @see VertexFormat#tangent
 */
+(CSVertexFormat *)all;


/**
 * An immutable vertex format with position, normal, and st attributes.
 * This is compatible with most appearances and materials; however
 * normal and st attributes are not always required.  When this is
 * known in advance, another <code>VertexFormat</code> should be used.
 *
 * @memberof VertexFormat
 *
 * @see VertexFormat#position
 * @see VertexFormat#normal
 */
+(CSVertexFormat *)default;

@end


