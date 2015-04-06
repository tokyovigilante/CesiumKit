//
//  AsyncGLView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import UIKit
import OpenGLES

public class AsyncGLView: UIView {
    
    private var _renderQueue: dispatch_queue_t!
    private var _renderSemaphore: dispatch_semaphore_t!
    
    private var _eaglLayer: CAEAGLLayer!
    private var _context: EAGLContext!
    
    private var _displayLink: CADisplayLink!
    
    private var _colorRenderBuffer: GLuint = 0
    private var _depthRenderBuffer: GLuint = 0
    
    public var render: Bool = false
    
    public var renderCallback: ((drawRect: CGRect) -> ())? = nil
    
    override public class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        setupLayer()
        setupContext()
        setupRenderbuffer()
        setupDepthBuffer()
        setupFramebuffer()
        setupMultitouchInput()
        setupDisplayLink()
    }
    
    private func setupDisplayLink () {
        
        _displayLink = CADisplayLink(target: self, selector: "render:")
        _displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        _renderQueue = dispatch_queue_create("com.testtoast.cesiumkit.renderqueue", DISPATCH_QUEUE_SERIAL)
        _renderSemaphore = dispatch_semaphore_create(1)
        render = true
    }
    
    private func setupLayer () {
        _eaglLayer = self.layer as! CAEAGLLayer
        _eaglLayer.opaque = true
    }
    
    private func setupContext () {
        
        _context = EAGLContext(API: .OpenGLES3)
        //context.multiThreaded = true
        
        if !EAGLContext.setCurrentContext(_context) {
            println("Failed to set current OpenGL context!")
            exit(1)
        }
        
        // Configure renderbuffers created by the view
        /*view.drawableColorFormat = .RGBA8888
        view.drawableDepthFormat = .Format24
        view.drawableStencilFormat = .Format8*/
        
        // Enable multisampling
        //view.drawableMultisample = .Multisample4X
        
        //preferredFramesPerSecond = 60
        
        // enable Retina support on device
        #if arch(i386) || arch(x86_64)
            // render low-res for simulator (Software GL)
            contentScaleFactor = UIScreen.mainScreen().scale * 0.25
            #else
            // render at native (screen pixel) scale for retina screens
            contentScaleFactor = 1.0// UIScreen.mainScreen().nativeScale
        #endif
    }
    
    private func setupRenderbuffer () {
        glGenRenderbuffers(1, &_colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        _context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: _eaglLayer)
    }
    
    private func setupDepthBuffer () {
        glGenRenderbuffers(1, &_depthRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _depthRenderBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(drawableWidth), GLsizei(drawableHeight))
    }
    
    private func setupFramebuffer () {
        var framebuffer: GLuint = 0
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
            GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), _depthRenderBuffer)

    }
    
    // MARK: - NSResponder
    private func setupMultitouchInput() {
        
    }
    
    // MARK: render
    func render (displayLink: CADisplayLink) {
        
        if render {
            if dispatch_semaphore_wait(_renderSemaphore, DISPATCH_TIME_NOW) != 0 {
                return
            }
            
            dispatch_async(_renderQueue, {
                
                EAGLContext.setCurrentContext(self._context)
                
                glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self._depthRenderBuffer)
                glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self._colorRenderBuffer)
                
                if self.renderCallback != nil {
                    self.renderCallback!(drawRect: CGRectMake(0, 0, self.drawableWidth, self.drawableHeight))
                }
                self._context.presentRenderbuffer(Int(GL_RENDERBUFFER))
            
                dispatch_semaphore_signal(self._renderSemaphore)
            })
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