//
//  Scene.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import MetalKit

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
    
    var context: Context
    
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
    * The maximum length in pixels of one edge of a cube map, supported by this WebGL implementation.  It will be at least 16.
    * @memberof Scene.prototype
    *
    * @type {Number}
    * @readonly
    *
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>GL_MAX_CUBE_MAP_TEXTURE_SIZE</code>.
    */
    var maximumCubeMapSize: Int {
        get  {
            return 0//context.maximumCubeMapSize
        }
    }

    /**
    * Gets or sets the depth-test ellipsoid.
    * @memberof Scene.prototype
    * @type {Globe}
    */
    var globe: Globe
    
    /**
    * Gets the collection of primitives.
    * @memberof Scene.prototype
    * @type {PrimitiveCollection}
    */
    var primitives = PrimitiveCollection()
    
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

    #if (iOS)
    var touchEventHandler: TouchEventHandler? = nil
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
    * Gets state information about the current scene. If called outside of a primitive's <code>update</code>
    * function, the previous frame's state is returned.
    * @memberof Scene.prototype
    * @type {FrameState}
    */
    private var _frameState: FrameState

    /**
    * Gets the collection of animations taking place in the scene.
    * @memberof Scene.prototype
    * @type {AnimationCollection}
    */
    // TODO: AnimationCollection
    //var animations = AnimationCollection()
    
    
    var shaderFrameCount = 0
    
    //this._sunPostProcess = undefined;
    
    
    private var _commandList = [DrawCommand]()
    private var _frustumCommandsList = [FrustumCommands]()
    private var _overlayCommandList = [DrawCommand]()
    
    
    /*
    // TODO: OIT and FXAA
    if (useOIT)
    this._oit = new OIT(context);
    this._executeOITFunction = undefined;
    
    this._fxaa = new FXAA();
    */
    
    var _clearColorCommand = ClearCommand(color: Cartesian4.zero()/*, owner: self*/)
    
    var _depthClearCommand = ClearCommand(depth: 1.0/*, owner: self*/)
    
    lazy var transitioner: SceneTransitioner = { return SceneTransitioner(owner: self) }()
    
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
    // TODO: SkyAtmosphere
    //var skyAtmosphere: SkyAtmosphere = nil
    
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
    var mode: SceneMode = .Scene3D
    
    /**
    * Get the map projection to use in 2D and Columbus View modes.
    * @memberof Scene.prototype
    *
    * @type {MapProjection}
    * @readonly
    *
    * @default new GeographicProjection()
    */
    private(set) var mapProjection: Projection = GeographicProjection(ellipsoid: Ellipsoid.wgs84())

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
    * Gets whether or not the scene has order independent translucency enabled.
    * Note that this only reflects the original construction option, and there are
    * other factors that could prevent OIT from functioning on a given system configuration.
    * @memberof Scene.prototype
    * @type {Boolean}
    * @readonly
    */
    var orderIndependentTranslucency: Bool {
        get {
            return false
            //return _oit != nil
        }
    }
    
    /**
    * If <code>true</code>, enables Fast Aproximate Anti-aliasing only if order independent translucency
    * is supported.
    *
    * @type Boolean
    * @default true
    */
    var fxaaOrderIndependentTranslucency = true
    
    /**
    * When <code>true</code>, enables Fast Approximate Anti-aliasing even when order independent translucency
    * is unsupported.
    *
    * @type Boolean
    * @default false
    */
    var fxaa = false
    
    //this._performanceDisplay = undefined;
    //this._debugSphere = undefined;

    
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
    var maximumAliasedLineWidth: Int { get { return 1/*context.maximumAliasedLineWidth*/ } }
    
    /**
    * Gets the collection of image layers that will be rendered on the globe.
    * @memberof Scene.prototype
    * @type {ImageryLayerCollection}
    */
    public var imageryLayers: ImageryLayerCollection { get { return globe.imageryLayers } }

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

    init (view: MTKView, globe: Globe, useOIT: Bool = true, scene3DOnly: Bool = false, projection: Projection = GeographicProjection()) {
        
        context = Context(view: view)
        self.globe = globe
        
        _frameState = FrameState(/*new CreditDisplay(creditContainer*/)
        _frameState.scene3DOnly = scene3DOnly
        
        // initial guess at frustums.
        camera = Camera(
            projection: projection,
            mode: mode,
            initialWidth: Double(view.drawableSize.width),
            initialHeight: Double(view.drawableSize.height)
        )
        #if (iOS)
        touchEventHandler = TouchEventHandler(scene: self, view: view)
        #endif
        
        // TODO: OIT and FXAA
        if useOIT {
        //this._oit = new OIT(context);
        //this._executeOITFunction = undefined;
        
        //this._fxaa = new FXAA();
        }
        camera.scene = self
        let near = camera.frustum.near
        let far = camera.frustum.far
        let numFrustums = Int(ceil(log(far / near) / log(farToNearRatio)))
        updateFrustums(near: near, far: far, farToNearRatio: farToNearRatio, numFrustums: numFrustums)
        
        // give frameState, camera, and screen space camera controller initial state before rendering
        updateFrameState(0, time: JulianDate())
        initializeFrame()
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

        _frameState.mode = mode
        _frameState.morphTime = morphTime
        _frameState.mapProjection = mapProjection
        _frameState.frameNumber = frameNumber
        _frameState.time = time
        _frameState.camera = camera
        _frameState.cullingVolume = camera.frustum.computeCullingVolume(
            position: camera.positionWC,
            direction: camera.directionWC,
            up: camera.upWC)
        _frameState.occluder = getOccluder()
        
        clearPasses(&_frameState.passes)
    }
    
    func updateFrustums(near near: Double, far: Double, farToNearRatio: Double, numFrustums: Int) {
        
        for (var m = 0; m < numFrustums; ++m) {
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
            // FIXME: Command passes
            let pass = Pass.Globe//pass: Pass = (command is ClearCommand) ? Pass.Opaque : command.pass!
            let passIndex = pass.rawValue
            let index = frustumCommands.indices[pass.rawValue]++
            frustumCommands.commands[pass.rawValue]!.append(command)
            
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
    
    var occluder: Occluder?
    if _frameState.mode == .Scene3D {
        occluder = _frameState.occluder
    }
    
    // get user culling volume minus the far plane.
    var planes = _frameState.cullingVolume!.planes[0...4]
    let cullingVolume = CullingVolume(planes: Array(planes[0..<planes.count]))
    
    
    for command in _commandList {
        // FIXME: Command.pass
        /*if command.pass == .Overlay {
            _overlayCommandList.append(command)
        } else *///{
            if let boundingVolume = command.boundingVolume {
                if command.cull &&
                   (cullingVolume.visibility(boundingVolume) == .Outside ||
                    occluder != nil && !(occluder!.isBoundingSphereVisible(boundingVolume as! BoundingSphere))) {
                            continue
                }
                
                distances = (boundingVolume as! BoundingSphere).computePlaneDistances(position, direction: direction)
                near = min(near, distances.start)
                far = max(far, distances.stop)
            } else {
                // Clear commands don't need a bounding volume - just add the clear to all frustums.
                // If another command has no bounding volume, though, we need to use the camera's
                // worst-case near and far planes to avoid clipping something important.
                distances.start = camera.frustum.near
                distances.stop = camera.frustum.far
                undefBV = !(command is ClearCommand)
            }
            
            insertIntoBin(command, distance: distances)
        //}
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
    return context.createShaderProgram(sp.vertexShaderSource, fs, attributeLocations);
}

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
            // Assumes bounding volume is a bounding sphere.
            if (defined(scene._debugSphere)) {
                scene._debugSphere.destroy();
            }
            
            var frameState = scene._frameState;
            var boundingVolume = command.boundingVolume;
            var radius = boundingVolume.radius;
            var center = boundingVolume.center;
            
            var geometry = GeometryPipeline.toWireframe(EllipsoidGeometry.createGeometry(new EllipsoidGeometry({
                radii : new Cartesian3(radius, radius, radius),
                vertexFormat : PerInstanceColorAppearance.FLAT_VERTEX_FORMAT
            })));
            
            if (frameState.mode !== SceneMode.SCENE3D) {
                center = Matrix4.multiplyByPoint(transformFrom2D, center);
                var projection = frameState.scene2D.projection;
                var centerCartographic = projection.unproject(center);
                center = projection.ellipsoid.cartographicToCartesian(centerCartographic);
            }
            
            scene._debugSphere = new Primitive({
            geometryInstances : new GeometryInstance({
            geometry : geometry,
            modelMatrix : Matrix4.multiplyByTranslation(Matrix4.IDENTITY, center),
            attributes : {
            color : new ColorGeometryInstanceAttribute(1.0, 0.0, 0.0, 1.0)
            }
            }),
            appearance : new PerInstanceColorAppearance({
            flat : true,
            translucent : false
            }),
            asynchronous : false
            });
            
            var commandList = [];
            scene._debugSphere.update(context, frameState, commandList);
            
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
                (!defined(occluder) || occluder.isBoundingSphereVisible(boundingVolume)))));
}
*/
    func translucentCompare(a: DrawCommand, b: DrawCommand, position: Cartesian3) -> Bool {
    return ((b.boundingVolume as! BoundingSphere).distanceSquaredTo(position)) > ((a.boundingVolume as! BoundingSphere).distanceSquaredTo(position))
}

    func executeTranslucentCommandsSorted(executeFunction: () -> Bool, passState: PassState, commands: [DrawCommand]) {
    // FIXME: sorting
    //mergeSort(commands, translucentCompare, scene._camera.positionWC)
    
    //var length = commands.count
    //for (var j = 0; j < length; ++j) {
    //    executeFunction(commands[j], context: context, passState: passState)
   //}
}
/*
var scratchPerspectiveFrustum = new PerspectiveFrustum();
var scratchPerspectiveOffCenterFrustum = new PerspectiveOffCenterFrustum();
var scratchOrthographicFrustum = new OrthographicFrustum();
*/
    func executeCommands(passState: PassState?, clearColor: Cartesian4, picking: Bool = false) {
        
        var j: Int
        
        var frustum: Frustum
        if camera.frustum.fovy != Double.NaN {
            frustum = camera.frustum.clone(PerspectiveFrustum())
        } else if camera.frustum.infiniteProjectionMatrix != nil {
            frustum = camera.frustum.clone(PerspectiveOffCenterFrustum())
        } else {
            frustum = camera.frustum.clone(OrthographicFrustum())
        }
        
        // FIXME: Sun
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
        
        // FIXME: Skybox, atmosphere
        /*var skyBoxCommand = (frameState.passes.render && defined(scene.skyBox)) ? scene.skyBox.update(context, frameState) : undefined;
        var skyAtmosphereCommand = (frameState.passes.render && defined(scene.skyAtmosphere)) ? scene.skyAtmosphere.update(context, frameState) : undefined;
        var sunCommand = (frameState.passes.render && defined(scene.sun)) ? scene.sun.update(scene) : undefined;
        var sunVisible = isVisible(sunCommand, frameState);*/
        

        
        
        _clearColorCommand.color = MTLClearColorMake(clearColor.red, clearColor.green, clearColor.blue, clearColor.alpha)
        let spaceRenderPass = context.createRenderPass(clearCommand: _clearColorCommand)

        /*var renderTranslucentCommands = false
        //var frustumCommandsList = scene._frustumCommandsList;
        //var numFrustums = frustumCommandsList.length;
        for frustumCommands in _frustumCommandsList {
        //for (i = 0; i < numFrustums; ++i) {
            if frustumCommands.translucentCommands.count > 0 {
            //if (frustumCommandsList[i].translucentIndex > 0) {
                renderTranslucentCommands = true
                break
            }
        }
        // FIXME: OIT
        var useOIT = !picking && renderTranslucentCommands && defined(scene._oit) && scene._oit.isSupported();
        if (useOIT) {
            scene._oit.update(context);
            scene._oit.clear(context, passState, clearColor);
            useOIT = useOIT && scene._oit.isSupported();
        }
        
        var useFXAA = !picking && (scene.fxaa || (useOIT && scene.fxaaOrderIndependentTranslucency));
        if (useFXAA) {
            scene._fxaa.update(context);
            scene._fxaa.clear(context, passState, clearColor);
        }
        */
        
        /*if (useOIT) {
            opaqueFramebuffer = scene._oit.getColorFramebuffer();
        } else if (useFXAA) {
            opaqueFramebuffer = scene._fxaa.getColorFramebuffer();
        }*/
        // FIXME: Sun
        /*if (sunVisible && scene.sunBloom) {
            passState.framebuffer = scene._sunPostProcess.update(context);
        } else {
            passState.framebuffer = opaqueFramebuffer;
        }*/
        // FIXME: skybox, atmosphere
        /*
        // Ideally, we would render the sky box and atmosphere last for
        // early-z, but we would have to draw it in each frustum
        frustum.near = camera.frustum.near
        frustum.far = camera.frustum.far
        context.uniformState.updateFrustum(frustum)
        
        if (defined(skyBoxCommand)) {
            executeCommand(skyBoxCommand, scene, context, passState);
        }
        
        if (defined(skyAtmosphereCommand)) {
            executeCommand(skyAtmosphereCommand, scene, context, passState);
        }
        
        if (defined(sunCommand) && sunVisible) {
            sunCommand.execute(context, passState);
            
            if (scene.sunBloom) {
                scene._sunPostProcess.execute(context, opaqueFramebuffer);
                passState.framebuffer = opaqueFramebuffer;
            }
        }*/
        spaceRenderPass.complete()
        
        /*
        var clearDepth = scene._depthClearCommand;
        // FIXME: Translucentcommands
        var executeTranslucentCommands;
        /*if (useOIT) {
            if (!defined(scene._executeOITFunction)) {
                scene._executeOITFunction = function(scene, executeFunction, passState, commands) {
                    scene._oit.executeCommands(scene, executeFunction, passState, commands);
                };
            }
            executeTranslucentCommands = scene._executeOITFunction;
        } else {*/
            executeTranslucentCommands = executeTranslucentCommandsSorted()
        //}*/

        // Execute commands in each frustum in back to front order
    
        let globeRenderPass = context.createRenderPass(clearCommand: _depthClearCommand)
        
        for (index, frustumCommands) in _frustumCommandsList.enumerate() {
            frustum.near = frustumCommands.near
            frustum.far = frustumCommands.far
            
            if index != 0 {
                // Avoid tearing artifacts between adjacent frustums
                frustum.near *= 0.99
            }
            
            context.uniformState.updateFrustum(frustum)


            // Execute commands in order by pass up to the translucent pass.
            // Translucent geometry needs special handling (sorting/OIT).
            let numPasses = Pass.Translucent.rawValue
            for pass in 0..<numPasses {
                for command in frustumCommands.commands[pass]! {
                    executeCommand(command, renderPass: globeRenderPass)
                }
            }
            
            frustum.near = frustumCommands.near
            context.uniformState.updateFrustum(frustum)
            // FIXME: translucentcommands
            /*commands = frustumCommands.commands[Pass.TRANSLUCENT];
            commands.length = frustumCommands.indices[Pass.TRANSLUCENT];
            executeTranslucentCommands(scene, executeCommand, passState, commands);*/
        }
        globeRenderPass.complete()
        /*
        if (useOIT) {
            passState.framebuffer = useFXAA ? scene._fxaa.getColorFramebuffer() : undefined;
            scene._oit.execute(context, passState);
        }
        
        if (useFXAA) {
            passState.framebuffer = undefined;
            scene._fxaa.execute(context, passState);
        }*/
    }

    func executeOverlayCommands() {
/*
        context.createCommandEncoder(passState: nil)
        for command in _overlayCommandList {
            command.execute(context: context, passState: passState, renderState: nil, shaderProgram: nil)*/
        //}
    }

    func updatePrimitives() {
        
        globe.update(context: context, frameState: _frameState, commandList: &_commandList)
        //FIXME: primitives
        //scene._primitives.update(context, frameState, commandList);
        //FIXME: moon
        /*
        if (defined(scene.moon)) {
            scene.moon.update(context, frameState, commandList);
        }*/
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
        if drawableWidth > 0 && drawableHeight > 0 {
        //    context.createDepthTexture()
        //    context.createStencilTexture()
        }
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

    
    func render(time: JulianDate) {
    
        // FIXME: Events
        //preRender.raiseEvent(self, time)
        
        let uniformState = context.uniformState
        
        let frameNumber = Math.incrementWrap(_frameState.frameNumber, maximumValue: 15000000, minimumValue: 1)
        updateFrameState(frameNumber, time: time)
        _frameState.passes.render = true
        // FIXME: Creditdisplay
        //frameState.creditDisplay.beginFrame();
        
        uniformState.update(context, frameState: _frameState)
        _commandList.removeAll()
        _overlayCommandList.removeAll()
    
        updatePrimitives()
        createPotentiallyVisibleSet()
        
        if !context.beginFrame() {
            return
        }
        executeCommands(nil, clearColor: backgroundColor)
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
* @returns {Object[]} Array of objects, each containing 1 picked primitives.
*
* @exception {DeveloperError} windowPosition is undefined.
*
* @example
* var pickedObjects = Cesium.Scene.drillPick(new Cesium.Cartesian2(100.0, 200.0));
*/
Scene.prototype.drillPick = function(windowPosition) {
    // PERFORMANCE_IDEA: This function calls each primitive's update for each pass. Instead
    // we could update the primitive once, and then just execute their commands for each pass,
    // and cull commands for picked primitives.  e.g., base on the command's owner.
    
    //>>includeStart('debug', pragmas.debug);
    if (!defined(windowPosition)) {
        throw new DeveloperError('windowPosition is undefined.');
    }
    //>>includeEnd('debug');
    
    var i;
    var attributes;
    var result = [];
    var pickedPrimitives = [];
    var pickedAttributes = [];
    
    var pickedResult = this.pick(windowPosition);
    while (defined(pickedResult) && defined(pickedResult.primitive)) {
    result.push(pickedResult);
        var primitive = pickedResult.primitive;
var hasShowAttribute = false;
        
    //If the picked object has a show attribute, use it.
    +            if (typeof primitive.getGeometryInstanceAttributes === 'function') {
    +                attributes = primitive.getGeometryInstanceAttributes(pickedResult.id);
            if (defined(attributes) && defined(attributes.show)) {
    +                    hasShowAttribute = true;
    +                    attributes.show = ShowGeometryInstanceAttribute.toValue(false, attributes.show);
    +                    pickedAttributes.push(attributes);            }
        }
    //Otherwise, hide the entire primitive
    +            if (!hasShowAttribute) {
    +                primitive.show = false;
    +                pickedPrimitives.push(primitive);
    +            }
        pickedResult = this.pick(windowPosition);
    }
    
    // unhide everything we hid while drill picking
    +        for (i = 0; i < pickedPrimitives.length; ++i) {
    +            pickedPrimitives[i].show = true;
    }
    
    for (i = 0; i < pickedAttributes.length; ++i) {
    +            attributes = pickedAttributes[i];
    +            attributes.show = ShowGeometryInstanceAttribute.toValue(true, attributes.show);
    +        }
    +
    +        return result;};

/**
* Instantly completes an active transition.
* @memberof Scene
*/
Scene.prototype.completeMorph = function(){
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
        this._fxaa.destroy();
        
        this._context = this._context && this._context.destroy();
        this._frameState.creditDisplay.destroy();
        if (defined(this._performanceDisplay)){
        this._performanceDisplay = this._performanceDisplay && this._performanceDisplay.destroy();
        this._performanceContainer.parentNode.removeChild(this._performanceContainer);
        }
        
        return destroyObject(this);*/
    }

}
