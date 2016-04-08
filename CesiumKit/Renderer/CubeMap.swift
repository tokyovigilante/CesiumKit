//
//  CubeMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

struct CubeMapSources {
    let sources: [CGImage]
}

extension CubeMapSources {
    
    var positiveX: CGImage {
        return sources[0]
    }
    
    var negativeX: CGImage {
        return sources[1]
    }
    
    var positiveY: CGImage {
        return sources[2]
    }
    
    var negativeY: CGImage {
        return sources[3]
    }
    
    var positiveZ: CGImage {
        return sources[4]
    }
    
    var negativeZ: CGImage {
        return sources[5]
    }
    
}

class CubeMap {
    
    class func loadImagesForSources (sources: [String]) -> CubeMapSources {
        return CubeMapSources(sources: sources.flatMap { $0.loadImageForCubeMapSource() })
    }
    
}