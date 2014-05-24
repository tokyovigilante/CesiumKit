//
//  CSScene.h
//  CesiumKit
//
//  Created by Ryan Walklin on 4/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//


/**
 * The container for all 3D graphical objects and state in a Cesium virtual scene.  Generally,
 * a scene is not created directly; instead, it is implicitly created by {@link CesiumWidget}.
 *
 * @alias Scene
 * @constructor
 *
 * @param {HTMLCanvasElement} canvas The HTML canvas element to create the scene for.
 * @param {Object} [contextOptions=undefined] Context and WebGL creation properties corresponding to {@link Context#options}.
 * @param {HTMLElement} [creditContainer=undefined] The HTML element in which the credits will be displayed.
 *
 * @see CesiumWidget
 * @see <a href='http://www.khronos.org/registry/webgl/specs/latest/#5.2'>WebGLContextAttributes</a>
 *
 * @example
 * // Create scene without anisotropic texture filtering
 * var scene = new Cesium.Scene(canvas, {
 *   allowTextureFilterAnisotropic : false
 * });
 */

/*global define*/
enum CSSceneMode;

typedef void(^CSDebugFilterBlock)(void);

@import Foundation;

@class CSFrameState, CSPassState, CSRenderState, CSContext, CSGlobe, CSPrimitives, CSCamera, CSScreenSpaceCameraController, CSClearCommand, CSSceneTransitioner, CSEvent;
@class CSGeographicProjection, CSCanvas, CSImageryLayerCollection, CSTerrainProvider, CSInterval, CSDrawCommand, CSCartesian2, CSCullingVolume, CSShaderProgram, GLKView, UIColor;

@interface CSScene : NSObject

@property (nonatomic) CSFrameState *frameState;
@property (nonatomic) CSPassState *passState;
@property (nonatomic) GLKView *glView;
@property (nonatomic) CSContext *context;
@property (nonatomic) CSGlobe *globe;
@property (nonatomic) CSPrimitives *primitives;
//@property (nonatomic) CSPickFrameBuffer *pickFrameBuffer;
@property (nonatomic) CSCamera *camera;
@property (nonatomic) CSScreenSpaceCameraController *cameraController;
//@property (nonatomic) NSMutableArray *animations;
@property (readonly) UInt32 shaderFrameCount;
@property (nonatomic) NSMutableArray *commandList;
@property (nonatomic) NSMutableArray *frustrumCommandsList;
@property (nonatomic) NSMutableArray *overlayCommandList;
//@property (nonatomic) CSOITransparency *orderIndependentTransparency;
//      this._executeOITFunction = undefined;
        
//        this._fxaa = new FXAA();

@property (nonatomic) CSClearCommand *clearColourCommand;
@property (nonatomic) CSClearCommand *clearDepthCommand;
@property (nonatomic) CSSceneTransitioner *SceneTransitioner;

/**
 * Determines whether or not to instantly complete the
 * scene transition animation on user input.
 *
 * @type {Boolean}
 * @default true
 */
@property BOOL completeMorphOnUserInput;

/**
 * The event fired at the beginning of a scene transition.
 * @type {Event}
 * @default Event()
 */
@property (nonatomic) CSEvent *morphStart;

/**
 * The event fired at the completion of a scene transition.
 * @type {Event}
 * @default Event()
 */
@property (nonatomic) CSEvent *morphComplete;

/**
 * The {@link SkyBox} used to draw the stars.
 *
 * @type {SkyBox}
 * @default undefined
 *
 * @see Scene#backgroundColor
 */
@property (nonatomic) id skyBox;

/**
 * The sky atmosphere drawn around the globe.
 *
 * @type {SkyAtmosphere}
 * @default undefined
 */
@property (nonatomic) id skyAtmosphere;

/**
 * The background color, which is only visible if there is no sky box, i.e., {@link Scene#skyBox} is undefined.
 *
 * @type {Color}
 * @default {@link Color.BLACK}
 *
 * @see Scene#skyBox
 */
@property (nonatomic) UIColor *backgroundColor;

/**
 * The current mode of the scene.
 *
 * @type {SceneMode}
 * @default {@link SceneMode.SCENE3D}
 */
