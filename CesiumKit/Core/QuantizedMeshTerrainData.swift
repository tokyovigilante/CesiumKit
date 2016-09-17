    //
//  QuantizedMeshTerrainData.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

private let maxShort = Double(Int16.max)

/**
 * Terrain data for a single tile where the terrain data is represented as a quantized mesh.  A quantized
 * mesh consists of three vertex attributes, longitude, latitude, and height.  All attributes are expressed
 * as 16-bit values in the range 0 to 32767.  Longitude and latitude are zero at the southwest corner
 * of the tile and 32767 at the northeast corner.  Height is zero at the minimum height in the tile
 * and 32767 at the maximum height in the tile.
 *
 * @alias QuantizedMeshTerrainData
 * @constructor
 *
 * @param {Object} options Object with the following properties:
 * @param {Uint16Array} options.quantizedVertices The buffer containing the quantized mesh.
 * @param {Uint16Array|Uint32Array} options.indices The indices specifying how the quantized vertices are linked
 *                      together into triangles.  Each three indices specifies one triangle.
 * @param {Number} options.minimumHeight The minimum terrain height within the tile, in meters above the ellipsoid.
 * @param {Number} options.maximumHeight The maximum terrain height within the tile, in meters above the ellipsoid.
 * @param {BoundingSphere} options.boundingSphere A sphere bounding all of the vertices in the mesh.
 * @param {OrientedBoundingBox} [options.orientedBoundingBox] An OrientedBoundingBox bounding all of the vertices in the mesh.
 * @param {Cartesian3} options.horizonOcclusionPoint The horizon occlusion point of the mesh.  If this point
 *                      is below the horizon, the entire tile is assumed to be below the horizon as well.
 *                      The point is expressed in ellipsoid-scaled coordinates.
 * @param {Number[]} options.westIndices The indices of the vertices on the western edge of the tile.
 * @param {Number[]} options.southIndices The indices of the vertices on the southern edge of the tile.
 * @param {Number[]} options.eastIndices The indices of the vertices on the eastern edge of the tile.
 * @param {Number[]} options.northIndices The indices of the vertices on the northern edge of the tile.
 * @param {Number} options.westSkirtHeight The height of the skirt to add on the western edge of the tile.
 * @param {Number} options.southSkirtHeight The height of the skirt to add on the southern edge of the tile.
 * @param {Number} options.eastSkirtHeight The height of the skirt to add on the eastern edge of the tile.
 * @param {Number} options.northSkirtHeight The height of the skirt to add on the northern edge of the tile.
 * @param {Number} [options.childTileMask=15] A bit mask indicating which of this tile's four children exist.
 *                 If a child's bit is set, geometry will be requested for that tile as well when it
 *                 is needed.  If the bit is cleared, the child tile is not requested and geometry is
 *                 instead upsampled from the parent.  The bit values are as follows:
 *                 <table>
 *                  <tr><th>Bit Position</th><th>Bit Value</th><th>Child Tile</th></tr>
 *                  <tr><td>0</td><td>1</td><td>Southwest</td></tr>
 *                  <tr><td>1</td><td>2</td><td>Southeast</td></tr>
 *                  <tr><td>2</td><td>4</td><td>Northwest</td></tr>
 *                  <tr><td>3</td><td>8</td><td>Northeast</td></tr>
 *                 </table>
 * @param {Boolean} [options.createdByUpsampling=false] True if this instance was created by upsampling another instance;
 *                  otherwise, false.
 * @param {Uint8Array} [options.encodedNormals] The buffer containing per vertex normals, encoded using 'oct' encoding
 * @param {Uint8Array} [options.waterMask] The buffer containing the watermask.
 *
 * @see TerrainData
 * @see HeightmapTerrainData
 *
 * @example
 * var data = new Cesium.QuantizedMeshTerrainData({
 *     minimumHeight : -100,
 *     maximumHeight : 2101,
 *     quantizedVertices : new Uint16Array([// order is SW NW SE NE
 *                                          // longitude
 *                                          0, 0, 32767, 32767,
 *                                          // latitude
 *                                          0, 32767, 0, 32767,
 *                                          // heights
 *                                          16384, 0, 32767, 16384]),
 *     indices : new Uint16Array([0, 3, 1,
 *                                0, 2, 3]),
 *     boundingSphere : new Cesium.BoundingSphere(new Cesium.Cartesian3(1.0, 2.0, 3.0), 10000),
 *     orientedBoundingBox : new Cesium.OrientedBoundingBox(new Cesium.Cartesian3(1.0, 2.0, 3.0), Cesium.Matrix3.fromRotationX(Cesium.Math.PI, new Cesium.Matrix3())),
 *     horizonOcclusionPoint : new Cesium.Cartesian3(3.0, 2.0, 1.0),
 *     westIndices : [0, 1],
 *     southIndices : [0, 1],
 *     eastIndices : [2, 3],
 *     northIndices : [1, 3],
 *     westSkirtHeight : 1.0,
 *     southSkirtHeight : 1.0,
 *     eastSkirtHeight : 1.0,
 *     northSkirtHeight : 1.0
 * });
 */
