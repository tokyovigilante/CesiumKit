//
//  QuantizedMeshUpsampler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/03/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

private let halfMaxShort = Int((Int16.max / 2) | 0)
private let maxShort = Int(Int16.max)

class QuantizedMeshUpsampler {
/*
 
 var maxShort = 32767;
 var halfMaxShort = (maxShort / 2) | 0;
 
 var clipScratch = [];
 var clipScratch2 = [];
 var verticesScratch = [];
 var cartographicScratch = new Cartographic();
 var cartesian3Scratch = new Cartesian3();
 var uScratch = [];
 var vScratch = [];
 var heightScratch = [];
 var indicesScratch = [];
 var normalsScratch = [];
 var horizonOcclusionPointScratch = new Cartesian3();
 var boundingSphereScratch = new BoundingSphere();
 var orientedBoundingBoxScratch = new OrientedBoundingBox();
 */
    
    class func upsampleQuantizedTerrainMesh (
        vertices parentVertices: [UInt16],
        indices parentIndices: [Int],
        encodedNormals parentNormalBuffer: [UInt8]?,
        minimumHeight parentMinimumHeight: Double,
        maximumHeight parentMaximumHeight: Double,
        isEastChild: Bool,
        isNorthChild: Bool,
        childRectangle: Rectangle,
        ellipsoid: Ellipsoid) ->
        (
            vertices: [UInt16],
            encodedNormals: [UInt8],
            indices: [Int],
            minimumHeight: Double,
            maximumHeight: Double,
            westIndices: [Int],
            southIndices: [Int],
            eastIndices: [Int],
            northIndices: [Int],
            boundingSphere: BoundingSphere,
            orientedBoundingBox: OrientedBoundingBox,
            horizonOcclusionPoint: Cartesian3
        )
    {
 
        let minU = isEastChild ? halfMaxShort : 0
        let maxU = isEastChild ? maxShort : halfMaxShort
        let minV = isNorthChild ? halfMaxShort : 0
        let maxV = isNorthChild ? maxShort : halfMaxShort
        var uBuffer = [Int]()
        var vBuffer = [Int]()
        var heightBuffer = [Double]()
        var normalBuffer = [UInt8]()
 
        var indices = [Int]()
 
        var vertexMap = [String: Int]()
 
        let quantizedVertexCount = parentVertices.count / 3
        let parentUBuffer = parentVertices[0..<quantizedVertexCount].map { Int($0) }
        let parentVBuffer = parentVertices[quantizedVertexCount..<(2 * quantizedVertexCount)].map { Int($0) }
        let parentHeightBuffer = parentVertices[(quantizedVertexCount*2)..<(3*quantizedVertexCount)].map { Double($0) }
 
        var vertexCount = 0
        let hasVertexNormals = parentNormalBuffer != nil
        
        for (i, (parentU, parentV)) in zip(parentUBuffer, parentVBuffer).enumerated() {
            let u = Int(parentU)
            let v = Int(parentV)
            if (isEastChild && u >= halfMaxShort || !isEastChild && u <= halfMaxShort) &&
                (isNorthChild && v >= halfMaxShort || !isNorthChild && v <= halfMaxShort) {

                vertexMap["\(i)"] = vertexCount
                uBuffer.append(u)
                vBuffer.append(v)
                heightBuffer.append(parentHeightBuffer[i])
                if hasVertexNormals {
                    normalBuffer.append(parentNormalBuffer![i*2])
                    normalBuffer.append(parentNormalBuffer![i*2+1])
                }
                vertexCount += 1
            }
        }
        
        var triangleVertices = [Vertex(), Vertex(), Vertex()]
        
        var clippedTriangleVertices = [Vertex(), Vertex(), Vertex()]
        
        for i in stride(from: 0, to: parentIndices.count, by: 3) {
            let i0 = parentIndices[i]
            let i1 = parentIndices[i + 1]
            let i2 = parentIndices[i + 2]
            
            let u0 = Int(parentUBuffer[i0])
            let u1 = Int(parentUBuffer[i1])
            let u2 = Int(parentUBuffer[i2])
            
            triangleVertices[0].initializeIndexed(
                parentUBuffer,
                vBuffer: parentVBuffer,
                heightBuffer: parentHeightBuffer,
                normalBuffer: parentNormalBuffer,
                index: i0
            )
            triangleVertices[1].initializeIndexed(
                parentUBuffer,
                vBuffer: parentVBuffer,
                heightBuffer: parentHeightBuffer,
                normalBuffer: parentNormalBuffer,
                index: i1
            )
            triangleVertices[2].initializeIndexed(
                parentUBuffer,
                vBuffer: parentVBuffer,
                heightBuffer: parentHeightBuffer,
                normalBuffer: parentNormalBuffer,
                index: i2
            )
            
            // Clip triangle on the east-west boundary.
            let clipped = Intersections2D.clipTriangleAtAxisAlignedThreshold(threshold: halfMaxShort, keepAbove: isEastChild, u0: u0, u1: u1, u2: u2)
            
            // Get the first clipped triangle, if any.
            var clippedIndex = 0
            
            if clippedIndex >= clipped.count {
                continue
            }
            clippedIndex = clippedTriangleVertices[0].initializeFromClipResult(clipped, index: clippedIndex, vertices: triangleVertices)
            
            if clippedIndex >= clipped.count {
                continue
            }
            clippedIndex = clippedTriangleVertices[1].initializeFromClipResult(clipped, index: clippedIndex, vertices: triangleVertices)
            
            if clippedIndex >= clipped.count {
                continue
            }
            clippedIndex = clippedTriangleVertices[2].initializeFromClipResult(clipped, index: clippedIndex, vertices: triangleVertices)
            
            // Clip the triangle against the North-south boundary.
            var clipped2 = Intersections2D.clipTriangleAtAxisAlignedThreshold(threshold: halfMaxShort, keepAbove: isNorthChild, u0: clippedTriangleVertices[0].getV(), u1: clippedTriangleVertices[1].getV(), u2: clippedTriangleVertices[2].getV())
            
            addClippedPolygon(&uBuffer, vBuffer: &vBuffer, heightBuffer: &heightBuffer, normalBuffer: &normalBuffer, indices: &indices, vertexMap: &vertexMap, clipped: clipped2, triangleVertices: clippedTriangleVertices, hasVertexNormals: hasVertexNormals)
            
            // If there's another vertex in the original clipped result,
            // it forms a second triangle.  Clip it as well.
            if clippedIndex < clipped.count {
                clippedTriangleVertices[2].clone(clippedTriangleVertices[1])
                clippedTriangleVertices[2].initializeFromClipResult(clipped, index: clippedIndex, vertices: triangleVertices)
                
                clipped2 = Intersections2D.clipTriangleAtAxisAlignedThreshold(threshold: halfMaxShort, keepAbove: isNorthChild, u0: clippedTriangleVertices[0].getV(), u1: clippedTriangleVertices[1].getV(), u2: clippedTriangleVertices[2].getV())
                addClippedPolygon(&uBuffer, vBuffer: &vBuffer, heightBuffer: &heightBuffer, normalBuffer: &normalBuffer, indices: &indices, vertexMap: &vertexMap, clipped: clipped2, triangleVertices: clippedTriangleVertices, hasVertexNormals: hasVertexNormals)
            }
        }
        
        let uOffset = isEastChild ? -Int(maxShort) : 0
        let vOffset = isNorthChild ? -Int(maxShort) : 0
        
        var westIndices = [Int]()
        var southIndices = [Int]()
        var eastIndices = [Int]()
        var northIndices = [Int]()
        
        var minimumHeight = Double(Int.max)
        var maximumHeight = -minimumHeight
        
        var cartesianVertices = [Float]()
        
        let north = childRectangle.north
        let south = childRectangle.south
        var east = childRectangle.east
        let west = childRectangle.west
        
        if east < west {
            east += Math.TwoPi
        }
        
        var u, v: Int

        for i in 0..<uBuffer.count {
            u = uBuffer[i]
            if u <= minU {
                westIndices.append(i)
                u = 0
            } else if u >= maxU {
                eastIndices.append(i)
                u = maxShort
            } else {
                u = u * 2 + uOffset
            }
            
            uBuffer[i] = u
            
            v = vBuffer[i]
            if v <= minV {
                southIndices.append(i)
                v = 0
            } else if (v >= maxV) {
                northIndices.append(i)
                v = maxShort
            } else {
                v = v * 2 + vOffset
            }
            
            vBuffer[i] = v
            
            let height = Math.lerp(p: parentMinimumHeight, q: parentMaximumHeight, time: heightBuffer[i] / Double(maxShort))
            if height < minimumHeight {
                minimumHeight = height
            }
            if height > maximumHeight {
                maximumHeight = height
            }
            
            heightBuffer[i] = height
            
            let cartesian = ellipsoid.cartographicToCartesian(
                Cartographic(
                    longitude: Math.lerp(p: west, q: east, time: Double(u / maxShort)),
                    latitude:  Math.lerp(p: south, q: north, time: Double(v / maxShort)),
                    height: height
                )
            )
            cartesianVertices.append(contentsOf: (0..<3).map { cartesian.floatRepresentation[$0] })
        }
        
        let boundingSphere = BoundingSphere.fromVertices(cartesianVertices, center: Cartesian3.zero, stride: 3)
        let orientedBoundingBox = OrientedBoundingBox(fromRectangle: childRectangle, minimumHeight: minimumHeight, maximumHeight: maximumHeight, ellipsoid: ellipsoid)
        
        let occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        let horizonOcclusionPoint = occluder.computeHorizonCullingPointFromVertices(directionToPoint: boundingSphere.center, vertices: cartesianVertices, stride: 3, center: boundingSphere.center)!
        
        let heightRange = maximumHeight - minimumHeight

        var vertices = uBuffer.map { UInt16 ($0) }
        vertices.append(contentsOf: vBuffer.map { UInt16($0) })
        vertices.append(contentsOf: heightBuffer.map { UInt16(Double(maxShort) * ($0 - minimumHeight) / heightRange) } )

        return (
            vertices: vertices,
            encodedNormals: normalBuffer,
            indices: indices,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight,
            westIndices: westIndices,
            southIndices: southIndices,
            eastIndices: eastIndices,
            northIndices: northIndices,
            boundingSphere: boundingSphere,
            orientedBoundingBox: orientedBoundingBox,
            horizonOcclusionPoint: horizonOcclusionPoint
        )
    }
    
