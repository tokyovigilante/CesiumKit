//
//  TileCoordinatesImageryProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreText

/**
* An {@link ImageryProvider} that draws a box around every rendered tile in the tiling scheme, and draws
* a label inside it indicating the X, Y, Level coordinates of the tile.  This is mostly useful for
* debugging terrain and imagery rendering problems.
*
* @alias TileCoordinatesImageryProvider
* @constructor
*
* @param {Object} [options] Object with the following properties:
* @param {TilingScheme} [options.tilingScheme=new GeographicTilingScheme()] The tiling scheme for which to draw tiles.
* @param {Color} [options.color=Color.YELLOW] The color to draw the tile box and label.
* @param {Number} [options.tileWidth=256] The width of the tile for level-of-detail selection purposes.
* @param {Number} [options.tileHeight=256] The height of the tile for level-of-detail selection purposes.
*/
public class TileCoordinateImageryProvider: ImageryProvider {
    
    public struct Options {
        
        let tilingScheme: TilingScheme = GeographicTilingScheme()
        
        let color: Cartesian4 = Cartesian4.fromColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        
        let tileWidth: Int = 256
        
        let tileHeight: Int = 256
    }
    
    public let color: Cartesian4

    /**
    * The default alpha blending value of this provider, with 0.0 representing fully transparent and
    * 1.0 representing fully opaque.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultAlpha: Double = 1.0
    
    /**
    * The default brightness of this provider.  1.0 uses the unmodified imagery color.  Less than 1.0
    * makes the imagery darker while greater than 1.0 makes it brighter.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultBrightness: Double = 1.0
    
    /**
    * The default contrast of this provider.  1.0 uses the unmodified imagery color.  Less than 1.0 reduces
    * the contrast while greater than 1.0 increases it.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultContrast: Double = 1.0
    
    /**
    * The default hue of this provider in radians. 0.0 uses the unmodified imagery color.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultHue: Double = 1.0
    
    /**
    * The default saturation of this provider. 1.0 uses the unmodified imagery color. Less than 1.0 reduces the
    * saturation while greater than 1.0 increases it.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultSaturation: Double = 1.0
    
    /**
    * The default gamma correction to apply to this provider.  1.0 uses the unmodified imagery color.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultGamma: Double = 1.0
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof ImageryProvider.prototype
    * @type {Boolean}
    */
    public let ready: Bool = true
    
    /**
    * Gets the rectangle, in radians, of the imagery provided by the instance.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Rectangle}
    */
    public var rectangle: Rectangle {
        get {
            return tilingScheme.rectangle
        }
    }
    
    /**
    * Gets the height of each tile, in pixels.  This function should
    * not be called before {@link TileCoordinatesImageryProvider#ready} returns true.
    * @memberof TileCoordinatesImageryProvider.prototype
    * @type {Number}
    */
    public let tileWidth: Int
    
    /**
    * Gets the maximum level-of-detail that can be requested.  This function should
    * not be called before {@link TileCoordinatesImageryProvider#ready} returns true.
    * @memberof TileCoordinatesImageryProvider.prototype
    * @type {Number}
    */
    public let tileHeight: Int
    
    
    /**
    * Gets the maximum level-of-detail that can be requested.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Number}
    */
    public let maximumLevel = Int.max
    
    /**
    * Gets the minimum level-of-detail that can be requested.  This function should
    * not be called before {@link ImageryProvider#ready} returns true. Generally,
    * a minimum level should only be used when the rectangle of the imagery is small
    * enough that the number of tiles at the minimum level is small.  An imagery
    * provider with more than a few tiles at the minimum level will lead to
    * rendering problems.
    * @memberof ImageryProvider.prototype
    * @type {Number}
    */
    public let minimumLevel: Int? = nil
    
    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {TilingScheme}
    */
    public let tilingScheme: TilingScheme
    
    /**
    * Gets the tile discard policy.  If not undefined, the discard policy is responsible
    * for filtering out "missing" tiles via its shouldDiscardImage function.  If this function
    * returns undefined, no tiles are filtered.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {TileDiscardPolicy}
    */
    public let tileDiscardPolicy: TileDiscardPolicy? = nil
    
    /**
    * Gets an event that is raised when the imagery provider encounters an asynchronous error..  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof ImageryProvider.prototype
    * @type {Event}
    */
    public var errorEvent = Event()
    
    /**
    * Gets the credit to display when this imagery provider is active.  Typically this is used to credit
    * the source of the imagery. This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Credit}
    */
    public var credit: Credit = Credit(text: "CesiumKit")
    
    /**
    * Gets the proxy used by this provider.
    * @memberof ImageryProvider.prototype
    * @type {Proxy}
    */
    // FIXME: Disabled
    //var proxy: Proxy { get }
    
