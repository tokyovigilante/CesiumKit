//
//  RenderState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

/**
* Validates and then finds or creates an immutable render state, which defines the pipeline
* state for a {@link DrawCommand} or {@link ClearCommand}.  All inputs states are optional.  Omitted states
* use the defaults shown in the example below.
*
* @memberof Context
*
* @param {Object} [renderState] The states defining the render state as shown in the example below.
*
* @exception {RuntimeError} renderState.lineWidth is out of range.
* @exception {DeveloperError} Invalid renderState.frontFace.
* @exception {DeveloperError} Invalid renderState.cull.face.
* @exception {DeveloperError} scissorTest.rectangle.width and scissorTest.rectangle.height must be greater than or equal to zero.
* @exception {DeveloperError} renderState.depthRange.near can't be greater than renderState.depthRange.far.
* @exception {DeveloperError} renderState.depthRange.near must be greater than or equal to zero.
* @exception {DeveloperError} renderState.depthRange.far must be less than or equal to zero.
* @exception {DeveloperError} Invalid renderState.depthTest.func.
* @exception {DeveloperError} renderState.blending.color components must be greater than or equal to zero and less than or equal to one
* @exception {DeveloperError} Invalid renderState.blending.equationRgb.
* @exception {DeveloperError} Invalid renderState.blending.equationAlpha.
* @exception {DeveloperError} Invalid renderState.blending.functionSourceRgb.
* @exception {DeveloperError} Invalid renderState.blending.functionSourceAlpha.
* @exception {DeveloperError} Invalid renderState.blending.functionDestinationRgb.
* @exception {DeveloperError} Invalid renderState.blending.functionDestinationAlpha.
* @exception {DeveloperError} Invalid renderState.stencilTest.frontFunction.
* @exception {DeveloperError} Invalid renderState.stencilTest.backFunction.
* @exception {DeveloperError} Invalid renderState.stencilTest.frontOperation.fail.
* @exception {DeveloperError} Invalid renderState.stencilTest.frontOperation.zFail.
* @exception {DeveloperError} Invalid renderState.stencilTest.frontOperation.zPass.
* @exception {DeveloperError} Invalid renderState.stencilTest.backOperation.fail.
* @exception {DeveloperError} Invalid renderState.stencilTest.backOperation.zFail.
* @exception {DeveloperError} Invalid renderState.stencilTest.backOperation.zPass.
* @exception {DeveloperError} renderState.viewport.width must be greater than or equal to zero.
* @exception {DeveloperError} renderState.viewport.width must be less than or equal to the maximum viewport width.
* @exception {DeveloperError} renderState.viewport.height must be greater than or equal to zero.
* @exception {DeveloperError} renderState.viewport.height must be less than or equal to the maximum viewport height.
*
* @example
* var defaults = {
*     frontFace : WindingOrder.COUNTER_CLOCKWISE,
*     cull : {
*         enabled : false,
*         face : CullFace.BACK
*     },
*     lineWidth : 1,
*     polygonOffset : {
*         enabled : false,
*         factor : 0,
*         units : 0
*     },
*     scissorTest : {
*         enabled : false,
*         rectangle : {
*             x : 0,
*             y : 0,
*             width : 0,
*             height : 0
*         }
*     },
*     depthRange : {
*         near : 0,
*         far : 1
*     },
*     depthTest : {
*         enabled : false,
*         func : DepthFunction.LESS
*      },
*     depthMask : true,
*     stencilMask : ~0,
*     blending : {
*         enabled : false,
*         color : {
*             red : 0.0,
*             green : 0.0,
*             blue : 0.0,
*             alpha : 0.0
*         },
*         equationRgb : BlendEquation.ADD,
*         equationAlpha : BlendEquation.ADD,
*         functionSourceRgb : BlendFunction.ONE,
*         functionSourceAlpha : BlendFunction.ONE,
*         functionDestinationRgb : BlendFunction.ZERO,
*         functionDestinationAlpha : BlendFunction.ZERO
*     },
*     stencilTest : {
*         enabled : false,
*         frontFunction : StencilFunction.ALWAYS,
*         backFunction : StencilFunction.ALWAYS,
*         reference : 0,
*         mask : ~0,
*         frontOperation : {
*             fail : StencilOperation.KEEP,
*             zFail : StencilOperation.KEEP,
*             zPass : StencilOperation.KEEP
*         },
*         backOperation : {
*             fail : StencilOperation.KEEP,
*             zFail : StencilOperation.KEEP,
*             zPass : StencilOperation.KEEP
*         }
*     },
*     sampleCoverage : {
*         enabled : false,
*         value : 1.0,
*         invert : false
*      }
* };

* @see DrawCommand
* @see ClearCommand
*/
struct RenderState/*: Printable*/ {
    
