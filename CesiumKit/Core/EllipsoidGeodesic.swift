//
//  EllipsoidGeodesic.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 2/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Initializes a geodesic on the ellipsoid connecting the two provided planetodetic points.
 *
 * @alias EllipsoidGeodesic
 * @constructor
 *
 * @param {Cartographic} [start] The initial planetodetic point on the path.
 * @param {Cartographic} [end] The final planetodetic point on the path.
 * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the geodesic lies.
 */
class EllipsoidGeodesic {
    
    /**
     * Gets the ellipsoid.
     * @memberof EllipsoidGeodesic.prototype
     * @type {Ellipsoid}
     * @readonly
     */
    let ellipsoid: Ellipsoid
    
    /**
     * Gets the initial planetodetic point on the path.
     * @memberof EllipsoidGeodesic.prototype
     * @type {Cartographic?}
     * @readonly
     */
    fileprivate (set) var start: Cartographic? = nil
    
    /**
     * Gets the final planetodetic point on the path.
     * @memberof EllipsoidGeodesic.prototype
     * @type {Cartographic?}
     * @readonly
     */
    fileprivate (set) var end: Cartographic? = nil
    
    /**
     * Gets the heading at the initial point.
     * @memberof EllipsoidGeodesic.prototype
     * @type {Number}
     * @readonly
     */
    var startHeading: Double {
        assert(_distance != nil, "set end positions before getting startHeading")
        return _startHeading!
    }
    
    fileprivate var _startHeading: Double? = nil
    
    /**
     * Gets the heading at the final point.
     * @memberof EllipsoidGeodesic.prototype
     * @type {Number}
     * @readonly
     */
    var endHeading: Double {
        assert(_distance != nil, "set end positions before getting endHeading")
        return _endHeading!
    }
    
    fileprivate var _endHeading: Double? = nil
    
    /**
     * Gets the surface distance between the start and end point
     * @memberof EllipsoidGeodesic.prototype
     * @type {Number}
     * @readonly
     */
    var surfaceDistance: Double {
        assert(_distance != nil, "set end positions before getting surfaceDistance")
        return _distance!
    }
    
    fileprivate var _distance: Double? = nil
    
    fileprivate var _uSquared: Double? = nil
    
    fileprivate var _constants = EllipsoidGeodesicConstants()
    
    init (start: Cartographic? = nil, end: Cartographic? = nil, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        
        self.ellipsoid = ellipsoid
        
        if start != nil && end != nil {
            computeProperties(start: start!, end: end!)
        }
    }
    
    
    /**
     * Sets the start and end points of the geodesic
     *
     * @param {Cartographic} start The initial planetodetic point on the path.
     * @param {Cartographic} end The final planetodetic point on the path.
     */
    func setEndPoints (start: Cartographic, end: Cartographic) {
        computeProperties(start: start, end: end)
    }
    
    fileprivate func computeProperties(start: Cartographic, end: Cartographic) {
        let firstCartesian = ellipsoid.cartographicToCartesian(start).normalize()
        let lastCartesian = ellipsoid.cartographicToCartesian(end).normalize()
        
        assert(abs(abs(firstCartesian.angle(between: lastCartesian)) - .pi) >= 0.0125, "geodesic position is not unique")
        
        vincentyInverseFormula(major: ellipsoid.maximumRadius, minor: ellipsoid.minimumRadius,
            firstLongitude: start.longitude, firstLatitude: start.latitude, secondLongitude: end.longitude, secondLatitude: end.latitude)
        
        var surfaceStart = start
        var surfaceEnd = end
        surfaceStart.height = 0
        surfaceEnd.height = 0
        self.start = surfaceStart
        self.end = surfaceEnd
        
        setConstants()
    }
    