@property BOOL sceneIs3D;

/**
 * The projection to use in 2D mode.
 */
@property (nonatomic) CSGeographicProjection *projection;

/**
 * The current morph transition time between 2D/Columbus View and 3D,
 * with 0.0 being 2D or Columbus View and 1.0 being 3D.
 *
 * @type {Number}
 * @default 1.0
 */
@property NSTimeInterval morphTime;
/**
 * The far-to-near ratio of the multi-frustum. The default is 1,000.0.
 *
 * @type {Number}
 * @default 1000.0
 */
@property Float64 farToNearRatio;

/**
 * This property is for debugging only; it is not for production use.
 * <p>
 * A function that determines what commands are executed.  As shown in the examples below,
 * the function receives the command's <code>owner</code> as an argument, and returns a boolean indicating if the
 * command should be executed.
 * </p>
 * <p>
 * The default is <code>undefined</code>, indicating that all commands are executed.
 * </p>
 *
 * @type Function
 *
 * @default undefined
 *
 * @example
 * // Do not execute any commands.
 * scene.debugCommandFilter = function(command) {
 *     return false;
 * };
 *
 * // Execute only the billboard's commands.  That is, only draw the billboard.
 * var billboards = new Cesium.BillboardCollection();
 * scene.debugCommandFilter = function(command) {
 *     return command.owner === billboards;
 * };
 *
 * @see DrawCommand
 * @see ClearCommand
 */

@property (nonatomic, copy) CSDebugFilterBlock debugCommandFilter;

/**
 * This property is for debugging only; it is not for production use.
 * <p>
 * When <code>true</code>, commands are randomly shaded.  This is useful
 * for performance analysis to see what parts of a scene or model are
 * command-dense and could benefit from batching.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property BOOL debugShowCommands;

/**
 * This property is for debugging only; it is not for production use.
 * <p>
 * When <code>true</code>, commands are shaded based on the frustums they
 * overlap.  Commands in the closest frustum are tinted red, commands in
 * the next closest are green, and commands in the farthest frustum are
 * blue.  If a command overlaps more than one frustum, the color components
 * are combined, e.g., a command overlapping the first two frustums is tinted
 * yellow.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property BOOL debugShowFrustums;

/**
 * This property is for debugging only; it is not for production use.
 * <p>
 * When {@link Scene.debugShowFrustums} is <code>true</code>, this contains
 * properties with statistics about the number of command execute per frustum.
 * <code>totalCommands</code> is the total number of commands executed, ignoring
 * overlap. <code>commandsInFrustums</code> is an array with the number of times
 * commands are executed redundantly, e.g., how many commands overlap two or
 * three frustums.
 * </p>
 *
 * @type Object
 *
 * @default undefined
 *
 * @readonly
 */
@property id debugFrustumStatistics;

/**
 * This property is for debugging only; it is not for production use.
 * <p>
 * Displays frames per second and time between frames.
 * </p>
 *
 * @type Boolean
 *
 * @default false
 */
@property BOOL debugShowFramesPerSecond;

/**
 * If <code>true</code>, enables Fast Aproximate Anti-aliasing only if order independent translucency
 * is supported.
 *
 * @type Boolean
 * @default true
 */
@property BOOL fxaaOrderIndependentTranslucency;

/**
 * When <code>true</code>, enables Fast Approximate Anti-aliasing even when order independent translucency
 * is unsupported.
 *
 * @type Boolean
 * @default false
 */
@property BOOL fxaa;

@property (nonatomic) id performanceDisplay;

@property (nonatomic) id debugSphere;

/**
 * Gets the canvas element to which this scene is bound.
 * @memberof Scene.prototype
 * @type {Element}
 */
@property (nonatomic) CSCanvas *canvas;

-(id)initWithGLKView:(GLKView *)glView;

/**
 * The drawingBufferWidth of the underlying GL context.
 * @memberof Scene.prototype
 * @type {Number}
 * @see <a href='https://www.khronos.org/registry/webgl/specs/1.0/#DOM-WebGLRenderingContext-drawingBufferWidth'>drawingBufferWidth</a>
 */
