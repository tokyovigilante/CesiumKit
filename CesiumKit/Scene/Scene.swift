//
//  Scene.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import MetalKit

private let OpaqueFrustumNearOffset = 0.99

/**
* The container for all 3D graphical objects and state in a Cesium virtual scene.  Generally,
* a scene is not created directly; instead, it is implicitly created by {@link CesiumWidget}.
* <p>
* <em><code>contextOptions</code> parameter details:</em>
* </p>
* <p>
* The default values are:
* <code>
* {
*   webgl : {
*     alpha : false,
*     depth : true,
*     stencil : false,
*     antialias : true,
*     premultipliedAlpha : true,
*     preserveDrawingBuffer : false
*     failIfMajorPerformanceCaveat : true
*   },
*   allowTextureFilterAnisotropic : true
* }
* </code>
* </p>
* <p>
* The <code>webgl</code> property corresponds to the {@link http://www.khronos.org/registry/webgl/specs/latest/#5.2|WebGLContextAttributes}
* object used to create the WebGL context.
* </p>
* <p>
* <code>options.webgl.alpha</code> defaults to false, which can improve performance compared to the standard WebGL default
* of true.  If an application needs to composite Cesium above other HTML elements using alpha-blending, set
* <code>options.webgl.alpha</code> to true.
* </p>
* <p>
* <code>options.webgl.failIfMajorPerformanceCaveat</code> defaults to true, which ensures a context is not successfully created
* if the system has a major performance issue such as only supporting software rendering.  The standard WebGL default is false,
* which is not appropriate for almost any Cesium app.
* </p>
* <p>
* The other <code>options.webgl</code> properties match the WebGL defaults for {@link http://www.khronos.org/registry/webgl/specs/latest/#5.2|WebGLContextAttributes}.
* </p>
* <p>
* <code>options.allowTextureFilterAnisotropic</code> defaults to true, which enables anisotropic texture filtering when the
* WebGL extension is supported.  Setting this to false will improve performance, but hurt visual quality, especially for horizon views.
* </p>
*
* @alias Scene
* @constructor
*
* @param {Canvas} canvas The HTML canvas element to create the scene for.
* @param {Object} [contextOptions] Context and WebGL creation properties.  See details above.
* @param {Element} [creditContainer] The HTML element in which the credits will be displayed.
*
* @see CesiumWidget
* @see {@link http://www.khronos.org/registry/webgl/specs/latest/#5.2|WebGLContextAttributes}
*
* @example
* // Create scene without anisotropic texture filtering
* var scene = new Cesium.Scene(canvas, {
*   allowTextureFilterAnisotropic : false
* });
*/

public class Scene {
    
    let context: Context
    
    private let _computeEngine: ComputeEngine
    
    /*
    if (!defined(creditContainer)) {
        creditContainer = document.createElement('div');
        creditContainer.style.position = 'absolute';
        creditContainer.style.bottom = '0';
        creditContainer.style['text-shadow'] = '0px 0px 2px #000000';
        creditContainer.style.color = '#ffffff';
        creditContainer.style['font-size'] = '10px';
        creditContainer.style['padding-right'] = '5px';
        canvas.parentNode.appendChild(creditContainer);
    }*/
    
    /**
    * Gets or sets the depth-test ellipsoid.
    * @memberof Scene.prototype
    * @type {Globe}
    */
    var globe: Globe!
    
    /**
    * Gets the collection of primitives.
    * @memberof Scene.prototype
    * @type {PrimitiveCollection}
    */
    let primitives = PrimitiveCollection()

    /**
     * Gets the collection of ground primitives.
     * @memberof Scene.prototype
     *
     * @type {PrimitiveCollection}
     * @readonly
     */
    let groundPrimitives = PrimitiveCollection()
    
    //var pickFramebuffer: Framebuffer? = nil
    
    //TODO: TweenCollection
//    var tweens = TweenCollection()

    /**
    * Gets the camera.
    * @memberof Scene.prototype
    * @type {Camera}
    */
    // TODO: setCamera
    public var camera: Camera
    public var cameraClone: Camera

    #if os(iOS)
    var touchEventHandler: TouchEventHandler!
    #endif
    /**
    * Gets the controller for camera input handling.
    * @memberof Scene.prototype
    * @type {ScreenSpaceCameraController}
    */
    lazy public var screenSpaceCameraController: ScreenSpaceCameraController = {
        ScreenSpaceCameraController(scene: self)
        }()
    
    /**
     * Get the map projection to use in 2D and Columbus View modes.
     * @memberof Scene.prototype
     *
     * @type {MapProjection}
     * @readonly
     *
     * @default new GeographicProjection()
     */
    private(set) var mapProjection: MapProjection
    
    /**
    * Gets state information about the current scene. If called outside of a primitive's <code>update</code>
    * function, the previous frame's state is returned.
    * @memberof Scene.prototype
    * @type {FrameState}
    */
    private (set) var frameState: FrameState
    
    private var _passState: PassState

    /**
    * Gets the collection of animations taking place in the scene.
    * @memberof Scene.prototype
    * @type {AnimationCollection}
    */
    // TODO: AnimationCollection
    //var animations = AnimationCollection()
    
    
    var shaderFrameCount = 0
    
    //this._sunPostProcess = undefined;
    
    private var _computeCommandList = [ComputeCommand]()
    private var _commandList = [Command]()
    private var _frustumCommandsList = [FrustumCommands]()
    private var _overlayCommandList = [DrawCommand]()
    
    
    // TODO: OIT
    
    private var _globeDepth: GlobeDepth? = nil
    private var _depthPlane = DepthPlane()
    private var _oit: OIT? = nil
    private var _executeOITFunction: ((
        scene: Scene,
        executeFunction: ((DrawCommand, RenderPass, RenderPipeline?) -> ()),
        passState: PassState,
        commands: [DrawCommand]) -> ())? = nil
    
    private let _fxaa = FXAA()
    
    
    var _clearColorCommand = ClearCommand(color: Cartesian4.zero(), stencil: 0/*, owner: self*/)
    
    var _depthClearCommand = ClearCommand(depth: 1.0/*, owner: self*/)
    
    lazy var transitioner: SceneTransitioner = { return SceneTransitioner(owner: self, projection: self.mapProjection) }()
    
    private var _pickDepths = [Int: PickDepth]()
    private var _debugGlobeDepths = [Int: GlobeDepth]()
    
    /**
    * Gets the event that will be raised when an error is thrown inside the <code>render</code> function.
    * The Scene instance and the thrown error are the only two parameters passed to the event handler.
    * By default, errors are not rethrown after this event is raised, but that can be changed by setting
    * the <code>rethrowRenderErrors</code> property.
    * @memberof Scene.prototype
    * @type {Event}
    */
    var renderError = Event()
    
    /**
    * Gets the event that will be raised at the start of each call to <code>render</code>.  Subscribers to the event
    * receive the Scene instance as the first parameter and the current time as the second parameter.
    * @memberof Scene.prototype
    * @type {Event}
    */
    var preRender = Event()
    
    /**
    * Gets the event that will be raised at the end of each call to <code>render</code>.  Subscribers to the event
    * receive the Scene instance as the first parameter and the current time as the second parameter.
    * @memberof Scene.prototype
    * @type {Event}
    */
    var postRender = Event()
    
    private var _cameraStartFired = false
    private var _cameraMovedTime: Double? = nil
    
    /*
    /**
    * Exceptions occurring in <code>render</code> are always caught in order to raise the
    * <code>renderError</code> event.  If this property is true, the error is rethrown
    * after the event is raised.  If this property is false, the <code>render</code> function
    * returns normally after raising the event.
    *
    * @type {Boolean}
    * @default false
    */
    this.rethrowRenderErrors = false;
    */
    
    /**
    * Determines whether or not to instantly complete the
    * scene transition animation on user input.
    *
    * @type {Boolean}
    * @default true
    */
    var completeMorphOnUserInput = true
    
