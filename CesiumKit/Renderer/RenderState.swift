//
//  File.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

/*
/*global WebGLRenderingContext*/

function validateBlendEquation(blendEquation) {
return ((blendEquation === WebGLRenderingContext.FUNC_ADD) ||
(blendEquation === WebGLRenderingContext.FUNC_SUBTRACT) ||
(blendEquation === WebGLRenderingContext.FUNC_REVERSE_SUBTRACT));
}

function validateBlendFunction(blendFunction) {
return ((blendFunction === WebGLRenderingContext.ZERO) ||
(blendFunction === WebGLRenderingContext.ONE) ||
(blendFunction === WebGLRenderingContext.SRC_COLOR) ||
(blendFunction === WebGLRenderingContext.ONE_MINUS_SRC_COLOR) ||
(blendFunction === WebGLRenderingContext.DST_COLOR) ||
(blendFunction === WebGLRenderingContext.ONE_MINUS_DST_COLOR) ||
(blendFunction === WebGLRenderingContext.SRC_ALPHA) ||
(blendFunction === WebGLRenderingContext.ONE_MINUS_SRC_ALPHA) ||
(blendFunction === WebGLRenderingContext.DST_ALPHA) ||
(blendFunction === WebGLRenderingContext.ONE_MINUS_DST_ALPHA) ||
(blendFunction === WebGLRenderingContext.CONSTANT_COLOR) ||
(blendFunction === WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR) ||
(blendFunction === WebGLRenderingContext.CONSTANT_ALPHA) ||
(blendFunction === WebGLRenderingContext.ONE_MINUS_CONSTANT_ALPHA) ||
(blendFunction === WebGLRenderingContext.SRC_ALPHA_SATURATE));
}

function validateCullFace(cullFace) {
return ((cullFace === WebGLRenderingContext.FRONT) ||
(cullFace === WebGLRenderingContext.BACK) ||
(cullFace === WebGLRenderingContext.FRONT_AND_BACK));
}

function validateDepthFunction(depthFunction) {
return ((depthFunction === WebGLRenderingContext.NEVER) ||
(depthFunction === WebGLRenderingContext.LESS) ||
(depthFunction === WebGLRenderingContext.EQUAL) ||
(depthFunction === WebGLRenderingContext.LEQUAL) ||
(depthFunction === WebGLRenderingContext.GREATER) ||
(depthFunction === WebGLRenderingContext.NOTEQUAL) ||
(depthFunction === WebGLRenderingContext.GEQUAL) ||
(depthFunction === WebGLRenderingContext.ALWAYS));
}

function validateStencilFunction (stencilFunction) {
return ((stencilFunction === WebGLRenderingContext.NEVER) ||
(stencilFunction === WebGLRenderingContext.LESS) ||
(stencilFunction === WebGLRenderingContext.EQUAL) ||
(stencilFunction === WebGLRenderingContext.LEQUAL) ||
(stencilFunction === WebGLRenderingContext.GREATER) ||
(stencilFunction === WebGLRenderingContext.NOTEQUAL) ||
(stencilFunction === WebGLRenderingContext.GEQUAL) ||
(stencilFunction === WebGLRenderingContext.ALWAYS));
}

function validateStencilOperation(stencilOperation) {
return ((stencilOperation === WebGLRenderingContext.ZERO) ||
(stencilOperation === WebGLRenderingContext.KEEP) ||
(stencilOperation === WebGLRenderingContext.REPLACE) ||
(stencilOperation === WebGLRenderingContext.INCR) ||
(stencilOperation === WebGLRenderingContext.DECR) ||
(stencilOperation === WebGLRenderingContext.INVERT) ||
(stencilOperation === WebGLRenderingContext.INCREMENT_WRAP) ||
(stencilOperation === WebGLRenderingContext.DECR_WRAP));
}

*/
struct RenderState/*: Printable*/ {
    
    var frontFace = WindingOrder.CounterClockwise
    
    struct Cull {
        var enabled: Bool = false
        var face = CullFace.Back
    }
    var cull = Cull()
    
    struct PolygonOffset {
        var enabled: Bool = false
        var factor : GLfloat = 0.0
        var units : GLfloat = 0.0
    }
    var polygonOffset = PolygonOffset()
    
