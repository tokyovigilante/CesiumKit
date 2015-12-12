//
//  TimeConstants.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Constants for time conversions like those done by {@link JulianDate}.
 *
 * @namespace
 * @alias TimeConstants
 *
 * @see JulianDate
 *
 * @private
 */
struct TimeConstants {
    
    /**
    * The number of seconds in one millisecond: <code>0.001</code>
    * @type {Number}
    * @constant
    */
    static let SecondsPerMillisecond: Double = 0.001
    
    /**
     * The number of seconds in one millisecond: <code>0.001</code>
     * @type {Number}
     * @constant
     */
    static let SecondsPerNanosecond: Double = 0.000000001
    
    /**
    * The number of seconds in one minute: <code>60</code>.
    * @type {Number}
    * @constant
    */
    static let SecondsPerMinute: Double = 60.0
    
    /**
    * The number of minutes in one hour: <code>60</code>.
    * @type {Number}
    * @constant
    */
    static let MinutesPerHour: Double = 60.0
    
    /**
    * The number of hours in one day: <code>24</code>.
    * @type {Number}
    * @constant
    */
    static let HoursPerDay: Double = 24.0
    
    /**
    * The number of seconds in one hour: <code>3600</code>.
    * @type {Number}
    * @constant
    */
    static let SecondsPerHour: Double = 3600.0
    
    /**
    * The number of minutes in one day: <code>1440</code>.
    * @type {Number}
    * @constant
    */
    static let MinutesPerDay: Double = 1440.0
    
    /**
    * The number of seconds in one day, ignoring leap seconds: <code>86400</code>.
    * @type {Number}
    * @constant
    */
    static let SecondsPerDay: Double = 86400.0
    
    /**
    * The number of days in one Julian century: <code>36525</code>.
    * @type {Number}
    * @constant
    */
    static let DaysPerJulianCentury: Double = 36525.0
    
    /**
    * One trillionth of a second.
    * @type {Number}
    * @constant
    */
    static let PicoSecond: Double = 0.000000001
    
    /**
    * The number of days to subtract from a Julian date to determine the
    * modified Julian date, which gives the number of days since midnight
    * on November 17, 1858.
    * @type {Number}
    * @constant
    */
    static let ModifiedJulianDateDifference: Double = 2400000.5
    
}