    fileprivate class func addClippedPolygon (
        _ uBuffer: inout [Int],
        vBuffer: inout [Int],
        heightBuffer: inout [Double],
        normalBuffer: inout [UInt8],
        indices: inout [Int],
        vertexMap: inout [String: Int],
        clipped: [Double],
        triangleVertices: [Vertex],
        hasVertexNormals: Bool)
    {
        var polygonVertices = [Vertex(), Vertex(), Vertex(), Vertex()]
        
        if clipped.count == 0 {
            return
        }
        
        var numVertices = 0
        var clippedIndex = 0
        while clippedIndex < clipped.count {
            clippedIndex = polygonVertices[numVertices].initializeFromClipResult(clipped, index: clippedIndex, vertices: triangleVertices)
            numVertices += 1
        }
        
        for i in 0..<numVertices {
            let polygonVertex = polygonVertices[i]

            if !polygonVertex.isIndexed {
                let key = polygonVertex.getKey()
                if let newIndex = vertexMap[key] {
                    polygonVertex.newIndex = newIndex
                } else {
                    let newIndex = uBuffer.count
                    uBuffer.append(polygonVertex.getU())
                    vBuffer.append(polygonVertex.getV())
                    heightBuffer.append(polygonVertex.getH())
                    if hasVertexNormals {
                        normalBuffer.append(polygonVertex.getNormalX())
                        normalBuffer.append(polygonVertex.getNormalY())
                    }
                    polygonVertex.newIndex = newIndex
                    vertexMap[key] = newIndex
                }
            } else {
                polygonVertex.newIndex = vertexMap["\(polygonVertex.index!)"]
                polygonVertex.uBuffer = uBuffer
                polygonVertex.vBuffer = vBuffer
                polygonVertex.heightBuffer = heightBuffer
                if hasVertexNormals {
                    polygonVertex.normalBuffer = normalBuffer
                }
            }
        }
        
        if numVertices == 3 {
            // A triangle.
            indices.append(polygonVertices[0].newIndex!)
            indices.append(polygonVertices[1].newIndex!)
            indices.append(polygonVertices[2].newIndex!)
        } else if numVertices == 4 {
            // A quad - two triangles.
            indices.append(polygonVertices[0].newIndex!)
            indices.append(polygonVertices[1].newIndex!)
            indices.append(polygonVertices[2].newIndex!)
            
            indices.append(polygonVertices[0].newIndex!)
            indices.append(polygonVertices[2].newIndex!)
            indices.append(polygonVertices[3].newIndex!)
        }
    }

 
}

