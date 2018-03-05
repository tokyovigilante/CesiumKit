//
//  OrbitType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

enum OrbitType {

    case circular

    case elliptical

    case parabolic

    case hyperbolic

    static func fromEccentricity(_ eccentricity: Double, tolerance: Double) -> OrbitType {
        assert(eccentricity >= 0, "eccentricity cannot be negative.")

        if eccentricity <= tolerance {
            return .circular
        } else if eccentricity < 1.0 - tolerance {
            return .elliptical
        } else if eccentricity <= 1.0 + tolerance {
            return .parabolic
        } else {
            return .hyperbolic
        }
    }

}