    let windingOrder: WindingOrder// = .CounterClockwise
    
    let cullFace: CullFace// = .Back
    
    struct PolygonOffset {
        var enabled: Bool = false
        var factor : Float = 0.0
        var units : Float = 0.0
    }
    let polygonOffset: PolygonOffset// = PolygonOffset()
    
    let lineWidth: Double// = 1.0
    
    struct ScissorTest {
        var enabled: Bool = false
        var rectangle: BoundingRectangle? = nil
    }
    let scissorTest: ScissorTest// = ScissorTest()
    
    struct DepthRange {
        var near = 0.0
        var far = 1.0
    }
    
    let depthRange: DepthRange// = DepthRange()
    
    private let _depthStencilState: MTLDepthStencilState?
    
    struct DepthTest {
        var enabled: Bool = false
        var function: DepthFunction = .Less  // function, because func is a Swift keyword ;)
    }
    let depthTest: DepthTest// = DepthTest()
    
    let depthMask: Bool// = false
    
    let stencilMask: Int// = 0
    
    struct StencilTest {
        var enabled: Bool = false
        var frontFunction: Int = 0
        var backFunction: Int = 0
        var reference: Int = 0
        var mask: Int = 0
        
        struct FrontOperation {
            var fail: MTLStencilOperation = .Keep
            var zFail: MTLStencilOperation = .Keep
            var zPass: MTLStencilOperation = .Keep
        }
        let frontOperation = FrontOperation()
        
        struct BackOperation {
            var fail: MTLStencilOperation = .Keep
            var zFail: MTLStencilOperation = .Keep
            var zPass: MTLStencilOperation = .Keep
        }
        let backOperation = BackOperation()
    }
    let stencilTest: StencilTest// = StencilTest()
    
    struct SampleCoverage {
        var enabled = false
        var value: Float = 1.0
        var invert = false
    }
    let sampleCoverage: SampleCoverage// = SampleCoverage()
    
    let viewport: Cartesian4?
    
    var wireFrame: Bool = false
    
    let hash: String
    
