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
    
    private var _cesiumKitController: CesiumKitController! = nil
    
    @IBOutlet var _metalView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer!.contentsScale = NSScreen.mainScreen()?.backingScaleFactor ?? 1.0
        _cesiumKitController = CesiumKitController(view: _metalView)
        _metalView.delegate = _cesiumKitController
        _cesiumKitController.startRendering()
    }
    
    override func viewWillAppear() {
        _metalView.window?.acceptsMouseMovedEvents = true
    }
    
    override func mouseDown(event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let localPoint = _metalView.convertPoint(locationInWindow, fromView: nil)
       
        let viewHeight = Double(_metalView.bounds.height)
        let position = Cartesian2(x: Double(localPoint.x), y: viewHeight - Double(localPoint.y))
        
        let modifier: KeyboardEventModifier?
        if event.modifierFlags.contains(.ControlKeyMask) {
            modifier = .Ctrl
        } else if event.modifierFlags.contains(.AlternateKeyMask) {
            modifier  = .Alt
        } else if event.modifierFlags.contains(.ShiftKeyMask) {
            modifier = .Shift
        } else {
            modifier = nil
        }
        _cesiumKitController.handleMouseDown(.Left, position: position, modifier: modifier)
    }
    
    override func mouseDragged(event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let localPoint = _metalView.convertPoint(locationInWindow, fromView: nil)
        let viewHeight = Double(_metalView.bounds.height)
        let position = Cartesian2(x: Double(localPoint.x), y: viewHeight - Double(localPoint.y))
        
        let modifier: KeyboardEventModifier?
        if event.modifierFlags.contains(.ControlKeyMask) {
            modifier = .Ctrl
        } else if event.modifierFlags.contains(.AlternateKeyMask) {
            modifier  = .Alt
        } else if event.modifierFlags.contains(.ShiftKeyMask) {
            modifier = .Shift
        } else {
            modifier = nil
        }
        _cesiumKitController.handleMouseMove(.Left, position: position, modifier: modifier)
    }
    
    override func mouseMoved(event: NSEvent) {
    
    }
    
    override func mouseUp(event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let localPoint = _metalView.convertPoint(locationInWindow, fromView: nil)
        let viewHeight = Double(_metalView.bounds.height)
        let position = Cartesian2(x: Double(localPoint.x), y: viewHeight - Double(localPoint.y))
        
        let modifier: KeyboardEventModifier?
        if event.modifierFlags.contains(.ControlKeyMask) {
            modifier = .Ctrl
        } else if event.modifierFlags.contains(.AlternateKeyMask) {
            modifier  = .Alt
        } else if event.modifierFlags.contains(.ShiftKeyMask) {
            modifier = .Shift
        } else {
            modifier = nil
        }
        _cesiumKitController.handleMouseUp(.Left, position: position, modifier: modifier)
    }
    
    override func scrollWheel(event: NSEvent) {
        _cesiumKitController.handleWheel(Double(event.deltaX), deltaY: Double(event.deltaY))
    }
    
    
}