    /**
    * The event fired at the beginning of a scene transition.
    * @type {Event}
    * @default Event()
    */
    var morphStart = Event()
    
    /**
    * The event fired at the completion of a scene transition.
    * @type {Event}
    * @default Event()
    */
    var morphComplete = Event()
    
    /**
    * The {@link SkyBox} used to draw the stars.
    *
    * @type {SkyBox}
    * @default undefined
    *
    * @see Scene#backgroundColor
    */
    var skyBox: SkyBox? = nil
    
    /**
    * The sky atmosphere drawn around the globe.
    *
    * @type {SkyAtmosphere}
    * @default undefined
    */
    var skyAtmosphere: SkyAtmosphere? = nil
    
    /**
    * The {@link Sun}.
    *
    * @type {Sun}
    * @default undefined
    */
    //this.sun = undefined;
    
    /**
    * Uses a bloom filter on the sun when enabled.
    *
    * @type {Boolean}
    * @default true
    */
    //this.sunBloom = true;
    //this._sunBloom = undefined;
    
    /**
    * The {@link Moon}
    *
    * @type Moon
    * @default undefined
    */
    //this.moon = undefined;
    
    /**
    * The background color, which is only visible if there is no sky box, i.e., {@link Scene#skyBox} is undefined.
    *
    * @type {Color}
    * @default {@link Color.BLACK}
    *
    * @see Scene#skyBox
    */
    var backgroundColor = Cartesian4.zero()
    
    /**
    * The current mode of the scene.
    *
    * @type {SceneMode}
    * @default {@link SceneMode.SCENE3D}
    */
    var mode: SceneMode = .Scene3D {
        didSet {
            if mode != .Scene3D && scene3DOnly {
                mode = .Scene3D
            }
        }
    }
    
    /**
     * Gets the number of frustums used in the last frame.
     * @memberof Scene.prototype
     * @type {Number}
     *
     * @private
     */
    var numberOfFrustums: Int { return _frustumCommandsList.count }
    
    /**
    * The current morph transition time between 2D/Columbus View and 3D,
    * with 0.0 being 2D or Columbus View and 1.0 being 3D.
    *
    * @type {Number}
    * @default 1.0
    */
    var morphTime = 1.0

    /**
    * The far-to-near ratio of the multi-frustum. The default is 1,000.0.
    *
    * @type {Number}
    * @default 1000.0
    */
    var farToNearRatio = 1000.0
    
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
    //var debugCommandFilter = () -> ()?
    
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
    public var debugShowCommands = false
    
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
    var _debugShowFrustums = false
    
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
    * @memberof Scene.prototype
    *
    * @type Object
    * @readonly
    *
    * @default undefined
    */
    private var _debugFrustumStatistics: (totalCommands: Int, commandsInFrustums: [Int]) = (0, [Int]())
    
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
    var debugShowFramesPerSecond = false
    
    /**
    * Gets whether or not the scene is optimized for 3D only viewing.
    * @memberof Scene.prototype
    * @type {Boolean}
    * @readonly
    */
    var scene3DOnly: Bool { return frameState.scene3DOnly }
    
    /**
    * Gets whether or not the scene has order independent translucency enabled.
    * Note that this only reflects the original construction option, and there are
    * other factors that could prevent OIT from functioning on a given system configuration.
    * @memberof Scene.prototype
    * @type {Boolean}
    * @readonly
    */
    var orderIndependentTranslucency: Bool { return _oit != nil }
    
    /**
     * This property is for debugging only; it is not for production use.
     * <p>
     * Displays depth information for the indicated frustum.
     * </p>
     * @type Boolean
     *
     * @default false
     */
    var debugShowGlobeDepth = false
    
    /**
     * This property is for debugging only; it is not for production use.
     * <p>
     * Indicates which frustum will have depth information displayed.
     * </p>
     *
     * @type Number
     *
     * @default 1
     */
    var debugShowDepthFrustum = 1
    
    /**
    * When <code>true</code>, enables Fast Approximate Anti-aliasing even when order independent translucency
    * is unsupported.
    *
    * @type Boolean
    * @default true
    */
    var fxaa = true
    
    /**
     * The time in milliseconds to wait before checking if the camera has not moved and fire the cameraMoveEnd event.
     * @type {Number}
     * @default 500.0
     * @private
     */
    var cameraEventWaitTime = 500.0
    
    /**
     * Set to true to copy the depth texture after rendering the globe. Makes czm_globeDepthTexture valid.
     * @type {Boolean}
     @default false
     * @private
     */
    var copyGlobeDepth = false
    
    //this._performanceDisplay = undefined;
    private var _debugVolume: BoundingVolume? = nil
    

    
    /**
    * The drawingBufferWidth of the underlying GL context.
    * @memberof Scene.prototype
    * @type {Number}
    * @see {@link https://www.khronos.org/registry/webgl/specs/1.0/#DOM-WebGLRenderingContext-drawingBufferWidth|drawingBufferWidth}
    */
    var drawableHeight: Int {
        get {
            return context.height
        }
        set (newValue) {
            context.height = newValue
        }
    }
    
    /**
    * The drawingBufferHeight of the underlying GL context.
    * @memberof Scene.prototype
    * @type {Number}
    * @see {@link https://www.khronos.org/registry/webgl/specs/1.0/#DOM-WebGLRenderingContext-drawingBufferHeight|drawingBufferHeight}
    */
    var drawableWidth: Int {
        get {
            return context.width
        }
        set (newValue) {
            context.width = newValue
        }
    }

    /**
    * The maximum aliased line width, in pixels, supported by this WebGL implementation.  It will be at least one.
    * @memberof Scene.prototype
    * @type {Number}
    * @see {@link http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml|glGet} with <code>ALIASED_LINE_WIDTH_RANGE</code>.
    */
    var maximumAliasedLineWidth: Int { return context.limits.maximumAliasedLineWidth }
    
    /**
     * The maximum length in pixels of one edge of a cube map, supported by this WebGL implementation.  It will be at least 16.
     * @memberof Scene.prototype
     *
     * @type {Number}
     * @readonly
     *
     */
    var maximumCubeMapSize: Int { return context.limits.maximumCubeMapSize }
    
    /**
     * Returns true if the pickPosition function is supported.
     *
     * @type {Boolean}
     * @readonly
     */
    var pickPositionSupported: Bool { return context.depthTexture }
    
    /**
    * Gets the collection of image layers that will be rendered on the globe.
    * @memberof Scene.prototype
    * @type {ImageryLayerCollection}
    */
    public var imageryLayers: ImageryLayerCollection { return globe.imageryLayers }

    /**
    * The terrain provider providing surface geometry for the globe.
    * @memberof Scene.prototype
    * @type {TerrainProvider}
    */
    var terrainProvider: TerrainProvider {
        get {
            return globe.terrainProvider
        }
        set (newTerrainProvider) {
            globe.terrainProvider = newTerrainProvider
        }
    }
    
    /**
    * Gets the unique identifier for this scene.
    * @memberof Scene.prototype
    * @type {String}
    * @readonly
    */
    let id: String

