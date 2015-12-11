//
//  ClockRange.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Constants used by {@link Clock#tick} to determine behavior
 * when {@link Clock#startTime} or {@link Clock#stopTime} is reached.
 *
 * @namespace
 * @alias ClockRange
 *
 * @see Clock
 * @see ClockStep
 */
public enum ClockRange {
    
    /**
    * {@link Clock#tick} will always advances the clock in its current direction.
    *
    * @type {Number}
    * @constant
    */
    case Unbounded
    
    /**
    * When {@link Clock#startTime} or {@link Clock#stopTime} is reached,
    * {@link Clock#tick} will not advance {@link Clock#currentTime} any further.
    *
    * @type {Number}
    * @constant
    */
    case Clamped
    
    /**
    * When {@link Clock#stopTime} is reached, {@link Clock#tick} will advance
    * {@link Clock#currentTime} to the opposite end of the interval.  When
    * time is moving backwards, {@link Clock#tick} will not advance past
    * {@link Clock#startTime}
    *
    * @type {Number}
    * @constant
    */
    case LoopStop
}