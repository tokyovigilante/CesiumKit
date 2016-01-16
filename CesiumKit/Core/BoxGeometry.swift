//
//  BoxGeometry.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Describes a cube centered at the origin.
 *
 * @alias BoxGeometry
 * @constructor
 *
 * @param {Object} options Object with the following properties:
 * @param {Cartesian3} options.minimum The minimum x, y, and z coordinates of the box.
 * @param {Cartesian3} options.maximum The maximum x, y, and z coordinates of the box.
 * @param {VertexFormat} [options.vertexFormat=VertexFormat.DEFAULT] The vertex attributes to be computed.
 *
 * @see BoxGeometry.fromDimensions
 * @see BoxGeometry.createGeometry
 * @see Packable
 *
 * @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Box.html|Cesium Sandcastle Box Demo}
 *
 * @example
 * var box = new Cesium.BoxGeometry({
 *   vertexFormat : Cesium.VertexFormat.POSITION_ONLY,
 *   maximum : new Cesium.Cartesian3(250000.0, 250000.0, 250000.0),
 *   minimum : new Cesium.Cartesian3(-250000.0, -250000.0, -250000.0)
 * });
 * var geometry = Cesium.BoxGeometry.createGeometry(box);
 */

struct BoxGeometry {
    
    private var _minimum: Cartesian3
    
    private var _maximum: Cartesian3
    
    private var _vertexFormat: VertexFormat
    
    init (minimum min: Cartesian3, maximum max: Cartesian3, vertexFormat vf: VertexFormat = .Default()) {
        _minimum = min
        _maximum = max
        _vertexFormat = vf
    }
    
    /**
     * Creates a cube centered at the origin given its dimensions.
     *
     * @param {Object} options Object with the following properties:
     * @param {Cartesian3} options.dimensions The width, depth, and height of the box stored in the x, y, and z coordinates of the <code>Cartesian3</code>, respectively.
     * @param {VertexFormat} [options.vertexFormat=VertexFormat.DEFAULT] The vertex attributes to be computed.
     * @returns {BoxGeometry}
     *
     * @exception {DeveloperError} All dimensions components must be greater than or equal to zero.
     *
     * @see BoxGeometry.createGeometry
     *
     * @example
     * var box = Cesium.BoxGeometry.fromDimensions({
     *   vertexFormat : Cesium.VertexFormat.POSITION_ONLY,
     *   dimensions : new Cesium.Cartesian3(500000.0, 500000.0, 500000.0)
     * });
     * var geometry = Cesium.BoxGeometry.createGeometry(box);
     */
    init (fromDimensions dimensions: Cartesian3, vertexFormat: VertexFormat = .Default()) {
        
        assert(dimensions.x >= 0.0 || dimensions.y >= 0.0 || dimensions.z >= 0.0, "All dimensions components must be greater than or equal to zero")
        
        let corner = dimensions.multiplyByScalar(0.5)
        
        self.init(
            minimum: corner.negate(),
            maximum: corner,
            vertexFormat: vertexFormat
        )
    }
    /*
    /**
    * Creates a cube from the dimensions of an AxisAlignedBoundingBox.
    *
    * @param {AxisAlignedBoundingBox} boundingBox A description of the AxisAlignedBoundingBox.
    * @returns {BoxGeometry}
    *
    * @exception {DeveloperError} AxisAlignedBoundingBox must be defined.
    *
    * @see BoxGeometry.createGeometry
    *
    * @example
    * var aabb = Cesium.AxisAlignedBoundingBox.fromPoints(Cesium.Cartesian3.fromDegreesArray([
    *      -72.0, 40.0,
    *      -70.0, 35.0,
    *      -75.0, 30.0,
    *      -70.0, 30.0,
    *      -68.0, 40.0
    * ]));
    * var box = Cesium.BoxGeometry.fromAxisAlignedBoundingBox({
    *      boundingBox: aabb
    * });
    */
    BoxGeometry.fromAxisAlignedBoundingBox = function (boundingBox) {
    if (!defined(boundingBox)) {
    throw new DeveloperError('boundingBox is required.');
    }
    
    return new BoxGeometry({
    minimum: boundingBox.minimum,
    maximum: boundingBox.maximum
    });
    };
    
