//
//  Clock.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
 * A simple clock for keeping track of simulated time.
 *
 * @alias Clock
 * @constructor
 *
 * @param {Object} [options] Object with the following properties:
 * @param {JulianDate} [options.startTime] The start time of the clock.
 * @param {JulianDate} [options.stopTime] The stop time of the clock.
 * @param {JulianDate} [options.currentTime] The current time.
 * @param {Number} [options.multiplier=1.0] Determines how much time advances when tick is called, negative values allow for advancing backwards.
 * @param {ClockStep} [options.clockStep=ClockStep.SYSTEM_CLOCK_MULTIPLIER] Determines if calls to <code>tick</code> are frame dependent or system clock dependent.
 * @param {ClockRange} [options.clockRange=ClockRange.UNBOUNDED] Determines how the clock should behave when <code>startTime</code> or <code>stopTime</code> is reached.
 * @param {Boolean} [options.canAnimate=true] Indicates whether tick can advance time.  This could be false if data is being buffered, for example.  The clock will only tick when both <code>canAnimate</code> and <code>shouldAnimate</code> are true.
 * @param {Boolean} [options.shouldAnimate=true] Indicates whether tick should attempt to advance time.  The clock will only tick when both <code>canAnimate</code> and <code>shouldAnimate</code> are true.
 *
 * @exception {DeveloperError} startTime must come before stopTime.
 *
 * @see ClockStep
 * @see ClockRange
 * @see JulianDate
 *
 * @example
 * // Create a clock that loops on Christmas day 2013 and runs in real-time.
 * var clock = new Cesium.Clock({
 *    startTime : Cesium.JulianDate.fromIso8601("2013-12-25"),
 *    currentTime : Cesium.JulianDate.fromIso8601("2013-12-25"),
 *    stopTime : Cesium.JulianDate.fromIso8601("2013-12-26"),
 *    clockRange : Cesium.ClockRange.LOOP_STOP,
 *    clockStep : Cesium.ClockStep.SYSTEM_CLOCK_MULTIPLIER
 * });
 */
public class Clock {
    
    /**
    * The start time of the clock.
    * @type {JulianDate}
    */
    var startTime: NSDate
    
    /**
    * The stop time of the clock.
    * @type {JulianDate}
    */
    var stopTime: NSDate
    
    /**
    * The current time.
    * @type {JulianDate}
    */
    var currentTime: NSDate
    
    /**
     * Determines if calls to <code>tick</code> are frame dependent or system clock dependent.
     * @type ClockStep
     * @default {@link ClockStep.SYSTEM_CLOCK_MULTIPLIER}
     */
    var clockStep: ClockStep
    
    /**
     * Determines how the clock should behave when <code>startTime</code> or <code>stopTime</code> is reached.
     * @type {ClockRange}
     * @default {@link ClockRange.UNBOUNDED}
     */
    var clockRange: ClockRange
    
    /**
     * Determines how much time advances when tick is called, negative values allow for advancing backwards.
     * If <code>clockStep</code> is set to ClockStep.TICK_DEPENDENT this is the number of seconds to advance.
     * If <code>clockStep</code> is set to ClockStep.SYSTEM_CLOCK_MULTIPLIER this value is multiplied by the
     * elapsed system time since the last call to tick.
     * @type {Number}
     * @default 1.0
     */
    var multiplier: Double
    
    /**
    * Indicates whether tick can advance time.  This could be false if data is being buffered,
    * for example.  The clock will only tick when both <code>canAnimate</code> and <code>shouldAnimate</code> are true.
    * @type {Boolean}
    * @default true
    */
    var canAnimate: Bool
    
    /**
     * Indicates whether tick should attempt to advance time.
     * The clock will only tick when both <code>canAnimate</code> and <code>shouldAnimate</code> are true.
     * @type {Boolean}
     * @default true
     */
    var shouldAnimate: Bool
    
    /**
    * An {@link Event} that is fired whenever <code>tick</code>.
    * @type {Event}
    */
    var onTick = Event()
    
    /**
     Indicates whether the clock keeps TAI or UTC time. Must be explicitly set for safety (for navigation etc.).
     Should always be set to false inside Cesium.
     */
    private (set) var isUTC: Bool
    
