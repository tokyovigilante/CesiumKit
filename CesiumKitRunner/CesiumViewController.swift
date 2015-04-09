//
//  GameViewController.swift
//  CesiumKitRunner
//
//  Created by Ryan Walklin on 10/12/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES
import GLKit
import CesiumKit

class CesiumViewController: UIViewController {
    
    private var _renderQueue: dispatch_queue_t!
    private var _renderSemaphore: dispatch_semaphore_t!
    
    private var lastFrameRateUpdate = NSDate()    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    private func setupContext () {
        
        /*let view: AsyncGLView = self.view as! AsyncGLView
        view.renderCallback = { (drawRect: CG) (globe?.render(Cartesian2(Double(view.drawableWidth), Double(view.drawableHeight))) }
        
        /*view.context = EAGLContext(API: .OpenGLES3)
        view.context.multiThreaded = true
        
        if !EAGLContext.setCurrentContext(view.context) {
            println("Failed to set current OpenGL context!")
            exit(1)
        }
        
        // Configure renderbuffers created by the view
        view.drawableColorFormat = .RGBA8888
        view.drawableDepthFormat = .Format24
        view.drawableStencilFormat = .Format8
        
        // Enable multisampling
        //view.drawableMultisample = .Multisample4X
        
        //preferredFramesPerSecond = 60*/
        
        // enable Retina support on device
        #if arch(i386) || arch(x86_64)
            // render low-res for simulator (Software GL)
            view.contentScaleFactor = UIScreen.mainScreen().scale * 0.25
            #else
            // render at native (screen pixel) scale for retina screens
            view.contentScaleFactor = UIScreen.mainScreen().nativeScale
        #endif
        
        // create globe
        let options = CesiumOptions(
            imageryProvider: nil)
        globe = CesiumKit.CesiumGlobe(view: view, options: options)
        globe.scene.imageryLayers.addImageryProvider(BingMapsImageryProvider())
        //globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
        globe.scene.camera.constrainedAxis = Cartesian3.unitZ()*/
    }
    
    // MARK: - NSResponder
    func setupMultitouchInput() {
        
    }
    
    private var globe: CesiumGlobe!
    
    override func viewDidLoad () {
        super.viewDidLoad()
        setupContext()
        setupMultitouchInput()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        tearDownGL()
        
        let glView = self.view as! GLKView
        
        if EAGLContext.currentContext() == glView.context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
        
    }
    
    //MARK: - GLKView delegate
    
    //override func glkView(view: GLKView!, drawInRect rect: CGRect) {
        
        //globe?.render(Cartesian2(Double(view.drawableWidth), Double(view.drawableHeight)))
        //if -lastFrameRateUpdate.timeIntervalSinceNow > 1.0 {
            //lastFrameRateUpdate = NSDate()
            //let performanceString = String(format: "%.02f fps (%.0f ms)", 1/timeSinceLastDraw, timeSinceLastDraw * 1000)
            //println(performanceString)
        
    //}
    
    // MARK: - GLKViewControllerDelegate
    func update () {
        
    }
    
    func tearDownGL () {
        globe = nil
    }
    
    deinit {
        
        /*tearDownGL()
        
        let glView = self.view as! GLKView
        
        if EAGLContext.currentContext() == glView.context {
            EAGLContext.setCurrentContext(nil)
        }*/

    }
}


//helper extensions to pass arguments to GL land
extension Array {
    func size () -> Int {
        return self.count * sizeofValue(self[0])
    }
}


