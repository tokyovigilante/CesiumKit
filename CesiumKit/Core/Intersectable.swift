//
//  BoundingVolume.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

// Protocol for bounding volumes

protocol BoundingVolume {
    
    var center: Cartesian3 { get }
    
    func intersectPlane(_ plane: Plane) -> Intersect
    
    func isOccluded (_ occluder: Occluder) -> Bool
    
    func distanceSquaredTo(_ cartesian: Cartesian3) -> Double
    
    func computePlaneDistances(_ position: Cartesian3, direction: Cartesian3) -> Interval 

}
