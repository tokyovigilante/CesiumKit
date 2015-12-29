//
//  QuantizedMeshTerrainGenerator.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation


private let maxShort = Double(Int16.max)

private let xIndex = 0
private let yIndex = 1
private let zIndex = 2
private let hIndex = 3
private let uIndex = 4
private let vIndex = 5
private let nIndex = 6

class QuantizedMeshTerrainGenerator {
    
    class func computeMesh (
        minimumHeight minimumHeight: Double,
        maximumHeight: Double,
        quantizedVertices: [UInt16],
        octEncodedNormals: [UInt8]?,
        indices: [Int],
        westIndices: [Int],
        southIndices: [Int],
        eastIndices: [Int],
        northIndices: [Int],
        westSkirtHeight: Double,
        southSkirtHeight: Double,
        eastSkirtHeight: Double,
        northSkirtHeight: Double,
        rectangle: Rectangle,
        relativeToCenter: Cartesian3,
        ellipsoid: Ellipsoid,
        exaggeration: Double) -> (boundingSphere: BoundingSphere?, center: Cartesian3, indices: [Int], maximumHeight: Double, minimumHeight: Double, occludeePointInScaledSpace: Cartesian3?, orientedBoundingBox: OrientedBoundingBox?, vertexStride: Int, vertices: [Float32])
    {

        let quantizedVertexCount = quantizedVertices.count / 3
        let edgeVertexCount = westIndices.count + eastIndices.count +
        southIndices.count + northIndices.count
        
        let west = rectangle.west
        let south = rectangle.south
        let east = rectangle.east
        let north = rectangle.north
        
        let uBuffer = quantizedVertices[0..<quantizedVertexCount]
        let vBuffer = quantizedVertices[quantizedVertexCount..<(quantizedVertexCount * 2)]
        let heightBuffer = quantizedVertices[(quantizedVertexCount * 2)..<(quantizedVertexCount * 3)]
        let hasVertexNormals = octEncodedNormals != nil
        
        let vertexStride: Int
        if hasVertexNormals {
            vertexStride = 7
        } else {
            vertexStride = 6
        }
        
        var vertexBuffer = [Float32](count: quantizedVertexCount * vertexStride + edgeVertexCount * vertexStride, repeatedValue: 0.0)
        
        for (var i = 0, bufferIndex = 0, n = 0; i < quantizedVertexCount; i += 1, bufferIndex += vertexStride, n += 2) {
            let uStartIndex = uBuffer.startIndex
            let vStartIndex = vBuffer.startIndex
            let hStartIndex = heightBuffer.startIndex
            
            let u = Double(uBuffer[uStartIndex + i]) / maxShort
            let v = Double(vBuffer[vStartIndex + i]) / maxShort
            let height = Math.lerp(p: minimumHeight, q: maximumHeight, time: Double(heightBuffer[hStartIndex + i]) / maxShort)
            
            let cartographic = Cartographic(
                longitude: Math.lerp(p: west, q: east, time: u),
                latitude: Math.lerp(p: south, q: north, time: v),
                height: height
            )
            
            let cartesian = ellipsoid.cartographicToCartesian(cartographic)
            
            vertexBuffer[bufferIndex + xIndex] = Float(cartesian.x - relativeToCenter.x)
            vertexBuffer[bufferIndex + yIndex] = Float(cartesian.y - relativeToCenter.y)
            vertexBuffer[bufferIndex + zIndex] = Float(cartesian.z - relativeToCenter.z)
            vertexBuffer[bufferIndex + hIndex] = Float(height)
            vertexBuffer[bufferIndex + uIndex] = Float(u)
            vertexBuffer[bufferIndex + vIndex] = Float(v)
            if hasVertexNormals {
                let toPack = Cartesian2(
                    x: Double(octEncodedNormals![n]),
                    y: Double(octEncodedNormals![n + 1])
                )
                vertexBuffer[bufferIndex + nIndex] = AttributeCompression.octPackFloat(toPack)
            }
        }
        
        let edgeTriangleCount = max(0, (edgeVertexCount - 4) * 2)
        var indexBuffer = indices + [Int](count: edgeTriangleCount * 3, repeatedValue: 0)
        
        
        //indexBuffer.set(parameters.indices, 0);
        
        // Add skirts.
        var vertexBufferIndex = quantizedVertexCount * vertexStride
        var indexBufferIndex = indices.count
        
        indexBufferIndex = addSkirt(&vertexBuffer, vertexBufferIndex: &vertexBufferIndex, indexBuffer: &indexBuffer, indexBufferIndex: &indexBufferIndex, edgeVertices: westIndices, center: relativeToCenter, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: westSkirtHeight, isWestOrNorthEdge: true, hasVertexNormals: hasVertexNormals)
        vertexBufferIndex += westIndices.count * vertexStride
        indexBufferIndex = addSkirt(&vertexBuffer, vertexBufferIndex: &vertexBufferIndex, indexBuffer: &indexBuffer, indexBufferIndex: &indexBufferIndex, edgeVertices: southIndices, center: relativeToCenter, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: southSkirtHeight, isWestOrNorthEdge: false, hasVertexNormals: hasVertexNormals)
        vertexBufferIndex += southIndices.count * vertexStride
        indexBufferIndex = addSkirt(&vertexBuffer, vertexBufferIndex: &vertexBufferIndex, indexBuffer: &indexBuffer, indexBufferIndex: &indexBufferIndex, edgeVertices: eastIndices, center: relativeToCenter, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: eastSkirtHeight, isWestOrNorthEdge: false, hasVertexNormals: hasVertexNormals)
        vertexBufferIndex += eastIndices.count * vertexStride;
        indexBufferIndex = addSkirt(&vertexBuffer, vertexBufferIndex: &vertexBufferIndex, indexBuffer: &indexBuffer, indexBufferIndex: &indexBufferIndex, edgeVertices: northIndices, center: relativeToCenter, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: northSkirtHeight, isWestOrNorthEdge: true, hasVertexNormals: hasVertexNormals)
        vertexBufferIndex += northIndices.count * vertexStride
        
        //transferableObjects.push(vertexBuffer.buffer, indexBuffer.buffer);
        
        return (
            boundingSphere: nil,
            center: relativeToCenter,
            indices: indexBuffer,
            maximumHeight: maximumHeight,
            minimumHeight: minimumHeight,
            occludeePointInScaledSpace: nil,
            orientedBoundingBox: nil,
            vertexStride: vertexStride,
            vertices: vertexBuffer
        )
        //maximumHeight: Double, minimumHeight: Double, vertices: [Float], boundingSphere: BoundingSphere?, orientedBoundingBox: OrientedBoundingBox?, occludeePointInScaledSpace: Cartesian3?
    }
    