class QuantizedMeshTerrainData: TerrainData {
    
    fileprivate var _quantizedVertices: [UInt16]!
    
    fileprivate var _uValues: ArraySlice<UInt16>!
    
    fileprivate var _vValues: ArraySlice<UInt16>!
    
    fileprivate var _heightValues: ArraySlice<UInt16>!
    
    fileprivate var _encodedNormals: [UInt8]?
    
    fileprivate var _indices: [Int]!
    
    fileprivate let _minimumHeight: Double
    
    fileprivate let _maximumHeight: Double
    
    fileprivate let _boundingSphere: BoundingSphere
    
    fileprivate let _orientedBoundingBox: OrientedBoundingBox?
    
    fileprivate let _horizonOcclusionPoint: Cartesian3
    
    fileprivate var _westIndices: [Int]! = nil
    fileprivate var _southIndices: [Int]! = nil
    fileprivate var _eastIndices: [Int]! = nil
    fileprivate var _northIndices: [Int]! = nil
    
    fileprivate let _westSkirtHeight: Double
    fileprivate let _southSkirtHeight: Double
    fileprivate let _eastSkirtHeight: Double
    fileprivate let _northSkirtHeight: Double
    
    fileprivate var _mesh: TerrainMesh? = nil
    
    /**
     * The water mask included in this terrain data, if any.  A water mask is a rectangular
     * Uint8Array or image where a value of 255 indicates water and a value of 0 indicates land.
     * Values in between 0 and 255 are allowed as well to smoothly blend between land and water.
     * @memberof QuantizedMeshTerrainData.prototype
     * @type {Uint8Array|Image|Canvas}
     */
    let waterMask: [UInt8]?
    
    /**
     * Gets a value indicating whether or not this terrain data was created by upsampling lower resolution
     * terrain data.  If this value is false, the data was obtained from some other source, such
     * as by downloading it from a remote server.  This method should return true for instances
     * returned from a call to {@link HeightmapTerrainData#upsample}.
     *
     * @returns {Boolean} True if this instance was created by upsampling; otherwise, false.
     */
    let createdByUpsampling: Bool
    
    var childTileMask: Int
    
