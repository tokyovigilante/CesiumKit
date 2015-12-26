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
            northwestTileCoordinates.y += 1
        }
        if (abs(northwestTileRectangle.east - tile.rectangle.west) < veryCloseX && northwestTileCoordinates.x < southeastTileCoordinates.x) {
            northwestTileCoordinates.x += 1
        }
        
        let southeastTileRectangle = imageryTilingScheme.tileXYToRectangle(x: southeastTileCoordinates.x, y: southeastTileCoordinates.y, level: imageryLevel)
        if (abs(southeastTileRectangle.north - tile.rectangle.south) < veryCloseY && southeastTileCoordinates.y > northwestTileCoordinates.y) {
            southeastTileCoordinates.y -= 1
        }
        if (abs(southeastTileRectangle.west - tile.rectangle.east) < veryCloseX && southeastTileCoordinates.x > northwestTileCoordinates.x) {
            southeastTileCoordinates.x -= 1
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
        
        if (!isBaseLayer && abs(clippedImageryRectangle.north - tile.rectangle.north) >= veryCloseY) {
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
                insertionPoint! += 1
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
    func requestImagery (frameState frameState: FrameState, imagery: Imagery) {
        
        let context = frameState.context

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
    func createTexture (frameState frameState: FrameState, imagery: Imagery) {
        
        let context = frameState.context
        
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
                source : .Image(imagery.image!),
                pixelFormat: .RGBA8Unorm,
                flipY: true, // CGImage
                usage: .ShaderRead
                )
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
     * @param {FrameState} frameState The frameState.
     * @param {Imagery} imagery The imagery instance to reproject.
     */
    func reprojectTexture (inout frameState frameState: FrameState, imagery: Imagery) {
        
        let texture = imagery.texture!
        let rectangle = imagery.rectangle!
        let context = frameState.context
        
        // Reproject this texture if it is not already in a geographic projection and
        // the pixels are more than 1e-5 radians apart.  The pixel spacing cutoff
        // avoids precision problems in the reprojection transformation while making
        // no noticeable difference in the georeferencing of the image.
        let pixelGap: Bool = rectangle.width / Double(texture.width) > pow(10, -5)
        let isGeographic = self.imageryProvider.tilingScheme is GeographicTilingScheme
        if !isGeographic && pixelGap {
            let computeCommand = ComputeCommand(
                // Update render resources right before execution instead of now.
                // This allows different ImageryLayers to share the same vao and buffers.
                preExecute: { command in
                    self.reprojectToGeographic(command, context: context, texture: texture, rectangle: rectangle)
                },
                postExecute: { outputTexture in
                    imagery.texture = outputTexture
                    self.finalizeReprojectTexture(context, imagery: imagery, texture: outputTexture)
                },
                persists: true,
                owner : self
            )
            frameState.commandList.append(computeCommand)
        } else {
            finalizeReprojectTexture(context, imagery: imagery, texture: texture)
        }
        
    }
    func finalizeReprojectTexture(context: Context, imagery: Imagery, texture: Texture) {
        /*
        // Use mipmaps if this texture has power-of-two dimensions.
        if (CesiumMath.isPowerOfTwo(texture.width) && CesiumMath.isPowerOfTwo(texture.height)) {
        var mipmapSampler = context.cache.imageryLayer_mipmapSampler;
        if (!defined(mipmapSampler)) {
        var maximumSupportedAnisotropy = ContextLimits.maximumTextureFilterAnisotropy;
        mipmapSampler = context.cache.imageryLayer_mipmapSampler = new Sampler({
        wrapS : TextureWrap.CLAMP_TO_EDGE,
        wrapT : TextureWrap.CLAMP_TO_EDGE,
        minificationFilter : TextureMinificationFilter.LINEAR_MIPMAP_LINEAR,
        magnificationFilter : TextureMagnificationFilter.LINEAR,
        maximumAnisotropy : Math.min(maximumSupportedAnisotropy, defaultValue(imageryLayer._maximumAnisotropy, maximumSupportedAnisotropy))
        });
        }
        texture.generateMipmap(MipmapHint.NICEST);
        texture.sampler = mipmapSampler;
        } else {
        var nonMipmapSampler = context.cache.imageryLayer_nonMipmapSampler;
        if (!defined(nonMipmapSampler)) {
        nonMipmapSampler = context.cache.imageryLayer_nonMipmapSampler = new Sampler({
        wrapS : TextureWrap.CLAMP_TO_EDGE,
        wrapT : TextureWrap.CLAMP_TO_EDGE,
        minificationFilter : TextureMinificationFilter.LINEAR,
        magnificationFilter : TextureMagnificationFilter.LINEAR
        });
        }
        texture.sampler = nonMipmapSampler;
        }
        
        imagery.state = ImageryState.READY;*/
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
    }
    
    func generateMipmaps (inout frameState frameState: FrameState, imagery: Imagery) {
        
        let context = frameState.context
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
        let vertexBuffer: Buffer
        let vertexAttributes: [VertexAttributes]
        let pipeline: RenderPipeline
        let sampler: Sampler
        let indexBuffer: Buffer
        
        init (vertexBuffer: Buffer, vertexAttributes: [VertexAttributes], pipeline: RenderPipeline, sampler: Sampler, indexBuffer: Buffer) {
            self.vertexBuffer = vertexBuffer
            self.vertexAttributes = vertexAttributes
            self.pipeline = pipeline
            self.sampler = sampler
            self.indexBuffer = indexBuffer
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
    
    func reprojectToGeographic(command: ComputeCommand, context: Context, texture: Texture, rectangle: Rectangle) {
        
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
            
            var positions = [Float32]()//count: 2*64*2, repeatedValue: 0.0)
            let position0: Float = 0.0
            let position1: Float = 1.0
            
            for j in 0..<64 {
                let y = 1 - Float(j) / 63.0
                positions.append(position0)
                positions.append(y)
                positions.append(position1)
                positions.append(y)
            }
            
            let vertexBuffer = Buffer(device: context.device, array: positions, componentDatatype: .Float32, sizeInBytes: positions.sizeInBytes)
            
            let indices = EllipsoidTerrainProvider.getRegularGridIndices(width: 2, height: 64).map({ UInt16($0) })
            
            let indexBuffer = Buffer(device: context.device, array: indices, componentDatatype: .UnsignedShort, sizeInBytes: indices.sizeInBytes)
            
            let vertexAttributes = [
                //position
                VertexAttributes(
                    buffer: vertexBuffer,
                    bufferIndex: 1,
                    index: 0,
                    format: .Float2,
                    offset: 0,
                    size: sizeof(Float) * 2,
                    normalize: false
                ),
                // webMercatorT
                VertexAttributes(
                    buffer: nil,
                    bufferIndex: 2,
                    index: 1,
                    format: .Float,
                    offset: 0,
                    size: sizeof(Float),
                    normalize: false
                )
            ]
            let vertexDescriptor = VertexDescriptor(attributes: vertexAttributes)
            
            let pipeline = context.pipelineCache.getRenderPipeline(
                vertexShaderSource: ShaderSource(sources: [Shaders["ReprojectWebMercatorVS"]!]),
                fragmentShaderSource: ShaderSource(sources: [Shaders["ReprojectWebMercatorFS"]!]),
                vertexDescriptor: vertexDescriptor,
                colorMask: nil,
                depthStencil: false
            )
            
            let maximumSupportedAnisotropy = context.limits.maximumTextureFilterAnisotropy
            let sampler = Sampler(context: context, maximumAnisotropy: min(maximumSupportedAnisotropy, maximumAnisotropy ?? maximumSupportedAnisotropy))
            
            reproject = Reproject(
                vertexBuffer: vertexBuffer,
                vertexAttributes: vertexAttributes,
                pipeline: pipeline,
                sampler: sampler,
                indexBuffer: indexBuffer)
            
            context.cache["imageryLayer_reproject"] = reproject
        }
        
        texture.sampler = reproject!.sampler
        
        let width = texture.width
        let height = texture.height
        
        let uniformMap = ImageryLayerUniformMap()
        
        uniformMap.textureDimensions = [Float(width), Float(height)]
        uniformMap.texture = texture
        
        var sinLatitude = sin(rectangle.south)
        let southMercatorY = 0.5 * log((1 + sinLatitude) / (1 - sinLatitude))
        
        sinLatitude = sin(rectangle.north)
        let northMercatorY = 0.5 * log((1 + sinLatitude) / (1 - sinLatitude))
        let oneOverMercatorHeight = 1.0 / (northMercatorY - southMercatorY)
        
        let south = rectangle.south
        let north = rectangle.north
        
        var webMercatorT = [Float]()
        
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
        
        var attributes = reproject.vertexAttributes
        attributes[1].buffer = webMercatorTBuffer
        
        let vertexArray = VertexArray(attributes: attributes, vertexCount: 128, indexBuffer: reproject.indexBuffer)
        
        let textureUsage: MTLTextureUsage = [.RenderTarget, .ShaderRead]
        
        let outputTexture = Texture(
            context: context,
            options: TextureOptions(
                width: width,
                height: height,
                pixelFormat: context.view.colorPixelFormat,
                premultiplyAlpha: texture.premultiplyAlpha,
                usage: textureUsage
            )
        )
        outputTexture.sampler = reproject.sampler
        
        command.pipeline = reproject.pipeline
        command.outputTexture = outputTexture
        command.uniformMap = uniformMap
        command.vertexArray = vertexArray
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