    class func addSkirt(inout vertexBuffer: [Float32], inout vertexBufferIndex: Int, inout indexBuffer: [Int], inout indexBufferIndex: Int, edgeVertices: [Int  ], center: Cartesian3, ellipsoid: Ellipsoid, rectangle: Rectangle, skirtLength: Double, isWestOrNorthEdge: Bool, hasVertexNormals: Bool) -> Int {
        
        let vertexStride: Int
        if hasVertexNormals {
            vertexStride = 7
        } else {
            vertexStride = 6
        }
        
        let start, end, increment: Int
        if isWestOrNorthEdge {
            start = edgeVertices.count - 1
            end = -1;
            increment = -1;
        } else {
            start = 0;
            end = edgeVertices.count
            increment = 1;
        }
        
        var previousIndex = -1
        
        var vertexIndex = vertexBufferIndex / vertexStride
        
        let north = rectangle.north
        let south = rectangle.south
        var east = rectangle.east
        let west = rectangle.west
        
        if east < west {
            east += Math.TwoPi
        }
        
        for (var i = start; i != end; i += increment) {
            let index = edgeVertices[i];
            let offset = index * vertexStride
            let u = Double(vertexBuffer[offset + uIndex])
            let v = Double(vertexBuffer[offset + vIndex])
            let h = Double(vertexBuffer[offset + hIndex])
            
            let cartographic = Cartographic(
                longitude: Double(Math.lerp(p: west, q: east, time: u)),
                latitude: Double(Math.lerp(p: south, q: north, time: v)),
                height: h - skirtLength
            )
            
            let position = ellipsoid.cartographicToCartesian(cartographic).subtract(center)
            
            vertexBuffer.append(Float(position.x))
            vertexBuffer.append(Float(position.y))
            vertexBuffer.append(Float(position.z))
            vertexBuffer.append(Float(cartographic.height))
            vertexBuffer.append(Float(u))
            vertexBuffer.append(Float(v))
            if (hasVertexNormals) {
                vertexBuffer.append(vertexBuffer[offset + nIndex])
            }
            
            if (previousIndex != -1) {
                indexBuffer[indexBufferIndex++] = previousIndex
                indexBuffer[indexBufferIndex++] = vertexIndex - 1
                indexBuffer[indexBufferIndex++] = index
                
                indexBuffer[indexBufferIndex++] = vertexIndex - 1
                indexBuffer[indexBufferIndex++] = vertexIndex
                indexBuffer[indexBufferIndex++] = index
            }
            
            previousIndex = index
            ++vertexIndex
        }
        
        return indexBufferIndex
    }
    
}