    init(
        device: MTLDevice,
        windingOrder: WindingOrder = WindingOrder.CounterClockwise,
        cullFace: CullFace = .None, // default cull disabled
        polygonOffset: PolygonOffset = PolygonOffset(),
        lineWidth: Double = 1.0,
        scissorTest: ScissorTest = ScissorTest(),
        depthRange: DepthRange = DepthRange(),
        depthTest: DepthTest = DepthTest(),
        depthMask: Bool = true,
        stencilMask: Int = ~0,
        blending: BlendingState = BlendingState.Disabled(),
        stencilTest: RenderState.StencilTest = StencilTest(),
        sampleCoverage: RenderState.SampleCoverage = SampleCoverage(),
        viewport: Cartesian4? = nil,
        wireFrame: Bool = false) {
            self.windingOrder = windingOrder
            self.cullFace = cullFace
            self.polygonOffset  = polygonOffset
            self.lineWidth  = lineWidth
            self.scissorTest  = scissorTest
            self.depthRange  = depthRange
            self.depthTest  = depthTest
            self.depthMask = depthMask
            self.stencilMask  = stencilMask
            self.stencilTest  = stencilTest
            self.sampleCoverage  = sampleCoverage
            self.viewport = viewport
            self.wireFrame = wireFrame
            
            //FIXME: checks disabled
            /*if self.lineWidth < ContextLimits.minimumAliasedLineWidth ||
                self.lineWidth > ContextLimits.maximumAliasedLineWidth {
                    fatalError("renderState.lineWidth is out of range.  Check minimumAliasedLineWidth and maximumAliasedLineWidth.")
            }*/
            
            assert(viewport == nil || (viewport != nil && viewport!.width >= 0), "renderState.viewport.width must be greater than or equal to zero")
            assert(viewport == nil || (viewport != nil && viewport!.height >= 0), "renderState.viewport.height must be greater than or equal to zero")
            /*
            assert(viewport == nil || (viewport != nil && viewport!.height < context.limits.maximumViewportWidth), "renderState.viewport.width must be less than or equal to the maximum viewport width (" + maximumViewportWidth.toString() + ').  Check maximumViewportWidth.');
                +            if (this.viewport.width > ContextLimits.maximumViewportWidth) {
                    +                throw new DeveloperError('renderState.viewport.width must be less than or equal to the maximum viewport width (' + ContextLimits.maximumViewportWidth.toString() + ').  Check maximumViewportWidth.');
                }
                -            if (this.viewport.height > context.maximumViewportHeight) {
                    -                throw new RuntimeError('renderState.viewport.height must be less than or equal to the maximum viewport height (' + this.maximumViewportHeight.toString() + ').  Check maximumViewportHeight.');
                    +            if (this.viewport.height > ContextLimits.maximumViewportHeight) {
                        +                throw new DeveloperError('renderState.viewport.height must be less than or equal to the maximum viewport height (' + ContextLimits.maximumViewportHeight.toString() + ').  Check maximumViewportHeight.');*/
            var hash = ""

            // frontFace
            hash += "\(self.windingOrder.toMetal().rawValue)"
            
            // cull
            hash += "\(self.cullFace.toMetal().rawValue)"
            
            // polygonOffset
            hash += polygonOffset.enabled ? "p1" : "p0" + "f\(polygonOffset.factor)u\(polygonOffset.units)"

            // lineWidth
            hash += "l\(lineWidth)"

            // scissorTest
            hash += scissorTest.enabled ? "s1" : "s0" + (scissorTest.rectangle == nil ? "" : "srx\(scissorTest.rectangle!.x)y\(scissorTest.rectangle!.y)w\(scissorTest.rectangle!.width)h\(scissorTest.rectangle!.height)")
            
            // depthRange
            hash += "dn\(depthRange.near)df\(depthRange.far)"

            // depthTest
            hash += depthTest.enabled ? "d1" : "d0" + "df\(depthTest.function.toMetal().rawValue)"

            // depthMask
            hash += "dm" + (depthMask ? "1" : "0")
            
            // stencilMask
            hash += "sm\(stencilMask)"
            
            // stencilTest
            hash += "st" + (stencilTest.enabled ? "1" : "0") + "ff\(stencilTest.frontFunction)" + "bf\(stencilTest.backFunction)" + "r\(stencilTest.reference)" + "m\(stencilTest.mask)" + "ff\(stencilTest.frontOperation.fail)" + "zf\(stencilTest.frontOperation.zFail)" + "zp\(stencilTest.frontOperation.zPass)" + "bf\(stencilTest.backOperation.fail)" + "bzf\(stencilTest.backOperation.zFail)" + "bzp\(stencilTest.backOperation.zPass)"

            // sampleCoverage
            hash += "sc" + (sampleCoverage.enabled ? "1" : "0") + "v\(sampleCoverage.value)" + "i\(sampleCoverage.invert)"
            
            // viewPort
            hash += "v" + (viewport == nil ? "0" : "x\(viewport!.x)y\(viewport!.y)w\(viewport!.width)h\(viewport!.height)")
            
            self.hash = hash
            
            let depthStencilDescriptor = MTLDepthStencilDescriptor()

            if self.depthTest.enabled {
                depthStencilDescriptor.depthCompareFunction = depthTest.function.toMetal()
                depthStencilDescriptor.depthWriteEnabled = true
            }
            _depthStencilState = device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
    }
    
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
    /*
    func enableOrDisable(feature: GLenum, enable: Bool) {
        if enable {
            glEnable(feature)
        } else {
            glDisable(feature)
        }
    }*/
    