    fileprivate func vincentyInverseFormula(major: Double, minor: Double, firstLongitude: Double, firstLatitude: Double, secondLongitude: Double, secondLatitude: Double) {
        let eff = (major - minor) / major
        let l = secondLongitude - firstLongitude
        
        let u1 = atan((1 - eff) * tan(firstLatitude))
        let u2 = atan((1 - eff) * tan(secondLatitude))
        
        let cosineU1 = cos(u1)
        let sineU1 = sin(u1)
        let cosineU2 = cos(u2)
        let sineU2 = sin(u2)
        
        let cc = cosineU1 * cosineU2
        let cs = cosineU1 * sineU2
        let ss = sineU1 * sineU2
        let sc = sineU1 * cosineU2
        
        var lambda = l
        var lambdaDot = M_2_PI
        
        var cosineLambda = cos(lambda)
        var sineLambda = sin(lambda)
        
        var sigma: Double
        var cosineSigma: Double
        var sineSigma: Double
        var cosineSquaredAlpha: Double
        var cosineTwiceSigmaMidpoint: Double
        
        repeat {
            cosineLambda = cos(lambda)
            sineLambda = sin(lambda)
            
            let temp = cs - sc * cosineLambda
            sineSigma = sqrt(cosineU2 * cosineU2 * sineLambda * sineLambda + temp * temp)
            cosineSigma = ss + cc * cosineLambda
            
            sigma = atan2(sineSigma, cosineSigma)
            
            let sineAlpha: Double
            
            if sineSigma == 0.0 {
                sineAlpha = 0.0
                cosineSquaredAlpha = 1.0
            } else {
                sineAlpha = cc * sineLambda / sineSigma
                cosineSquaredAlpha = 1.0 - sineAlpha * sineAlpha
            }
            
            lambdaDot = lambda
            
            cosineTwiceSigmaMidpoint = cosineSigma - 2.0 * ss / cosineSquaredAlpha;
            
            if cosineTwiceSigmaMidpoint.isNaN {
                cosineTwiceSigmaMidpoint = 0.0
            }
            
            lambda = l + computeDeltaLambda(eff, sineAlpha: sineAlpha, cosineSquaredAlpha: cosineSquaredAlpha,
                sigma: sigma, sineSigma: sineSigma, cosineSigma: cosineSigma, cosineTwiceSigmaMidpoint: cosineTwiceSigmaMidpoint)
        } while (abs(lambda - lambdaDot) > Math.Epsilon12)
        
        let uSquared = cosineSquaredAlpha * (major * major - minor * minor) / (minor * minor)
        let A = 1.0 + uSquared * (4096.0 + uSquared * (uSquared * (320.0 - 175.0 * uSquared) - 768.0)) / 16384.0
        let B = uSquared * (256.0 + uSquared * (uSquared * (74.0 - 47.0 * uSquared) - 128.0)) / 1024.0
        
        let cosineSquaredTwiceSigmaMidpoint = cosineTwiceSigmaMidpoint * cosineTwiceSigmaMidpoint;
        let deltaSigma = B * sineSigma * (cosineTwiceSigmaMidpoint + B * (cosineSigma *
            (2.0 * cosineSquaredTwiceSigmaMidpoint - 1.0) - B * cosineTwiceSigmaMidpoint *
            (4.0 * sineSigma * sineSigma - 3.0) * (4.0 * cosineSquaredTwiceSigmaMidpoint - 3.0) / 6.0) / 4.0);
        
        _distance = minor * A * (sigma - deltaSigma)
        
        _startHeading = atan2(cosineU2 * sineLambda, cs - sc * cosineLambda)
        _endHeading = atan2(cosineU1 * sineLambda, cs * cosineLambda - sc)
        
        _uSquared = uSquared
    }
    
