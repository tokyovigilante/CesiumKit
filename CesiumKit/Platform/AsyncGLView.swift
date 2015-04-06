//
//  AsyncGLView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import UIKit
import OpenGLES

class AsyncGLView: UIView {
    
    private var _renderQueue: dispatch_queue_t!
    private var _eaglLayer: CAEAGLLayer!
    private var _context: EAGLContext!
    private var _displayLink: CADisplayLink!
    
    private var _colorRenderBuffer: GLuint = 0
    private var _depthRenderBuffer: GLuint = 0
    
    var render: Bool = false
    
    var renderCallback: ((drawRect: CGRect) -> ())? = nil
    
    override class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }
    required init(coder aDecoder: NSCoder) {
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
        _renderQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
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
            contentScaleFactor = UIScreen.mainScreen().nativeScale
        #endif
    }
    
    func setupRenderbuffer () {
        glGenRenderbuffers(1, &_colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        _context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: _eaglLayer)
    }
    
    func setupDepthBuffer () {
        glGenRenderbuffers(1, &_depthRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _depthRenderBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(frame.size.width * contentScaleFactor), GLsizei(self.frame.size.height * contentScaleFactor))
    }
    
    func setupFramebuffer () {
        var framebuffer: GLuint = 0
        glGenFramebuffers(1, &framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
            GLenum(GL_RENDERBUFFER), _colorRenderBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), _depthRenderBuffer)

    }
    
    // MARK: - NSResponder
    func setupMultitouchInput() {
        
    }
    
    // MARK: render
    func render (displayLink: CADisplayLink) {
        
        if render {
            dispatch_async(_renderQueue, {
                EAGLContext.setCurrentContext(self._context)
                
                glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self._depthRenderBuffer)
                glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self._colorRenderBuffer)
                
                if self.renderCallback != nil {
                    self.renderCallback!()
                }
                self._context.presentRenderbuffer(Int(GL_RENDERBUFFER))
            })
        }

    }
}

extension UIView {
    
    var drawableWidth: CGFloat {
        get {
            return CGFloat(frame.width) * contentScaleFactor
        }
    }
    
    var drawableHeight: CGFloat {
        get {
            return CGFloat(frame.height) * contentScaleFactor
        }
    }
}