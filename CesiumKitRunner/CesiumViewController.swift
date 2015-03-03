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
            imageryProvider: BingMapsImageryProvider(options: BingMapsImageryProvider.Options(mapStyle: .AerialWithLabels)))
        globe = CesiumKit.CesiumGlobe(view: view, options: options)
        globe.scene.imageryLayers.addImageryProvider(TileCoordinateImageryProvider())
        
        //Murrumbeena
        globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 145.075, latitude: -37.892, height: 1000), target: Cartesian3.zero(), up: Cartesian3.unitZ())
        globe.scene.camera.lookUp(Math.toRadians(90))
        //Wellington
        //globe.scene.camera.lookAt(Cartesian3.fromDegrees(longitude: 174.777222, latitude: -41.288889, height: 50000), target: Cartesian3.zero(), up: Cartesian3.unitZ())
        //globe.scene.camera.viewRectangle(Rectangle.fromDegrees(west: 140.0, south: 20.0, east: 165.0, north: -90.0))
    }
    
    func setupGestureRecognisers() {
        let pinch = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchGesture:"))
        view.addGestureRecognizer(pinch)
    }
    
    func tearDownGL () {
        
    }
    
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