-(Float64)drawingBufferWidth;

/**
 * The drawingBufferHeight of the underlying GL context.
 * @memberof Scene.prototype
 * @type {Number}
 * @see <a href='https://www.khronos.org/registry/webgl/specs/1.0/#DOM-WebGLRenderingContext-drawingBufferHeight'>drawingBufferHeight</a>
 */
-(Float64)drawingBufferHeight;

/**
 * The maximum aliased line width, in pixels, supported by this WebGL implementation.  It will be at least one.
 * @memberof Scene.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>ALIASED_LINE_WIDTH_RANGE</code>.
 */
-(Float64)maximumAliasedLineWidth;

/**
 * Gets the collection of image layers that will be rendered on the globe.
 * @memberof Scene.prototype
 * @type {ImageryLayerCollection}
 */
-(CSImageryLayerCollection *)imageryLayers;


/**
 * The terrain provider providing surface geometry for the globe.
 * @memberof Scene.prototype
 * @type {TerrainProvider}
 */
-(CSTerrainProvider *)terrainProvider;

/*
var scratchOccluderBoundingSphere = new BoundingSphere();
var scratchOccluder;
*/

-(void)clearPasses;
-(void)updateFrameState:(UInt32)frameNumber;
-(void)updateFrustums:(id)near far:(id)far farToNearRatio:(Float64)farToNearRatio frustumCommandsList:(NSArray *)frustumCommandsList;
-(void)insertIntoBin:(CSClearCommand *)command distance:(CSInterval *)distance;
-(void)createPotentiallyVisibleSet;
/*
function getAttributeLocations(shaderProgram);
 function createDebugFragmentShaderProgram(command, scene, shaderProgram) ;
 
function executeDebugCommand(command, scene, passState, renderState, shaderProgram) {

}*/
/*
var transformFrom2D = Matrix4.inverseTransformation(//
                                                    new Matrix4(0.0, 0.0, 1.0, 0.0, //
                                                                1.0, 0.0, 0.0, 0.0, //
                                                                0.0, 1.0, 0.0, 0.0, //
                                                                0.0, 0.0, 0.0, 1.0));*/

-(void)executeCommand:(CSDrawCommand *)command scene:(CSScene *)scene context:(CSContext *)context passState:(CSPassState *)passState renderState:(CSRenderState *)renderState shaderProgram:(CSShaderProgram *)shaderProgram;
-(void)isVisible:(CSDrawCommand *)command frameState:(CSFrameState *)frameState;
//-(void)translucentCompare

/*
function translucentCompare(a, b, position) {
    return BoundingSphere.distanceSquaredTo(b.boundingVolume, position) - BoundingSphere.distanceSquaredTo(a.boundingVolume, position);
}

function executeTranslucentCommandsSorted(scene, executeFunction, passState, commands) {
    var context = scene._context;
    
    mergeSort(commands, translucentCompare, scene._camera.positionWC);
    
    var length = commands.length;
    for (var j = 0; j < length; ++j) {
        executeFunction(commands[j], scene, context, passState);
    }
}*/

-(void)executeCommands:(CSPassState *)passState clearColour:(UIColor *)clearColour;
-(void)executeOverlayCommands:(CSPassState *)passState;
-(void)updatePrimitives;
-(void)callAfterRenderFunctions:(CSFrameState *)frameState;
/*
-(void)
/**
 * Creates a new texture atlas.
 *
 * @memberof Scene
 *
 * @param {PixelFormat} [options.pixelFormat = PixelFormat.RGBA] The pixel format of the texture.
 * @param {Number} [options.borderWidthInPixels = 1] The amount of spacing between adjacent images in pixels.
 * @param {Cartesian2} [options.initialSize = new Cartesian2(16.0, 16.0)] The initial side lengths of the texture.
 * @param {Array} [options.images=undefined] Array of {@link Image} to be added to the atlas. Same as calling addImages(images).
 * @param {Image} [options.image=undefined] Single image to be added to the atlas. Same as calling addImage(image).
 *
 * @returns {TextureAtlas} The new texture atlas.
 *
 * @see TextureAtlas
 */