    /**
    * Gets a value indicating whether or not the images provided by this imagery provider
    * include an alpha channel.  If this property is false, an alpha channel, if present, will
    * be ignored.  If this property is true, any images without an alpha channel will be treated
    * as if their alpha is 1.0 everywhere.  When this property is false, memory usage
    * and texture upload time are reduced.
    * @memberof ImageryProvider.prototype
    * @type {Boolean}
    */
    public let hasAlphaChannel: Bool = true
    
    public init (options: TileCoordinateImageryProvider.Options = TileCoordinateImageryProvider.Options()) {
        
        tilingScheme = options.tilingScheme
        color = options.color
        tileWidth = options.tileWidth
        tileHeight = options.tileHeight
    }

    /**
    * Gets the credits to be displayed when a given tile is displayed.
    * @function
    *
    * @param {Number} x The tile X coordinate.
    * @param {Number} y The tile Y coordinate.
    * @param {Number} level The tile level;
    * @returns {Credit[]} The credits to be displayed when the tile is displayed.
    *
    * @exception {DeveloperError} <code>getTileCredits</code> must not be called before the imagery provider is ready.
    */
    public func tileCredits (#x: Int, y: Int, level: Int) -> [Credit] {
        return [credit]
    }
    
    /**
    * Requests the image for a given tile.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @function
    *
    * @param {Number} x The tile X coordinate.
    * @param {Number} y The tile Y coordinate.
    * @param {Number} level The tile level.
    * @param (Function) completion Block
    * @returns {Promise} A promise for the image that will resolve when the image is available, or
    *          undefined if there are too many active requests to the server, and the request
    *          should be retried later.  The resolved image may be either an
    *          Image or a Canvas DOM object.
    *
    * requestImage(x: 0, y: 0, level: 0) {
    * (result: Image?) in
    * if let returnedImage = Image? {
    * // process Image
    *   }
    * }
    * @exception {DeveloperError} <code>requestImage</code> must not be called before the imagery provider is ready.
    */
    public func requestImage(#x: Int, y: Int, level: Int) -> UIImage? {
        
        /*var canvas = document.createElement('canvas');
        canvas.width = 256;
        canvas.height = 256;
        var context = canvas.getContext('2d');
        
        var cssColor = this._color.toCssColorString();
        
        context.strokeStyle = cssColor;
        context.lineWidth = 2;
        context.strokeRect(1, 1, 255, 255);
        
        var label = 'L' + level + 'X' + x + 'Y' + y;
        context.font = 'bold 25px Arial';
        context.textAlign = 'center';
        context.fillStyle = 'black';
        context.fillText(label, 127, 127);
        context.fillStyle = cssColor;
        context.fillText(label, 124, 124);
        */

        let size = CGSizeMake(CGFloat(tileWidth), CGFloat(256.0))
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        
        let drawColor = UIColor(red: CGFloat(color.red), green: CGFloat(color.green), blue: CGFloat(color.blue), alpha: CGFloat(color.alpha))
        CGContextSetStrokeColorWithColor(context, drawColor.CGColor)
        
        // border
        let rect = CGRectMake(1.0, 1.0, size.width-2.0, size.height-2.0)
        CGContextClearRect(context, rect)
        CGContextStrokeRectWithWidth(context, rect, 2.0)
        
        // label
        let string = "L\(level)X\(x)Y\(y)" as NSString
        let font = UIFont(name: "Helvetica Neue", size: 25.0)
        assert(font != nil, "Could not create UIFont")

        //CGContextSetFillColorWithColor(context, drawColor)

        let attr = [NSFontAttributeName: font!, NSForegroundColorAttributeName: drawColor]
        let textSize = string.sizeWithAttributes(attr)
        
        let textRect = CGRectMake(size.width/2 - textSize.width/2, size.height/2 - textSize.height/2, textSize.width, textSize.height)
        string.drawInRect(textRect, withAttributes: attr)
        
        /*let fontAttributes: [String: String] = [
            kCTFontFamilyNameAttribute: "Helvetica Neue",
            kCTFontStyleNameAttribute: "Bold",
            kCTFontSizeAttribute: NSNumber(float: 25.0)]

        // Create a descriptor.
        let descriptor = CTFontDescriptorCreateWithAttributes(fontAttributes)
        
        // Create a font using the descriptor.
        CTFontRef font = CTFontCreateWithFontDescriptor(descriptor, 0.0, NULL);
        CFRelease(descriptor);

        
        CFStringRef string; CTFontRef font; CGContextRef context;
        // Initialize the string, font, and context
        
        CFStringRef keys[] = { kCTFontAttributeName };
        CFTypeRef values[] = { font };
        
        CFDictionaryRef attributes =
            CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys,
                (const void**)&values, sizeof(keys) / sizeof(keys[0]),
                &kCFTypeDictionaryKeyCallBacks,
                &kCFTypeDictionaryValueCallBacks);
        
        CFAttributedStringRef attrString =
            CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
        CFRelease(string);
        CFRelease(attributes);
        
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        
        // Set text position and draw the line into the graphics context
        CGContextSetTextPosition(context, 10.0, 10.0);
        CTLineDraw(line, context);
        CFRelease(line);*/

        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
}
