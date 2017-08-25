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
    
    enum CodingKeys: String, CodingKey {
        case topLeft = "tl"
        case bottomRight = "br"
    }
    
    var topLeft: GlyphPoint
    
    var bottomRight: GlyphPoint
    
    init (topLeftTexCoord: CGPoint, bottomRightTexCoord: CGPoint) {
        topLeft = GlyphPoint(x: Double(topLeftTexCoord.x), y: Double(topLeftTexCoord.y))
        bottomRight = GlyphPoint(x: Double(bottomRightTexCoord.x), y: Double(bottomRightTexCoord.y))
    }
}

struct GlyphPoint: Codable {
    var x: Double
    var y: Double
}

