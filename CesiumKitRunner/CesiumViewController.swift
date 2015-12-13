//
//  GameViewController.swift
//  CesiumKitRunner
//
//  Created by Ryan Walklin on 10/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import UIKit
import CesiumKit
import MetalKit

class CesiumViewController: UIViewController, MTKViewDelegate {
    
    private var _globe: CesiumGlobe!
    
    @IBOutlet var _metalView: MTKView!
    
    override func viewDidLoad() {
        

        let scaleFactor = UIScreen.mainScreen().nativeScale
        view.contentScaleFactor = scaleFactor

        let viewBoundsSize = view.bounds.size
        let renderWidth = viewBoundsSize.width * scaleFactor
        let renderHeight = viewBoundsSize.height * scaleFactor
        
        let renderSize = CGSizeMake(renderWidth, renderHeight)
                
        _metalView.delegate = self
        
        _metalView.device = MTLCreateSystemDefaultDevice()
        _metalView.colorPixelFormat = .BGRA8Unorm
        _metalView.depthStencilPixelFormat = .Depth32Float_Stencil8
        _metalView.framebufferOnly = false
        _metalView.preferredFramesPerSecond = 60

        _metalView.drawableSize = renderSize
        _metalView.autoResizeDrawable = true
            
        let options = CesiumOptions(
            clock: Clock(clockStep: .SystemClock, isUTC: false),
            imageryProvider: nil,
            terrain: true,
            skyBox: true,
            scene3DOnly: false
        )
    
        _globe = CesiumGlobe(view: _metalView, options: options)
        
        _globe.scene.imageryLayers.addImageryProvider(BingMapsImageryProvider())
        //_globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
        
        _globe.scene.camera.constrainedAxis = Cartesian3.unitZ()
        //_globe.scene.camera.setView(positionCartographic: Cartographic(longitude: 0.01, latitude: 0.01, height: 10), heading: 0, pitch: Math.toRadians(-90), roll: 0)
        //Murrumbeena
        //_globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 145.075, latitude: -37.892, height: 10), offsetCartesian: nil, offsetHPR: HeadingPitchRange(heading: 0.0, pitch: Math.toRadians(0), range: 1000))
        //Wellington
        //_globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 174.777222, latitude: -41.288889, height: 50000), target: Cartesian3.zero(), up: Cartesian3.unitZ())
        //_globe.scene.camera.viewRectangle(Rectangle.fromDegrees(west: 140.0, south: 20.0, east: 165.0, north: -90.0))
        
        //startRendering()

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
    
    func startRendering () {
        _metalView.paused = false
    }
    
    func stopRendering () {
        _metalView.paused = true
    }
    
    func drawInMTKView(view: MTKView) {
        let scaleFactor = view.contentScaleFactor
        let viewBoundsSize = view.bounds.size
        let renderWidth = viewBoundsSize.width * scaleFactor
        let renderHeight = viewBoundsSize.height * scaleFactor
        
        let renderSize = CGSizeMake(renderWidth , renderHeight)
        _globe.render(renderSize)
    }
    
    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        //let scale = view.contentScaleFactor
        //let layerSize = view.bounds.size
        
        //view.drawableSize = layerSize
        /*
        _metalView.metalLayer.contentsScale = scale
        _metalView.metalLayer.frame = CGRectMake(0, 0, layerSize.width, layerSize.height)
        _metalView.metalLayer.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)*/
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}



