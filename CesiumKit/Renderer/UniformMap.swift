//
//  UniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

typealias UniformFunc = (map: UniformMap) -> [Any]
typealias FloatUniformFunc = (map: UniformMap) -> [Float]

protocol UniformMap {
    
    var floatUniforms: [String: FloatUniformFunc] { get }
    
    func uniform(name: String) -> UniformFunc?
    
    subscript(name: String) -> UniformFunc? { get }
    
    func indexForFloatUniform(name: String) -> UniformIndex?
    
    func floatUniform(index: UniformIndex) -> FloatUniformFunc
    
    func textureForUniform (uniform: UniformSampler) -> Texture?
}

extension UniformMap {
    
    func uniform(name: String) -> UniformFunc? {
        return nil
    }
    
    subscript(name: String) -> UniformFunc? {
        return uniform(name)
    }
    
    func indexForFloatUniform(name: String) -> UniformIndex? {
        return floatUniforms.indexForKey(name)
    }
    
    func floatUniform(index: UniformIndex) -> FloatUniformFunc {
        return floatUniforms[index].1
    }
    
    func textureForUniform (uniform: UniformSampler) -> Texture? {
        return nil
    }
    
}

class NullUniformMap: UniformMap { let floatUniforms = [String : FloatUniformFunc]() }

