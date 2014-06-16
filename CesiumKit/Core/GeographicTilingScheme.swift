//
//  GeographicTilingScheme.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
     * A tiling scheme for geometry referenced to a simple {@link GeographicProjection} where
     * longitude and latitude are directly mapped to X and Y.  This projection is commonly
     * known as geographic, equirectangular, equidistant cylindrical, or plate carrée.
     *
     * @alias GeographicTilingScheme
     * @constructor
     *
     * @param {Object} [options] Object with the following properties:
     * @param {Ellipsoid} [options.ellipsoid=Ellipsoid.WGS84] The ellipsoid whose surface is being tiled. Defaults to
     * the WGS84 ellipsoid.
     * @param {Rectangle} [options.rectangle=Rectangle.MAX_VALUE] The rectangle, in radians, covered by the tiling scheme.
     * @param {Number} [options.numberOfLevelZeroTilesX=2] The number of tiles in the X direction at level zero of
     * the tile tree.
     * @param {Number} [options.numberOfLevelZeroTilesY=1] The number of tiles in the Y direction at level zero of
     * the tile tree.
     */
class GeographicTilingScheme: TilingScheme {

        /**
         * Gets the ellipsoid that is tiled by this tiling scheme.
         * @memberof GeographicTilingScheme.prototype
         * @type {Ellipsoid}
         */
    var ellipsoid: Ellipsoid
    
    /**
    * Gets the rectangle, in radians, covered by this tiling scheme.
    * @memberof TilingScheme.prototype
    * @type {Rectangle}
    */
    var rectangle : Rectangle
    
    /**
    * Gets the map projection used by the tiling scheme.
    * @memberof TilingScheme.prototype
    * @type {Projection}
    */
    var projection : Projection

    var numberOfLevelZeroTilesX: Int
    var numberOfLevelZeroTilesY: Int
    
    init(
ellipsoid: Ellipsoid = Ellipsoid.wgs84Ellipsoid(),
rectangle: Rectangle = Rectangle.maxValue(),
numberOfLevelZeroTilesX: Int = 2,
numberOfLevelZeroTilesY: Int = 1) {
    
self.ellipsoid = ellipsoid
self.rectangle = rectangle
self.numberOfLevelZeroTilesX = numberOfLevelZeroTilesX
self.numberOfLevelZeroTilesY = numberOfLevelZeroTilesY
    self.projection = GeographicProjection()

}



    /**
     * Gets the total number of tiles in the X direction at a specified level-of-detail.
     *
     * @param {Number} level The level-of-detail.
     * @returns {Number} The number of tiles in the X direction at the given level.
     */
    func numberOfXTilesAtLevel(level: Int) -> Int {
        return numberOfLevelZeroTilesX << level
    }

    /**
     * Gets the total number of tiles in the Y direction at a specified level-of-detail.
     *
     * @param {Number} level The level-of-detail.
     * @returns {Number} The number of tiles in the Y direction at the given level.
     */
    func numberOfYTilesAtLevel(level: Int) -> Int {
        return numberOfLevelZeroTilesY << level
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
        var west = Math.toDegrees(rectangle.west)
        var south = Math.toDegrees(rectangle.south)
        var east = Math.toDegrees(rectangle.east)
        var north = Math.toDegrees(rectangle.north)

            return Rectangle(west, south, east, north);
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
    func tileXYToNativeRectangle(#x: Int, y: Int, level: Int) -> Rectangle {
        var rectangleRadians = tileXYToRectangle(x: x, y: y, level: level)
        rectangleRadians.west = Math.toDegrees(rectangleRadians.west)
        rectangleRadians.south = Math.toDegrees(rectangleRadians.south)
        rectangleRadians.east = Math.toDegrees(rectangleRadians.east)
        rectangleRadians.north = Math.toDegrees(rectangleRadians.north)
        return rectangleRadians
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
    func tileXYToRectangle(#x: Int, y: Int, level: Int) -> Rectangle {

        var xTiles = getNumberOfXTilesAtLevel(level)
        var yTiles = getNumberOfYTilesAtLevel(level)

        var xTileWidth = (rectangle.east - rectangle.west) / xTiles
        var west = x * xTileWidth + rectangle.west
        var east = (x + 1) * xTileWidth + rectangle.west

        var yTileHeight = (rectangle.north - rectangle.south) / yTiles
        var north = rectangle.north - y * yTileHeight
        var south = rectangle.north - (y + 1) * yTileHeight

            return Rectangle(west, south, east, north)

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
    func positionToTileXY(#position: Cartographic, level: Int) -> Cartesian2? {
        if (position.latitude > rectangle.north ||
            position.latitude < rectangle.south ||
            position.longitude < rectangle.west ||
            position.longitude > rectangle.east) {
            // outside the bounds of the tiling scheme
            return nil
        }

        var xTiles = getNumberOfXTilesAtLevel(level)
        var yTiles = getNumberOfYTilesAtLevel(level)

        var xTileWidth = (rectangle.east - rectangle.west) / xTiles
        var yTileHeight = (rectangle.north - rectangle.south) / yTiles

        var xTileCoordinate = (position.longitude - rectangle.west) / xTileWidth | 0
        if (xTileCoordinate >= xTiles) {
            xTileCoordinate = xTiles - 1
        }

        var yTileCoordinate = (rectangle.north - position.latitude) / yTileHeight | 0
        if (yTileCoordinate >= yTiles) {
            yTileCoordinate = yTiles - 1
        }

        return Cartesian2(x: xTileCoordinate, y: yTileCoordinate)
    }

}