    private var _lastSystemTime: NSDate
    
    public init(
        startTime: NSDate? = nil,
        currentTime: NSDate? = nil,
        stopTime: NSDate? = nil,
        clockRange: ClockRange = .Unbounded,
        clockStep: ClockStep = .SystemClockMultiplier,
        multiplier: Double = 1.0,
        canAnimate: Bool = true,
        shouldAnimate: Bool = true,
        isUTC: Bool) {
            
            
            var startTime: NSDate? = startTime
            let startTimeUndefined = startTime == nil
            
            var stopTime: NSDate? = stopTime
            let stopTimeUndefined = stopTime == nil
            
            var currentTime: NSDate? = currentTime
            let currentTimeUndefined = currentTime == nil
            
            if startTimeUndefined && stopTimeUndefined && currentTimeUndefined {
                currentTime = NSDate.taiDate()
                startTime = currentTime!.copy() as? NSDate
                stopTime = startTime!.dateByAddingDays(1.0)
            } else if startTimeUndefined && stopTimeUndefined {
                startTime = currentTime!.copy() as? NSDate
                stopTime = currentTime?.dateByAddingDays(1.0)
            } else if startTimeUndefined && currentTimeUndefined {
                startTime = stopTime!.dateByAddingDays(-1.0)
                currentTime = startTime!.copy() as? NSDate
            } else if currentTimeUndefined && stopTimeUndefined {
                currentTime = startTime?.copy() as? NSDate
                stopTime = startTime!.dateByAddingDays(1.0)
            } else if currentTimeUndefined {
                currentTime = startTime!.copy() as? NSDate
            } else if stopTimeUndefined {
                stopTime = currentTime!.dateByAddingDays(1.0)
            } else if startTimeUndefined {
                startTime = currentTime!.copy() as? NSDate
            }
            
            assert(startTime!.compare(stopTime!) == .OrderedAscending, "startTime must come before stopTime.")
            
            self.startTime = startTime!
            self.stopTime = stopTime!
            self.currentTime = currentTime!

            self.multiplier = multiplier
            
            self.clockStep = clockStep
            
            self.clockRange = clockRange
            
            self.canAnimate = canAnimate
        
            self.shouldAnimate = shouldAnimate
            
            if isUTC {
                _lastSystemTime = NSDate()

            } else {
                _lastSystemTime = NSDate.taiDate()
            }
            
            self.isUTC = isUTC
    }
    
    /**
     * Advances the clock from the currentTime based on the current configuration options.
     * tick should be called every frame, regardless of whether animation is taking place
     * or not.  To control animation, use the <code>shouldAnimate</code> property.
     *
     * @returns {JulianDate} The new value of the <code>currentTime</code> property.
     */
    func tick() -> NSDate {
        
        let currentSystemTime: NSDate
        if isUTC {
            currentSystemTime = NSDate()
        } else {
            currentSystemTime = NSDate.taiDate()
        }
        
        var currentTime = self.currentTime.copy() as! NSDate
        
        if canAnimate && shouldAnimate {
            if clockStep == .SystemClock {
                currentTime = currentSystemTime
            } else {
                if clockStep == .TickDependent {
                    currentTime = currentTime.dateByAddingTimeInterval(multiplier)
                } else {
                    currentTime = currentTime.dateByAddingTimeInterval(multiplier * currentSystemTime.timeIntervalSinceDate(_lastSystemTime))
                }
                
                if clockRange == .Clamped {
                    if currentTime.compare(startTime) == .OrderedAscending {
                        currentTime = startTime.copy() as! NSDate
                    } else if currentTime.compare(stopTime) == .OrderedDescending {
                        currentTime = stopTime.copy() as! NSDate
                    }
                } else if clockRange == .LoopStop {
                    if currentTime.compare(startTime) == .OrderedAscending {
                        currentTime = startTime.copy() as! NSDate
                    }
                    while currentTime.compare(stopTime) == .OrderedAscending {
                        currentTime = currentTime.dateByAddingTimeInterval(stopTime.timeIntervalSinceDate(currentTime))
                    }
                }
            }
        }
        
        self.currentTime = currentTime
        _lastSystemTime = currentSystemTime
        //onTick.raiseEvent(self)
        return currentTime
    }
    
}