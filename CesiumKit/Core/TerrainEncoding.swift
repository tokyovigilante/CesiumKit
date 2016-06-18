//
//  TerrainEncoding.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

private let shiftLeft12 = pow(2.0, 12.0)

/**
 * Data used to quantize and pack the terrain mesh. The position can be unpacked for picking and all attributes
 * are unpacked in the vertex shader.
 *
 * @alias TerrainEncoding
 * @constructor
 *
 * @param {AxisAlignedBoundingBox} axisAlignedBoundingBox The bounds of the tile in the east-north-up coordinates at the tiles center.
 * @param {Number} minimumHeight The minimum height.
 * @param {Number} maximumHeight The maximum height.
 * @param {Matrix4} fromENU The east-north-up to fixed frame matrix at the center of the terrain mesh.
 * @param {Boolean} hasVertexNormals If the mesh has vertex normals.
 *
 * @private
 */
struct TerrainEncoding {
    /*
    var cartesian3Scratch = new Cartesian3();
    var cartesian3DimScratch = new Cartesian3();
    var cartesian2Scratch = new Cartesian2();
    var matrix4Scratch = new Matrix4();
    var matrix4Scratch2 = new Matrix4();
    
    */
    /**
     * How the vertices of the mesh were compressed.
     * @type {TerrainQuantization}
     */
    let quantization: TerrainQuantization
    
    /**
     * The minimum height of the tile including the skirts.
     * @type {Number}
     */
    let minimumHeight: Double
    
    /**
     * The maximum height of the tile.
     * @type {Number}
     */
    let maximumHeight: Double
    
    /**
     * The center of the tile.
     * @type {Cartesian3}
     */
    let center: Cartesian3
    
    /**
     * A matrix that takes a vertex from the tile, transforms it to east-north-up at the center and scales
     * it so each component is in the [0, 1] range.
     * @type {Matrix4}
     */
    let toScaledENU: Matrix4
    
    /**
     * A matrix that restores a vertex transformed with toScaledENU back to the earth fixed reference frame
     * @type {Matrix4}
     */
    let fromScaledENU: Matrix4
    
    /**
     * The matrix used to decompress the terrain vertices in the shader for RTE rendering.
     * @type {Matrix4}
     */
    let matrix: Matrix4
    
    /**
     * The terrain mesh contains normals.
     * @type {Boolean}
     */
    let hasVertexNormals: Bool
    
    let vertexAttributes: [VertexAttributes]

    init (axisAlignedBoundingBox: AxisAlignedBoundingBox, minimumHeight: Double, maximumHeight: Double, fromENU: Matrix4, hasVertexNormals: Bool) {
        
        let minimum = axisAlignedBoundingBox.minimum
        let maximum = axisAlignedBoundingBox.maximum
        
        let dimensions = maximum.subtract(minimum)
        let hDim = maximumHeight - minimumHeight
        let maxDim = max(dimensions.maximumComponent(), hDim)
        
        if maxDim < shiftLeft12 - 1.0 {
            quantization = .bits12
        } else {
            quantization = .none
        }
        
        let center = axisAlignedBoundingBox.center
        var toENU = fromENU.inverse
        
        toENU = Matrix4(translation: minimum.negate()).multiply(toENU)
        
        let scale = Cartesian3(
            x: 1.0 / dimensions.x,
            y: 1.0 / dimensions.y,
            z: 1.0 / dimensions.z
        )
        toENU = Matrix4(scale: scale).multiply(toENU)
        
        var matrix = fromENU.setTranslation(Cartesian3.zero)
        
        var fromENU = fromENU
        
        let translationMatrix = Matrix4(translation: minimum)
        let scaleMatrix =  Matrix4(scale: dimensions)
        let st = translationMatrix.multiply(scaleMatrix)
        
        fromENU = fromENU.multiply(st)
        matrix = matrix.multiply(st)
        
        self.minimumHeight = minimumHeight
        self.maximumHeight = maximumHeight
        self.center = center
        self.toScaledENU = toENU
        self.fromScaledENU = fromENU
        self.matrix = matrix
        self.hasVertexNormals = hasVertexNormals
        
        let datatype = ComponentDatatype.float32
        
        if quantization == .none {
            let position3DAndHeightLength = 4
            var numTexCoordComponents = 2
            if hasVertexNormals {
                numTexCoordComponents += 1
            }
            
            vertexAttributes = [
                //position3DAndHeight
                VertexAttributes(
                    buffer: nil,
                    bufferIndex: VertexDescriptorFirstBufferOffset,
                    index: 0,
                    format: .float4,
                    offset: 0,
                    size: position3DAndHeightLength * datatype.elementSize,
                    normalize: false),
                // texCoordAndEncodedNormals
                VertexAttributes(
                    buffer: nil,
                    bufferIndex: VertexDescriptorFirstBufferOffset,
                    index: 1,
                    format: hasVertexNormals ? .float3 : .float2,
                    offset: position3DAndHeightLength * datatype.elementSize,
                    size: numTexCoordComponents * datatype.elementSize,
                    normalize: false)
            ]
        } else {
            var numComponents = 3
            if hasVertexNormals {
                numComponents += 1
            }
            vertexAttributes = [
                // compressed
                VertexAttributes(
                    buffer: nil,
                    bufferIndex: VertexDescriptorFirstBufferOffset,
                    index: 0,
                    format: hasVertexNormals ? .float4 : .float3,
                    offset: 0,
                    size: numComponents * datatype.elementSize,
                    normalize: false)
            ]
        }
    }

