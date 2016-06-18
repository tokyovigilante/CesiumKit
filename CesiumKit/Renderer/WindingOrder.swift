//
//  WindingOrder.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* Winding order defines the order of vertices for a triangle to be considered front-facing.
*
* @namespace
* @alias WindingOrder
*/
enum WindingOrder {
    /**
    * 0x0900. Vertices are in clockwise order.
    *
    * @type {Number}
    * @constant
    */
    case clockwise, // WebGL: CW
    
    /**
    * 0x0901. Vertices are in counter-clockwise order.
    *
    * @type {Number}
    * @constant
    */
    counterClockwise // WebGL: CCW
    
    func toMetal() -> MTLWinding {
        switch self {
        case .clockwise:
            return .clockwise
        case .counterClockwise:
            return .counterClockwise
        }
    }
}
