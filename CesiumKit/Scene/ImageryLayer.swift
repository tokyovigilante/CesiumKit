//
//  ImageryLayer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import UIKit.UIImage

/**
* An imagery layer that displays tiled image data from a single imagery provider
* on a {@link Globe}.
*
* @alias ImageryLayer
* @constructor
*
* @param {ImageryProvider} imageryProvider The imagery provider to use.
*/
class ImageryLayer {
    
    /**
    * This value is used as the default brightness for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the brightness of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let DefaultBrightness = 1.0
    
    /**
    * This value is used as the default contrast for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the contrast of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let DefaultContrast = 1.0
    
    /**
    * This value is used as the default hue for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the hue of the imagery.
    * @type {Number}
    * @default 0.0
    */
    let DefaultHue = 0.0
    
    /**
    * This value is used as the default saturation for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the saturation of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let DefaultSaturation = 1.0
    
    /**
    * This value is used as the default gamma for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the gamma of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let DefaultGamma = 1.0

    var imageryProvider: ImageryProvider
    
    /**
    * @param {Rectangle} [options.rectangle=imageryProvider.rectangle] The rectangle of the layer.  This rectangle
    *        can limit the visible portion of the imagery provider.
    */
    private let _rectangle: Rectangle
    
    /**
    * @param {Number|Function} [options.alpha=1.0] The alpha blending value of this layer, from 0.0 to 1.0.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates of the
    *                          imagery tile for which the alpha is required, and it is expected to return
    *                          the alpha value to use for the tile.
    */
    let alpha: (() -> Double)
    
    /**
    * @param {Number|Function} [options.brightness=1.0] The brightness of this layer.  1.0 uses the unmodified imagery
    *                          color.  Less than 1.0 makes the imagery darker while greater than 1.0 makes it brighter.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates of the
    *                          imagery tile for which the brightness is required, and it is expected to return
    *                          the brightness value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let brightness: (() -> Double)
    
    /**
    * @param {Number|Function} [options.contrast=1.0] The contrast of this layer.  1.0 uses the unmodified imagery color.
    *                          Less than 1.0 reduces the contrast while greater than 1.0 increases it.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates of the
    *                          imagery tile for which the contrast is required, and it is expected to return
    *                          the contrast value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let contrast: (() -> Double)
    
    /*
    * @param {Number|Function} [options.hue=0.0] The hue of this layer.  0.0 uses the unmodified imagery color.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates
    *                          of the imagery tile for which the hue is required, and it is expected to return
    *                          the contrast value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let hue: (() -> Double)
    
    /**
    * @param {Number|Function} [options.saturation=1.0] The saturation of this layer.  1.0 uses the unmodified imagery color.
    *                          Less than 1.0 reduces the saturation while greater than 1.0 increases it.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates
    *                          of the imagery tile for which the saturation is required, and it is expected to return
    *                          the contrast value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let saturation: (() -> Double)
    
    /**
    * @param {Number|Function} [options.gamma=1.0] The gamma correction to apply to this layer.  1.0 uses the unmodified imagery color.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates of the
    *                          imagery tile for which the gamma is required, and it is expected to return
    *                          the gamma value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let gamma: (() -> Double)
    
    /**
    * @param {Boolean} [options.show=true] True if the layer is shown; otherwise, false.
    */
    let show: Bool
    
    // The value of the show property on the last update.
    var _show: Bool = true
    
    /*
    * @param {Number} [options.maximumAnisotropy=maximum supported] The maximum anisotropy level to use
    *        for texture filtering.  If this parameter is not specified, the maximum anisotropy supported
    *        by the WebGL stack will be used.  Larger values make the imagery look better in horizon
    *        views.
    */
    let maximumAnisotropy: Int?
    
    /*
    * @param {Number} [options.minimumTerrainLevel] The minimum terrain level-of-detail at which to show this imagery layer,
    *                 or undefined to show it at all levels.  Level zero is the least-detailed level.
    */
    private let _minimumTerrainLevel: Int?
    
