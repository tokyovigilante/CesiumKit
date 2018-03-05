//
//  GlobeSurfaceTile.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//
/**
* Contains additional information about a {@link QuadtreeTile} of the globe's surface, and
* encapsulates state transition logic for loading tiles.
*
* @constructor
* @alias GlobeSurfaceTile
* @private
*/

import Foundation

class GlobeSurfaceTile: QuadTreeTileData {

    /**
    * The {@link TileImagery} attached to this tile.
    * @type {TileImagery[]}
    * @default []
    */
    var imagery = [TileImagery]()

    var waterMaskTexture: Texture? = nil

    var waterMaskTranslationAndScale = Cartesian4(x: 0.0, y: 0.0, z: 1.0, w: 1.0)

    var terrainData: TerrainData? = nil

    var center = Cartesian3()

    var vertexArray: VertexArray? = nil

    var minimumHeight = 0.0
    var maximumHeight = 0.0

    var boundingSphere3D = BoundingSphere()
    var boundingSphere2D = BoundingSphere()
    var orientedBoundingBox: OrientedBoundingBox? = nil
    var tileBoundingBox: TileBoundingBox? = nil

    var occludeePointInScaledSpace: Cartesian3? = Cartesian3()

    var loadedTerrain: TileTerrain? = nil

    var upsampledTerrain: TileTerrain? = nil

    var pickBoundingSphere = BoundingSphere()

    var pickTerrain: TileTerrain? = nil

    var surfacePipeline: GlobeSurfacePipeline? = nil

    /**
    * Gets a value indicating whether or not this tile is eligible to be unloaded.
    * Typically, a tile is ineligible to be unloaded while an asynchronous operation,
    * such as a request for data, is in progress on it.  A tile will never be
    * unloaded while it is needed for rendering, regardless of the value of this
    * property.
    * @memberof GlobeSurfaceTile.prototype
    * @type {Boolean}
    */
    func eligibleForUnloading() -> Bool {
        // Do not remove tiles that are transitioning or that have
        // imagery that is transitioning.

        let loadingIsTransitioning = loadedTerrain != nil &&
            (loadedTerrain!.state == .receiving || loadedTerrain!.state == .transforming)

        let upsamplingIsTransitioning = upsampledTerrain != nil &&
            (upsampledTerrain!.state == .receiving || upsampledTerrain!.state == .transforming)

        var shouldRemoveTile = !loadingIsTransitioning && !upsamplingIsTransitioning

        if !shouldRemoveTile {
            return false
        }
        for tileImagery in imagery {
            shouldRemoveTile = tileImagery.loadingImagery == nil || tileImagery.loadingImagery!.state != .transitioning
            if !shouldRemoveTile {
                break
            }
        }

        return shouldRemoveTile
    }


    func getPosition(_ encoding: TerrainEncoding, mode: SceneMode? = nil, projection: MapProjection, vertices: [Float], index: Int) -> Cartesian3 {

        var result = encoding.decodePosition(vertices, index: index)

        if mode != nil && mode != .scene3D {
            let positionCart = projection.ellipsoid.cartesianToCartographic(result)
            result = projection.project(positionCart!)
            result = Cartesian3(x: result.z, y: result.x, z: result.y)
        }

        return result
    }

    func pick (_ ray: Ray, mode: SceneMode, projection: MapProjection, cullBackFaces: Bool) -> Cartesian3? {

        guard let mesh = pickTerrain?.mesh else {
            return nil
        }

        let vertices = mesh.vertices
        let indices = mesh.indices
        let encoding = mesh.encoding
        let length = indices.count
        for i in stride(from: 0, to: length, by: 3) {
            let i0 = indices[i]
            let i1 = indices[i + 1]
            let i2 = indices[i + 2]

            let v0 = getPosition(encoding, mode: mode, projection: projection, vertices: vertices, index: i0)
            let v1 = getPosition(encoding, mode: mode, projection: projection, vertices: vertices, index: i1)
            let v2 = getPosition(encoding, mode: mode, projection: projection, vertices: vertices, index: i2)

            let intersection = IntersectionTests.rayTriangle(ray, p0: v0, p1: v1, p2: v2, cullBackFaces: cullBackFaces)
            if intersection != nil {
                return intersection
            }
        }
        return nil
    }

