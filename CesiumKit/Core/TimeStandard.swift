//
//  TimeStandard.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Provides the type of time standards which JulianDate can take as input.
 *
 * @namespace
 * @alias TimeStandard
 *
 * @see JulianDate
 */
enum TimeStandard {
    /**
    * Represents the coordinated Universal Time (UTC) time standard.
    *
    * UTC is related to TAI according to the relationship
    * <code>UTC = TAI - deltaT</code> where <code>deltaT</code> is the number of leap
    * seconds which have been introduced as of the time in TAI.
    *
    */
    case UTC
    
    /**
    * Represents the International Atomic Time (TAI) time standard.
    * TAI is the principal time standard to which the other time standards are related.
    */
    case TAI
}