    /**
    * Creates a cube from the dimensions of an AxisAlignedBoundingBox.
    *
    * @param {AxisAlignedBoundingBox} boundingBox A description of the AxisAlignedBoundingBox.
    * @returns {BoxGeometry}
    *
    * @exception {DeveloperError} AxisAlignedBoundingBox must be defined.
    *
    * @see BoxGeometry.createGeometry
    *
    * @example
    * var aabb = Cesium.AxisAlignedBoundingBox.fromPoints(Cesium.Cartesian3.fromDegreesArray([
    *      -72.0, 40.0,
    *      -70.0, 35.0,
    *      -75.0, 30.0,
    *      -70.0, 30.0,
    *      -68.0, 40.0
    * ]));
    * var box = Cesium.BoxGeometry.fromAxisAlignedBoundingBox({
    *      boundingBox: aabb
    * });
    */
    BoxGeometry.fromAxisAlignedBoundingBox = function (boundingBox) {
    if (!defined(boundingBox)) {
    throw new DeveloperError('boundingBox is required.');
    }
    
    return new BoxGeometry({
    minimum : boundingBox.minimum,
    maximum : boundingBox.maximum
    });
    };
    
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    BoxGeometry.packedLength = 2 * Cartesian3.packedLength + VertexFormat.packedLength;
    