    init (view: MTKView, globe: Globe, useOIT: Bool = true, scene3DOnly: Bool = false, projection: MapProjection = GeographicProjection()) {
        
        context = Context(view: view)
        
        if let name = context.device.name {
            if name.hasPrefix("NVIDIA") {
                print("FXAA disabled - NVIDIA GPU")
                fxaa = false
            }
        }
        
        _computeEngine = ComputeEngine(context: context)
        
        self.globe = globe
        
        self.mapProjection = projection
        
        id = NSUUID().UUIDString
            
        frameState = FrameState()
        frameState.context = context/*new CreditDisplay(creditContainer*/
        frameState.scene3DOnly = scene3DOnly
        
        _passState = PassState()
        _passState.context = context
        
        // initial guess at frustums.
        camera = Camera(
            projection: projection,
            mode: mode,
            initialWidth: Double(view.drawableSize.width),
            initialHeight: Double(view.drawableSize.height)
        )
        cameraClone = Camera(
            projection: projection,
            mode: mode,
            initialWidth: Double(view.drawableSize.width),
            initialHeight: Double(view.drawableSize.height)
        )

        #if os(iOS)
        touchEventHandler = TouchEventHandler(scene: self, view: view)
        #endif
        
        let globeDepth: GlobeDepth?
        
        if context.depthTexture {
            globeDepth = GlobeDepth()
        } else {
            globeDepth = nil
        }
        
        let oit: OIT?
        if useOIT && globeDepth != nil {
            oit = OIT(context: context)
        } else {
            oit = nil
        }
        _globeDepth = globeDepth
        _oit = oit
        
        camera.scene = self
        let near = camera.frustum.near
        let far = camera.frustum.far
        let numFrustums = Int(ceil(log(far / near) / log(farToNearRatio)))
        updateFrustums(near: near, far: far, farToNearRatio: farToNearRatio, numFrustums: numFrustums)
        
        // give frameState, camera, and screen space camera controller initial state before rendering
        updateFrameState(0, time: JulianDate.now())
        initializeFrame()
    }

    func maxComponent(a a: Cartesian3, b: Cartesian3) -> Double {
        return max(
            abs(a.x), abs(b.x),
            abs(a.y), abs(b.y),
            abs(a.z), abs(b.z)
        )
    }

    func cameraEqual(camera0: Camera, camera1: Camera, epsilon: Double) -> Bool {
        let scalar = 1 / max(1, maxComponent(a: camera0.position, b: camera1.position))
        let position0 = camera0.position.multiplyByScalar(scalar)
        let position1 = camera1.position.multiplyByScalar(scalar)
        return position0.equalsEpsilon(position1, relativeEpsilon: epsilon, absoluteEpsilon: epsilon) &&
            camera0.direction.equalsEpsilon(camera1.direction, relativeEpsilon: epsilon, absoluteEpsilon: epsilon) &&
            camera0.up.equalsEpsilon(camera1.up, relativeEpsilon: epsilon, absoluteEpsilon: epsilon) &&
            camera0.right.equalsEpsilon(camera1.right, relativeEpsilon: epsilon, absoluteEpsilon: epsilon) &&
            camera0.transform.equalsEpsilon(camera1.transform, epsilon: epsilon)
    }


    func getOccluder() -> Occluder? {
        // TODO: The occluder is the top-level globe. When we add
        //       support for multiple central bodies, this should be the closest one.
        if mode == SceneMode.Scene3D {//&& globe != nil {
            return Occluder(occluderBoundingSphere: BoundingSphere(radius: globe.ellipsoid.minimumRadius), cameraPosition: camera.positionWC)
        }
        return nil
    }

    func clearPasses(inout passes: FrameState.Passes ) {
        passes.render = false
        passes.pick = false
    }

    func updateFrameState(frameNumber: Int, time: JulianDate) {

        frameState.mode = mode
        frameState.morphTime = morphTime
        frameState.mapProjection = mapProjection
        frameState.frameNumber = frameNumber
        frameState.time = time
        frameState.camera = camera
        frameState.cullingVolume = camera.frustum.computeCullingVolume(
            position: camera.positionWC,
            direction: camera.directionWC,
            up: camera.upWC)
        frameState.occluder = getOccluder()
        
        clearPasses(&frameState.passes)
    }
    
    func updateFrustums(near near: Double, far: Double, farToNearRatio: Double, numFrustums: Int) {
        
        for m in 0..<numFrustums {
            let curNear = max(near, pow(farToNearRatio, Double(m)) * near)
            let curFar = min(far, farToNearRatio * curNear)
            
            if _frustumCommandsList.count > m {
                _frustumCommandsList[m].near = curNear
                _frustumCommandsList[m].far = curFar
            }
            else {
                _frustumCommandsList.append(FrustumCommands(near: curNear, far: curFar))
            }
        }
        if _frustumCommandsList.count > numFrustums {
            _frustumCommandsList.removeRange(Range(numFrustums..<_frustumCommandsList.count))
        }
    }

    func insertIntoBin(command: DrawCommand, distance: Interval) {
        if _debugShowFrustums {
            command.debugOverlappingFrustums = 0
        }
        
        for (index, frustumCommands) in _frustumCommandsList.enumerate() {
            if distance.start > frustumCommands.far {
                continue
            }
            
            if distance.stop < frustumCommands.near {
                break
            }
            frustumCommands.commands[command.pass]!.append(command)
            
            if _debugShowFrustums {
                command.debugOverlappingFrustums |= (1 << index)
            }
            
            if command.executeInClosestFrustum {
                break
            }
        }
        if _debugShowFrustums {
            // FIXME: debugShowFrustums
            //let cf = _debugFrustumStatistics.commandsInFrustums
            //cf[command.debugOverlappingFrustums] = defined(cf[command.debugOverlappingFrustums]) ? cf[command.debugOverlappingFrustums] + 1 : 1;
            //++scene._debugFrustumStatistics.totalCommands;
        }
    }

