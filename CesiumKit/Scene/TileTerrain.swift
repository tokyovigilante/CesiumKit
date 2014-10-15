//
//  TileTerrain.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

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
    
    TileTerrain.prototype.publishToTile = function(tile) {
    var surfaceTile = tile.data;
    
    var mesh = this.mesh;
    Cartesian3.clone(mesh.center, surfaceTile.center);
    surfaceTile.minimumHeight = mesh.minimumHeight;
    surfaceTile.maximumHeight = mesh.maximumHeight;
    surfaceTile.boundingSphere3D = BoundingSphere.clone(mesh.boundingSphere3D, surfaceTile.boundingSphere3D);
    
    tile.data.occludeePointInScaledSpace = Cartesian3.clone(mesh.occludeePointInScaledSpace, surfaceTile.occludeePointInScaledSpace);
    
    // Free the tile's existing vertex array, if any.
    surfaceTile.freeVertexArray();
    
    // Transfer ownership of the vertex array to the tile itself.
    surfaceTile.vertexArray = this.vertexArray;
    this.vertexArray = undefined;
    };
    */
    
    func processLoadStateMachine (#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state == .Unloaded {
            requestTileGeometry(terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
        
        if state == .Received {
            transform(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level);
        }
        
        /*if state == .Transformed) {
            createResources(this, context, terrainProvider, x, y, level);
        }*/
    }
    
    
    func requestTileGeometry(#terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        weak var weakSelf = self
        
        func success(terrainData: TerrainData) {
            weakSelf?.data = terrainData
            weakSelf?.state = TerrainState.Received
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
            /*
            // If the request method returns undefined (instead of a promise), the request
            // has been deferred.
            if (defined(tileTerrain.data)) {
                tileTerrain.state = TerrainState.RECEIVING;
                
                when(tileTerrain.data, success, failure);
            } else {
                // Deferred - try again later.
                tileTerrain.state = TerrainState.UNLOADED;
            }*/
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
        let tilingScheme = terrainProvider.tilingScheme
        
        var mesh = self.data?.createMesh(tilingScheme: tilingScheme, x: x, y: y, level: level)
        /*
        if (!defined(meshPromise)) {
        // Postponed.
        return;
        }
        
        tileTerrain.state = TerrainState.TRANSFORMING;
        
        when(meshPromise, function(mesh) {
        tileTerrain.mesh = mesh;
        tileTerrain.state = TerrainState.TRANSFORMED;
        }, function() {
        tileTerrain.state = TerrainState.FAILED;
        });*/
    }
/*
function createResources(tileTerrain, context, terrainProvider, x, y, level) {
    var datatype = ComponentDatatype.FLOAT;
    var stride;
    var numTexCoordComponents;
    var typedArray = tileTerrain.mesh.vertices;
    var buffer = context.createVertexBuffer(typedArray, BufferUsage.STATIC_DRAW);
    if (terrainProvider.hasVertexNormals) {
        stride = 8 * ComponentDatatype.getSizeInBytes(datatype);
        numTexCoordComponents = 4;
    } else {
        stride = 6 * ComponentDatatype.getSizeInBytes(datatype);
        numTexCoordComponents = 2;
    }
    
    var position3DAndHeightLength = 4;
    
    var attributes = [{
        index : terrainAttributeLocations.position3DAndHeight,
        vertexBuffer : buffer,
        componentDatatype : datatype,
        componentsPerAttribute : position3DAndHeightLength,
        offsetInBytes : 0,
        strideInBytes : stride
        }, {
            index : terrainAttributeLocations.textureCoordAndEncodedNormals,
            vertexBuffer : buffer,
            componentDatatype : datatype,
            componentsPerAttribute : numTexCoordComponents,
            offsetInBytes : position3DAndHeightLength * ComponentDatatype.getSizeInBytes(datatype),
            strideInBytes : stride
    }];
    
    var indexBuffers = tileTerrain.mesh.indices.indexBuffers || {};
    var indexBuffer = indexBuffers[context.id];
    if (!defined(indexBuffer) || indexBuffer.isDestroyed()) {
        var indices = tileTerrain.mesh.indices;
        indexBuffer = context.createIndexBuffer(indices, BufferUsage.STATIC_DRAW, IndexDatatype.UNSIGNED_SHORT);
        indexBuffer.vertexArrayDestroyable = false;
        indexBuffer.referenceCount = 1;
        indexBuffers[context.id] = indexBuffer;
        tileTerrain.mesh.indices.indexBuffers = indexBuffers;
    } else {
        ++indexBuffer.referenceCount;
    }
    
    tileTerrain.vertexArray = context.createVertexArray(attributes, indexBuffer);
    
    tileTerrain.state = TerrainState.READY;
}

return TileTerrain;
});

*/
}