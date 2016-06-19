//
//  GlyphDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CoreGraphics

private let GlyphIndexKey = "glyphIndex"
private let TopLeftTexCoordKey = "topLeftTexCoord"
private let BottomRightTexCoordKey = "bottomRightTexCoord"

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
        self.glyphIndex = try UInt16(json.getInt(key: GlyphIndexKey))
        self.topLeftTexCoord = try CGPoint(fromJSON: JSON.Object(json.getObject(key: TopLeftTexCoordKey)))
        self.bottomRightTexCoord = try CGPoint(fromJSON: JSON.Object(json.getObject(key: BottomRightTexCoordKey)))
    }
    
    func toJSON() -> JSON {
        let json = JSON.Object(JSONObject([
            GlyphIndexKey: JSON(integerLiteral: Int64(glyphIndex)),
            TopLeftTexCoordKey: topLeftTexCoord.toJSON(),
            BottomRightTexCoordKey: bottomRightTexCoord.toJSON()
        ]))
        return json
    }
    
}

extension CGPoint: JSONEncodable {
    
    init (fromJSON json: JSON) throws {
        self.x = try CGFloat(json.getDouble(key: "x"))
        self.y = try CGFloat(json.getDouble(key: "y"))
    }
    
    func toJSON() -> JSON {
        let json = JSON.Object(JSONObject([
            "x": JSON(floatLiteral: Double(x)),
            "y": JSON(floatLiteral: Double(y))
            ]))
        return json
    }
}
