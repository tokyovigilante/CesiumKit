//
//  WindingOrder.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/07/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Winding order defines the order of vertices for a triangle to be considered front-facing.
*
* @namespace
* @alias WindingOrder
*/
enum WindingOrder: Int32 {
    /**
    * 0x0900. Vertices are in clockwise order.
    *
    * @type {Number}
    * @constant
    */
    case Clockwise = 0x0900, // WebGL: CW
    
    /**
    * 0x0901. Vertices are in counter-clockwise order.
    *
    * @type {Number}
    * @constant
    */
    CounterClockwise = 0x0901 // WebGL: CCW
}