//
//  EllipsoidGeometry.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

let defaultRadii = Cartesian3(x: 1.0, y: 1.0, z: 1.0)


/**
 * A description of an ellipsoid centered at the origin.
 *
 * @alias EllipsoidGeometry
 * @constructor
 *
 * @param {Object} [options] Object with the following properties:
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
 * @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Ellipsoid.html|Cesium Sandcastle Ellipsoid Demo}
 *
 * @example
 * var ellipsoid = new Cesium.EllipsoidGeometry({
 *   vertexFormat : Cesium.VertexFormat.POSITION_ONLY,
 *   radii : new Cesium.Cartesian3(1000000.0, 500000.0, 500000.0)
 * });
 * var geometry = Cesium.EllipsoidGeometry.createGeometry(ellipsoid);
 */

struct EllipsoidGeometry {
    
    let _radii: Cartesian3
    
    let _stackPartitions: Int
    
    let _slicePartitions: Int
    
    let _vertexFormat: VertexFormat
    
    init (
        radii: Cartesian3 = defaultRadii,
        stackPartitions: Int = 64,
        slicePartitions: Int = 64,
        vertexFormat: VertexFormat = VertexFormat.Default()
        ) {
            
            assert(slicePartitions >= 3, "slicePartitions cannot be less than three.")
            assert(slicePartitions >= 3, "stackPartitions cannot be less than three.")
            
            
            _radii = radii
            _stackPartitions = stackPartitions;
            _slicePartitions = slicePartitions;
            _vertexFormat = vertexFormat
    }
    
    
    
