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
    
    func freeResources () {
        state = .Unloaded
        data = nil
        mesh = nil
        
        var indexBuffer: IndexBuffer? = nil
        if vertexArray != nil {
            let indexBuffer = vertexArray!.indexBuffer
            vertexArray = nil
        }
        
        /*if (!indexBuffer.isDestroyed() && defined(indexBuffer.referenceCount)) {
        --indexBuffer.referenceCount;
        if (indexBuffer.referenceCount === 0) {
        indexBuffer.destroy();
        }
        }*/
    }


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
        surfaceTile.vertexArray = vertexArray
        vertexArray = nil
    }
    
    func processLoadStateMachine (#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state == .Unloaded {
            requestTileGeometry(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
        
        if state == .Received {
            transform(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
        
        if state == .Transformed {
            createResources(context: context, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
    }
    
    
    func requestTileGeometry(#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {

        dispatch_async(context.processorQueue, {
            self.state = .Receiving
            var terrainData = terrainProvider.requestTileGeometry(x: x, y: y, level: level)
            if let terrainData = terrainData {
                dispatch_async(context.renderQueue, {
                    self.data = terrainData
                    self.state = .Received
                })
            } else {
                dispatch_async(context.renderQueue, {
                    // Initially assume failure.  handleError may retry, in which case the state will
                    // change to RECEIVING or UNLOADED.
                    self.state = TerrainState.Failed
                    
                    let message = "Failed to obtain terrain tile X: \(x) Y: \(y) Level: \(level) - terrain data request failed"
                    println(message)
                    
                })
            }
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

    func transform(#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        self.state = .Transforming

        dispatch_async(context.processorQueue, {
            var mesh = self.data!.createMesh(tilingScheme: terrainProvider.tilingScheme, x: x, y: y, level: level)
            
            if let mesh = mesh {
                dispatch_async(context.renderQueue, {
                    self.mesh = mesh
                    self.state = .Transformed
                })
            } else {
                dispatch_async(context.processorQueue, {
                    self.state = .Failed
                    var message = "Failed to transform terrain tile X: \(x) Y: \(y) Level: \(level) - terrain create mesh request failed"
                    println(message)
                })
            }
        })
    }

    func createResources(#context: Context, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        let datatype = ComponentDatatype.Float32
        var terrainMesh = mesh!
        let buffer = context.createVertexBuffer(
            array: SerializedType.fromFloatArray(terrainMesh.vertices),
            usage: BufferUsage.StaticDraw)

        var stride: Int
        var numTexCoordComponents: Int
        if terrainProvider.hasVertexNormals {
            stride = 7 * datatype.elementSize()
            numTexCoordComponents = 3
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
        
        var indexBuffer = terrainMesh.indexBuffer
        if indexBuffer == nil {
            // FIXME geometry with > 64k indices
            //let indices = terrainMesh.indices
            //let indexDatatype = vertices.= 2) ?  IndexDatatype.UNSIGNED_SHORT : IndexDatatype.UNSIGNED_INT;
            //indexBuffer = context.createIndexBuffer(indices, BufferUsage.STATIC_DRAW, indexDatatype);
            indexBuffer = context.createIndexBuffer(
                array: SerializedType.fromIntArray(terrainMesh.indices, datatype: .UnsignedShort),
                usage: .StaticDraw,
                indexDatatype: .UnsignedShort)
            terrainMesh.indexBuffer = indexBuffer
        }
        vertexArray = context.createVertexArray(attributes, indexBuffer: indexBuffer)
        state = .Ready
    }
    
}