    /**
    * @param {Number} [options.maximumTerrainLevel] The maximum terrain level-of-detail at which to show this imagery layer,
    *                 or undefined to show it at all levels.  Level zero is the least-detailed level.
    */
    private let _maximumTerrainLevel: Int?
    
    
    private var _imageryCache = [String: Imagery]()
    
    lazy private var _skeletonPlaceholder: TileImagery = TileImagery(imagery: Imagery.createPlaceholder(self))

    // The index of this layer in the ImageryLayerCollection.
    var layerIndex = -1
    
    //private var _requestImageError = undefined;
    
    /**
    * Gets a value indicating whether this layer is the base layer in the
    * {@link ImageryLayerCollection}.  The base layer is the one that underlies all
    * others.  It is special in that it is treated as if it has global rectangle, even if
    * it actually does not, by stretching the texels at the edges over the entire
    * globe.
    *
    * @returns {Boolean} true if this is the base layer; otherwise, false.
    */
    var isBaseLayer = false
    
    init (
        imageryProvider: ImageryProvider,
        rectangle: Rectangle = Rectangle.maxValue(),
        alpha: (() -> Double) = { return 1.0 },
        brightness: (() -> Double) = { return 1.0 },
        contrast: (() -> Double) = { return 1.0 },
        hue: (() -> Double) = { return 0.0 },
        saturation: (() -> Double) = { return 1.0 },
        gamma: (() -> Double) = { return 1.0 },
        show: Bool = true,
        minimumTerrainLevel: Int? = nil,
        maximumTerrainLevel: Int? = nil,
        maximumAnisotropy: Int? = nil
        ) {
            self.imageryProvider = imageryProvider
            self._rectangle = rectangle
            self.alpha = alpha
            self.brightness = brightness
            self.contrast = contrast
            self.hue = hue
            self.saturation = saturation
            self.gamma = gamma
            self.show = show
            self._minimumTerrainLevel = minimumTerrainLevel
            self._maximumTerrainLevel = maximumTerrainLevel
            self.maximumAnisotropy = maximumAnisotropy
        }
    
    
    
    
    /**
    * Create skeletons for the imagery tiles that partially or completely overlap a given terrain
    * tile.
    *
    * @private
    *
    * @param {QuadtreeTile} tile The terrain tile.
    * @param {TerrainProvider} terrainProvider The terrain provider associated with the terrain tile.
    * @param {Number} insertionPoint The position to insert new skeletons before in the tile's imagery lsit.
    * @returns {Boolean} true if this layer overlaps any portion of the terrain tile; otherwise, false.
    */
    func createTileImagerySkeletons (tile: QuadtreeTile, terrainProvider: TerrainProvider, insertionPoint: Int? = nil) -> Bool {
        let surfaceTile = tile.data!
        
        if _minimumTerrainLevel != nil && tile.level < _minimumTerrainLevel {
            return false
        }
        if _maximumTerrainLevel != nil && tile.level > _maximumTerrainLevel {
            return false
        }
        var insertionPoint = insertionPoint
        if insertionPoint == nil {
            insertionPoint = surfaceTile.imagery.count
        }
        
        if (!imageryProvider.ready) {
            // The imagery provider is not ready, so we can't create skeletons, yet.
            // Instead, add a placeholder so that we'll know to create
            // the skeletons once the provider is ready.
            _skeletonPlaceholder.loadingImagery!.addReference()
            surfaceTile.imagery.removeAtIndex(insertionPoint!)
            surfaceTile.imagery.insert(_skeletonPlaceholder, atIndex: insertionPoint!)
            return true
        }
        
        // Compute the rectangle of the imagery from this imageryProvider that overlaps
        // the geometry tile.  The ImageryProvider and ImageryLayer both have the
        // opportunity to constrain the rectangle.  The imagery TilingScheme's rectangle
        // always fully contains the ImageryProvider's rectangle.
        var rectangle = tile.rectangle.intersectWith(imageryProvider.rectangle).intersectWith(_rectangle)
        
        if rectangle.east <= rectangle.west || rectangle.north <= rectangle.south {
            // There is no overlap between this terrain tile and this imagery
            // provider.  Unless this is the base layer, no skeletons need to be created.
            // We stretch texels at the edge of the base layer over the entire globe.
            if !isBaseLayer {
                return false
            }
            
            let baseImageryRectangle = imageryProvider.rectangle.intersectWith(_rectangle)
            var baseTerrainRectangle = tile.rectangle
            
            if baseTerrainRectangle.south >= baseImageryRectangle.north {
                rectangle.north = baseImageryRectangle.north
                rectangle.south = rectangle.north
            } else if baseTerrainRectangle.north <= baseImageryRectangle.south {
                rectangle.south = baseImageryRectangle.south
                rectangle.north = rectangle.south
            }
            
            if baseTerrainRectangle.west >= baseImageryRectangle.east {
                rectangle.east = baseImageryRectangle.east
                rectangle.west = rectangle.east
            } else if baseTerrainRectangle.east <= baseImageryRectangle.west {
                rectangle.east = baseImageryRectangle.west
                rectangle.west = rectangle.east
            }
        }
        
        var latitudeClosestToEquator = 0.0
        if (rectangle.south > 0.0) {
            latitudeClosestToEquator = rectangle.south
        } else if (rectangle.north < 0.0) {
            latitudeClosestToEquator = rectangle.north
        }
        
        // Compute the required level in the imagery tiling scheme.
        // The errorRatio should really be imagerySSE / terrainSSE rather than this hard-coded value.
        // But first we need configurable imagery SSE and we need the rendering to be able to handle more
        // images attached to a terrain tile than there are available texture units.  So that's for the future.
        let errorRatio = 1.0
        let targetGeometricError = errorRatio * terrainProvider.levelMaximumGeometricError(tile.level)
        var imageryLevel = levelWithMaximumTexelSpacing(texelSpacing: targetGeometricError, latitudeClosestToEquator: latitudeClosestToEquator)
        imageryLevel = max(0, imageryLevel)
        var maximumLevel = imageryProvider.maximumLevel
        if (imageryLevel > maximumLevel) {
            imageryLevel = maximumLevel
        }
        
        if let minimumLevel = imageryProvider.minimumLevel {
            if (imageryLevel < minimumLevel) {
                imageryLevel = minimumLevel
            }
        }
        
        let imageryTilingScheme = imageryProvider.tilingScheme
        var northwestTileCoordinates = imageryTilingScheme.positionToTileXY(position: rectangle.northwest(), level: imageryLevel)!
        var southeastTileCoordinates = imageryTilingScheme.positionToTileXY(position: rectangle.southeast(), level: imageryLevel)!
        
        // If the southeast corner of the rectangle lies very close to the north or west side
        // of the southeast tile, we don't actually need the southernmost or easternmost
        // tiles.
        // Similarly, if the northwest corner of the rectangle lies very close to the south or east side
        // of the northwest tile, we don't actually need the northernmost or westernmost tiles.
        
        // We define "very close" as being within 1/512 of the width of the tile.
        var veryCloseX = (tile.rectangle.north - tile.rectangle.south) / 512.0
        var veryCloseY = (tile.rectangle.east - tile.rectangle.west) / 512.0
        
        var northwestTileRectangle = imageryTilingScheme.tileXYToRectangle(x: northwestTileCoordinates.x, y: northwestTileCoordinates.y, level: imageryLevel)
        if (abs(northwestTileRectangle.south - tile.rectangle.north) < veryCloseY && northwestTileCoordinates.y < southeastTileCoordinates.y) {
            ++northwestTileCoordinates.y
        }
        if (abs(northwestTileRectangle.east - tile.rectangle.west) < veryCloseX && northwestTileCoordinates.x < southeastTileCoordinates.x) {
            ++northwestTileCoordinates.x
        }
        
        var southeastTileRectangle = imageryTilingScheme.tileXYToRectangle(x: southeastTileCoordinates.x, y: southeastTileCoordinates.y, level: imageryLevel)
        if (abs(southeastTileRectangle.north - tile.rectangle.south) < veryCloseY && southeastTileCoordinates.y > northwestTileCoordinates.y) {
            --southeastTileCoordinates.y
        }
        if (abs(southeastTileRectangle.west - tile.rectangle.east) < veryCloseX && southeastTileCoordinates.x > northwestTileCoordinates.x) {
            --southeastTileCoordinates.x
        }
        
        // Create TileImagery instances for each imagery tile overlapping this terrain tile.
        // We need to do all texture coordinate computations in the imagery tile's tiling scheme.
        
        var terrainRectangle = tile.rectangle
        var imageryRectangle = imageryTilingScheme.tileXYToRectangle(x: northwestTileCoordinates.x, y: northwestTileCoordinates.y, level: imageryLevel)
        
        var minU: Double
        var maxU = 0.0
        
        var minV = 1.0
        var maxV: Double
        
        // If this is the northern-most or western-most tile in the imagery tiling scheme,
        // it may not start at the northern or western edge of the terrain tile.
        // Calculate where it does start.
        if !isBaseLayer && abs(imageryRectangle.west - tile.rectangle.west) >= veryCloseX {
            maxU = min(1.0, (imageryRectangle.west - terrainRectangle.west) / (terrainRectangle.east - terrainRectangle.west))
        }
        
        if (isBaseLayer && abs(imageryRectangle.north - tile.rectangle.north) >= veryCloseY) {
            minV = max(0.0, (imageryRectangle.north - terrainRectangle.south) / (terrainRectangle.north - terrainRectangle.south))
        }
        
        var initialMinV = minV
        
        for i in northwestTileCoordinates.x...southeastTileCoordinates.x {
            minU = maxU
            
            imageryRectangle = imageryTilingScheme.tileXYToRectangle(x: i, y: northwestTileCoordinates.y, level: imageryLevel)
            maxU = min(1.0, (imageryRectangle.east - terrainRectangle.west) / (terrainRectangle.east - terrainRectangle.west));
            
            // If this is the eastern-most imagery tile mapped to this terrain tile,
            // and there are more imagery tiles to the east of this one, the maxU
            // should be 1.0 to make sure rounding errors don't make the last
            // image fall shy of the edge of the terrain tile.
            if i == southeastTileCoordinates.x && (isBaseLayer || abs(imageryRectangle.east - tile.rectangle.east) < veryCloseX) {
                maxU = 1.0
            }
            
            minV = initialMinV
            
            for j in northwestTileCoordinates.y...southeastTileCoordinates.y {
                maxV = minV
                
                imageryRectangle = imageryTilingScheme.tileXYToRectangle(x: i, y: j, level: imageryLevel)
                minV = max(0.0, (imageryRectangle.south - terrainRectangle.south) / (terrainRectangle.north - terrainRectangle.south))
                
                // If this is the southern-most imagery tile mapped to this terrain tile,
                // and there are more imagery tiles to the south of this one, the minV
                // should be 0.0 to make sure rounding errors don't make the last
                // image fall shy of the edge of the terrain tile.
                if j == southeastTileCoordinates.y && (isBaseLayer || abs(imageryRectangle.south - tile.rectangle.south) < veryCloseY) {
                    minV = 0.0
                }
                
                let texCoordsRectangle = Cartesian4(x: minU, y: minV, z: maxU, w: maxV)
                let imagery = getImageryFromCache(x: i, y: j, level: imageryLevel, imageryRectangle: imageryRectangle)
                surfaceTile.imagery.insert(TileImagery(imagery: imagery, textureCoordinateRectangle: texCoordsRectangle), atIndex: insertionPoint!)
                ++insertionPoint!
            }
        }
        return true
    }
    
