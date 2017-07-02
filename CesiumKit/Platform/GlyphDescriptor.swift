//
//  GlyphDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CoreGraphics

struct GlyphDescriptor: Codable {
    
    var glyphIndex: Int
    
    var tl: GlyphPoint
    
    var br: GlyphPoint
    
    init (glyphIndex: CGGlyph, topLeftTexCoord: CGPoint, bottomRightTexCoord: CGPoint) {
        self.glyphIndex = Int(glyphIndex)
        self.tl = GlyphPoint(x: Float(topLeftTexCoord.x), y: Float(topLeftTexCoord.y))
        self.br = GlyphPoint(x: Float(bottomRightTexCoord.x), y: Float(bottomRightTexCoord.y))
    }
}

struct GlyphPoint: Codable {
    var x: Float
    var y: Float
}

