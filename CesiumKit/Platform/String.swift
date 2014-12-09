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
    
    func replace(existingString: String, _ newString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(existingString, withString: newString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func indexOf(findStr:String, startIndex: String.Index? = nil) -> String.Index? {
        return self.rangeOfString(findStr, options: nil, range: nil, locale: nil)?.startIndex
        /*var startInd = startIndex ?? self.startIndex
        // check first that the first character of search string exists
        if contains(self, first(findStr)!) {
        // if so set this as the place to start searching
        startInd = find(self,first(findStr)!)!
        }
        else {
        // if not return empty array
        return nil
        }
        var i = distance(self.startIndex, startInd)
        while i<=countElements(self)-countElements(findStr) {
        if self[advance(self.startIndex, i)..<advance(self.startIndex, i+countElements(findStr))] == findStr {
        return advance(self.startIndex, i)
        }
        i++
        }
        return nil*/
    }

}