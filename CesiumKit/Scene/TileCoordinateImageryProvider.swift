//
//  TileCoordinatesImageryProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/02/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import CoreGraphics
import CoreText
import Foundation

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
* @param {Ellipsoid} [options.ellipsoid] The ellipsoid.  If the tilingScheme is specified,
*                    this parameter is ignored and the tiling scheme's ellipsoid is used instead. If neither
*                    parameter is specified, the WGS84 ellipsoid is used.
* @param {Color} [options.color=Color.YELLOW] The color to draw the tile box and label.
* @param {Number} [options.tileWidth=256] The width of the tile for level-of-detail selection purposes.
* @param {Number} [options.tileHeight=256] The height of the tile for level-of-detail selection purposes.
*/
open class TileCoordinateImageryProvider: ImageryProvider {
    
    public struct Options {
        
        let tilingScheme: TilingScheme = GeographicTilingScheme()
        
        let ellipsoid: Ellipsoid = Ellipsoid.wgs84
        
        let color = Cartesian4(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        
        let tileWidth: Int = 256
        
        let tileHeight: Int = 256
    }
    
    var color: Cartesian4 {
        get {
            return Cartesian4.unpack(_colorArray.map { Float($0) })
        }
        set (newColor) {
            _colorArray = newColor
                .toArray()
                .map { CGFloat($0) }
        }
    }

    fileprivate var _colorArray: [CGFloat]!

    /**
    * The default alpha blending value of this provider, with 0.0 representing fully transparent and
    * 1.0 representing fully opaque.
    *
    * @type {Number}
    * @default undefined
    */
    open let defaultAlpha: Float = 1.0
    
    /**
    * The default brightness of this provider.  1.0 uses the unmodified imagery color.  Less than 1.0
    * makes the imagery darker while greater than 1.0 makes it brighter.
    *
    * @type {Number}
    * @default undefined
    */
    open let defaultBrightness: Float = 1.0
    
    /**
    * The default contrast of this provider.  1.0 uses the unmodified imagery color.  Less than 1.0 reduces
    * the contrast while greater than 1.0 increases it.
    *
    * @type {Number}
    * @default undefined
    */
    open let defaultContrast: Float = 1.0
    
    /**
    * The default hue of this provider in radians. 0.0 uses the unmodified imagery color.
    *
    * @type {Number}
    * @default undefined
    */
    open let defaultHue: Float = 1.0
    
    /**
    * The default saturation of this provider. 1.0 uses the unmodified imagery color. Less than 1.0 reduces the
    * saturation while greater than 1.0 increases it.
    *
    * @type {Number}
    * @default undefined
    */
    open let defaultSaturation: Float = 1.0
    
    /**
    * The default gamma correction to apply to this provider.  1.0 uses the unmodified imagery color.
    *
    * @type {Number}
    * @default undefined
    */
    open let defaultGamma: Float = 1.0
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof ImageryProvider.prototype
    * @type {Boolean}
    */
    open let ready: Bool = true
    
    /**
    * Gets the rectangle, in radians, of the imagery provided by the instance.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Rectangle}
    */
    open var rectangle: Rectangle {
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
    open let tileWidth: Int
    
    /**
    * Gets the maximum level-of-detail that can be requested.  This function should
    * not be called before {@link TileCoordinatesImageryProvider#ready} returns true.
    * @memberof TileCoordinatesImageryProvider.prototype
    * @type {Number}
    */
    open let tileHeight: Int
    
    
    /**
    * Gets the maximum level-of-detail that can be requested.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Number}
    */
    open let maximumLevel = Int.max
    
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
    open let minimumLevel: Int? = nil
    
    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {TilingScheme}
    */
    open let tilingScheme: TilingScheme
    
    /**
    * Gets the tile discard policy.  If not undefined, the discard policy is responsible
    * for filtering out "missing" tiles via its shouldDiscardImage function.  If this function
    * returns undefined, no tiles are filtered.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {TileDiscardPolicy}
    */
    open let tileDiscardPolicy: TileDiscardPolicy? = nil
    
    /**
    * Gets an event that is raised when the imagery provider encounters an asynchronous error..  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof ImageryProvider.prototype
    * @type {Event}
    */
    open var errorEvent = Event()
    
    /**
    * Gets the credit to display when this imagery provider is active.  Typically this is used to credit
    * the source of the imagery. This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Credit}
    */
    open var credit: Credit? = nil
    
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
    open let hasAlphaChannel: Bool = true
    
    public init (options: TileCoordinateImageryProvider.Options) {
        
        tilingScheme = options.tilingScheme
        tileWidth = options.tileWidth
        tileHeight = options.tileHeight
        color = options.color
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
    open func tileCredits (x: Int, y: Int, level: Int) -> [Credit] {
        return [credit].flatMap { $0 }
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
    open func requestImage(x: Int, y: Int, level: Int, completionBlock: @escaping ((CGImage?) -> Void)) {
    
        logPrint(.debug, "request for imagery L\(level)X\(x)Y\(y)")
        let bytesPerPixel: Int = 4
        let bytesPerRow = bytesPerPixel * tileWidth
        let bitsPerComponent = 8
        
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        
        let bitmapInfo: CGBitmapInfo = [.byteOrder32Big]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let contextRef = CGContext(data: nil, width: tileWidth, height: tileHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue | alphaInfo.rawValue) else {
            assertionFailure("contextRef == nil")
            return
        }
                
        let rgbSpace = CGColorSpaceCreateDeviceRGB()
        let drawColor = CGColor(colorSpace: rgbSpace, components: _colorArray)
        
        contextRef.setStrokeColor(drawColor!)
        
        let borderRect = CGRect(x: 1.0, y: 1.0, width: CGFloat(tileWidth-2), height: CGFloat(tileHeight-2))
        contextRef.clear(borderRect)
        contextRef.stroke(borderRect, width: 2.0)
        
        let tileString = "L\(level)X\(x)Y\(y)"
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), tileString as CFString!)
        
        let font = CTFontCreateWithName("HelveticaNeue" as CFString, 36, nil)
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font)

        contextRef.setFillColor(drawColor!)
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorFromContextAttributeName, kCFBooleanTrue)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString!)
        var fitRange = CFRangeMake(0, 0)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, borderRect.size, &fitRange)
        
        let pathZeroX = borderRect.size.width / 2 - textSize.width / 2
        let pathZeroY = borderRect.size.height / 2 - textSize.height / 2
        let pathRect = CGRect(x: pathZeroX, y: pathZeroY, width: textSize.width, height: textSize.height)
        
        let path = CGMutablePath()
        path.addRect(pathRect)
        
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        CTFrameDraw(frame, contextRef)
        
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(tileHeight))
        contextRef.concatenate(flipVertical)
    
        completionBlock(contextRef.makeImage())

    }
    
}