    init (
        quantizedVertices: [UInt16],
        indices: [Int],
        encodedNormals: [UInt8]?,
        minimumHeight: Double,
        maximumHeight: Double,
        boundingSphere: BoundingSphere,
        orientedBoundingBox: OrientedBoundingBox?,
        horizonOcclusionPoint: Cartesian3,
        westIndices: [Int],
        southIndices: [Int],
        eastIndices: [Int],
        northIndices: [Int],
        westSkirtHeight: Double,
        southSkirtHeight: Double,
        eastSkirtHeight: Double,
        northSkirtHeight: Double,
        childTileMask: Int = 15,
        waterMask: [UInt8]? = nil,
        createdByUpsampling: Bool = false)
    {
        _quantizedVertices = quantizedVertices
        _encodedNormals = encodedNormals
        _indices = indices
        _minimumHeight = minimumHeight
        _maximumHeight = maximumHeight
        _boundingSphere = boundingSphere
        _orientedBoundingBox = orientedBoundingBox
        _horizonOcclusionPoint = horizonOcclusionPoint
        
        let vertexCount = _quantizedVertices.count / 3
        _uValues = _quantizedVertices[0..<vertexCount]
        _vValues = _quantizedVertices[vertexCount..<(vertexCount * 2)]
        _heightValues = _quantizedVertices[(vertexCount * 2)..<(vertexCount * 3)]
        
        _westSkirtHeight = westSkirtHeight
        _southSkirtHeight = southSkirtHeight
        _eastSkirtHeight = eastSkirtHeight
        _northSkirtHeight = northSkirtHeight
        
        self.childTileMask = childTileMask
        
        self.createdByUpsampling = createdByUpsampling
        self.waterMask = waterMask
        
        // We don't assume that we can count on the edge vertices being sorted by u or v.
        let sortByV = { (a: Int, b: Int) -> Bool in
            let startIndex = self._vValues.startIndex
            return Int(self._vValues[startIndex + a]) - Int(self._vValues[startIndex + b]) <= 0
        }
        
        let sortByU = { (a: Int, b: Int) -> Bool in
            let startIndex = self._uValues.startIndex
            return Int(self._uValues[startIndex + a]) - Int(self._uValues[startIndex + b]) <= 0
        }
        
        _westIndices = sortIndicesIfNecessary(westIndices, sortFunction: sortByV, vertexCount: vertexCount)
        _southIndices = sortIndicesIfNecessary(southIndices, sortFunction: sortByU, vertexCount: vertexCount)
        _eastIndices = sortIndicesIfNecessary(eastIndices, sortFunction: sortByV, vertexCount: vertexCount)
        _northIndices = sortIndicesIfNecessary(northIndices, sortFunction: sortByU, vertexCount: vertexCount)
    }
    
