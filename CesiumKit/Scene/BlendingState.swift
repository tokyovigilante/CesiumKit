//
//  BlendingState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* The blending state combines {@link BlendEquation} and {@link BlendFunction} and the
* <code>enabled</code> flag to define the full blending state for combining source and
* destination fragments when rendering.
* <p>
* This is a helper when using custom render states with {@link Appearance#renderState}.
* </p>
*
* @namespace
* @alias BlendingState
*/
struct BlendingState: Equatable, CustomStringConvertible {
    let enabled: Bool
    let equationRgb: BlendEquation
    let equationAlpha: BlendEquation
    let functionSourceRgb: BlendFunction
    let functionSourceAlpha: BlendFunction
    let functionDestinationRgb: BlendFunction
    let functionDestinationAlpha: BlendFunction
    let color: Cartesian4?
    
    /**
    * Blending is disabled.
    *
    * @type {Object}
    * @constant
    */
    static func Disabled() -> BlendingState {
        return BlendingState(enabled: false,
            equationRgb: .add,
            equationAlpha: .add,
            functionSourceRgb: .zero,
            functionSourceAlpha: .zero,
            functionDestinationRgb: .zero,
            functionDestinationAlpha: .zero,
            color: nil)
    }
    
    /**
    * Blending is enabled using alpha blending, <code>source(source.alpha) + destination(1 - source.alpha)</code>.
    *
    * @type {Object}
    * @constant
    */
    static func AlphaBlend() -> BlendingState {
        return BlendingState(enabled: true,
            equationRgb : .add,
            equationAlpha : .add,
            functionSourceRgb : .sourceAlpha,
            functionSourceAlpha : .sourceAlpha,
            functionDestinationRgb : .oneMinusSourceAlpha,
            functionDestinationAlpha : .oneMinusSourceAlpha,
            color: nil)
    }
    
    static func AlphaBlend(_ color: Cartesian4) -> BlendingState {
        return BlendingState(enabled: true,
            equationRgb : .add,
            equationAlpha : .add,
            functionSourceRgb : .sourceAlpha,
            functionSourceAlpha : .sourceAlpha,
            functionDestinationRgb : .oneMinusSourceAlpha,
            functionDestinationAlpha : .oneMinusSourceAlpha,
            color: color)
    }
    
    /**
    * Blending is enabled using alpha blending with premultiplied alpha, <code>source + destination(1 - source.alpha)</code>.
    *
    * @type {Object}
    * @constant
    */
    static func PremultipliedAlphaBlend(_ color: Cartesian4) -> BlendingState {
        return BlendingState(enabled : true,
            equationRgb : .add,
            equationAlpha : .add,
            functionSourceRgb : .one,
            functionSourceAlpha : .one,
            functionDestinationRgb : .oneMinusSourceAlpha,
            functionDestinationAlpha : .oneMinusSourceAlpha,
            color: color)
    }
    
    /**
    * Blending is enabled using additive blending, <code>source(source.alpha) + destination</code>.
    *
    * @type {Object}
    * @constant
    */
    static func AdditiveBlend(_ color: Cartesian4) -> BlendingState {
        return BlendingState(enabled : true,
            equationRgb : .add,
            equationAlpha : .add,
            functionSourceRgb : .sourceAlpha,
            functionSourceAlpha : .sourceAlpha,
            functionDestinationRgb : .one,
            functionDestinationAlpha : .one,
            color: color)
    }
    
    var description: String {
        return "r\(equationRgb.rawValue):a\(equationAlpha.rawValue):sr\(functionSourceRgb.rawValue):sa\(functionSourceAlpha.rawValue):dr\(functionDestinationRgb.rawValue):da\(functionDestinationAlpha.rawValue):c\(color?.simdType.debugDescription)"

    }
}

func == (lhs: BlendingState, rhs: BlendingState) -> Bool {
    return lhs.description == rhs.description
}
