//
//  NSData+ArrayView.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 26/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

extension NSData {
    
    func getFloat64(pos: Int, littleEndian: Bool = true) -> Double {
        assert(self.length >= pos + sizeof(Double), "pos out of bounds")
        var result: Double = 0.0
        getBytes(&result, range: NSMakeRange(pos, sizeof(Double)))
        return result
    }
}