//
//  TileDiscardPolicy.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* A policy for discarding tile images according to some criteria.  This type describes an
* interface and is not intended to be instantiated directly.
*
* @alias TileDiscardPolicy
* @constructor
*
* @see DiscardMissingTileImagePolicy
* @see NeverTileDiscardPolicy
*/
protocol TileDiscardPolicy {
    
    /**
    * Determines if the discard policy is ready to process images.
    * @function
    *
    * @returns {Boolean} True if the discard policy is ready to process images; otherwise, false.
    */
    var isReady: Bool
    
    /**
    * Given a tile image, decide whether to discard that image.
    * @function
    *
    * @param {Image|Promise} image An image, or a promise that will resolve to an image.
    * @returns {Boolean} A promise that will resolve to true if the tile should be discarded.
    */
    func shouldDiscardImage (image: Image) -> Bool
}