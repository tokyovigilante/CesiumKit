//
//  UniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

public protocol UniformMap {
    
    var uniforms: [String: UniformFunc] { get } 
    
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

class NullUniformMap: UniformMap { let uniforms = [String : UniformFunc]() }

