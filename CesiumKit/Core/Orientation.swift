//
//  Orientation.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

public enum Orientation {
    case headingPitchRoll (heading: Double, pitch: Double, roll: Double)

    case directionUp (direction: Cartesian3, up: Cartesian3)
}
