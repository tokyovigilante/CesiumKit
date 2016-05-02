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
            
            //var indexBuffer: Buffer? = nil
            if self.vertexArray != nil {
                //let indexBuffer = self.vertexArray!.indexBuffer
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
        guard let mesh = mesh else {
            assertionFailure("mesh not created")
            return
        }
        surfaceTile.center = mesh.center
        surfaceTile.minimumHeight = mesh.minimumHeight
        surfaceTile.maximumHeight = mesh.maximumHeight
        surfaceTile.boundingSphere3D = mesh.boundingSphere3D
        surfaceTile.orientedBoundingBox = mesh.orientedBoundingBox
        surfaceTile.tileBoundingBox = TileBoundingBox(
            rectangle: tile.rectangle,
            minimumHeight: mesh.minimumHeight,
            maximumHeight: mesh.maximumHeight,
            ellipsoid: tile.tilingScheme.ellipsoid
        )
        
        tile.data!.occludeePointInScaledSpace = mesh.occludeePointInScaledSpace
        
        // Free the tile's existing vertex array, if any.
        surfaceTile.freeVertexArray()
        
        // Transfer ownership of the vertex array to the tile itself.
        surfaceTile.vertexArray = vertexArray
        vertexArray = nil
        
        // update cached draw commands
        tile.invalidateCommandCache = true
    }
    
    func processLoadStateMachine (frameState frameState: FrameState, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state == .Unloaded {
            requestTileGeometry(terrainProvider, x: x, y: y, level: level)
        } else if state == .Received {
            transform(frameState: frameState, terrainProvider: terrainProvider, x: x, y: y, level: level)
        } else if state == .Transformed {
            createResources(frameState: frameState, terrainProvider: terrainProvider, x: x, y: y, level: level)
        }
    }
    
    func requestTileGeometry(terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        
        self.state = .Receiving
        terrainProvider.requestTileGeometry(x: x, y: y, level: level, throttleRequests: true, completionBlock: { terrainData in
            if let terrainData = terrainData {
                self.data = terrainData
                self.state = .Received
            } else {
                // Initially assume failure.  handleError may retry, in which case the state will
                // change to RECEIVING or UNLOADED.
                self.state = TerrainState.Failed
                
                let message = "Failed to obtain terrain tile X: \(x) Y: \(y) Level: \(level) - terrain data request failed"
                print(message)
            }
        })
    }
    
    func processUpsampleStateMachine (frameState frameState: FrameState, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        if state != .Unloaded {
            return
        }
        guard let upsampleDetails = upsampleDetails else {
            assertionFailure("TileTerrain cannot upsample unless provided upsampleDetails")
            return
        }
        
        let sourceData = upsampleDetails.data
        let sourceX = upsampleDetails.x
        let sourceY = upsampleDetails.y
        let sourceLevel = upsampleDetails.level
        
        state = .Receiving
        
        dispatch_async(QueueManager.sharedInstance.upsampleQueue, {
            sourceData.upsample(
                tilingScheme: terrainProvider.tilingScheme,
                thisX: sourceX,
                thisY: sourceY,
                thisLevel: sourceLevel,
                descendantX: x,
                descendantY: y,
                descendantLevel: level,
                completionBlock: { terrainData in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let terrainData = terrainData {
                            self.data = terrainData
                            self.state = .Received
                        } else {
                            self.state = .Failed
                        }
                    })
            })
        })


        if state == .Received {
            transform(frameState: frameState, terrainProvider: terrainProvider, x: x, y: y, level: level)
         }
         
         if state == .Transformed {
            createResources(frameState: frameState, terrainProvider: terrainProvider, x: x, y: y, level: level)
         }
    }

    func transform(frameState frameState: FrameState, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        state = .Transforming

        guard let data = data else {
            self.state = .Failed
            let message = "Failed to transform terrain tile X: \(x) Y: \(y) Level: \(level) - data missing"
            print(message)
            return
        }
        
        let context = frameState.context
        
        dispatch_async(QueueManager.sharedInstance.processorQueue, {
            data.createMesh(tilingScheme: terrainProvider.tilingScheme, x: x, y: y, level: level, exaggeration: frameState.terrainExaggeration, completionBlock: { mesh in
                
                if let mesh = mesh {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mesh = mesh
                        self.state = .Transformed
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.state = .Failed
                        let message = "Failed to transform terrain tile X: \(x) Y: \(y) Level: \(level) - terrain create mesh request failed"
                        print(message)
                    })
                }
            })
        })
    }
    
    func createResources(frameState frameState: FrameState, terrainProvider: TerrainProvider, x: Int, y: Int, level: Int) {
        
        let context = frameState.context
        
        self.state = .Buffering
        var terrainMesh = self.mesh!
        
        dispatch_async(QueueManager.sharedInstance.resourceLoadQueue, {
            let datatype = ComponentDatatype.Float32
            let meshBufferSize = terrainMesh.vertices.sizeInBytes
            
            let stride: Int
            if terrainProvider.hasVertexNormals {
                stride = 7 * datatype.elementSize
            } else {
                stride = 6 * datatype.elementSize
            }
            
            let vertexCount = meshBufferSize / stride
            
            let vertexBuffer = Buffer(device: context.device, array: terrainMesh.vertices, componentDatatype: ComponentDatatype.Float32, sizeInBytes: meshBufferSize)
            
            var indexBuffer = terrainMesh.indexBuffer
            if indexBuffer == nil {
                let indices = terrainMesh.indices
                if indices.count < Math.SixtyFourKilobytes {
                    let indicesShort = indices.map({ UInt16($0) })
                    indexBuffer = Buffer(
                        device: context.device,
                        array: indicesShort,
                        componentDatatype: ComponentDatatype.UnsignedShort,
                        sizeInBytes: indicesShort.sizeInBytes)
                } else {
                    let indicesInt = indices.map({ UInt32($0) })
                    indexBuffer = Buffer(
                        device: context.device,
                        array: indicesInt,
                        componentDatatype: ComponentDatatype.UnsignedInt,
                        sizeInBytes: indicesInt.sizeInBytes)
                }
                terrainMesh.indexBuffer = indexBuffer!
            }
            var attributes = terrainMesh.encoding.vertexAttributes
            attributes[0].buffer = vertexBuffer
            let vertexArray = VertexArray(attributes: attributes, vertexCount: vertexCount, indexBuffer: indexBuffer)
            dispatch_async(dispatch_get_main_queue(), {
                self.vertexArray = vertexArray
                self.state = .Ready
            })
        })
    }
    
}
