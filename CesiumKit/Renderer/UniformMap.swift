//
//  UniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

protocol UniformStruct {

}

typealias UniformUpdateBlock = ((buffer: Buffer) -> [Texture])

typealias UniformMapDeallocBlock = (UniformBufferProvider) -> Void

struct UniformDescriptor {
    let name: String
    let type: UniformDataType
    let count: Int
    
    func declaration () -> String {
        var declaration = "\(type.metalDeclaration) \(name)"
        
        if count == 1 {
            declaration += ";"
        } else {
            declaration += "[\(count)];"
        }
        
        return declaration
    }
}

protocol UniformMap: class {
    
    var uniformBufferProvider: UniformBufferProvider! { get set }
    
    var uniformDescriptors: [UniformDescriptor] { get }

}

protocol NativeUniformMap: class, UniformMap {
    
    var uniformUpdateBlock: UniformUpdateBlock! { get }
    
    func generateMetalUniformStruct () -> String
}

extension NativeUniformMap {
    
    func generateMetalUniformStruct () -> String {
        
        let prefix = "struct xlatMtlShaderUniform {\n"
        let suffix = "};\n"
        let uniformDefinitions = uniformDescriptors.reduce(prefix) { $0 + "    \($1.declaration())\n" }
        
        return uniformDefinitions + suffix
    }
}

protocol LegacyUniformMap: class, UniformMap {
    
    var uniforms: [String: UniformFunc] { get }
    
    func indexForUniform(name: String) -> UniformIndex?
    
    func uniform(index: UniformIndex) -> UniformFunc
    
    func textureForUniform (uniform: UniformSampler) -> Texture?
}

extension LegacyUniformMap {
    
    public func indexForUniform(name: String) -> UniformIndex? {
        return uniforms.indexForKey(name)
    }
    
    public func uniform(index: UniformIndex) -> UniformFunc {
        return uniforms[index].1
    }
    
    public func textureForUniform (uniform: UniformSampler) -> Texture? {
        return nil
    }
    
}




