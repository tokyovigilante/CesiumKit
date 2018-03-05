//
//  HeightMapTerrainData.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

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
* var terrainData = new Cesium.HeightmapTerrainData({
*   buffer : heightBuffer,
*   width : 65,
*   height : 65,
*   childTileMask : childTileMask,
*   waterMask : waterMask
* });
*/

class HeightmapTerrainData: TerrainData, Equatable {
    /**
    * The water mask included in this terrain data, if any.  A water mask is a rectangular
    * Uint8Array or image where a value of 255 indicates water and a value of 0 indicates land.
    * Values in between 0 and 255 are allowed as well to smoothly blend between land and water.
    * @memberof TerrainData.prototype
    * @type {Uint8Array|Image|Canvas}
    */

    fileprivate var _buffer: [UInt16]

    fileprivate let _width: Int

    fileprivate let _height: Int

    fileprivate let _structure: HeightmapStructure

    fileprivate var _skirtHeight: Double = 0.0

    fileprivate var _mesh: TerrainMesh? = nil

    let waterMask: [UInt8]?

    let createdByUpsampling: Bool

    let childTileMask: Int

    init (buffer: [UInt16],
          width: Int,
          height: Int,
          childTileMask: Int = 15,
          structure: HeightmapStructure = HeightmapStructure(),
          waterMask: [UInt8]? = nil,
          createdByUpsampling: Bool = false)
    {

        _buffer = buffer
        _width = width
        _height = height

        self.childTileMask = childTileMask

        _structure = structure

        self.waterMask = waterMask
        self.createdByUpsampling = createdByUpsampling
    }

    /**
    * Creates a {@link TerrainMesh} from this terrain data.
    * @function
    *
    * @param {TilingScheme} tilingScheme The tiling scheme to which this tile belongs.
    * @param {Number} x The X coordinate of the tile for which to create the terrain data.
    * @param {Number} y The Y coordinate of the tile for which to create the terrain data.
    * @param {Number} level The level of the tile for which to create the terrain data.
    * @param {Number} [exaggeration=1.0] The scale used to exaggerate the terrain.
    * @returns {Promise|TerrainMesh} A promise for the terrain mesh, or undefined if too many
    *          asynchronous mesh creations are already in progress and the operation should
    *          be retried later.
    */
    func createMesh(tilingScheme: TilingScheme, x: Int, y: Int, level: Int, exaggeration: Double = 1.0, completionBlock: (TerrainMesh?) -> ()) -> Bool {
        let ellipsoid = tilingScheme.ellipsoid
        let nativeRectangle = tilingScheme.tileXYToNativeRectangle(x: x, y: y, level: level)
        let rectangle = tilingScheme.tileXYToRectangle(x: x, y: y, level: level)

        // Compute the center of the tile for RTC rendering.
        let center = ellipsoid.cartographicToCartesian(rectangle.center)

        let levelZeroMaxError = EllipsoidTerrainProvider.estimatedLevelZeroGeometricErrorForAHeightmap(
            ellipsoid: ellipsoid,
            tileImageWidth: _width,
            numberOfTilesAtLevelZero: tilingScheme.numberOfXTilesAt(level: 0))
        let thisLevelMaxError = levelZeroMaxError / Double(1 << level)

        _skirtHeight = min(thisLevelMaxError * 4.0, 1000.0)

        let numberOfAttributes = 6

        var arrayWidth = _width
        var arrayHeight = _height

        if _skirtHeight > 0.0 {
            arrayWidth += 2
            arrayHeight += 2
        }

        let result = HeightmapTessellator.computeVertices(
            heightmap: _buffer,
            height: _height,
            width: _width,
            skirtHeight: _skirtHeight,
            nativeRectangle: nativeRectangle,
            rectangle: rectangle,
            isGeographic: tilingScheme is GeographicTilingScheme,
            ellipsoid: ellipsoid,
            structure: _structure,
            relativeToCenter: center,
            exaggeration: exaggeration)
        let boundingSphere3D = BoundingSphere.fromVertices(result.vertices, center: center, stride: numberOfAttributes)

        let orientedBoundingBox: OrientedBoundingBox?

        if (rectangle.width < .pi/2 + Math.Epsilon5) {
            // Here, rectangle.width < pi/2, and rectangle.height < pi
            // (though it would still work with rectangle.width up to pi)
            orientedBoundingBox = OrientedBoundingBox(fromRectangle: rectangle, minimumHeight: result.minimumHeight, maximumHeight: result.maximumHeight, ellipsoid: ellipsoid)
        } else {
            orientedBoundingBox = nil
        }

        let occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        let occludeePointInScaledSpace = occluder.computeHorizonCullingPointFromVertices(directionToPoint: center, vertices: result.vertices, stride: numberOfAttributes, center: center)
        _mesh = TerrainMesh(
            center: center,
            vertices: result.vertices,
            indices: EllipsoidTerrainProvider.getRegularGridIndices(width: arrayWidth, height: arrayHeight),
            minimumHeight: result.minimumHeight,
            maximumHeight: result.maximumHeight,
            boundingSphere3D: boundingSphere3D,
            occludeePointInScaledSpace: occludeePointInScaledSpace!,
            orientedBoundingBox: orientedBoundingBox,
            encoding: result.encoding,
            exaggeration: exaggeration
        )

        // Free memory received from server after mesh is created.
        _buffer = []

        completionBlock(_mesh)
        return true
    }

