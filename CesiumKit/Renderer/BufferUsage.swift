//
//  BufferUsage.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 14/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum BufferUsage: GLenum {
    case StreamDraw = 0x88E0,
    StaticDraw = 0x88E4,
    DynamicDraw = 0x88E8
}