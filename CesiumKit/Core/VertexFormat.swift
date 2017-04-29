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
* @see Packable*
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
    var position: Bool = false
    
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
    var normal: Bool = false
    
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
    var st: Bool = false
    
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
    var tangent: Bool = false
    
    /**
     * When <code>true</code>, the vertex has a bitangent attribute (normalized), which is used for tangent-space effects like bump mapping.
     * <p>
     * 32-bit floating-point.  3 components per attribute.
     * </p>
     *
     * @type Boolean
     *
     * @default false
     */
    var bitangent: Bool = false
    
    /**
    * When <code>true</code>, the vertex has an RGB color attribute.
    * <p>
    * 8bit unsigned byte.  3 components per attribute.
    * </p>
    *
    * @type Boolean
    *
    * @default false
    */
    var color: Bool = false
    
    /**
    * An immutable vertex format with only a position attribute.
    *
    * @memberof VertexFormat
    *
    * @see VertexFormat#position
    */
    static func PositionOnly() -> VertexFormat {
        return VertexFormat(position: true, normal: false, st: false, tangent: false, bitangent: false, color: false)
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
        return VertexFormat(position: true, normal: true, st: false, tangent: false, bitangent: false, color: false)
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
        return VertexFormat(position: true, normal: true, st: true, tangent: false, bitangent: false, color: false)
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
        return VertexFormat(position: true, normal: false, st: true, tangent: false, bitangent: false, color: false)
    }
    
    /**
    * An immutable vertex format with position and color attributes.
    *
    * @type {VertexFormat}
    * @constant
    *
    * @see VertexFormat#position
    * @see VertexFormat#color
    */
    static func PositionAndColor() -> VertexFormat {
        return VertexFormat(position: true, normal: false, st: false, tangent: false, bitangent: false, color: true)
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
        return VertexFormat(position: true, normal: true, st: true, tangent: true, bitangent: true, color: false)
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

extension VertexFormat: Packable {
    
    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    static func packedLength () -> Int {
        return 6
    }
    
    /**
     * Stores the provided instance into the provided array.
     * @function
     *
     * @param {Object} value The value to pack.
     * @param {Number[]} array The array to pack into.
     * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
     */
    func toArray() -> [Double] {
        return [
            position ? 1.0 : 0.0,
            normal ? 1.0 : 0.0,
            st ? 1.0 : 0.0,
            tangent ? 1.0 : 0.0,
            bitangent ? 1.0 : 0.0,
            color ? 1.0 : 0.0
        ]
    }
    
    init(array: [Double], startingIndex: Int) {
        assert(checkPackedArrayLength(array, startingIndex: startingIndex), "Invalid packed array length")
        position = array[startingIndex] == 1.0
        normal = array[startingIndex+1] == 1.0
        st = array[startingIndex+2] == 1.0
        tangent = array[startingIndex+3] == 1.0
        bitangent = array[startingIndex+4] == 1.0
        color = array[startingIndex+5] == 1.0
        
    }
}