private class Vertex {
    var vertexBuffer: [Float32]? = nil
    var uBuffer: [Int]? = nil
    var vBuffer: [Int]? = nil
    var heightBuffer: [Double]? = nil
    var normalBuffer: [UInt8]? = nil
    var index: Int? = nil
    var newIndex: Int? = nil
    var first: Vertex? = nil
    var second: Vertex? = nil
    var ratio: Double? = nil
 
    func clone (_ result: Vertex?) -> Vertex {
        
        let result = result ?? Vertex()

        result.uBuffer = self.uBuffer
        result.vBuffer = self.vBuffer
        result.heightBuffer = self.heightBuffer
        result.normalBuffer = self.normalBuffer
        result.index = self.index
        result.first = self.first
        result.second = self.second
        result.ratio = self.ratio
 
        return result
    }

    func initializeIndexed (_ uBuffer: [Int], vBuffer: [Int], heightBuffer: [Double], normalBuffer: [UInt8]?, index: Int) {
        self.uBuffer = uBuffer
        self.vBuffer = vBuffer
        self.heightBuffer = heightBuffer
        self.normalBuffer = normalBuffer
        self.index = index
        self.first = nil
        self.second = nil
        self.ratio = nil
    }
 /*
 Vertex.prototype.initializeInterpolated = function(first, second, ratio) {
 this.vertexBuffer = undefined;
 this.index = undefined;
 this.newIndex = undefined;
 this.first = first;
 this.second = second;
 this.ratio = ratio;
 };
     */
    func initializeFromClipResult (_ clipResult: [Double], index: Int, vertices: [Vertex]) -> Int {
        var nextIndex = index + 1
        
        if (clipResult[index] != -1) {
            vertices[Int(clipResult[index])].clone(self)
        } else {
            vertexBuffer = nil
            self.index = nil
            first = vertices[Int(clipResult[nextIndex])]
            nextIndex += 1
            second = vertices[Int(clipResult[nextIndex])]
            nextIndex += 1
            ratio = clipResult[nextIndex]
            nextIndex += 1
        }
        
        return nextIndex
    }
 