    func encode (_ vertexBuffer: inout [Float], position: Cartesian3, uv: Cartesian2, height: Double, normalToPack: Cartesian2? = nil) {
        let u = uv.x
        let v = uv.y
        
        if quantization == .bits12 {
            var position = toScaledENU.multiplyByPoint(position)
            
            position.x = Math.clamp(position.x, min: 0.0, max: 1.0)
            position.y = Math.clamp(position.y, min: 0.0, max: 1.0)
            position.z = Math.clamp(position.z, min: 0.0, max: 1.0)
            
            let hDim = maximumHeight - minimumHeight
            let h = Math.clamp((height - minimumHeight) / hDim, min: 0.0, max: 1.0)
            
            let compressed0 = AttributeCompression.compressTextureCoordinates(Cartesian2(x: position.x, y: position.y))
            
            let compressed1 = AttributeCompression.compressTextureCoordinates(Cartesian2(x: position.z, y: h))
            
            let compressed2 = AttributeCompression.compressTextureCoordinates(Cartesian2(x: u, y: v))
            
            vertexBuffer.append(compressed0)
            vertexBuffer.append(compressed1)
            vertexBuffer.append(compressed2)
        } else {
            let positionRTC = position.subtract(center)
            
            vertexBuffer.append(Float(positionRTC.x))
            vertexBuffer.append(Float(positionRTC.y))
            vertexBuffer.append(Float(positionRTC.z))
            vertexBuffer.append(Float(height))
            vertexBuffer.append(Float(u))
            vertexBuffer.append(Float(v))
        }
        
        if hasVertexNormals {
            vertexBuffer.append(AttributeCompression.octPackFloat(normalToPack!))
        }
    }
    
    func decodePosition (_ buffer: [Float], index: Int) -> Cartesian3 {
        let index  = index * getStride()
        
        var result = Cartesian3()
        
        if quantization == .bits12 {
            let xy = AttributeCompression.decompressTextureCoordinates(buffer[index])
            result.x = xy.x
            result.y = xy.y
            
            let zh = AttributeCompression.decompressTextureCoordinates(buffer[index + 1])
            result.z = zh.x
            
            return fromScaledENU.multiplyByPoint(result)
        }
        result.x = Double(buffer[index])
        result.y = Double(buffer[index + 1])
        result.z = Double(buffer[index + 2])
        return result.add(center)
    }

    func decodeTextureCoordinates (_ buffer: [Float], index: Int) -> Cartesian2 {
        let index = index * getStride()
        
        if quantization == .bits12 {
            return AttributeCompression.decompressTextureCoordinates(buffer[index + 2])
        }
        return Cartesian2(x: Double(buffer[index + 4]), y: Double(buffer[index + 5]))
    }
    
    func decodeHeight (_ buffer: [Float], index: Int) -> Double {
        let index = index * getStride()
        
        if quantization == .bits12 {
            let zh = AttributeCompression.decompressTextureCoordinates(buffer[index + 1])
            return zh.y * (maximumHeight - minimumHeight) + minimumHeight
        }
        return Double(buffer[index + 3])
    }
    /*
    TerrainEncoding.prototype.getOctEncodedNormal = function(buffer, index, result) {
    var stride = this.getStride();
    index = (index + 1) * stride - 1;
    
    var temp = buffer[index] / 256.0;
    var x = Math.floor(temp);
    var y = (temp - x) * 256.0;
    
    return Cartesian2.fromElements(x, y, result);
    };
    */
    
    func getStride () -> Int {
        var vertexStride: Int
        
        switch quantization {
        case .bits12:
            vertexStride = 3
        default:
            vertexStride = 6
        }
        
        if hasVertexNormals {
            vertexStride += 1
        }
        
        return vertexStride
    }
    
}