    func createPotentiallyVisibleSet() {
        
        var distances = Interval()
        
        let direction = camera.directionWC
        let position = camera.positionWC
        
        
        //FIXME debugShowFrustums
        if _debugShowFrustums {
            _debugFrustumStatistics = (
                totalCommands : 0,
                commandsInFrustums : [Int]()
            )
        }
        
        let numberOfFrustums = _frustumCommandsList.count
        for frustumCommands in _frustumCommandsList {
            frustumCommands.removeAll()
        }
        var near: Double = Double.infinity
        var far: Double = 0.0
        var undefBV = false
        
        let occluder: Occluder?
        if frameState.mode == .Scene3D {
            occluder = frameState.occluder
        } else {
            occluder = nil
        }
        
        // get user culling volume minus the far plane.
        var planes = frameState.cullingVolume!.planes[0...4]
        let cullingVolume = CullingVolume(planes: Array(planes[0..<planes.count]))
        
        for command in _commandList {
            
            if command.pass == .Compute {
                _computeCommandList.append(command as! ComputeCommand)
            } else if command.pass == .Overlay {
                _overlayCommandList.append(command as! DrawCommand)
            } else {
                let command = command as! DrawCommand
                if let boundingVolume = command.boundingVolume {
                    if command.cull && (cullingVolume.visibility(boundingVolume) == .Outside ||
                        occluder != nil && boundingVolume.isOccluded(occluder!)) {
                            continue
                    }
                    
                    distances = boundingVolume.computePlaneDistances(position, direction: direction)
                    near = min(near, distances.start)
                    far = max(far, distances.stop)
                } else {
                    // Clear commands don't need a bounding volume - just add the clear to all frustums.
                    // If another command has no bounding volume, though, we need to use the camera's
                    // worst-case near and far planes to avoid clipping something important.
                    distances.start = camera.frustum.near
                    distances.stop = camera.frustum.far
                    undefBV = true//!(command is ClearCommand)
                }
                
                insertIntoBin(command, distance: distances)
            }
        }
        
        if (undefBV) {
            near = camera.frustum.near
            far = camera.frustum.far
        } else {
            // The computed near plane must be between the user defined near and far planes.
            // The computed far plane must between the user defined far and computed near.
            // This will handle the case where the computed near plane is further than the user defined far plane.
            near = min(max(near, camera.frustum.near), camera.frustum.far)
            far = max(min(far, camera.frustum.far), near)
        }
        
        // Exploit temporal coherence. If the frustums haven't changed much, use the frustums computed
        // last frame, else compute the new frustums and sort them by frustum again.
        let numFrustums = Int(ceil(log(far / near) / log(farToNearRatio)))
        if near != Double.infinity &&
            (numFrustums != numberOfFrustums ||
                (_frustumCommandsList.count != 0 &&
                    (near < (_frustumCommandsList.first! as FrustumCommands).near
                        || far > (_frustumCommandsList.last! as FrustumCommands).far)
                )
            ) {
                updateFrustums(near: near, far: far, farToNearRatio: farToNearRatio, numFrustums: numFrustums)
                createPotentiallyVisibleSet()
        }
    }
    
/*
function getAttributeLocations(shaderProgram) {
    var attributeLocations = {};
    var attributes = shaderProgram.vertexAttributes;
    for (var a in attributes) {
        if (attributes.hasOwnProperty(a)) {
            attributeLocations[a] = attributes[a].index;
        }
    }
    
    return attributeLocations;
}

function createDebugFragmentShaderProgram(command, scene, shaderProgram) {
    var context = scene.context;
    var sp = defaultValue(shaderProgram, command.shaderProgram);
    var fs = sp.fragmentShaderSource.clone();
    
    fs.sources = fs.sources.map(function(source) {
    source = source.replace(/void\s+main\s*\(\s*(?:void)?\s*\)/g, 'void czm_Debug_main()');
    return source;
    });
    
    var newMain =
    'void main() \n' +
    '{ \n' +
        '    czm_Debug_main(); \n';
        
        if (scene.debugShowCommands) {
            if (!defined(command._debugColor)) {
                command._debugColor = Color.fromRandom();
            }
            var c = command._debugColor;
            newMain += '    gl_FragColor.rgb *= vec3(' + c.red + ', ' + c.green + ', ' + c.blue + '); \n';
        }
        
        if (scene.debugShowFrustums) {
            // Support up to three frustums.  If a command overlaps all
            // three, it's code is not changed.
            var r = (command.debugOverlappingFrustums & (1 << 0)) ? '1.0' : '0.0';
            var g = (command.debugOverlappingFrustums & (1 << 1)) ? '1.0' : '0.0';
            var b = (command.debugOverlappingFrustums & (1 << 2)) ? '1.0' : '0.0';
            newMain += '    gl_FragColor.rgb *= vec3(' + r + ', ' + g + ', ' + b + '); \n';
        }
        
        newMain += '}';
    
    fs.sources.push(newMain);
    var attributeLocations = getAttributeLocations(sp);
    return ShaderProgram.fromCache({
    +            context : context,
    +            vertexShaderSource : sp.vertexShaderSource,
    +            fragmentShaderSource : fs,
    +            attributeLocations : attributeLocations
    +        });}

function executeDebugCommand(command, scene, passState, renderState, shaderProgram) {
    if (defined(command.shaderProgram) || defined(shaderProgram)) {
        // Replace shader for frustum visualization
        var sp = createDebugFragmentShaderProgram(command, scene, shaderProgram);
        command.execute(scene.context, passState, renderState, sp);
        sp.destroy();
    }
}

var transformFrom2D = Matrix4.inverseTransformation(//
    new Matrix4(0.0, 0.0, 1.0, 0.0, //
        1.0, 0.0, 0.0, 0.0, //
        0.0, 1.0, 0.0, 0.0, //
        0.0, 0.0, 0.0, 1.0));
*/
    
    func executeCommand(command: DrawCommand, renderPass: RenderPass, renderPipeline: RenderPipeline? = nil) {
        // FIXME: scene.debugCommandFilter
        /*if ((defined(scene.debugCommandFilter)) && !scene.debugCommandFilter(command)) {
            return;
        }*/
        // FIXME: debugShowCommands
        /*
        if (scene.debugShowCommands || scene.debugShowFrustums) {
            executeDebugCommand(command, scene, passState, renderState, shaderProgram);
        } else {*/
        command.execute(context, renderPass: renderPass, renderPipeline: renderPipeline)
        //}
        
        /*if (command.debugShowBoundingVolume && (defined(command.boundingVolume))) {
            // Debug code to draw bounding volume for command.  Not optimized!
        +            // Assumes bounding volume is a bounding sphere or box

        
            var frameState = scene._frameState;
            var boundingVolume = command.boundingVolume;

            
        +            if (defined(scene._debugVolume)) {
        +                scene._debugVolume.destroy();
        +            }
        +
        +            var geometry;
        
        +            var center = Cartesian3.clone(boundingVolume.center);
            
            if (frameState.mode !== SceneMode.SCENE3D) {
                center = Matrix4.multiplyByPoint(transformFrom2D, center);
                var projection = frameState.scene2D.projection;
                var centerCartographic = projection.unproject(center);
                center = projection.ellipsoid.cartographicToCartesian(centerCartographic);
            }
            
        if (defined(boundingVolume.radius)) {
        +                var radius = boundingVolume.radius;
        +
        +                geometry = GeometryPipeline.toWireframe(EllipsoidGeometry.createGeometry(new EllipsoidGeometry({
        +                    radii : new Cartesian3(radius, radius, radius),
        +                    vertexFormat : PerInstanceColorAppearance.FLAT_VERTEX_FORMAT
        +                })));
        +
        +                scene._debugVolume = new Primitive({
        +                    geometryInstances : new GeometryInstance({
        +                        geometry : geometry,
        +                        modelMatrix : Matrix4.multiplyByTranslation(Matrix4.IDENTITY, center, new Matrix4()),
        +                        attributes : {
        +                            color : new ColorGeometryInstanceAttribute(1.0, 0.0, 0.0, 1.0)
        +                        }
        +                    }),
        +                    appearance : new PerInstanceColorAppearance({
        +                        flat : true,
        +                        translucent : false
        +                    }),
        +                    asynchronous : false
        +                });
        +            } else {
        +                var halfAxes = boundingVolume.halfAxes;
        +
        +                geometry = GeometryPipeline.toWireframe(BoxGeometry.createGeometry(BoxGeometry.fromDimensions({
        +                    dimensions : new Cartesian3(2.0, 2.0, 2.0),
        +                    vertexFormat : PerInstanceColorAppearance.FLAT_VERTEX_FORMAT
        +                })));
        +
        +                scene._debugVolume = new Primitive({
        +                    geometryInstances : new GeometryInstance({
        +                        geometry : geometry,
        +                        modelMatrix : Matrix4.fromRotationTranslation(halfAxes, center, new Matrix4()),
        +                        attributes : {
        +                            color : new ColorGeometryInstanceAttribute(1.0, 0.0, 0.0, 1.0)
        +                        }
        +                    }),
        +                    appearance : new PerInstanceColorAppearance({
        +                        flat : true,
        +                        translucent : false
        +                    }),
        +                    asynchronous : false
        +                });
        +            }
        
            
            var commandList = [];
        +            scene._debugVolume.update(context, frameState, commandList);
        
            var framebuffer;
            if (defined(debugFramebuffer)) {
                framebuffer = passState.framebuffer;
                passState.framebuffer = debugFramebuffer;
            }
            
            commandList[0].execute(context, passState);
            
            if (defined(framebuffer)) {
                passState.framebuffer = framebuffer;
            }
        }*/
    }
/*
function isVisible(command, frameState) {
    if (!defined(command)) {
        return;
    }
    
    var occluder = (frameState.mode === SceneMode.SCENE3D) ? frameState.occluder: undefined;
    var cullingVolume = frameState.cullingVolume;
    
    // get user culling volume minus the far plane.
    var planes = scratchCullingVolume.planes;
    for (var k = 0; k < 5; ++k) {
        planes[k] = cullingVolume.planes[k];
    }
    cullingVolume = scratchCullingVolume;
    
    var boundingVolume = command.boundingVolume;
    
    return ((defined(command)) &&
        ((!defined(command.boundingVolume)) ||
            !command.cull ||
            ((cullingVolume.getVisibility(boundingVolume) !== Intersect.OUTSIDE) &&
    +                   (!defined(occluder) || !boundingVolume.isOccluded(occluder)))));
}
*/
    func translucentCompare(a: DrawCommand, b: DrawCommand, position: Cartesian3) -> Bool {
    return b.boundingVolume!.distanceSquaredTo(position) > a.boundingVolume!.distanceSquaredTo(position)
}

