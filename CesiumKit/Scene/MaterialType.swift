//
//  MaterialType.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import simd

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

public class FabricDescription {
    var uniformMap: UniformMap? = nil
    
    var uniformTypes: [String: UniformDataType] {
        return [:]
    }
}

public class ColorFabricDescription: FabricDescription {
    
    public var color: Color {
        get {
            return Color(
                red: Double(uniformStruct.color.x),
                green: Double(uniformStruct.color.y),
                blue: Double(uniformStruct.color.z),
                alpha: Double(uniformStruct.color.w)
            )
        }
        set {
            uniformStruct.color = newValue.floatRepresentation
        }
    }
    
    //public let uniforms: [String: UniformFunc]
    
    //public let uniformTypes: [String : UniformDataType]
    
    var uniformStruct: ColorFabricUniformStruct
    
    public init (color: Color = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)) {
        uniformStruct = ColorFabricUniformStruct(color: color.floatRepresentation)
    }

}

struct ColorFabricUniformStruct: UniformStruct {
    var color: float4
}


public class ImageFabricDescription: FabricDescription {
    
    //var uniformMap: UniformMap = NullUniformMap()

    //public var uniforms: [String: UniformFunc]
    
    //public var uniformTypes: [String : UniformDataType]
    
}