    fileprivate func setConstants() {
        let a = ellipsoid.maximumRadius
        let b = ellipsoid.minimumRadius
        let f = (a - b) / a
        
        let cosineHeading = cos(startHeading)
        let sineHeading = sin(startHeading)
        
        let tanU = (1 - f) * tan(start!.latitude)
        
        let cosineU = 1.0 / sqrt(1.0 + tanU * tanU)
        let sineU = cosineU * tanU
        
        let sigma = atan2(tanU, cosineHeading)
        
        let sineAlpha = cosineU * sineHeading
        let sineSquaredAlpha = sineAlpha * sineAlpha
        
        let cosineSquaredAlpha = 1.0 - sineSquaredAlpha
        let cosineAlpha = sqrt(cosineSquaredAlpha)
        
        let u2Over4 = _uSquared! / 4.0
        let u4Over16 = u2Over4 * u2Over4
        let u6Over64 = u4Over16 * u2Over4
        let u8Over256 = u4Over16 * u4Over16
        
        let a0: Double = (1.0 + u2Over4 - 3.0 * u4Over16 / 4.0 + 5.0 * u6Over64 / 4.0 - 175.0 * u8Over256 / 64.0)
        let a1: Double = (1.0 - u2Over4 + 15.0 * u4Over16 / 8.0 - 35.0 * u6Over64 / 8.0)
        let a2: Double = (1.0 - 3.0 * u2Over4 + 35.0 * u4Over16 / 4.0)
        let a3: Double = (1.0 - 5.0 * u2Over4)
        
        // FIXME: Compiler
        //let distanceRatio0 = a0 * sigma - a1 * sin(2.0 * sigma) * u2Over4 / 2.0 - a2 * sin(4.0 * sigma) * u4Over16 / 16.0 - a3 * sin(6.0 * sigma) * u6Over64 / 48.0 - sin(8.0 * sigma) * 5.0 * u8Over256 / 512
        let dr0 = a0 * sigma
        let dr1 = a1 * sin(2.0 * sigma) * u2Over4 / 2.0
        let dr2 = a2 * sin(4.0 * sigma) * u4Over16 / 16.0
        let dr3 = a3 * sin(6.0 * sigma) * u6Over64 / 48.0
        let dr4 = sin(8.0 * sigma) * 5.0 * u8Over256 / 512
        let distanceRatio = dr0 - dr1 - dr2 - dr3 - dr4
        
        _constants.a = a
        _constants.b = b
        _constants.f = f
        _constants.cosineHeading = cosineHeading
        _constants.sineHeading = sineHeading
        _constants.tanU = tanU
        _constants.cosineU = cosineU
        _constants.sineU = sineU
        _constants.sigma = sigma
        _constants.sineAlpha = sineAlpha
        _constants.sineSquaredAlpha = sineSquaredAlpha
        _constants.cosineSquaredAlpha = cosineSquaredAlpha
        _constants.cosineAlpha = cosineAlpha
        _constants.u2Over4 = u2Over4
        _constants.u4Over16 = u4Over16
        _constants.u6Over64 = u6Over64
        _constants.u8Over256 = u8Over256
        _constants.a0 = a0
        _constants.a1 = a1
        _constants.a2 = a2
        _constants.a3 = a3
        _constants.distanceRatio = distanceRatio
    }
    
    fileprivate func computeDeltaLambda(_ f: Double, sineAlpha: Double, cosineSquaredAlpha: Double, sigma: Double, sineSigma: Double, cosineSigma: Double, cosineTwiceSigmaMidpoint: Double) -> Double {
        let C = computeC(f, cosineSquaredAlpha: cosineSquaredAlpha)
        
        return (1.0 - C) * f * sineAlpha * (sigma + C * sineSigma * (cosineTwiceSigmaMidpoint +
            C * cosineSigma * (2.0 * cosineTwiceSigmaMidpoint * cosineTwiceSigmaMidpoint - 1.0)))
    }
    
    fileprivate func computeC(_ f: Double, cosineSquaredAlpha: Double) -> Double {
        return f * cosineSquaredAlpha * (4.0 + f * (4.0 - 3.0 * cosineSquaredAlpha)) / 16.0
    }
    
    /**
     * Provides the location of a point at the indicated portion along the geodesic.
     *
     * @param {Number} fraction The portion of the distance between the initial and final points.
     * @returns {Cartographic} The location of the point along the geodesic.
     */
    func interpolate (fraction: Double) -> Cartographic {
        assert(fraction >= 0.0 && fraction <= 1.0, "fraction out of bounds")
        assert(_distance != nil, "start and end must be set before calling funciton interpolateUsingSurfaceDistance")
        return interpolate(surfaceDistance: _distance! * fraction)
    }
    
