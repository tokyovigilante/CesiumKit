//
//  MaterialType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

public protocol MaterialDescription {
    var fabric: FabricDescription { get }
    var components: [String: String] { get }
    var translucent: (Material) -> Bool { get }
}

public struct ColorMaterialDescription: MaterialDescription {
    
    public var fabric: FabricDescription
    
    public let components = [
        "diffuse": "color.rgb",
        "alpha": "color.a"
    ]
    
    public let translucent = { (material: Material) in
        return false//(material.fabric as ColorFabricDescription).color.alpha < 1.0
    }
}

public protocol FabricDescription: UniformMap {}

public struct ColorFabricDescription: FabricDescription {
    
    var color: Color = Color(1.0, 1.0, 1.0, 1.0)
    
    public var uniforms: [String: UniformFunc] = [
        "color": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            
        }
    ]
}

public struct ImageFabricDescription: FabricDescription {
    public var uniforms: [String: UniformFunc]
}

public enum MaterialType {
    
    case Color(ColorMaterialDescription)
    
    //case Image(ImageMaterialDescription)
}