    func freeResources () {

        waterMaskTexture = nil
        terrainData = nil

        if loadedTerrain != nil {
            loadedTerrain!.freeResources()
            loadedTerrain = nil
        }

        if upsampledTerrain != nil {
            upsampledTerrain!.freeResources()
            upsampledTerrain = nil
        }

        if pickTerrain != nil {
            pickTerrain!.freeResources()
            pickTerrain = nil
        }
        // FIXME:             tileImagery.freeResources()

        /*for tileImagery in imagery {
            tileImagery.freeResources()
        }
        var i, len;

        var imageryList = this.imagery;
        for (i = 0, len = imageryList.length; i < len; ++i) {
            imageryList[i].freeResources();
        }*/
        imagery.removeAll()

        freeVertexArray()
    }

    func freeVertexArray() {
        vertexArray = nil
    }

    class func processStateMachine(_ tile: QuadtreeTile, frameState: inout FrameState, terrainProvider: TerrainProvider, imageryLayerCollection: ImageryLayerCollection) {

        if (tile.data == nil) {
            tile.data = GlobeSurfaceTile()
        }
        let surfaceTile = tile.data

        if tile.state == .start {
            GlobeSurfaceTile.prepareNewTile(tile, terrainProvider: terrainProvider, imageryLayerCollection: imageryLayerCollection)
            tile.state = .loading
        }

        if tile.state == .loading {
            GlobeSurfaceTile.processTerrainStateMachine(tile, frameState: frameState, terrainProvider: terrainProvider)
        }

        // The terrain is renderable as soon as we have a valid vertex array.
        var isRenderable = surfaceTile?.vertexArray != nil

        // But it's not done loading until our two state machines are terminated.
        var isDoneLoading = surfaceTile?.loadedTerrain == nil && surfaceTile?.upsampledTerrain == nil

        // If this tile's terrain and imagery are just upsampled from its parent, mark the tile as
        // upsampled only.  We won't refine a tile if its four children are upsampled only.
        var isUpsampledOnly = surfaceTile?.terrainData != nil && surfaceTile!.terrainData!.createdByUpsampling

        // Transition imagery states
        var i = 0
        var tileImageryCollection = surfaceTile!.imagery

        while i < tileImageryCollection.count {
            let tileImagery = tileImageryCollection[i]
            if tileImagery.loadingImagery == nil {
                isUpsampledOnly = false
                i += 1
                continue
            }
            if tileImagery.loadingImagery!.state == .placeHolder {
                let imageryLayer = tileImagery.loadingImagery!.imageryLayer
                if (imageryLayer.imageryProvider.ready) {
                    // Remove the placeholder and add the actual skeletons (if any)
                    // at the same position.  Then continue the loop at the same index.
                    tileImageryCollection.remove(at: i)
                    imageryLayer.createTileImagerySkeletons(tile, terrainProvider: terrainProvider, insertionPoint: i)
                    continue
                } else {
                    isUpsampledOnly = false
                }
            }

            let thisTileDoneLoading = tileImagery.processStateMachine(tile, frameState: &frameState)
            if thisTileDoneLoading {
                // update cached draw commands
                tile.invalidateCommandCache = true
            }
            isDoneLoading = isDoneLoading && thisTileDoneLoading

            // The imagery is renderable as soon as we have any renderable imagery for this region.
            isRenderable = isRenderable && (thisTileDoneLoading || tileImagery.readyImagery != nil)

            isUpsampledOnly = isUpsampledOnly && tileImagery.loadingImagery != nil &&
                (tileImagery.loadingImagery!.state == .failed || tileImagery.loadingImagery!.state == .invalid)

            i += 1
        }

        tile.upsampledFromParent = isUpsampledOnly