    /**
    * Calculate the translation and scale for a particular {@link TileImagery} attached to a
    * particular terrain tile.
    *
    * @private
    *
    * @param {Tile} tile The terrain tile.
    * @param {TileImagery} tileImagery The imagery tile mapping.
    * @returns {Cartesian4} The translation and scale where X and Y are the translation and Z and W
    *          are the scale.
    */
    func calculateTextureTranslationAndScale (tile: QuadtreeTile, tileImagery: TileImagery) -> Cartesian4 {
        let imageryRectangle = tileImagery.readyImagery!.rectangle!
        let terrainRectangle = tile.rectangle
        let terrainWidth = terrainRectangle.east - terrainRectangle.west
        let terrainHeight = terrainRectangle.north - terrainRectangle.south
        
        let scaleX = terrainWidth / (imageryRectangle.east - imageryRectangle.west)
        let scaleY = terrainHeight / (imageryRectangle.north - imageryRectangle.south)
        
        return Cartesian4(
            x: scaleX * (terrainRectangle.west - imageryRectangle.west) / terrainWidth,
            y: scaleY * (terrainRectangle.south - imageryRectangle.south) / terrainHeight,
            z: scaleX,
            w: scaleY)
    }
    
    /**
    * Request a particular piece of imagery from the imagery provider.  This method handles raising an
    * error event if the request fails, and retrying the request if necessary.
    *
    * @private
    *
    * @param {Imagery} imagery The imagery to request.
    */
    func requestImagery (imagery: Imagery) {
        
        weak var weakSelf = self
        weak var weakImagery = imagery
        func success(image: UIImage) {
            
            weakImagery?.image = image
            weakImagery?.credits = imageryProvider.tileCredits(x: imagery.x, y: imagery.y, level: imagery.level)

            weakImagery?.state = .Received
            
            //TileProviderError.handleSuccess(that._requestImageError);
        }
        
        func failure(error: String) {
            // Initially assume failure.  handleError may retry, in which case the state will
            // change to TRANSITIONING.
            imagery.state = .Failed
            
            var message = "Failed to obtain image tile X: \(imagery.x) Y: \(imagery.y) Level: \(imagery.level)"
            /*that._requestImageError = TileProviderError.handleError(
            that._requestImageError,
            imageryProvider,
            imageryProvider.errorEvent,
            message,
            imagery.x, imagery.y, imagery.level,
            doRequest);*/
            println(message)
        }
        
        func doRequest() -> AsyncResult<UIImage> {
            
            weakImagery?.state = .Transitioning
            
            if let image = imageryProvider.requestImage(x: imagery.x, y: imagery.y, level: imagery.level) {
                return AsyncResult(image)
            }
            return AsyncResult("image data request failed")
        }
        
        AsyncResult<UIImage>.perform(doRequest, asyncClosures: (success: success, failure: failure))
    }
    