    func executeTranslucentCommandsSorted(
        scene: Scene, executeFunction: ((DrawCommand, RenderPass, RenderPipeline?) -> ()), passState: PassState, commands: [DrawCommand]) {
        // FIXME: sorting
        //mergeSort(commands, translucentCompare, scene._camera.positionWC)
        
        //var length = commands.count
        //for (var j = 0; j < length; ++j) {
        //    executeFunction(commands[j], context: context, passState: passState)
        //}
    }

    
    func getDebugGlobeDepth(index: Int) -> GlobeDepth {
        var globeDepth = _debugGlobeDepths[index]
        if globeDepth == nil && context.depthTexture {
            globeDepth = GlobeDepth()
            _debugGlobeDepths[index] = globeDepth
        }
        return globeDepth!
    }
    
    func getPickDepth(index: Int) -> PickDepth {
        var pickDepth = _pickDepths[index]
        if pickDepth == nil {
            pickDepth = PickDepth()
            _pickDepths[index] = pickDepth
        }
        return pickDepth!
    }
    /*
    
    var scratchPerspectiveFrustum = new PerspectiveFrustum();
var scratchPerspectiveOffCenterFrustum = new PerspectiveOffCenterFrustum();
var scratchOrthographicFrustum = new OrthographicFrustum();
*/
    func executeCommands(passState: PassState, clearColor: Cartesian4, picking: Bool = false) {
        
        // Manage sun bloom post-processing effect.
        
        // FIXME: SunBloom
        /*if (defined(scene.sun) && scene.sunBloom !== scene._sunBloom) {
        if (scene.sunBloom) {
        scene._sunPostProcess = new SunPostProcess();
        } else if(defined(scene._sunPostProcess)){
        scene._sunPostProcess = scene._sunPostProcess.destroy();
        }
        
        scene._sunBloom = scene.sunBloom;
        } else if (!defined(scene.sun) && defined(scene._sunPostProcess)) {
        scene._sunPostProcess = scene._sunPostProcess.destroy();
        scene._sunBloom = false;
        }*/
        
        // Manage celestial and terrestrial environment effects.
        let renderPass = frameState.passes.render
        let skyBoxCommand: DrawCommand? = (renderPass && skyBox != nil) ? skyBox!.update(context, frameState: frameState) : nil
        let skyAtmosphereCommand: DrawCommand? = (renderPass && skyAtmosphere != nil) ? skyAtmosphere!.update(context, frameState: frameState) : nil
        /*var sunCommands = (renderPass && defined(scene.sun)) ? scene.sun.update(scene) : undefined;
        var sunDrawCommand = defined(sunCommands) ? sunCommands.drawCommand : undefined;
        var sunComputeCommand = defined(sunCommands) ? sunCommands.computeCommand : undefined;
        var sunVisible = isVisible(sunDrawCommand, frameState);
        var moonCommand = (renderPass && defined(scene.moon)) ? scene.moon.update(context, frameState) : undefined;
        var moonVisible = isVisible(moonCommand, frameState);*/
        
        // Preserve the reference to the original framebuffer.
        let originalFramebuffer = passState.framebuffer ?? context.defaultFramebuffer
        
        // Create a working frustum from the original camera frustum
        let frustum: Frustum
        if camera.frustum.fovy != Double.NaN {
            frustum = camera.frustum.clone(PerspectiveFrustum())
        } else if camera.frustum.infiniteProjectionMatrix != nil {
            frustum = camera.frustum.clone(PerspectiveOffCenterFrustum())
        } else {
            frustum = camera.frustum.clone(OrthographicFrustum())
        }
        
        // Clear the pass state framebuffer.
        _clearColorCommand.color = clearColor
        _clearColorCommand.execute(context, passState: passState)
        
        // Update globe depth rendering based on the current context and clear the globe depth framebuffer.
        let useGlobeDepthFramebuffer = !picking && _globeDepth != nil
        if useGlobeDepthFramebuffer {
            _globeDepth!.update(context)
            _globeDepth!.clear(context, passState: passState, clearColor: clearColor)
        }
        
        // Determine if there are any translucent surfaces in any of the frustums.
        var renderTranslucentCommands = false
        for frustum in _frustumCommandsList {
            if frustum.commands[Pass.Translucent]!.count > 0 {
                renderTranslucentCommands = true
                break
            }
        }
    
        let clearGlobeDepth = globe != nil && (!globe.depthTestAgainstTerrain || mode == SceneMode.Scene2D)
        let useDepthPlane = clearGlobeDepth && mode == SceneMode.Scene3D
        if useDepthPlane {
            // Update the depth plane that is rendered in 3D when the primitives are
            // not depth tested against terrain so primitives on the backface
            // of the globe are not picked.
            _depthPlane.update(context, frameState: frameState)
        }
        
        // If supported, configure OIT to use the globe depth framebuffer and clear the OIT framebuffer.
        var useOIT = !picking && renderTranslucentCommands && _oit != nil && _oit!.isSupported()
        if useOIT {
            //FIXME: Renderstate
            //_oit.update(context, scene._globeDepth.framebuffer);
            //_oit.clear(context, passState, clearColor);
            useOIT = useOIT && _oit!.isSupported()
        }
        
        // If supported, configure FXAA to use the globe depth color texture and clear the FXAA framebuffer.
        let useFXAA = !picking && fxaa
        if useFXAA {
            _fxaa.update(context)
            _fxaa.clear(context, passState: passState, clearColor: clearColor)
        }
        
        if false /*sunVisible && scene.sunBloom)*/ {
            //passState.framebuffer = scene._sunPostProcess.update(context);
        } else if useGlobeDepthFramebuffer {
            passState.framebuffer = _globeDepth!.framebuffer
        } else if useFXAA {
            passState.framebuffer = _fxaa.getColorFramebuffer()
        }
        
        if passState.framebuffer !== context.defaultFramebuffer {
            _clearColorCommand.execute(context, passState: passState)
        }
        
        // Ideally, we would render the sky box and atmosphere last for
        // early-z, but we would have to draw it in each frustum
        frustum.near = camera.frustum.near
        frustum.far = camera.frustum.far
        context.uniformState.updateFrustum(frustum)
        
        let spaceRenderPass = context.createRenderPass(passState)
        
        if let skyBoxCommand = skyBoxCommand {
            executeCommand(skyBoxCommand, renderPass: spaceRenderPass)
        }
        
        if let skyAtmosphereCommand = skyAtmosphereCommand {
            executeCommand(skyAtmosphereCommand, renderPass: spaceRenderPass)
        }
        
        /*
        if (sunVisible) {
            if (defined(sunComputeCommand)) {
                sunComputeCommand.execute(scene._computeEngine);
            }
            sunDrawCommand.execute(context, passState);
            if (scene.sunBloom) {
                var framebuffer;
                if (useGlobeDepthFramebuffer) {
                    framebuffer = scene._globeDepth.framebuffer;
                } else if (useFXAA) {
                    framebuffer = scene._fxaa.getColorFramebuffer();
                } else {
                    framebuffer = originalFramebuffer;
                }
                scene._sunPostProcess.execute(context, framebuffer);
                passState.framebuffer = framebuffer;
            }
        }
        // Moon can be seen through the atmosphere, since the sun is rendered after the atmosphere.
        if (moonVisible) {
            moonCommand.execute(context, passState);
        }*/
        spaceRenderPass.complete()
        
        // Determine how translucent surfaces will be handled.
        let executeTranslucentCommands: ((
        scene: Scene,
        executeFunction: ((DrawCommand, RenderPass, RenderPipeline?) -> ()),
        passState: PassState,
        commands: [DrawCommand]) -> ())
        
        if useOIT {
            if _executeOITFunction == nil {
                _executeOITFunction = { scene, executeFunction, passState, commands in
                    self._oit!.executeCommands(scene, executeFunction: executeFunction, passState: passState, commands: commands)
                }
            }
            executeTranslucentCommands = _executeOITFunction!
        } else {
            executeTranslucentCommands = executeTranslucentCommandsSorted
        }
        
        let clearDepth = _depthClearCommand

        // Execute commands in each frustum in back to front order
        for (index, frustumCommands) in _frustumCommandsList.enumerate() {
            
            // Avoid tearing artifacts between adjacent frustums in the opaque passes
            frustum.near = index != 0 ? frustumCommands.near * OpaqueFrustumNearOffset : frustumCommands.near
            frustum.far = frustumCommands.far
            
            let globeDepth = debugShowGlobeDepth ? getDebugGlobeDepth(index) : _globeDepth
            
            var fb: Framebuffer?
            if debugShowGlobeDepth && globeDepth != nil && useGlobeDepthFramebuffer {
                fb = passState.framebuffer
                passState.framebuffer = globeDepth!.framebuffer
            }
            context.uniformState.updateFrustum(frustum)
            clearDepth.execute(context, passState: passState)
        
            let globeRenderPass = context.createRenderPass(passState)
            
            for command in frustumCommands.commands[.Globe]! {
                executeCommand(command, renderPass: globeRenderPass)
            }
            
            if globeDepth != nil && useGlobeDepthFramebuffer && (copyGlobeDepth || debugShowGlobeDepth) {
                globeDepth!.update(context)
                globeDepth!.executeCopyDepth(context, passState: passState)
            }
            
            if debugShowGlobeDepth && globeDepth != nil && useGlobeDepthFramebuffer {
                passState.framebuffer = fb
            }
            
            globeRenderPass.complete()
            
            let groundRenderPass = context.createRenderPass(passState)
            
            for command in frustumCommands.commands[.Ground]! {
                executeCommand(command, renderPass: groundRenderPass)
            }
            groundRenderPass.complete()

            
            if clearGlobeDepth {
                let groundDepthRenderPass = context.createRenderPass(passState)
                
                clearDepth.execute(context, passState: passState)
                if useDepthPlane {
                    _depthPlane.execute(context, renderPass: groundDepthRenderPass)
                }
                groundDepthRenderPass.complete()
            }
            
            // Execute commands in order by pass up to the translucent pass.
            // Translucent geometry needs special handling (sorting/OIT).
            let startPass = Pass.Ground.rawValue + 1
            let endPass = Pass.Translucent.rawValue
            for pass in startPass..<endPass {
                let renderPass = context.createRenderPass(passState)
                let commands = frustumCommands.commands[Pass(rawValue: pass)!]
                for command in commands! {
                    executeCommand(command, renderPass: renderPass)
                }
                renderPass.complete()
            }
            
            if index != 0 {
                // Do not overlap frustums in the translucent pass to avoid blending artifacts
                frustum.near = frustumCommands.near
                context.uniformState.updateFrustum(frustum)
            }
            
            let commands = frustumCommands.commands[Pass.Translucent]!
            executeTranslucentCommands(scene: self, executeFunction: executeCommand, passState: passState, commands: commands)
            
            if globeDepth != nil && useGlobeDepthFramebuffer {
                // PERFORMANCE_IDEA: Use MRT to avoid the extra copy.
                //let pickDepth = getPickDepth(index)
                //pickDepth.update(context, depthTexture: globeDepth!.framebuffer!.depthStencilTexture!)
                //pickDepth.executeCopyDepth(context, passState)
            }
        }

        if debugShowGlobeDepth && useGlobeDepthFramebuffer {
            //var gd = getDebugGlobeDepth(scene, scene.debugShowDepthFrustum - 1);
            //gd.executeDebugGlobeDepth(context, passState);
        }
        
        // FIXME: debugShowPickDepth
        /*if debugShowPickDepth && useGlobeDepthFramebuffer {
            //var pd = getPickDepth(scene, scene.debugShowDepthFrustum - 1);
            //pd.executeDebugPickDepth(context, passState);
        }*/
        
        if useOIT {
            passState.framebuffer = useFXAA ? _fxaa.getColorFramebuffer() : nil
            _oit!.execute(context, passState: passState)
        }
        
        if useFXAA {
            if !useOIT && useGlobeDepthFramebuffer {
                passState.framebuffer = _fxaa.getColorFramebuffer()
                _globeDepth!.executeCopyColor(context, passState: passState)
            }
            passState.framebuffer = originalFramebuffer
            let fxaaRenderPass = context.createRenderPass(passState)
            _fxaa.execute(context, renderPass: fxaaRenderPass)
            fxaaRenderPass.complete()
        }
        
        if !useOIT && !useFXAA && useGlobeDepthFramebuffer {
            passState.framebuffer = originalFramebuffer
            _globeDepth!.executeCopyColor(context, passState: passState)
        }
    }
    
