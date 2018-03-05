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
        "diffuse": "u_color.rgb",
        "alpha": "u_color.a"
    ]

    public let translucent = { (material: Material) in
        return (material.type.fabric as! ColorFabricDescription).color.alpha < 1.0
    }

    public init (fabric: ColorFabricDescription = ColorFabricDescription(), source: String? = nil) {
        self.fabric = fabric
        self.source = source
    }
}

open class FabricDescription {
    var uniformMap: LegacyUniformMap! {
        assertionFailure("invalid base class")
        return nil
    }
}

open class ColorFabricDescription: FabricDescription {

    open var color: Color {
        get {
            return _uniformMap.color
        }
        set {
            _uniformMap.color = newValue
        }
    }

    override var uniformMap: LegacyUniformMap {
        return _uniformMap
    }

    fileprivate let _uniformMap = ColorFabricUniformMap()

    public override init () {

    }
}

class ColorFabricUniformMap: LegacyUniformMap {

    var color = Color()

    var uniformBufferProvider: UniformBufferProvider! = nil

    let uniforms: [String: UniformFunc] = [
        "u_color": { map, buffer, offset in
            let simd = (map as! ColorFabricUniformMap).color.floatRepresentation
            buffer.write(from: [simd], length: MemoryLayout.size(ofValue: simd))
        }
    ]

    let uniformDescriptors = [
        UniformDescriptor(name: "u_color", type: .floatVec4, count: 1)
    ]
}





open class ImageFabricDescription: FabricDescription {

    //var uniformMap: UniformMap = NullUniformMap()

    //public var uniforms: [String: UniformFunc]

    //public var uniformTypes: [String : UniformDataType]

}
