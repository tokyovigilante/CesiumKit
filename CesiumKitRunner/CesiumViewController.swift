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
        
        view.contentScaleFactor = UIScreen.mainScreen().nativeScale

        // create globe
        let options = CesiumOptions(imageryProvider: nil)
        
        _globe = CesiumGlobe(view: view, layer: metalView.metalLayer, options: options)
        
        //_globe.scene.imageryLayers.addImageryProvider(BingMapsImageryProvider())
        //_globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
        
        _globe.scene.camera.constrainedAxis = Cartesian3.unitZ()
        
        //Murrumbeena
        //_globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 145.075, latitude: -37.892, height: 1000), offsetCartesian: nil, offsetHPR: HeadingPitchRange(heading: 0.0, pitch: Math.toRadians(-90), range: 1000))
        //Wellington
        //_globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 174.777222, latitude: -41.288889, height: 50000), target: Cartesian3.zero(), up: Cartesian3.unitZ())
        //_globe.scene.camera.viewRectangle(Rectangle.fromDegrees(west: 140.0, south: 20.0, east: 165.0, north: -90.0))
        
        _displayLink = CADisplayLink(target: self, selector: "render:")
        _displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
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
        _globe.render(metalView.metalLayer.drawableSize)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let window = metalView.window {
            let scale = window.screen.nativeScale
            let layerSize = view.bounds.size
            
            metalView.contentScaleFactor = scale
            metalView.metalLayer.frame = CGRectMake(0, 0, layerSize.width, layerSize.height)
            metalView.metalLayer.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)
        }    
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}



