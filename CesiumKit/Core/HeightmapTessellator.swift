//
//  HeightmapTessellator.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
* Contains functions to create a mesh from a heightmap image.
*
* @namespace
* @alias HeightmapTessellator
*/
class HeightmapTessellator {

    /**
    * Fills an array of vertices from a heightmap image.
    *
    * @param {Object} options Object with the following properties:
    * @param {TypedArray} options.heightmap The heightmap to tessellate.
    * @param {Number} options.width The width of the heightmap, in height samples.
    * @param {Number} options.height The height of the heightmap, in height samples.
    * @param {Number} options.skirtHeight The height of skirts to drape at the edges of the heightmap.
    * @param {Rectangle} options.nativeRectangle An rectangle in the native coordinates of the heightmap's projection.  For
    *                 a heightmap with a geographic projection, this is degrees.  For the web mercator
    *                 projection, this is meters.
    * @param {Rectangle} [options.rectangle] The rectangle covered by the heightmap, in geodetic coordinates with north, south, east and
    *                 west properties in radians.  Either rectangle or nativeRectangle must be provided.  If both
    *                 are provided, they're assumed to be consistent.
    * @param {Boolean} [options.isGeographic=true] True if the heightmap uses a {@link GeographicProjection}, or false if it uses
    *                  a {@link WebMercatorProjection}.
    * @param {Cartesian3} [options.relativetoCenter=Cartesian3.ZERO] The positions will be computed as <code>Cartesian3.subtract(worldPosition, relativeToCenter)</code>.
    * @param {Ellipsoid} [options.ellipsoid=Ellipsoid.WGS84] The ellipsoid to which the heightmap applies.
    * @param {Object} [options.structure] An object describing the structure of the height data.
    * @param {Number} [options.exaggeration=1.0] The scale used to exaggerate the terrain.
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
    *
    * @example
    * var width = 5;
    * var height = 5;
    * var vertices = new Float32Array(width * height * 6);
    * Cesium.HeightmapTessellator.computeVertices({
    *     vertices : vertices,
    *     heightmap : [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0],
    *     width : width,
    *     height : height,
    *     skirtHeight : 0.0,
    *     nativeRectangle : {
    *         west : 10.0,
    *         east : 20.0,
    *         south : 30.0,
    *         north : 40.0
    *     }
    * });
    */
    class func computeVertices (
        heightmap: [UInt16],
                  height: Int,
                  width: Int,
                  skirtHeight: Double,
                  nativeRectangle: Rectangle,
                  rectangle: Rectangle?,
                  isGeographic: Bool = true,
                  ellipsoid: Ellipsoid = Ellipsoid.wgs84(),
                  structure: HeightmapStructure = HeightmapStructure(),
                  relativeToCenter: Cartesian3? = nil,
                  exaggeration: Double
        ) -> (
        vertices: [Float],
        maximumHeight: Double,
        minimumHeight: Double,
        encoding: TerrainEncoding,
        boundingSphere3D: BoundingSphere,
        orientedBoundingBox: OrientedBoundingBox?,
        occludeePointInScaledSpace: Cartesian3?
        )
    {
        
        // This function tends to be a performance hotspot for terrain rendering,
        // so it employs a lot of inlining and unrolling as an optimization.
        // In particular, the functionality of Ellipsoid.cartographicToCartesian
        // is inlined.
        let piOverTwo = M_PI_2
        
        let oneOverGlobeSemimajorAxis = 1.0 / ellipsoid.maximumRadius
        
        var geographicWest: Double
        var geographicSouth: Double
        var geographicEast: Double
        var geographicNorth: Double
        
        if rectangle == nil {
            if isGeographic {
                geographicWest = Math.toRadians(nativeRectangle.west)
                geographicSouth = Math.toRadians(nativeRectangle.south)
                geographicEast = Math.toRadians(nativeRectangle.east)
                geographicNorth = Math.toRadians(nativeRectangle.north)
            } else {
                geographicWest = nativeRectangle.west * oneOverGlobeSemimajorAxis
                geographicSouth = piOverTwo - (2.0 * atan(exp(-nativeRectangle.south * oneOverGlobeSemimajorAxis)))
                geographicEast = nativeRectangle.east * oneOverGlobeSemimajorAxis;
                geographicNorth = piOverTwo - (2.0 * atan(exp(-nativeRectangle.north * oneOverGlobeSemimajorAxis)))
            }
        } else {
            geographicWest = rectangle!.west
            geographicSouth = rectangle!.south
            geographicEast = rectangle!.east
            geographicNorth = rectangle!.north
        }
        
        let heightScale = structure.heightScale
        let heightOffset = structure.heightOffset
        let elementsPerHeight = structure.elementsPerHeight
        let stride = structure.stride
        let elementMultiplier = structure.elementMultiplier
        let isBigEndian = structure.isBigEndian
        
        let granularityX = nativeRectangle.width / Double(width - 1)
        let granularityY = nativeRectangle.height / Double(height - 1)
        
        let radiiSquared = ellipsoid.radiiSquared
        let radiiSquaredX = radiiSquared.x
        let radiiSquaredY = radiiSquared.y
        let radiiSquaredZ = radiiSquared.z
        
        var minimumHeight = 65536.0
        var maximumHeight = -65536.0
        
        let fromENU = Transforms.eastNorthUpToFixedFrame(relativeToCenter!, ellipsoid: ellipsoid)
        let toENU = fromENU.inverse
        
        var minimum = Cartesian3(simd: double3(Double.infinity))
        var maximum = Cartesian3(simd: double3(-Double.infinity))
        
        var hMin = Double.infinity
        
        var positions = [Cartesian3]()
        var heights = [Double]()
        var uvs = [Cartesian2]()
        
        var startRow = 0
        var endRow = height
        var startCol = 0
        var endCol = width
        
        if (skirtHeight > 0) {
            startRow -= 1
            endRow += 1
            startCol -= 1
            endCol += 1
        }
        
        for rowIndex in startRow..<endRow {
            var row = rowIndex
            if row < 0 {
                row = 0
            }
            if row >= height {
                row = height - 1
            }
            
            var latitude = nativeRectangle.north - granularityY * Double(row)
            
            if !isGeographic {
                latitude = piOverTwo - (2.0 * atan(exp(-latitude * oneOverGlobeSemimajorAxis)))
            } else {
                latitude = Math.toRadians(latitude)
            }
            
            let cosLatitude = cos(latitude)
            let nZ = sin(latitude)
            let kZ = radiiSquaredZ * nZ
            
            let v = Math.clamp((latitude - geographicSouth) / (geographicNorth - geographicSouth), min: 0.0, max: 1.0)
            
            for colIndex in startCol..<endCol {
                var col = colIndex
                if col < 0 {
                    col = 0
                }
                if col >= width {
                    col = width - 1
                }
                
                var longitude = nativeRectangle.west + granularityX * Double(col)
                
                if !isGeographic {
                    longitude = longitude * oneOverGlobeSemimajorAxis
                } else {
                    longitude = Math.toRadians(longitude)
                }
                
                let terrainOffset = row * (width * stride) + col * stride
                
                var heightSample: Double
                if elementsPerHeight == 1 {
                    heightSample = Double(heightmap[terrainOffset])
                } else {
                    heightSample = 0
                    
                    if isBigEndian {
                        for elementOffset in 0.stride(to: elementsPerHeight, by: 1) {
                            heightSample = (heightSample * elementMultiplier) + Double(heightmap[terrainOffset + elementOffset])
                        }
                    } else {
                        for elementOffset in stride(from: (elementsPerHeight - 1), through: 0, by: -1) {
                            heightSample = (heightSample * elementMultiplier) + Double(heightmap[terrainOffset + elementOffset])
                        }
                    }
                }
                
                heightSample = heightSample * heightScale + heightOffset * exaggeration
                
                maximumHeight = max(maximumHeight, heightSample)
                minimumHeight = min(minimumHeight, heightSample)
                
                if colIndex != col || rowIndex != row {
                    heightSample -= skirtHeight
                }
                
                let nX = cosLatitude * cos(longitude)
                let nY = cosLatitude * sin(longitude)
                
                let kX = radiiSquaredX * nX
                let kY = radiiSquaredY * nY
                
                let gamma = sqrt(kX * nX + kY * nY + kZ * nZ)
                let oneOverGamma = 1.0 / gamma
                
                let rSurfaceX = kX * oneOverGamma
                let rSurfaceY = kY * oneOverGamma
                let rSurfaceZ = kZ * oneOverGamma
                
                let position = Cartesian3(
                    x: rSurfaceX + nX * heightSample,
                    y: rSurfaceY + nY * heightSample,
                    z: rSurfaceZ + nZ * heightSample
                )
                positions.append(position)
                
                heights.append(heightSample)
                
                let u = (longitude - geographicWest) / (geographicEast - geographicWest)
                uvs.append(Cartesian2(x: u, y: v))
                
                let point = toENU.multiplyByPoint(position)
                minimum = point.minimumByComponent(minimum)
                maximum = point.maximumByComponent(maximum)
                hMin = min(hMin, heightSample)

            }
        }
        
        let boundingSphere3D = BoundingSphere(fromPoints: positions)
        
        var orientedBoundingBox: OrientedBoundingBox? = nil
        if let rectangle = rectangle {
            if rectangle.width < piOverTwo + Math.Epsilon5 {
                // Here, rectangle.width < pi/2, and rectangle.height < pi
                // (though it would still work with rectangle.width up to pi)
                orientedBoundingBox = OrientedBoundingBox(
                    fromRectangle: rectangle,
                    minimumHeight: minimumHeight,
                    maximumHeight: maximumHeight,
                    ellipsoid: ellipsoid)
            }
        }
        
        var occludeePointInScaledSpace: Cartesian3? = nil

        if let center = relativeToCenter {
            let occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
            occludeePointInScaledSpace = occluder.computeHorizonCullingPointFromPoints(directionToPoint: center, points: positions)
        }
        
        let aaBox = AxisAlignedBoundingBox(minimum: minimum, maximum: maximum, center: relativeToCenter)
        let encoding = TerrainEncoding(axisAlignedBoundingBox: aaBox, minimumHeight: hMin, maximumHeight: maximumHeight, fromENU: fromENU, hasVertexNormals: false)
        var vertices = [Float]()
        
        for j in 0..<positions.count {
            encoding.encode(&vertices, position: positions[j], uv: uvs[j], height: heights[j], normalToPack: nil)
        }
        
        return (
            vertices: vertices,
            maximumHeight: maximumHeight,
            minimumHeight: minimumHeight,
            encoding: encoding,
            boundingSphere3D: boundingSphere3D,
            orientedBoundingBox: orientedBoundingBox,
            occludeePointInScaledSpace: occludeePointInScaledSpace
        )
    }
    
}
