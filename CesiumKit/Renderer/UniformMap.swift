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
    
    var index: DictionaryIndex<String, FloatUniformFunc>? { get }

    func uniform(name: String) -> UniformFunc?
    
    subscript(name: String) -> UniformFunc? { get }
    
    func floatUniform(name: String) -> FloatUniformFunc?
    
    func floatUniform(index: DictionaryIndex<String, FloatUniformFunc>) -> FloatUniformFunc
    
    func indexForFloatUniform(name: String) -> DictionaryIndex<String, FloatUniformFunc>?
    
    func floatUniform(index: Int) -> FloatUniformFunc
    
    func textureForUniform (uniform: UniformSampler) -> Texture?
}

extension UniformMap {
    
    func uniform(name: String) -> UniformFunc? {
        return nil
    }
    
    subscript(name: String) -> UniformFunc? {
        return uniform(name)
    }
    
    func floatUniform(name: String) -> FloatUniformFunc? {
        return nil
    }
    
    func indexForFloatUniform(name: String) -> DictionaryIndex<String, FloatUniformFunc>? {
        return nil
    }
    
    func textureForUniform (uniform: UniformSampler) -> Texture? {
        return nil
    }
    
}

class NullUniformMap: UniformMap { var index: DictionaryIndex<String, FloatUniformFunc>? { return nil } }

