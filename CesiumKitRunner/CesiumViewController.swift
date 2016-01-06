//
//  GameViewController.swift
//  CesiumKitRunner
//
//  Created by Ryan Walklin on 10/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import UIKit
import MetalKit

class CesiumViewController: UIViewController {
    
    private var _cesiumKitController: CesiumKitController! = nil

    @IBOutlet var _metalView: MTKView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        view.contentScaleFactor = UIScreen.mainScreen().nativeScale
        
        _cesiumKitController = CesiumKitController(view: _metalView)
        _metalView.delegate = _cesiumKitController
        _cesiumKitController.startRendering()
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

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}



