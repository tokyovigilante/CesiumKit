//
//  QuantizedMeshUpsampler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/03/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

private let halfMaxShort = UInt16((Int16.max / 2) | 0)

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
        minimumHeight: Double,
        maximumHeight: Double,
        isEastChild: Bool,
        isNorthChild: Bool,
        childRectangle: Rectangle,
        ellipsoid: Ellipsoid)
    {
 
        let minU = isEastChild ? halfMaxShort : 0
        let maxU = isEastChild ? UInt16.max : halfMaxShort
        let minV = isNorthChild ? halfMaxShort : 0
        let maxV = isNorthChild ? UInt16.max : halfMaxShort
        let halfMS = halfMaxShort
        var uBuffer = [UInt16]()
        var vBuffer = [UInt16]()
        var heightBuffer = [UInt16]()
        var normalBuffer = [UInt8]()
 
        let indices = [Int]()
 
        var vertexMap = [Int]()
 
        let quantizedVertexCount = parentVertices.count / 3
        let parentUBuffer = parentVertices[0..<quantizedVertexCount]
        let parentVBuffer = parentVertices[quantizedVertexCount..<(2 * quantizedVertexCount)]
        let parentHeightBuffer = parentVertices[(quantizedVertexCount*2)..<(3*quantizedVertexCount)]
 
        var vertexCount = 0
        let hasVertexNormals = parentNormalBuffer != nil
        
        for (i, (u, v)) in zip(parentUBuffer, parentVBuffer).enumerate() {
            
            if (isEastChild && u >= halfMaxShort || !isEastChild && u <= halfMaxShort) &&
                (isNorthChild && v >= halfMaxShort || !isNorthChild && v <= halfMaxShort) {
                
                vertexMap.append(vertexCount)
                uBuffer.append(u)
                vBuffer.append(v)
                heightBuffer.append(parentHeightBuffer[parentHeightBuffer.startIndex+i])
                if hasVertexNormals {
                    normalBuffer.append(parentNormalBuffer![i*2])
                    normalBuffer.append(parentNormalBuffer![i*2+1])
                }
                vertexCount += 1
            }
        }
        
        var triangleVertices = [Vertex](count: 3, repeatedValue: Vertex())
        
        var clippedTriangleVertices = [Vertex](count: 3, repeatedValue: Vertex())
        
        for i in 0.stride(to: parentIndices.count, by: 3) {
            var i0 = parentIndices[i]
            var i1 = parentIndices[i + 1]
            var i2 = parentIndices[i + 2]
            
            var u0 = parentUBuffer[i0]
            var u1 = parentUBuffer[i1]
            var u2 = parentUBuffer[i2]
            
            triangleVertices[0].initializeIndexed(
                uBuffer: Array<UInt16>(parentUBuffer),
                vBuffer: Array<UInt16>(parentVBuffer),
                heightBuffer: Array<UInt16>(parentHeightBuffer),
                normalBuffer: parentNormalBuffer != nil ? Array<UInt8>(parentNormalBuffer!) : nil,
                index: i0
            )
            triangleVertices[1].initializeIndexed(
                uBuffer: Array<UInt16>(parentUBuffer),
                vBuffer: Array<UInt16>(parentVBuffer),
                heightBuffer: Array<UInt16>(parentHeightBuffer),
                normalBuffer: parentNormalBuffer != nil ? Array<UInt8>(parentNormalBuffer!) : nil,
                index: i1
            )
            triangleVertices[2].initializeIndexed(
                uBuffer: Array<UInt16>(parentUBuffer),
                vBuffer: Array<UInt16>(parentVBuffer),
                heightBuffer: Array<UInt16>(parentHeightBuffer),
                normalBuffer: parentNormalBuffer != nil ? Array<UInt8>(parentNormalBuffer!) : nil,
                index: i2
            )
            
            // Clip triangle on the east-west boundary.
            let clipped = Intersections2D.clipTriangleAtAxisAlignedThreshold(threshold: halfMaxShort, keepAbove: isEastChild, u0: u0, u1: u1, u2: u2)
            
            // Get the first clipped triangle, if any.
            var clippedIndex = 0
            
            if clippedIndex >= clipped.count {
                continue
            }
            clippedIndex = clippedTriangleVertices[0].initializeFromClipResult(clipResult: clipped, index: clippedIndex, vertices: triangleVertices)
            
            if clippedIndex >= clipped.count {
                continue
            }
            clippedIndex = clippedTriangleVertices[1].initializeFromClipResult(clipResult: clipped, index: clippedIndex, vertices: triangleVertices)
            
            if clippedIndex >= clipped.count {
                continue
            }
            clippedIndex = clippedTriangleVertices[2].initializeFromClipResult(clipResult: clipped, index: clippedIndex, vertices: triangleVertices)
            
            // Clip the triangle against the North-south boundary.
            let clipped2 = Intersections2D.clipTriangleAtAxisAlignedThreshold(threshold: halfMaxShort, keepAbove: isNorthChild, u0: clippedTriangleVertices[0].getV(), u1: clippedTriangleVertices[1].getV(), u2: clippedTriangleVertices[2].getV())
            /*
            addClippedPolygon(uBuffer, vBuffer, heightBuffer, normalBuffer, indices, vertexMap, clipped2, clippedTriangleVertices, hasVertexNormals);
            
            // If there's another vertex in the original clipped result,
            // it forms a second triangle.  Clip it as well.
            if (clippedIndex < clipped.length) {
                clippedTriangleVertices[2].clone(clippedTriangleVertices[1]);
                clippedTriangleVertices[2].initializeFromClipResult(clipped, clippedIndex, triangleVertices);
                
                clipped2 = Intersections2D.clipTriangleAtAxisAlignedThreshold(halfMaxShort, isNorthChild, clippedTriangleVertices[0].getV(), clippedTriangleVertices[1].getV(), clippedTriangleVertices[2].getV(), clipScratch2);
                addClippedPolygon(uBuffer, vBuffer, heightBuffer, normalBuffer, indices, vertexMap, clipped2, clippedTriangleVertices, hasVertexNormals);
            }*/
        }
        /*
        var uOffset = isEastChild ? -maxShort : 0;
        var vOffset = isNorthChild ? -maxShort : 0;
        
        var parentMinimumHeight = parameters.minimumHeight;
        var parentMaximumHeight = parameters.maximumHeight;
        
        var westIndices = [];
        var southIndices = [];
        var eastIndices = [];
        var northIndices = [];
        
        var minimumHeight = Number.MAX_VALUE;
        var maximumHeight = -minimumHeight;
        
        var cartesianVertices = verticesScratch;
        cartesianVertices.length = 0;
        
        var ellipsoid = Ellipsoid.clone(parameters.ellipsoid);
        var rectangle = parameters.childRectangle;
        
        var north = rectangle.north;
        var south = rectangle.south;
        var east = rectangle.east;
        var west = rectangle.west;
        
        if (east < west) {
            east += CesiumMath.TWO_PI;
        }
        
        for (i = 0; i < uBuffer.length; ++i) {
            u = Math.round(uBuffer[i]);
            if (u <= minU) {
                westIndices.push(i);
                u = 0;
            } else if (u >= maxU) {
                eastIndices.push(i);
                u = maxShort;
            } else {
                u = u * 2 + uOffset;
            }
            
            uBuffer[i] = u;
            
            v = Math.round(vBuffer[i]);
            if (v <= minV) {
                southIndices.push(i);
                v = 0;
            } else if (v >= maxV) {
                northIndices.push(i);
                v = maxShort;
            } else {
                v = v * 2 + vOffset;
            }
            
            vBuffer[i] = v;
            
            var height = CesiumMath.lerp(parentMinimumHeight, parentMaximumHeight, heightBuffer[i] / maxShort);
            if (height < minimumHeight) {
                minimumHeight = height;
            }
            if (height > maximumHeight) {
                maximumHeight = height;
            }
            
            heightBuffer[i] = height;
            
            cartographicScratch.longitude = CesiumMath.lerp(west, east, u / maxShort);
            cartographicScratch.latitude = CesiumMath.lerp(south, north, v / maxShort);
            cartographicScratch.height = height;
            
            ellipsoid.cartographicToCartesian(cartographicScratch, cartesian3Scratch);
            
            cartesianVertices.push(cartesian3Scratch.x);
            cartesianVertices.push(cartesian3Scratch.y);
            cartesianVertices.push(cartesian3Scratch.z);
        }
        
        var boundingSphere = BoundingSphere.fromVertices(cartesianVertices, Cartesian3.ZERO, 3, boundingSphereScratch);
        var orientedBoundingBox = OrientedBoundingBox.fromRectangle(rectangle, minimumHeight, maximumHeight, ellipsoid, orientedBoundingBoxScratch);
        
        var occluder = new EllipsoidalOccluder(ellipsoid);
        var horizonOcclusionPoint = occluder.computeHorizonCullingPointFromVertices(boundingSphere.center, cartesianVertices, 3, boundingSphere.center, horizonOcclusionPointScratch);
        
        var heightRange = maximumHeight - minimumHeight;
        
        var vertices = new Uint16Array(uBuffer.length + vBuffer.length + heightBuffer.length);
        
        for (i = 0; i < uBuffer.length; ++i) {
            vertices[i] = uBuffer[i];
        }
        
        var start = uBuffer.length;
        
        for (i = 0; i < vBuffer.length; ++i) {
            vertices[start + i] = vBuffer[i];
        }
        
        start += vBuffer.length;
        
        for (i = 0; i < heightBuffer.length; ++i) {
            vertices[start + i] = maxShort * (heightBuffer[i] - minimumHeight) / heightRange;
        }
        
        var indicesTypedArray = IndexDatatype.createTypedArray(uBuffer.length, indices);
        
        var encodedNormals;
        if (hasVertexNormals) {
            var normalArray = new Uint8Array(normalBuffer);
            transferableObjects.push(vertices.buffer, indicesTypedArray.buffer, normalArray.buffer);
            encodedNormals = normalArray.buffer;
        } else {
            transferableObjects.push(vertices.buffer, indicesTypedArray.buffer);
        }
        
        return {
            vertices : vertices.buffer,
            encodedNormals : encodedNormals,
            indices : indicesTypedArray.buffer,
            minimumHeight : minimumHeight,
            maximumHeight : maximumHeight,
            westIndices : westIndices,
            southIndices : southIndices,
            eastIndices : eastIndices,
            northIndices : northIndices,
            boundingSphere : boundingSphere,
            orientedBoundingBox : orientedBoundingBox,
            horizonOcclusionPoint : horizonOcclusionPoint
        }*/
    }
 
}

