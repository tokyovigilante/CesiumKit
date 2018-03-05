//
//  QuadtreeTileLoadState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//
/**
* The state of a {@link QuadtreeTile} in the tile load pipeline.
* @exports QuadtreeTileLoadState
* @private
*/
enum TileLoadState: CustomStringConvertible {
    /**
    * The tile is new and loading has not yet begun.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 0
    */
    case start,

    /**
    * Loading is in progress.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 1
    */
    loading,

    /**
    * Draw commands are being generated
    */
    generatingCommands,

    /**
    * Loading is complete.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 2
    */
    done,

    /**
    * The tile has failed to load.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 3
    */
    failed

    var description: String {
        get {
            switch self {
            case .start:
                return "Start"
            case .loading:
                return "Loading"
            case .done:
                return "Done"
            case .generatingCommands:
                return "GeneratingCommands"
            case .failed:
                return "Failed"
            }
        }
    }
}
