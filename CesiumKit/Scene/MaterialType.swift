//
//  MaterialType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

public struct ColorFabricDescription {
    var color: Color
}

public struct ImageFabricDescription {
    var path: String
}

public enum FabricType {
    
    case Color(ColorFabricDescription)
    
    case Image(ImageFabricDescription)
}