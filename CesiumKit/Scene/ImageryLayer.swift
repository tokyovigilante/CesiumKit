//
//  ImageryLayer.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import Metal

/**
* An imagery layer that displays tiled image data from a single imagery provider
* on a {@link Globe}.
*
* @alias ImageryLayer
* @constructor
*
* @param {ImageryProvider} imageryProvider The imagery provider to use.
*/
public class ImageryLayer {
    
    /**
    * This value is used as the default brightness for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the brightness of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let defaultBrightness: Float = 1.0
    
    /**
    * This value is used as the default contrast for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the contrast of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let defaultContrast: Float = 1.0
    
    /**
    * This value is used as the default hue for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the hue of the imagery.
    * @type {Number}
    * @default 0.0
    */
    let defaultHue: Float = 0.0
    
    /**
    * This value is used as the default saturation for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the saturation of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let defaultSaturation: Float = 1.0
    
    /**
    * This value is used as the default gamma for the imagery layer if one is not provided during construction
    * or by the imagery provider. This value does not modify the gamma of the imagery.
    * @type {Number}
    * @default 1.0
    */
    let defaultGamma: Float = 1.0
    
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
    let alpha: (() -> Float)
    
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
    let brightness: (() -> Float)
    
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
    let contrast: (() -> Float)
    
    /*
    * @param {Number|Function} [options.hue=0.0] The hue of this layer.  0.0 uses the unmodified imagery color.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates
    *                          of the imagery tile for which the hue is required, and it is expected to return
    *                          the contrast value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let hue: (() -> Float)
    
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
    let saturation: (() -> Float)
    
    /**
    * @param {Number|Function} [options.gamma=1.0] The gamma correction to apply to this layer.  1.0 uses the unmodified imagery color.
    *                          This can either be a simple number or a function with the signature
    *                          <code>function(frameState, layer, x, y, level)</code>.  The function is passed the
    *                          current frame state, this layer, and the x, y, and level coordinates of the
    *                          imagery tile for which the gamma is required, and it is expected to return
    *                          the gamma value to use for the tile.  The function is executed for every
    *                          frame and for every tile, so it must be fast.
    */
    let gamma: (() -> Float)
    
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
    
    /**
    * Uniform map for texture reprojection
    */
    private var uniformMap = ImageryLayerUniformMap()
    
