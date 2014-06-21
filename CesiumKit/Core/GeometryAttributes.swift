//
//  GeometryAttributes.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Attributes, which make up a geometry's vertices.  Each property in this object corresponds to a
* {@link GeometryAttribute} containing the attribute's data.
* <p>
* Attributes are always stored non-interleaved in a Geometry.
* </p>
*
* @alias GeometryAttributes
* @constructor
*/
struct GeometryAttributes  {
    
    /**
    * The 3D position attribute.
    * <p>
    * 64-bit floating-point (for precision).  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var position: GeometryAttribute? = nil
    
    /**
    * The normal attribute (normalized), which is commonly used for lighting.
    * <p>
    * 32-bit floating-point.  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var normal: GeometryAttribute? = nil
    
    /**
    * The 2D texture coordinate attribute.
    * <p>
    * 32-bit floating-point.  2 components per attribute
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var st: GeometryAttribute? = nil
    
    /**
    * The binormal attribute (normalized), which is used for tangent-space effects like bump mapping.
    * <p>
    * 32-bit floating-point.  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var binormal: GeometryAttribute? = nil
    
    /**
    * The tangent attribute (normalized), which is used for tangent-space effects like bump mapping.
    * <p>
    * 32-bit floating-point.  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var tangent: GeometryAttribute? = nil
    
    /**
    * The color attribute.
    * <p>
    * 8-bit unsigned integer. 4 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var color: GeometryAttribute? = nil
    
    func vertexCount() -> Int {
        var vertexCount = position.vertexCount
        vertexCount == normal.vertexCount ? vertexCount = normal.vertexCount : assert("unequal vertex count")
        vertexCount == st.vertexCount ? vertexCount = st.vertexCount : assert("unequal vertex count")
        vertexCount == binormal.vertexCount ? vertexCount = binormal.vertexCount : assert("unequal vertex count")
        vertexCount == tangent.vertexCount ? vertexCount = tangent.vertexCount : assert("unequal vertex count")
        vertexCount == color.vertexCount ? vertexCount = color.vertexCount : assert("unequal vertex count")
        return vertexCount
    }
}
