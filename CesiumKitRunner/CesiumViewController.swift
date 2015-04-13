//
//  GameViewController.swift
//  CesiumKitRunner
//
//  Created by Ryan Walklin on 10/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import UIKit

class CesiumViewController: UIViewController {
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
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

    
    //MARK: - GLKView delegate
    
    override func glkView(view: GLKView!, drawInRect rect: CGRect) {
        globe?.render(CGSizeMake(CGFloat(view.drawableWidth), CGFloat(view.drawableHeight)))
        if -lastFrameRateUpdate.timeIntervalSinceNow > 1.0 {
            lastFrameRateUpdate = NSDate()
            let performanceString = String(format: "%.02f fps (%.0f ms)", 1/timeSinceLastDraw, timeSinceLastDraw * 1000)
            println(performanceString)
        }
    }
    
    // MARK: - GLKViewControllerDelegate
    func update () {
        
    }
    
    deinit {
        
        globe = nil
        
        let glView = self.view as! GLKView
        
        if EAGLContext.currentContext() == glView.context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
}


//helper extensions to pass arguments to GL land
extension Array {
    func size () -> Int {
        return self.count * sizeofValue(self[0])
    }
}


