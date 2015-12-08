//
//  CubeMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

class CubeMap {
    
    class func loadImagesForSources (sources: [String]) -> CubeMapSources
    {
        let sourceURLs = urlsForSources(sources)
        let cgImageSources = sourceURLs.map({ CGImageRef.fromURL($0)! })

        return CubeMapSources(sources: cgImageSources)
    }
    
    private class func urlsForSources (sources: [String]) -> [NSURL] {
        let type = sources[0].referenceType
        
        let sourceURLs: [NSURL]
        let bundle = NSBundle(identifier: "com.testtoast.CesiumKit") ?? NSBundle.mainBundle()
        switch type {
        case .BundleResource:
            sourceURLs = sources.map({ bundle.URLForImageResource($0)! })
        case .FilePath:
            sourceURLs = sources.map({ NSURL(fileURLWithPath: $0, isDirectory: false) })
        case .NetworkURL:
            sourceURLs = sources.map({ NSURL(string: $0)! })
        }
        return sourceURLs
    }
}