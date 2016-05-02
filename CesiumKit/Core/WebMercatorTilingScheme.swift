//
//  WebMercatorTilingScheme.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A tiling scheme for geometry referenced to a {@link WebMercatorProjection}, EPSG:3857.  This is
* the tiling scheme used by Google Maps, Microsoft Bing Maps, and most of ESRI ArcGIS Online.
*
* @alias WebMercatorTilingScheme
* @constructor
*
* @param {Object} [options] Object with the following properties:
* @param {Ellipsoid} [options.ellipsoid=Ellipsoid.WGS84] The ellipsoid whose surface is being tiled. Defaults to
* the WGS84 ellipsoid.
* @param {Number} [options.numberOfLevelZeroTilesX=1] The number of tiles in the X direction at level zero of
*        the tile tree.
* @param {Number} [options.numberOfLevelZeroTilesY=1] The number of tiles in the Y direction at level zero of
*        the tile tree.
* @param {Cartesian2} [options.rectangleSouthwestInMeters] The southwest corner of the rectangle covered by the
*        tiling scheme, in meters.  If this parameter or rectangleNortheastInMeters is not specified, the entire
*        globe is covered in the longitude direction and an equal distance is covered in the latitude
*        direction, resulting in a square projection.
* @param {Cartesian2} [options.rectangleNortheastInMeters] The northeast corner of the rectangle covered by the
*        tiling scheme, in meters.  If this parameter or rectangleSouthwestInMeters is not specified, the entire
*        globe is covered in the longitude direction and an equal distance is covered in the latitude
*        direction, resulting in a square projection.
*/

class WebMercatorTilingScheme: TilingScheme {
    /**
    * Gets the ellipsoid that is tiled by this tiling scheme.
    * @memberof WebMercatorTilingScheme.prototype
    * @type {Ellipsoid}
    */
    var ellipsoid: Ellipsoid
    
    /**
    * Gets the rectangle, in radians, covered by this tiling scheme.
    * @memberof WebMercatorTilingScheme.prototype
    * @type {Rectangle}
    */
    var rectangle: Rectangle
    
    /**
    * Gets the map projection used by this tiling scheme.
    * @memberof WebMercatorTilingScheme.prototype
    * @type {Projection}
    */
    var projection: MapProjection
    
    var numberOfLevelZeroTilesX: Int
    var numberOfLevelZeroTilesY: Int
    
    var rectangleSouthwestInMeters: Cartesian3
    var rectangleNortheastInMeters: Cartesian3
    
    init(ellipsoid: Ellipsoid = Ellipsoid.wgs84(),
        numberOfLevelZeroTilesX: Int = 1,
        numberOfLevelZeroTilesY: Int = 1,
        rectangleSouthwestInMeters: Cartesian3? = nil,
        rectangleNortheastInMeters: Cartesian3? = nil) {
            
            self.ellipsoid = ellipsoid
            self.projection = WebMercatorProjection(ellipsoid: ellipsoid)
            self.numberOfLevelZeroTilesX = numberOfLevelZeroTilesX
            self.numberOfLevelZeroTilesY = numberOfLevelZeroTilesY
            
            if (rectangleSouthwestInMeters != nil && rectangleNortheastInMeters != nil) {
                self.rectangleSouthwestInMeters = rectangleSouthwestInMeters!
                self.rectangleNortheastInMeters = rectangleNortheastInMeters!
            }
            else {
                let semimajorAxisTimesPi = self.ellipsoid.maximumRadius * M_PI;
                self.rectangleSouthwestInMeters = Cartesian3(x: -semimajorAxisTimesPi, y: -semimajorAxisTimesPi, z: 0.0)
                self.rectangleNortheastInMeters = Cartesian3(x: semimajorAxisTimesPi, y: semimajorAxisTimesPi, z: 0.0)
            }
            let southwest = self.projection.unproject(self.rectangleSouthwestInMeters)
            let northeast = self.projection.unproject(self.rectangleNortheastInMeters)
            self.rectangle = Rectangle(west: southwest.longitude, south: southwest.latitude,
                east: northeast.longitude, north: northeast.latitude)
    }
    
    
    /**
    * Gets the total number of tiles in the X direction at a specified level-of-detail.
    *
    * @param {Number} level The level-of-detail.
    * @returns {Number} The number of tiles in the X direction at the given level.
    */
    func numberOfXTilesAtLevel(level: Int) -> Int {
        return self.numberOfLevelZeroTilesX << level
    }
    
    /**
    * Gets the total number of tiles in the Y direction at a specified level-of-detail.
    *
    * @param {Number} level The level-of-detail.
    * @returns {Number} The number of tiles in the Y direction at the given level.
    */
    func numberOfYTilesAtLevel(level: Int) -> Int {
        return self.numberOfLevelZeroTilesY << level
    }
    
