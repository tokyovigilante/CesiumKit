//
//  TileImagery.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* The assocation between a terrain tile and an imagery tile.
*
* @alias TileImagery
* @private
*
* @param {Imagery} imagery The imagery tile.
* @param {Cartesian4} textureCoordinateRectangle The texture rectangle of the tile that is covered
*        by the imagery, where X=west, Y=south, Z=east, W=north.
*/
class TileImagery {

    var readyImagery: Imagery? = nil
    
    var loadingImagery: Imagery? = nil
    
    var textureCoordinateRectangle: Cartesian4? = nil
    
    var textureTranslationAndScale: Cartesian4? = nil
    
    init(imagery: Imagery, textureCoordinateRectangle: Cartesian4? = nil) {
        loadingImagery = imagery
        self.textureCoordinateRectangle = textureCoordinateRectangle
        textureTranslationAndScale = nil
    }
    
    /**
    * Frees the resources held by this instance.
    */
    deinit {
        if readyImagery != nil {
            readyImagery!.releaseReference()
        }
        
        if loadingImagery != nil {
            loadingImagery!.releaseReference()
        }
    }
    
    /**
    * Processes the load state machine for this instance.
    *
    * @param {Tile} tile The tile to which this instance belongs.
    * @param {Context} context The context.
    * @returns {Boolean} True if this instance is done loading; otherwise, false.
    */
    func processStateMachine (tile: QuadtreeTile, context: Context, commandList: [Command]) -> Bool {
        
        let imageryLayer = loadingImagery!.imageryLayer
        
        loadingImagery!.processStateMachine(context)
        
        if loadingImagery!.state == .Ready {
            if readyImagery != nil {
                readyImagery!.releaseReference()
            }
            readyImagery = loadingImagery
            loadingImagery = nil
            textureTranslationAndScale = imageryLayer.calculateTextureTranslationAndScale(tile, tileImagery: self)
            return true // done loading
        }
        
        // Find some ancestor imagery we can use while this imagery is still loading.
        var ancestor = loadingImagery!.parent
        var closestAncestorThatNeedsLoading: Imagery?
        while ancestor != nil && ancestor!.state != ImageryState.Ready {
            if ancestor!.state != ImageryState.Failed && ancestor!.state != ImageryState.Invalid {
                // ancestor is still loading
                closestAncestorThatNeedsLoading = closestAncestorThatNeedsLoading ?? ancestor!
            }
            ancestor = ancestor!.parent
        }
        
        if readyImagery !== ancestor {
                if let readyImagery = readyImagery {
                    readyImagery.releaseReference()
                }
                
                readyImagery = ancestor
                
                if let ancestor = ancestor {
                    ancestor.addReference()
                    textureTranslationAndScale = imageryLayer.calculateTextureTranslationAndScale(tile, tileImagery: self)
                }
        }
        
        if loadingImagery!.state == .Failed || loadingImagery!.state == .Invalid {
            if let closestAncestorThatNeedsLoading = closestAncestorThatNeedsLoading {
                // Push the ancestor's load process along a bit.  This is necessary because some ancestor imagery
                // tiles may not be attached directly to a terrain tile.  Such tiles will never load if
                // we don't do it here.
                closestAncestorThatNeedsLoading.processStateMachine(context)
                return false
            } else {
                // This imagery tile is failed or invalid, and we have the "best available" substitute.  So we're done loading.
                return true // done loading
            }
        }
        return false // not done loading
    }

}