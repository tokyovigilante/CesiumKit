//
//  String.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/11/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

enum ObjectSourceReferenceType {
    case bundleResource
    case networkURL
    case filePath
}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound - r.lowerBound)
            
            return self[startIndex..<endIndex]
        }
    }
    
    func replace(_ existingString: String, _ newString: String) -> String {
        return self.replacingOccurrences(of: existingString, with: newString, options: NSString.CompareOptions.literalSearch, range: nil)
    }
    
    func indexOf(_ findStr:String, startIndex: String.Index? = nil) -> String.Index? {
        return self.range(of: findStr, options: [], range: nil, locale: nil)?.lowerBound
    }
    
}
// FIXME: move to cubemap
extension String {
    var referenceType: ObjectSourceReferenceType {
        if self.hasPrefix("/") {
            return .filePath
        } else if self.hasPrefix("http") {
            return .networkURL
        }
        return .bundleResource
    }
    
    
    func urlForSource () -> URL? {
        switch self.referenceType {
        case .bundleResource:
            let bundle = Bundle(identifier: "com.testtoast.CesiumKit") ?? Bundle.main()
            #if os(OSX)
                return bundle.urlForImageResource(self)
            #elseif os(iOS)
                return bundle.urlForResource((self as NSString).deletingPathExtension, withExtension: (self as NSString).pathExtension)
            #endif
        case .filePath:
            return URL(fileURLWithPath: self, isDirectory: false)
        case .networkURL:
            return URL(string: self)
        }
    }
    
    func loadImageForCubeMapSource () -> CGImage? {

        guard let sourceURL = urlForSource() else {
            return nil
        }
        do {
            let data = try Data(contentsOf: sourceURL, options: [])
            return CGImage.from(data: data)
        } catch {
            return nil
        }

    }
    
}
