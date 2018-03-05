//
//  MapProjection.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

public protocol MapProjection {

    var ellipsoid: Ellipsoid { get }
    var semimajorAxis: Double { get }
    var oneOverSemimajorAxis: Double { get }

    init (ellipsoid: Ellipsoid)

    /**
    * Converts geodetic ellipsoid coordinates, in radians, to the equivalent
    * X, Y, Z coordinates expressed in meters and returned in a {@link Cartesian3}.  The height
    * is copied unmodified to the Z coordinate.
    *
    * @memberof WebMercatorProjection
    *
    * @param {Cartographic} cartographic The cartographic coordinates in radians.
    * @param {Cartesian3} [result] The instance to which to copy the result, or undefined if a
    *        new instance should be created.
    * @returns {Cartesian3} The equivalent web mercator X, Y, Z coordinates, in meters.
    */
    func project(_ cartographic: Cartographic) -> Cartesian3

    /**
    * Converts X, Y coordinates, expressed in meters, to a {@link Cartographic}
    * containing geodetic ellipsoid coordinates.  The Z coordinate is copied unmodified to the
    * height.
    *
    * @memberof WebMercatorProjection
    *
    * @param {Cartesian3} cartesian The web mercator coordinates in meters.
    * @param {Cartographic} [result] The instance to which to copy the result, or undefined if a
    *        new instance should be created.
    * @returns {Cartographic} The equivalent cartographic coordinates.
    */
    func unproject(_ cartesian: Cartesian3) -> Cartographic

}
