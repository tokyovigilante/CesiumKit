//
//  PrimitiveType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* The type of a geometric primitive, i.e., points, lines, and triangles.
*
* @exports PrimitiveType
*/
enum PrimitiveType: Int {
    /**
    * 0x0000.  Points primitive where each vertex (or index) is a separate point.
    *
    * @type {Number}
    * @constant
    */
    case Points = 0x0000,
    /**
    * 0x0001.  Lines primitive where each two vertices (or indices) is a line segment.  Line segments are not necessarily connected.
    *
    * @type {Number}
    * @constant
    */
    Lines = 0x0001,
    /**
    * 0x0002.  Line loop primitive where each vertex (or index) after the first connects a line to
    * the previous vertex, and the last vertex implicitly connects to the first.
    *
    * @type {Number}
    * @constant
    */
    LineLoop = 0x0002,
    /**
    * 0x0003.  Line strip primitive where each vertex (or index) after the first connects a line to the previous vertex.
    *
    * @type {Number}
    * @constant
    */
    LineStrip = 0x0003,
    /**
    * 0x0004.  Triangles primitive where each three vertices (or indices) is a triangle.  Triangles do not necessarily share edges.
    *
    * @type {Number}
    * @constant
    */
    Triangles = 0x0004,
    /**
    * 0x0005.  Triangle strip primitive where each vertex (or index) after the first two connect to
    * the previous two vertices forming a triangle.  For example, this can be used to model a wall.
    *
    * @type {Number}
    * @constant
    */
    TriangleStrip = 0x0005,
    /**
    * 0x0006.  Triangle fan primitive where each vertex (or index) after the first two connect to
    * the previous vertex and the first vertex forming a triangle.  For example, this can be used
    * to model a cone or circle.
    *
    * @type {Number}
    * @constant
    */
    TriangleFan = 0x0006
}
