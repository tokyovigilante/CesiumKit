//
//  TerrainState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

enum TerrainState: Int, Printable {
    
    case Failed = 0,
    Unloaded,
    Receiving,
    Received,
    Transforming,
    Transformed,
    Buffering,
    Ready
    
    var description: String {
        get {
            switch self {
            case .Failed:
                return "Failed"
            case .Unloaded:
                return "Unloaded"
            case .Receiving:
                return "Receiving"
            case .Received:
                return "Received"
            case .Transforming:
                return "Transforming"
            case .Transformed:
                return "Transformed"
            case .Buffering:
                return "Buffering"
            case .Ready:
                return "Ready"
            }
        }
    }
}