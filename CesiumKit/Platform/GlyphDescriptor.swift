//
//  GlyphDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CoreGraphics

private let GlyphIndexKey = "g"
private let TopLeftTexCoordKey = "tl"
private let BottomRightTexCoordKey = "br"

struct GlyphDescriptor: JSONEncodable {
    
    var glyphIndex: CGGlyph
    
    var topLeftTexCoord: CGPoint
    
    var bottomRightTexCoord: CGPoint
    
    init (glyphIndex: CGGlyph, topLeftTexCoord: CGPoint, bottomRightTexCoord: CGPoint) {
        self.glyphIndex = glyphIndex
        self.topLeftTexCoord = topLeftTexCoord
        self.bottomRightTexCoord = bottomRightTexCoord
    }
    
    init (fromJSON json: JSON) throws {
        self.glyphIndex = try UInt16(json.getInt(GlyphIndexKey))
        self.topLeftTexCoord = try CGPoint(fromJSON: JSON.object(json.getObject(TopLeftTexCoordKey)))
        self.bottomRightTexCoord = try CGPoint(fromJSON: JSON.object(json.getObject(BottomRightTexCoordKey)))
    }
    
    func toJSON() -> JSON {
        let json = JSON.object(JSONObject([
            GlyphIndexKey: JSON(integerLiteral: Int64(glyphIndex)),
            TopLeftTexCoordKey: topLeftTexCoord.toJSON(),
            BottomRightTexCoordKey: bottomRightTexCoord.toJSON()
        ]))
        return json
    }
    
}

extension CGPoint: JSONEncodable {
    
    init (fromJSON json: JSON) throws {
        self.x = try CGFloat(json.getDouble("x"))
        self.y = try CGFloat(json.getDouble("y"))
    }
    
    func toJSON() -> JSON {
        let json = JSON.object(JSONObject([
            "x": JSON(floatLiteral: Double(x)),
            "y": JSON(floatLiteral: Double(y))
            ]))
        return json
    }
}
