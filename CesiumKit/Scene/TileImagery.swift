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
        
    }
    
        /*
    /**
    * Processes the load state machine for this instance.
    *
    * @param {Tile} tile The tile to which this instance belongs.
    * @param {Context} context The context.
    * @returns {Boolean} True if this instance is done loading; otherwise, false.
    */
    TileImagery.prototype.processStateMachine = function(tile, context) {
    var loadingImagery = this.loadingImagery;
    var imageryLayer = loadingImagery.imageryLayer;
    
    if (loadingImagery.state === ImageryState.UNLOADED) {
    loadingImagery.state = ImageryState.TRANSITIONING;
    imageryLayer._requestImagery(loadingImagery);
    }
    
    if (loadingImagery.state === ImageryState.RECEIVED) {
    loadingImagery.state = ImageryState.TRANSITIONING;
    imageryLayer._createTexture(context, loadingImagery);
    }
    
    if (loadingImagery.state === ImageryState.TEXTURE_LOADED) {
    loadingImagery.state = ImageryState.TRANSITIONING;
    imageryLayer._reprojectTexture(context, loadingImagery);
    }
    
    if (loadingImagery.state === ImageryState.READY) {
    if (defined(this.readyImagery)) {
    this.readyImagery.releaseReference();
    }
    this.readyImagery = this.loadingImagery;
    this.loadingImagery = undefined;
    this.textureTranslationAndScale = imageryLayer._calculateTextureTranslationAndScale(tile, this);
    return true; // done loading
    }
    
    // Find some ancestor imagery we can use while this imagery is still loading.
    var ancestor = loadingImagery.parent;
    var ancestorsAreStillLoading = false;
    while (defined(ancestor) && ancestor.state !== ImageryState.READY) {
    ancestorsAreStillLoading = ancestorsAreStillLoading || (ancestor.state !== ImageryState.FAILED && ancestor.state !== ImageryState.INVALID);
    ancestor = ancestor.parent;
    }
    
    if (this.readyImagery !== ancestor) {
    if (defined(this.readyImagery)) {
    this.readyImagery.releaseReference();
    }
    
    this.readyImagery = ancestor;
    
    if (defined(ancestor)) {
    ancestor.addReference();
    this.textureTranslationAndScale = imageryLayer._calculateTextureTranslationAndScale(tile, this);
    }
    }
    
    if (!ancestorsAreStillLoading && (loadingImagery.state === ImageryState.FAILED || loadingImagery.state === ImageryState.INVALID)) {
    // This imagery tile is failed or invalid, and we have the "best available" substitute.  So we're done loading.
    return true; // done loading
    }
    
    return false; // not done loading
    };
    
    return TileImagery;
    }*/
}