    /**
     * Computes the terrain height at a specified longitude and latitude.
     *
     * @param {Rectangle} rectangle The rectangle covered by this terrain data.
     * @param {Number} longitude The longitude in radians.
     * @param {Number} latitude The latitude in radians.
     * @returns {Number} The terrain height at the specified position.  If the position
     *          is outside the rectangle, this method will extrapolate the height, which is likely to be wildly
     *          incorrect for positions far outside the rectangle.
     */
    func interpolateHeight(_ rectangle: Rectangle, longitude: Double, latitude: Double) -> Double? {

        var heightSample: Double

        if let mesh = _mesh {
             heightSample = interpolateMeshHeight(mesh.vertices, encoding: mesh.encoding, heightOffset: _structure.heightOffset, heightScale: _structure.heightScale, skirtHeight: _skirtHeight, sourceRectangle: rectangle, width: _width, height: _height, longitude: longitude, latitude: latitude, exaggeration: mesh.exaggeration)
        } else {
            heightSample = interpolateHeight2(_buffer, elementsPerHeight: _structure.elementsPerHeight, elementMultiplier: _structure.elementMultiplier, stride: _structure.stride, isBigEndian: _structure.isBigEndian, sourceRectangle: rectangle, width: _width, height: _height, longitude: longitude, latitude: latitude)
            heightSample = heightSample * _structure.heightScale + _structure.heightOffset
        }

        return heightSample
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
    func upsample(tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int, completionBlock: (TerrainData?) -> ()) -> Bool {

        let levelDifference = descendantLevel - thisLevel
        assert(levelDifference == 1, "Upsampling through more than one level at a time is not currently supported")

        let stride = _structure.stride

        var heights = [UInt16](repeating: 0, count: _width * _height * stride)

        guard let mesh = _mesh else {
            return false
        }

        let buffer = mesh.vertices
        let encoding = mesh.encoding

        // PERFORMANCE_IDEA: don't recompute these rectangles - the caller already knows them.
        let sourceRectangle = tilingScheme.tileXYToRectangle(x: thisX, y: thisY, level: thisLevel)
        let destinationRectangle = tilingScheme.tileXYToRectangle(x: descendantX, y: descendantY, level: descendantLevel)

        let heightOffset = _structure.heightOffset
        let heightScale = _structure.heightScale
        let exaggeration = mesh.exaggeration

        let elementsPerHeight = _structure.elementsPerHeight
        let elementMultiplier = _structure.elementMultiplier
        let isBigEndian = _structure.isBigEndian

        let divisor = pow(elementMultiplier, Double(elementsPerHeight - 1))

        for j in 0..<_height {
            let latitude = Math.lerp(p: destinationRectangle.north, q: destinationRectangle.south, time: Double(j) / Double(_height - 1))
            for i in 0..<_width {
                let longitude = Math.lerp(p: destinationRectangle.west, q: destinationRectangle.east, time: Double(i) / Double(_width - 1))
                let heightSample = interpolateMeshHeight(buffer, encoding: encoding, heightOffset: heightOffset, heightScale: heightScale, skirtHeight: _skirtHeight, sourceRectangle: sourceRectangle, width: _width, height: _height, longitude: longitude, latitude: latitude, exaggeration: exaggeration)
                setHeight(&heights, elementsPerHeight: elementsPerHeight, elementMultiplier: elementMultiplier, divisor: divisor, stride: stride, isBigEndian: isBigEndian, index: j * _width + i, height: heightSample)
            }
        }

        let result =  HeightmapTerrainData(
            buffer: heights,
            width: _width,
            height: _height,
            childTileMask : 0,
            structure: _structure,
            createdByUpsampling: true
        )
        completionBlock(result)
        return true
    }

    fileprivate func interpolateHeight2(_ sourceHeights: [UInt16], elementsPerHeight: Int, elementMultiplier: Double, stride: Int, isBigEndian: Bool, sourceRectangle: Rectangle, width: Int, height: Int, longitude: Double, latitude: Double) -> Double {
        let fromWest = (longitude - sourceRectangle.west) * Double(width - 1) / (sourceRectangle.east - sourceRectangle.west)
        let fromSouth = (latitude - sourceRectangle.south) * Double(height - 1) / (sourceRectangle.north - sourceRectangle.south)

        var westInteger = Int(floor(fromWest))
        var eastInteger = westInteger + 1
        if (eastInteger >= width) {
            eastInteger = width - 1
            westInteger = width - 2
        }

        var southInteger = Int(floor(fromSouth))
        var northInteger = southInteger + 1
        if northInteger >= height {
            northInteger = height - 1
            southInteger = height - 2
        }

        let dx = fromWest - Double(westInteger)
        let dy = fromSouth - Double(southInteger)

        southInteger = height - 1 - southInteger
        northInteger = height - 1 - northInteger

        let southwestHeight = getHeight(sourceHeights, elementsPerHeight: elementsPerHeight, elementMultiplier: elementMultiplier, stride: stride, isBigEndian: isBigEndian, index: southInteger * width + westInteger)
        let southeastHeight = getHeight(sourceHeights, elementsPerHeight: elementsPerHeight, elementMultiplier: elementMultiplier, stride: stride, isBigEndian: isBigEndian, index: southInteger * width + eastInteger)
        let northwestHeight = getHeight(sourceHeights, elementsPerHeight: elementsPerHeight, elementMultiplier: elementMultiplier, stride: stride, isBigEndian: isBigEndian, index: northInteger * width + westInteger)
        let northeastHeight = getHeight(sourceHeights, elementsPerHeight: elementsPerHeight, elementMultiplier: elementMultiplier, stride: stride, isBigEndian: isBigEndian, index: northInteger * width + eastInteger)

        return triangleInterpolateHeight(dx, dY: dy, southwestHeight: southwestHeight, southeastHeight: southeastHeight, northwestHeight: northwestHeight, northeastHeight: northeastHeight)
    }

    fileprivate func interpolateMeshHeight(_ buffer: [Float], encoding: TerrainEncoding, heightOffset: Double, heightScale: Double, skirtHeight: Double, sourceRectangle: Rectangle, width: Int, height: Int, longitude: Double, latitude: Double, exaggeration: Double) -> Double
    {

        var fromWest = (longitude - sourceRectangle.west) * Double(width - 1) / (sourceRectangle.east - sourceRectangle.west)
        var fromSouth = (latitude - sourceRectangle.south) * Double(height - 1) / (sourceRectangle.north - sourceRectangle.south)

        var width = width
        var height = height

        if skirtHeight > 0 {
            fromWest += 1.0
            fromSouth += 1.0

            width += 2
            height += 2
        }

        let widthEdge = skirtHeight > 0 ? width - 1 : width
        var westInteger = Int(floor(fromWest))
        var eastInteger = westInteger + 1
        if eastInteger >= widthEdge {
            eastInteger = width - 1
            westInteger = width - 2
        }

        let heightEdge = skirtHeight > 0 ? height - 1 : height
        var southInteger = Int(floor(fromSouth))
        var northInteger = southInteger + 1
        if northInteger >= heightEdge {
            northInteger = height - 1
            southInteger = height - 2
        }

        let dx = fromWest - Double(westInteger)
        let dy = fromSouth - Double(southInteger)

        southInteger = height - 1 - southInteger
        northInteger = height - 1 - northInteger

        let southwestHeight = (encoding.decodeHeight(buffer, index: southInteger * width + westInteger) / exaggeration - heightOffset) / heightScale
        let southeastHeight = (encoding.decodeHeight(buffer, index: southInteger * width + eastInteger) / exaggeration - heightOffset) / heightScale
        let northwestHeight = (encoding.decodeHeight(buffer, index: northInteger * width + westInteger) / exaggeration - heightOffset) / heightScale
        let northeastHeight = (encoding.decodeHeight(buffer, index: northInteger * width + eastInteger) / exaggeration - heightOffset) / heightScale

        return triangleInterpolateHeight(dx, dY: dy, southwestHeight: southwestHeight, southeastHeight: southeastHeight, northwestHeight: northwestHeight, northeastHeight: northeastHeight)
    }

    fileprivate func triangleInterpolateHeight(_ dX: Double, dY: Double, southwestHeight: Double, southeastHeight: Double, northwestHeight: Double, northeastHeight: Double) -> Double {
        // The HeightmapTessellator bisects the quad from southwest to northeast.
        if (dY < dX) {
            // Lower right triangle
            return southwestHeight + (dX * (southeastHeight - southwestHeight)) + (dY * (northeastHeight - southeastHeight))
        }

        // Upper left triangle
        return southwestHeight + (dX * (northeastHeight - northwestHeight)) + (dY * (northwestHeight - southwestHeight))
    }

    fileprivate func getHeight(_ heights: [UInt16], elementsPerHeight: Int, elementMultiplier: Double, stride increment: Int, isBigEndian: Bool, index: Int) -> Double {
        let trueIndex = index * increment

        var height = 0.0

        if isBigEndian {
            for i in 0..<elementsPerHeight {
                height = Double(height) * elementMultiplier + Double(heights[trueIndex + i])
            }
        } else {
            for i in stride(from: (elementsPerHeight - 1), through: 0, by: -1) {
                height = height * elementMultiplier + Double(heights[trueIndex + i])
            }
        }

        return height
    }

    fileprivate func setHeight(_ heights: inout [UInt16], elementsPerHeight: Int, elementMultiplier: Double, divisor: Double, stride increment: Int, isBigEndian: Bool, index: Int, height: Double) {

        let index = index * increment

        var height = height
        var divisor = divisor
        if isBigEndian {
            for i in 0..<elementsPerHeight {
                heights[index + i] = UInt16(floor(height / divisor))
                height -= Double(heights[index + i]) * divisor
                divisor /= elementMultiplier
            }
        } else {
            for i in stride(from: (elementsPerHeight - 1), through: 0, by: -1) {
                heights[index + i] = UInt16(floor(height / divisor))
                height -= Double(heights[index + i]) * divisor
                divisor /= elementMultiplier
            }
        }
    }
}

func ==(lhs: HeightmapTerrainData, rhs: HeightmapTerrainData) -> Bool {
    return lhs === rhs
}
