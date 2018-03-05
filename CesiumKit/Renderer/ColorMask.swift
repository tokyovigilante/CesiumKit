//
//  ColorMask.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 5/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

struct ColorMask {
    var red = true
    var green = true
    var blue = true
    var alpha = true

    func description() -> String {
        return (red ? "r" : "x") + (green ? "g" : "x") + (blue ? "b" : "x") + (alpha ? "a" : "x")
    }

    func toMetal() -> MTLColorWriteMask {
        let writeMask: MTLColorWriteMask =  [(red ? .red : MTLColorWriteMask()), (green ? .green : MTLColorWriteMask()),  (blue ? .blue : MTLColorWriteMask()), (alpha ? .alpha : MTLColorWriteMask())]
        return writeMask
    }
}
