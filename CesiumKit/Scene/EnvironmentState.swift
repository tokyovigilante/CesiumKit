//
//  EnvironmentState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

// Keeps track of the state of a frame. FrameState is the state across
// the primitives of the scene. This state is for internally keeping track
// of celestial and environment effects that need to be updated/rendered in
// a certain order as well as updating/tracking framebuffer usage.
struct EnvironmentState {
    var skyBoxCommand: DrawCommand! = nil
    var skyAtmosphereCommand: DrawCommand! = nil
    var sunDrawCommand: DrawCommand! = nil
    var sunComputeCommand: ComputeCommand! = nil
    var moonCommand: DrawCommand! = nil

    var isSunVisible: Bool = false
    var isMoonVisible: Bool = false
    var isSkyAtmosphereVisible: Bool = false

    var clearGlobeDepth: Bool = false
    var useDepthPlane: Bool = false

    var originalFramebuffer: Framebuffer! = nil
    var useGlobeDepthFramebuffer: Bool = false
    var useOIT: Bool = false
    var useFXAA: Bool = false
}
