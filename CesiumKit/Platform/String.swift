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
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func replace(existingString: String, _ newString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(existingString, withString: newString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func indexOf(findStr:String, startIndex: String.Index? = nil) -> String.Index? {
        return self.rangeOfString(findStr, options: [], range: nil, locale: nil)?.startIndex
    }

}