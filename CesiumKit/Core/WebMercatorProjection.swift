//
//  WebMercatorProjection.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* The map projection used by Google Maps, Bing Maps, and most of ArcGIS Online, EPSG:3857.  This
* projection use longitude and latitude expressed with the WGS84 and transforms them to Mercator using
* the spherical (rather than ellipsoidal) equations.
*
* @alias WebMercatorProjection
* @constructor
* @immutable
*
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid.
*
* @see GeographicProjection
*/
struct WebMercatorProjection: MapProjection {
    
    let ellipsoid: Ellipsoid
    let semimajorAxis: Double
    let oneOverSemimajorAxis: Double
    
    /**
    * The maximum latitude (both North and South) supported by a Web Mercator
    * (EPSG:3857) projection.  Technically, the Mercator projection is defined
    * for any latitude up to (but not including) 90 degrees, but it makes sense
    * to cut it off sooner because it grows exponentially with increasing latitude.
    * The logic behind this particular cutoff value, which is the one used by
    * Google Maps, Bing Maps, and Esri, is that it makes the projection
    * square.  That is, the rectangle is equal in the X and Y directions.
    *
    * The constant value is computed by calling:
    *    WebMercatorProjection.mercatorAngleToGeodeticLatitude(Math.PI)
    *
    * @type {Number}
    */
    static let maximumLatitude: Double = WebMercatorProjection.mercatorAngleToGeodeticLatitude(M_PI)
    
    init (ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        self.ellipsoid = ellipsoid
        semimajorAxis = ellipsoid.maximumRadius
        oneOverSemimajorAxis = 1.0 / semimajorAxis
    }
    /**
    * Converts a Mercator angle, in the range -PI to PI, to a geodetic latitude
    * in the range -PI/2 to PI/2.
    *
    * @param {Number} mercatorAngle The angle to convert.
    * @returns {Number} The geodetic latitude in radians.
    */
    static func mercatorAngleToGeodeticLatitude(mercatorAngle: Double) -> Double {
        return M_PI_2 - (2.0 * atan(exp(-mercatorAngle)))
    }
    
    /**
    * Converts a geodetic latitude in radians, in the range -PI/2 to PI/2, to a Mercator
    * angle in the range -PI to PI.
    *
    * @param {Number} latitude The geodetic latitude in radians.
    * @returns {Number} The Mercator angle.
    */
    static func geodeticLatitudeToMercatorAngle(latitude: Double) -> Double {
        // Clamp the latitude coordinate to the valid Mercator bounds.
        var clampedLat = latitude
        if (clampedLat > WebMercatorProjection.maximumLatitude) {
            clampedLat = WebMercatorProjection.maximumLatitude;
        } else if (clampedLat < -WebMercatorProjection.maximumLatitude) {
            clampedLat = -WebMercatorProjection.maximumLatitude;
        }
        let sinLatitude = sin(clampedLat);
        return 0.5 * log((1.0 + sinLatitude) / (1.0 - sinLatitude));
    }
    
    /**
    * Converts geodetic ellipsoid coordinates, in radians, to the equivalent Web Mercator
    * X, Y, Z coordinates expressed in meters and returned in a {@link Cartesian3}.  The height
    * is copied unmodified to the Z coordinate.
    *
    * @param {Cartographic} cartographic The cartographic coordinates in radians.
    * @param {Cartesian3} [result] The instance to which to copy the result, or undefined if a
    *        new instance should be created.
    * @returns {Cartesian3} The equivalent web mercator X, Y, Z coordinates, in meters.
    */
    func project(cartographic: Cartographic) -> Cartesian3 {
        return Cartesian3(x: cartographic.longitude * semimajorAxis,
            y: WebMercatorProjection.geodeticLatitudeToMercatorAngle(cartographic.latitude) * semimajorAxis,
            z: cartographic.height)
    }
    
    /**
    * Converts Web Mercator X, Y coordinates, expressed in meters, to a {@link Cartographic}
    * containing geodetic ellipsoid coordinates.  The Z coordinate is copied unmodified to the
    * height.
    *
    * @param {Cartesian3} cartesian The web mercator Cartesian position to unrproject with height (z) in meters.
    * @param {Cartographic} [result] The instance to which to copy the result, or undefined if a
    *        new instance should be created.
    * @returns {Cartographic} The equivalent cartographic coordinates.
    */
    func unproject(cartesian: Cartesian3) -> Cartographic  {
        return Cartographic(longitude: cartesian.x * oneOverSemimajorAxis,
            latitude: WebMercatorProjection.mercatorAngleToGeodeticLatitude(cartesian.y * oneOverSemimajorAxis),
            height: cartesian.z)
    }
}
