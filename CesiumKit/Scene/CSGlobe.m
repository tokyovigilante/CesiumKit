//
//  CSGlobe.m
//  CesiumKit
//
//  Created by Ryan Walklin on 24/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//


#import "CSGlobe.h"

#import "CSEllipsoid.h"

#import "CSDrawCommand.h"
#import "CSBoundingSphere.h"

#import "CSRendererDefines.h"

#import "CSCartesian2.h"
#import "CSCartesian4.h"

@class CSGlobeSurface, CSOccluder, CSGlobeSurfaceShaderSet, CSCartesian4;


@interface CSGlobe ()

@property (readonly) CSGlobeSurface *surface;
@property (readonly) CSOccluder *occluder;
@property (readonly) CSGlobeSurfaceShaderSet *surfaceShaderSet;
@property (readonly) CSCartesian4 *rsColor;
@property (readonly) CSCartesian4 *rsColorWithoutDepthTest;
@property (readonly) CSDrawCommand *clearDepthCommand;
@property (readonly) CSDrawCommand *depthCommand;
@property (readonly) CSDrawCommand *northPoleCommand;
@property (readonly) CSDrawCommand *southPoleCommand;
@property (readonly) BOOL drawNorthPole;
@property (readonly) BOOL drawSouthPole;
@property (nonatomic) CSCartesian2 *lightingFadeDistance;

@end

@implementation CSGlobe



