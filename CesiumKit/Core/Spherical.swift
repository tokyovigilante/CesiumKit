//
//  Spherical.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A set of curvilinear 3-dimensional coordinates.
*
* @alias Spherical
* @constructor
*
* @param {Number} [clock=0.0] The angular coordinate lying in the xy-plane measured from the positive x-axis and toward the positive y-axis.
* @param {Number} [cone=0.0] The angular coordinate measured from the positive z-axis and toward the negative z-axis.
* @param {Number} [magnitude=1.0] The linear coordinate measured from the origin.
*/
struct Spherical: Packable {
    var clock: Double = 0.0
    var cone: Double = 0.0
    var magnitude: Double = 1.0
    
    static let packedLength: Int = 3;
    
    func pack(inout array: [Float], startingIndex: Int) {
    }
    
    static func unpack(array: [Float], startingIndex: Int) -> Spherical {
        return Spherical()
    }
}