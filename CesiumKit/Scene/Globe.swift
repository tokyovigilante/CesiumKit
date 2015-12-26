//
//  Globe.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//
import Foundation

/**
* The globe rendered in the scene, including its terrain ({@link Globe#terrainProvider})
* and imagery layers ({@link Globe#imageryLayers}).  Access the globe using {@link Scene#globe}.
*
* @alias Globe
* @constructor
*
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] Determines the size and shape of the
* globe.
*/
class Globe {
    
    let ellipsoid: Ellipsoid
    
    var imageryLayers: ImageryLayerCollection
    
    private var _surfaceShaderSet: GlobeSurfaceShaderSet!
        
    private var _surface: QuadtreePrimitive!
    
    /**
    * The terrain provider providing surface geometry for this globe.
    * @type {TerrainProvider}
    */
    var terrainProvider: TerrainProvider
    
    private var _mode = SceneMode.Scene3D
    
    /**
    * Determines if the globe will be shown.
    *
    * @type {Boolean}
    * @default true
    */
    var show = true
    
    /**
    * The normal map to use for rendering waves in the ocean.  Setting this property will
    * only have an effect if the configured terrain provider includes a water mask.
    *
    * @type {String}
    * @default buildModuleUrl('Assets/Textures/waterNormalsSmall.jpg')
    */
    var oceanNormalMapUrl: String = /*buildModuleUrl*/("Assets/Textures/waterNormalsSmall.jpg")

    private var _oceanNormalMapUrl: String? = nil
    private var _oceanNormalMapChanged = false
    
    /**
    * The maximum screen-space error used to drive level-of-detail refinement.  Higher
    * values will provide better performance but lower visual quality.
    *
    * @type {Number}
    * @default 2
    */
    var maximumScreenSpaceError: Double = 2.0
    
    /**
    * The size of the terrain tile cache, expressed as a number of tiles.  Any additional
    * tiles beyond this number will be freed, as long as they aren't needed for rendering
    * this frame.  A larger number will consume more memory but will show detail faster
    * when, for example, zooming out and then back in.
    *
    * @type {Number}
    * @default 100
    */
    var tileCacheSize = 100
    
    /**
    * Enable lighting the globe with the sun as a light source.
    *
    * @type {Boolean}
    * @default false
    */
    var enableLighting = false
    
    /**
    * True if an animated wave effect should be shown in areas of the globe
    * covered by water; otherwise, false.  This property is ignored if the
    * <code>terrainProvider</code> does not provide a water mask.
    *
    * @type {Boolean}
    * @default true
    */
    var showWaterEffect = true
    
    /**
     * True if primitives such as billboards, polylines, labels, etc. should be depth-tested
     * against the terrain surface, or false if such primitives should always be drawn on top
     * of terrain unless they're on the opposite side of the globe.  The disadvantage of depth
     * testing primitives against terrain is that slight numerical noise or terrain level-of-detail
     * switched can sometimes make a primitive that should be on the surface disappear underneath it.
     *
     * @type {Boolean}
     * @default false
     *
     */
    var depthTestAgainstTerrain = false
    
    private var _oceanNormalMap: Texture? = nil
    
    private var _zoomedOutOceanSpecularIntensity: Float = 0.5
    
    /**
    * Gets or sets the color of the globe when no imagery is available.
    * @memberof Globe.prototype
    * @type {Color}
    */
    var baseColor: Cartesian4 {
        get {
            return _surface.tileProvider.baseColor
        }
        set (value) {
            var tileProvider = _surface.tileProvider
            tileProvider.baseColor = value
        }
    }
    
    init(ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        
        /*terrainProvider = EllipsoidTerrainProvider(
            ellipsoid : ellipsoid
        )*/
        terrainProvider = CesiumTerrainProvider(
            url: "https://assets.agi.com/stk-terrain/world",
            requestVertexNormals: true,
            requestWaterMask: true
        )
        
        self.ellipsoid = ellipsoid
        
        imageryLayers = ImageryLayerCollection()
        
    }
    
    /*func updateVertexDescriptor () -> VertexDescriptor {
        let datatype = ComponentDatatype.Float32
        let numTexCoordComponents: Int
        if terrainProvider.hasVertexNormals {
            numTexCoordComponents = 3
        } else {
            numTexCoordComponents = 2
        }
        
        let position3DAndHeightLength = 4
        
        let attributes = [
            //position3DAndHeight
            VertexAttributes(
                bufferIndex: 1,
                format: .Float4,
                offset: 0,
                size: position3DAndHeightLength * datatype.elementSize),
            // texCoordAndEncodedNormals
            VertexAttributes(
                bufferIndex: 1,
                format: terrainProvider.hasVertexNormals ? .Float3 : .Float2,
                offset: position3DAndHeightLength * datatype.elementSize,
                size: numTexCoordComponents * datatype.elementSize)
        ]
        
        return VertexDescriptor(attributes: attributes)
    }*/

    
    func createComparePickTileFunction(rayOrigin: Cartesian3) -> ((GlobeSurfaceTile, GlobeSurfaceTile) -> Bool) {
        func comparePickTileFunction(a: GlobeSurfaceTile, b: GlobeSurfaceTile) -> Bool {
            let aDist = a.pickBoundingSphere.distanceSquaredTo(rayOrigin)
            let bDist = b.pickBoundingSphere.distanceSquaredTo(rayOrigin)
            return aDist < bDist
        }
        return comparePickTileFunction
    }
    
