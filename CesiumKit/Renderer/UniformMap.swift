//
//  UniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

typealias UniformFunc = (map: UniformMap) -> [Any]

protocol UniformMap {

    func uniform(name: String) -> UniformFunc?
    
    subscript(name: String) -> UniformFunc? { get }
    
}

