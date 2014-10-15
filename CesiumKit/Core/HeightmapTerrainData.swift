//
//  HeightMapTerrainData.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Terrain data for a single tile where the terrain data is represented as a heightmap.  A heightmap
* is a rectangular array of heights in row-major order from south to north and west to east.
*
* @alias HeightmapTerrainData
* @constructor
*
* @param {Object} options Object with the following properties:
* @param {TypedArray} options.buffer The buffer containing height data.
* @param {Number} options.width The width (longitude direction) of the heightmap, in samples.
* @param {Number} options.height The height (latitude direction) of the heightmap, in samples.
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
* @param {Object} [options.structure] An object describing the structure of the height data.
* @param {Number} [options.structure.heightScale=1.0] The factor by which to multiply height samples in order to obtain
*                 the height above the heightOffset, in meters.  The heightOffset is added to the resulting
*                 height after multiplying by the scale.
* @param {Number} [options.structure.heightOffset=0.0] The offset to add to the scaled height to obtain the final
*                 height in meters.  The offset is added after the height sample is multiplied by the
*                 heightScale.
* @param {Number} [options.structure.elementsPerHeight=1] The number of elements in the buffer that make up a single height
*                 sample.  This is usually 1, indicating that each element is a separate height sample.  If
*                 it is greater than 1, that number of elements together form the height sample, which is
*                 computed according to the structure.elementMultiplier and structure.isBigEndian properties.
* @param {Number} [options.structure.stride=1] The number of elements to skip to get from the first element of
*                 one height to the first element of the next height.
* @param {Number} [options.structure.elementMultiplier=256.0] The multiplier used to compute the height value when the
*                 stride property is greater than 1.  For example, if the stride is 4 and the strideMultiplier
*                 is 256, the height is computed as follows:
*                 `height = buffer[index] + buffer[index + 1] * 256 + buffer[index + 2] * 256 * 256 + buffer[index + 3] * 256 * 256 * 256`
*                 This is assuming that the isBigEndian property is false.  If it is true, the order of the
*                 elements is reversed.
* @param {Boolean} [options.structure.isBigEndian=false] Indicates endianness of the elements in the buffer when the
*                  stride property is greater than 1.  If this property is false, the first element is the
*                  low-order element.  If it is true, the first element is the high-order element.
* @param {Boolean} [options.createdByUpsampling=false] True if this instance was created by upsampling another instance;
*                  otherwise, false.
*
* @see TerrainData
* @see QuantizedMeshTerrainData
*
* @example
* var buffer = ...
* var heightBuffer = new Uint16Array(buffer, 0, that._heightmapWidth * that._heightmapWidth);
* var childTileMask = new Uint8Array(buffer, heightBuffer.byteLength, 1)[0];
* var waterMask = new Uint8Array(buffer, heightBuffer.byteLength + 1, buffer.byteLength - heightBuffer.byteLength - 1);
* var structure = Cesium.HeightmapTessellator.DEFAULT_STRUCTURE;
* var terrainData = new Cesium.HeightmapTerrainData({
*   buffer : heightBuffer,
*   width : 65,
*   height : 65,
*   childTileMask : childTileMask,
*   structure : structure,
*   waterMask : waterMask
* });
*/
class HeightmapTerrainData: TerrainData {
    /**
    * The water mask included in this terrain data, if any.  A water mask is a rectangular
    * Uint8Array or image where a value of 255 indicates water and a value of 0 indicates land.
    * Values in between 0 and 255 are allowed as well to smoothly blend between land and water.
    * @memberof TerrainData.prototype
    * @type {Uint8Array|Image|Canvas}
    */
    
    private let _buffer: SerializedArray
    
    private let _width: Int
    
    private let _height: Int
    
    private let _childTileMask: Int
    
    private let _structure: HeightmapTessellator.Structure
    
    //private let _createdByUpsampling: Bool
    
    let waterMask: Array<UInt16>? = nil

    
    init (
        buffer: SerializedArray,
        width: Int,
        height: Int,
        childTileMask: Int = 15,
        structure: HeightmapTessellator.Structure = HeightmapTessellator.Structure(),
        //createdByUpsampling: Bool = false,
        waterMask: Array<UInt16>? = nil
        ) {
        
        self._buffer = buffer
        self._width = width
        self._height = height
        
        self._childTileMask = childTileMask
            
        self._structure = structure
        //self._createdByUpsampling = createdByUpsampling
        self.waterMask = waterMask
    }
    
    /**
    * Computes the terrain height at a specified longitude and latitude.
    * @function
    *
    * @param {Rectangle} rectangle The rectangle covered by this terrain data.
    * @param {Number} longitude The longitude in radians.
    * @param {Number} latitude The latitude in radians.
    * @returns {Number} The terrain height at the specified position.  If the position
    *          is outside the rectangle, this method will extrapolate the height, which is likely to be wildly
    *          incorrect for positions far outside the rectangle.
    */
    func interpolateHeight(#rectangle: Rectangle, longitude: Double, latitude: Double) -> Double {
        return 0.0
    }
    
