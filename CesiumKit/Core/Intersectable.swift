//
//  Intersectable.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

// Protocol for objects which support plane intersection testing

protocol Intersectable {
    func intersectPlane(plane: Plane) -> Intersect
}