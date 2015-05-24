//
//  AsyncGLView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import UIKit
import Metal
import QuartzCore.CAMetalLayer

public class MetalView: UIView {
    
    internal var renderQueue: dispatch_queue_t!
    
    private var _renderSemaphore: dispatch_semaphore_t!
    
    private var _metalDevice: MTLDevice!
    public private(set) var metalLayer: CAMetalLayer!
    private var _displayLink: CADisplayLink!
    
    private var _framebuffer: GLuint = 0
    private var _colorRenderbuffer: GLuint = 0
    private var _depthStencilRenderbuffer: GLuint = 0
    
    private var _rendererDimensions: CGSize? = nil
    
    public var render: Bool = false
    
    public var renderCallback: ((drawRect: CGRect) -> ())? = nil
    
    override public class func layerClass() -> AnyClass {
        return CAMetalLayer.self
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDisplayLink()
        
        setupLayer()
        
        createRenderer()
        
        setupMultitouchInput()
    }
    
    private func setupDisplayLink () {
        
        _displayLink = CADisplayLink(target: self, selector: "render:")
        _displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        //renderQueue = dispatch_queue_create("com.testtoast.cesiumkit.renderqueue", DISPATCH_QUEUE_SERIAL)
        //_renderSemaphore = dispatch_semaphore_create(1)
    }
    
    private func setupLayer () {
        metalLayer = self.layer as! CAMetalLayer
    }
    
    private func createRenderer () {
        
        _metalDevice = MTLCreateSystemDefaultDevice()
        metalLayer.device = _metalDevice
        metalLayer.pixelFormat = MTLPixelFormat.BGRA8Unorm
        metalLayer.framebufferOnly = true
        
        // render at native (screen pixel) scale for retina screens
        contentScaleFactor = UIScreen.mainScreen().nativeScale
        
        render = true
    }
    

    
    //MARK: -Destroy renderer
    private func destroyRenderer () {
        render = false
        _rendererDimensions = nil
    }


    
    // MARK: - NSResponder
    private func setupMultitouchInput() {
        
    }
    
    // MARK: render
    func render (displayLink: CADisplayLink) {
        
        if render {
            
            //if dispatch_semaphore_wait(_renderSemaphore, DISPATCH_TIME_NOW) != 0 {
            //    return
            //}
            
            /*if self._rendererDimensions != nil && self._rendererDimensions! != self._eaglLayer.bounds.size {
                destroyRenderer()
                createRenderer()
            }*/
            
            //dispatch_async(renderQueue, {
                
                //EAGLContext.setCurrentContext(self.context)
                
                
                if self.renderCallback != nil {
                    self.renderCallback!(drawRect: CGRectMake(0, 0, CGFloat(self.drawableWidth), CGFloat(self.drawableHeight)))
                }

                //dispatch_semaphore_signal(self._renderSemaphore)
            //})
        }
    }
}

extension UIView {
    
    public var drawableWidth: CGFloat {
        get {
            return CGFloat(frame.width) * contentScaleFactor
        }
    }
    
    public var drawableHeight: CGFloat {
        get {
            return CGFloat(frame.height) * contentScaleFactor
        }
    }
}