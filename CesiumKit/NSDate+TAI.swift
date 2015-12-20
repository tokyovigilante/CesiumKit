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
     Calculate the [TAI](https://en.wikipedia.org/wiki/International_Atomic_Time) offset for a given UTC date
     
     - parameter date: UTC date to calculate offset for.
    */
    class func taiOffsetForDate (date: NSDate? = nil) -> NSTimeInterval {
        
        let taiDate = date ?? NSDate()
        
        var taiOffset = 0
    
        for leapSecond in _leapSeconds {
            if leapSecond.date.compare(taiDate) == .OrderedAscending {
                taiOffset = leapSecond.offset
            } else {
                break
            }
        }
        return NSTimeInterval(taiOffset)
    }
    
    class func taiDate() -> NSDate {
        return NSDate().taiOffsetDateForUTCDate()
    }
    
    /**
     Returns an NSDate using [TAI](https://en.wikipedia.org/wiki/International_Atomic_Time) for a date in UTC.
    */
    func taiOffsetDateForUTCDate() -> NSDate {
        return self.dateByAddingTimeInterval(NSDate.taiOffsetForDate(self))
    }
    
    /**
     Creates an NSDate using UTC for a date in TAI.
     */
    func utcDateForTAIOffsetDate() -> NSDate {
        return self.dateByAddingTimeInterval(-NSDate.taiOffsetForDate(self))
    }

    /**
    Creates an NSDate from Julian date components
    */
    convenience init (julianDayNumber: Int, secondsOfDay: Double) {
        let timeInterval = Double(julianDayNumber) + secondsOfDay / TimeConstants.SecondsPerDay
        let macReferenceOffset = TimeConstants.JulianEpochToMacEpochDifference - timeInterval
        self.init(timeIntervalSinceReferenceDate: macReferenceOffset)
    }
    
    func computeJulianDateComponents() -> (dayNumber: Int, secondsOfDay: Double) {
        // Algorithm from page 604 of the Explanatory Supplement to the
        // Astronomical Almanac (Seidelmann 1992).
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
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
    
    /**
     Returns an NSDate formatted from an ISO8601 date in UTC with the format yyyy-MM-ddTHH:mm:ssZ
     
     - parameter isoDate: Date string to generate date from.
     
     - returns: An NSDate object from the provided string or nil if the conversion failed.
     */
    class func fromUTCISO8601String (isoDate: String) -> NSDate? {
        return _iso8601Formatter.dateFromString(isoDate)
    }
    
    private static let _leapSeconds: [(date: NSDate, offset: Int)] = [
        (NSDate.fromUTCISO8601String("1972-01-01T00:00:00Z")!, 10), // January 1, 1972 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1972-07-01T00:00:00Z")!, 11), // July 1, 1972 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1973-01-01T00:00:00Z")!, 12), // January 1, 1973 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1974-01-01T00:00:00Z")!, 13), // January 1, 1974 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1975-01-01T00:00:00Z")!, 14), // January 1, 1975 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1976-01-01T00:00:00Z")!, 15), // January 1, 1976 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1977-01-01T00:00:00Z")!, 16), // January 1, 1977 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1978-01-01T00:00:00Z")!, 17), // January 1, 1978 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1979-01-01T00:00:00Z")!, 18), // January 1, 1979 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1980-01-01T00:00:00Z")!, 19), // January 1, 1980 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1981-07-01T00:00:00Z")!, 20), // July 1, 1981 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1982-07-01T00:00:00Z")!, 21), // July 1, 1982 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1983-07-01T00:00:00Z")!, 22), // July 1, 1983 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1985-07-01T00:00:00Z")!, 23), // July 1, 1985 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1988-01-01T00:00:00Z")!, 24), // January 1, 1988 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1990-01-01T00:00:00Z")!, 25), // January 1, 1990 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1991-01-01T00:00:00Z")!, 26), // January 1, 1991 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1992-07-01T00:00:00Z")!, 27), // July 1, 1992 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1993-07-01T00:00:00Z")!, 28), // July 1, 1993 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1994-07-01T00:00:00Z")!, 29), // July 1, 1994 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1996-01-01T00:00:00Z")!, 30), // January 1, 1996 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1997-07-01T00:00:00Z")!, 31), // July 1, 1997 00:00:00 UTC
        (NSDate.fromUTCISO8601String("1999-01-01T00:00:00Z")!, 32), // January 1, 1999 00:00:00 UTC
        (NSDate.fromUTCISO8601String("2006-01-01T00:00:00Z")!, 33), // January 1, 2006 00:00:00 UTC
        (NSDate.fromUTCISO8601String("2009-01-01T00:00:00Z")!, 34), // January 1, 2009 00:00:00 UTC
        (NSDate.fromUTCISO8601String("2012-07-01T00:00:00Z")!, 35), // July 1, 2012 00:00:00 UTC
        (NSDate.fromUTCISO8601String("2015-07-01T00:00:00Z")!, 36)  // July 1, 2015 00:00:00 UTC
    ]
    
}

private var _iso8601Formatter: NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter
}

