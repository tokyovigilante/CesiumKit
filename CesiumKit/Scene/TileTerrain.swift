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
    var state: TerrainState = TerrainState.Unloaded

    var data: TerrainData? = nil
    
    var mesh: TerrainMesh? = nil
    
    var vertexArray: VertexArray? = nil

    var upsampleDetails: (data: TerrainData, x: Int, y: Int, level: Int)?

    init (upsampleDetails: (data: TerrainData, x: Int, y: Int, level: Int)? = nil) {
        self.upsampleDetails = upsampleDetails
    }
    
    func freeResources (context: Context? = nil) {
        self.state = .Unloaded
        
        let freeResourcesRaw = { () -> () in
            self.data = nil
            self.mesh = nil
            
            var indexBuffer: Buffer? = nil
            if self.vertexArray != nil {
                let indexBuffer = self.vertexArray!.indexBuffer
                self.vertexArray = nil
            }
        }
        /*if let context = context {
            dispatch_async(context.processorQueue, freeResourcesRaw)
        } else {*/
            freeResourcesRaw()
        //}
        // FIXME: Index buffer
        /*if (!indexBuffer.isDestroyed() && defined(indexBuffer.referenceCount)) {
        --indexBuffer.referenceCount;
        if (indexBuffer.referenceCount === 0) {
        indexBuffer.destroy();
        }
        }*/
    }


    func publishToTile(tile: QuadtreeTile) {
        let surfaceTile = tile.data!
        assert(mesh != nil, "mesh not created")
        surfaceTile.center = mesh!.center

        surfaceTile.minimumHeight = mesh!.minimumHeight
        surfaceTile.maximumHeight = mesh!.maximumHeight
        surfaceTile.boundingSphere3D = mesh!.boundingSphere3D
        
        tile.data!.occludeePointInScaledSpace = mesh!.occludeePointInScaledSpace
        
        // Free the tile's existing vertex array, if any.
        surfaceTile.freeVertexArray()
        
        // Transfer ownership of the vertex array to the tile itself.
        surfaceTile.vertexArray = vertexArray
        vertexArray = nil
    }
    
    func processLoadStateMachine (context context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state == .Unloaded {
            requestTileGeometry(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        } else if state == .Received {
            transform(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        } else if state == .Transformed {
            createResources(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
    }
    
    
    func requestTileGeometry(context context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        
        self.state = .Receiving
        dispatch_async(context.processorQueue, {
            let terrainData = terrainProvider.requestTileGeometry(x: x, y: y, level: level, throttleRequests: false, completionBlock: { terrainData in
                if let terrainData = terrainData {
                    dispatch_async(dispatch_get_main_queue(), {
                        //dispatch_async(context.renderQueue, {
                        self.data = terrainData
                        self.state = .Received
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        //dispatch_async(context.renderQueue, {
                        // Initially assume failure.  handleError may retry, in which case the state will
                        // change to RECEIVING or UNLOADED.
                        self.state = TerrainState.Failed
                        
                        let message = "Failed to obtain terrain tile X: \(x) Y: \(y) Level: \(level) - terrain data request failed"
                        print(message)
                        
                    })
                }
            })
        })
    }

    func processUpsampleStateMachine (context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state == .Unloaded {
            
            
            assert(upsampleDetails != nil, "TileTerrain cannot upsample unless provided upsampleDetails")
            
            var sourceData = upsampleDetails!.data
            var sourceX = upsampleDetails!.x
            var sourceY = upsampleDetails!.y
            var sourceLevel = upsampleDetails!.level
            /*
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
            });*/
        }
        
        /*if (this.state === TerrainState.RECEIVED) {
        transform(this, context, terrainProvider, x, y, level);
        }
        
        if (this.state === TerrainState.TRANSFORMED) {
        createResources(this, context, terrainProvider, x, y, level);
        }*/
    }

    func transform(context context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        self.state = .Transforming

        guard let data = data else {
            self.state = .Failed
            let message = "Failed to transform terrain tile X: \(x) Y: \(y) Level: \(level) - data missing"
            print(message)
            return
        }
        
        dispatch_async(context.processorQueue, {
            data.createMesh(tilingScheme: terrainProvider.tilingScheme, x: x, y: y, level: level, completionBlock: { mesh in
                
                if let mesh = mesh {
                    dispatch_async(dispatch_get_main_queue(), {
                        //dispatch_async(context.renderQueue, {
                        self.mesh = mesh
                        self.state = .Transformed
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        //dispatch_async(context.renderQueue, {
                        self.state = .Failed
                        let message = "Failed to transform terrain tile X: \(x) Y: \(y) Level: \(level) - terrain create mesh request failed"
                        print(message)
                    })
                }
            })
        })
    }
    
    func createResources(context context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        self.state = .Buffering
        var terrainMesh = self.mesh!
        dispatch_async(context.processorQueue, {
            let datatype = ComponentDatatype.Float32
            let meshBufferSize = terrainMesh.vertices.sizeInBytes
            
            let stride: Int
            if terrainProvider.hasVertexNormals {
                stride = 7 * datatype.elementSize
            } else {
                stride = 6 * datatype.elementSize
            }
            
            let vertexCount = meshBufferSize / stride
            
            let vertexBuffer = context.createBuffer(terrainMesh.vertices, componentDatatype: ComponentDatatype.Float32, sizeInBytes: meshBufferSize)
            
            var indexBuffer = terrainMesh.indexBuffer
            if indexBuffer == nil {
                // FIXME geometry with > 64k indices
                let indices = terrainMesh.indices
                if indices.count < Math.SixtyFourKilobytes {
                    let indicesShort = indices.map({ UInt16($0) })
                    indexBuffer = context.createBuffer(
                        indicesShort,
                        componentDatatype: ComponentDatatype.UnsignedShort,
                        sizeInBytes: indicesShort.sizeInBytes)
                } else {
                    let indicesInt = indices.map({ UInt32($0) })
                    indexBuffer = context.createBuffer(
                        indicesInt,
                        componentDatatype: ComponentDatatype.UnsignedInt,
                        sizeInBytes: indicesInt.sizeInBytes)
                }
                terrainMesh.indexBuffer = indexBuffer!
            }
            let vertexArray = context.createVertexArray(buffers: [vertexBuffer], vertexCount: vertexCount, indexBuffer: indexBuffer)
            dispatch_async(dispatch_get_main_queue(), {
                //dispatch_async(context.renderQueue, {
                self.vertexArray = vertexArray
                self.state = .Ready
            })
        })
    }
    
}