        // The tile becomes renderable when the terrain and all imagery data are loaded.
        if i == tileImageryCollection.count {
            if isRenderable {
                tile.renderable = true
            }

            if isDoneLoading {
                tile.state = .done
            }
        }
    }

    class func prepareNewTile (_ tile: QuadtreeTile, terrainProvider: TerrainProvider, imageryLayerCollection: ImageryLayerCollection) {
        let surfaceTile = tile.data!

        if let upsampleTileDetails = GlobeSurfaceTile.getUpsampleTileDetails(tile) {
            surfaceTile.upsampledTerrain = TileTerrain(upsampleDetails: upsampleTileDetails)
        }

        if isDataAvailable(tile, terrainProvider: terrainProvider) {
            surfaceTile.loadedTerrain = TileTerrain()
        }

        // Map imagery tiles to this terrain tile

        for i in 0..<imageryLayerCollection.count {
            if let layer = imageryLayerCollection[i] {
                if layer.show {
                    layer.createTileImagerySkeletons(tile, terrainProvider: terrainProvider)
                }
            }
        }
    }

    class func processTerrainStateMachine(_ tile: QuadtreeTile, frameState: FrameState, terrainProvider: TerrainProvider) {
        let surfaceTile = tile.data!
        let loaded = surfaceTile.loadedTerrain
        let upsampled = surfaceTile.upsampledTerrain
        var suspendUpsampling = false

        if let loaded = loaded {
            loaded.processLoadStateMachine(frameState: frameState, terrainProvider: terrainProvider, x: tile.x, y: tile.y, level: tile.level)

            // Publish the terrain data on the tile as soon as it is available.
            // We'll potentially need it to upsample child tiles.
            if loaded.state.rawValue >= TerrainState.received.rawValue {
                if surfaceTile.terrainData !== loaded.data {
                    surfaceTile.terrainData = loaded.data

                    // If there's a water mask included in the terrain data, create a
                    // texture for it.
                    surfaceTile.createWaterMaskTextureIfNeeded(frameState.context)

                    GlobeSurfaceTile.propagateNewLoadedDataToChildren(tile)
                }
                suspendUpsampling = true
            }

            if loaded.state == .ready {
                loaded.publishToTile(tile)

                // No further loading or upsampling is necessary.
                surfaceTile.pickTerrain = surfaceTile.loadedTerrain ?? surfaceTile.upsampledTerrain
                surfaceTile.loadedTerrain = nil
                surfaceTile.upsampledTerrain = nil
            } else if (loaded.state == .failed) {
                // Loading failed for some reason, or data is simply not available,
                // so no need to continue trying to load.  Any retrying will happen before we
                // reach this point.
                surfaceTile.loadedTerrain = nil
            }
        }

        if !suspendUpsampling, let upsampled = upsampled {

            upsampled.processUpsampleStateMachine(frameState: frameState, terrainProvider: terrainProvider, x: tile.x, y: tile.y, level: tile.level)

            // Publish the terrain data on the tile as soon as it is available.
            // We'll potentially need it to upsample child tiles.
            // It's safe to overwrite terrainData because we won't get here after
            // loaded terrain data has been received.
            if upsampled.state.rawValue >= TerrainState.received.rawValue && surfaceTile.terrainData !== upsampled.data {
                surfaceTile.terrainData = upsampled.data

                // If the terrain provider has a water mask, "upsample" that as well
                // by computing texture translation and scale.
                if (terrainProvider.hasWaterMask) {
                    upsampleWaterMask(tile)
                }
                GlobeSurfaceTile.propagateNewUpsampledDataToChildren(tile)

            }
            if upsampled.state == .ready {
                upsampled.publishToTile(tile)
                // No further upsampling is necessary.  We need to continue loading, though.
                surfaceTile.pickTerrain = surfaceTile.upsampledTerrain
                surfaceTile.upsampledTerrain = nil
            } else if upsampled.state == .failed {
                // Upsampling failed for some reason.  This is pretty much a catastrophic failure,
                // but maybe we'll be saved by loading.
                surfaceTile.upsampledTerrain = nil
            }
        }
    }

