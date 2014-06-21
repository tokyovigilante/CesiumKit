//
//  Geometry.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

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
* @param {PrimitiveType} options.primitiveType The type of primitives in the geometry.
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

struct Geometry {

    var geometryAttributes: VertexAttribute[]
    
    var primitiveType: PrimitiveType
    
    var indices
    
    var BoundingSphere: BoundingSphere? = nil
    
        var Geometry = function(options) {
    options = defaultValue(options, defaultValue.EMPTY_OBJECT);
    
    //>>includeStart('debug', pragmas.debug);
    if (!defined(options.attributes)) {
    throw new DeveloperError('options.attributes is required.');
}
if (!defined(options.primitiveType)) {
    throw new DeveloperError('options.primitiveType is required.');
}
//>>includeEnd('debug');

this.attributes = options.attributes;

/**
* Optional index data that - along with {@link Geometry#primitiveType} -
* determines the primitives in the geometry.
*
* @type Array
*
* @default undefined
*/
this.indices = options.indices;

/**
* The type of primitives in the geometry.  This is most often {@link PrimitiveType.TRIANGLES},
* but can varying based on the specific geometry.
*
* @type PrimitiveType
*
* @default undefined
*/
this.primitiveType = options.primitiveType;

/**
* An optional bounding sphere that fully encloses the geometry.  This is
* commonly used for culling.
*
* @type BoundingSphere
*
* @default undefined
*/
this.boundingSphere = options.boundingSphere;
};

/**
* Computes the number of vertices in a geometry.  The runtime is linear with
* respect to the number of attributes in a vertex, not the number of vertices.
*
* @param {Cartesian3} geometry The geometry.
* @returns {Number} The number of vertices in the geometry.
*
* @example
* var numVertices = Cesium.Geometry.computeNumberOfVertices(geometry);
*/
Geometry.computeNumberOfVertices = function(geometry) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(geometry)) {
        throw new DeveloperError('geometry is required.');
    }
    //>>includeEnd('debug');
    
    var numberOfVertices = -1;
    for ( var property in geometry.attributes) {
        if (geometry.attributes.hasOwnProperty(property) &&
            defined(geometry.attributes[property]) &&
            defined(geometry.attributes[property].values)) {
                
                var attribute = geometry.attributes[property];
                var num = attribute.values.length / attribute.componentsPerAttribute;
                if ((numberOfVertices !== num) && (numberOfVertices !== -1)) {
                    throw new DeveloperError('All attribute lists must have the same number of attributes.');
                }
                numberOfVertices = num;
        }
    }
    
    return numberOfVertices;
};

return Geometry;
});

}