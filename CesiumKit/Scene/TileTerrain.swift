//
//  TileTerrain.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
/**
* Manages details of the terrain load or upsample process.
*
* @alias TileTerrain
* @constructor
* @private
*
* @param {TerrainData} [upsampleDetails.data] The terrain data being upsampled.
* @param {Number} [upsampleDetails.x] The X coordinate of the tile being upsampled.
* @param {Number} [upsampleDetails.y] The Y coordinate of the tile being upsampled.
* @param {Number} [upsampleDetails.level] The level coordinate of the tile being upsampled.
*/
class TileTerrain {
    
    /**
    * The current state of the terrain in the terrain processing pipeline.
    * @type {TerrainState}
    * @default {@link TerrainState.UNLOADED}
    */
    var state = TerrainState.Unloaded

    var data: TerrainData? = nil
    
    var mesh: TerrainMesh? = nil
    
    var vertexArray: VertexArray? = nil

    var upsampleDetails: (data: TerrainData, x: Int, y: Int, level: Int)?

    init (upsampleDetails: (data: TerrainData, x: Int, y: Int, level: Int)? = nil) {
        self.upsampleDetails = upsampleDetails
    }
    /*
    TileTerrain.prototype.freeResources = function() {
    this.state = TerrainState.UNLOADED;
    this.data = undefined;
    this.mesh = undefined;
    
    if (defined(this.vertexArray)) {
    var indexBuffer = this.vertexArray.indexBuffer;
    
    this.vertexArray.destroy();
    this.vertexArray = undefined;
    
    if (!indexBuffer.isDestroyed() && defined(indexBuffer.referenceCount)) {
    --indexBuffer.referenceCount;
    if (indexBuffer.referenceCount === 0) {
    indexBuffer.destroy();
    }
    }
    }
    };
    */
    func publishToTile(tile: QuadtreeTile) {
        var surfaceTile = tile.data!
        assert(mesh != nil, "mesh not created")
        surfaceTile.center = mesh!.center

        surfaceTile.minimumHeight = mesh!.minimumHeight
        surfaceTile.maximumHeight = mesh!.maximumHeight
        surfaceTile.boundingSphere3D = mesh!.boundingSphere3D
        
        tile.data!.occludeePointInScaledSpace = mesh!.occludeePointInScaledSpace
        
        // Free the tile's existing vertex array, if any.
        surfaceTile.freeVertexArray()
        
        // Transfer ownership of the vertex array to the tile itself.
        surfaceTile.vertexArray = this.vertexArray;
        this.vertexArray = undefined;
    }
    
