//
//  PixelDatatype.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 20/07/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

enum PixelDatatype: Int {
    case UnsignedByte = 0x1401,
    UnsignedShort = 0x1403,
    UnsignedInt = 0x1405,
    Float = 0x1406,
    UnsignedInt24_8 = 0x84FA,
    UnsignedShort4444 = 0x8033,
    UnsignedShort5551 = 0x8034,
    UnsignedShort565 = 0x8363
}