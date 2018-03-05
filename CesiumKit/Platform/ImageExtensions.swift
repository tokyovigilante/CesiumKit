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
                guard let imageData = tiffRepresentation else {
                    return nil
                }
                guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
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
    class func loadFromURL (_ url: String, completionBlock: @escaping (CGImage?, NSError?) -> ()) {

        let imageOperation = NetworkOperation(url: url)
        imageOperation.completionBlock = {
            if let error = imageOperation.error {
                completionBlock(nil, error)
            }
            completionBlock(CGImage.from(imageOperation.data), nil)
        }
        imageOperation.enqueue()
    }

    class func from(_ data: Data) -> CGImage? {
        #if os(OSX)
            let nsImage = NSImage(data: data)
            return nsImage?.cgImage
        #elseif os(iOS)
            let uiImage = UIImage(data: data)
            return uiImage?.cgImage
        #endif
    }

    func renderToPixelArray (colorSpace cs: CGColorSpace, premultiplyAlpha: Bool, flipY: Bool) -> (array: [UInt8], bytesPerRow: Int)? {

        let width = self.width
        let height = self.height
        let bitsPerComponent = self.bitsPerComponent
        let numberOfComponents = 4

        let bytesPerPixel = (bitsPerComponent * numberOfComponents + 7)/8

        let bytesPerRow = bytesPerPixel * width

        let alphaInfo: CGImageAlphaInfo
        if bytesPerPixel == 1 {
            // no alpha info in single byte pixel array
            alphaInfo = .none
        } else if premultiplyAlpha {
            alphaInfo = .premultipliedLast
        } else {
            alphaInfo = .last
        }

        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: alphaInfo.rawValue)]

        let pixelBuffer = [UInt8](repeating: 0, count: bytesPerRow * height) // if 4 components per pixel (RGBA)

        guard let bitmapContext = CGContext(data: UnsafeMutableRawPointer(mutating: pixelBuffer), width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: cs, bitmapInfo: bitmapInfo.rawValue) else {
                assertionFailure("bitmapContext == nil")
                return nil
        }

        let imageRect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))

        if flipY {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(height))
            bitmapContext.concatenate(flipVertical)
        }
        bitmapContext.draw(self, in: imageRect)
        return (pixelBuffer, bytesPerRow)
    }
}

