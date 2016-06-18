//
//  Cartographic.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A position defined by longitude, latitude, and height.
* @alias Cartographic
* @constructor
*
* @param {Number} [longitude=0.0] The longitude, in radians.
* @param {Number} [latitude=0.0] The latitude, in radians.
* @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
*
* @see Ellipsoid
*/

public struct Cartographic {
    /**
    * The longitude, in radians.
    * @type {Number}
    * @default 0.0
    */
    public var longitude: Double = 0.0
    /**
    * The latitude, in radians.
    * @type {Number}
    * @default 0.0
    */
    public var latitude: Double = 0.0
    
    /**
    * The height, in meters, above the ellipsoid.
    * @type {Number}
    * @default 0.0
    */
    public var height: Double = 0.0
    
    public init(longitude: Double = 0.0, latitude: Double = 0.0, height: Double = 0.0) {
        self.longitude = longitude
        self.latitude = latitude
        self.height = height
    }
    
    /**
    * Creates a new Cartographic instance from longitude and latitude
    * specified in radians.
    *
    * @param {Number} longitude The longitude, in radians.
    * @param {Number} latitude The latitude, in radians.
    * @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if one was not provided.
    */
    static func fromRadians(longitude: Double, latitude: Double, height: Double = 0.0) -> Cartographic {
        
        return Cartographic(longitude: longitude, latitude: latitude, height: height)
    }
    
    /**
    * Creates a new Cartographic instance from longitude and latitude
    * specified in degrees.  The values in the resulting object will
    * be in radians.
    *
    * @param {Number} longitude The longitude, in degrees.
    * @param {Number} latitude The latitude, in degrees.
    * @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
    * @param {Cartographic} [result] The object onto which to store the result.
    * @returns {Cartographic} The modified result parameter or a new Cartographic instance if one was not provided.
    */
    static func fromDegreees(_ longitude: Double, latitude: Double, height: Double = 0.0) -> Cartographic {
        let lon = Math.toRadians(longitude)
        let lat = Math.toRadians(latitude)
        
        return Cartographic.fromRadians(longitude: lon, latitude: lat, height: height);
    }
    
    /*
     +    var cartesianToCartographicN = new Cartesian3();
     +    var cartesianToCartographicP = new Cartesian3();
     +    var cartesianToCartographicH = new Cartesian3();
     +    var wgs84OneOverRadii = new Cartesian3(1.0 / 6378137.0, 1.0 / 6378137.0, 1.0 / 6356752.3142451793);
     +    var wgs84OneOverRadiiSquared = new Cartesian3(1.0 / (6378137.0 * 6378137.0), 1.0 / (6378137.0 * 6378137.0), 1.0 / (6356752.3142451793 * 6356752.3142451793));
     +    var wgs84CenterToleranceSquared = CesiumMath.EPSILON1;
     +
     +    /**
     +     * Creates a new Cartographic instance from a Cartesian position. The values in the
     +     * resulting object will be in radians.
     +     *
     +     * @param {Cartesian3} cartesian The Cartesian position to convert to cartographic representation.
     +     * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
     +     * @param {Cartographic} [result] The object onto which to store the result.
     +     * @returns {Cartographic} The modified result parameter, new Cartographic instance if none was provided, or undefined if the cartesian is at the center of the ellipsoid.
     +     */
     +    Cartographic.fromCartesian = function(cartesian, ellipsoid, result) {
     +        var oneOverRadii = defined(ellipsoid) ? ellipsoid.oneOverRadii : wgs84OneOverRadii;
     +        var oneOverRadiiSquared = defined(ellipsoid) ? ellipsoid.oneOverRadiiSquared : wgs84OneOverRadiiSquared;
     +        var centerToleranceSquared = defined(ellipsoid) ? ellipsoid._centerToleranceSquared : wgs84CenterToleranceSquared;
     +
     +        //`cartesian is required.` is thrown from scaleToGeodeticSurface
     +        var p = scaleToGeodeticSurface(cartesian, oneOverRadii, oneOverRadiiSquared, centerToleranceSquared, cartesianToCartographicP);
     +
     +        if (!defined(p)) {
     +            return undefined;
     +        }
     +
     +        var n = Cartesian3.multiplyComponents(cartesian, oneOverRadiiSquared, cartesianToCartographicN);
     +        n = Cartesian3.normalize(n, n);
     +
     +        var h = Cartesian3.subtract(cartesian, p, cartesianToCartographicH);
     +
     +        var longitude = Math.atan2(n.y, n.x);
     +        var latitude = Math.asin(n.z);
     +        var height = CesiumMath.sign(Cartesian3.dot(h, cartesian)) * Cartesian3.magnitude(h);
     +
     +        if (!defined(result)) {
     +            return new Cartographic(longitude, latitude, height);
     +        }
     +        result.longitude = longitude;
     +        result.latitude = latitude;
     +        result.height = height;
     +        return result;
     +    };
     +  
    */
    
    /**
    * Compares the provided cartographics componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {Cartographic} [left] The first cartographic.
    * @param {Cartographic} [right] The second cartographic.
    * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
    */
    /* @infix func == (left: Cartographic, right: Cartographic) -> Bool {
    
    return (left.longitude == right.longitude) &&
    (left.latitude == right.latitude) &&
    (left.height == right.height))
    }*/
    
    /**
    * Compares the provided cartographics componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    *
    * @param {Cartographic} [left] The first cartographic.
    * @param {Cartographic} [right] The second cartographic.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    func equalsEpsilon(_ other: Cartographic, epsilon: Double) -> Bool {
        return (abs(self.longitude - other.longitude) <= epsilon) &&
            (abs(self.latitude - other.latitude) <= epsilon) &&
            (abs(self.height - other.height) <= epsilon)
    }
    
    /**
    * Creates a string representing the provided cartographic in the format '(longitude, latitude, height)'.
    *
    * @param {Cartographic} cartographic The cartographic to stringify.
    * @returns {String} A string representing the provided cartographic in the format '(longitude, latitude, height)'.
    */
    func toString() -> String {
        return "(\(longitude)), (\(latitude)), (\(height))";
    }
    
    /**
    * An immutable Cartographic instance initialized to (0.0, 0.0, 0.0).
    *
    * @type {Cartographic}
    * @constant
    */
    static func zero() -> Cartographic {
        return Cartographic(longitude: 0.0, latitude: 0.0, height: 0.0)
    }
    
}