    func processLoadStateMachine (#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state == .Unloaded {
            requestTileGeometry(terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
        
        if state == .Received {
            transform(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
        
        if state == .Transformed {
            createResources(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
    }
    
    
    func requestTileGeometry(#terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        weak var weakSelf = self
        
        func success(terrainData: TerrainData) {
            weakSelf?.data = terrainData
            weakSelf?.state = .Received
        }
        
        func failure(error: String) {
            // Initially assume failure.  handleError may retry, in which case the state will
            // change to RECEIVING or UNLOADED.
            weakSelf?.state = TerrainState.Failed
            
            var message = "Failed to obtain terrain tile X: \(x) Y: \(y) Level: \(level) - \(error)"
            /*terrainProvider._requestError = TileProviderError.handleError(
            terrainProvider._requestError,
            terrainProvider,
            terrainProvider.errorEvent,
            message,
            x, y, level,
            doRequest);*/
            println(message)
        }
        
        func doRequest() -> AsyncResult<TerrainData> {
            // Request the terrain from the terrain provider.
            weakSelf?.state = .Receiving
            var terrainData = terrainProvider.requestTileGeometry(x: x, y: y, level: level)
            if let terrainData = terrainData {
                return AsyncResult(terrainData)
            }
            return AsyncResult("terrain data request failed")
        }
        
        AsyncResult<TerrainData>.perform(doRequest, asyncClosures: (success: success, failure: failure))
    }
/*
TileTerrain.prototype.processUpsampleStateMachine = function(context, terrainProvider, x, y, level) {
    if (this.state === TerrainState.UNLOADED) {
        var upsampleDetails = this.upsampleDetails;
        
        //>>includeStart('debug', pragmas.debug);
        if (!defined(upsampleDetails)) {
            throw new DeveloperError('TileTerrain cannot upsample unless provided upsampleDetails.');
        }
        //>>includeEnd('debug');
        
        var sourceData = upsampleDetails.data;
        var sourceX = upsampleDetails.x;
        var sourceY = upsampleDetails.y;
        var sourceLevel = upsampleDetails.level;
        
        this.data = sourceData.upsample(terrainProvider.tilingScheme, sourceX, sourceY, sourceLevel, x, y, level);
        if (!defined(this.data)) {
            // The upsample request has been deferred - try again later.
            return;
        }
        
        this.state = TerrainState.RECEIVING;
        
        var that = this;
        when(this.data, function(terrainData) {
            that.data = terrainData;
            that.state = TerrainState.RECEIVED;
            }, function() {
                that.state = TerrainState.FAILED;
            });
    }
    
    if (this.state === TerrainState.RECEIVED) {
        transform(this, context, terrainProvider, x, y, level);
    }
    
    if (this.state === TerrainState.TRANSFORMED) {
        createResources(this, context, terrainProvider, x, y, level);
    }
};
*/
    func transform(#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {

        weak var weakSelf = self
        
        func success(mesh: TerrainMesh) {
            weakSelf?.mesh = mesh
            weakSelf?.state = .Transformed
        }
        
        func failure(error: String) {
            weakSelf?.state = .Failed
            var message = "Failed to transform terrain tile X: \(x) Y: \(y) Level: \(level) - \(error)"
            println(message)
        }
        
        func doRequest() -> AsyncResult<TerrainMesh> {
            // Request the terrain from the terrain provider.
            weakSelf?.state = .Transforming
            var mesh = self.data!.createMesh(tilingScheme: terrainProvider.tilingScheme, x: x, y: y, level: level)

            if let mesh = mesh {
                return AsyncResult(mesh)
            }
            return AsyncResult("terrain data request failed")
        }
        
        AsyncResult<TerrainMesh>.perform(doRequest, asyncClosures: (success: success, failure: failure))
    }

    func createResources(#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        let datatype = ComponentDatatype.Float32
        var stride = 0
        var numTexCoordComponents = 0
        //var typedArray = tileTerrain.mesh.vertices;
        let buffer = context.createVertexBuffer(
            array: SerializedArray(data: NSData.serializeArray(self.mesh!.vertices), type: datatype),
            usage: BufferUsage.StaticDraw)
        
        if terrainProvider.hasVertexNormals {
            stride = 8 * datatype.elementSize()
            numTexCoordComponents = 4
        } else {
            stride = 6 * datatype.elementSize()
            numTexCoordComponents = 2
        }
        
        var position3DAndHeightLength = 4
        
        var attributes = [
            VertexAttributes(
                index: terrainAttributeLocations["position3DAndHeight"]!,
                vertexBuffer: buffer,
                componentsPerAttribute: position3DAndHeightLength,
                componentDatatype: datatype,
                offsetInBytes: 0,
                strideInBytes: stride),
            VertexAttributes(
                index: terrainAttributeLocations["textureCoordAndEncodedNormals"]!,
                vertexBuffer: buffer,
                componentsPerAttribute : numTexCoordComponents,
                componentDatatype: datatype,
                offsetInBytes : position3DAndHeightLength * datatype.elementSize(),
                strideInBytes : stride)
        ]
        
        var indexBuffer = mesh!.indexBuffers[context.id]
        if indexBuffer == nil {
            indexBuffer = context.createIndexBuffer(
                array: SerializedArray(data: NSData.serializeArray(self.mesh!.indices), type: .UnsignedShort),
                usage: .StaticDraw,
                indexDatatype: .UnsignedShort)
            mesh!.indexBuffers.removeAll()
            mesh!.indexBuffers[context.id] = indexBuffer
        }
        
        vertexArray = context.createVertexArray(attributes, indexBuffer: indexBuffer)
        state = .Ready
    }
    
}