    init (
        imageryProvider: ImageryProvider,
        rectangle: Rectangle = Rectangle.maxValue(),
        alpha: (() -> Float) = { return 1.0 },
        brightness: (() -> Float) = { return 1.0 },
        contrast: (() -> Float) = { return 1.0 },
        hue: (() -> Float) = { return 0.0 },
        saturation: (() -> Float) = { return 1.0 },
        gamma: (() -> Float) = { return 1.0 },
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
    * @param {Number} insertionPoint The position to insert new skeletons before in the tile's imagery list.
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
        let imageryBounds = imageryProvider.rectangle.intersection(_rectangle)
        var overlapRectangle = tile.rectangle.intersection(imageryBounds!)

        var rectangle = Rectangle(west: 0.0, south: 0.0, east: 0.0, north:0.0)
        
        if overlapRectangle != nil {
            rectangle = overlapRectangle!
        } else {
            // There is no overlap between this terrain tile and this imagery
            // provider.  Unless this is the base layer, no skeletons need to be created.
            // We stretch texels at the edge of the base layer over the entire globe.
            if !isBaseLayer {
                return false
            }
            
            let baseImageryRectangle = imageryBounds!
            let baseTerrainRectangle = tile.rectangle
            overlapRectangle = Rectangle(west: 0.0, south: 0.0, east: 0.0, north:0.0)
            
            if baseTerrainRectangle.south >= baseImageryRectangle.north {
                overlapRectangle!.south = baseImageryRectangle.north
                overlapRectangle!.north = overlapRectangle!.south
            } else if baseTerrainRectangle.north <= baseImageryRectangle.south {
                overlapRectangle!.south = baseImageryRectangle.south
                overlapRectangle!.north = overlapRectangle!.south
            } else {
                rectangle.south = max(baseTerrainRectangle.south, baseImageryRectangle.south)
                rectangle.north = min(baseTerrainRectangle.north, baseImageryRectangle.north)
            }
            
            if baseTerrainRectangle.west >= baseImageryRectangle.east {
                overlapRectangle!.east = baseImageryRectangle.east
                overlapRectangle!.west = overlapRectangle!.east
            } else if baseTerrainRectangle.east <= baseImageryRectangle.west {
                overlapRectangle!.east = baseImageryRectangle.west
                overlapRectangle!.west = overlapRectangle!.east
            } else {
                rectangle.west = max(baseTerrainRectangle.west, baseImageryRectangle.west)
                rectangle.east = min(baseTerrainRectangle.east, baseImageryRectangle.east)
            }
            rectangle = overlapRectangle!
            //Rectangle(west: overlapRectangle!.west, south: overlapRectangle!.south, east: overlapRectangle!.east, north: overlapRectangle!.north)

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
        let maximumLevel = imageryProvider.maximumLevel
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
        let veryCloseX = tile.rectangle.height / 512.0
        let veryCloseY = tile.rectangle.width / 512.0
        
        let northwestTileRectangle = imageryTilingScheme.tileXYToRectangle(x: northwestTileCoordinates.x, y: northwestTileCoordinates.y, level: imageryLevel)
        if (abs(northwestTileRectangle.south - tile.rectangle.north) < veryCloseY && northwestTileCoordinates.y < southeastTileCoordinates.y) {
            ++northwestTileCoordinates.y
        }
        if (abs(northwestTileRectangle.east - tile.rectangle.west) < veryCloseX && northwestTileCoordinates.x < southeastTileCoordinates.x) {
            ++northwestTileCoordinates.x
        }
        
        let southeastTileRectangle = imageryTilingScheme.tileXYToRectangle(x: southeastTileCoordinates.x, y: southeastTileCoordinates.y, level: imageryLevel)
        if (abs(southeastTileRectangle.north - tile.rectangle.south) < veryCloseY && southeastTileCoordinates.y > northwestTileCoordinates.y) {
            --southeastTileCoordinates.y
        }
        if (abs(southeastTileRectangle.west - tile.rectangle.east) < veryCloseX && southeastTileCoordinates.x > northwestTileCoordinates.x) {
            --southeastTileCoordinates.x
        }
        
        // Create TileImagery instances for each imagery tile overlapping this terrain tile.
        // We need to do all texture coordinate computations in the imagery tile's tiling scheme.
        let terrainRectangle = tile.rectangle
        var imageryRectangle = imageryTilingScheme.tileXYToRectangle(x: northwestTileCoordinates.x, y: northwestTileCoordinates.y, level: imageryLevel)
        var clippedImageryRectangle = imageryRectangle.intersection(imageryBounds!)!
        
        var minU: Double
        var maxU = 0.0
        
        var minV = 1.0
        var maxV: Double
        
        // If this is the northern-most or western-most tile in the imagery tiling scheme,
        // it may not start at the northern or western edge of the terrain tile.
        // Calculate where it does start.
        if !isBaseLayer && abs(clippedImageryRectangle.west - tile.rectangle.west) >= veryCloseX {
            maxU = min(1.0, (clippedImageryRectangle.west - terrainRectangle.west) / terrainRectangle.width)
        }
        
        if (isBaseLayer && abs(clippedImageryRectangle.north - tile.rectangle.north) >= veryCloseY) {
            minV = max(0.0, (imageryRectangle.north - terrainRectangle.south) / terrainRectangle.height)
        }
        
        let initialMinV = minV
        
        for i in northwestTileCoordinates.x...southeastTileCoordinates.x {
            minU = maxU
            
            imageryRectangle = imageryTilingScheme.tileXYToRectangle(x: i, y: northwestTileCoordinates.y, level: imageryLevel)
            clippedImageryRectangle = imageryRectangle.intersection(imageryBounds!)!

            maxU = min(1.0, (clippedImageryRectangle.east - terrainRectangle.west) / terrainRectangle.width)
            
            // If this is the eastern-most imagery tile mapped to this terrain tile,
            // and there are more imagery tiles to the east of this one, the maxU
            // should be 1.0 to make sure rounding errors don't make the last
            // image fall shy of the edge of the terrain tile.
            if i == southeastTileCoordinates.x && (isBaseLayer || abs(clippedImageryRectangle.east - tile.rectangle.east) < veryCloseX) {
                maxU = 1.0
            }
            
            minV = initialMinV
            
            for j in northwestTileCoordinates.y...southeastTileCoordinates.y {
                maxV = minV
                
                imageryRectangle = imageryTilingScheme.tileXYToRectangle(x: i, y: j, level: imageryLevel)
                clippedImageryRectangle = imageryRectangle.intersection(imageryBounds!)!

                minV = max(0.0, (clippedImageryRectangle.south - terrainRectangle.south) / terrainRectangle.height)
                
                // If this is the southern-most imagery tile mapped to this terrain tile,
                // and there are more imagery tiles to the south of this one, the minV
                // should be 0.0 to make sure rounding errors don't make the last
                // image fall shy of the edge of the terrain tile.
                if j == southeastTileCoordinates.y && (isBaseLayer || abs(clippedImageryRectangle.south - tile.rectangle.south) < veryCloseY) {
                    minV = 0.0
                }
                
                let texCoordsRectangle = Cartesian4(x: minU, y: minV, z: maxU, w: maxV)
                let imagery = getImageryFromCache(level: imageryLevel, x: i, y: j, imageryRectangle: imageryRectangle)
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
        let terrainWidth = terrainRectangle.width
        let terrainHeight = terrainRectangle.height
        
        let scaleX = terrainWidth / imageryRectangle.width
        let scaleY = terrainHeight / imageryRectangle.height
        
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
    func requestImagery (context: Context, imagery: Imagery) {
        
        imagery.state = .Transitioning

        
        dispatch_async(context.networkQueue, {
            
            dispatch_semaphore_wait(context.networkSemaphore, DISPATCH_TIME_FOREVER)

            let completionBlock: (CGImageRef? -> Void) = { (image) in
                
                dispatch_semaphore_signal(context.networkSemaphore)
                if let image = image {
                    dispatch_async(dispatch_get_main_queue(), {
                        //dispatch_async(context.renderQueue, {
                        imagery.image = image
                        imagery.credits = self.imageryProvider.tileCredits(x: imagery.x, y: imagery.y, level: imagery.level)
                        
                        imagery.state = .Received
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        //dispatch_async(context.renderQueue, {
                        imagery.state = .Failed
                        
                        let message = "Failed to obtain image tile X: \(imagery.x) Y: \(imagery.y) Level: \(imagery.level)"
                        print(message)
                    })
                }
                
            }
            self.imageryProvider.requestImage(x: imagery.x, y: imagery.y, level: imagery.level, completionBlock: completionBlock)
        })
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
        dispatch_async(context.textureLoadQueue, {
            
            // If this imagery provider has a discard policy, use it to check if this
            // image should be discarded.
            if let discardPolicy = self.imageryProvider.tileDiscardPolicy {
                // If the discard policy is not ready yet, transition back to the
                // RECEIVED state and we'll try again next time.
                if !discardPolicy.isReady {
                    dispatch_async(dispatch_get_main_queue(), {
                        imagery.state = .Received
                    })
                    return
                }
                
                // Mark discarded imagery tiles invalid.  Parent imagery will be used instead.
                if (discardPolicy.shouldDiscardImage(imagery.image!)) {
                    dispatch_async(dispatch_get_main_queue(), {
                        imagery.state = .Invalid
                    })
                    return
                }
            }
            // Imagery does not need to be discarded, so upload it to GL.
            let texture = Texture(context: context, options: TextureOptions(
                source : .Image(imagery.image!))
            )

            //println("created texture \(texture.textureName) for L\(imagery.level)X\(imagery.x)Y\(imagery.y)")
            dispatch_async(dispatch_get_main_queue(), {
            //dispatch_async(context.renderQueue, {
                imagery.texture = texture
                imagery.image = nil
                imagery.state = ImageryState.TextureLoaded
            })
        })
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
        dispatch_async(context.textureLoadQueue, {
            var texture = imagery.texture!
            let rectangle = imagery.rectangle!
            
            // Reproject this texture if it is not already in a geographic projection and
            // the pixels are more than 1e-5 radians apart.  The pixel spacing cutoff
            // avoids precision problems in the reprojection transformation while making
            // no noticeable difference in the georeferencing of the image.
            let pixelGap: Bool = rectangle.width / Double(texture.width) > pow(10, -5)
            let isGeographic = self.imageryProvider.tilingScheme is GeographicTilingScheme
            if false { // !isGeographic && pixelGap {
                let reprojectCommand = self.reprojectToGeographic(context, texture: texture, rectangle: imagery.rectangle!)
                /*dispatch_async(dispatch_get_main_queue(),  {
                should be completion block for command buffer
                    texture = reprojectedTexture
                    imagery.texture = texture
                    imagery.state = .Reprojected
                })*/
            } else {
                dispatch_async(dispatch_get_main_queue(),  {
                    imagery.state = .Reprojected
                })
            }
        })
    }
    
    func generateMipmaps (context: Context, imagery: Imagery) {
        // Use mipmaps if this texture has power-of-two dimensions.
        dispatch_async(context.textureLoadQueue, {
            let texture = imagery.texture!
            if false { //Math.isPowerOfTwo(texture.width) && Math.isPowerOfTwo(texture.height) {
                var mipmapSampler = context.cache["imageryLayer_mipmapSampler"] as! Sampler?
                if mipmapSampler == nil {
                    mipmapSampler = Sampler(context: context, mipMagFilter: .Linear, maximumAnisotropy: context.limits.maximumTextureFilterAnisotropy)
                }
                // FIXME: Mipmaps
                context.cache["imageryLayer_mipmapSampler"] = mipmapSampler
            } else {
                var nonMipmapSampler = context.cache["imageryLayer_nonMipmapSampler"] as! Sampler?
                if nonMipmapSampler == nil {
                    nonMipmapSampler = Sampler(context: context)
                    context.cache["imageryLayer_nonMipmapSampler"] = nonMipmapSampler!
                }
                texture.sampler = nonMipmapSampler!
            }
            dispatch_async(dispatch_get_main_queue(), {
                // dispatch_async(context.renderQueue, {
                imagery.state = .Ready
            })
        })
    }
    
    func getImageryFromCache (level level: Int, x: Int, y: Int, imageryRectangle: Rectangle? = nil) -> Imagery {
        let cacheKey = getImageryCacheKey(level: level, x: x, y: y)
        var imagery = _imageryCache[cacheKey]
        
        if imagery == nil {
            imagery = Imagery(imageryLayer: self, level: level, x: x, y: y, rectangle: imageryRectangle)
            _imageryCache[cacheKey] = imagery
        }
        
        imagery!.addReference()
        return imagery!
    }
    
    func removeImageryFromCache (imagery: Imagery) {
        let cacheKey = getImageryCacheKey(level: imagery.level, x: imagery.x, y: imagery.y)
        _imageryCache.removeValueForKey(cacheKey)
    }
    
    private func getImageryCacheKey(level level: Int, x: Int, y: Int) -> String {
        return "level\(level)x\(x)y\(y)"
    }
    
    class Reproject {
        //var framebuffer: Framebuffer? = nil
        var renderPassDescriptor: MTLRenderPassDescriptor
        let vertexArray: VertexArray
        let pipeline: RenderPipeline
        var renderState: RenderState? = nil
        let sampler: Sampler
        
        init (vertexArray: VertexArray, pipeline: RenderPipeline, renderPassDescriptor: MTLRenderPassDescriptor, sampler: Sampler) {
            self.vertexArray = vertexArray
            self.pipeline = pipeline
            self.renderPassDescriptor = renderPassDescriptor
            self.sampler = sampler
        }
        
        deinit {
            // FIXME: destroy
            //if framebuffer != nil {
                //this.framebuffer.destroy()
            //}
            //this.vertexArray.destroy();
            //shaderProgram.destroy();
        }
    }
    
    func reprojectToGeographic(context: Context, texture: Texture, rectangle: Rectangle) -> DrawCommand {
        
        // This function has gone through a number of iterations, because GPUs are awesome.
        //
        // Originally, we had a very simple vertex shader and computed the Web Mercator texture coordinates
        // per-fragment in the fragment shader.  That worked well, except on mobile devices, because
        // fragment shaders have limited precision on many mobile devices.  The result was smearing artifacts
        // at medium zoom levels because different geographic texture coordinates would be reprojected to Web
        // Mercator as the same value.
        //
        // Our solution was to reproject to Web Mercator in the vertex shader instead of the fragment shader.
        // This required far more vertex data.  With fragment shader reprojection, we only needed a single quad.
        // But to achieve the same precision with vertex shader reprojection, we needed a vertex for each
        // output pixel.  So we used a grid of 256x256 vertices, because most of our imagery
        // tiles are 256x256.  Fortunately the grid could be created and uploaded to the GPU just once and
        // re-used for all reprojections, so the performance was virtually unchanged from our original fragment
        // shader approach.  See https://github.com/AnalyticalGraphicsInc/cesium/pull/714.
        //
        // Over a year later, we noticed (https://github.com/AnalyticalGraphicsInc/cesium/issues/2110)
        // that our reprojection code was creating a rare but severe artifact on some GPUs (Intel HD 4600
        // for one).  The problem was that the GLSL sin function on these GPUs had a discontinuity at fine scales in
        // a few places.
        //
        // We solved this by implementing a more reliable sin function based on the CORDIC algorithm
        // (https://github.com/AnalyticalGraphicsInc/cesium/pull/2111).  Even though this was a fair
        // amount of code to be executing per vertex, the performance seemed to be pretty good on most GPUs.
        // Unfortunately, on some GPUs, the performance was absolutely terrible
        // (https://github.com/AnalyticalGraphicsInc/cesium/issues/2258).
        //
        // So that brings us to our current solution, the one you see here.  Effectively, we compute the Web
        // Mercator texture coordinates on the CPU and store the T coordinate with each vertex (the S coordinate
        // is the same in Geographic and Web Mercator).  To make this faster, we reduced our reprojection mesh
        // to be only 2 vertices wide and 64 vertices high.  We should have reduced the width to 2 sooner,
        // because the extra vertices weren't buying us anything.  The height of 64 means we are technically
        // doing a slightly less accurate reprojection than we were before, but we can't see the difference
        // so it's worth the 4x speedup.
        
        var reproject = context.cache["imageryLayer_reproject"] as! Reproject!
        
        if reproject == nil {
            
            // We need a vertex array with close to one vertex per output texel because we're doing
            // the reprojection by computing texture coordinates in the vertex shader.
            // If we computed Web Mercator texture coordinate per-fragment instead, we could get away with only
            // four vertices.  Problem is: fragment shaders have limited precision on many mobile devices,
            // leading to all kinds of smearing artifacts.  Current browsers (Chrome 26 for example)
            // do not correctly report the available fragment shader precision, so we can't have different
            // paths for devices with or without high precision fragment shaders, even if we want to.
            
            var positions = [Float32](count: 2*64*2, repeatedValue: 0.0)
            let position0: Float = 0.0
            let position1: Float = 1.0
            
            var index = 0
            for j in 0..<64 {
                let y = Float(j) / 63.0
                positions.append(position0)
                positions.append(y)
                positions.append(position1)
                positions.append(y)
            }
            
            let vertexBuffer = Buffer(device: context.device, array: positions, componentDatatype: .Float32, sizeInBytes: positions.sizeInBytes)
            let webMercatorTBuffer = Buffer(device: context.device, componentDatatype: .Float32, sizeInBytes: 64 * 2 * 4)
            
            let indices = EllipsoidTerrainProvider.getRegularGridIndices(width: 2, height: 64).map({ UInt16($0) })

            let indexBuffer = Buffer(device: context.device, array: indices, componentDatatype: .UnsignedShort, sizeInBytes: indices.sizeInBytes)
            
            let vertexAttributes = [
                //position
                VertexAttributes(
                    bufferIndex: 1,
                    index: 0,
                    format: .Float4,
                    offset: 0,
                    size: sizeof(Float) * 4),
                // webMercatorT
                VertexAttributes(
                    bufferIndex: 2,
                    index: 1,
                    format: .Float2,
                    offset: 0,
                    size: sizeof(Float) * 2)
            ]
            let vertexDescriptor = VertexDescriptor(attributes: vertexAttributes)
            
            let vertexArray = VertexArray(buffers: [vertexBuffer, webMercatorTBuffer], attributes: vertexAttributes, vertexCount: positions.count, indexBuffer: indexBuffer)
            
            let pipeline = context.pipelineCache.getRenderPipeline(
                vertexShaderSource: ShaderSource(sources: [Shaders["ReprojectWebMercatorVS"]!]),
                fragmentShaderSource: ShaderSource(sources: [Shaders["ReprojectWebMercatorFS"]!]),
                vertexDescriptor: vertexDescriptor
            )

            let maximumSupportedAnisotropy = context.limits.maximumTextureFilterAnisotropy
            let sampler = Sampler(context: context, maximumAnisotropy: min(maximumSupportedAnisotropy, maximumAnisotropy ?? maximumSupportedAnisotropy))
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].loadAction = .DontCare
            renderPassDescriptor.colorAttachments[0].storeAction = .Store
            
            reproject = Reproject(
                vertexArray: vertexArray,
                pipeline: pipeline,
                renderPassDescriptor: renderPassDescriptor,
                sampler: sampler)
            
            context.cache["imageryLayer_reproject"] = reproject
        }
        
        texture.sampler = reproject!.sampler
        
        let width = texture.width
        let height = texture.height
        
        uniformMap.textureDimensions = [Float(width), Float(height)]
        uniformMap.texture = texture
        
        var sinLatitude = sin(rectangle.south)
        let southMercatorY = 0.5 * log((1 + sinLatitude) / (1 - sinLatitude))
        
        sinLatitude = sin(rectangle.north)
        let northMercatorY = 0.5 * log((1 + sinLatitude) / (1 - sinLatitude))
        let oneOverMercatorHeight = 1.0 / (northMercatorY - southMercatorY)
        
        let outputTexture = Texture(
            context: context,
            options: TextureOptions(
                width: width,
                height: height,
                pixelFormat: texture.pixelFormat,
                premultiplyAlpha: texture.premultiplyAlpha
            )
        )
        reproject.renderPassDescriptor.colorAttachments[0].texture = outputTexture.metalTexture

        let south = rectangle.south
        let north = rectangle.north
        
        var webMercatorT = [Float]()
        
        //var outputIndex = 0;
        for webMercatorTIndex in 0..<64 {
            let fraction = Double(webMercatorTIndex) / 63.0
            let latitude = Math.lerp(p: south, q: north, time: fraction)
            sinLatitude = sin(latitude)
            let mercatorY = 0.5 * log((1.0 + sinLatitude) / (1.0 - sinLatitude))
            let mercatorFraction = Float((mercatorY - southMercatorY) * oneOverMercatorHeight)
            webMercatorT.append(mercatorFraction)
            webMercatorT.append(mercatorFraction)
        }
        
        let webMercatorTBuffer = Buffer(device: context.device, array: webMercatorT, componentDatatype: .Float32, sizeInBytes: webMercatorT.sizeInBytes)
        
        if reproject.renderState == nil {
            reproject.renderState = RenderState(viewport: BoundingRectangle(x: 0.0, y: 0.0, width: Double(width), height: Double(height)))
        }
        
        /*if reproject!.renderState!.viewport == nil ||
        reproject!.renderState!.viewport!.width != width ||
        reproject!.renderState!.viewport!.height != height {*/
        //  reproject!.renderState!.viewport = BoundingRectangle(x: 0.0, y: 0.0, width: Double(width), height: Double(height))
        //}
        
        let drawCommand = DrawCommand(
            //framebuffer: reproject!.framebuffer,
            //pipeline: reproject!.pipeline,
            renderState: reproject!.renderState,
            vertexArray: reproject!.vertexArray,
            uniformMap: uniformMap
        )
        drawCommand.pipeline = reproject.pipeline
        //drawCommand.execute(context: context, pass: )
        //return outputTexture
        return drawCommand
    }
    
    /**
    * Gets the level with the specified world coordinate spacing between texels, or less.
    *
    * @param {Number} texelSpacing The texel spacing for which to find a corresponding level.
    * @param {Number} latitudeClosestToEquator The latitude closest to the equator that we're concerned with.
    * @returns {Number} The level with the specified texel spacing or less.
    */
    func levelWithMaximumTexelSpacing(texelSpacing texelSpacing: Double, latitudeClosestToEquator: Double) -> Int {
        // PERFORMANCE_IDEA: factor out the stuff that doesn't change.
        let tilingScheme = imageryProvider.tilingScheme
        let latitudeFactor = !(tilingScheme is GeographicTilingScheme) ? cos(latitudeClosestToEquator) : 1.0
        
        let levelZeroMaximumTexelSpacing = tilingScheme.ellipsoid.maximumRadius * tilingScheme.rectangle.width * latitudeFactor / Double(imageryProvider.tileWidth * tilingScheme.numberOfXTilesAtLevel(0))
        
        let twoToTheLevelPower = levelZeroMaximumTexelSpacing / texelSpacing;
        let level = log(twoToTheLevelPower) / log(2)
        let rounded = Int(round(level))
        return rounded | 0
    }
    
}