-(instancetype)initWithEllipsoid:(CSEllipsoid *)ellipsoid
{
    self = [super init];
    if (self)
    {
        if (ellipsoid)
        {
            _ellipsoid = ellipsoid;
        }
        else
        {
            _ellipsoid = [CSEllipsoid wgs84Ellipsoid];
        }
#warning terrainprovider
        //var terrainProvider = new EllipsoidTerrainProvider({ellipsoid : ellipsoid});
        //var imageryLayerCollection = new ImageryLayerCollection();
        
        /**
         * The terrain provider providing surface geometry for this globe.
         * @type {TerrainProvider}
         */
        //this.terrainProvider = terrainProvider;
#warning surface
/*        this._surface = new GlobeSurface({
            terrainProvider : terrainProvider,
            imageryLayerCollection : imageryLayerCollection
        });*/
#warning occluder
//        this._occluder = new Occluder(new BoundingSphere(Cartesian3.ZERO, ellipsoid.minimumRadius), Cartesian3.ZERO);
#warning surfaceshaderset
//        _surfaceShaderSet = [[CSGlobeSurfaceShaderSet alloc] init];
        _rsColor = nil;
        _rsColorWithoutDepthTest = nil;
        
        _clearDepthCommand = [[CSDrawCommand alloc] initWithOptions:@{ @"depth" : @1.0,
                                                                       @"stencil" : @0,
                                                                       @"owner" : self }];
        _depthCommand [[CSDrawCommand alloc] initWithOptions:@{ @"boundingVolume" : [[CSBoundingSphere alloc] initWithCenter:[CSCartesian3 zero]
                                                                                                                      radius:ellipsoid.maximumRadius],
                                                                @"pass" : [NSNumber numberWithUnsignedInt:PassOpaque],
                                                                @"owner" : self }];
        _northPoleCommand = [[CSDrawCommand alloc] initWithOptions:@{ @"pass" : [NSNumber numberWithUnsignedInt:PassOpaque],
                                                                      @"owner" : self }];
        _southPoleCommand = [[CSDrawCommand alloc] initWithOptions:@{ @"pass" : [NSNumber numberWithUnsignedInt:PassOpaque],
                                                                      @"owner" : self }];
        _drawNorthPole = NO;
        _drawSouthPole = NO;
        
        _northPoleColor = [CSCartesian4 cartesian4WithRed:2.0/255.0 green:6.0/255.0 blue:18.0/255.0 alpha:1.0];
        _southPoleColor = [CSCartesian4 cartesian4WithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        _show = YES;
        
#warning oceanmap
        /**
         * The normal map to use for rendering waves in the ocean.  Setting this property will
         * only have an effect if the configured terrain provider includes a water mask.
         *
         * @type {String}
         * @default buildModuleUrl('Assets/Textures/waterNormalsSmall.jpg')
         */
        //this.oceanNormalMapUrl = buildModuleUrl('Assets/Textures/waterNormalsSmall.jpg');
        
#warning should probably be true for airspace
        _depthTestAgainstTerrain = NO;
        
        _maximumScreenSpaceError = 2;
        _tileCacheSize = 100;
        _enableLighting = NO;
        _lightingFadeOutDistance = 6500000.0;
        _lightingFadeInDistance = 9000000.0;

        
/*        this._lastOceanNormalMapUrl = undefined;
        this._oceanNormalMap = undefined;
        this._zoomedOutOceanSpecularIntensity = 0.5;
        this._showingPrettyOcean = false;
        this._hasWaterMask = false;*/
#warning Cartesian2 not implemented
        _lightingFadeDistance = [[CSCartesian2 alloc] initWithX:_lightingFadeOutDistance Y:_lightingFadeInDistance];
        
        CSGlobe *weakSelf = self;
#warning ocean map
        _drawUniforms = @{ //@"u_zoomedOutOceanSpecularIntensity", ^{ return weakSelf.zoomedOutOceanSpecularIntensity; },
                           //@"u_oceanNormalMap", ^{ return weakSelf.oceanNormalMap },
                           @"u_lightingFadeDistance", ^{ return weakSelf.lightingFadeDistance; }};
    }
    return self;
}

var depthQuadScratch = FeatureDetection.supportsTypedArrays() ? new Float32Array(12) : [];
var scratchCartesian1 = new Cartesian3();
var scratchCartesian2 = new Cartesian3();
var scratchCartesian3 = new Cartesian3();
var scratchCartesian4 = new Cartesian3();

function computeDepthQuad(globe, frameState) {
    var radii = globe._ellipsoid.radii;
    var p = frameState.camera.positionWC;
    
    // Find the corresponding position in the scaled space of the ellipsoid.
    var q = Cartesian3.multiplyComponents(globe._ellipsoid.oneOverRadii, p, scratchCartesian1);
    
    var qMagnitude = Cartesian3.magnitude(q);
    var qUnit = Cartesian3.normalize(q, scratchCartesian2);
    
    // Determine the east and north directions at q.
    var eUnit = Cartesian3.normalize(Cartesian3.cross(Cartesian3.UNIT_Z, q, scratchCartesian3), scratchCartesian3);
    var nUnit = Cartesian3.normalize(Cartesian3.cross(qUnit, eUnit, scratchCartesian4), scratchCartesian4);
    
    // Determine the radius of the 'limb' of the ellipsoid.
    var wMagnitude = Math.sqrt(Cartesian3.magnitudeSquared(q) - 1.0);
    
    // Compute the center and offsets.
    var center = Cartesian3.multiplyByScalar(qUnit, 1.0 / qMagnitude, scratchCartesian1);
    var scalar = wMagnitude / qMagnitude;
    var eastOffset = Cartesian3.multiplyByScalar(eUnit, scalar, scratchCartesian2);
    var northOffset = Cartesian3.multiplyByScalar(nUnit, scalar, scratchCartesian3);
    
    // A conservative measure for the longitudes would be to use the min/max longitudes of the bounding frustum.
    var upperLeft = Cartesian3.add(center, northOffset, scratchCartesian4);
    Cartesian3.subtract(upperLeft, eastOffset, upperLeft);
    Cartesian3.multiplyComponents(radii, upperLeft, upperLeft);
    Cartesian3.pack(upperLeft, depthQuadScratch, 0);
    
    var lowerLeft = Cartesian3.subtract(center, northOffset, scratchCartesian4);
    Cartesian3.subtract(lowerLeft, eastOffset, lowerLeft);
    Cartesian3.multiplyComponents(radii, lowerLeft, lowerLeft);
    Cartesian3.pack(lowerLeft, depthQuadScratch, 3);
    
    var upperRight = Cartesian3.add(center, northOffset, scratchCartesian4);
    Cartesian3.add(upperRight, eastOffset, upperRight);
    Cartesian3.multiplyComponents(radii, upperRight, upperRight);
    Cartesian3.pack(upperRight, depthQuadScratch, 6);
    
    var lowerRight = Cartesian3.subtract(center, northOffset, scratchCartesian4);
    Cartesian3.add(lowerRight, eastOffset, lowerRight);
    Cartesian3.multiplyComponents(radii, lowerRight, lowerRight);
    Cartesian3.pack(lowerRight, depthQuadScratch, 9);
    
    return depthQuadScratch;
}

function computePoleQuad(globe, frameState, maxLat, maxGivenLat, viewProjMatrix, viewportTransformation) {
    var pt1 = globe._ellipsoid.cartographicToCartesian(new Cartographic(0.0, maxGivenLat));
    var pt2 = globe._ellipsoid.cartographicToCartesian(new Cartographic(Math.PI, maxGivenLat));
    var radius = Cartesian3.magnitude(Cartesian3.subtract(pt1, pt2)) * 0.5;
    
    var center = globe._ellipsoid.cartographicToCartesian(new Cartographic(0.0, maxLat));
    
    var right;
    var dir = frameState.camera.direction;
    if (1.0 - Cartesian3.dot(Cartesian3.negate(Cartesian3.UNIT_Z), dir) < CesiumMath.EPSILON6) {
        right = Cartesian3.UNIT_X;
    } else {
        right = Cartesian3.normalize(Cartesian3.cross(dir, Cartesian3.UNIT_Z));
    }
    
    var screenRight = Cartesian3.add(center, Cartesian3.multiplyByScalar(right, radius));
    var screenUp = Cartesian3.add(center, Cartesian3.multiplyByScalar(Cartesian3.normalize(Cartesian3.cross(Cartesian3.UNIT_Z, right)), radius));
    
    Transforms.pointToWindowCoordinates(viewProjMatrix, viewportTransformation, center, center);
    Transforms.pointToWindowCoordinates(viewProjMatrix, viewportTransformation, screenRight, screenRight);
    Transforms.pointToWindowCoordinates(viewProjMatrix, viewportTransformation, screenUp, screenUp);
    
    var halfWidth = Math.floor(Math.max(Cartesian3.distance(screenUp, center), Cartesian3.distance(screenRight, center)));
    var halfHeight = halfWidth;
    
    return new BoundingRectangle(
                                 Math.floor(center.x) - halfWidth,
                                 Math.floor(center.y) - halfHeight,
                                 halfWidth * 2.0,
                                 halfHeight * 2.0);
}

var viewportScratch = new BoundingRectangle();
var vpTransformScratch = new Matrix4();
var polePositionsScratch = FeatureDetection.supportsTypedArrays() ? new Float32Array(8) : [];

function fillPoles(globe, context, frameState) {
    var terrainProvider = globe._surface._terrainProvider;
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
        rectangle = new Rectangle(
                                  -Math.PI,
                                  terrainMaxRectangle.north,
                                  Math.PI,
                                  CesiumMath.PI_OVER_TWO
                                  );
        boundingVolume = BoundingSphere.fromRectangle3D(rectangle, globe._ellipsoid);
        frustumCull = frameState.cullingVolume.getVisibility(boundingVolume) === Intersect.OUTSIDE;
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
        rectangle = new Rectangle(
                                  -Math.PI,
                                  -CesiumMath.PI_OVER_TWO,
                                  Math.PI,
                                  terrainMaxRectangle.south
                                  );
        boundingVolume = BoundingSphere.fromRectangle3D(rectangle, globe._ellipsoid);
        frustumCull = frameState.cullingVolume.getVisibility(boundingVolume) === Intersect.OUTSIDE;
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
    
    var that = globe;
    if (!defined(globe._northPoleCommand.uniformMap)) {
        var northPoleUniforms = combine(drawUniforms, {
            u_color : function() {
                return that.northPoleColor;
            }
        });
        globe._northPoleCommand.uniformMap = combine(northPoleUniforms, globe._drawUniforms);
    }
    
    if (!defined(globe._southPoleCommand.uniformMap)) {
        var southPoleUniforms = combine(drawUniforms, {
            u_color : function() {
                return that.southPoleColor;
            }
        });
        globe._southPoleCommand.uniformMap = combine(southPoleUniforms, globe._drawUniforms);
    }
}

/**
 * @private
 */
Globe.prototype.update = function(context, frameState, commandList) {
    if (!this.show) {
        return;
    }
    
    var width = context.drawingBufferWidth;
    var height = context.drawingBufferHeight;
    
    if (width === 0 || height === 0) {
        return;
    }
    
    var mode = frameState.mode;
    var projection = frameState.scene2D.projection;
    var modeChanged = false;
    
    if (this._mode !== mode || !defined(this._rsColor)) {
        modeChanged = true;
        if (mode === SceneMode.SCENE3D || mode === SceneMode.COLUMBUS_VIEW) {
            this._rsColor = context.createRenderState({ // Write color and depth
                cull : {
                    enabled : true
                },
                depthTest : {
                    enabled : true
                }
            });
            this._rsColorWithoutDepthTest = context.createRenderState({ // Write color, not depth
                cull : {
                    enabled : true
                }
            });
            this._depthCommand.renderState = context.createRenderState({ // Write depth, not color
                cull : {
                    enabled : true
                },
                depthTest : {
                    enabled : true,
                    func : DepthFunction.ALWAYS
                },
                colorMask : {
                    red : false,
                    green : false,
                    blue : false,
                    alpha : false
                }
            });
        } else {
            this._rsColor = context.createRenderState({
                cull : {
                    enabled : true
                }
            });
            this._rsColorWithoutDepthTest = context.createRenderState({
                cull : {
                    enabled : true
                }
            });
            this._depthCommand.renderState = context.createRenderState({
                cull : {
                    enabled : true
                }
            });
        }
    }
    
    this._northPoleCommand.renderState = this._rsColorWithoutDepthTest;
    this._southPoleCommand.renderState = this._rsColorWithoutDepthTest;
    
    // update depth plane
    var depthQuad = computeDepthQuad(this, frameState);
    
    // depth plane
    if (!this._depthCommand.vertexArray) {
        var geometry = new Geometry({
            attributes : {
                position : new GeometryAttribute({
                    componentDatatype : ComponentDatatype.FLOAT,
                    componentsPerAttribute : 3,
                    values : depthQuad
                })
            },
            indices : [0, 1, 2, 2, 1, 3],
            primitiveType : PrimitiveType.TRIANGLES
        });
        this._depthCommand.vertexArray = context.createVertexArrayFromGeometry({
            geometry : geometry,
            attributeLocations : {
                position : 0
            },
            bufferUsage : BufferUsage.DYNAMIC_DRAW
        });
    } else {
        this._depthCommand.vertexArray.getAttribute(0).vertexBuffer.copyFromArrayView(depthQuad);
    }
    
    if (!defined(this._depthCommand.shaderProgram)) {
        this._depthCommand.shaderProgram = context.createShaderProgram(
                                                                       GlobeVSDepth,
                                                                       GlobeFSDepth, {
                                                                           position : 0
                                                                       });
    }
    
    if (this._surface._terrainProvider.ready &&
        this._surface._terrainProvider.hasWaterMask() &&
        this.oceanNormalMapUrl !== this._lastOceanNormalMapUrl) {
        
        this._lastOceanNormalMapUrl = this.oceanNormalMapUrl;
        
        var that = this;
        when(loadImage(this.oceanNormalMapUrl), function(image) {
            that._oceanNormalMap = that._oceanNormalMap && that._oceanNormalMap.destroy();
            that._oceanNormalMap = context.createTexture2D({
                source : image
            });
        });
    }
    
    // Initial compile or re-compile if uber-shader parameters changed
    var projectionChanged = this._projection !== projection;
    var hasWaterMask = this._surface._terrainProvider.ready && this._surface._terrainProvider.hasWaterMask();
    var hasWaterMaskChanged = this._hasWaterMask !== hasWaterMask;
    var hasEnableLightingChanged = this._enableLighting !== this.enableLighting;
    
    if (!defined(this._surfaceShaderSet) ||
        !defined(this._northPoleCommand.shaderProgram) ||
        !defined(this._southPoleCommand.shaderProgram) ||
        modeChanged ||
        projectionChanged ||
        hasWaterMaskChanged ||
        hasEnableLightingChanged ||
        (defined(this._oceanNormalMap)) !== this._showingPrettyOcean) {
        
        var getPosition3DMode = 'vec4 getPosition(vec3 position3DWC) { return getPosition3DMode(position3DWC); }';
        var getPosition2DMode = 'vec4 getPosition(vec3 position3DWC) { return getPosition2DMode(position3DWC); }';
        var getPositionColumbusViewMode = 'vec4 getPosition(vec3 position3DWC) { return getPositionColumbusViewMode(position3DWC); }';
        var getPositionMorphingMode = 'vec4 getPosition(vec3 position3DWC) { return getPositionMorphingMode(position3DWC); }';
        
        var getPositionMode;
        
        switch (mode) {
            case SceneMode.SCENE3D:
                getPositionMode = getPosition3DMode;
                break;
            case SceneMode.SCENE2D:
                getPositionMode = getPosition2DMode;
                break;
            case SceneMode.COLUMBUS_VIEW:
                getPositionMode = getPositionColumbusViewMode;
                break;
            case SceneMode.MORPHING:
                getPositionMode = getPositionMorphingMode;
                break;
        }
        
        var get2DYPositionFractionGeographicProjection = 'float get2DYPositionFraction() { return get2DGeographicYPositionFraction(); }';
        var get2DYPositionFractionMercatorProjection = 'float get2DYPositionFraction() { return get2DMercatorYPositionFraction(); }';
        
        var get2DYPositionFraction;
        
        if (projection instanceof GeographicProjection) {
            get2DYPositionFraction = get2DYPositionFractionGeographicProjection;
        } else {
            get2DYPositionFraction = get2DYPositionFractionMercatorProjection;
        }
        
        this._surfaceShaderSet.baseVertexShaderString = createShaderSource({
            defines : [
                       (hasWaterMask ? 'SHOW_REFLECTIVE_OCEAN' : ''),
                       (this.enableLighting ? 'ENABLE_LIGHTING' : '')
                       ],
            sources : [GlobeVS, getPositionMode, get2DYPositionFraction]
        });
        
        var showPrettyOcean = hasWaterMask && defined(this._oceanNormalMap);
        
        this._surfaceShaderSet.baseFragmentShaderString = createShaderSource({
            defines : [
                       (hasWaterMask ? 'SHOW_REFLECTIVE_OCEAN' : ''),
                       (showPrettyOcean ? 'SHOW_OCEAN_WAVES' : ''),
                       (this.enableLighting ? 'ENABLE_LIGHTING' : '')
                       ],
            sources : [GlobeFS]
        });
        this._surfaceShaderSet.invalidateShaders();
        
        var poleShaderProgram = context.replaceShaderProgram(this._northPoleCommand.shaderProgram,
                                                             GlobeVSPole, GlobeFSPole, terrainAttributeLocations);
        
        this._northPoleCommand.shaderProgram = poleShaderProgram;
        this._southPoleCommand.shaderProgram = poleShaderProgram;
        
        this._showingPrettyOcean = defined(this._oceanNormalMap);
        this._hasWaterMask = hasWaterMask;
        this._enableLighting = this.enableLighting;
    }
    
    var cameraPosition = frameState.camera.positionWC;
    
    this._occluder.cameraPosition = cameraPosition;
    
    fillPoles(this, context, frameState);
    
    this._mode = mode;
    this._projection = projection;
    
    var pass = frameState.passes;
    if (pass.render) {
        // render quads to fill the poles
        if (mode === SceneMode.SCENE3D) {
            if (this._drawNorthPole) {
                commandList.push(this._northPoleCommand);
            }
            
            if (this._drawSouthPole) {
                commandList.push(this._southPoleCommand);
            }
        }
        
        // Don't show the ocean specular highlights when zoomed out in 2D and Columbus View.
        if (mode === SceneMode.SCENE3D) {
            this._zoomedOutOceanSpecularIntensity = 0.5;
        } else {
            this._zoomedOutOceanSpecularIntensity = 0.0;
        }
        
        this._lightingFadeDistance.x = this.lightingFadeOutDistance;
        this._lightingFadeDistance.y = this.lightingFadeInDistance;
        
        this._surface._maximumScreenSpaceError = this.maximumScreenSpaceError;
        this._surface._tileCacheSize = this.tileCacheSize;
        this._surface.terrainProvider = this.terrainProvider;
        this._surface.update(context,
                             frameState,
                             commandList,
                             this._drawUniforms,
                             this._surfaceShaderSet,
                             this._rsColor,
                             this._projection);
        
        // render depth plane
        if (mode === SceneMode.SCENE3D || mode === SceneMode.COLUMBUS_VIEW) {
            if (!this.depthTestAgainstTerrain) {
                commandList.push(this._clearDepthCommand);
                if (mode === SceneMode.SCENE3D) {
                    commandList.push(this._depthCommand);
                }
            }
        }
    }
    
    if (pass.pick) {
        // Not actually pickable, but render depth-only so primitives on the backface
        // of the globe are not picked.
        commandList.push(this._depthCommand);
    }
};

/**
 * Returns true if this object was destroyed; otherwise, false.
 * <br /><br />
 * If this object was destroyed, it should not be used; calling any function other than
 * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
 *
 * @memberof Globe
 *
 * @returns {Boolean} True if this object was destroyed; otherwise, false.
 *
 * @see Globe#destroy
 */
Globe.prototype.isDestroyed = function() {
    return false;
};

/**
 * Destroys the WebGL resources held by this object.  Destroying an object allows for deterministic
 * release of WebGL resources, instead of relying on the garbage collector to destroy this object.
 * <br /><br />
 * Once an object is destroyed, it should not be used; calling any function other than
 * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
 * assign the return value (<code>undefined</code>) to the object as done in the example.
 *
 * @memberof Globe
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
Globe.prototype.destroy = function() {
    this._northPoleCommand.vertexArray = this._northPoleCommand.vertexArray && this._northPoleCommand.vertexArray.destroy();
    this._southPoleCommand.vertexArray = this._southPoleCommand.vertexArray && this._southPoleCommand.vertexArray.destroy();
    
    this._surfaceShaderSet = this._surfaceShaderSet && this._surfaceShaderSet.destroy();
    
    this._northPoleCommand.shaderProgram = this._northPoleCommand.shaderProgram && this._northPoleCommand.shaderProgram.destroy();
    this._southPoleCommand.shaderProgram = this._northPoleCommand.shaderProgram;
    
    this._depthCommand.shaderProgram = this._depthCommand.shaderProgram && this._depthCommand.shaderProgram.destroy();
    this._depthCommand.vertexArray = this._depthCommand.vertexArray && this._depthCommand.vertexArray.destroy();
    
    this._surface = this._surface && this._surface.destroy();
    
    this._oceanNormalMap = this._oceanNormalMap && this._oceanNormalMap.destroy();
    
    return destroyObject(this);
};

return Globe;

});


@end
