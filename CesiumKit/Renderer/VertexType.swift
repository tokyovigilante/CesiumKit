//
//  VertexFormat.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Metal

enum VertexType: UInt {
    case Invalid
    
    case UChar2
    case UChar3
    case UChar4
    
    case Char2
    case Char3
    case Char4
    
    case UChar2Normalized
    case UChar3Normalized
    case UChar4Normalized
    
    case Char2Normalized
    case Char3Normalized
    case Char4Normalized
    
    case UShort2
    case UShort3
    case UShort4
    
    case Short2
    case Short3
    case Short4
    
    case UShort2Normalized
    case UShort3Normalized
    case UShort4Normalized
    
    case Short2Normalized
    case Short3Normalized
    case Short4Normalized
    
    case Half2
    case Half3
    case Half4
    
    case Float
    case Float2
    case Float3
    case Float4
    
    case Int
    case Int2
    case Int3
    case Int4
    
    case UInt
    case UInt2
    case UInt3
    case UInt4
    
    case Int1010102Normalized
    case UInt1010102Normalized
    
    /** VertexType: Wrapper class for MTLVertexFormat */
    var metalVertexFormat: MTLVertexFormat {
        return MTLVertexFormat(rawValue: self.rawValue)!
    }
}
