//
//  Interval.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 7/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Represents the closed interval [start, stop].
* @alias Interval
* @constructor
*
* @param {Number} [start=0.0] The beginning of the interval.
* @param {Number} [stop=0.0] The end of the interval.
*/
struct Interval: Equatable {
    /**
    * The beginning of the interval.
    * @type {Number}
    * @default 0.0
    */
    var start = 0.0
    /**
    * The end of the interval.
    * @type {Number}
    * @default 0.0
    */
    var stop = 0.0
}

func == (lhs: Interval, rhs: Interval) -> Bool {
    return lhs.start == rhs.start && lhs.stop == rhs.stop
}