    class func getUpsampleTileDetails(_ tile: QuadtreeTile) -> (data: TerrainData, x: Int, y: Int, level: Int)? {
        // Find the nearest ancestor with loaded terrain.
        var sourceTile = tile.parent
        while sourceTile != nil &&
            sourceTile!.data != nil &&
            sourceTile!.data!.terrainData == nil {
            sourceTile = sourceTile?.parent
        }

        if sourceTile == nil ||
            sourceTile!.data == nil {
            // No ancestors have loaded terrain - try again later.
            return nil
        }
        return (data: sourceTile!.data!.terrainData!, x: sourceTile!.x, y: sourceTile!.y, level: sourceTile!.level)
    }

    class func propagateNewUpsampledDataToChildren(_ tile: QuadtreeTile) {
        let surfaceTile = tile.data!

        // Now that there's new data for this tile:
        //  - child tiles that were previously upsampled need to be re-upsampled based on the new data.

        // Generally this is only necessary when a child tile is upsampled, and then one
        // of its ancestors receives new (better) data and we want to re-upsample from the
        // new data.
        for childTile in tile.children {
            if childTile.state != .start {
                let childSurfaceTile = childTile.data!
                if childSurfaceTile.terrainData != nil && !childSurfaceTile.terrainData!.createdByUpsampling {
                    // Data for the child tile has already been loaded.
                    continue
                }
                // Restart the upsampling process, no matter its current state.
                // We create a new instance rather than just restarting the existing one
                // because there could be an asynchronous operation pending on the existing one.
                if childSurfaceTile.upsampledTerrain != nil {
                    childSurfaceTile.upsampledTerrain!.freeResources()
                    childSurfaceTile.upsampledTerrain = nil
                }
                childSurfaceTile.upsampledTerrain = TileTerrain(upsampleDetails: (
                    data: surfaceTile.terrainData!,
                    x: tile.x,
                    y: tile.y,
                    level: tile.level)
                )
                childTile.state = .loading
            }
        }
    }

    class func propagateNewLoadedDataToChildren(_ tile: QuadtreeTile) {
        let surfaceTile = tile.data!

        // Now that there's new data for this tile:
        //  - child tiles that were previously upsampled need to be re-upsampled based on the new data.
        //  - child tiles that were previously deemed unavailable may now be available.

        for childTile in tile.children {
            if childTile.state != .start {
                let childSurfaceTile = childTile.data!
                if childSurfaceTile.terrainData != nil && childSurfaceTile.terrainData!.createdByUpsampling {
                    // Data for the child tile has already been loaded.
                    continue
                }

                // Restart the upsampling process, no matter its current state.
                // We create a new instance rather than just restarting the existing one
                // because there could be an asynchronous operation pending on the existing one.
                childSurfaceTile.upsampledTerrain = TileTerrain(upsampleDetails: (
                    data : surfaceTile.terrainData!,
                    x : tile.x,
                    y : tile.y,
                    level : tile.level)
                )

                if surfaceTile.terrainData!.isChildAvailable(tile.x, thisY: tile.y, childX: childTile.x, childY: childTile.y) {
                    // Data is available for the child now.  It might have been before, too.
                    if childSurfaceTile.loadedTerrain == nil {
                        // No load process is in progress, so start one.
                        childSurfaceTile.loadedTerrain = TileTerrain()
                    }
                }
                childTile.state = .loading
            }
        }
    }

    class func isDataAvailable(_ tile: QuadtreeTile, terrainProvider: TerrainProvider) -> Bool {
        if let tileDataAvailable = terrainProvider.getTileDataAvailable(x: tile.x, y: tile.y, level: tile.level) {
            return tileDataAvailable
        }
        let parent = tile.parent
        if parent == nil {
            // Data is assumed to be available for root tiles.
            return true
        }
        if parent?.data?.terrainData == nil {
            // Parent tile data is not yet received or upsampled, so assume (for now) that this
            // child tile is not available.
            return false
        }
        return parent!.data!.terrainData!.isChildAvailable(parent!.x, thisY: parent!.y, childX: tile.x, childY: tile.y)
    }

