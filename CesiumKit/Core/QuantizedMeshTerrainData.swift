    //
//  QuantizedMeshTerrainData.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

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
    
    private let _quantizedVertices: [UInt16]
    
    private let _uValues: ArraySlice<UInt16>
    
    private let _vValues: ArraySlice<UInt16>
    
    private let _heightValues: ArraySlice<UInt16>
    
    private let _encodedNormals: [UInt8]?
    
    private let _indices: [Int]
    
    private let _minimumHeight: Double
    
    private let _maximumHeight: Double
    
    private let _boundingSphere: BoundingSphere
    
    private let _orientedBoundingBox: OrientedBoundingBox?
    
    private let _horizonOcclusionPoint: Cartesian3
    
    private var _westIndices: [Int]! = nil
    private var _southIndices: [Int]! = nil
    private var _eastIndices: [Int]! = nil
    private var _northIndices: [Int]! = nil
    
    private let _westSkirtHeight: Double
    private let _southSkirtHeight: Double
    private let _eastSkirtHeight: Double
    private let _northSkirtHeight: Double
    
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
        center: Cartesian3,
        minimumHeight: Double,
        maximumHeight: Double,
        boundingSphere: BoundingSphere,
        orientedBoundingBox: OrientedBoundingBox?,
        horizonOcclusionPoint: Cartesian3,
        quantizedVertices: [UInt16],
        encodedNormals: [UInt8]?,
        indices: [Int],
        westIndices: [Int],
        southIndices: [Int],
        eastIndices: [Int],
        northIndices: [Int],
        westSkirtHeight: Double,
        southSkirtHeight: Double,
        eastSkirtHeight: Double,
        northSkirtHeight: Double,
        childTileMask: Int = 15,
        waterMask: [UInt8]?,
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
    
    func sortIndicesIfNecessary(indices: [Int], sortFunction: (a: Int, b: Int) -> Bool, vertexCount: Int) -> [Int] {

        var needsSort = false
        for (i, index) in indices.enumerate() {
            needsSort = needsSort || (i > 0 && !sortFunction(a: indices[i - 1], b: index))
            if needsSort {
                break
            }
        }
        if needsSort {
            return indices.sort(sortFunction)
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
    func createMesh(tilingScheme tilingScheme: TilingScheme, x: Int, y: Int, level: Int, exaggeration: Double = 1.0, completionBlock: (TerrainMesh?) -> ())
    {
  
        let mesh = QuantizedMeshTerrainGenerator.computeMesh(
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
 
        //let vertexCount = _quantizedVertices.count / 3  + _westIndices.count + _southIndices.count + _eastIndices.count + _northIndices.count
        
        //var rtc = result.center;
        //var minimumHeight = result.minimumHeight;
        //var maximumHeight = result.maximumHeight;
        //var boundingSphere = defaultValue(result.boundingSphere, that._boundingSphere);
        //var obb = defaultValue(result.orientedBoundingBox, _orientedBoundingBox);
        //var occlusionPoint = defaultValue(result.occludeePointInScaledSpace, that._horizonOcclusionPoint);
        //var stride = result.vertexStride;
 
        let terrainMesh = TerrainMesh(
            center: mesh.center,
            vertices: mesh.vertices,
            indices: mesh.indices,
            minimumHeight: mesh.minimumHeight,
            maximumHeight: mesh.maximumHeight,
            boundingSphere3D: mesh.boundingSphere ?? _boundingSphere,
            occludeePointInScaledSpace: mesh.occludeePointInScaledSpace ?? _horizonOcclusionPoint,
            vertexStride: mesh.vertexStride,
            orientedBoundingBox: mesh.orientedBoundingBox)
        completionBlock(terrainMesh)
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
    func upsample(tilingScheme tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int, completionBlock: (TerrainData?) -> ()?) {
        /*
//>>includeStart('debug', pragmas.debug);
 if (!defined(tilingScheme)) {
 throw new DeveloperError('tilingScheme is required.');
 }
 if (!defined(thisX)) {
 throw new DeveloperError('thisX is required.');
 }
 if (!defined(thisY)) {
 throw new DeveloperError('thisY is required.');
 }
 if (!defined(thisLevel)) {
 throw new DeveloperError('thisLevel is required.');
 }
 if (!defined(descendantX)) {
 throw new DeveloperError('descendantX is required.');
 }
 if (!defined(descendantY)) {
 throw new DeveloperError('descendantY is required.');
 }
 if (!defined(descendantLevel)) {
 throw new DeveloperError('descendantLevel is required.');
 }
 var levelDifference = descendantLevel - thisLevel;
 if (levelDifference > 1) {
 throw new DeveloperError('Upsampling through more than one level at a time is not currently supported.');
 }
 //>>includeEnd('debug');
 
 var isEastChild = thisX * 2 !== descendantX;
 var isNorthChild = thisY * 2 === descendantY;
 
 var ellipsoid = tilingScheme.ellipsoid;
 var childRectangle = tilingScheme.tileXYToRectangle(descendantX, descendantY, descendantLevel);
 
 var upsamplePromise = upsampleTaskProcessor.scheduleTask({
 vertices : this._quantizedVertices,
 indices : this._indices,
 encodedNormals : this._encodedNormals,
 minimumHeight : this._minimumHeight,
 maximumHeight : this._maximumHeight,
 isEastChild : isEastChild,
 isNorthChild : isNorthChild,
 childRectangle : childRectangle,
 ellipsoid : ellipsoid
 });
 
 if (!defined(upsamplePromise)) {
 // Postponed
 return undefined;
 }
 
 var shortestSkirt = Math.min(this._westSkirtHeight, this._eastSkirtHeight);
 shortestSkirt = Math.min(shortestSkirt, this._southSkirtHeight);
 shortestSkirt = Math.min(shortestSkirt, this._northSkirtHeight);
 
 var westSkirtHeight = isEastChild ? (shortestSkirt * 0.5) : this._westSkirtHeight;
 var southSkirtHeight = isNorthChild ? (shortestSkirt * 0.5) : this._southSkirtHeight;
 var eastSkirtHeight = isEastChild ? this._eastSkirtHeight : (shortestSkirt * 0.5);
 var northSkirtHeight = isNorthChild ? this._northSkirtHeight : (shortestSkirt * 0.5);
 
 return when(upsamplePromise, function(result) {
 var quantizedVertices = new Uint16Array(result.vertices);
 var indicesTypedArray = IndexDatatype.createTypedArray(quantizedVertices.length / 3, result.indices);
 var encodedNormals;
 if (defined(result.encodedNormals)) {
 encodedNormals = new Uint8Array(result.encodedNormals);
 }
 
 return new QuantizedMeshTerrainData({
 quantizedVertices : quantizedVertices,
 indices : indicesTypedArray,
 encodedNormals : encodedNormals,
 minimumHeight : result.minimumHeight,
 maximumHeight : result.maximumHeight,
 boundingSphere : BoundingSphere.clone(result.boundingSphere),
 orientedBoundingBox : OrientedBoundingBox.clone(result.orientedBoundingBox),
 horizonOcclusionPoint : Cartesian3.clone(result.horizonOcclusionPoint),
 westIndices : result.westIndices,
 southIndices : result.southIndices,
 eastIndices : result.eastIndices,
 northIndices : result.northIndices,
 westSkirtHeight : westSkirtHeight,
 southSkirtHeight : southSkirtHeight,
 eastSkirtHeight : eastSkirtHeight,
 northSkirtHeight : northSkirtHeight,
 childTileMask : 0,
 createdByUpsampling : true
 });
 });*/
 }
 /*
 var maxShort = 32767;
 var barycentricCoordinateScratch = new Cartesian3();
 */
    /**
     * Computes the terrain height at a specified longitude and latitude.
     *
     * @param {Rectangle} rectangle The rectangle covered by this terrain data.
     * @param {Number} longitude The longitude in radians.
     * @param {Number} latitude The latitude in radians.
     * @returns {Number} The terrain height at the specified position.  The position is clamped to
     *          the rectangle, so expect incorrect results for positions far outside the rectangle.
     */
    func interpolateHeight (rectangle rectangle: Rectangle, longitude: Double, latitude: Double) -> Double? {
        /*
         var u = CesiumMath.clamp((longitude - rectangle.west) / rectangle.width, 0.0, 1.0);
         u *= maxShort;
         var v = CesiumMath.clamp((latitude - rectangle.south) / rectangle.height, 0.0, 1.0);
         v *= maxShort;
         
         var uBuffer = this._uValues;
         var vBuffer = this._vValues;
         var heightBuffer = this._heightValues;
         
         var indices = this._indices;
         for (var i = 0, len = indices.length; i < len; i += 3) {
         var i0 = indices[i];
         var i1 = indices[i + 1];
         var i2 = indices[i + 2];
         
         var u0 = uBuffer[i0];
         var u1 = uBuffer[i1];
         var u2 = uBuffer[i2];
         
         var v0 = vBuffer[i0];
         var v1 = vBuffer[i1];
         var v2 = vBuffer[i2];
         
         var barycentric = Intersections2D.computeBarycentricCoordinates(u, v, u0, v0, u1, v1, u2, v2, barycentricCoordinateScratch);
         if (barycentric.x >= -1e-15 && barycentric.y >= -1e-15 && barycentric.z >= -1e-15) {
         var quantizedHeight = barycentric.x * heightBuffer[i0] +
         barycentric.y * heightBuffer[i1] +
         barycentric.z * heightBuffer[i2];
         return CesiumMath.lerp(this._minimumHeight, this._maximumHeight, quantizedHeight / maxShort);
         }
         }
         
         // Position does not lie in any triangle in this mesh.
         return undefined;*/
        return nil
    }
  
}