    /**
    * Find an intersection between a ray and the globe surface that was rendered. The ray must be given in world coordinates.
    *
    * @param {Ray} ray The ray to test for intersection.
    * @param {Scene} scene The scene.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3|undefined} The intersection or <code>undefined</code> if none was found.
    *
    * @example
    * // find intersection of ray through a pixel and the globe
    * var ray = viewer.camera.getPickRay(windowCoordinates);
    * var intersection = globe.pick(ray, scene);
    */
    func pick(ray: Ray, scene: Scene) -> Cartesian3? {
        let mode = scene.mode
        //let projection = scene.mapProjection
        
        var sphereIntersections = [GlobeSurfaceTile]()
        
        let tilesToRender = _surface.tilesToRender
        
        for tile in tilesToRender {
            
            if tile.data == nil {
                continue
            }
            let tileData = tile.data!
            
            var boundingVolume = tileData.pickBoundingSphere
            if mode != .Scene3D {
                assertionFailure("unimplemented")
                /*BoundingSphere.fromRectangleWithHeights2D(tile.rectangle, projection, tileData.minimumHeight, tileData.maximumHeight, boundingVolume);
                Cartesian3.fromElements(boundingVolume.center.z, boundingVolume.center.x, boundingVolume.center.y, boundingVolume.center);*/
            } else {
                boundingVolume = tileData.boundingSphere3D
            }
            
            if IntersectionTests.raySphere(ray, sphere: boundingVolume) != nil {
                sphereIntersections.append(tileData)
            }
        }
        
        sphereIntersections.sortInPlace(createComparePickTileFunction(ray.origin))
        
        for sphereIntersection in sphereIntersections {
            if let intersection = sphereIntersection.pick(ray, mode: scene.mode, projection: scene.mapProjection, cullBackFaces: true) {
                return intersection
            }
        }
        
        return nil
    }
    