    /**
    * Create a WebGL texture for a given {@link Imagery} instance.
    *
    * @private
    *
    * @param {Context} context The rendered context to use to create textures.
    * @param {Imagery} imagery The imagery for which to create a texture.
    */
    func createTexture (context: Context, imagery: Imagery) {
        
        // If this imagery provider has a discard policy, use it to check if this
        // image should be discarded.
        if let discardPolicy = imageryProvider.tileDiscardPolicy {
            // If the discard policy is not ready yet, transition back to the
            // RECEIVED state and we'll try again next time.
            if !discardPolicy.isReady {
                imagery.state = .Received
                return
            }
            
            // Mark discarded imagery tiles invalid.  Parent imagery will be used instead.
            if (discardPolicy.shouldDiscardImage(imagery.image!)) {
                imagery.state = .Invalid
                return
            }
        }
        
        // Imagery does not need to be discarded, so upload it to GL.
        let texture = context.createTexture2D(TextureOptions(
            source : .Image(imagery.image!),
            pixelFormat : imageryProvider.hasAlphaChannel ? .RGBA : .RGB))
        
        imagery.texture = texture
        imagery.image = nil
        imagery.state = ImageryState.TextureLoaded
    }
    
    /**
    * Reproject a texture to a {@link GeographicProjection}, if necessary, and generate
    * mipmaps for the geographic texture.
    *
    * @private
    *
    * @param {Context} context The rendered context to use.
    * @param {Imagery} imagery The imagery instance to reproject.
    */
    func reprojectTexture (context: Context, imagery: Imagery) {
        var texture = imagery.texture!
        let rectangle = imagery.rectangle!
        
        // Reproject this texture if it is not already in a geographic projection and
        // the pixels are more than 1e-5 radians apart.  The pixel spacing cutoff
        // avoids precision problems in the reprojection transformation while making
        // no noticeable difference in the georeferencing of the image.
        let pixelGap: Bool = (rectangle.east - rectangle.west) / Double(texture.width) > pow(1, -5)
        let isGeographic = imageryProvider.tilingScheme is GeographicTilingScheme
        if !isGeographic && pixelGap {
            let reprojectedTexture = reprojectToGeographic(context, texture: texture, rectangle: imagery.rectangle!)
            texture = reprojectedTexture
            imagery.texture = texture
        }

        // Use mipmaps if this texture has power-of-two dimensions.
        if Math.isPowerOfTwo(texture.width) && Math.isPowerOfTwo(texture.height) {
            var mipmapSampler = context.cache["imageryLayer_mipmapSampler"] as Sampler?
            if mipmapSampler == nil {
                mipmapSampler = Sampler()
                mipmapSampler!.wrapS = .Edge
                mipmapSampler!.wrapT = .Edge
                mipmapSampler!.minificationFilter = TextureMinificationFilter.LinearMipmapLinear
                mipmapSampler!.magnificationFilter = TextureMagnificationFilter.Linear
                mipmapSampler!.maximumAnisotropy = context.maximumTextureFilterAnisotropy
            }
            
            context.cache["imageryLayer_mipmapSampler"] = mipmapSampler
            texture.generateMipmap(.Nicest)
            texture.sampler = mipmapSampler
        } else {
            var nonMipmapSampler = context.cache["imageryLayer_nonMipmapSampler"] as Sampler?
            if nonMipmapSampler == nil {
                nonMipmapSampler = Sampler()
                //nonMipmapSampler?.wrapS = TextureWrap.Edge
                /*nonMipmapSampler = Sampler(
                wrapS: TextureWrap.Edge,
                wrapT: .Edge,
                minificationFilter: .Linear,
                magnificationFilter: .Linear,
                maximumAnisotropy: 1.0*/
                //)
                context.cache["imageryLayer_nonMipmapSampler"] = nonMipmapSampler!
            }
            texture.sampler = nonMipmapSampler!
        }
        
        imagery.state = .Ready
    }