    /**
     * Provides the location of a point at the indicated distance along the geodesic.
     *
     * @param {Number} distance The distance from the inital point to the point of interest along the geodesic
     * @returns {Cartographic} The location of the point along the geodesic.
     *
     * @exception {DeveloperError} start and end must be set before calling funciton interpolateUsingSurfaceDistance
     */
    func interpolate (surfaceDistance distance: Double) -> Cartographic {
        assert(_distance != nil, "start and end must be set before calling funciton interpolateUsingSurfaceDistance")
        
        let constants = _constants
        
        let s = constants.distanceRatio + distance / constants.b
        
        let cosine2S = cos(2.0 * s)
        let cosine4S = cos(4.0 * s)
        let cosine6S = cos(6.0 * s)
        let sine2S = sin(2.0 * s)
        let sine4S = sin(4.0 * s)
        let sine6S = sin(6.0 * s)
        let sine8S = sin(8.0 * s)
        
        let s2 = s * s;
        let s3 = s * s2;
        
        let u8Over256 = constants.u8Over256
        let u2Over4 = constants.u2Over4
        let u6Over64 = constants.u6Over64
        let u4Over16 = constants.u4Over16
        var sigma = 2.0 * s3 * u8Over256 * cosine2S / 3.0 +
            s * (1.0 - u2Over4 + 7.0 * u4Over16 / 4.0 - 15.0 * u6Over64 / 4.0 + 579.0 * u8Over256 / 64.0 -
                (u4Over16 - 15.0 * u6Over64 / 4.0 + 187.0 * u8Over256 / 16.0) * cosine2S -
                (5.0 * u6Over64 / 4.0 - 115.0 * u8Over256 / 16.0) * cosine4S -
                29.0 * u8Over256 * cosine6S / 16.0) +
            (u2Over4 / 2.0 - u4Over16 + 71.0 * u6Over64 / 32.0 - 85.0 * u8Over256 / 16.0) * sine2S +
            (5.0 * u4Over16 / 16.0 - 5.0 * u6Over64 / 4.0 + 383.0 * u8Over256 / 96.0) * sine4S -
            s2 * ((u6Over64 - 11.0 * u8Over256 / 2.0) * sine2S + 5.0 * u8Over256 * sine4S / 2.0) +
            (29.0 * u6Over64 / 96.0 - 29.0 * u8Over256 / 16.0) * sine6S +
            539.0 * u8Over256 * sine8S / 1536.0;
        
        let theta = asin(sin(sigma) * constants.cosineAlpha)
        let latitude = atan(constants.a / constants.b * tan(theta))
        
        // Redefine in terms of relative argument of latitude.
        sigma = sigma - constants.sigma
        
        let cosineTwiceSigmaMidpoint = cos(2.0 * constants.sigma + sigma)
        
        let sineSigma = sin(sigma)
        let cosineSigma = cos(sigma)
        
        let cc = constants.cosineU * cosineSigma;
        let ss = constants.sineU * sineSigma;
        
        let lambda = atan2(sineSigma * constants.sineHeading, cc - ss * constants.cosineHeading)
        
        let l = lambda - computeDeltaLambda(constants.f, sineAlpha: constants.sineAlpha, cosineSquaredAlpha: constants.cosineSquaredAlpha,
            sigma: sigma, sineSigma: sineSigma, cosineSigma: cosineSigma, cosineTwiceSigmaMidpoint: cosineTwiceSigmaMidpoint)
        
        return Cartographic(longitude: start!.longitude + l, latitude: latitude, height: 0.0)
    }
    
    fileprivate struct EllipsoidGeodesicConstants {
        var a = Double.nan
        var b = Double.nan
        var f = Double.nan
        var cosineHeading = Double.nan
        var sineHeading = Double.nan
        var tanU = Double.nan
        var cosineU = Double.nan
        var sineU = Double.nan
        var sigma = Double.nan
        var sineAlpha = Double.nan
        var sineSquaredAlpha = Double.nan
        var cosineSquaredAlpha = Double.nan
        var cosineAlpha = Double.nan
        var u2Over4 = Double.nan
        var u4Over16 = Double.nan
        var u6Over64 = Double.nan
        var u8Over256 = Double.nan
        var a0 = Double.nan
        var a1 = Double.nan
        var a2 = Double.nan
        var a3 = Double.nan
        var distanceRatio = Double.nan
    }
}
