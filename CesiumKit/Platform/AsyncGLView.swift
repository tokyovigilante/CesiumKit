//
//  AsyncGLView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 6/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

//import UIKit
import GLKit

public class AsyncGLView: GLKView {
    
    internal var renderQueue: dispatch_queue_t!
    
    private var _renderSemaphore: dispatch_semaphore_t!
    
    //private var _eaglLayer: CAEAGLLayer!
    //private var _context: EAGLContext!
    
    private var _displayLink: CADisplayLink!
    
    //private var _framebuffer: GLuint = 0
    //private var _colorRenderbuffer: GLuint = 0
    //private var _depthStencilRenderbuffer: GLuint = 0
    
    //private var _rendererDimensions: CGSize? = nil
    
    public var render: Bool = false
    
    public var renderCallback: ((drawRect: CGRect) -> ())? = nil
    
    /*override public class func layerClass() -> AnyClass {
        return CAEAGLLayer.self
    }*/
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDisplayLink()
        createRenderer()
        setupMultitouchInput()
    }
    
    private func createRenderer () {
        //setupLayer()
        setupContext()
        //setupRenderbuffer()
        //setupDepthStencilBuffer()
        //setupFramebuffer()
        render = true
    }
    
    private func destroyRenderer () {
        render = false
        deleteDrawable()
        //destroyContext()
        //destroyBuffers()
        //_rendererDimensions = nil
    }
    
    private func setupDisplayLink () {
        
        _displayLink = CADisplayLink(target: self, selector: "render:")
        _displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        renderQueue = dispatch_queue_create("com.testtoast.cesiumkit.renderqueue", DISPATCH_QUEUE_SERIAL)
        _renderSemaphore = dispatch_semaphore_create(1)
        render = true
    }
    
    /*private func setupLayer () {
        _eaglLayer = self.layer as! CAEAGLLayer
        _eaglLayer.opaque = true
    }*/
    
    private func setupContext () {
        
        context = EAGLContext(API: .OpenGLES3)
        //context.multiThreaded = true
        
        if !EAGLContext.setCurrentContext(context) {
            println("Failed to set current OpenGL context!")
            exit(1)
        }
        
        // Configure renderbuffers created by the view
        drawableColorFormat = .RGBA8888
        drawableDepthFormat = .Format24
        drawableStencilFormat = .Format8
        
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
    
    /*private func destroyContext () {
        _context = nil
    }*/
    
    /*private func setupRenderbuffer () {
        _rendererDimensions = _eaglLayer.bounds.size
        glGenRenderbuffers(1, &_colorRenderbuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _colorRenderbuffer)
        _eaglLayer.drawableProperties = [kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyRetainedBacking: NSNumber(bool: false)]
        _context.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: _eaglLayer)
    }*/
    
    private func destroyBuffers () {
        //glDeleteFramebuffers(1, &_framebuffer)
        //glDeleteRenderbuffers(1, &_depthStencilRenderbuffer)
        //glDeleteRenderbuffers(1, &_colorRenderbuffer)
    }
    
    /*private func setupDepthStencilBuffer () {
        glGenRenderbuffers(1, &_depthStencilRenderbuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), _depthStencilRenderbuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8), GLsizei(drawableWidth), GLsizei(drawableHeight))
    }*/
    
    /*private func setupFramebuffer () {
        glGenFramebuffers(1, &_framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _framebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
            GLenum(GL_RENDERBUFFER), _colorRenderbuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), _depthStencilRenderbuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_STENCIL_ATTACHMENT), GLenum(GL_RENDERBUFFER), _depthStencilRenderbuffer)

    }*/
    
    // MARK: - NSResponder
    private func setupMultitouchInput() {
        
    }
    
    // MARK: render
    func render (displayLink: CADisplayLink) {
        
        if render /*&& _rendererDimensions != nil*/ {
            
            if dispatch_semaphore_wait(_renderSemaphore, DISPATCH_TIME_NOW) != 0 {
                return
            }
            
            /*if self._rendererDimensions != nil && self._rendererDimensions! != self._eaglLayer.bounds.size {
                destroyRenderer()
                createRenderer()
            }*/
            
            dispatch_async(renderQueue, {
                
                EAGLContext.setCurrentContext(self.context)
                
                //glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self._depthStencilRenderbuffer)
                //glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self._colorRenderbuffer)
                
                if self.renderCallback != nil {
                    self.renderCallback!(drawRect: CGRectMake(0, 0, CGFloat(self.drawableWidth), CGFloat(self.drawableHeight)))
                }
                //self._context.presentRenderbuffer(Int(GL_RENDERBUFFER))

                dispatch_semaphore_signal(self._renderSemaphore)

                dispatch_async(dispatch_get_main_queue(), {
                    self.display()
                })
                
            })
        }
    }
}

/*extension UIView {
    
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
}*/