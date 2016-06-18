//
//  ClockStep.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Constants to determine how much time advances with each call
 * to {@link Clock#tick}.
 *
 * @namespace
 * @alias ClockStep
 *
 * @see Clock
 * @see ClockRange
 */
public enum ClockStep {
    
    /**
    * {@link Clock#tick} advances the current time by a fixed step,
    * which is the number of seconds specified by {@link Clock#multiplier}.
    *
    * @type {Number}
    * @constant
    */
    case tickDependent
    
    /**
    * {@link Clock#tick} advances the current time by the amount of system
    * time elapsed since the previous call multiplied by {@link Clock#multiplier}.
    *
    * @type {Number}
    * @constant
    */
    case systemClockMultiplier
    
    /**
    * {@link Clock#tick} sets the clock to the current system time;
    * ignoring all other settings.
    *
    * @type {Number}
    * @constant
    */
    case systemClock
}
