//
//  UniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

protocol MetalUniformStruct {
    
}

typealias UniformMapDeallocBlock = (UniformBufferProvider) -> Void

public protocol UniformMap: class {
    
    var uniforms: [String: UniformFunc] { get }
    
    var uniformBufferProvider: UniformBufferProvider! { get set }
    
    func indexForUniform(name: String) -> UniformIndex?
    
    func uniform(index: UniformIndex) -> UniformFunc
    
    func textureForUniform (uniform: UniformSampler) -> Texture?
}

extension UniformMap {
    
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

class NullUniformMap: UniformMap {
    let uniforms = [String : UniformFunc]()
    var uniformBufferProvider: UniformBufferProvider! = nil
}

