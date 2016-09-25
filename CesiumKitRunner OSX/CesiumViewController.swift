//
//  ViewController.swift
//  CesiumKitRunner OSX
//
//  Created by Ryan Walklin on 1/08/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Cocoa
import MetalKit
import CesiumKit

class CesiumViewController: NSViewController {
    
    fileprivate var _cesiumKitController: CesiumKitController! = nil
    
    @IBOutlet var _metalView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer!.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1.0
        _cesiumKitController = CesiumKitController(view: _metalView)
        _metalView.delegate = _cesiumKitController
        _cesiumKitController.startRendering()
    }
    
    override func viewWillAppear() {
        _metalView.window?.acceptsMouseMovedEvents = true
    }
    
    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let localPoint = _metalView.convert(locationInWindow, from: nil)
       
        let viewHeight = Double(_metalView.bounds.height)
        let position = Cartesian2(x: Double(localPoint.x), y: viewHeight - Double(localPoint.y))
        
        let modifier: KeyboardEventModifier?
        if event.modifierFlags.contains(.control) {
            modifier = .ctrl
        } else if event.modifierFlags.contains(.option) {
            modifier  = .alt
        } else if event.modifierFlags.contains(.shift) {
            modifier = .shift
        } else {
            modifier = nil
        }
        _cesiumKitController.handleMouseDown(.left, position: position, modifier: modifier)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let localPoint = _metalView.convert(locationInWindow, from: nil)
        let viewHeight = Double(_metalView.bounds.height)
        let position = Cartesian2(x: Double(localPoint.x), y: viewHeight - Double(localPoint.y))
        
        let modifier: KeyboardEventModifier?
        if event.modifierFlags.contains(.control) {
            modifier = .ctrl
        } else if event.modifierFlags.contains(.option) {
            modifier  = .alt
        } else if event.modifierFlags.contains(.shift) {
            modifier = .shift
        } else {
            modifier = nil
        }
        _cesiumKitController.handleMouseMove(.left, position: position, modifier: modifier)
    }
    
    override func mouseMoved(with event: NSEvent) {
    
    }
    
    override func mouseUp(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let localPoint = _metalView.convert(locationInWindow, from: nil)
        let viewHeight = Double(_metalView.bounds.height)
        let position = Cartesian2(x: Double(localPoint.x), y: viewHeight - Double(localPoint.y))
        
        let modifier: KeyboardEventModifier?
        if event.modifierFlags.contains(.control) {
            modifier = .ctrl
        } else if event.modifierFlags.contains(.option) {
            modifier  = .alt
        } else if event.modifierFlags.contains(.shift) {
            modifier = .shift
        } else {
            modifier = nil
        }
        _cesiumKitController.handleMouseUp(.left, position: position, modifier: modifier)
    }
    
    override func scrollWheel(with event: NSEvent) {
        _cesiumKitController.handleWheel(Double(event.deltaX), deltaY: Double(event.deltaY))
    }
    
    
}