    func sortIndicesIfNecessary(_ indices: [Int], sortFunction: (_ a: Int, _ b: Int) -> Bool, vertexCount: Int) -> [Int] {

        var needsSort = false
        for (i, index) in indices.enumerated() {
            needsSort = needsSort || (i > 0 && !sortFunction(indices[i - 1], index))
            if needsSort {
                break
            }
        }
        if needsSort {
            return indices.sorted(isOrderedBefore: sortFunction)
        }
        return indices
    }
    
    

/*
 var createMeshTaskProcessor = new TaskProcessor('createVerticesFromQuantizedTerrainMesh');
 */
 /**
 * Creates a {@link TerrainMesh} from this terrain data.
 *
 * @param {TilingScheme} tilingScheme The tiling scheme to which this tile belongs.
 * @param {Number} x The X coordinate of the tile for which to create the terrain data.
 * @param {Number} y The Y coordinate of the tile for which to create the terrain data.
 * @param {Number} level The level of the tile for which to create the terrain data.
 * @param {Number} [exaggeration=1.0] The scale used to exaggerate the terrain.
 * @returns {Promise.<TerrainMesh>|undefined} A promise for the terrain mesh, or undefined if too many
 *          asynchronous mesh creations are already in progress and the operation should
 *          be retried later.
 */
    func createMesh(_ tilingScheme: TilingScheme, x: Int, y: Int, level: Int, exaggeration: Double = 1.0, completionBlock: (TerrainMesh?) -> ()) -> Bool
    {
        let result = QuantizedMeshTerrainGenerator.computeMesh(
            minimumHeight: _minimumHeight,
            maximumHeight: _maximumHeight,
            quantizedVertices: _quantizedVertices,
            octEncodedNormals: _encodedNormals,
            indices: _indices,
            westIndices: _westIndices,
            southIndices: _southIndices,
            eastIndices: _eastIndices,
            northIndices: _northIndices,
            westSkirtHeight: _westSkirtHeight,
            southSkirtHeight : _southSkirtHeight,
            eastSkirtHeight : _eastSkirtHeight,
            northSkirtHeight : _northSkirtHeight,
            rectangle : tilingScheme.tileXYToRectangle(x: x, y: y, level: level),
            relativeToCenter : _boundingSphere.center,
            ellipsoid : tilingScheme.ellipsoid,
            exaggeration: exaggeration
        )
 
        _mesh = TerrainMesh(
            center: result.center,
            vertices: result.vertices,
            indices: result.indices,
            minimumHeight: result.minimumHeight,
            maximumHeight: result.maximumHeight,
            boundingSphere3D: result.boundingSphere ?? _boundingSphere,
            occludeePointInScaledSpace: result.occludeePointInScaledSpace ?? _horizonOcclusionPoint,
            vertexStride: result.vertexStride,
            orientedBoundingBox: result.orientedBoundingBox,
            encoding: result.encoding,
            exaggeration: exaggeration
        )
        
        //Free memory received from server after mesh is created.
        
        _quantizedVertices = nil
        _encodedNormals = nil
        _indices = nil
        
        _uValues = nil
        _vValues = nil
        _heightValues = nil
        
        _westIndices = nil
        _southIndices = nil
        _eastIndices = nil
        _northIndices = nil
        completionBlock(_mesh!)
        return true
    }
 /*
 var upsampleTaskProcessor = new TaskProcessor('upsampleQuantizedTerrainMesh');
 */
 /**
 * Upsamples this terrain data for use by a descendant tile.  The resulting instance will contain a subset of the
 * vertices in this instance, interpolated if necessary.
 *
 * @param {TilingScheme} tilingScheme The tiling scheme of this terrain data.
 * @param {Number} thisX The X coordinate of this tile in the tiling scheme.
 * @param {Number} thisY The Y coordinate of this tile in the tiling scheme.
 * @param {Number} thisLevel The level of this tile in the tiling scheme.
 * @param {Number} descendantX The X coordinate within the tiling scheme of the descendant tile for which we are upsampling.
 * @param {Number} descendantY The Y coordinate within the tiling scheme of the descendant tile for which we are upsampling.
 * @param {Number} descendantLevel The level within the tiling scheme of the descendant tile for which we are upsampling.
 * @returns {Promise.<QuantizedMeshTerrainData>|undefined} A promise for upsampled heightmap terrain data for the descendant tile,
 *          or undefined if too many asynchronous upsample operations are in progress and the request has been
 *          deferred.
 */
    func upsample(_ tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int, completionBlock: (TerrainData?) -> ()) -> Bool {
        
        let levelDifference = descendantLevel - thisLevel
        if levelDifference > 1 {
            assertionFailure("Upsampling through more than one level at a time is not currently supported")
            completionBlock(nil)
        }
        
        if _mesh != nil {
            completionBlock(nil)
            return false
        }
        
        let isEastChild = thisX * 2 != descendantX
        let isNorthChild = thisY * 2 == descendantY
        
        let ellipsoid = tilingScheme.ellipsoid
        let childRectangle = tilingScheme.tileXYToRectangle(x: descendantX, y: descendantY, level: descendantLevel)
        
        let upsampledMesh = QuantizedMeshUpsampler.upsampleQuantizedTerrainMesh(
            vertices: _quantizedVertices,
            indices: _indices,
            encodedNormals: _encodedNormals,
            minimumHeight: _minimumHeight,
            maximumHeight: _maximumHeight,
            isEastChild: isEastChild,
            isNorthChild: isNorthChild,
            childRectangle: childRectangle,
            ellipsoid: ellipsoid)

        let shortestSkirt = min(_westSkirtHeight, _eastSkirtHeight, _northSkirtHeight, _southSkirtHeight)
        
        let westSkirtHeight = isEastChild ? shortestSkirt * 0.5 : _westSkirtHeight
        let southSkirtHeight = isNorthChild ? shortestSkirt * 0.5 : _southSkirtHeight
        let eastSkirtHeight = isEastChild ? _eastSkirtHeight : shortestSkirt * 0.5
        let northSkirtHeight = isNorthChild ? _northSkirtHeight : shortestSkirt * 0.5
        
        let data = QuantizedMeshTerrainData(
            quantizedVertices : upsampledMesh.vertices,
            indices: upsampledMesh.indices,
            encodedNormals: upsampledMesh.encodedNormals,
            minimumHeight: upsampledMesh.minimumHeight,
            maximumHeight: upsampledMesh.maximumHeight,
            boundingSphere: upsampledMesh.boundingSphere,
            orientedBoundingBox: upsampledMesh.orientedBoundingBox,
            horizonOcclusionPoint: upsampledMesh.horizonOcclusionPoint,
            westIndices: upsampledMesh.westIndices,
            southIndices: upsampledMesh.southIndices,
            eastIndices: upsampledMesh.eastIndices,
            northIndices: upsampledMesh.northIndices,
            westSkirtHeight: westSkirtHeight,
            southSkirtHeight: southSkirtHeight,
            eastSkirtHeight: eastSkirtHeight,
            northSkirtHeight: northSkirtHeight,
            childTileMask: 0,
            createdByUpsampling: true
        )
        
        completionBlock(data)
        return true
    }
    /**
     * Computes the terrain height at a specified longitude and latitude.
     *
     * @param {Rectangle} rectangle The rectangle covered by this terrain data.
     * @param {Number} longitude The longitude in radians.
     * @param {Number} latitude The latitude in radians.
     * @returns {Number} The terrain height at the specified position.  The position is clamped to
     *          the rectangle, so expect incorrect results for positions far outside the rectangle.
     */
    func interpolateHeight (_ rectangle: Rectangle, longitude: Double, latitude: Double) -> Double? {
        let u = Math.clamp((longitude - rectangle.west) / rectangle.width, min: 0.0, max: 1.0) * maxShort
        let v = Math.clamp((latitude - rectangle.south) / rectangle.height, min: 0.0, max: 1.0) * maxShort
        
        if _mesh != nil {
            return interpolateMeshHeight(u, v: v)
        }
        return interpolateHeight(u, v: v)
    }
    
