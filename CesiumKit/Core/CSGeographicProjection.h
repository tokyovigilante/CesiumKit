//
//  CSGeographicProjection.h
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSProjection.h"

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
@interface CSGeographicProjection : CSProjection

@end
