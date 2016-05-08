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
enum QuadtreeTileLoadState: CustomStringConvertible {
    /**
    * The tile is new and loading has not yet begun.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 0
    */
    case Start,
    
    /**
    * Loading is in progress.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 1
    */
    Loading,
    
    /**
    * Draw commands are being generated
    */
    GeneratingCommands,
    
    /**
    * Loading is complete.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 2
    */
    Done,
    
    /**
    * The tile has failed to load.
    * @type QuadtreeTileLoadState
    * @constant
    * @default 3
    */
    Failed
    
    var description: String {
        get {
            switch self {
            case .Start:
                return "Start"
            case .Loading:
                return "Loading"
            case .Done:
                return "Done"
            case .GeneratingCommands:
                return "GeneratingCommands"
            case .Failed:
                return "Failed"
            }
        }
    }
}
