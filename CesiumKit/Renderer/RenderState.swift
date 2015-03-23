//
//  File.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

struct RenderState/*: Printable*/ {
    
    let frontFace: WindingOrder
    
    struct Cull {
        var enabled: Bool = false
        var face = CullFace.Back
    }
    
    let cull: Cull
    
    struct PolygonOffset {
        var enabled: Bool = false
        var factor : GLfloat = 0.0
        var units : GLfloat = 0.0
    }
    let polygonOffset: PolygonOffset
    
    let lineWidth: Double
    
    struct ScissorTest {
        var enabled: Bool = false
        var rectangle: BoundingRectangle? = nil
    }
    let scissorTest: ScissorTest
    
    struct DepthRange {
        var near = 0.0
        var far = 0.0
    }
    
    let depthRange: DepthRange
    
    struct DepthTest {
        var enabled: Bool = false
        var function: DepthFunction = .Less  // function, because func is a Swift keyword ;)
    }
    let depthTest: DepthTest
    
    struct ColorMask {
        var red = true
        var green = true
        var blue = true
        var alpha = true
    }
    let colorMask: ColorMask
    
    let depthMask: Bool
    
    let stencilMask: GLuint
    
    let blending: BlendingState
    
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
        let frontOperation = FrontOperation()
        
        struct BackOperation {
            var fail: GLenum = GLenum(GL_KEEP)
            var zFail: GLenum = GLenum(GL_KEEP)
            var zPass: GLenum = GLenum(GL_KEEP)
        }
        let backOperation = BackOperation()
    }
    let stencilTest: StencilTest
    
    struct SampleCoverage {
        var enabled = false
        var value: GLclampf = 1.0
        var invert: GLboolean = GLboolean(GL_FALSE)
    }
    let sampleCoverage: SampleCoverage
    
    let viewport: BoundingRectangle?
    
    let hash: String

    init(
        frontFace: WindingOrder = WindingOrder.CounterClockwise,
        cull: Cull = Cull(),
        polygonOffset: PolygonOffset = PolygonOffset(),
        lineWidth: Double = 1.0,
        scissorTest: ScissorTest = ScissorTest(),
        depthRange: DepthRange = DepthRange(),
        depthTest: DepthTest = DepthTest(),
        colorMask: ColorMask = ColorMask(),
        depthMask: Bool = true,
        stencilMask: GLuint = ~0,
        blending: BlendingState = BlendingState.Disabled(),
        stencilTest: RenderState.StencilTest = StencilTest(),
        sampleCoverage: RenderState.SampleCoverage = SampleCoverage(),
        viewport: BoundingRectangle? = nil) {
            self.frontFace  = frontFace
            self.cull  = cull
            self.polygonOffset  = polygonOffset
            self.lineWidth  = lineWidth
            self.scissorTest  = scissorTest
            self.depthRange  = depthRange
            self.depthTest  = depthTest
            self.colorMask  = colorMask
            self.depthMask = depthMask
            self.stencilMask  = stencilMask
            self.blending  = blending
            self.stencilTest  = stencilTest
            self.sampleCoverage  = sampleCoverage
            self.viewport = viewport
            
            var hash = ""
            
            // frontFace
            hash += "\(self.frontFace.toGL())"
            
            // cull
            hash += cull.enabled ? "c1" : "c0" + "\(cull.face.toGL())"
            
            // polygonOffset
            hash += polygonOffset.enabled ? "p1" : "p0" + "f\(polygonOffset.factor)u\(polygonOffset.units)"

            // lineWidth
            hash += "l\(lineWidth)"

            // scissorTest
            hash += scissorTest.enabled ? "s1" : "s0" + (scissorTest.rectangle == nil ? "" : "srx\(scissorTest.rectangle!.x)y\(scissorTest.rectangle!.y)w\(scissorTest.rectangle!.width)h\(scissorTest.rectangle!.height)")
            
            // depthRange
            hash += "dn\(depthRange.near)df\(depthRange.far)"

            // depthTest
            hash += depthTest.enabled ? "d1" : "d0" + "df\(depthTest.function.toGL())"

            // colorMask
            hash += "cm" + (colorMask.red ? "1" : "0") + (colorMask.green ? "1" : "0") + (colorMask.blue ? "1" : "0") + (colorMask.alpha ? "1" : "0")

            // depthMask
            hash += "dm" + (depthMask ? "1" : "0")
            
            // stencilMask
            hash += "sm\(stencilMask)"
            
            // blending
            hash += "bs" + (blending.enabled ? "1" : "0") + "be\(blending.equationRgb.toGL())" + "ba\(blending.equationAlpha.toGL())" + "bfsr\(blending.functionSourceRgb.toGL())" + "bfsa\(blending.functionSourceAlpha.toGL())" + "bfdr\(blending.functionDestinationRgb.toGL())" + "bfda\(blending.functionDestinationAlpha.toGL())" + "x\(blending.color.x)y\(blending.color.y)z\(blending.color.z)w\(blending.color.w)"

            // stencilTest
            hash += "st" + (stencilTest.enabled ? "1" : "0") + "ff\(stencilTest.frontFunction)" + "bf\(stencilTest.backFunction)" + "r\(stencilTest.reference)" + "m\(stencilTest.mask)" + "ff\(stencilTest.frontOperation.fail)" + "zf\(stencilTest.frontOperation.zFail)" + "zp\(stencilTest.frontOperation.zPass)" + "bf\(stencilTest.backOperation.fail)" + "bzf\(stencilTest.backOperation.zFail)" + "bzp\(stencilTest.backOperation.zPass)"

            // sampleCoverage
            hash += "sc" + (sampleCoverage.enabled ? "1" : "0") + "v\(sampleCoverage.value)" + "i\(sampleCoverage.invert)"
            
            // viewPort
            hash += "v" + (viewport == nil ? "0" : "x\(viewport!.x)y\(viewport!.y)w\(viewport!.width)h\(viewport!.height)")
            
            self.hash = hash
    }
    
    //var applyFunctions = [((), -> Any)]? = nil
    
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
    
    /*func validate() {
    
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
        
    //}
    
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
            glBlendEquationSeparate(blending.equationRgb.toGL(), blending.equationAlpha.toGL())
            glBlendFuncSeparate(blending.functionSourceRgb.toGL(), blending.functionDestinationRgb.toGL(), blending.functionSourceAlpha.toGL(), blending.functionDestinationAlpha.toGL())
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
            actualViewport.width = Double(context.width)
            actualViewport.height = Double(context.height)
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
    */
    func partialApply (previousState: RenderState, passState: PassState) {
        // When a new render state is applied, instead of making WebGL calls for all the states or first
        // comparing the states one-by-one with the previous state (basically a linear search), we take
        // advantage of RenderState's immutability, and store a dynamically populated sparse data structure
        // containing functions that make the minimum number of WebGL calls when transitioning from one state
        // to the other.  In practice, this works well since state-to-state transitions generally only require a
        // few WebGL calls, especially if commands are stored by state.
        // FIXME: PartialApply
        apply(passState)
        /*var funcs = applyFunctions[previousState.id]
        if (!defined(funcs)) {
            funcs = createFuncs(previousState, nextState);
            nextState._applyFunctions[previousState.id] = funcs;
        }
        
        var len = funcs.length;
        for (var i = 0; i < len; ++i) {
            funcs[i](gl, nextState, passState);
        }*/
    }
    /*
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