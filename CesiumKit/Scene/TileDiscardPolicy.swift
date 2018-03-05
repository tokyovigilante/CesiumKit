//
//  TileDiscardPolicy.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import CoreGraphics

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
public protocol TileDiscardPolicy {

    /**
    * Determines if the discard policy is ready to process images.
    * @function
    *
    * @returns {Boolean} True if the discard policy is ready to process images; otherwise, false.
    */
    var isReady: Bool { get }

    /**
    * Given a tile image, decide whether to discard that image.
    * @function
    *
    * @param {Image} image An image to test.
    * @returns {Boolean} True if the image should be discarded; otherwise, false.
    */
    func shouldDiscardImage (_ image: CGImage) -> Bool
}
