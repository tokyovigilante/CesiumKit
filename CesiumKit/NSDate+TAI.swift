//
//  NSDate+TAI.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

extension NSDate {
    
    /**
     Creates an NSDate using [TAI](https://en.wikipedia.org/wiki/International_Atomic_Time) for a date in UTC.
     
    */
    class func taiDate (date: NSDate? = nil) -> NSDate {
        
        var taiDate = date ?? NSDate()
        
        var taiDifference = 0
        for leapSecond in leapSeconds {
            if taiDate.compare(leapSecond) == .OrderedDescending {
                taiDifference++
            }
        }
        
        return taiDate.dateByAddingTimeInterval(Double(taiDifference))
    }
    
    func dateByAddingDays(days: Double) -> NSDate {
        return self.dateByAddingTimeInterval(days * TimeConstants.SecondsPerDay)
    }
    
    func computeJulianDateComponents() -> (dayNumber: Int, secondsOfDay: Double)/*year: Int, month, day, hour, minute, second, millisecond)*/ {
        // Algorithm from page 604 of the Explanatory Supplement to the
        // Astronomical Almanac (Seidelmann 1992).
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let dateComponents = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second, .Nanosecond], fromDate: self)
        
        let a = ((dateComponents.month - 14) / 12) | 0
        let b = dateComponents.year + 4800 + a
        var dayNumber = (((1461 * b) / 4) | 0) + (((367 * (dateComponents.month - 2 - 12 * a)) / 12) | 0) - (((3 * (((b + 100) / 100) | 0)) / 4) | 0) + dateComponents.day - 32075
        
        // JulianDates are noon-based
        var hour = dateComponents.hour - 12
        if hour < 0 {
            hour += 24
        }
        
        let secondsOfDay: Double = Double(dateComponents.second) + (Double(hour) * TimeConstants.SecondsPerHour) + (Double(dateComponents.minute) * TimeConstants.SecondsPerMinute) + (Double(dateComponents.nanosecond) * TimeConstants.SecondsPerNanosecond)
        
        if secondsOfDay >= 43200.0 {
            dayNumber -= 1
        }

        return (dayNumber, secondsOfDay)
    }
    
}

private let leapSeconds: [NSDate] = [
    /*
JulianDate.leapSeconds = [
new LeapSecond(new JulianDate(2441317, 43210.0, TimeStandard.TAI), 10), // January 1, 1972 00:00:00 UTC
new LeapSecond(new JulianDate(2441499, 43211.0, TimeStandard.TAI), 11), // July 1, 1972 00:00:00 UTC
new LeapSecond(new JulianDate(2441683, 43212.0, TimeStandard.TAI), 12), // January 1, 1973 00:00:00 UTC
new LeapSecond(new JulianDate(2442048, 43213.0, TimeStandard.TAI), 13), // January 1, 1974 00:00:00 UTC
new LeapSecond(new JulianDate(2442413, 43214.0, TimeStandard.TAI), 14), // January 1, 1975 00:00:00 UTC
new LeapSecond(new JulianDate(2442778, 43215.0, TimeStandard.TAI), 15), // January 1, 1976 00:00:00 UTC
new LeapSecond(new JulianDate(2443144, 43216.0, TimeStandard.TAI), 16), // January 1, 1977 00:00:00 UTC
new LeapSecond(new JulianDate(2443509, 43217.0, TimeStandard.TAI), 17), // January 1, 1978 00:00:00 UTC
new LeapSecond(new JulianDate(2443874, 43218.0, TimeStandard.TAI), 18), // January 1, 1979 00:00:00 UTC
new LeapSecond(new JulianDate(2444239, 43219.0, TimeStandard.TAI), 19), // January 1, 1980 00:00:00 UTC
new LeapSecond(new JulianDate(2444786, 43220.0, TimeStandard.TAI), 20), // July 1, 1981 00:00:00 UTC
new LeapSecond(new JulianDate(2445151, 43221.0, TimeStandard.TAI), 21), // July 1, 1982 00:00:00 UTC
new LeapSecond(new JulianDate(2445516, 43222.0, TimeStandard.TAI), 22), // July 1, 1983 00:00:00 UTC
new LeapSecond(new JulianDate(2446247, 43223.0, TimeStandard.TAI), 23), // July 1, 1985 00:00:00 UTC
new LeapSecond(new JulianDate(2447161, 43224.0, TimeStandard.TAI), 24), // January 1, 1988 00:00:00 UTC
new LeapSecond(new JulianDate(2447892, 43225.0, TimeStandard.TAI), 25), // January 1, 1990 00:00:00 UTC
new LeapSecond(new JulianDate(2448257, 43226.0, TimeStandard.TAI), 26), // January 1, 1991 00:00:00 UTC
new LeapSecond(new JulianDate(2448804, 43227.0, TimeStandard.TAI), 27), // July 1, 1992 00:00:00 UTC
new LeapSecond(new JulianDate(2449169, 43228.0, TimeStandard.TAI), 28), // July 1, 1993 00:00:00 UTC
new LeapSecond(new JulianDate(2449534, 43229.0, TimeStandard.TAI), 29), // July 1, 1994 00:00:00 UTC
new LeapSecond(new JulianDate(2450083, 43230.0, TimeStandard.TAI), 30), // January 1, 1996 00:00:00 UTC
new LeapSecond(new JulianDate(2450630, 43231.0, TimeStandard.TAI), 31), // July 1, 1997 00:00:00 UTC
new LeapSecond(new JulianDate(2451179, 43232.0, TimeStandard.TAI), 32), // January 1, 1999 00:00:00 UTC
new LeapSecond(new JulianDate(2453736, 43233.0, TimeStandard.TAI), 33), // January 1, 2006 00:00:00 UTC
new LeapSecond(new JulianDate(2454832, 43234.0, TimeStandard.TAI), 34), // January 1, 2009 00:00:00 UTC
new LeapSecond(new JulianDate(2456109, 43235.0, TimeStandard.TAI), 35), // July 1, 2012 00:00:00 UTC
new LeapSecond(new JulianDate(2457204, 43236.0, TimeStandard.TAI), 36)  // July 1, 2015 00:00:00 UTC
];
*/
]