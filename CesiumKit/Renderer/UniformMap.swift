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

    func uniform(name: String) -> UniformFunc?
    
    subscript(name: String) -> UniformFunc? { get }
    
    func floatUniform(name: String) -> FloatUniformFunc?
    
    func textureForUniform (uniform: UniformSampler) -> Texture?
}

extension UniformMap {
    
    subscript(name: String) -> UniformFunc? {
        get {
            return uniform(name)
        }
    }

}