    func executeComputeCommands () {
        // each command has a different render target so needs separate pass
        for command in _computeCommandList {
            command.execute(_computeEngine)
        }

    }

    func executeOverlayCommands() {
        /*
        context.createCommandEncoder(passState: nil)
        for command in _overlayCommandList {
        command.execute(context: context, passState: passState, renderState: nil, shaderProgram: nil)*/
        //}
    }

    func updatePrimitives() {
    
        if globe != nil {
            globe.update(context: context, frameState: frameState)
        }
    /*
    _groundPrimitives.update(context, frameState, _commandList);
    _primitives.update(context, frameState, _commandList);*/
    }

/*
function callAfterRenderFunctions(frameState) {
    // Functions are queued up during primitive update and executed here in case
    // the function modifies scene state that should remain constant over the frame.
    var functions = frameState.afterRender;
    for (var i = 0, length = functions.length; i < length; ++i) {
        functions[i]();
    }
    functions.length = 0;
}
*/
    func resize(size: Cartesian2) {
        drawableWidth = Int(size.x)
        drawableHeight = Int(size.y)
    }
    /**
    * @private
    */
    func initializeFrame() {
        // FIXME - initializeframe
        // Destroy released shaders once every 120 frames to avoid thrashing the cache
/*        if (shaderFrameCount++ == 120) {
            shaderFrameCount = 0
            context.shaderCache.destroyReleasedShaderPrograms()
        }*/
        
        //tweens.update()
        camera.update(mode)
        screenSpaceCameraController.update()
    }

    
    func render(time: JulianDate = JulianDate.now()) {
        
        /*var camera = scene._camera;
        if (!cameraEqual(camera, scene._cameraClone, CesiumMath.EPSILON6)) {
        if (!scene._cameraStartFired) {
        camera.moveStart.raiseEvent();
        scene._cameraStartFired = true;
        }
        scene._cameraMovedTime = getTimestamp();
        Camera.clone(camera, scene._cameraClone);
        } else if (scene._cameraStartFired && getTimestamp() - scene._cameraMovedTime > scene.cameraEventWaitTime) {
        camera.moveEnd.raiseEvent();
        scene._cameraStartFired = false;
        }
        */
        // FIXME: Events
        //preRender.raiseEvent(self, time)

        let uniformState = context.uniformState

        let frameNumber = Math.incrementWrap(frameState.frameNumber, maximumValue: 15000000, minimumValue: 1)
        updateFrameState(frameNumber, time: time)
        frameState.passes.render = true
        // FIXME: Creditdisplay
        //frameState.creditDisplay.beginFrame();
        
        uniformState.update(context, frameState: frameState)
        _computeCommandList.removeAll()
        _commandList.removeAll()
        _overlayCommandList.removeAll()
    
        updatePrimitives()
        createPotentiallyVisibleSet()
        
        let passState = _passState
        passState.framebuffer = nil
        passState.blendingEnabled = nil
        passState.scissorTest = nil
        
        if !context.beginFrame() {
            return
        }
        
        executeComputeCommands()
        executeCommands(passState, clearColor: backgroundColor)
        executeOverlayCommands()
        
        /*frameState.creditDisplay.endFrame();
        
        if (scene.debugShowFramesPerSecond) {
            // TODO: Performance display
/*            if (!defined(scene._performanceDisplay)) {
                var performanceContainer = document.createElement('div');
                performanceContainer.style.position = 'absolute';
                performanceContainer.style.top = '50px';
                performanceContainer.style.left = '10px';
                var container = scene._canvas.parentNode;
                container.appendChild(performanceContainer);
                var performanceDisplay = new PerformanceDisplay({container: performanceContainer});
                scene._performanceDisplay = performanceDisplay;
                scene._performanceContainer = performanceContainer;
            }
            
            //scene._performanceDisplay.update();
        } else if (defined(scene._performanceDisplay)) {
            scene._performanceDisplay = scene._performanceDisplay && scene._performanceDisplay.destroy();
            scene._performanceContainer.parentNode.removeChild(scene._performanceContainer);*/
        }
        */
        
