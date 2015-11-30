//
//  GeographicProjection.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A simple map projection where longitude and latitude are linearly mapped to X and Y by multiplying
* them by the {@link Ellipsoid#maximumRadius}.  This projection
* is commonly known as geographic, equirectangular, equidistant cylindrical, or plate carrée.  It
* is also known as EPSG:4326.
*
* @alias GeographicProjection
* @constructor
* @immutable
*
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid.
*
* @see WebMercatorProjection
*/
public struct GeographicProjection: MapProjection {
    
    public let ellipsoid: Ellipsoid
    public let semimajorAxis: Double
    public let oneOverSemimajorAxis: Double
  
    public init (ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        self.ellipsoid = ellipsoid
        semimajorAxis = ellipsoid.maximumRadius
        oneOverSemimajorAxis = 1.0 / semimajorAxis
    }
    
    /**
    * Projects a set of {@link Cartographic} coordinates, in radians, to map coordinates, in meters.
    * X and Y are the longitude and latitude, respectively, multiplied by the maximum radius of the
    * ellipsoid.  Z is the unmodified height.
    *
    * @param {Cartographic} cartographic The coordinates to project.
    * @param {Cartesian3} [result] An instance into which to copy the result.  If this parameter is
    *        undefined, a new instance is created and returned.
    * @returns {Cartesian3} The projected coordinates.  If the result parameter is not undefined, the
    *          coordinates are copied there and that instance is returned.  Otherwise, a new instance is
    *          created and returned.
    */
    public func project(cartographic: Cartographic) -> Cartesian3 {
    // Actually this is the special case of equidistant cylindrical called the plate carree
        return Cartesian3(x: cartographic.longitude * semimajorAxis,
            y: cartographic.latitude * semimajorAxis,
            z: cartographic.height)
    }
    
    /**
    * Unprojects a set of projected {@link Cartesian3} coordinates, in meters, to {@link Cartographic}
    * coordinates, in radians.  Longitude and Latitude are the X and Y coordinates, respectively,
    * divided by the maximum radius of the ellipsoid.  Height is the unmodified Z coordinate.
    *
    * @param {Cartesian3} cartesian The Cartesian position to unproject with height (z) in meters.
    * @param {Cartographic} [result] An instance into which to copy the result.  If this parameter is
    *        undefined, a new instance is created and returned.
    * @returns {Cartographic} The unprojected coordinates.  If the result parameter is not undefined, the
    *          coordinates are copied there and that instance is returned.  Otherwise, a new instance is
    *          created and returned.
    */
    public func unproject(cartesian: Cartesian3) -> Cartographic {
        let longitude = cartesian.x * oneOverSemimajorAxis
        let latitude = cartesian.y * oneOverSemimajorAxis
        let height = cartesian.z
        return Cartographic(longitude: longitude, latitude: latitude, height: height)
    }
    
}