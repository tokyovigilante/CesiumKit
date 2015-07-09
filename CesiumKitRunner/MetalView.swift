//
//  AsyncGLView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import UIKit
import Metal
import QuartzCore.CAMetalLayer

public class MetalView: UIView {
    
    internal var renderQueue: dispatch_queue_t!
    
    private var _renderSemaphore: dispatch_semaphore_t!
    
    public private(set) var metalLayer: CAMetalLayer!
    
    override public class func layerClass() -> AnyClass {
        return CAMetalLayer.self
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