        context.endFrame()
        //callAfterRenderFunctions(frameState);
        
        // FIXME: events
        //scene._postRender.raiseEvent(scene, time)
        
}

/*
    /**
    * @private
    */
    Scene.prototype.clampLineWidth = function(width) {
    var context = this._context;
    return Math.max(context.minimumAliasedLineWidth, Math.min(width, context.maximumAliasedLineWidth));
    };

var orthoPickingFrustum = new OrthographicFrustum();
var scratchOrigin = new Cartesian3();
var scratchDirection = new Cartesian3();
var scratchBufferDimensions = new Cartesian2();
var scratchPixelSize = new Cartesian2();
var scratchPickVolumeMatrix4 = new Matrix4();

function getPickOrthographicCullingVolume(scene, drawingBufferPosition, width, height) {
    var camera = scene._camera;
    var frustum = camera.frustum;
    
    var drawingBufferWidth = scene.drawingBufferWidth;
    var drawingBufferHeight = scene.drawingBufferHeight;
    
    var x = (2.0 / drawingBufferWidth) * drawingBufferPosition.x - 1.0;
    x *= (frustum.right - frustum.left) * 0.5;
    var y = (2.0 / drawingBufferHeight) * (drawingBufferHeight - drawingBufferPosition.y) - 1.0;
    y *= (frustum.top - frustum.bottom) * 0.5;
    
    var transform = Matrix4.clone(camera.transform, scratchPickVolumeMatrix4);
    camera._setTransform(Matrix4.IDENTITY);
    
    var origin = Cartesian3.clone(camera.position, scratchOrigin);
    Cartesian3.multiplyByScalar(camera.right, x, scratchDirection);
    Cartesian3.add(scratchDirection, origin, origin);
    Cartesian3.multiplyByScalar(camera.up, y, scratchDirection);
    Cartesian3.add(scratchDirection, origin, origin);
    
    camera._setTransform(transform);
    
    Cartesian3.fromElements(origin.z, origin.x, origin.y, origin);
    
    scratchBufferDimensions.x = drawingBufferWidth;
    scratchBufferDimensions.y = drawingBufferHeight;
    
    var pixelSize = frustum.getPixelSize(scratchBufferDimensions, undefined, scratchPixelSize);
    
    var ortho = orthoPickingFrustum;
    ortho.right = pixelSize.x * 0.5;
    ortho.left = -ortho.right;
    ortho.top = pixelSize.y * 0.5;
    ortho.bottom = -ortho.top;
    ortho.near = frustum.near;
    ortho.far = frustum.far;
    
    return ortho.computeCullingVolume(origin, camera.directionWC, camera.upWC);
}

var perspPickingFrustum = new PerspectiveOffCenterFrustum();

function getPickPerspectiveCullingVolume(scene, drawingBufferPosition, width, height) {
    var camera = scene._camera;
    var frustum = camera.frustum;
    var near = frustum.near;
    
    var drawingBufferWidth = scene.drawingBufferWidth;
    var drawingBufferHeight = scene.drawingBufferHeight;
    
    var tanPhi = Math.tan(frustum.fovy * 0.5);
    var tanTheta = frustum.aspectRatio * tanPhi;
    
    var x = (2.0 / drawingBufferWidth) * drawingBufferPosition.x - 1.0;
    var y = (2.0 / drawingBufferHeight) * (drawingBufferHeight - drawingBufferPosition.y) - 1.0;
    
    var xDir = x * near * tanTheta;
    var yDir = y * near * tanPhi;
    
    scratchBufferDimensions.x = drawingBufferWidth;
    scratchBufferDimensions.y = drawingBufferHeight;
    
    var pixelSize = frustum.getPixelSize(scratchBufferDimensions, undefined, scratchPixelSize);
    var pickWidth = pixelSize.x * width * 0.5;
    var pickHeight = pixelSize.y * height * 0.5;
    
    var offCenter = perspPickingFrustum;
    offCenter.top = yDir + pickHeight;
    offCenter.bottom = yDir - pickHeight;
    offCenter.right = xDir + pickWidth;
    offCenter.left = xDir - pickWidth;
    offCenter.near = near;
    offCenter.far = frustum.far;
    
    return offCenter.computeCullingVolume(camera.positionWC, camera.directionWC, camera.upWC);
}

function getPickCullingVolume(scene, drawingBufferPosition, width, height) {
    if (scene.mode === SceneMode.SCENE2D) {
        return getPickOrthographicCullingVolume(scene, drawingBufferPosition, width, height);
    }
    
    return getPickPerspectiveCullingVolume(scene, drawingBufferPosition, width, height);
}

