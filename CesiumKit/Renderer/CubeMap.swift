//
//  CubeMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

struct CubeMapSources {
    let sources: [CGImageRef]
}

extension CubeMapSources {
    
    var positiveX: CGImageRef {
        return sources[0]
    }
    
    var negativeX: CGImageRef {
        return sources[1]
    }
    
    var positiveY: CGImageRef {
        return sources[2]
    }
    
    var negativeY: CGImageRef {
        return sources[3]
    }
    
    var positiveZ: CGImageRef {
        return sources[4]
    }
    
    var negativeZ: CGImageRef {
        return sources[5]
    }
    
}

class CubeMap {
    
    class func loadImagesForSources (sources: [String]) -> CubeMapSources {
        return CubeMapSources(sources: sources.flatMap { $0.loadImageForSource() })
    }
    
}