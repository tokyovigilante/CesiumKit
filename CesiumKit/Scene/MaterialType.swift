//
//  MaterialType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

public protocol MaterialType {
    var name: String { get }
    var fabric: FabricDescription { get }
    var source: String? { get }
    var components: [String: String] { get }
    var translucent: (Material) -> Bool { get }
}

public struct ColorMaterialType: MaterialType {
    
    public let name = "Color"
    
    public var fabric: FabricDescription
    
    public var source: String? = nil
    
    public let components = [
        "diffuse": "color.rgb",
        "alpha": "color.a"
    ]
    
    public let translucent = { (material: Material) in
        return (material.type.fabric as! ColorFabricDescription).color.alpha < 1.0
    }
    
    public init (fabric: ColorFabricDescription = ColorFabricDescription(), source: String? = nil) {
        self.fabric = fabric
        self.source = source
    }
}

public protocol FabricDescription: UniformMap {
    var uniformTypes: [String: UniformDataType] { get }
}

public struct ColorFabricDescription: FabricDescription {
    
    public var color: Color
    
    public let uniforms: [String: UniformFunc]
    
    public let uniformTypes: [String : UniformDataType]
    
    public init (color: Color = Color(fromRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) {
        
        self.color = color
        
        uniforms = [
            "color": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
                let simd = (map as! ColorFabricDescription).color.floatRepresentation
                memcpy(buffer, [simd], strideofValue(simd))
            }
        ]
        
        uniformTypes = [
                "color": .FloatVec4
        ]
    }
}

public struct ImageFabricDescription: FabricDescription {
    public var uniforms: [String: UniformFunc]
    
    public var uniformTypes: [String : UniformDataType]
    
}
