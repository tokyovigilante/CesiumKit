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
        var cgImage: CGImage? {
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
#elseif os(iOS)
    import UIKit.UIImage
#endif

extension CGImage {
    class func fromURL (url: NSURL) -> CGImage? {
        if let imageData = NSData(contentsOfURL: url) {
        #if os(OSX)
            let nsImage = NSImage(data: imageData)
            return nsImage?.cgImage
        #elseif os(iOS)
            let uiImage = UIImage(data: imageData)
            return uiImage?.CGImage
        #endif
        }
        return nil
    }
    
    func renderToPixelArray (colorSpace cs: CGColorSpace, premultiplyAlpha: Bool, flipY: Bool) -> (array: [UInt8], bytesPerRow: Int) {
        //Extract info for your image
        let width = CGImageGetWidth(self)
        let height = CGImageGetHeight(self)
        let bytesPerPixel: Int = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        
        let alphaInfo = premultiplyAlpha ? CGImageAlphaInfo.PremultipliedLast : CGImageAlphaInfo.None
        
        var rawBitmapInfo = CGBitmapInfo.ByteOrder32Big.rawValue
        
        rawBitmapInfo &= ~CGBitmapInfo.AlphaInfoMask.rawValue
        rawBitmapInfo |= CGBitmapInfo(rawValue: alphaInfo.rawValue).rawValue
        
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        
        
        // Allocate a textureData with the above properties:
        let pixelBuffer = [UInt8](count: bytesPerRow * height, repeatedValue: 0) // if 4 components per pixel (RGBA)
        
        let contextRef = CGBitmapContextCreate(UnsafeMutablePointer<Void>(pixelBuffer), width, height, bitsPerComponent, bytesPerRow, cs, bitmapInfo.rawValue)
        assert(contextRef != nil, "contextRef == nil")
        let imageRect = CGRectMake(CGFloat(0), CGFloat(0), CGFloat(width), CGFloat(height))
        if flipY {
            let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, CGFloat(height))
            CGContextConcatCTM(contextRef, flipVertical)
        }
        CGContextDrawImage(contextRef, imageRect, self)
        return (pixelBuffer, bytesPerRow)
    }

}