    /**
    * Determines if a given child tile is available, based on the
    * {@link TerrainData#childTileMask}.  The given child tile coordinates are assumed
    * to be one of the four children of this tile.  If non-child tile coordinates are
    * given, the availability of the southeast child tile is returned.
    * @function
    *
    * @param {Number} thisX The tile X coordinate of this (the parent) tile.
    * @param {Number} thisY The tile Y coordinate of this (the parent) tile.
    * @param {Number} childX The tile X coordinate of the child tile to check for availability.
    * @param {Number} childY The tile Y coordinate of the child tile to check for availability.
    * @returns {Boolean} True if the child tile is available; otherwise, false.
    */
    func isChildAvailable(thisX: Int, thisY: Int, childX: Int, childY: Int) -> Bool {
        return false
    }
    
    /**
    * Creates a {@link TerrainMesh} from this terrain data.
    * @function
    *
    * @param {TilingScheme} tilingScheme The tiling scheme to which this tile belongs.
    * @param {Number} x The X coordinate of the tile for which to create the terrain data.
    * @param {Number} y The Y coordinate of the tile for which to create the terrain data.
    * @param {Number} level The level of the tile for which to create the terrain data.
    * @returns {Promise|TerrainMesh} A promise for the terrain mesh, or undefined if too many
    *          asynchronous mesh creations are already in progress and the operation should
    *          be retried later.
    */
    func createMesh(#tilingScheme: TilingScheme, x: Int, y: Int, level: Int) -> TerrainMesh? {
        
        let ellipsoid = tilingScheme.ellipsoid
        let nativeRectangle = tilingScheme.tileXYToNativeRectangle(x: x, y: y, level: level)
        var rectangle = tilingScheme.tileXYToRectangle(x: x, y: y, level: level)
        
        // Compute the center of the tile for RTC rendering.
        let center = ellipsoid.cartographicToCartesian(rectangle.center())
        
        let levelZeroMaxError = EllipsoidTerrainProvider.estimatedLevelZeroGeometricErrorForAHeightmap(
            ellipsoid: ellipsoid,
            tileImageWidth: _width,
            numberOfTilesAtLevelZero: tilingScheme.numberOfXTilesAtLevel(0))
        let thisLevelMaxError = levelZeroMaxError / Double(1 << level)
        
        let skirtHeight = min(thisLevelMaxError * 4.0, 1000.0)
        
        var numberOfAttributes = 6
        
        var arrayWidth = _width
        var arrayHeight = _height
        
        if skirtHeight > 0.0 {
            arrayWidth += 2
            arrayHeight += 2
        }
        
        var vertices = [Float](count: arrayWidth * arrayHeight * numberOfAttributes, repeatedValue: 0.0)
        
        let statistics = HeightmapTessellator.computeVertices(
            &vertices,
            heightmap: _buffer,
            height: _height,
            width: _width,
            skirtHeight: skirtHeight,
            nativeRectangle: nativeRectangle,
            rectangle: rectangle,
            isGeographic: tilingScheme is GeographicTilingScheme,
            relativeToCenter: center,
            ellipsoid: ellipsoid,
            structure: _structure)()
        let boundingSphere3D = BoundingSphere.fromVertices(vertices, center: center, stride: numberOfAttributes)
        
        let occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        let occludeePointInScaledSpace = occluder.computeHorizonCullingPointFromVertices(center, vertices: vertices, stride: numberOfAttributes, center: center)
        return TerrainMesh(
            center: center,
            vertices: vertices,
            indices: EllipsoidTerrainProvider.getRegularGridIndices(width: arrayWidth, height: arrayHeight),
            minimumHeight: statistics.minimumHeight,
            maximumHeight: statistics.maximumHeight,
            boundingSphere3D: boundingSphere3D,
            occludeePointInScaledSpace: occludeePointInScaledSpace!
        )
        return nil
    }

    /**
    * Upsamples this terrain data for use by a descendant tile.
    * @function
    *
    * @param {TilingScheme} tilingScheme The tiling scheme of this terrain data.
    * @param {Number} thisX The X coordinate of this tile in the tiling scheme.
    * @param {Number} thisY The Y coordinate of this tile in the tiling scheme.
    * @param {Number} thisLevel The level of this tile in the tiling scheme.
    * @param {Number} descendantX The X coordinate within the tiling scheme of the descendant tile for which we are upsampling.
    * @param {Number} descendantY The Y coordinate within the tiling scheme of the descendant tile for which we are upsampling.
    * @param {Number} descendantLevel The level within the tiling scheme of the descendant tile for which we are upsampling.
    * @returns {Promise|TerrainData} A promise for upsampled terrain data for the descendant tile,
    *          or undefined if too many asynchronous upsample operations are in progress and the request has been
    *          deferred.
    */
    func upsample(#tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int, resolve: (TerrainData) -> ()) {
        
    }
    
    /**
    * Gets a value indicating whether or not this terrain data was created by upsampling lower resolution
    * terrain data.  If this value is false, the data was obtained from some other source, such
    * as by downloading it from a remote server.  This method should return true for instances
    * returned from a call to {@link TerrainData#upsample}.
    * @function
    *
    * @returns {Boolean} True if this instance was created by upsampling; otherwise, false.
    */
    var wasCreatedByUpsampling: Bool {
        get {
            return false
        }
    }
}