    fileprivate func interpolateMeshHeight (_ u: Double, v: Double) -> Double? {

        guard let mesh = _mesh else {
            assertionFailure("mesh should exist")
            return Double.nan
        }
        let vertices = mesh.vertices
        let encoding = mesh.encoding
        let indices = mesh.indices
        
        for i in stride(from: 0, to: indices.count, by: 3) {
            let i0 = indices[i]
            let i1 = indices[i + 1]
            let i2 = indices[i + 2]
            
            let uv0 = encoding.decodeTextureCoordinates(vertices, index: i0)
            let uv1 = encoding.decodeTextureCoordinates(vertices, index: i1)
            let uv2 = encoding.decodeTextureCoordinates(vertices, index: i2)
            
            let barycentric = Intersections2D.computeBarycentricCoordinates(x: u, y: v, x1: uv0.x, y1: uv0.y, x2: uv1.x, y2: uv1.y, x3: uv2.x, y3: uv2.y)
            if barycentric.x >= -1e-15 && barycentric.y >= -1e-15 && barycentric.z >= -1e-15 {
                let h0 = encoding.decodeHeight(vertices, index: i0)
                let h1 = encoding.decodeHeight(vertices, index: i1)
                let h2 = encoding.decodeHeight(vertices, index: i2)
                return barycentric.x * h0 + barycentric.y * h1 + barycentric.z * h2
            }
        }
        // Position does not lie in any triangle in this mesh.
        return nil
    }
    
    fileprivate func interpolateHeight (_ u: Double, v: Double) -> Double? {

        for i in stride(from: 0, to: _indices.count, by: 3) {
            let i0 = _indices[i]
            let i1 = _indices[i + 1]
            let i2 = _indices[i + 2]
            
            let u0 = Double(_uValues[i0])
            let u1 = Double(_uValues[i1])
            let u2 = Double(_uValues[i2])
            
            let v0 = Double(_vValues[i0])
            let v1 = Double(_vValues[i1])
            let v2 = Double(_vValues[i2])
            
            var barycentric = Intersections2D.computeBarycentricCoordinates(x: u, y: v, x1: u0, y1: v0, x2: u1, y2: v1, x3: u2, y3: v2)
            if barycentric.x >= -1e-15 && barycentric.y >= -1e-15 && barycentric.z >= -1e-15 {
                let quantizedHeight = barycentric.x * Double(_heightValues[i0]) +
                    barycentric.y * Double(_heightValues[i1]) +
                    barycentric.z * Double(_heightValues[i2])
                return Math.lerp(p: _minimumHeight, q: _maximumHeight, time: quantizedHeight / maxShort)
            }
        }
        // Position does not lie in any triangle in this mesh.
        return nil
    }
}