    func getContextWaterMaskData(_ context: Context) -> (allWaterTexture: Texture, sampler: Sampler) {
        var data = context.cache["tile_waterMaskData"]// as! (Texture, Sampler)?

        if data == nil {
            let allWaterTexture = Texture(context: context, options: TextureOptions(
                source: .buffer(Imagebuffer(
                    array: [255],
                    width: 1,
                    height: 1)
                ),
                pixelFormat: PixelFormat.r8Unorm
            ))
            let sampler = Sampler(
                context: context,
                wrapS: .clampToEdge,
                wrapT: .clampToEdge,
                minFilter: .linear,
                magFilter: .linear
             )

            data = (
                allWaterTexture: allWaterTexture,
                sampler: sampler
            )
            context.cache["tile_waterMaskData"] = data as Any
        }
        return data! as! (Texture, Sampler)
        // as
    }

    func createWaterMaskTextureIfNeeded(_ context: Context) {

        guard let waterMask = terrainData?.waterMask else {
            waterMaskTexture = nil
            return
        }

        let waterMaskData = getContextWaterMaskData(context)

        let texture: Texture
        let waterMaskLength = waterMask.count

        if waterMaskLength == 1 {
            // Length 1 means the tile is entirely land or entirely water.
            // A value of 0 indicates entirely land, a value of 1 indicates entirely water.
            if waterMask.first != 0 {
                texture = waterMaskData.allWaterTexture
            } else {
                // Leave the texture undefined if the tile is entirely land.
                waterMaskTexture = nil
                return
            }
        } else {
            let textureSize = Int(sqrt(Double(waterMaskLength)))

            // flip water mask for Metal
            var flippedMask = [UInt8]()
            for i in stride(from: (textureSize-1), through: 0, by: -1) {
                let rowRange = (i * textureSize)..<(i * textureSize + textureSize)
                let slice = waterMask[rowRange]
                flippedMask.append(contentsOf: slice)
            }

            texture = Texture(
                context: context,
                options: TextureOptions(
                    source: TextureSource.buffer(Imagebuffer(
                        array: flippedMask,
                        width: textureSize,
                        height: textureSize,
                        bytesPerPixel: 1
                    )),
                    pixelFormat: PixelFormat.r8Unorm,
                    sampler : waterMaskData.sampler
                )
            )
        }
        waterMaskTexture = texture
        waterMaskTranslationAndScale = Cartesian4(x: 0.0, y: 0.0, z: 1.0, w: 1.0)
    }


    class func upsampleWaterMask(_ tile: QuadtreeTile) {
        let surfaceTile = tile.data!

        // Find the nearest ancestor with loaded terrain.
        var sourceTile = tile.parent
        while sourceTile != nil && sourceTile!.data!.terrainData == nil || sourceTile!.data!.terrainData!.createdByUpsampling {
            sourceTile = sourceTile!.parent
        }

        if sourceTile == nil || sourceTile!.data?.waterMaskTexture == nil {
            // No ancestors have a water mask texture - try again later.
            return
        }

        surfaceTile.waterMaskTexture = sourceTile!.data!.waterMaskTexture

        // Compute the water mask translation and scale
        let sourceTileRectangle = sourceTile!.rectangle
        let tileRectangle = tile.rectangle
        let tileWidth = tileRectangle.width
        let tileHeight = tileRectangle.height

        let scaleX = tileWidth / sourceTileRectangle.width
        let scaleY = tileHeight / sourceTileRectangle.height
        surfaceTile.waterMaskTranslationAndScale.x = scaleX * (tileRectangle.west - sourceTileRectangle.west) / tileWidth
        surfaceTile.waterMaskTranslationAndScale.y = scaleY * (tileRectangle.south - sourceTileRectangle.south) / tileHeight
        surfaceTile.waterMaskTranslationAndScale.z = scaleX
        surfaceTile.waterMaskTranslationAndScale.w = scaleY
    }


}
