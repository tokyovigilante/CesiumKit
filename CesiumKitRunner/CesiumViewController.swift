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

class CesiumViewController: GLKViewController {
    
    var setup = false
    
    private var lastFrameRateUpdate = NSDate()

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    private var globe: CesiumGlobe!
    
    override func viewDidLoad () {
        super.viewDidLoad()
        setupContext()
        setupGestureRecognisers()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        tearDownGL()
        
        let glView = self.view as! GLKView
        
        if EAGLContext.currentContext() == glView.context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    deinit {
        
        tearDownGL()
        
        let glView = self.view as! GLKView
        
        if EAGLContext.currentContext() == glView.context {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    private func setupContext () {
        
        let view: GLKView = self.view as! GLKView
       
        view.context = EAGLContext(API: .OpenGLES3)

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
        
        preferredFramesPerSecond = 60

        // enable Retina support
        
        view.contentScaleFactor = UIScreen.mainScreen().scale * 0.5
        
        // create globe
        let options = CesiumOptions(
            imageryProvider: BingMapsImageryProvider())
        globe = CesiumKit.CesiumGlobe(view: view, options: options)
        globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
//        globe.scene.camera.viewRectangle(Rectangle.fromDegrees(west: 140.0, south: 20.0, east: 165.0, north: -90.0))
    }
    
    func setupGestureRecognisers() {
        let pinch = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchGesture:"))
        view.addGestureRecognizer(pinch)
    }
    
    func tearDownGL () {
        
    }
    
    //MARK: - GLKView delegate
    
    override func glkView(view: GLKView!, drawInRect rect: CGRect) {
        
        globe?.render(rect.size)
        if -lastFrameRateUpdate.timeIntervalSinceNow > 1.0 {
            lastFrameRateUpdate = NSDate()
            let performanceString = String(format: "%.02f fps (%.0f ms)", 1/timeSinceLastDraw, timeSinceLastDraw * 1000)
            println(performanceString)
        }
    }
    
    // MARK: - GLKViewControllerDelegate
    func update () {
        
    }
    
    func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        
        
        if recognizer.scale < 1 {
            println("Pinched")
        } else {
            println("Zoomed")
        }
        /*if ([sender isKindOfClass:[UIPinchGestureRecognizer class]]) {
            [gesture setString:kPinchGesture];
            if (((UIGestureRecognizer*)sender).state == UIGestureRecognizerStateEnded) {
                if (((UIPinchGestureRecognizer*)sender).scale < 1) {
                    NSLog(@"Pinched");
                }
                else {
                    NSLog(@"Zoomed");
                }
                
            }*/
    }
}


//helper extensions to pass arguments to GL land
extension Array {
    func size () -> Int {
        return self.count * sizeofValue(self[0])
    }
}


