//
//  OrbitType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

enum OrbitType {
    
    case Circular
    
    case Elliptical
    
    case Parabolic
    
    case Hyperbolic
    
    static func fromEccentricity(eccentricity: Double, tolerance: Double) -> OrbitType {
        assert(eccentricity >= 0, "eccentricity cannot be negative.")
        
        if eccentricity <= tolerance {
            return .Circular
        } else if eccentricity < 1.0 - tolerance {
            return .Elliptical
        } else if eccentricity <= 1.0 + tolerance {
            return .Parabolic
        } else {
            return .Hyperbolic
        }
    }
    
}


