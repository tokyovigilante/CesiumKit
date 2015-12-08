//
//  Extensions.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 4/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit.NSImage
    
    extension NSImage {
        var CGImage: CGImageRef? {
            get {
                guard let imageData = self.TIFFRepresentation else {
                    return nil
                }
                guard let source = CGImageSourceCreateWithData(imageData, nil) else {
                    return nil
                }
                let maskRef = CGImageSourceCreateImageAtIndex(source, 0, nil)
                return maskRef
            }
        }
    }

    extension CGImageRef {
        func fromFile (file: String) -> CGImageRef? {
            return nil
        }
    }
#endif