    /**
    * Stores the provided instance into the provided array.
    * @function
    *
    * @param {BoxGeometry} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    BoxGeometry.pack = function(value, array, startingIndex) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(value)) {
    throw new DeveloperError('value is required');
    }
    if (!defined(array)) {
    throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    Cartesian3.pack(value._minimum, array, startingIndex);
    Cartesian3.pack(value._maximum, array, startingIndex + Cartesian3.packedLength);
    VertexFormat.pack(value._vertexFormat, array, startingIndex + 2 * Cartesian3.packedLength);
    };
    
    var scratchMin = new Cartesian3();
    var scratchMax = new Cartesian3();
    var scratchVertexFormat = new VertexFormat();
    var scratchOptions = {
    minimum: scratchMin,
    maximum: scratchMax,
    vertexFormat: scratchVertexFormat
    };
    
    /**
    * Retrieves an instance from a packed array.
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {BoxGeometry} [result] The object into which to store the result.
    * @returns {BoxGeometry} The modified result parameter or a new BoxGeometry instance if one was not provided.
    */
    BoxGeometry.unpack = function(array, startingIndex, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(array)) {
    throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    var min = Cartesian3.unpack(array, startingIndex, scratchMin);
    var max = Cartesian3.unpack(array, startingIndex + Cartesian3.packedLength, scratchMax);
    var vertexFormat = VertexFormat.unpack(array, startingIndex + 2 * Cartesian3.packedLength, scratchVertexFormat);
    
    if (!defined(result)) {
    return new BoxGeometry(scratchOptions);
    }
    
    result._minimum = Cartesian3.clone(min, result._minimum);
    result._maximum = Cartesian3.clone(max, result._maximum);
    result._vertexFormat = VertexFormat.clone(vertexFormat, result._vertexFormat);
    
    return result;
    };
    */
    /**
    * Computes the geometric representation of a box, including its vertices, indices, and a bounding sphere.
    *
    * @param {BoxGeometry} boxGeometry A description of the box.
    * @returns {Geometry} The computed vertices and indices.
    */
    func createGeometry (context: Context) -> Geometry {
        let min = _minimum
        let max = _maximum
        let vertexFormat = _vertexFormat
        
        let attributes = GeometryAttributes()
        let indices: [Int]
        let positions: [Double]
        
        if vertexFormat.position &&
            (vertexFormat.st || vertexFormat.normal || vertexFormat.binormal || vertexFormat.tangent) {
                if (vertexFormat.position) {
                    // 8 corner points.  Duplicated 3 times each for each incident edge/face.
                    
                    positions = [
                        min.x, min.y, max.z, max.x, min.y, max.z, max.x, max.y, max.z, min.x, max.y, max.z, // +z face
                        min.x, min.y, min.z, max.x, min.y, min.z, max.x, max.y, min.z, min.x, max.y, min.z, // -z face
                        max.x, min.y, min.z, max.x, max.y, min.z, max.x, max.y, max.z, max.x, min.y, max.z, // +x face
                        min.x, min.y, min.z, min.x, max.y, min.z, min.x, max.y, max.z, min.x, min.y, max.z, // -x face
                        min.x, max.y, min.z, max.x, max.y, min.z, max.x, max.y, max.z, min.x, max.y, max.z, // +y face
                        min.x, min.y, min.z, max.x, min.y, min.z, max.x, min.y, max.z, min.x, min.y, max.z // -y face
                    ]
                    
                    attributes.position = GeometryAttribute(
                        componentDatatype : ComponentDatatype.Float64,
                        componentsPerAttribute : 3,
                        values : Buffer(device: context.device, array: positions, componentDatatype: .Float64, sizeInBytes: positions.sizeInBytes)
                    )
                }
                
                if vertexFormat.normal {
                    let normals: [Float] = [
                        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, // +z face
                        0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, // -z face
                        1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, // +x face
                        -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, // -x face
                        0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, // +y face
                        0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0] // -y face
                    
                    attributes.normal = GeometryAttribute(
                        componentDatatype : .Float32,
                        componentsPerAttribute : 3,
                        values : Buffer(device: context.device, array: normals, componentDatatype: .Float32, sizeInBytes: normals.sizeInBytes)
                    )
                }
                
                if vertexFormat.st {
                    let texCoords: [Float] = [
                        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, // +z face
                        1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, // -z face
                        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, //+x face
                        1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, // -x face
                        1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, // +y face
                        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0 // -y face
                    ]
                    
                    attributes.st = GeometryAttribute(
                        componentDatatype : .Float32,
                        componentsPerAttribute : 2,
                        values : Buffer(device: context.device, array: texCoords, componentDatatype: .Float32, sizeInBytes: texCoords.sizeInBytes)
                    )
                }
                
                if vertexFormat.tangent {
                    let tangents: [Float] = [
                        1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, // +z face
                        -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, // -z face
                        0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, // +x face
                        0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, // -x face
                        -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, // +y face
                        1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0 // -y face
                    ]
                    attributes.tangent = GeometryAttribute(
                        componentDatatype : .Float32,
                        componentsPerAttribute : 3,
                        values : Buffer(device: context.device, array: tangents, componentDatatype: .Float32, sizeInBytes: tangents.sizeInBytes)
                    )
                }
                
                if vertexFormat.binormal {
                    let binormals: [Float] = [
                        0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, // +z face
                        0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, // -z face
                        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, // +x face
                        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, // -x face
                        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, // +y face
                        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0 // -y face
                    ]
                    
                    attributes.binormal = GeometryAttribute(
                        componentDatatype : .Float32,
                        componentsPerAttribute : 3,
                        values : Buffer(device: context.device, array: binormals, componentDatatype: .Float32, sizeInBytes: binormals.sizeInBytes)
                    )
                }
                
                // 12 triangles:  6 faces, 2 triangles each.
                indices = [
                    0, 1, 2, 0, 2, 3, // +z face
                    4 + 2, 4 + 1, 4 + 0, 4 + 3, 4 + 2, 4 + 0, // -z face
                    8 + 0, 8 + 1, 8 + 2, 8 + 0, 8 + 2, 8 + 3, // +x face,
                    12 + 2, 12 + 1, 12 + 0, 12 + 3, 12 + 2, 12 + 0, // -x face
                    16 + 2, 16 + 1, 16 + 0, 16 + 3, 16 + 2, 16 + 0, // +y face
                    20 + 0, 20 + 1, 20 + 2, 20 + 0, 20 + 2, 20 + 3 // -y face
                ]
        } else {
            // Positions only - no need to duplicate corner points
            positions = [
                min.x, min.y, min.z,
                max.x, min.y, min.z,
                max.x, max.y, min.z,
                min.x, max.y, min.z,
                min.x, min.y, max.z,
                max.x, min.y, max.z,
                max.x, max.y, max.z,
                min.x, max.y, max.z
            ]
            
            attributes.position = GeometryAttribute(
                componentDatatype : .Float64,
                componentsPerAttribute : 3,
                values : Buffer(device: context.device, array: positions, componentDatatype: .Float64, sizeInBytes: positions.sizeInBytes)
            )
            
            // 12 triangles:  6 faces, 2 triangles each.
            indices = [
                4 , 5 , 6 , 4 , 6 , 7, // plane z = corner.Z
                1 , 0 , 3 , 1 , 3 , 2, // plane z = -corner.Z
                1 , 6 , 5 , 1 , 2 , 6, // plane x = corner.X
                2 , 3 , 7 , 2 , 7 , 6, // plane y = corner.Y
                3 , 0 , 4 , 3 , 4 , 7, // plane x = -corner.X
                0 , 1 , 5 , 0 , 5 , 4  // plane y = -corner.Y
            ]
        }
        
        let diff = max.subtract(min)
        let radius = diff.magnitude * 0.5
        
        return Geometry(
            attributes: attributes,
            indices: indices,
            primitiveType: .Triangle,
            boundingSphere: BoundingSphere(center: Cartesian3.zero, radius: radius)
        )
    }
    
}