    var lineWidth: Double = 1.0
    
    struct ScissorTest {
        var enabled: Bool = false
        var rectangle: BoundingRectangle? = nil
    }
    var scissorTest = ScissorTest()
    
    struct DepthRange {
        var near = 0.0
        var far = 0.0
    }
    var depthRange = DepthRange()
    
    struct DepthTest {
        var enabled: Bool = false
        var function: DepthFunction = .Less  // function, because func is a Swift keyword ;)
    }
    var depthTest = DepthTest()
    
    struct ColorMask {
        var red = true
        var green = true
        var blue = true
        var alpha = true
    }
    var colorMask = ColorMask()
    
    var depthMask = true
    
    var stencilMask: GLuint = ~0
    
    struct Blending {
        var enabled: Bool = false
        var color: Cartesian4 = Cartesian4.fromColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        var equationRgb: GLenum = GLenum(GL_FUNC_ADD)
        var equationAlpha: GLenum = GLenum(GL_FUNC_ADD)
        var functionSourceRgb: GLenum = GLenum(GL_ONE)
        var functionSourceAlpha: GLenum = GLenum(GL_ONE)
        var functionDestinationRgb: GLenum = GLenum(GL_ZERO)
        var functionDestinationAlpha: GLenum = GLenum(GL_ZERO)
    }
    var blending = Blending()
    
    struct StencilTest {
        var enabled: Bool = false
        var frontFunction: GLenum = GLenum(GL_ALWAYS)
        var backFunction: GLenum = GLenum(GL_ALWAYS)
        var reference: GLint = 0
        var mask: GLuint = ~0
        
        struct FrontOperation {
            var fail: GLenum = GLenum(GL_KEEP)
            var zFail: GLenum = GLenum(GL_KEEP)
            var zPass: GLenum = GLenum(GL_KEEP)
        }
        var frontOperation = FrontOperation()
        
        struct BackOperation {
            var fail: GLenum = GLenum(GL_KEEP)
            var zFail: GLenum = GLenum(GL_KEEP)
            var zPass: GLenum = GLenum(GL_KEEP)
        }
        var backOperation = BackOperation()
    }
    var stencilTest = StencilTest()
    
    struct SampleCoverage {
        var enabled = false
        var value: GLclampf = 1.0
        var invert: GLboolean = GLboolean(GL_FALSE)
    }
    var sampleCoverage = SampleCoverage()
    
    var viewport: BoundingRectangle? = nil
    
    var id = 0
    
    //var applyFunctions = []
    
    init(context: Context) {
        
    /*
    view

    
    this.viewport = (defined(viewport)) ? new BoundingRectangle(viewport.x, viewport.y,
    (!defined(viewport.width)) ? context.drawingBufferWidth : viewport.width,
    (!defined(viewport.height)) ? context.drawingBufferHeight : viewport.height) : undefined;
    */
    }
    
    /*var description: String {
        get {
            let address: Pointer = Pointer(address: unsafeBitCast(self, UInt.self))
            if let memory: Memory = Memory.read(address, knownSize: nil) {
                return memory.hex()
            }
            return address.description
            return "renderState"
        }
    }*/
    
