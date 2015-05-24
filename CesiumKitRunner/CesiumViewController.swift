//
//  GameViewController.swift
//  CesiumKitRunner
//
//  Created by Ryan Walklin on 10/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import UIKit
import CesiumKit

class CesiumViewController: UIViewController {
    
    private var _globe: CesiumGlobe!

    private var _displayLink: CADisplayLink!
    
    @IBOutlet var metalView: MetalView!
    
    override func viewDidLoad() {
        
        // create globe
        let options = CesiumOptions(imageryProvider: nil)
        
        _globe = CesiumGlobe(layer: metalView.metalLayer, options: options)
        
        //_globe.scene.imageryLayers.addImageryProvider(BingMapsImageryProvider())
        _globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
        
        _globe.scene.camera.constrainedAxis = Cartesian3.unitZ()
        
        _displayLink = CADisplayLink(target: self, selector: "render:")
        _displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    /*override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // propagate to CesiumKit
        globe?.eventHandler.handleTouchStart(touches, screenScaleFactor: Double(view.contentScaleFactor))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        globe?.eventHandler.handleTouchMove(touches, screenScaleFactor: Double(view.contentScaleFactor))
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        globe?.eventHandler.handleTouchEnd(touches)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        
    }*/
    
    func render (displayLink: CADisplayLink) {
        _globe.render()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}



