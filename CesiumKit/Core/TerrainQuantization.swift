//
//  TerrainQuantization.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

/**
 * This enumerated type is used to determine how the vertices of the terrain mesh are compressed.
 *
 * @exports TerrainQuantization
 *
 * @private
 */
import Foundation

enum TerrainQuantization {
    /**
     * The vertices are not compressed.
     *
     * @type {Number}
     * @constant
     */
    case none
    
    /**
     * The vertices are compressed to 12 bits.
     *
     * @type {Number}
     * @constant
     */
    case bits12
}