    func validate() {
        /*
        if ((this.lineWidth < context.minimumAliasedLineWidth) ||
        (this.lineWidth > context.maximumAliasedLineWidth)) {
        throw new RuntimeError('renderState.lineWidth is out of range.  Check minimumAliasedLineWidth and maximumAliasedLineWidth.');
        }
        
        //>>includeStart('debug', pragmas.debug);
        if (!WindingOrder.validate(this.frontFace)) {
        throw new DeveloperError('Invalid renderState.frontFace.');
        }
        if (!validateCullFace(this.cull.face)) {
        throw new DeveloperError('Invalid renderState.cull.face.');
        }
        if ((this.scissorTest.rectangle.width < 0) ||
        (this.scissorTest.rectangle.height < 0)) {
        throw new DeveloperError('renderState.scissorTest.rectangle.width and renderState.scissorTest.rectangle.height must be greater than or equal to zero.');
        }
        if (this.depthRange.near > this.depthRange.far) {
        // WebGL specific - not an error in GL ES
        throw new DeveloperError('renderState.depthRange.near can not be greater than renderState.depthRange.far.');
        }
        if (this.depthRange.near < 0) {
        // Would be clamped by GL
        throw new DeveloperError('renderState.depthRange.near must be greater than or equal to zero.');
        }
        if (this.depthRange.far > 1) {
        // Would be clamped by GL
        throw new DeveloperError('renderState.depthRange.far must be less than or equal to one.');
        }
        if (!validateDepthFunction(this.depthTest.func)) {
        throw new DeveloperError('Invalid renderState.depthTest.func.');
        }
        if ((this.blending.color.red < 0.0) || (this.blending.color.red > 1.0) ||
        (this.blending.color.green < 0.0) || (this.blending.color.green > 1.0) ||
        (this.blending.color.blue < 0.0) || (this.blending.color.blue > 1.0) ||
        (this.blending.color.alpha < 0.0) || (this.blending.color.alpha > 1.0)) {
        // Would be clamped by GL
        throw new DeveloperError('renderState.blending.color components must be greater than or equal to zero and less than or equal to one.');
        }
        if (!validateBlendEquation(this.blending.equationRgb)) {
        throw new DeveloperError('Invalid renderState.blending.equationRgb.');
        }
        if (!validateBlendEquation(this.blending.equationAlpha)) {
        throw new DeveloperError('Invalid renderState.blending.equationAlpha.');
        }
        if (!validateBlendFunction(this.blending.functionSourceRgb)) {
        throw new DeveloperError('Invalid renderState.blending.functionSourceRgb.');
        }
        if (!validateBlendFunction(this.blending.functionSourceAlpha)) {
        throw new DeveloperError('Invalid renderState.blending.functionSourceAlpha.');
        }
        if (!validateBlendFunction(this.blending.functionDestinationRgb)) {
        throw new DeveloperError('Invalid renderState.blending.functionDestinationRgb.');
        }
        if (!validateBlendFunction(this.blending.functionDestinationAlpha)) {
        throw new DeveloperError('Invalid renderState.blending.functionDestinationAlpha.');
        }
        if (!validateStencilFunction(this.stencilTest.frontFunction)) {
        throw new DeveloperError('Invalid renderState.stencilTest.frontFunction.');
        }
        if (!validateStencilFunction(this.stencilTest.backFunction)) {
        throw new DeveloperError('Invalid renderState.stencilTest.backFunction.');
        }
        if (!validateStencilOperation(this.stencilTest.frontOperation.fail)) {
        throw new DeveloperError('Invalid renderState.stencilTest.frontOperation.fail.');
        }
        if (!validateStencilOperation(this.stencilTest.frontOperation.zFail)) {
        throw new DeveloperError('Invalid renderState.stencilTest.frontOperation.zFail.');
        }
        if (!validateStencilOperation(this.stencilTest.frontOperation.zPass)) {
        throw new DeveloperError('Invalid renderState.stencilTest.frontOperation.zPass.');
        }
        if (!validateStencilOperation(this.stencilTest.backOperation.fail)) {
        throw new DeveloperError('Invalid renderState.stencilTest.backOperation.fail.');
        }
        if (!validateStencilOperation(this.stencilTest.backOperation.zFail)) {
        throw new DeveloperError('Invalid renderState.stencilTest.backOperation.zFail.');
        }
        if (!validateStencilOperation(this.stencilTest.backOperation.zPass)) {
        throw new DeveloperError('Invalid renderState.stencilTest.backOperation.zPass.');
        }
        //>>includeEnd('debug');
        
        if (defined(this.viewport)) {
        //>>includeStart('debug', pragmas.debug);
        if (this.viewport.width < 0) {
        throw new DeveloperError('renderState.viewport.width must be greater than or equal to zero.');
        }
        if (this.viewport.height < 0) {
        throw new DeveloperError('renderState.viewport.height must be greater than or equal to zero.');
        }
        //>>includeEnd('debug');
        
        if (this.viewport.width > context.maximumViewportWidth) {
        throw new RuntimeError('renderState.viewport.width must be less than or equal to the maximum viewport width (' + this.maximumViewportWidth.toString() + ').  Check maximumViewportWidth.');
        }
        if (this.viewport.height > context.maximumViewportHeight) {
        throw new RuntimeError('renderState.viewport.height must be less than or equal to the maximum viewport height (' + this.maximumViewportHeight.toString() + ').  Check maximumViewportHeight.');
        }
        }
        */
        
    }
    
