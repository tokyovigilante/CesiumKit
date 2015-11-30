//
//  HeightmapTessellator.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Contains functions to create a mesh from a heightmap image.
*
* @namespace
* @alias HeightmapTessellator
*/
class HeightmapTessellator {

    /**
    * The default structure of a heightmap, as given to {@link HeightmapTessellator.computeVertices}.
    *
    * @constant
    */
    struct Structure {
        let heightScale = 1.0
        let heightOffset = 0.0
        let elementsPerHeight = 1
        let stride = 1
        let elementMultiplier = 256.0
        let isBigEndian = false
    }

    /**
    * Fills an array of vertices from a heightmap image.  On return, the vertex data is in the order
    * [X, Y, Z, H, U, V], where X, Y, and Z represent the Cartesian position of the vertex, H is the
    * height above the ellipsoid, and U and V are the texture coordinates.
    *
    * @param {Object} options Object with the following properties:
    * @param {Array|Float32Array} options.vertices The array to use to store computed vertices.
    *                             If options.skirtHeight is 0.0, the array should have
    *                             options.width * options.height * 6 elements.  If
    *                             options.skirtHeight is greater than 0.0, the array should
    *                             have (options.width + 2) * (options.height * 2) * 6
    *                             elements.
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
        heightmap heightmap: [UInt16],
        height: Int,
        width: Int,
        skirtHeight: Double,
        nativeRectangle: Rectangle,
        rectangle: Rectangle?,
        isGeographic: Bool = true,
        relativeToCenter: Cartesian3 = Cartesian3.zero(),
        ellipsoid: Ellipsoid = Ellipsoid.wgs84(),
        structure: HeightmapTessellator.Structure = HeightmapTessellator.Structure()
        ) -> (maximumHeight: Double, minimumHeight: Double, vertices: [Float]) {
        
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
            
            var vertexArrayIndex: Int = 0
            
            var minimumHeight = 65536.0
            var maximumHeight = -65536.0
            
            var startRow = 0
            var endRow = height
            var startCol = 0
            var endCol = width
            
            if (skirtHeight > 0) {
                --startRow
                ++endRow
                --startCol
                ++endCol
            }
            
            //let vertexCount = (endRow - startRow) * (endCol - startCol) * 6
            
            var vertices = [Float]()//count: vertexCount, repeatedValue: 0.0)
            
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
                
                let v = (latitude - geographicSouth) / (geographicNorth - geographicSouth)
                
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
                    if (elementsPerHeight == 1) {
                        heightSample = Double(heightmap[terrainOffset])
                    } else {
                        heightSample = 0
                        
                        if isBigEndian {
                            for (var elementOffset = 0; elementOffset < elementsPerHeight; ++elementOffset) {
                                heightSample = (heightSample * elementMultiplier) + Double(heightmap[terrainOffset + elementOffset])
                            }
                        } else {
                            for (var elementOffset = elementsPerHeight - 1; elementOffset >= 0; --elementOffset) {
                                heightSample = (heightSample * elementMultiplier) + Double(heightmap[terrainOffset + elementOffset])
                            }
                        }
                    }
                    
                    heightSample = heightSample * heightScale + heightOffset
                    
                    maximumHeight = max(maximumHeight, heightSample)
                    minimumHeight = min(minimumHeight, heightSample)
                    
                    if colIndex != col || rowIndex != row {
                        heightSample -= skirtHeight
                    }
                    
                    let nX = cosLatitude * cos(longitude)
                    let nY = cosLatitude * sin(longitude)
                    
                    let kX = radiiSquaredX * nX
                    let kY = radiiSquaredY * nY
                    
                    let gamma = sqrt((kX * nX) + (kY * nY) + (kZ * nZ))
                    let oneOverGamma = 1.0 / gamma
                    
                    let rSurfaceX = kX * oneOverGamma
                    let rSurfaceY = kY * oneOverGamma
                    let rSurfaceZ = kZ * oneOverGamma
                    
                    vertices.append(Float(rSurfaceX + nX * heightSample - relativeToCenter.x))
                    vertices.append(Float(rSurfaceY + nY * heightSample - relativeToCenter.y))
                    vertices.append(Float(rSurfaceZ + nZ * heightSample - relativeToCenter.z))
                    
                    vertices.append(Float(heightSample))
                    
                    let u = (longitude - geographicWest) / (geographicEast - geographicWest)
                    
                    vertices.append(Float(u))
                    vertices.append(Float(v))
                }
            }
            
            return (
                maximumHeight : maximumHeight,
                minimumHeight : minimumHeight,
                vertices: vertices
            )
    }

}