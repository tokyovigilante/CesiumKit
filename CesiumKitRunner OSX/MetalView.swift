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
    
    internal var renderQueue: dispatch_queue_t!
    
    private var _renderSemaphore: dispatch_semaphore_t!
    
    public private(set) var metalLayer: CAMetalLayer!
    
    override public func makeBackingLayer() -> CALayer {
        return CAMetalLayer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
        setupMultitouchInput()
    }
    
    private func setupLayer () {
        metalLayer = self.layer as! CAMetalLayer
    }
    
    
    
    // MARK: - NSResponder
    private func setupMultitouchInput() {
        
    }
}
