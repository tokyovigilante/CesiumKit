//
//  ImageryState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 16/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

enum ImageryState {
    case Unloaded,
    Transitioning,
    Received,
    TextureLoaded,
    Reprojected,
    Ready,
    Failed,
    Invalid,
    PlaceHolder
}