    func getImageryFromCache (#x: Int, y: Int, level: Int, imageryRectangle: Rectangle? = nil) -> Imagery {
        let cacheKey = getImageryCacheKey(x: x, y: y, level: level)
        var imagery = _imageryCache[cacheKey]
        
        if imagery == nil {
        imagery = Imagery(imageryLayer: self, level: x, x: y, y: level, rectangle: imageryRectangle)
        _imageryCache[cacheKey] = imagery
        }
        
        imagery!.addReference()
        return imagery!
    }
    
    func removeImageryFromCache (imagery: Imagery) {
        var cacheKey = getImageryCacheKey(x: imagery.x, y: imagery.y, level: imagery.level)
        _imageryCache.removeValueForKey(cacheKey)
    }
    
    func getImageryCacheKey(#x: Int, y: Int, level: Int) -> String {
        return "x:\(x)y\(y)level\(level)"
    }
    /*
    var uniformMap = {
    u_textureDimensions : function() {
    return this.textureDimensions;
    },
    u_texture : function() {
    return this.texture;
    },
    u_northLatitude : function() {
    return this.northLatitude;
    },
    u_southLatitude : function() {
    return this.southLatitude;
    },
    u_southMercatorYLow : function() {
    return this.southMercatorYLow;
    },
    u_southMercatorYHigh : function() {
    return this.southMercatorYHigh;
    },
    u_oneOverMercatorHeight : function() {
    return this.oneOverMercatorHeight;
    },
    
    textureDimensions : new Cartesian2(),
    texture : undefined,
    northLatitude : 0,
    southLatitude : 0,
    southMercatorYHigh : 0,
    southMercatorYLow : 0,
    oneOverMercatorHeight : 0
    };
    
    var float32ArrayScratch = FeatureDetection.supportsTypedArrays() ? new Float32Array(1) : undefined;
    */
    func reprojectToGeographic(context: Context, texture: Texture, rectangle: Rectangle) -> Texture {
        // FIXME: reproject
        return texture
    /*var reproject = context.cache.imageryLayer_reproject;
    
    if (!defined(reproject)) {
    reproject = context.cache.imageryLayer_reproject = {
    framebuffer : undefined,
    vertexArray : undefined,
    shaderProgram : undefined,
    renderState : undefined,
    sampler : undefined,
    destroy : function() {
    if (defined(this.framebuffer)) {
    this.framebuffer.destroy();
    }
    if (defined(this.vertexArray)) {
    this.vertexArray.destroy();
    }
    if (defined(this.shaderProgram)) {
    this.shaderProgram.destroy();
    }
    }
    };
    
    // We need a vertex array with close to one vertex per output texel because we're doing
    // the reprojection by computing texture coordinates in the vertex shader.
    // If we computed Web Mercator texture coordinate per-fragment instead, we could get away with only
    // four vertices.  Problem is: fragment shaders have limited precision on many mobile devices,
    // leading to all kinds of smearing artifacts.  Current browsers (Chrome 26 for example)
    // do not correctly report the available fragment shader precision, so we can't have different
    // paths for devices with or without high precision fragment shaders, even if we want to.
    
    var positions = new Array(256 * 256 * 2);
    var index = 0;
    for (var j = 0; j < 256; ++j) {
    var y = j / 255.0;
    for (var i = 0; i < 256; ++i) {
    var x = i / 255.0;
    positions[index++] = x;
    positions[index++] = y;
    }
    }
    
    var reprojectGeometry = new Geometry({
    attributes : {
    position : new GeometryAttribute({
    componentDatatype : ComponentDatatype.FLOAT,
    componentsPerAttribute : 2,
    values : positions
    })
    },
    indices : TerrainProvider.getRegularGridIndices(256, 256),
    primitiveType : PrimitiveType.TRIANGLES
    });
    
    var reprojectAttribInds = {
    position : 0
    };
    
    reproject.vertexArray = context.createVertexArrayFromGeometry({
    geometry : reprojectGeometry,
    attributeLocations : reprojectAttribInds,
    bufferUsage : BufferUsage.STATIC_DRAW
    });
    
    reproject.shaderProgram = context.createShaderProgram(
    ReprojectWebMercatorVS,
    ReprojectWebMercatorFS,
    reprojectAttribInds);
    
    var maximumSupportedAnisotropy = context.maximumTextureFilterAnisotropy;
    reproject.sampler = context.createSampler({
    wrapS : TextureWrap.CLAMP_TO_EDGE,
    wrapT : TextureWrap.CLAMP_TO_EDGE,
    minificationFilter : TextureMinificationFilter.LINEAR,
    magnificationFilter : TextureMagnificationFilter.LINEAR,
    maximumAnisotropy : Math.min(maximumSupportedAnisotropy, defaultValue(imageryLayer._maximumAnisotropy, maximumSupportedAnisotropy))
    });
    }
    
    texture.sampler = reproject.sampler;
    
    var width = texture.width;
    var height = texture.height;
    
    uniformMap.textureDimensions.x = width;
    uniformMap.textureDimensions.y = height;
    uniformMap.texture = texture;
    
    uniformMap.northLatitude = rectangle.north;
    uniformMap.southLatitude = rectangle.south;
    
    var sinLatitude = Math.sin(rectangle.south);
    var southMercatorY = 0.5 * Math.log((1 + sinLatitude) / (1 - sinLatitude));
    
    float32ArrayScratch[0] = southMercatorY;
    uniformMap.southMercatorYHigh = float32ArrayScratch[0];
    uniformMap.southMercatorYLow = southMercatorY - float32ArrayScratch[0];
    
    sinLatitude = Math.sin(rectangle.north);
    var northMercatorY = 0.5 * Math.log((1 + sinLatitude) / (1 - sinLatitude));
    uniformMap.oneOverMercatorHeight = 1.0 / (northMercatorY - southMercatorY);
    
    var outputTexture = context.createTexture2D({
    width : width,
    height : height,
    pixelFormat : texture.pixelFormat,
    pixelDatatype : texture.pixelDatatype,
    preMultiplyAlpha : texture.preMultiplyAlpha
    })
    
    // Allocate memory for the mipmaps.  Failure to do this before rendering
    // to the texture via the FBO, and calling generateMipmap later,
    // will result in the texture appearing blank.  I can't pretend to
    // understand exactly why this is.
    outputTexture.generateMipmap(MipmapHint.NICEST);
    
    if (defined(reproject.framebuffer)) {
    reproject.framebuffer.destroy();
    }
    
    reproject.framebuffer = context.createFramebuffer({
    colorTextures : [outputTexture]
    });
    reproject.framebuffer.destroyAttachments = false;
    
    var command = new ClearCommand({
    color : Color.BLACK,
    framebuffer : reproject.framebuffer
    });
    command.execute(context);
    
    if ((!defined(reproject.renderState)) ||
    (reproject.renderState.viewport.width !== width) ||
    (reproject.renderState.viewport.height !== height)) {
    
    reproject.renderState = context.createRenderState({
    viewport : new BoundingRectangle(0, 0, width, height)
    });
    }
    
    var drawCommand = new DrawCommand({
    framebuffer : reproject.framebuffer,
    shaderProgram : reproject.shaderProgram,
    renderState : reproject.renderState,
    primitiveType : PrimitiveType.TRIANGLES,
    vertexArray : reproject.vertexArray,
    uniformMap : uniformMap
    });
    drawCommand.execute(context);
    
    return outputTexture;*/
    }

