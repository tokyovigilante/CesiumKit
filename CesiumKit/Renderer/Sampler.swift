//
//  Sampler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

struct Sampler {
    var wrapS: Int  = GL_CLAMP_TO_EDGE
    var wrapT: Int = GL_CLAMP_TO_EDGE
    var minificationFilter: Int = GL_LINEAR
    var magnificationFilter: Int = GL_LINEAR
    var maximumAnisotropy: Double = 1.0
}