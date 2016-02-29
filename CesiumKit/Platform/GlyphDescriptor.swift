//
//  GlyphDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CoreGraphics

struct GlyphDescriptor: JSONEncodable {
    
    var glyphIndex: CGGlyph
    
    var topLeftTexCoord: CGPoint
    
    var bottomRightTexCoord: CGPoint
    
    init (glyphIndex: CGGlyph, topLeftTexCoord: CGPoint, bottomRightTexCoord: CGPoint) {
        self.glyphIndex = glyphIndex
        self.topLeftTexCoord = topLeftTexCoord
        self.bottomRightTexCoord = bottomRightTexCoord
    }
    
    init (json: JSONObject) throws {
        self.glyphIndex = try UInt16(json.getInt("glyphIndex"))
        self.topLeftTexCoord = try CGPoint(json: json.getObject("topLeftTexCoord"))
        self.bottomRightTexCoord = try CGPoint(json: json.getObject("bottomRightTexCoord"))
    }
    
    func toJSON() -> JSONObject {
        let object = JSONObject([
            "glyphIndex": JSON(integerLiteral: Int64(glyphIndex)),
            "topLeftTexCoord": JSON.Object(topLeftTexCoord.toJSON()),
            "bottomRightTexCoord": JSON.Object(bottomRightTexCoord.toJSON())
        ])
        return object
    }
    /*- (instancetype)initWithCoder:(NSCoder *)aDecoder
     {
     if ((self = [super init]))
     {
     _glyphIndex = [aDecoder decodeIntForKey:MBEGlyphIndexKey];
     _topLeftTexCoord.x = [aDecoder decodeFloatForKey:MBELeftTexCoordKey];
     _topLeftTexCoord.y = [aDecoder decodeFloatForKey:MBETopTexCoordKey];
     _bottomRightTexCoord.x = [aDecoder decodeFloatForKey:MBERightTexCoordKey];
     _bottomRightTexCoord.y = [aDecoder decodeFloatForKey:MBEBottomTexCoordKey];
     }
     
     return self;
     }
     
     - (void)encodeWithCoder:(NSCoder *)aCoder
     {
     [aCoder encodeInt:self.glyphIndex forKey:MBEGlyphIndexKey];
     [aCoder encodeFloat:self.topLeftTexCoord.x forKey:MBELeftTexCoordKey];
     [aCoder encodeFloat:self.topLeftTexCoord.y forKey:MBETopTexCoordKey];
     [aCoder encodeFloat:self.bottomRightTexCoord.x forKey:MBERightTexCoordKey];
     [aCoder encodeFloat:self.bottomRightTexCoord.y forKey:MBEBottomTexCoordKey];
     }*/
}

extension CGPoint: JSONEncodable {
    
    init (json: JSONObject) throws {
        self.x = try CGFloat(json.getDouble("x"))
        self.y = try CGFloat(json.getDouble("y"))
    }
    
    func toJSON() -> JSONObject {
        let object = JSONObject([
            "x": JSON(floatLiteral: Double(x)),
            "y": JSON(floatLiteral: Double(y))
            ])
        return object
    }
}