// pick rectangle width and height, assumed odd
var rectangleWidth = 3.0;
var rectangleHeight = 3.0;
var scratchRectangle = new BoundingRectangle(0.0, 0.0, rectangleWidth, rectangleHeight);
var scratchColorZero = new Color(0.0, 0.0, 0.0, 0.0);
var scratchPosition = new Cartesian2();

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
Scene.prototype.pick = function(windowPosition) {
    //>>includeStart('debug', pragmas.debug);
    if(!defined(windowPosition)) {
        throw new DeveloperError('windowPosition is undefined.');
    }
    //>>includeEnd('debug');
    
    var context = this._context;
    var us = context.uniformState;
    var frameState = this._frameState;
    
    var drawingBufferPosition = SceneTransforms.transformWindowToDrawingBuffer(this, windowPosition, scratchPosition);
    
    if (!defined(this._pickFramebuffer)) {
        this._pickFramebuffer = context.createPickFramebuffer();
    }
    
    // Update with previous frame's number and time, assuming that render is called before picking.
    updateFrameState(this, frameState.frameNumber, frameState.time);
    frameState.cullingVolume = getPickCullingVolume(this, drawingBufferPosition, rectangleWidth, rectangleHeight);
    frameState.passes.pick = true;
    
    us.update(context, frameState);
    
    this._commandList.length = 0;
    updatePrimitives(this);
    createPotentiallyVisibleSet(this);
    
    scratchRectangle.x = drawingBufferPosition.x - ((rectangleWidth - 1.0) * 0.5);
    scratchRectangle.y = (this.drawingBufferHeight - drawingBufferPosition.y) - ((rectangleHeight - 1.0) * 0.5);
    
    executeCommands(this, this._pickFramebuffer.begin(scratchRectangle), scratchColorZero, true);
    var object = this._pickFramebuffer.end(scratchRectangle);
    context.endFrame();
    callAfterRenderFunctions(frameState);
    return object;
};
*/
    /*var scratchPickDepthPosition = new Cartesian3();
    var scratchMinDistPos = new Cartesian3();
    var scratchPackedDepth = new Cartesian4();*/

   /**
     * Returns the cartesian position reconstructed from the depth buffer and window position.
     *
     * @param {Cartesian2} windowPosition Window coordinates to perform picking on.
     * @param {Cartesian3} [result] The object on which to restore the result.
     * @returns {Cartesian3} The cartesian position.
     *
     * @exception {DeveloperError} Picking from the depth buffer is not supported. Check pickPositionSupported.
     * @exception {DeveloperError} 2D is not supported. An orthographic projection matrix is not invertible.
     */
    func pickPosition (windowPosition: Cartesian2) -> Cartesian3? {
        
        assert(_globeDepth != nil, "Picking from the depth buffer is not supported. Check pickPositionSupported.")
        //return Cartesian3()
            
        //assertionFailure("Not implemented")
        //let uniformState = context.uniformState
        /*
        var drawingBufferPosition = SceneTransforms.transformWindowToDrawingBuffer(this, windowPosition, scratchPosition);
        drawingBufferPosition.y = this.drawingBufferHeight - drawingBufferPosition.y;
        
        var camera = this._camera;
        
        // Create a working frustum from the original camera frustum.
        var frustum;
        if (defined(camera.frustum.fov)) {
            frustum = camera.frustum.clone(scratchPerspectiveFrustum);
        } else if (defined(camera.frustum.infiniteProjectionMatrix)){
            frustum = camera.frustum.clone(scratchPerspectiveOffCenterFrustum);
        } else {
            //>>includeStart('debug', pragmas.debug);
            throw new DeveloperError('2D is not supported. An orthographic projection matrix is not invertible.');
            //>>includeEnd('debug');
        }
        var packedDepthScale = new Cartesian4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 160581375.0);
        
        var numFrustums = this.numberOfFrustums;
        for (var i = 0; i < numFrustums; ++i) {
            var pickDepth = getPickDepth(this, i);
            var pixels = context.readPixels({
                x : drawingBufferPosition.x,
                y : drawingBufferPosition.y,
                width : 1,
                height : 1,
                framebuffer : pickDepth.framebuffer
            });
            
            var packedDepth = Cartesian4.unpack(pixels, 0, scratchPackedDepth);
            Cartesian4.divideByScalar(packedDepth, 255.0, packedDepth);
            var depth = Cartesian4.dot(packedDepth, packedDepthScale);
            
            if (depth > 0.0 && depth < 1.0) {
                var renderedFrustum = this._frustumCommandsList[i];
                frustum.near = renderedFrustum.near * (i !== 0 ? OPAQUE_FRUSTUM_NEAR_OFFSET : 1.0);
                frustum.far = renderedFrustum.far;
                uniformState.updateFrustum(frustum);
                
                return SceneTransforms.drawingBufferToWgs84Coordinates(this, drawingBufferPosition, depth, result);
            }
        }
        */
        return nil
    }

    /**
    * Returns a list of objects, each containing a `primitive` property, for all primitives at
    * a particular window coordinate position. Other properties may also be set depending on the
    * type of primitive. The primitives in the list are ordered by their visual order in the
    * scene (front to back).
    *
    * @memberof Scene
    *
    * @param {Cartesian2} windowPosition Window coordinates to perform picking on.
    * @param {Number} [limit] If supplied, stop drilling after collecting this many picks.
    * @returns {Object[]} Array of objects, each containing 1 picked primitives.
    *
    * @exception {DeveloperError} windowPosition is undefined.
    *
    * @example
    * var pickedObjects = scene.drillPick(new Cesium.Cartesian2(100.0, 200.0));
    */
    func drillPick (windowPosition: Cartesian2, limit: Int) {
    assertionFailure("unimplemented")
    // PERFORMANCE_IDEA: This function calls each primitive's update for each pass. Instead
    // we could update the primitive once, and then just execute their commands for each pass,
    // and cull commands for picked primitives.  e.g., base on the command's owner.
    
    //>>includeStart('debug', pragmas.debug);
    /*if (!defined(windowPosition)) {
    throw new DeveloperError('windowPosition is undefined.');
    }
    //>>includeEnd('debug');
    
    var i;
    var attributes;
    var result = [];
    var pickedPrimitives = [];
    var pickedAttributes = [];
    if (!defined(limit)) {
    limit = Number.MAX_VALUE;
    }
    
    var pickedResult = this.pick(windowPosition);
    while (defined(pickedResult) && defined(pickedResult.primitive)) {
    result.push(pickedResult);
    if (0 >= --limit) {
    break;
    }
    var primitive = pickedResult.primitive;
    var hasShowAttribute = false;
    
    //If the picked object has a show attribute, use it.
    if (typeof primitive.getGeometryInstanceAttributes === 'function') {
    attributes = primitive.getGeometryInstanceAttributes(pickedResult.id);
    if (defined(attributes) && defined(attributes.show)) {
    hasShowAttribute = true;
    attributes.show = ShowGeometryInstanceAttribute.toValue(false, attributes.show);
    pickedAttributes.push(attributes);            }
    }
    //Otherwise, hide the entire primitive
    if (!hasShowAttribute) {
    primitive.show = false;
    pickedPrimitives.push(primitive);
    }
    pickedResult = this.pick(windowPosition);
    }
    
    // unhide everything we hid while drill picking
    for (i = 0; i < pickedPrimitives.length; ++i) {
    pickedPrimitives[i].show = true;
    }
    
    for (i = 0; i < pickedAttributes.length; ++i) {
    attributes = pickedAttributes[i];
    attributes.show = ShowGeometryInstanceAttribute.toValue(true, attributes.show);
    }
    
    return result;*/
    }

/**
* Instantly completes an active transition.
* @memberof Scene
*/
/*Scene.prototype.completeMorph = function(){
    this._transitioner.completeMorph();
};
*/
/**
* Asynchronously transitions the scene to 2D.
* @param {Number} [duration=2000] The amount of time, in milliseconds, for transition animations to complete.
* @memberof Scene
*/
// FIXME: Morph functions
func morphTo2D (duration: Double = 2000) {
    assertionFailure("unimplemented")
    /*var globe = this.globe;
    if (defined(globe)) {
        this._transitioner.morphTo2D(duration, globe.ellipsoid);
    }*/
}

/**
* Asynchronously transitions the scene to Columbus View.
* @param {Number} [duration=2000] The amount of time, in milliseconds, for transition animations to complete.
* @memberof Scene
*/
func morphToColumbusView (duration: Double = 2000) {
    /*var globe = this.globe;
    if (defined(globe)) {
        this._transitioner.morphToColumbusView(duration, globe.ellipsoid);
    }*/
}

/**
* Asynchronously transitions the scene to 3D.
* @param {Number} [duration=2000] The amount of time, in milliseconds, for transition animations to complete.
* @memberof Scene
*/
    func morphTo3D (duration: Double = 2000) {
    /*var globe = this.globe;
    if (defined(globe)) {
        duration = defaultValue(duration, 2000);
        this._transitioner.morphTo3D(duration, globe.ellipsoid);
    }*/
}
/*
/**
* Returns true if this object was destroyed; otherwise, false.
* <br /><br />
* If this object was destroyed, it should not be used; calling any function other than
* <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
*
* @memberof Scene
*
* @returns {Boolean} <code>true</code> if this object was destroyed; otherwise, <code>false</code>.
*
* @see Scene#destroy
*/
Scene.prototype.isDestroyed = function() {
    return false;
};
*/
/**
* Destroys the WebGL resources held by this object.  Destroying an object allows for deterministic
* release of WebGL resources, instead of relying on the garbage collector to destroy this object.
* <br /><br />
* Once an object is destroyed, it should not be used; calling any function other than
* <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
* assign the return value (<code>undefined</code>) to the object as done in the example.
*
* @memberof Scene
*
* @returns {undefined}
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see Scene#isDestroyed
*
* @example
* scene = scene && scene.destroy();
*/
    deinit {
        /*    this._animations.removeAll();
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
        
        this._context = this._context && this._context.destroy();
        this._frameState.creditDisplay.destroy();
        if (defined(this._performanceDisplay)){
        this._performanceDisplay = this._performanceDisplay && this._performanceDisplay.destroy();
        this._performanceContainer.parentNode.removeChild(this._performanceContainer);
        }
        
        return destroyObject(this);*/
    }

}
