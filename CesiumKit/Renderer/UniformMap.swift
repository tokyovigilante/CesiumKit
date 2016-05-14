//
//  UniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

protocol UniformStruct {

}

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
    
    //FIXME: remove forced optional by creating in init
    var metalUniformUpdateBlock: ((buffer: Buffer) -> [Texture])! { get set }
    
    var uniformDescriptors: [UniformDescriptor] { get }
    
    func generateMetalUniformStruct () -> String
}

extension UniformMap {
    
    func generateMetalUniformStruct () -> String {
        
        let prefix = "struct xlatMtlShaderUniform {\n"
        let suffix = "};\n"
        let uniformDefinitions = uniformDescriptors.reduce(prefix) { $0 + "    \($1.declaration())\n" }
        
        return uniformDefinitions + suffix
    }
}