    /**
    * Get the height of the surface at a given cartographic.
    *
    * @param {Cartographic} cartographic The cartographic for which to find the height.
    * @returns {Number|undefined} The height of the cartographic or undefined if it could not be found.
    */
    func getHeight(cartographic: Cartographic) -> Double? {
        //FIXME: Unimplemented
        /*
        var scratchGetHeightCartesian = new Cartesian3();
        var scratchGetHeightIntersection = new Cartesian3();
        var scratchGetHeightCartographic = new Cartographic();
        var scratchGetHeightRay = new Ray();
        //>>includeStart('debug', pragmas.debug);
        if (!defined(cartographic)) {
        throw new DeveloperError('cartographic is required');
        }
        //>>includeEnd('debug');
        
        var levelZeroTiles = this._surface._levelZeroTiles;
        if (!defined(levelZeroTiles)) {
        return;
        }
        
        var tile;
        var i;
        
        var length = levelZeroTiles.length;
        for (i = 0; i < length; ++i) {
        tile = levelZeroTiles[i];
        if (Rectangle.contains(tile.rectangle, cartographic)) {
        break;
        }
        }
        
        if (!defined(tile) || !Rectangle.contains(tile.rectangle, cartographic)) {
        return undefined;
        }
        
        while (tile.renderable) {
        var children = tile.children;
        length = children.length;
        
        for (i = 0; i < length; ++i) {
        tile = children[i];
        if (Rectangle.contains(tile.rectangle, cartographic)) {
        break;
        }
        }
        }
        
        while (defined(tile) && (!defined(tile.data) || !defined(tile.data.pickTerrain))) {
        tile = tile.parent;
        }
        
        if (!defined(tile)) {
        return undefined;
        }
        
        var ellipsoid = this._surface._tileProvider.tilingScheme.ellipsoid;
        var cartesian = ellipsoid.cartographicToCartesian(cartographic, scratchGetHeightCartesian);
        
        var ray = scratchGetHeightRay;
        Cartesian3.normalize(cartesian, ray.direction);
        
        var intersection = tile.data.pick(ray, undefined, undefined, false, scratchGetHeightIntersection);
        if (!defined(intersection)) {
        return undefined;
        }
        
        return ellipsoid.cartesianToCartographic(intersection, scratchGetHeightCartographic).height;*/return 0.0
    }
    
    
/**
* @private
*/
    func update(context context: Context, inout frameState: FrameState) {
        if !show {
            return
        }
        
        if !terrainProvider.ready {
            return
        }
        
        if _surface == nil {
            let vertexDescriptor = VertexDescriptor(attributes: terrainProvider.vertexAttributes)
            
            _surfaceShaderSet = GlobeSurfaceShaderSet(
                baseVertexShaderSource: ShaderSource(sources: [Shaders["GlobeVS"]!]),
                                        baseFragmentShaderSource: ShaderSource(sources: [Shaders["GlobeFS"]!]),
                                                                  vertexDescriptor: vertexDescriptor)
            
            _surface = QuadtreePrimitive(
                tileProvider: GlobeSurfaceTileProvider(
                    terrainProvider: terrainProvider,
                    imageryLayers: imageryLayers,
                    surfaceShaderSet: _surfaceShaderSet
                )
            )
        }
        
        let width = context.width
        let height = context.height
        
        if (width == 0 || height == 0) {
            return
        }
        
        let hasWaterMask = showWaterEffect && terrainProvider.ready && _surface.tileProvider.terrainProvider.hasWaterMask
        
        if (hasWaterMask && oceanNormalMapUrl != _oceanNormalMapUrl) {
                
            /*              // url changed, load new normal map asynchronously
            +            var oceanNormalMapUrl = this.oceanNormalMapUrl;
            +            this._oceanNormalMapUrl = oceanNormalMapUrl;
            +
            +            if (defined(oceanNormalMapUrl)) {
            +                var that = this;
            +                when(loadImage(oceanNormalMapUrl), function(image) {
            +                    if (oceanNormalMapUrl !== that.oceanNormalMapUrl) {
            +                        // url changed while we were loading
            +                        return;
            +                    }
            
            +                    that._oceanNormalMap = that._oceanNormalMap && that._oceanNormalMap.destroy();
            +                    that._oceanNormalMap = context.createTexture2D({
            +                        source : image
            +                    });
            +                });
            } else {
            +                this._oceanNormalMap = this._oceanNormalMap && this._oceanNormalMap.destroy();
            }
            +        }*/
        }
        
        let mode = frameState.mode
        if (frameState.passes.render) {
            
            // Don't show the ocean specular highlights when zoomed out in 2D and Columbus View.
            if mode == .Scene3D {
                _zoomedOutOceanSpecularIntensity = 0.5
            } else {
                _zoomedOutOceanSpecularIntensity = 0.0
            }
            
            _surface.maximumScreenSpaceError = maximumScreenSpaceError
            _surface.tileCacheSize = tileCacheSize
            
            var tileProvider = _surface.tileProvider
            tileProvider.terrainProvider = terrainProvider
            tileProvider.zoomedOutOceanSpecularIntensity = _zoomedOutOceanSpecularIntensity
            tileProvider.hasWaterMask = hasWaterMask
            tileProvider.oceanNormalMap = _oceanNormalMap
            tileProvider.enableLighting = enableLighting
            
            _surface.update(context: context, frameState: &frameState)
        }
        
        if (frameState.passes.pick && mode == .Scene3D) {
            // Not actually pickable, but render depth-only so primitives on the backface
            // of the globe are not picked.
            _surface.update(context: context, frameState: &frameState)
        }
    }

/**
* Destroys the WebGL resources held by this object.  Destroying an object allows for deterministic
* release of WebGL resources, instead of relying on the garbage collector to destroy this object.
* <br /><br />
* Once an object is destroyed, it should not be used; calling any function other than
* <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
* assign the return value (<code>undefined</code>) to the object as done in the example.
*
* @returns {undefined}
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see Globe#isDestroyed
*
* @example
* globe = globe && globe.destroy();
*/
    deinit {
        /*this._northPoleCommand.vertexArray = this._northPoleCommand.vertexArray && this._northPoleCommand.vertexArray.destroy();
        this._southPoleCommand.vertexArray = this._southPoleCommand.vertexArray && this._southPoleCommand.vertexArray.destroy();
        
        this._surfaceShaderSet = this._surfaceShaderSet && this._surfaceShaderSet.destroy();
        
        this._northPoleCommand.shaderProgram = this._northPoleCommand.shaderProgram && this._northPoleCommand.shaderProgram.destroy();
        this._southPoleCommand.shaderProgram = this._northPoleCommand.shaderProgram;
        
        this._depthCommand.shaderProgram = this._depthCommand.shaderProgram && this._depthCommand.shaderProgram.destroy();
        this._depthCommand.vertexArray = this._depthCommand.vertexArray && this._depthCommand.vertexArray.destroy();
        
        this._surface = this._surface && this._surface.destroy();
        
        this._oceanNormalMap = this._oceanNormalMap && this._oceanNormalMap.destroy();
        
        return destroyObject(this);*/
    }
}

