//
//  CullFace.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

enum CullFace {
    case Front,
    Back,
    FrontAndBack
    
    func toGL() -> GLenum {
        switch self {
        case .Front:
            return GLenum(GL_FRONT)
        case .Back:
            return GLenum(GL_BACK)
        case .FrontAndBack:
            return GLenum(GL_FRONT_AND_BACK)
        }
    }
}