//
//  ViewController.swift
//  CesiumKitRunner OSX
//
//  Created by Ryan Walklin on 1/08/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Cocoa
import MetalKit

class CesiumViewController: NSViewController {
    
    private var _cesiumKitController: CesiumKitController! = nil
    
    @IBOutlet var _metalView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer!.contentsScale = NSScreen.mainScreen()?.backingScaleFactor ?? 1.0

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
    

    
    
    
}

