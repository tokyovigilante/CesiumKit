//
//  TerrainState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

enum TerrainState: Int, CustomStringConvertible {

    case failed = 0,
    unloaded,
    receiving,
    received,
    transforming,
    transformed,
    buffering,
    ready

    var description: String {
        get {
            switch self {
            case .failed:
                return "Failed"
            case .unloaded:
                return "Unloaded"
            case .receiving:
                return "Receiving"
            case .received:
                return "Received"
            case .transforming:
                return "Transforming"
            case .transformed:
                return "Transformed"
            case .buffering:
                return "Buffering"
            case .ready:
                return "Ready"
            }
        }
    }
}