    func enableOrDisable(feature: GLenum, enable: Bool) {
        if enable {
            glEnable(feature)
        } else {
            glDisable(feature)
        }
    }
    
    func applyFrontFace() {
        glFrontFace(frontFace.toGL())
    }
    
    func applyCull() {
        enableOrDisable(GLenum(GL_CULL_FACE), enable: cull.enabled)
        
        if (cull.enabled) {
            glCullFace(cull.face.toGL())
        }
    }
    
    func applyLineWidth() {
        glLineWidth(GLfloat(lineWidth))
    }
    
    func applyPolygonOffset() {
        enableOrDisable(GLenum(GL_POLYGON_OFFSET_FILL), enable: polygonOffset.enabled)
        
        if (polygonOffset.enabled) {
            glPolygonOffset(polygonOffset.factor, polygonOffset.units)
        }
    }
    
    func applyScissorTest(passState: PassState) {
        
        var enabled = (passState.scissorTest != nil ? passState.scissorTest!.enabled : scissorTest.enabled)
        
        enableOrDisable(GLenum(GL_SCISSOR_TEST), enable: enabled)
        
        if (enabled) {
            var rectangle = passState.scissorTest != nil ? passState.scissorTest!.rectangle! : scissorTest.rectangle!
            glScissor(GLint(rectangle.x), GLint(rectangle.y), GLsizei(rectangle.width), GLsizei(rectangle.height))
        }
    }
    
    func applyDepthRange() {
        glDepthRangef(GLclampf(depthRange.near), GLclampf(depthRange.far))
    }
    
    func applyDepthTest() {
        
        enableOrDisable(GLenum(GL_DEPTH_TEST), enable: depthTest.enabled)
        
        if (depthTest.enabled) {
            glDepthFunc(depthTest.function.toGL())
        }
    }
    
    func applyColorMask() {
        glColorMask(
            GLboolean(Int(colorMask.red)),
            GLboolean(Int(colorMask.green)),
            GLboolean(Int(colorMask.blue)),
            GLboolean(Int(colorMask.alpha)))
    }
    
    func applyDepthMask() {
        glDepthMask(GLboolean(Int(depthMask)))
    }
    
    func applyStencilMask() {
        glStencilMask(stencilMask)
    }
    
    func applyBlending(passState: PassState) {
        
        var enabled = passState.blendingEnabled != nil ? passState.blendingEnabled! : blending.enabled
        
        enableOrDisable(GLenum(GL_BLEND), enable: enabled)
        
        if enabled {
            glBlendColor(GLfloat(blending.color.x), GLfloat(blending.color.y), GLfloat(blending.color.z), GLfloat(blending.color.w))
            glBlendEquationSeparate(blending.equationRgb, blending.equationAlpha);
            glBlendFuncSeparate(blending.functionSourceRgb, blending.functionDestinationRgb, blending.functionSourceAlpha, blending.functionDestinationAlpha)
        }
    }
    
    func applyStencilTest() {
        
        enableOrDisable(GLenum(GL_STENCIL_TEST), enable: stencilTest.enabled)
        
        if (stencilTest.enabled) {
            
            // Section 6.8 of the WebGL spec requires the reference and masks to be the same for
            // front- and back-face tests.  This call prevents invalid operation errors when calling
            // stencilFuncSeparate on Firefox.  Perhaps they should delay validation to avoid requiring this.
            glStencilFunc(stencilTest.frontFunction, stencilTest.reference, stencilTest.mask);
            glStencilFuncSeparate(GLenum(GL_BACK), stencilTest.backFunction, stencilTest.reference, stencilTest.mask);
            glStencilFuncSeparate(GLenum(GL_FRONT), stencilTest.frontFunction, stencilTest.reference, stencilTest.mask);
            
            var frontOperation = stencilTest.frontOperation;
            glStencilOpSeparate(GLenum(GL_FRONT), frontOperation.fail, frontOperation.zFail, frontOperation.zPass)
            
            var backOperation = stencilTest.backOperation;
            glStencilOpSeparate(GLenum(GL_BACK), backOperation.fail, backOperation.zFail, backOperation.zPass)
        }
    }
    
