//
//  GeometryAttribute.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Attributes, which make up the geometry's vertices.  Each property in this object corresponds to a
* {@link GeometryAttribute} containing the attribute's data.
* <p>
* Attributes are always stored non-interleaved in a Geometry.
* </p>
* <p>
* There are reserved attribute names with well-known semantics.  The following attributes
* are created by a Geometry (depending on the provided {@link VertexFormat}.
* <ul>
*    <li><code>position</code> - 3D vertex position.  64-bit floating-point (for precision).  3 components per attribute.  See {@link VertexFormat#position}.</li>
*    <li><code>normal</code> - Normal (normalized), commonly used for lighting.  32-bit floating-point.  3 components per attribute.  See {@link VertexFormat#normal}.</li>
*    <li><code>st</code> - 2D texture coordinate.  32-bit floating-point.  2 components per attribute.  See {@link VertexFormat#st}.</li>
*    <li><code>binormal</code> - Binormal (normalized), used for tangent-space effects like bump mapping.  32-bit floating-point.  3 components per attribute.  See {@link VertexFormat#binormal}.</li>
*    <li><code>tangent</code> - Tangent (normalized), used for tangent-space effects like bump mapping.  32-bit floating-point.  3 components per attribute.  See {@link VertexFormat#tangent}.</li>
* </ul>
* </p>
* <p>
* The following attribute names are generally not created by a Geometry, but are added
* to a Geometry by a {@link Primitive} or {@link GeometryPipeline} functions to prepare
* the geometry for rendering.
* <ul>
*    <li><code>position3DHigh</code> - High 32 bits for encoded 64-bit position computed with {@link GeometryPipeline.encodeAttribute}.  32-bit floating-point.  4 components per attribute.</li>
*    <li><code>position3DLow</code> - Low 32 bits for encoded 64-bit position computed with {@link GeometryPipeline.encodeAttribute}.  32-bit floating-point.  4 components per attribute.</li>
*    <li><code>position3DHigh</code> - High 32 bits for encoded 64-bit 2D (Columbus view) position computed with {@link GeometryPipeline.encodeAttribute}.  32-bit floating-point.  4 components per attribute.</li>
*    <li><code>position2DLow</code> - Low 32 bits for encoded 64-bit 2D (Columbus view) position computed with {@link GeometryPipeline.encodeAttribute}.  32-bit floating-point.  4 components per attribute.</li>
*    <li><code>color</code> - RGBA color (normalized) usually from {@link GeometryInstance#color}.  32-bit floating-point.  4 components per attribute.</li>
*    <li><code>pickColor</code> - RGBA color used for picking.  32-bit floating-point.  4 components per attribute.</li>
* </ul>
* </p>
*
* @type GeometryAttributes
*
* @default undefined
*
* @see GeometryAttribute
* @see VertexFormat
*
* @example
* geometry.attributes.position = new Cesium.GeometryAttribute({
*   componentDatatype : Cesium.ComponentDatatype.FLOAT,
*   componentsPerAttribute : 3,
*   values : new Float32Array()
* });
*/
struct GeometryAttribute {
    
}