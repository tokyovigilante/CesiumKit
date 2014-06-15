//
//  VertexFormat.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A vertex format defines what attributes make up a vertex.  A VertexFormat can be provided
* to a {@link Geometry} to request that certain properties be computed, e.g., just position,
* position and normal, etc.
*
* @param {Object} [options] An object with boolean properties corresponding to VertexFormat properties as shown in the code example.
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
struct VertexFormat {
    
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
    let position: Bool = false
    
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
    let normal: Bool = false
    
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
    let st: Bool = false
    
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
    let binormal: Bool = false
    
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
    let tangent: Bool = false
    
    
    /**
    * An immutable vertex format with only a position attribute.
    *
    * @memberof VertexFormat
    *
    * @see VertexFormat#position
    */
    static func PositionOnly() -> VertexFormat {
        return VertexFormat(position: true, normal: false, st: false, binormal: false, tangent: false)
    }
    
    /**
    * An immutable vertex format with position and normal attributes.
    * This is compatible with per-instance color appearances like {@link PerInstanceColorAppearance}.
    *
    * @memberof VertexFormat
    *
    * @see VertexFormat#position
    * @see VertexFormat#normal
    */
    static func PositionAndNormal() -> VertexFormat {
        return VertexFormat(position: true, normal: true, st: false, binormal: false, tangent: false)
    }
    
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
    static func PositionNormalAndST() -> VertexFormat {
        return VertexFormat(position: true, normal: true, st: true, binormal: false, tangent: false)
    }
    
    /**
    * An immutable vertex format with position and st attributes.
    * This is compatible with {@link EllipsoidSurfaceAppearance}.
    *
    * @memberof VertexFormat
    *
    * @see VertexFormat#position
    * @see VertexFormat#st
    */
    static func PositionAndST() -> VertexFormat {
        return VertexFormat(position: true, normal: false, st: true, binormal: false, tangent: false)
    }
    
    
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
    static func All() -> VertexFormat {
        return VertexFormat(position: true, normal: true, st: true, binormal: true, tangent: true)
    }
    
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
    static func Default() -> VertexFormat {
        return VertexFormat.PositionNormalAndST()
    }
    
}