    func applyWindingOrder(encoder: MTLRenderCommandEncoder) {
        encoder.setFrontFacingWinding(windingOrder.toMetal())
    }
    
    func applyCullFace(encoder: MTLRenderCommandEncoder) {
        encoder.setCullMode(cullFace.toMetal())
    }
    /*
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
        
        let enabled = (passState.scissorTest != nil ? passState.scissorTest!.enabled : scissorTest.enabled)
        
        enableOrDisable(GLenum(GL_SCISSOR_TEST), enable: enabled)
        
        if (enabled) {
            let rectangle = passState.scissorTest != nil ? passState.scissorTest!.rectangle! : scissorTest.rectangle!
            glScissor(GLint(rectangle.x), GLint(rectangle.y), GLsizei(rectangle.width), GLsizei(rectangle.height))
        }
    }
    
    func applyDepthRange() {
        glDepthRangef(GLclampf(depthRange.near), GLclampf(depthRange.far))
    }
    */
    func applyDepthTest(encoder: MTLRenderCommandEncoder) {
        
        if depthTest.enabled {
            encoder.setDepthStencilState(_depthStencilState)
        }
    }
    
    /*
    func applyDepthMask() {
        glDepthMask(GLboolean(Int(depthMask)))
    }
    
    func applyStencilMask() {
        glStencilMask(stencilMask)
    }
    
    var applyBlendingColor = function(gl, color) {
            gl.blendColor(color.red, color.green, color.blue, color.alpha);
        };
    
    func applyBlending(passState: PassState) {
        
        let enabled = passState.blendingEnabled != nil ? passState.blendingEnabled! : blending.enabled
        
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
            
            let frontOperation = stencilTest.frontOperation;
            glStencilOpSeparate(GLenum(GL_FRONT), frontOperation.fail, frontOperation.zFail, frontOperation.zPass)
            
            let backOperation = stencilTest.backOperation;
            glStencilOpSeparate(GLenum(GL_BACK), backOperation.fail, backOperation.zFail, backOperation.zPass)
        }
    }
    
    func applySampleCoverage() {
        
        enableOrDisable(GLenum(GL_SAMPLE_COVERAGE), enable: sampleCoverage.enabled)
        
        if sampleCoverage.enabled {
            glSampleCoverage(sampleCoverage.value, sampleCoverage.invert)
        }
    }
    */
    
    func applyViewport(encoder: MTLRenderCommandEncoder, passState: PassState) {
        
        var actualViewport = Cartesian4()
        let context = passState.context!
        
        if viewport == nil {
            actualViewport.width = Double(context.width)
            actualViewport.height = Double(context.height)
        } else {
            actualViewport = viewport!
        }
        
        context.uniformState.viewport = actualViewport
        encoder.setViewport(MTLViewport(originX: actualViewport.x, originY: actualViewport.y, width: actualViewport.width, height: actualViewport.height, znear: 0.0, zfar: 1.0))
    }
    
    func applyWireFrame(encoder: MTLRenderCommandEncoder) {
        if wireFrame {
            encoder.setTriangleFillMode(.Lines)
        } else {
            encoder.setTriangleFillMode(.Fill)
        }
    }
    
    func apply(encoder: MTLRenderCommandEncoder, passState: PassState) {
        applyWindingOrder(encoder)
        applyCullFace(encoder)
        /*applyLineWidth()
        applyPolygonOffset()
        applyDepthRange()*/
        applyDepthTest(encoder)
        /*applyDepthMask()
        applyStencilMask()
        applySampleCoverage()
        applyScissorTest(passState)
        applyBlending(passState)
        applyStencilTest()*/
        applyViewport(encoder, passState: passState)
        applyWireFrame(encoder)
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
});*/
}