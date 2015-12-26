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

class HeightmapTerrainData: TerrainData, Equatable {
    /**
    * The water mask included in this terrain data, if any.  A water mask is a rectangular
    * Uint8Array or image where a value of 255 indicates water and a value of 0 indicates land.
    * Values in between 0 and 255 are allowed as well to smoothly blend between land and water.
    * @memberof TerrainData.prototype
    * @type {Uint8Array|Image|Canvas}
    */
    
    private let _buffer: [UInt16]
    
    private let _width: Int
    
    private let _height: Int
    
    private let _childTileMask: Int
    
    private let _structure: HeightmapStructure
    
    let waterMask: [UInt8]?
    
    let createdByUpsampling: Bool
        
    init (
        buffer: [UInt16],
        width: Int,
        height: Int,
        childTileMask: Int = 15,
        structure: HeightmapStructure = HeightmapStructure(),
        waterMask: [UInt8]? = nil,
        createdByUpsampling: Bool = false
        ) {
            
            _buffer = buffer
            _width = width
            _height = height
            
            _childTileMask = childTileMask
            
            _structure = structure
        
            self.waterMask = waterMask
            self.createdByUpsampling = createdByUpsampling
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
    func interpolateHeight(rectangle rectangle: Rectangle, longitude: Double, latitude: Double) -> Double {
        
        var heightSample: Double
        
        if _structure.stride > 1 {
            heightSample = interpolateHeightWithStride(sourceHeights: _buffer, elementsPerHeight: _structure.elementsPerHeight, elementMultiplier: _structure.elementMultiplier, stride: _structure.stride, isBigEndian: _structure.isBigEndian, sourceRectangle: rectangle, width: _width, height: _height, longitude: longitude, latitude: latitude)
        } else {
            heightSample = interpolateHeight2(sourceHeights: _buffer, sourceRectangle: rectangle, width: _width, height: _height, longitude: longitude, latitude: latitude)
        }
        
        return heightSample * _structure.heightScale + _structure.heightOffset
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
        var bitNumber = 2 // northwest child
        if childX != thisX * 2 {
            bitNumber += 1 // east child
        }
        if childY != thisY * 2 {
            bitNumber -= 2 // south child
        }
        
        return _childTileMask & (1 << bitNumber) != 0
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
    func createMesh(tilingScheme tilingScheme: TilingScheme, x: Int, y: Int, level: Int, completionBlock: (TerrainMesh?) -> ()) {
        let ellipsoid = tilingScheme.ellipsoid
        let nativeRectangle = tilingScheme.tileXYToNativeRectangle(x: x, y: y, level: level)
        let rectangle = tilingScheme.tileXYToRectangle(x: x, y: y, level: level)
        
        // Compute the center of the tile for RTC rendering.
        let center = ellipsoid.cartographicToCartesian(rectangle.center())
        
        let levelZeroMaxError = EllipsoidTerrainProvider.estimatedLevelZeroGeometricErrorForAHeightmap(
            ellipsoid: ellipsoid,
            tileImageWidth: _width,
            numberOfTilesAtLevelZero: tilingScheme.numberOfXTilesAtLevel(0))
        let thisLevelMaxError = levelZeroMaxError / Double(1 << level)
        
        let skirtHeight = min(thisLevelMaxError * 4.0, 1000.0)
        
        let numberOfAttributes = 6
        
        var arrayWidth = _width
        var arrayHeight = _height
        
        if skirtHeight > 0.0 {
            arrayWidth += 2
            arrayHeight += 2
        }
        
        let statistics = HeightmapTessellator.computeVertices(
            heightmap: _buffer,
            height: _height,
            width: _width,
            skirtHeight: skirtHeight,
            nativeRectangle: nativeRectangle,
            rectangle: rectangle,
            isGeographic: tilingScheme is GeographicTilingScheme,
            relativeToCenter: center,
            ellipsoid: ellipsoid,
            structure: _structure)
        let boundingSphere3D = BoundingSphere.fromVertices(statistics.vertices, center: center, stride: numberOfAttributes)
        
        let orientedBoundingBox: OrientedBoundingBox?
        
        if (rectangle.width < M_PI_2 + Math.Epsilon5) {
            // Here, rectangle.width < pi/2, and rectangle.height < pi
            // (though it would still work with rectangle.width up to pi)
            orientedBoundingBox = OrientedBoundingBox(fromRectangle: rectangle, minimumHeight: statistics.minimumHeight, maximumHeight: statistics.maximumHeight, ellipsoid: ellipsoid)
        } else {
            orientedBoundingBox = nil
        }
        
        let occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        let occludeePointInScaledSpace = occluder.computeHorizonCullingPointFromVertices(center, vertices: statistics.vertices, stride: numberOfAttributes, center: center)
        let mesh = TerrainMesh(
            center: center,
            vertices: statistics.vertices,
            indices: EllipsoidTerrainProvider.getRegularGridIndices(width: arrayWidth, height: arrayHeight),
            minimumHeight: statistics.minimumHeight,
            maximumHeight: statistics.maximumHeight,
            boundingSphere3D: boundingSphere3D,
            occludeePointInScaledSpace: occludeePointInScaledSpace!,
            orientedBoundingBox: orientedBoundingBox)
        completionBlock(mesh)
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
    func upsample(tilingScheme tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int, completionBlock: (TerrainData?) -> ()) {

        let levelDifference = descendantLevel - thisLevel
        assert(levelDifference == 1, "Upsampling through more than one level at a time is not currently supported")
        
        let result: TerrainData
        
        if _width % 2 == 1 && _height % 2 == 1 {
            // We have an odd number of posts greater than 2 in each direction,
            // so we can upsample by simply dropping half of the posts in each direction.
            result = upsampleBySubsetting(tilingScheme, thisX: thisX, thisY: thisY, thisLevel: thisLevel, descendantX: descendantX, descendantY: descendantY, descendantLevel: descendantLevel)
        } else {
            // The number of posts in at least one direction is even, so we must upsample
            // by interpolating heights.
            result = upsampleByInterpolating(tilingScheme, thisX: thisX, thisY: thisY, thisLevel: thisLevel, descendantX: descendantX, descendantY: descendantY, descendantLevel: descendantLevel)
        }
        completionBlock(result)
    }
    
    private func upsampleBySubsetting(tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int) -> HeightmapTerrainData {
        
        let levelDifference = 1
        
        // Compute the post indices of the corners of this tile within its own level.
        var leftPostIndex = descendantX * (_width - 1)
        var rightPostIndex = leftPostIndex + _width - 1
        var topPostIndex = descendantY * (_height - 1)
        var bottomPostIndex = topPostIndex + _height - 1
        
        // Transform the post indices to the ancestor's level.
        let twoToTheLevelDifference = 1 << levelDifference
        leftPostIndex /= twoToTheLevelDifference
        rightPostIndex /= twoToTheLevelDifference
        topPostIndex /= twoToTheLevelDifference
        bottomPostIndex /= twoToTheLevelDifference
        
        // Adjust the indices to be relative to the northwest corner of the source tile.
        let sourceLeft = thisX * (_width - 1)
        let sourceTop = thisY * (_height - 1)
        leftPostIndex -= sourceLeft
        rightPostIndex -= sourceLeft
        topPostIndex -= sourceTop
        bottomPostIndex -= sourceTop
    
        let leftInteger = leftPostIndex | 0
        let rightInteger = rightPostIndex | 0
        let topInteger = topPostIndex | 0
        let bottomInteger = bottomPostIndex | 0
        
        let upsampledWidth = (rightInteger - leftInteger + 1)
        let upsampledHeight = (bottomInteger - topInteger + 1)
        
        let sourceHeights = _buffer
        
        // Copy the relevant posts.
        let numberOfHeights = upsampledWidth * upsampledHeight
        let numberOfElements = numberOfHeights * _structure.stride
        var heights = [UInt16](count: numberOfElements, repeatedValue: 0)
        
        var outputIndex = 0
        
        if _structure.stride > 1 {
            for i in topInteger...bottomInteger {
                for j in leftInteger...rightInteger {
                    let index = (j * _width + i) * _structure.stride
                    for k in 0..<_structure.stride {
                        heights[outputIndex] = sourceHeights[index + k]
                        outputIndex += 1
                    }
                }
            }
        } else {
            for j in topInteger...bottomInteger {
                for i in leftInteger...rightInteger {
                    heights[outputIndex] = sourceHeights[j * _width + i]
                    outputIndex += 1
                }
            }
        }

        return HeightmapTerrainData(
            buffer : heights,
            width : upsampledWidth,
            height : upsampledHeight,
            childTileMask : 0,
            structure : _structure,
            createdByUpsampling : true)
    }
    
    private func upsampleByInterpolating(tilingScheme: TilingScheme, thisX: Int, thisY: Int, thisLevel: Int, descendantX: Int, descendantY: Int, descendantLevel: Int) -> HeightmapTerrainData {

        let sourceHeights = _buffer

        let numberOfElements = _width * _height * _structure.stride
        
        var heights = [Double](count: numberOfElements, repeatedValue: 0.0)

        // PERFORMANCE_IDEA: don't recompute these rectangles - the caller already knows them.
        let sourceRectangle = tilingScheme.tileXYToRectangle(x: thisX, y: thisY, level: thisLevel)
        let destinationRectangle = tilingScheme.tileXYToRectangle(x: descendantX, y: descendantY, level: descendantLevel)
        
        var latitude, longitude: Double
        
        if _structure.stride > 1 {
            let elementsPerHeight = _structure.elementsPerHeight
            let elementMultiplier = _structure.elementMultiplier
            let isBigEndian = _structure.isBigEndian
            
            let divisor = pow(elementMultiplier, Double(elementsPerHeight - 1))
            
            for j in 0..<_height {
                latitude = Math.lerp(
                    p: destinationRectangle.north,
                    q: destinationRectangle.south,
                    time: Double(j) / (Double(_height) - 1.0)
                )
                for i in 0..<_width {
                    longitude = Math.lerp(
                        p: destinationRectangle.west,
                        q: destinationRectangle.east,
                        time: Double(i) / (Double(_width) - 1.0)
                    )
                    let heightSample = interpolateHeightWithStride(
                        sourceHeights: sourceHeights,
                        elementsPerHeight: elementsPerHeight,
                        elementMultiplier: elementMultiplier,
                        stride: _structure.stride,
                        isBigEndian: isBigEndian,
                        sourceRectangle: sourceRectangle,
                        width: _width,
                        height: _height,
                        longitude: longitude,
                        latitude: latitude)
                    
                    setHeight(
                        heights: &heights,
                        elementsPerHeight: elementsPerHeight,
                        elementMultiplier: elementMultiplier,
                        divisor: divisor,
                        stride: _structure.stride,
                        isBigEndian: isBigEndian,
                        index: j * _width + i,
                        height: heightSample
                    )
                }
            }
        } else {
            for j in 0..<_height {
                latitude = Math.lerp(
                    p: destinationRectangle.north,
                    q: destinationRectangle.south,
                    time: Double(j) / Double(_height - 1))
                for i in 0..<_width {
                    longitude = Math.lerp(
                        p: destinationRectangle.west,
                        q: destinationRectangle.east,
                        time: Double(i) / Double(_width - 1)
                    )

                    heights[j * _width + i] = interpolateHeight2(
                        sourceHeights: sourceHeights,
                        sourceRectangle: sourceRectangle,
                        width: _width,
                        height: _height,
                        longitude: longitude,
                        latitude: latitude
                    )
                }
            }
        }
        return HeightmapTerrainData(
            buffer: heights.map({ UInt16($0) }),
            width: _width,
            height: _height,
            childTileMask: 0,
            structure: _structure,
            createdByUpsampling: true
        )
    }
    
    private func interpolateHeight2(sourceHeights sourceHeights: [UInt16], sourceRectangle: Rectangle, width: Int, height: Int, longitude: Double, latitude: Double) -> Double {
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
        
        let southwestHeight = Double(sourceHeights[southInteger * width + westInteger])
        let southeastHeight = Double(sourceHeights[southInteger * width + eastInteger])
        let northwestHeight = Double(sourceHeights[northInteger * width + westInteger])
        let northeastHeight = Double(sourceHeights[northInteger * width + eastInteger])
        
        return triangleInterpolateHeight(dX: dx, dY: dy, southwestHeight: southwestHeight, southeastHeight: southeastHeight, northwestHeight: northwestHeight, northeastHeight: northeastHeight)
    }
    
    private func interpolateHeightWithStride(sourceHeights sourceHeights: [UInt16], elementsPerHeight: Int, elementMultiplier: Double, stride: Int, isBigEndian: Bool, sourceRectangle: Rectangle, width: Int, height: Int, longitude: Double, latitude: Double) -> Double {
        let fromWest = (longitude - sourceRectangle.west) * (Double(width) - 1.0) / (sourceRectangle.east - sourceRectangle.west)
        let fromSouth = (latitude - sourceRectangle.south) * (Double(height) - 1.0) / (sourceRectangle.north - sourceRectangle.south)
        
        var westInteger = Int(floor(fromWest))
        var eastInteger = westInteger + 1
        if eastInteger >= width {
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
        
        let southwestHeight = getHeight(
            heights: sourceHeights,
            elementsPerHeight: elementsPerHeight,
            elementMultiplier: elementMultiplier,
            stride: stride,
            isBigEndian: isBigEndian,
            index: southInteger * width + westInteger
        )
        let southeastHeight = getHeight(
            heights: sourceHeights,
            elementsPerHeight: elementsPerHeight,
            elementMultiplier: elementMultiplier,
            stride: stride,
            isBigEndian: isBigEndian,
            index: southInteger * width + eastInteger
        )
        let northwestHeight = getHeight(
            heights: sourceHeights,
            elementsPerHeight: elementsPerHeight,
            elementMultiplier: elementMultiplier,
            stride: stride,
            isBigEndian: isBigEndian,
            index: northInteger * width + westInteger
        )
        let northeastHeight = getHeight(
            heights: sourceHeights,
            elementsPerHeight: elementsPerHeight,
            elementMultiplier: elementMultiplier,
            stride: stride,
            isBigEndian: isBigEndian,
            index: northInteger * width + eastInteger
        )
        
        return triangleInterpolateHeight(
            dX: dx,
            dY: dy,
            southwestHeight: southwestHeight,
            southeastHeight: southeastHeight,
            northwestHeight: northwestHeight,
            northeastHeight: northeastHeight)
    }
    
    private func triangleInterpolateHeight(dX dX: Double, dY: Double, southwestHeight: Double, southeastHeight: Double, northwestHeight: Double, northeastHeight: Double) -> Double {
        // The HeightmapTessellator bisects the quad from southwest to northeast.
        if (dY < dX) {
            // Lower right triangle
            return southwestHeight + (dX * (southeastHeight - southwestHeight)) + (dY * (northeastHeight - southeastHeight))
        }
        
        // Upper left triangle
        return southwestHeight + (dX * (northeastHeight - northwestHeight)) + (dY * (northwestHeight - southwestHeight))
    }
    
    private func getHeight(heights heights: [UInt16], elementsPerHeight: Int, elementMultiplier: Double, stride: Int, isBigEndian: Bool, index: Int) -> Double {
        let trueIndex = index * stride
        
        var height = 0.0
        
        if isBigEndian {
            for i in 0..<elementsPerHeight {
                height = Double(height) * elementMultiplier + Double(heights[trueIndex + i])
            }
        } else {
            for i in (elementsPerHeight - 1).stride(through: 0, by: -1) {
                height = height * elementMultiplier + Double(heights[trueIndex + i])
            }
        }
        
        return height
    }
    
    private func setHeight(inout heights heights: [Double], elementsPerHeight: Int, elementMultiplier: Double, divisor: Double, stride: Int, isBigEndian: Bool, index: Int, height: Double) {
        
        let trueIndex = index * stride
        
        var workingHeight = height
        var workingDivisor = divisor
        if (isBigEndian) {
            for i in 0..<elementsPerHeight {
                heights[trueIndex + i] = floor(workingHeight / workingDivisor)
                workingHeight -= heights[trueIndex + i] * workingDivisor
                workingDivisor /= elementMultiplier
            }
        } else {
            for i in (elementsPerHeight - 1).stride(through: 0, by: -1) {
                heights[trueIndex + i] = floor(workingHeight / workingDivisor)
                workingHeight -= heights[trueIndex + i] * workingDivisor
                workingDivisor /= elementMultiplier
            }
        }
    }
}

func ==(lhs: HeightmapTerrainData, rhs: HeightmapTerrainData) -> Bool {
    let left = unsafeAddressOf(lhs)
    let right = unsafeAddressOf(rhs)
    return left == right
}