//
//  TextureProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

class TextureProvider {
    
    let capacity: Int
    
    private let _options: TextureOptions
    
    var width: Int {
        return _options.width
    }
    
    var height: Int {
        return _options.height
    }
    
    private let _textures: [Texture]
    
    private var memBarrierIndex: Int = 0
    
    init (context: Context, capacity: Int, options: TextureOptions) {
        
        self.capacity = capacity
        _options = options
        _textures = [Texture](count: capacity, repeatedValue: Texture(context: context, options: options))
    }
    
    func nextTexture() -> Texture {
        let texture = _textures[memBarrierIndex]
        memBarrierIndex = (memBarrierIndex + 1) % capacity
        return texture
    }
    
}

