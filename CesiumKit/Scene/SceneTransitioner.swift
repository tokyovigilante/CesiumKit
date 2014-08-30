//
//  SceneTransitioner.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

class SceneTransitioner {
    
    weak var owner: Scene?
    
    init (owner: Scene) {
        
        self.owner = owner
    }
}