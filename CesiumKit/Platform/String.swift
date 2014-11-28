//
//  String.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/11/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}