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
    let options: TextureOptions
    
    private var _textures = [Texture]()
    
    private var memBarrierIndex: Int = 0
    
    init (context: Context, capacity: Int, options: TextureOptions) {
        
        self.capacity = capacity
        self.options = options
        
        for _ in 0..<capacity {
            _textures.append(Texture(context: context, options: options))
        }
    }
    
    func nextTexture() -> Texture {
        let texture = _textures[memBarrierIndex]
        memBarrierIndex = (memBarrierIndex + 1) % capacity
        return texture
    }
    
}