    /**
    * Transforms an rectangle specified in geodetic radians to the native coordinate system
    * of this tiling scheme.
    *
    * @param {Rectangle} rectangle The rectangle to transform.
    * @param {Rectangle} [result] The instance to which to copy the result, or undefined if a new instance
    *        should be created.
    * @returns {Rectangle} The specified 'result', or a new object containing the native rectangle if 'result'
    *          is undefined.
    */
    func rectangleToNativeRectangle(rectangle: Rectangle) -> Rectangle {
        let southwest = projection.project(rectangle.southwest)
        let northeast = projection.project(rectangle.northeast)
        
        return Rectangle(west: southwest.x, south: southwest.y, east: northeast.x, north: northeast.y)
        
    }
    
    /**
    * Converts tile x, y coordinates and level to an rectangle expressed in the native coordinates
    * of the tiling scheme.
    *
    * @param {Number} x The integer x coordinate of the tile.
    * @param {Number} y The integer y coordinate of the tile.
    * @param {Number} level The tile level-of-detail.  Zero is the least detailed.
    * @param {Object} [result] The instance to which to copy the result, or undefined if a new instance
    *        should be created.
    * @returns {Rectangle} The specified 'result', or a new object containing the rectangle
    *          if 'result' is undefined.
    */
    func tileXYToNativeRectangle(x x: Int, y: Int, level: Int) -> Rectangle {
        let xTiles = numberOfXTilesAtLevel(level)
        let yTiles = numberOfYTilesAtLevel(level)
        
        let xTileWidth = (rectangleNortheastInMeters.x - rectangleSouthwestInMeters.x) / Double(xTiles)
        let west = rectangleSouthwestInMeters.x + Double(x) * xTileWidth
        let east = rectangleSouthwestInMeters.x + Double(x + 1) * xTileWidth
        
        let yTileHeight = (rectangleNortheastInMeters.y - rectangleSouthwestInMeters.y) / Double(yTiles)
        let north = rectangleNortheastInMeters.y - Double(y) * yTileHeight
        let south = rectangleNortheastInMeters.y - Double(y + 1) * yTileHeight
        
        return Rectangle(west: west, south: south, east: east, north: north)
    }
    
    /**
    * Converts tile x, y coordinates and level to a cartographic rectangle in radians.
    *
    * @param {Number} x The integer x coordinate of the tile.
    * @param {Number} y The integer y coordinate of the tile.
    * @param {Number} level The tile level-of-detail.  Zero is the least detailed.
    * @param {Object} [result] The instance to which to copy the result, or undefined if a new instance
    *        should be created.
    * @returns {Rectangle} The specified 'result', or a new object containing the rectangle
    *          if 'result' is undefined.
    */
    func tileXYToRectangle(x x: Int, y: Int, level: Int) -> Rectangle {
        var nativeRectangle = tileXYToNativeRectangle(x: x, y: y, level: level)
        
        let southwest = projection.unproject(Cartesian3(x: nativeRectangle.west, y: nativeRectangle.south, z: 0.0))
        let northeast = projection.unproject(Cartesian3(x: nativeRectangle.east, y: nativeRectangle.north, z: 0.0))
        
        nativeRectangle.west = southwest.longitude
        nativeRectangle.south = southwest.latitude
        nativeRectangle.east = northeast.longitude
        nativeRectangle.north = northeast.latitude
        return nativeRectangle
    }
    
    /**
    * Calculates the tile x, y coordinates of the tile containing
    * a given cartographic position.
    *
    * @param {Cartographic} position The position.
    * @param {Number} level The tile level-of-detail.  Zero is the least detailed.
    * @param {Cartesian} [result] The instance to which to copy the result, or undefined if a new instance
    *        should be created.
    * @returns {Cartesian2} The specified 'result', or a new object containing the tile x, y coordinates
    *          if 'result' is undefined.
    */
    func positionToTileXY(position position: Cartographic, level: Int) -> (x: Int, y: Int)? {
        
        if !rectangle.contains(position) {
                // outside the bounds of the tiling scheme
                return nil
        }
        
        let xTiles = numberOfXTilesAtLevel(level)
        let yTiles = numberOfYTilesAtLevel(level)
        
        let overallWidth = rectangleNortheastInMeters.x - rectangleSouthwestInMeters.x
        let xTileWidth = overallWidth / Double(xTiles)
        let overallHeight = rectangleNortheastInMeters.y - rectangleSouthwestInMeters.y
        let yTileHeight = overallHeight / Double(yTiles)
        
        let webMercatorPosition = projection.project(position)
        let distanceFromWest = webMercatorPosition.x - rectangleSouthwestInMeters.x
        let distanceFromNorth = rectangleNortheastInMeters.y - webMercatorPosition.y
        
        var xTileCoordinate = Int(distanceFromWest / xTileWidth) | 0
        if (xTileCoordinate >= xTiles) {
            xTileCoordinate = xTiles - 1
        }
        var yTileCoordinate = Int(distanceFromNorth / yTileHeight) | 0
        if (yTileCoordinate >= yTiles) {
            yTileCoordinate = yTiles - 1
        }
        
        return (x: xTileCoordinate, y: yTileCoordinate)
    }
    
}
