//
//  MetalView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/08/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

//
//  AsyncGLView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Cocoa
import Metal
import QuartzCore.CAMetalLayer

public class MetalView: NSView {

    public private(set) var metalLayer: CAMetalLayer!
    
    override public func makeBackingLayer() -> CALayer {
        self.metalLayer = CAMetalLayer()
        return metalLayer
    }

}
