//
//  String.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/11/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

enum ObjectSourceReferenceType {
    case BundleResource
    case NetworkURL
    case FilePath
}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex - r.startIndex)
            
            return self[startIndex..<endIndex]
        }
    }
    
    func replace(existingString: String, _ newString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(existingString, withString: newString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func indexOf(findStr:String, startIndex: String.Index? = nil) -> String.Index? {
        return self.rangeOfString(findStr, options: [], range: nil, locale: nil)?.startIndex
    }
    
}
// FIXME: move to cubemap
extension String {
    var referenceType: ObjectSourceReferenceType {
        if self.hasPrefix("/") {
            return .FilePath
        } else if self.hasPrefix("http") {
            return .NetworkURL
        }
        return .BundleResource
    }
    
    
    func urlForSource () -> NSURL? {
        switch self.referenceType {
        case .BundleResource:
            let bundle = NSBundle(identifier: "com.testtoast.CesiumKit") ?? NSBundle.mainBundle()
            #if os(OSX)
                return bundle.URLForImageResource(self)
            #elseif os(iOS)
                return bundle.URLForResource((self as NSString).stringByDeletingPathExtension, withExtension: (self as NSString).pathExtension)
            #endif
        case .FilePath:
            return NSURL(fileURLWithPath: self, isDirectory: false)
        case .NetworkURL:
            return NSURL(string: self)
        }
    }
    
    func loadImageForCubeMapSource () -> CGImage? {

        guard let sourceURL = urlForSource() else {
            return nil
        }
        do {
            let data = try NSData(contentsOfURL: sourceURL, options: [])
            return CGImage.fromData(data)
        } catch {
            return nil
        }

    }
    
}