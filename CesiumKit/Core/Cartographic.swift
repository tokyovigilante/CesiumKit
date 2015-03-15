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
    static func fromRadians(#longitude: Double, latitude: Double, height: Double = 0.0) -> Cartographic {
        
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
    static func fromDegreees(longitude: Double, latitude: Double, height: Double = 0.0) -> Cartographic {
        let lon = Math.toRadians(longitude)
        let lat = Math.toRadians(latitude)
        
        return Cartographic.fromRadians(longitude: lon, latitude: lat, height: height);
    }
    
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
    func equalsEpsilon(other: Cartographic, epsilon: Double) -> Bool {
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