    /**
    * Gets the level with the specified world coordinate spacing between texels, or less.
    *
    * @param {Number} texelSpacing The texel spacing for which to find a corresponding level.
    * @param {Number} latitudeClosestToEquator The latitude closest to the equator that we're concerned with.
    * @returns {Number} The level with the specified texel spacing or less.
    */
    func levelWithMaximumTexelSpacing(#texelSpacing: Double, latitudeClosestToEquator: Double) -> Int {
        // PERFORMANCE_IDEA: factor out the stuff that doesn't change.
        let tilingScheme = imageryProvider.tilingScheme
        let ellipsoid = tilingScheme.ellipsoid
        let latitudeFactor = !(tilingScheme is GeographicTilingScheme) ? cos(latitudeClosestToEquator) : 1.0
        let tilingSchemeRectangle = tilingScheme.rectangle
        let levelZeroMaximumTexelSpacing = ellipsoid.maximumRadius * (tilingSchemeRectangle.east - tilingSchemeRectangle.west) * latitudeFactor / Double(imageryProvider.tileWidth * tilingScheme.numberOfXTilesAtLevel(0))
        
        let twoToTheLevelPower = levelZeroMaximumTexelSpacing / texelSpacing;
        let level = log(twoToTheLevelPower) / log(2)
        let rounded = Int(round(level))
        return rounded | 0
    }
    
}