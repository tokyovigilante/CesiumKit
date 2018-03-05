//
//  HeightmapStructure.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * The default structure of a heightmap, as given to {@link HeightmapTessellator.computeVertices}.
 *
 * @constant
 */
struct HeightmapStructure {
    var heightScale = 1.0
    var heightOffset = 0.0
    var elementsPerHeight = 1
    var stride = 1
    var elementMultiplier = 256.0
    var isBigEndian = false
}