    func getKey () -> String {
        if isIndexed {
            return "\(index)"
        }
        return "first:\(first!.getKey()),second:\(second!.getKey()),ratio:\(ratio)"
    }
 
    var isIndexed: Bool {
        return index != nil
    }

    func getH () -> Double {
        if let index = index {
            return heightBuffer![index]
        }
        return Math.lerp(p: first!.getH(), q: second!.getH(), time: Double(ratio!))
    }
    
    func getU () -> Int {
        if let index = index {
            return uBuffer![index]
        }
        return Int(Math.lerp(p: Double(first!.getU()), q: Double(second!.getU()), time: Double(ratio!)))
    }
 
    func getV () -> Int {
        if let index = index {
            return vBuffer![index]
        }
        return Int(Math.lerp(p: Double(first!.getV()), q: Double(second!.getV()), time: Double(ratio!)))
    }
 
    fileprivate var encodedScratch = Cartesian2()
    // An upsampled triangle may be clipped twice before it is assigned an index
    // In this case, we need a buffer to handle the recursion of getNormalX() and getNormalY().
    fileprivate var depth = -1
    fileprivate var cartesianScratch1 = [Cartesian3(), Cartesian3()]
    fileprivate var cartesianScratch2 = [Cartesian3(), Cartesian3()]
    
    func lerpOctEncodedNormal(_ vertex: Vertex) -> Cartesian2 {
        depth += 1
        // what about scratch variables
        var first = cartesianScratch1[depth]
        var second = cartesianScratch2[depth]
        
        first = AttributeCompression.octDecode(x: vertex.first!.getNormalX(), y: vertex.first!.getNormalY())
        second = AttributeCompression.octDecode(x: vertex.second!.getNormalX(), y: vertex.second!.getNormalY())
        
        depth -= 1
        return AttributeCompression.octEncode(first.lerp(second, t: Double(vertex.ratio!)).normalize())
    }
 
    func getNormalX () -> UInt8 {
        if let index = index {
            return normalBuffer![index * 2]
        }
        return UInt8(lerpOctEncodedNormal(self).x)
    }
    
    func getNormalY () -> UInt8 {
        if let index = index {
            return normalBuffer![index * 2 + 1]
        }
        return UInt8(lerpOctEncodedNormal(self).y)
    }

}