/*
Scene.prototype.createTextureAtlas = function(options) {
    return this._context.createTextureAtlas(options);
};

/**
 * DOC_TBA
 * @memberof Scene
 */

-(void)initialiseFrame;
-(void)render:(NSTimeInterval *)time;

-(CSCullingVolume *)getPickOrthographicCullingVolume:(CSCartesian2 *)drawingBufferPosition width:(Float64)width height:(Float64)height;
-(CSCullingVolume *)getPickPerspectiveCullingVolume:(CSCartesian2 *)drawingBufferPosition width:(Float64)width height:(Float64)height;
-(CSCullingVolume *)getPickCullingVolume:(CSCartesian2 *)drawingBufferPosition width:(Float64)width height:(Float64)height;

/**
 * Returns an object with a `primitive` property that contains the first (top) primitive in the scene
 * at a particular window coordinate or undefined if nothing is at the location. Other properties may
 * potentially be set depending on the type of primitive.
 *
 * @memberof Scene
 *
 * @param {Cartesian2} windowPosition Window coordinates to perform picking on.
 *
 * @returns {Object} Object containing the picked primitive.
 *
 * @exception {DeveloperError} windowPosition is undefined.
 */
-(id)pick:(CSCartesian2 *)windowPosition;

/**
 * Returns a list of objects, each containing a `primitive` property, for all primitives at
 * a particular window coordinate position. Other properties may also be set depending on the
 * type of primitive. The primitives in the list are ordered by their visual order in the
 * scene (front to back).
 *
 * @memberof Scene
 *
 * @param {Cartesian2} windowPosition Window coordinates to perform picking on.
 *
 * @returns {Array} Array of objects, each containing 1 picked primitives.
 *
 * @exception {DeveloperError} windowPosition is undefined.
 *
 * @example
 * var pickedObjects = Cesium.Scene.drillPick(new Cesium.Cartesian2(100.0, 200.0));
 */
-(NSArray *)drillPick:(CSCartesian2 *)windowPosition;

/**
 * Instantly completes an active transition.
 * @memberof Scene
 */
-(void)completeMorph;

/**
 * Asynchronously transitions the scene to 2D.
 * @param {Number} [duration = 2000] The amount of time, in milliseconds, for transition animations to complete.
 * @memberof Scene
 */
-(void)morphTo2D:(NSTimeInterval)duration;

/**
 * Asynchronously transitions the scene to Columbus View.
 * @param {Number} [duration = 2000] The amount of time, in milliseconds, for transition animations to complete.
 * @memberof Scene
 */
-(void)morphToColumbusView:(NSTimeInterval)duration;

/**
 * Asynchronously transitions the scene to 3D.
 * @param {Number} [duration = 2000] The amount of time, in milliseconds, for transition animations to complete.
 * @memberof Scene
 */
-(void)morphTo3D:(NSTimeInterval)duration;


/**
 * DOC_TBA
 * @memberof Scene
 */
/*Scene.prototype.destroy = function() {
    this._animations.removeAll();
    this._screenSpaceCameraController = this._screenSpaceCameraController && this._screenSpaceCameraController.destroy();
    this._pickFramebuffer = this._pickFramebuffer && this._pickFramebuffer.destroy();
    this._primitives = this._primitives && this._primitives.destroy();
    this._globe = this._globe && this._globe.destroy();
    this.skyBox = this.skyBox && this.skyBox.destroy();
    this.skyAtmosphere = this.skyAtmosphere && this.skyAtmosphere.destroy();
    this._debugSphere = this._debugSphere && this._debugSphere.destroy();
    this.sun = this.sun && this.sun.destroy();
    this._sunPostProcess = this._sunPostProcess && this._sunPostProcess.destroy();
    
    this._transitioner.destroy();
    
    this._oit.destroy();
    this._fxaa.destroy();
    
    this._context = this._context && this._context.destroy();
    this._frameState.creditDisplay.destroy();
    if (defined(this._performanceDisplay)){
        this._performanceDisplay = this._performanceDisplay && this._performanceDisplay.destroy();
        this._performanceContainer.parentNode.removeChild(this._performanceContainer);
    }
    
    return destroyObject(this);
};*/

@end