    func applySampleCoverage() {
        
        enableOrDisable(GLenum(GL_SAMPLE_COVERAGE), enable: sampleCoverage.enabled)
        
        if sampleCoverage.enabled {
            glSampleCoverage(sampleCoverage.value, sampleCoverage.invert)
        }
    }
    
    
    func applyViewport(passState: PassState) {
        
        var actualViewport = BoundingRectangle()
        var context = passState.context!
        if !(viewport != nil) {
            actualViewport.width = Double(context.drawingBufferWidth)
            actualViewport.height = Double(context.drawingBufferHeight)
        } else {
            actualViewport = viewport!
        }
        
        context.uniformState.viewport = actualViewport
        glViewport(GLint(actualViewport.x), GLint(actualViewport.y), GLint(actualViewport.width), GLint(actualViewport.height))
    }
    
    func apply(passState: PassState) {
        applyFrontFace()
        applyCull()
        applyLineWidth()
        applyPolygonOffset()
        applyScissorTest(passState)
        applyDepthRange()
        applyDepthTest()
        applyColorMask()
        applyDepthMask()
        applyStencilMask()
        applyBlending(passState)
        applyStencilTest()
        applySampleCoverage()
        applyViewport(passState)
    }
    
    /*
    func createFunctions(previousState: RenderState, nextState: RenderState) {
        var funcs = [() -> ()]
        
        if (previousState.frontFace !== nextState.frontFace) {
            funcs.push(applyFrontFace);
        }
        
        if ((previousState.cull.enabled !== nextState.cull.enabled) || (previousState.cull.face !== nextState.cull.face)) {
            funcs.push(applyCull);
        }
        
        if (previousState.lineWidth !== nextState.lineWidth) {
            funcs.push(applyLineWidth);
        }
        
        if ((previousState.polygonOffset.enabled !== nextState.polygonOffset.enabled) ||
            (previousState.polygonOffset.factor !== nextState.polygonOffset.factor) ||
            (previousState.polygonOffset.units !== nextState.polygonOffset.units)) {
                funcs.push(applyPolygonOffset);
        }
        
        // For now, always apply because of passState
        funcs.push(applyScissorTest);
        
        if ((previousState.depthRange.near !== nextState.depthRange.near) || (previousState.depthRange.far !== nextState.depthRange.far)) {
            funcs.push(applyDepthRange);
        }
        
        if ((previousState.depthTest.enabled !== nextState.depthTest.enabled) || (previousState.depthTest.func !== nextState.depthTest.func)) {
            funcs.push(applyDepthTest);
        }
        
        if ((previousState.colorMask.red !== nextState.colorMask.red) ||
            (previousState.colorMask.green !== nextState.colorMask.green) ||
            (previousState.colorMask.blue !== nextState.colorMask.blue) ||
            (previousState.colorMask.alpha !== nextState.colorMask.alpha)) {
                funcs.push(applyColorMask);
        }
        
        if (previousState.depthMask !== nextState.depthMask) {
            funcs.push(applyDepthMask);
        }
        
        // For now, always apply because of passState
        funcs.push(applyBlending);
        
        if (previousState.stencilMask !== nextState.stencilMask) {
            funcs.push(applyStencilMask);
        }
        
        if ((previousState.stencilTest.enabled !== nextState.stencilTest.enabled) ||
            (previousState.stencilTest.frontFunction !== nextState.stencilTest.frontFunction) ||
            (previousState.stencilTest.backFunction !== nextState.stencilTest.backFunction) ||
            (previousState.stencilTest.reference !== nextState.stencilTest.reference) ||
            (previousState.stencilTest.mask !== nextState.stencilTest.mask) ||
            (previousState.stencilTest.frontOperation.fail !== nextState.stencilTest.frontOperation.fail) ||
            (previousState.stencilTest.frontOperation.zFail !== nextState.stencilTest.frontOperation.zFail) ||
            (previousState.stencilTest.backOperation.fail !== nextState.stencilTest.backOperation.fail) ||
            (previousState.stencilTest.backOperation.zFail !== nextState.stencilTest.backOperation.zFail) ||
            (previousState.stencilTest.backOperation.zPass !== nextState.stencilTest.backOperation.zPass)) {
                funcs.push(applyStencilTest);
        }
        
        if ((previousState.sampleCoverage.enabled !== nextState.sampleCoverage.enabled) ||
            (previousState.sampleCoverage.value !== nextState.sampleCoverage.value) ||
            (previousState.sampleCoverage.invert !== nextState.sampleCoverage.invert)) {
                funcs.push(applySampleCoverage);
        }
        
        // For now, always apply because of passState
        funcs.push(applyViewport);
        
        return funcs;
    }
    
    RenderState.partialApply = function(gl, previousState, nextState, passState) {
    // When a new render state is applied, instead of making WebGL calls for all the states or first
    // comparing the states one-by-one with the previous state (basically a linear search), we take
    // advantage of RenderState's immutability, and store a dynamically populated sparse data structure
    // containing functions that make the minimum number of WebGL calls when transitioning from one state
    // to the other.  In practice, this works well since state-to-state transitions generally only require a
    // few WebGL calls, especially if commands are stored by state.
    var funcs = nextState._applyFunctions[previousState.id];
    if (!defined(funcs)) {
    funcs = createFuncs(previousState, nextState);
    nextState._applyFunctions[previousState.id] = funcs;
    }
    
    var len = funcs.length;
    for (var i = 0; i < len; ++i) {
    funcs[i](gl, nextState, passState);
    }
    }
    
    /**
    * Duplicates a RenderState instance. The object returned must still be created with {@link Context#createRenderState}.
    *
    * @param renderState The render state to be cloned.
    * @returns {Object} The duplicated render state.
    */
    RenderState.clone = function(renderState) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(renderState)) {
    throw new DeveloperError('renderState is required.');
    }
    //>>includeEnd('debug');
    
    return {
    frontFace : renderState.frontFace,
    cull : {
    enabled : renderState.cull.enabled,
    face : renderState.cull.face
    },
    lineWidth : renderState.lineWidth,
    polygonOffset : {
    enabled : renderState.polygonOffset.enabled,
    factor : renderState.polygonOffset.factor,
    units : renderState.polygonOffset.units
    },
    scissorTest : {
    enabled : renderState.scissorTest.enabled,
    rectangle : BoundingRectangle.clone(renderState.scissorTest.rectangle)
    },
    depthRange : {
    near : renderState.depthRange.near,
    far : renderState.depthRange.far
    },
    depthTest : {
    enabled : renderState.depthTest.enabled,
    func : renderState.depthTest.func
    },
    colorMask : {
    red : renderState.colorMask.red,
    green : renderState.colorMask.green,
    blue : renderState.colorMask.blue,
    alpha : renderState.colorMask.alpha
    },
    depthMask : renderState.depthMask,
    stencilMask : renderState.stencilMask,
    blending : {
    enabled : renderState.blending.enabled,
    color : Color.clone(renderState.blending.color),
    equationRgb : renderState.blending.equationRgb,
    equationAlpha : renderState.blending.equationAlpha,
    functionSourceRgb : renderState.blending.functionSourceRgb,
    functionSourceAlpha : renderState.blending.functionSourceAlpha,
    functionDestinationRgb : renderState.blending.functionDestinationRgb,
    functionDestinationAlpha : renderState.blending.functionDestinationAlpha
    },
    stencilTest : {
    enabled : renderState.stencilTest.enabled,
    frontFunction : renderState.stencilTest.frontFunction,
    backFunction : renderState.stencilTest.backFunction,
    reference : renderState.stencilTest.reference,
    mask : renderState.stencilTest.mask,
    frontOperation : {
    fail : renderState.stencilTest.frontOperation.fail,
    zFail : renderState.stencilTest.frontOperation.zFail,
    zPass : renderState.stencilTest.frontOperation.zPass
    },
    backOperation : {
    fail : renderState.stencilTest.backOperation.fail,
    zFail : renderState.stencilTest.backOperation.zFail,
    zPass : renderState.stencilTest.backOperation.zPass
    }
    },
    sampleCoverage : {
    enabled : renderState.sampleCoverage.enabled,
    value : renderState.sampleCoverage.value,
    invert : renderState.sampleCoverage.invert
    },
    viewport : defined(renderState.viewport) ? BoundingRectangle.clone(renderState.viewport) : undefined
    };
    };
    
    return RenderState;
    });
    */
}