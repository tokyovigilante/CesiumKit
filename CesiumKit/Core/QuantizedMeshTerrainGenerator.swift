//
//  QuantizedMeshTerrainGenerator.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

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
        minimumHeight: Double,
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
        relativeToCenter center: Cartesian3,
        ellipsoid: Ellipsoid,
        exaggeration: Double) -> (vertices: [Float], indices: [Int], vertexStride: Int, center: Cartesian3, minimumHeight: Double, maximumHeight: Double, boundingSphere: BoundingSphere?, orientedBoundingBox: OrientedBoundingBox?, occludeePointInScaledSpace: Cartesian3?, encoding: TerrainEncoding, skirtIndex: Int)
    {
        let quantizedVertexCount = quantizedVertices.count / 3
        let edgeVertexCount = westIndices.count + eastIndices.count + southIndices.count + northIndices.count
        
        let west = rectangle.west
        let south = rectangle.south
        let east = rectangle.east
        let north = rectangle.north
        
        let minimumHeight = minimumHeight * exaggeration
        let maximumHeight = maximumHeight * exaggeration
        
        let fromENU = Transforms.eastNorthUpToFixedFrame(center, ellipsoid: ellipsoid)
        let toENU = fromENU.inverse
        
        let uBuffer = quantizedVertices[0..<quantizedVertexCount]
        let vBuffer = quantizedVertices[quantizedVertexCount..<(quantizedVertexCount * 2)]
        let heightBuffer = quantizedVertices[(quantizedVertexCount * 2)..<(quantizedVertexCount * 3)]
        let hasVertexNormals = octEncodedNormals != nil
        
        var positions = [Cartesian3]()
        var heights = [Double]()
        var uvs = [Cartesian2]()
        
        var minimum = Cartesian3(simd: double3(Double.infinity))
        var maximum = Cartesian3(simd: double3(-Double.infinity))
        var cartesian3Scratch = Cartesian3()
        
        let uStartIndex = uBuffer.startIndex
        let vStartIndex = vBuffer.startIndex
        let hStartIndex = heightBuffer.startIndex
        
        for i in 0..<quantizedVertexCount {
            let u = Double(uBuffer[uStartIndex + i]) / maxShort
            let v = Double(vBuffer[vStartIndex + i]) / maxShort
            let height = Math.lerp(p: minimumHeight, q: maximumHeight, time: Double(heightBuffer[hStartIndex + i]) / maxShort)
            
            let cartographic = Cartographic(
                longitude: Math.lerp(p: west, q: east, time: u),
                latitude: Math.lerp(p: south, q: north, time: v),
                height: height
            )
            
            let position = ellipsoid.cartographicToCartesian(cartographic)
            
            uvs.append(Cartesian2(x: u, y: v))
            heights.append(height)
            positions.append(position)
            
            cartesian3Scratch = toENU.multiplyByPoint(position)
           
            minimum = cartesian3Scratch.minimumByComponent(minimum)
            maximum = cartesian3Scratch.maximumByComponent(maximum)
        }
        
        var occludeePointInScaledSpace: Cartesian3? = nil
        var orientedBoundingBox: OrientedBoundingBox? = nil
        var boundingSphere: BoundingSphere? = nil
        
        if exaggeration != 1.0 {
            // Bounding volumes and horizon culling point need to be recomputed since the tile payload assumes no exaggeration.
            boundingSphere = BoundingSphere(fromPoints: positions)
            orientedBoundingBox = OrientedBoundingBox(fromRectangle: rectangle, minimumHeight: minimumHeight, maximumHeight: maximumHeight, ellipsoid: ellipsoid)
            
            let occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
            occludeePointInScaledSpace = occluder.computeHorizonCullingPointFromPoints(directionToPoint: center, points: positions);
        }
        
        var hMin = minimumHeight
        hMin = min(hMin, findMinMaxSkirts(westIndices, edgeHeight: westSkirtHeight, heights: heights, uvs: uvs, rectangle: rectangle, ellipsoid: ellipsoid, toENU: toENU, minimum: &minimum, maximum: &maximum))
        hMin = min(hMin, findMinMaxSkirts(southIndices, edgeHeight: southSkirtHeight, heights: heights, uvs: uvs, rectangle: rectangle, ellipsoid: ellipsoid, toENU: toENU, minimum: &minimum, maximum: &maximum))
        hMin = min(hMin, findMinMaxSkirts(eastIndices, edgeHeight: eastSkirtHeight, heights: heights, uvs: uvs, rectangle: rectangle, ellipsoid: ellipsoid, toENU: toENU, minimum: &minimum, maximum: &maximum))
        hMin = min(hMin, findMinMaxSkirts(northIndices, edgeHeight: northSkirtHeight, heights: heights, uvs: uvs, rectangle: rectangle, ellipsoid: ellipsoid, toENU: toENU, minimum: &minimum, maximum: &maximum))
        
        let aaBox = AxisAlignedBoundingBox(minimum: minimum, maximum: maximum, center: center)
        let encoding = TerrainEncoding(axisAlignedBoundingBox: aaBox, minimumHeight: hMin, maximumHeight: maximumHeight, fromENU: fromENU, hasVertexNormals: hasVertexNormals)
        let vertexStride = encoding.getStride()
        let size = quantizedVertexCount * vertexStride + edgeVertexCount * vertexStride
        
        var vertexBuffer = [Float]()
        
        var toPack: Cartesian2? = nil
        
        for j in 0..<quantizedVertexCount {
            if hasVertexNormals {
                let n = j * 2
                let toPackX = octEncodedNormals![n]
                let toPackY = octEncodedNormals![n + 1]
                
                if exaggeration != 1.0 {
                    var normal = AttributeCompression.octDecode(x: toPackX, y: toPackY)
                    let fromENUNormal = Transforms.eastNorthUpToFixedFrame(cartesian3Scratch, ellipsoid: ellipsoid)
                    let toENUNormal = fromENUNormal.inverse
                    
                    normal = toENUNormal.multiplyByPointAsVector(normal)
                    normal.z *= exaggeration
                    normal = normal.normalize()
                    
                    normal = fromENUNormal.multiplyByPointAsVector(normal)
                    normal = normal.normalize()
                    
                    toPack = AttributeCompression.octEncode(normal)
                } else {
                    toPack = Cartesian2(x: Double(toPackX), y: Double(toPackY))
                    
                }
            }
            encoding.encode(&vertexBuffer, position: positions[j], uv: uvs[j], height: heights[j], normalToPack: toPack)
        }
        
        //let edgeTriangleCount = max(0, (edgeVertexCount - 4) * 2)
        //var indexBufferLength = parameters.indices.length + edgeTriangleCount * 3;
        //var indexBuffer = IndexDatatype.createTypedArray(quantizedVertexCount + edgeVertexCount, indexBufferLength);
        //indexBuffer.set(parameters.indices, 0);
        var indexBuffer = indices
        let skirtIndex = indices.count
        // Add skirts.
        addSkirt(&vertexBuffer, indexBuffer: &indexBuffer, edgeVertices: westIndices, encoding: encoding, heights: heights, uvs: uvs, octEncodedNormals: octEncodedNormals, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: westSkirtHeight, isWestOrNorthEdge: true, exaggeration: exaggeration)
        addSkirt(&vertexBuffer, indexBuffer: &indexBuffer, edgeVertices: southIndices, encoding: encoding, heights: heights, uvs: uvs, octEncodedNormals: octEncodedNormals, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: southSkirtHeight, isWestOrNorthEdge: false, exaggeration: exaggeration)
        addSkirt(&vertexBuffer, indexBuffer: &indexBuffer, edgeVertices: eastIndices, encoding: encoding, heights: heights, uvs: uvs, octEncodedNormals: octEncodedNormals, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: eastSkirtHeight, isWestOrNorthEdge: false, exaggeration: exaggeration)
        addSkirt(&vertexBuffer, indexBuffer: &indexBuffer, edgeVertices: northIndices, encoding: encoding, heights: heights, uvs: uvs, octEncodedNormals: octEncodedNormals, ellipsoid: ellipsoid, rectangle: rectangle, skirtLength: northSkirtHeight, isWestOrNorthEdge: true, exaggeration: exaggeration)

        

        return (
            vertices: vertexBuffer,
            indices : indexBuffer,
            vertexStride: vertexStride,
            center: center,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight,
            boundingSphere: boundingSphere,
            orientedBoundingBox: orientedBoundingBox,
            occludeePointInScaledSpace: occludeePointInScaledSpace,
            encoding: encoding,
            skirtIndex : skirtIndex
        )
    }
    
    class func addSkirt(_ vertexBuffer: inout [Float32], indexBuffer: inout [Int], edgeVertices: [Int], encoding: TerrainEncoding, heights: [Double], uvs: [Cartesian2], octEncodedNormals: [UInt8]?, ellipsoid: Ellipsoid, rectangle: Rectangle, skirtLength: Double, isWestOrNorthEdge: Bool, exaggeration: Double) {
        
        let start, end, increment: Int
        if isWestOrNorthEdge {
            start = edgeVertices.count - 1
            end = -1
            increment = -1
        } else {
            start = 0
            end = edgeVertices.count
            increment = 1
        }
        
        var previousIndex = -1
        
        let vertexStride = encoding.getStride()
        var vertexIndex = vertexBuffer.count / vertexStride
        
        let north = rectangle.north
        let south = rectangle.south
        var east = rectangle.east
        let west = rectangle.west
        
        if east < west {
            east += Math.TwoPi
        }
        
        for i in start.stride(to: end, by: increment) {
            let index = edgeVertices[i]
            let h = heights[index]
            var uv = uvs[index]
            
            let cartographic = Cartographic(
                longitude: Double(Math.lerp(p: west, q: east, time: uv.x)),
                latitude: Double(Math.lerp(p: south, q: north, time: uv.y)),
                height: h - skirtLength
            )
            
            let position = ellipsoid.cartographicToCartesian(cartographic)
            
            var toPack: Cartesian2? = nil
            if let vertexNormals = octEncodedNormals {
                let n = index * 2

                let toPackX = vertexNormals[n]
                let toPackY = vertexNormals[n + 1]
                
                if exaggeration != 1.0 {
                    var normal = AttributeCompression.octDecode(x: toPackX, y: toPackY)
                    let fromENUNormal = Transforms.eastNorthUpToFixedFrame(position, ellipsoid: ellipsoid)
                    let toENUNormal = fromENUNormal.inverse
                    
                    normal = toENUNormal.multiplyByPointAsVector(normal)
                    normal.z *= exaggeration
                    normal = normal.normalize()
                    
                    normal = fromENUNormal.multiplyByPointAsVector(normal)
                    normal = normal.normalize()
                    
                    toPack = AttributeCompression.octEncode(normal)
                } else {
                    toPack = Cartesian2(x: Double(toPackX), y: Double(toPackY))
                }
            }
            encoding.encode(&vertexBuffer, position: position, uv: uv, height: cartographic.height, normalToPack: toPack)
            
            if (previousIndex != -1) {
                indexBuffer.append(previousIndex)
                indexBuffer.append(vertexIndex - 1)
                indexBuffer.append(index)
                
                indexBuffer.append(vertexIndex - 1)
                indexBuffer.append(vertexIndex)
                indexBuffer.append(index)
            }
            
            previousIndex = index
            vertexIndex += 1
        }
    }
    
    class func findMinMaxSkirts(_ edgeIndices: [Int], edgeHeight: Double, heights: [Double], uvs: [Cartesian2], rectangle: Rectangle, ellipsoid: Ellipsoid, toENU: Matrix4, minimum: inout Cartesian3, maximum: inout Cartesian3) -> Double {
        var hMin = Double.infinity
        
        let north = rectangle.north
        let south = rectangle.south
        var east = rectangle.east
        let west = rectangle.west
        
        if east < west {
            east += M_2_PI
        }
        
        for i in 0..<edgeIndices.count {
            let index = edgeIndices[i]
            let h = heights[index]
            let uv = uvs[index]
            
            let cartographic = Cartographic(
                longitude:  Math.lerp(p: west, q: east, time: uv.x),
                latitude: Math.lerp(p: south, q: north, time: uv.y),
                height: h - edgeHeight
            )

            var position = ellipsoid.cartographicToCartesian(cartographic)
            position = toENU.multiplyByPoint(position)
            
            minimum = position.minimumByComponent(minimum)
            maximum = position.maximumByComponent(maximum)
            
            hMin = min(hMin, cartographic.height)
        }
        return hMin
    }

}
