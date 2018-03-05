//
//  Geometry.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* A geometry representation with attributes forming vertices and optional index data
* defining primitives.  Geometries and an {@link Appearance}, which describes the shading,
* can be assigned to a {@link Primitive} for visualization.  A <code>Primitive</code> can
* be created from many heterogeneous - in many cases - geometries for performance.
* <p>
* Geometries can be transformed and optimized using functions in {@link GeometryPipeline}.
* </p>
*
* @alias Geometry
* @constructor
*
* @param {Object} options Object with the following properties:
* @param {GeometryAttributes} options.attributes Attributes, which make up the geometry's vertices.
* @param {PrimitiveType} [options.primitiveType=PrimitiveType.TRIANGLES] The type of primitives in the geometry.
* @param {Uint16Array|Uint32Array} [options.indices] Optional index data that determines the primitives in the geometry.
* @param {BoundingSphere} [options.boundingSphere] An optional bounding sphere that fully enclosed the geometry.
*
* @see PolygonGeometry
* @see RectangleGeometry
* @see EllipseGeometry
* @see CircleGeometry
* @see WallGeometry
* @see SimplePolylineGeometry
* @see BoxGeometry
* @see EllipsoidGeometry
*
* @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Geometry%20and%20Appearances.html|Geometry and Appearances Demo}
*
* @example
* // Create geometry with a position attribute and indexed lines.
* var positions = new Float64Array([
*   0.0, 0.0, 0.0,
*   7500000.0, 0.0, 0.0,
*   0.0, 7500000.0, 0.0
* ]);
*
* var geometry = new Cesium.Geometry({
*   attributes : {
*     position : new Cesium.GeometryAttribute({
*       componentDatatype : Cesium.ComponentDatatype.DOUBLE,
*       componentsPerAttribute : 3,
*       values : positions
*     })
*   },
*   indices : new Uint16Array([0, 1, 1, 2, 2, 0]),
*   primitiveType : Cesium.PrimitiveType.LINES,
*   boundingSphere : Cesium.BoundingSphere.fromVertices(positions)
* });
*/
class Geometry {

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
    *   values : new Float32Array(0)
    * });
    */
    let attributes: GeometryAttributes

    /**
    * Optional index data that - along with {@link Geometry#primitiveType} -
    * determines the primitives in the geometry.
    *
    * @type Array
    *
    * @default undefined
    */
    let indices: [Int]?

    /**
    * The type of primitives in the geometry.  This is most often {@link PrimitiveType.TRIANGLES},
    * but can varying based on the specific geometry.
    *
    * @type PrimitiveType
    *
    * @default undefined
    */
    let primitiveType: MTLPrimitiveType

    /**
    * An optional bounding sphere that fully encloses the geometry.  This is
    * commonly used for culling.
    *
    * @type BoundingSphere
    *
    * @default undefined
    */
    let boundingSphere: BoundingSphere?

    /**
    * @private
    */
    let geometryType: GeometryType

    /**
    * @private
    */
    var boundingSphereCV: BoundingSphere? = nil

    // FIXME: primitiveType vs geometryType
    init(attributes: GeometryAttributes, indices: [Int]? = nil, primitiveType: MTLPrimitiveType = .triangle, boundingSphere: BoundingSphere? = nil, geometryType: GeometryType = GeometryType.none) {
        self.attributes = attributes
        self.indices = indices
        self.primitiveType = primitiveType
        self.boundingSphere = boundingSphere
        self.geometryType = geometryType
    }

    /**
    * Computes the number of vertices in a geometry.  The runtime is linear with
    * respect to the number of attributes in a vertex, not the number of vertices.
    *
    * @param {Geometry} geometry The geometry.
    * @returns {Number} The number of vertices in the geometry.
    *
    * @example
    * var numVertices = Cesium.Geometry.computeNumberOfVertices(geometry);
    */
    func computeNumberOfVertices() -> Int {
        let numberOfVertices = -1

        //for i in 0...5 {
            /*if let attributeComponentCount = attributes[i]?.values?.count, componentsPerAttribute = attributes[i]?.componentsPerAttribute {
                let num = attributeComponentCount / componentsPerAttribute
                assert(numberOfVertices == num || numberOfVertices == -1, "All attribute lists must have the same number of attributes")
                numberOfVertices = num
            }*/
        //}
        return numberOfVertices
    }

}
