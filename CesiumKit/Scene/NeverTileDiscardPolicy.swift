//
//  NeverTileDiscardPolicy.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation

/**
* A {@link TileDiscardPolicy} specifying that tile images should never be discard.
*
* @alias NeverTileDiscardPolicy
* @constructor
*
* @see DiscardMissingTileImagePolicy
*/
class NeverTileDiscardPolicy: TileDiscardPolicy {
    
    /**
    * Determines if the discard policy is ready to process images.
    * @returns True if the discard policy is ready to process images; otherwise, false.
    */
    var isReady: Bool {
        get {
            return true
        }
    }
    
    /**
    * Given a tile image, decide whether to discard that image.
    *
    * @param {Image|Promise} image An image, or a promise that will resolve to an image.
    * @returns A promise that will resolve to true if the tile should be discarded.
    */
    func shouldDiscardImage (_ image: CGImage) -> Bool {
        return false
    }
}
