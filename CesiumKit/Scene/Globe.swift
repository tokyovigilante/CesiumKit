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
    
    private var _surfaceShaderSet: GlobeSurfaceShaderSet
    
    private var _surface: QuadtreePrimitive
    
    private var _occluder: Occluder
    
    var _rsColor: RenderState? = nil
    var _rsColorWithoutDepthTest: RenderState? = nil
    
    var _clearDepthCommand: ClearCommand
    
    var _depthCommand: DrawCommand
    
    var _northPoleCommand: DrawCommand
    
    var _southPoleCommand: DrawCommand
    
    var drawNorthPole = false
    var drawSouthPole = false
    
    private var _mode = SceneMode.Scene3D

    /**
    * The terrain provider providing surface geometry for this globe.
    * @type {TerrainProvider}
    */
    var terrainProvider: TerrainProvider
    
    /**
    * Determines the color of the north pole. If the day tile provider imagery does not
    * extend over the north pole, it will be filled with this color before applying lighting.
    *
    * @type {Cartesian3}
    * @default Cartesian3(2.0 / 255.0, 6.0 / 255.0, 18.0 / 255.0)
    */
    var northPoleColor = Cartesian4(x: 2.0 / 255.0, y: 6.0 / 255.0, z: 18.0 / 255.0, w: 1.0)
    
    /**
    * Determines the color of the south pole. If the day tile provider imagery does not
    * extend over the south pole, it will be filled with this color before applying lighting.
    *
    * @type {Cartesian3}
    * @default Cartesian3(1.0, 1.0, 1.0)
    */
    var southPoleColor = Cartesian4(x: 1.0, y: 1.0, z: 1.0, w: 1.0)
    
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
    
    private var _oceanNormalMapUrl: String = ""
    private var _oceanNormalMapChanged = false
    
    /**
    * True if primitives such as billboards, polylines, labels, etc. should be depth-tested
    * against the terrain surface, or false if such primitives should always be drawn on top
    * of terrain unless they're on the opposite side of the globe.  The disadvantage of depth
    * testing primitives against terrain is that slight numerical noise or terrain level-of-detail
    * switched can sometimes make a primitive that should be on the surface disappear underneath it.
    *
    * @type {Boolean}
    * @default false
    */
    var depthTestAgainstTerrain = false
    
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
    
    private var _enableLighting = false
    
    /**
    * The distance where everything becomes lit. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 6500000.0
    */
    var _lightingFadeOutDistance = 6500000.0
    
    /**
    * The distance where lighting resumes. This only takes effect
    * when <code>enableLighting</code> is <code>true</code>.
    *
    * @type {Number}
    * @default 9000000.0
    */
    var _lightingFadeInDistance = 9000000.0
    
    /**
    * True if an animated wave effect should be shown in areas of the globe
    * covered by water; otherwise, false.  This property is ignored if the
    * <code>terrainProvider</code> does not provide a water mask.
    *
    * @type {Boolean}
    * @default true
    */
    var showWaterEffect = true
    
    var _oceanNormalMap: Texture? = nil
    
    var _zoomedOutOceanSpecularIntensity = 0.5
    
    private var _hasWaterMask = false
    
    private var _hasVertexNormals = false

    private var _lightingFadeDistance: Cartesian2
    
    lazy var drawUniforms: Dictionary<String, ()->Any> = {
        
        weak var weakSelf = self
        return [
            /*"u_zoomedOutOceanSpecularIntensity": { return weakSelf._zoomedOutOceanSpecularIntensity },*/
            "u_oceanNormalMap" : { return weakSelf!._oceanNormalMap },
            "u_lightingFadeDistance" :  { return weakSelf!._lightingFadeDistance }
        ]
        }()
    
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
            //_surface.tileProvider.baseColor = value
        }
    }
    
    init(ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
    
        self.ellipsoid = ellipsoid
        terrainProvider = EllipsoidTerrainProvider(ellipsoid : ellipsoid)
        imageryLayers = ImageryLayerCollection()
        
        _occluder = Occluder(occluderBoundingSphere: BoundingSphere(center: Cartesian3.zero(), radius: ellipsoid.minimumRadius), cameraPosition: Cartesian3.zero())
        
        _surfaceShaderSet = GlobeSurfaceShaderSet(attributeLocations: ["position3DAndHeight": 0, "textureCoordinates": 1])
        
        _surface = QuadtreePrimitive(
            tileProvider: GlobeSurfaceTileProvider(
                terrainProvider: terrainProvider,
                imageryLayers: imageryLayers,
                surfaceShaderSet: _surfaceShaderSet
            )
        )
        _lightingFadeDistance = Cartesian2(x: _lightingFadeOutDistance, y: _lightingFadeInDistance)
        
        _clearDepthCommand = ClearCommand(depth: 1.0, stencil: 0/*, owner: self*/)
        _depthCommand = DrawCommand(
            boundingVolume: BoundingSphere(center: Cartesian3.zero(), radius: Ellipsoid.wgs84().maximumRadius),
            pass: Pass.Opaque//,
            /*owner: self*/)
        _northPoleCommand = DrawCommand(pass: Pass.Opaque/*, owner: self*/)
        _southPoleCommand = DrawCommand(pass: Pass.Opaque/*, owner: self*/)
    }
    
    func createComparePickTileFunction(rayOrigin: Cartesian3) -> ((GlobeSurfaceTile, GlobeSurfaceTile) -> Double) {
        func comparePickTileFunction(a: GlobeSurfaceTile, b: GlobeSurfaceTile) -> Double {
            var aDist = a.pickBoundingSphere.distanceSquaredTo(rayOrigin)
            var bDist = b.pickBoundingSphere.distanceSquaredTo(rayOrigin)
            return aDist - bDist
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
    * var ray = scene.camera.getPickRay(windowCoordinates);
    * var intersection = globe.pick(ray, scene);
    */
    func pick(ray: Ray, scene: Scene) -> Cartesian3? {
        //FIXME: Unimplemented
        /*
        var scratchArray = [];
        var scratchSphereIntersectionResult = Interval)
        start : 0.0,
        stop : 0.0
        )
        //>>includeStart('debug', pragmas.debug);
        if (!defined(ray)) {
        throw new DeveloperError('ray is required');
        }
        if (!defined(scene)) {
        throw new DeveloperError('scene is required');
        }
        //>>includeEnd('debug');
        
        var mode = scene.mode;
        var projection = scene.mapProjection;
        
        var sphereIntersections = scratchArray;
        sphereIntersections.length = 0;
        
        var tilesToRender = this._surface._tilesToRender;
        var length = tilesToRender.length;
        
        var tile;
        var i;
        
        for (i = 0; i < length; ++i) {
        tile = tilesToRender[i];
        var tileData = tile.data;
        
        if (!defined(tileData)) {
        continue;
        }
        
        var boundingVolume = tileData.pickBoundingSphere;
        if (mode !== SceneMode.SCENE3D) {
        BoundingSphere.fromRectangleWithHeights2D(tile.rectangle, projection, tileData.minimumHeight, tileData.maximumHeight, boundingVolume);
        Cartesian3.fromElements(boundingVolume.center.z, boundingVolume.center.x, boundingVolume.center.y, boundingVolume.center);
        } else {
        BoundingSphere.clone(tileData.boundingSphere3D, boundingVolume);
        }
        
        var boundingSphereIntersection = IntersectionTests.raySphere(ray, boundingVolume, scratchSphereIntersectionResult);
        if (defined(boundingSphereIntersection)) {
        sphereIntersections.push(tileData);
        }
        }
        
        sphereIntersections.sort(createComparePickTileFunction(ray.origin));
        
        var intersection;
        length = sphereIntersections.length;
        for (i = 0; i < length; ++i) {
        intersection = sphereIntersections[i].pick(ray, scene, true, result);
        if (defined(intersection)) {
        break;
        }
        }
        
        return intersection;*/ return Cartesian3()
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
        
        var intersection = tile.data.pick(ray, undefined, false, scratchGetHeightIntersection);
        if (!defined(intersection)) {
        return undefined;
        }
        
        return ellipsoid.cartesianToCartographic(intersection, scratchGetHeightCartographic).height;*/return 0.0
    }

    func computeDepthQuad(#frameState: FrameState) -> [Float] {
        
        var depthQuad = [Float](count: 12, repeatedValue: 0.0)//(count: 12, repeatedValue: 0.0)
        
        var radii = ellipsoid.radii
        
        // Find the corresponding position in the scaled space of the ellipsoid.
        var q = ellipsoid.oneOverRadii.multiplyComponents(frameState.camera!.positionWC)
        
        var qMagnitude = q.magnitude()
        var qUnit = q.normalize()
        
        // Determine the east and north directions at q.
        var eUnit = q.cross(Cartesian3.unitZ()).normalize()
        var nUnit = qUnit.cross(eUnit).normalize()
        
        // Determine the radius of the 'limb' of the ellipsoid.
        var wMagnitude = sqrt(q.magnitudeSquared() - 1.0)
        
        // Compute the center and offsets.
        var center = qUnit.multiplyByScalar(qMagnitude)
        var scalar = wMagnitude / qMagnitude;
        var eastOffset = eUnit.multiplyByScalar(scalar)
        var northOffset = nUnit.multiplyByScalar(scalar)
        
        // A conservative measure for the longitudes would be to use the min/max longitudes of the bounding frustum.
        var upperLeft = center.add(northOffset).subtract(eastOffset).multiplyComponents(radii)
        var lowerLeft = center.subtract(northOffset).subtract(eastOffset).multiplyComponents(radii)
        var upperRight = center.add(northOffset).add(eastOffset).multiplyComponents(radii)
        var lowerRight = center.subtract(northOffset).add(eastOffset).multiplyComponents(radii)
        
        upperLeft.pack(&depthQuad, startingIndex: 0)
        lowerLeft.pack(&depthQuad, startingIndex: 3)
        upperRight.pack(&depthQuad, startingIndex: 6)
        lowerRight.pack(&depthQuad, startingIndex: 9)
        
        return depthQuad
    }
    
    func computePoleQuad(#frameState: FrameState, maxLat: Double, maxGivenLat: Double, viewProjMatrix: Matrix4, viewportTransformation: Matrix4) -> BoundingRectangle {
        //FIXME: PoleQuad
        /*
        let negativeZ = Cartesian3.unitZ().negate()
        
        var pt1 = ellipsoid.cartographicToCartesian(Cartographic(0.0, maxGivenLat))
        var pt2 = ellipsoid.cartographicToCartesian(Cartographic(M_PI, maxGivenLat))
        var radius = pt1.subtract(pt2).magnitude() * 0.5
        
        var center = ellipsoid.cartographicToCartesian(Cartographic(0.0, maxLat));
        
        var right: Cartesian3
        var dir = frameState.camera.direction
        if (1.0 - negativeZ.dot(dir) < Math.Epsilon6) {
            right = Cartesian3.unitX()
        } else {
            right = dir.cross(Cartesian3.unitX()).normalize()
        }
        
        var screenRight = center.add(right.multiplyByScalar(radius))
        var screenUp = center.add(Cartesian3.unitZ().cross(right).normalize().multiplyByScalar(radius))
        
        Transforms.pointToWindowCoordinates(viewProjMatrix, viewportTransformation, center, center)
        Transforms.pointToWindowCoordinates(viewProjMatrix, viewportTransformation, screenRight, screenRight)
        Transforms.pointToWindowCoordinates(viewProjMatrix, viewportTransformation, screenUp, screenUp)
        
        var halfWidth = floor(max(screenUp.distance(center), screenRight.distance(center)))
        var halfHeight = halfWidth
        */
        return BoundingRectangle()
            /*floor(center.x) - halfWidth,
            floor(center.y) - halfHeight,
            halfWidth * 2.0,
            halfHeight * 2.0)*/
 
    }
    
    func fillPoles(#context: Context, frameState: FrameState) {
        //FIXME: Fillpoles
        /*var terrainProvider = globe.terrainProvider;
        if (frameState.mode !== SceneMode.SCENE3D) {
        return;
        }
        
        if (!terrainProvider.ready) {
        return;
        }
        
        var terrainMaxRectangle = terrainProvider.tilingScheme.rectangle;
        
        var viewProjMatrix = context.uniformState.viewProjection;
        var viewport = viewportScratch;
        viewport.width = context.drawingBufferWidth;
        viewport.height = context.drawingBufferHeight;
        var viewportTransformation = Matrix4.computeViewportTransformation(viewport, 0.0, 1.0, vpTransformScratch);
        var latitudeExtension = 0.05;
        
        var rectangle;
        var boundingVolume;
        var frustumCull;
        var occludeePoint;
        var occluded;
        var geometry;
        var rect;
        var occluder = globe._occluder;
        
        // handle north pole
        if (terrainMaxRectangle.north < CesiumMath.PI_OVER_TWO) {
        rectangle = new Rectangle(-Math.PI, terrainMaxRectangle.north, Math.PI, CesiumMath.PI_OVER_TWO);
        boundingVolume = BoundingSphere.fromRectangle3D(rectangle, globe._ellipsoid);
        frustumCull = frameState.cullingVolume.computeVisibility(boundingVolume) === Intersect.OUTSIDE;
        occludeePoint = Occluder.computeOccludeePointFromRectangle(rectangle, globe._ellipsoid);
        occluded = (occludeePoint && !occluder.isPointVisible(occludeePoint, 0.0)) || !occluder.isBoundingSphereVisible(boundingVolume);
        
        globe._drawNorthPole = !frustumCull && !occluded;
        if (globe._drawNorthPole) {
        rect = computePoleQuad(globe, frameState, rectangle.north, rectangle.south - latitudeExtension, viewProjMatrix, viewportTransformation);
        polePositionsScratch[0] = rect.x;
        polePositionsScratch[1] = rect.y;
        polePositionsScratch[2] = rect.x + rect.width;
        polePositionsScratch[3] = rect.y;
        polePositionsScratch[4] = rect.x + rect.width;
        polePositionsScratch[5] = rect.y + rect.height;
        polePositionsScratch[6] = rect.x;
        polePositionsScratch[7] = rect.y + rect.height;
        
        if (!defined(globe._northPoleCommand.vertexArray)) {
        globe._northPoleCommand.boundingVolume = BoundingSphere.fromRectangle3D(rectangle, globe._ellipsoid);
        geometry = new Geometry({
        attributes : {
        position : new GeometryAttribute({
        componentDatatype : ComponentDatatype.FLOAT,
        componentsPerAttribute : 2,
        values : polePositionsScratch
        })
        }
        });
        globe._northPoleCommand.vertexArray = context.createVertexArrayFromGeometry({
        geometry : geometry,
        attributeLocations : {
        position : 0
        },
        bufferUsage : BufferUsage.STREAM_DRAW
        });
        } else {
        globe._northPoleCommand.vertexArray.getAttribute(0).vertexBuffer.copyFromArrayView(polePositionsScratch);
        }
        }
        }
        
        // handle south pole
        if (terrainMaxRectangle.south > -CesiumMath.PI_OVER_TWO) {
        rectangle = new Rectangle(-Math.PI, -CesiumMath.PI_OVER_TWO, Math.PI, terrainMaxRectangle.south);
        boundingVolume = BoundingSphere.fromRectangle3D(rectangle, globe._ellipsoid);
        frustumCull = frameState.cullingVolume.computeVisibility(boundingVolume) === Intersect.OUTSIDE;
        occludeePoint = Occluder.computeOccludeePointFromRectangle(rectangle, globe._ellipsoid);
        occluded = (occludeePoint && !occluder.isPointVisible(occludeePoint)) || !occluder.isBoundingSphereVisible(boundingVolume);
        
        globe._drawSouthPole = !frustumCull && !occluded;
        if (globe._drawSouthPole) {
        rect = computePoleQuad(globe, frameState, rectangle.south, rectangle.north + latitudeExtension, viewProjMatrix, viewportTransformation);
        polePositionsScratch[0] = rect.x;
        polePositionsScratch[1] = rect.y;
        polePositionsScratch[2] = rect.x + rect.width;
        polePositionsScratch[3] = rect.y;
        polePositionsScratch[4] = rect.x + rect.width;
        polePositionsScratch[5] = rect.y + rect.height;
        polePositionsScratch[6] = rect.x;
        polePositionsScratch[7] = rect.y + rect.height;
        
        if (!defined(globe._southPoleCommand.vertexArray)) {
        globe._southPoleCommand.boundingVolume = BoundingSphere.fromRectangle3D(rectangle, globe._ellipsoid);
        geometry = new Geometry({
        attributes : {
        position : new GeometryAttribute({
        componentDatatype : ComponentDatatype.FLOAT,
        componentsPerAttribute : 2,
        values : polePositionsScratch
        })
        }
        });
        globe._southPoleCommand.vertexArray = context.createVertexArrayFromGeometry({
        geometry : geometry,
        attributeLocations : {
        position : 0
        },
        bufferUsage : BufferUsage.STREAM_DRAW
        });
        } else {
        globe._southPoleCommand.vertexArray.getAttribute(0).vertexBuffer.copyFromArrayView(polePositionsScratch);
        }
        }
        }
        
        var poleIntensity = 0.0;
        var baseLayer = globe._imageryLayerCollection.length > 0 ? globe._imageryLayerCollection.get(0) : undefined;
        if (defined(baseLayer) && defined(baseLayer.imageryProvider) && defined(baseLayer.imageryProvider.getPoleIntensity)) {
        poleIntensity = baseLayer.imageryProvider.getPoleIntensity();
        }
        
        var drawUniforms = {
        u_dayIntensity : function() {
        return poleIntensity;
        }
        };
        
        if (!defined(globe._northPoleCommand.uniformMap)) {
        var northPoleUniforms = combine(drawUniforms, {
        u_color : function() {
        return globe.northPoleColor;
        }
        });
        globe._northPoleCommand.uniformMap = combine(northPoleUniforms, globe._drawUniforms);
        }
        
        if (!defined(globe._southPoleCommand.uniformMap)) {
        var southPoleUniforms = combine(drawUniforms, {
        u_color : function() {
        return globe.southPoleColor;
        }
        });
        globe._southPoleCommand.uniformMap = combine(southPoleUniforms, globe._drawUniforms);
        }*/
    }

/**
* @private
*/
    func update(#context: Context, frameState: FrameState, inout commandList: [Command]) {
        if !show {
            return
        }

        var width = context.drawingBufferWidth
        var height = context.drawingBufferHeight
        
        if (width == 0 || height == 0) {
            return
        }
        
        var mode = frameState.mode
        var projection = frameState.mapProjection
        var modeChanged = false
        
        if _mode != mode || _rsColor == nil {
            modeChanged = true
            
            _rsColor = context.createRenderState() // Write color and depth
            _rsColor?.cull.enabled = true
            _rsColor?.depthTest.enabled = true
            
            _rsColorWithoutDepthTest = context.createRenderState()
            _rsColorWithoutDepthTest?.cull.enabled = true
            _depthCommand.renderState = context.createRenderState()
            _depthCommand.renderState?.cull.enabled = true
            
            if (mode == SceneMode.Scene3D || mode == SceneMode.ColumbusView) {
                _depthCommand.renderState?.depthTest.enabled = true
                _depthCommand.renderState?.depthTest.function = .Less
                _depthCommand.renderState?.colorMask = RenderState.ColorMask(red: false, green: false, blue: false, alpha: false)
            }
        }
        
        _northPoleCommand.renderState = _rsColorWithoutDepthTest
        _southPoleCommand.renderState = _rsColorWithoutDepthTest
        
        // update depth plane
        var depthQuad = computeDepthQuad(frameState: frameState)
        var depthIndices = [0, 1, 2, 2, 1, 3]
        
        // depth plane
        if _depthCommand.vertexArray == nil {
            var geometry = Geometry(
                    attributes: GeometryAttributes(
                        position: GeometryAttribute(
                            componentDatatype: ComponentDatatype.Float32,
                            componentsPerAttribute: 3,
                            values: SerializedArray(data: NSData.serializeArray(depthQuad), type: .Float32))
                        ),
                    indices : depthIndices,
                    primitiveType : PrimitiveType.Triangles
            )
            _depthCommand.vertexArray = context.createVertexArrayFromGeometry(
                geometry,
                attributeLocations: ["position": 0],
                bufferUsage: .DynamicDraw)
        } else {
            _depthCommand.vertexArray?.attribute(0).vertexBuffer?.copyFromArrayView(SerializedArray(data: NSData.serializeArray(depthQuad), type: .Float32))
        }
        
        if _depthCommand.shaderProgram == nil {
             _depthCommand.shaderProgram = context.createShaderProgram(vertexShaderSource: Shaders["GlobeVSDepth"]!, fragmentShaderSource: Shaders["GlobeFSDepth"]!, attributeLocations: ["position" : 0])
        }
        
        var hasWaterMask = showWaterEffect && _surface.tileProvider.ready && _surface.tileProvider.terrainProvider.hasWaterMask
        var hasWaterMaskChanged = _hasWaterMask != hasWaterMask
        var hasVertexNormals = _surface.tileProvider.ready && _surface.tileProvider.terrainProvider.hasVertexNormals
        var hasVertexNormalsChanged = _hasVertexNormals != hasVertexNormals
        var hasEnableLightingChanged = _enableLighting != enableLighting
        

        if (hasWaterMask && oceanNormalMapUrl != _oceanNormalMapUrl) {
                
/*                // url changed, load new normal map asynchronously
                var oceanNormalMapUrl = this.oceanNormalMapUrl;
                this._oceanNormalMapUrl = oceanNormalMapUrl;
                
                var that = this;
                when(loadImage(oceanNormalMapUrl), function(image) {
                    if (oceanNormalMapUrl !== that.oceanNormalMapUrl) {
                        // url changed while we were loading
                        return;
                    }
                    
                    that._oceanNormalMap = that._oceanNormalMap && that._oceanNormalMap.destroy();
                    that._oceanNormalMap = context.createTexture2D({
                        source : image
                    });
                    that._oceanNormalMapChanged = true;
                    });*/
        }
        // Initial compile or re-compile if uber-shader parameters changed
        
        if _northPoleCommand.shaderProgram == nil ||
            _southPoleCommand.shaderProgram == nil ||
            _oceanNormalMapChanged ||
            _hasWaterMask != hasWaterMask ||
            _hasVertexNormals != hasVertexNormals ||
            _enableLighting != enableLighting  {
                
                let getPosition3DMode = "vec4 getPosition(vec3 position3DWC) { return getPosition3DMode(position3DWC); }"
                let getPosition2DMode = "vec4 getPosition(vec3 position3DWC) { return getPosition2DMode(position3DWC); }"
                let getPositionColumbusViewMode = "vec4 getPosition(vec3 position3DWC) { return getPositionColumbusViewMode(position3DWC); }"
                let getPositionMorphingMode = "vec4 getPosition(vec3 position3DWC) { return getPositionMorphingMode(position3DWC); }"
                
                var getPositionMode: String
                
                switch mode {
                case .Scene3D:
                    getPositionMode = getPosition3DMode
                case .Scene2D:
                    getPositionMode = getPosition2DMode
                case .ColumbusView:
                    getPositionMode = getPositionColumbusViewMode
                case .Morphing:
                    getPositionMode = getPositionMorphingMode
                }
                
                var get2DYPositionFractionGeographicProjection = "float get2DYPositionFraction() { return get2DGeographicYPositionFraction(); }"
                var get2DYPositionFractionMercatorProjection = "float get2DYPositionFraction() { return get2DMercatorYPositionFraction(); }"
                
                var get2DYPositionFraction: String
                
                if (projection is GeographicProjection) {
                    get2DYPositionFraction = get2DYPositionFractionGeographicProjection
                } else {
                    get2DYPositionFraction = get2DYPositionFractionMercatorProjection
                }
                
                var shaderDefines = [String]()
                
                if (hasWaterMask) {
                    shaderDefines.append("SHOW_REFLECTIVE_OCEAN")
                    
                    if _oceanNormalMap != nil {
                        shaderDefines.append("SHOW_OCEAN_WAVES")
                    }
                }
                
                if (enableLighting) {
                    if (hasVertexNormals) {
                        shaderDefines.append("ENABLE_VERTEX_LIGHTING")
                    } else {
                        shaderDefines.append("ENABLE_DAYNIGHT_SHADING")
                    }
                }
                
                _surfaceShaderSet.baseVertexShaderString = ShaderProgram.createShaderSource(
                    defines : shaderDefines,
                    sources: [Shaders["GlobeVS"]!, getPositionMode, get2DYPositionFraction]
                )
                
                _surfaceShaderSet.baseFragmentShaderString = ShaderProgram.createShaderSource(
                    defines: shaderDefines,
                    sources: [Shaders["GlobeFS"]!]
                )
                
                _surfaceShaderSet.invalidateShaders()
                
                var poleShaderProgram = context.replaceShaderProgram(_northPoleCommand.shaderProgram, vertexShaderSource: Shaders["GlobeVSPole"]!, fragmentShaderSource: Shaders["GlobeFSPole"]!, attributeLocations: terrainAttributeLocations)
                
                _northPoleCommand.shaderProgram = poleShaderProgram
                _southPoleCommand.shaderProgram = poleShaderProgram
                
                _hasWaterMask = hasWaterMask
                _hasVertexNormals = hasVertexNormals
                _enableLighting = enableLighting
                _oceanNormalMapChanged = false
        }
        
        _occluder.cameraPosition = frameState.camera!.positionWC
        
        fillPoles(context: context, frameState: frameState)
        
        _mode = mode
        
        if (frameState.passes.render) {
            // render quads to fill the poles
            if (mode == SceneMode.Scene3D) {
                if drawNorthPole {
                    commandList.append(_northPoleCommand)
                }
                
                if drawSouthPole {
                    commandList.append(_southPoleCommand)
                }
            }
            
            // Don't show the ocean specular highlights when zoomed out in 2D and Columbus View.
            if (mode == .Scene3D) {
                _zoomedOutOceanSpecularIntensity = 0.5
            } else {
                _zoomedOutOceanSpecularIntensity = 0.0
            }
            
            _surface.maximumScreenSpaceError = maximumScreenSpaceError
            _surface.tileCacheSize = tileCacheSize
            
            var tileProvider = _surface.tileProvider
            tileProvider.terrainProvider = terrainProvider
            tileProvider.lightingFadeOutDistance = _lightingFadeOutDistance
            tileProvider.lightingFadeInDistance = _lightingFadeInDistance
            tileProvider.zoomedOutOceanSpecularIntensity = _zoomedOutOceanSpecularIntensity
            tileProvider.oceanNormalMap = _oceanNormalMap
            
            _surface.update(context: context, frameState: frameState, commandList: &commandList)
            
            // render depth plane
            if (mode == .Scene3D || mode == .ColumbusView) {
                if (!depthTestAgainstTerrain) {
                    commandList.append(_clearDepthCommand)
                    if (mode == .Scene3D) {
                        commandList.append(_depthCommand)
                    }
                }
            }
        }
        
        if (frameState.passes.pick) {
            // Not actually pickable, but render depth-only so primitives on the backface
            // of the globe are not picked.
            commandList.append(_depthCommand)
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