private class Vertex {
    var vertexBuffer: [Float32]? = nil
    var uBuffer: [UInt16]? = nil
    var vBuffer: [UInt16]? = nil
    var heightBuffer: [UInt16]? = nil
    var normalBuffer: [UInt8]? = nil
    var index: Int? = nil
    var first: Vertex? = nil
    var second: Vertex? = nil
    var ratio: Float? = nil
 
    func clone (result: Vertex?) -> Vertex {
        
        var result = result ?? Vertex()

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

    func initializeIndexed (uBuffer uBuffer: [UInt16], vBuffer: [UInt16], heightBuffer: [UInt16], normalBuffer: [UInt8]?, index: Int) {
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
    func initializeFromClipResult (clipResult clipResult: [Float], index: Int, vertices: [Vertex]) -> Int {
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
 /*
 Vertex.prototype.getKey = function() {
 if (this.isIndexed()) {
 return this.index;
 }
 return JSON.stringify({
 first : this.first.getKey(),
 second : this.second.getKey(),
 ratio : this.ratio
 });
 };
 
 Vertex.prototype.isIndexed = function() {
 return defined(this.index);
 };
 
 Vertex.prototype.getH = function() {
 if (defined(this.index)) {
 return this.heightBuffer[this.index];
 }
 return CesiumMath.lerp(this.first.getH(), this.second.getH(), this.ratio);
 };
 
 Vertex.prototype.getU = function() {
 if (defined(this.index)) {
 return this.uBuffer[this.index];
 }
 return CesiumMath.lerp(this.first.getU(), this.second.getU(), this.ratio);
 };
 */
    func getV () -> UInt16 {
        if let index = index {
            return vBuffer![index]
        }
        return UInt16(Math.lerp(p: Double(first!.getV()), q: Double(second!.getV()), time: Double(ratio!)))
    }
 /*
 var encodedScratch = new Cartesian2();
 // An upsampled triangle may be clipped twice before it is assigned an index
 // In this case, we need a buffer to handle the recursion of getNormalX() and getNormalY().
 var depth = -1;
 var cartesianScratch1 = [new Cartesian3(), new Cartesian3()];
 var cartesianScratch2 = [new Cartesian3(), new Cartesian3()];
 function lerpOctEncodedNormal(vertex, result) {
 ++depth;
 
 var first = cartesianScratch1[depth];
 var second = cartesianScratch2[depth];
 
 first = AttributeCompression.octDecode(vertex.first.getNormalX(), vertex.first.getNormalY(), first);
 second = AttributeCompression.octDecode(vertex.second.getNormalX(), vertex.second.getNormalY(), second);
 cartesian3Scratch = Cartesian3.lerp(first, second, vertex.ratio, cartesian3Scratch);
 Cartesian3.normalize(cartesian3Scratch, cartesian3Scratch);
 
 AttributeCompression.octEncode(cartesian3Scratch, result);
 
 --depth;
 
 return result;
 }
 
 Vertex.prototype.getNormalX = function() {
 if (defined(this.index)) {
 return this.normalBuffer[this.index * 2];
 }
 
 encodedScratch = lerpOctEncodedNormal(this, encodedScratch);
 return encodedScratch.x;
 };
 
 Vertex.prototype.getNormalY = function() {
 if (defined(this.index)) {
 return this.normalBuffer[this.index * 2 + 1];
 }
 
 encodedScratch = lerpOctEncodedNormal(this, encodedScratch);
 return encodedScratch.y;
 };
 
 var polygonVertices = [];
 polygonVertices.push(new Vertex());
 polygonVertices.push(new Vertex());
 polygonVertices.push(new Vertex());
 polygonVertices.push(new Vertex());
 
 function addClippedPolygon(uBuffer, vBuffer, heightBuffer, normalBuffer, indices, vertexMap, clipped, triangleVertices, hasVertexNormals) {
 if (clipped.length === 0) {
 return;
 }
 
 var numVertices = 0;
 var clippedIndex = 0;
 while (clippedIndex < clipped.length) {
 clippedIndex = polygonVertices[numVertices++].initializeFromClipResult(clipped, clippedIndex, triangleVertices);
 }
 
 for (var i = 0; i < numVertices; ++i) {
 var polygonVertex = polygonVertices[i];
 if (!polygonVertex.isIndexed()) {
 var key = polygonVertex.getKey();
 if (defined(vertexMap[key])) {
 polygonVertex.newIndex = vertexMap[key];
 } else {
 var newIndex = uBuffer.length;
 uBuffer.push(polygonVertex.getU());
 vBuffer.push(polygonVertex.getV());
 heightBuffer.push(polygonVertex.getH());
 if (hasVertexNormals) {
 normalBuffer.push(polygonVertex.getNormalX());
 normalBuffer.push(polygonVertex.getNormalY());
 }
 polygonVertex.newIndex = newIndex;
 vertexMap[key] = newIndex;
 }
 } else {
 polygonVertex.newIndex = vertexMap[polygonVertex.index];
 polygonVertex.uBuffer = uBuffer;
 polygonVertex.vBuffer = vBuffer;
 polygonVertex.heightBuffer = heightBuffer;
 if (hasVertexNormals) {
 polygonVertex.normalBuffer = normalBuffer;
 }
 }
 }
 
 if (numVertices === 3) {
 // A triangle.
 indices.push(polygonVertices[0].newIndex);
 indices.push(polygonVertices[1].newIndex);
 indices.push(polygonVertices[2].newIndex);
 } else if (numVertices === 4) {
 // A quad - two triangles.
 indices.push(polygonVertices[0].newIndex);
 indices.push(polygonVertices[1].newIndex);
 indices.push(polygonVertices[2].newIndex);
 
 indices.push(polygonVertices[0].newIndex);
 indices.push(polygonVertices[2].newIndex);
 indices.push(polygonVertices[3].newIndex);
 }
 }
 
 return createTaskProcessorWorker(upsampleQuantizedTerrainMesh);
 });

 */
}