    /**
    * Stores the provided instance into the provided array.
    * @function
    *
    * @param {EllipsoidGeometry} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    func pack (_ array: inout [Float], startingIndex: Int = 0) {
    /*
    startingIndex = defaultValue(startingIndex, 0);
    
    Cartesian3.pack(value._radii, array, startingIndex);
    startingIndex += Cartesian3.packedLength;
    
    VertexFormat.pack(value._vertexFormat, array, startingIndex);
    startingIndex += VertexFormat.packedLength;
    
    array[startingIndex++] = value._stackPartitions;
    array[startingIndex]   = value._slicePartitions;*/
    }
    
    /*var scratchRadii = new Cartesian3();
    var scratchVertexFormat = new VertexFormat();
    var scratchOptions = {
    radii : scratchRadii,
    vertexFormat : scratchVertexFormat,
    stackPartitions : undefined,
    slicePartitions : undefined
    };*/
    

    
    /**
    * Computes the geometric representation of an ellipsoid, including its vertices, indices, and a bounding sphere.
    *
    * @param {EllipsoidGeometry} ellipsoidGeometry A description of the ellipsoid.
    * @returns {Geometry} The computed vertices and indices.
    */
    func createGeometry (_ context: Context) -> Geometry {
        
        let ellipsoid = Ellipsoid(radii: _radii)
        
        /*if ((radii.x <= 0) || (radii.y <= 0) || (radii.z <= 0)) {
            return;
        }*/
    
        // The extra slice and stack are for duplicating points at the x axis and poles.
        // We need the texture coordinates to interpolate from (2 * pi - delta) to 2 * pi instead of
        // (2 * pi - delta) to 0.
        let slicePartitions = _slicePartitions + 1
        let stackPartitions = _stackPartitions + 1
        
        let vertexCount = stackPartitions * slicePartitions
        var positions = [Double]()
    
        var indices = [Int]()
    
        var normals: [Float]? = _vertexFormat.normal ? [Float]() : nil
        var tangents: [Float]? = _vertexFormat.tangent ? [Float]() : nil
        var bitangents: [Float]? = _vertexFormat.bitangent ? [Float]() : nil
        var st: [Float]? = _vertexFormat.st ? [Float]() : nil
    
        var cosTheta = [Double]()
        var sinTheta = [Double]()
    
        var index = 0
        
        for i in 0..<slicePartitions {
            let theta = Math.TwoPi * Double(i) / Double(slicePartitions - 1)
            cosTheta.append(cos(theta))
            sinTheta.append(sin(theta))
            
            // duplicate first point for correct
            // texture coordinates at the north pole.
            positions.append(0.0)
            positions.append(0.0)
            positions.append(_radii.z)
        }
    
        for i in 1..<(stackPartitions-1) {
            let phi = .pi * Double(i) / Double(stackPartitions - 1)
            let sinPhi = sin(phi)
            
            let xSinPhi = _radii.x * sinPhi
            let ySinPhi = _radii.y * sinPhi
            let zCosPhi = _radii.z * cos(phi)
            
            for j in 0..<slicePartitions {
                positions.append(cosTheta[j] * xSinPhi)
                positions.append(sinTheta[j] * ySinPhi)
                positions.append(zCosPhi)
            }
        }
    
        for _ in 0..<slicePartitions {
            // duplicate first point for correct
            // texture coordinates at the sorth pole.
            positions.append(0.0)
            positions.append(0.0)
            positions.append(-_radii.z)
        }
        let attributes = GeometryAttributes()
        
        if _vertexFormat.position {
            attributes.position = GeometryAttribute(
                componentDatatype: .float64,
                componentsPerAttribute: 3,
                values: Buffer(device: context.device, array: positions, componentDatatype: .float64, sizeInBytes: positions.sizeInBytes)
            )
        }
        
        if _vertexFormat.st || _vertexFormat.normal || _vertexFormat.tangent || _vertexFormat.bitangent {
            for i in 0..<vertexCount {
                let position = Cartesian3(array: positions, startingIndex: i * 3)
                let normal = ellipsoid.geodeticSurfaceNormal(position)
                
                if _vertexFormat.st {
                    var normalST = normal.negate()
                    
                    // if the point is at or close to the pole, find a point along the same longitude
                    // close to the xy-plane for the s coordinate.
                    if normalST.magnitude < Math.Epsilon6 {
                        index = (i + slicePartitions * Int(floor(Double(stackPartitions)) * 0.5)) * 3
                        if index > positions.count {
                            index = (i - slicePartitions * Int(floor(Double(stackPartitions) * 0.5))) * 3
                        }
                        normalST = Cartesian3(array: positions, startingIndex: index)
                        normalST = ellipsoid.geodeticSurfaceNormal(normalST)
                        normalST.x = -normalST.x
                        normalST.y = -normalST.y
                    }
                    
                    st!.append(Float((atan2(normalST.y, normalST.x) / Math.TwoPi) + 0.5))
                    st!.append(Float((asin(normal.z) / .pi) + 0.5))
                }
    
                if _vertexFormat.normal {
                    normals!.append(Float(normal.x))
                    normals!.append(Float(normal.y))
                    normals!.append(Float(normal.z))
                }
            
            if _vertexFormat.tangent || _vertexFormat.bitangent {
                let tangent: Cartesian3
                if i < slicePartitions || i > vertexCount - slicePartitions - 1 {
                    tangent = Cartesian3.unitX.cross(normal).normalize()
                } else {
                    tangent = Cartesian3.unitZ.cross(normal).normalize()
                }
                
                if _vertexFormat.tangent, var tangents = tangents {
                    tangents.append(Float(tangent.x))
                    tangents.append(Float(tangent.y))
                    tangents.append(Float(tangent.z))
                }
                
                if _vertexFormat.bitangent, var bitangents = bitangents {
                    let bitangent = normal.cross(tangent).normalize()
                    
                    bitangents.append(Float(bitangent.x))
                    bitangents.append(Float(bitangent.y))
                    bitangents.append(Float(bitangent.z))
                }
                }
            }
            
            if _vertexFormat.st, let st = st {
                attributes.st = GeometryAttribute(
                    componentDatatype: .float32,
                    componentsPerAttribute: 2,
                    values : Buffer(device: context.device, array: st, componentDatatype: .float32, sizeInBytes: st.sizeInBytes)
                )
            }
            
            if _vertexFormat.normal, let normals = normals {
                attributes.normal = GeometryAttribute(
                    componentDatatype : .float32,
                    componentsPerAttribute : 3,
                    values : Buffer(device: context.device, array: normals, componentDatatype: .float32, sizeInBytes: normals.sizeInBytes)
                )
            }
            
            if _vertexFormat.tangent, let tangents = tangents {
                attributes.tangent = GeometryAttribute(
                    componentDatatype: ComponentDatatype.float32,
                    componentsPerAttribute: 3,
                    values: Buffer(device: context.device, array: tangents, componentDatatype: .float64, sizeInBytes: tangents.sizeInBytes)
                )
            }
            
            if _vertexFormat.bitangent, let bitangents = bitangents {
                attributes.bitangent = GeometryAttribute(
                    componentDatatype : ComponentDatatype.float32,
                    componentsPerAttribute : 3,
                    values : Buffer(device: context.device, array: bitangents, componentDatatype: .float64, sizeInBytes: bitangents.sizeInBytes)
                )
            }
        }
        
        for j in 0..<(slicePartitions - 1) {
            indices.append(slicePartitions + j)
            indices.append(slicePartitions + j + 1)
            indices.append(j + 1)
        }
        
        for i in 0..<(stackPartitions - 1) {
            let topOffset = i * slicePartitions
            let bottomOffset = (i + 1) * slicePartitions
            
            for j in 0..<(slicePartitions - 1) {
                indices.append(bottomOffset + j)
                indices.append(bottomOffset + j + 1)
                indices.append(topOffset + j + 1)
                
                indices.append(bottomOffset + j)
                indices.append(topOffset + j + 1)
                indices.append(topOffset + j)
            }
        }
        
        let i = stackPartitions - 2
        let topOffset = i * slicePartitions
        let bottomOffset = (i + 1) * slicePartitions
        
        for j in 0..<(slicePartitions - 1) {
            indices.append(bottomOffset + j)
            indices.append(topOffset + j + 1)
            indices.append(topOffset + j)
        }
        
        return  Geometry(
            attributes: attributes,
            indices: indices,
            boundingSphere : BoundingSphere(ellipsoid: ellipsoid)
        )
    }
    
}

extension EllipsoidGeometry: Packable {
    
    /**
     * The number of elements used to pack the object into an array.
     * @type {Number}
     */
    static func packedLength () -> Int {
        return Cartesian3.packedLength() + VertexFormat.packedLength() + 2
    }

    init(array: [Double], startingIndex: Int) {
        assert(array.count == EllipsoidGeometry.packedLength(), "Invalid packed array length")

        var index = startingIndex
        _radii = Cartesian3(array: array, startingIndex: index)
        
        index += Cartesian3.packedLength()
        
        _vertexFormat = VertexFormat(array: array, startingIndex: index)
        
        index += VertexFormat.packedLength()
        
        let stackPartitions = array[index]
        index += 1
        let slicePartitions = array[index]
        
        _stackPartitions = stackPartitions == Double.nan ? 64 : Int(stackPartitions)
        _slicePartitions = slicePartitions == Double.nan ? 64 : Int(slicePartitions)
    }

}
