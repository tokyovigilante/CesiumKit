//
//  FrustumCommands.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//


/**
* Defines a list of commands whose geometry are bound by near and far distances from the camera.
* @alias FrustumCommands
* @constructor
*
* @param {Number} [near=0.0] The lower bound or closest distance from the camera.
* @param {Number} [far=0.0] The upper bound or farthest distance from the camera.
*
* @private
*/
class FrustumCommands {
    var near = 0.0
    var far = 0.0

    var commands = Array<[DrawCommand]>()
    
    init (near: Double = 0.0, far: Double = 0.0) {
        self.near = near
        self.far = far
        removeAll()
    }
    
    func removeAll() {
        commands = (0..<Pass.count).map { _ in [DrawCommand]() }
    }
    
}