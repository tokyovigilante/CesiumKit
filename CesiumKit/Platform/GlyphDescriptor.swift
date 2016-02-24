//
//  GlyphDescriptor.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation
import CoreGraphics

struct GlyphDescriptor {
    
    var glyphIndex: CGGlyph
    
    var topLeftTexCoord: CGPoint
    
    var bottomRightTexCoord: CGPoint
    
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
