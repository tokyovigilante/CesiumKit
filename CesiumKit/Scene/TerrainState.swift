//
//  TerrainState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

enum TerrainState {
    
    case Failed,
    Unloaded,
    Receiving,
    Received,
    Transforming,
    Transformed,
    Ready
}