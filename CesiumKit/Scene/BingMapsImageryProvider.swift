 //
//  BingMapsImageryProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
#if os(OSX)
import AppKit.NSImage
#endif
 
 private struct AttributionArea {
    
    var zoomMin: Int
    
    var zoomMax: Int
    
    var bbox: Rectangle
    
 }
 
 private struct Attribution {
    
    var attribution: Credit
    
    var areas: [AttributionArea]
 }

/**
* Provides tiled imagery using the Bing Maps Imagery REST API.
*
* @alias BingMapsImageryProvider
* @constructor
*
* @param {Object} options Object with the following properties:
* @param {String} options.url The url of the Bing Maps server hosting the imagery.
* @param {String} [options.key] The Bing Maps key for your application, which can be
*        created at {@link https://www.bingmapsportal.com/}.
*        If this parameter is not provided, {@link BingMapsApi.defaultKey} is used.
*        If {@link BingMapsApi.defaultKey} is undefined as well, a message is
*        written to the console reminding you that you must create and supply a Bing Maps
*        key as soon as possible.  Please do not deploy an application that uses
*        Bing Maps imagery without creating a separate key for your application.
* @param {String} [options.tileProtocol] The protocol to use when loading tiles, e.g. 'http:' or 'https:'.
*        By default, tiles are loaded using the same protocol as the page.
* @param {String} [options.mapStyle=BingMapsStyle.AERIAL] The type of Bing Maps
*        imagery to load.
* @param {String} [options.culture=''] The culture to use when requesting Bing Maps imagery. Not
*        all cultures are supported. See {@link http://msdn.microsoft.com/en-us/library/hh441729.aspx}
*        for information on the supported cultures.
* @param {TileDiscardPolicy} [options.tileDiscardPolicy] The policy that determines if a tile
*        is invalid and should be discarded.  If this value is not specified, a default
*        {@link DiscardMissingTileImagePolicy} is used which requests
*        tile 0,0 at the maximum tile level and checks pixels (0,0), (120,140), (130,160),
*        (200,50), and (200,200).  If all of these pixels are transparent, the discard check is
*        disabled and no tiles are discarded.  If any of them have a non-transparent color, any
*        tile that has the same values in these pixel locations is discarded.  The end result of
*        these defaults should be correct tile discarding for a standard Bing Maps server.  To ensure
*        that no tiles are discarded, construct and pass a {@link NeverTileDiscardPolicy} for this
*        parameter.
* @param {Proxy} [options.proxy] A proxy to use for requests. This object is
*        expected to have a getURL function which returns the proxied URL, if needed.
*
* @see ArcGisMapServerImageryProvider
* @see GoogleEarthImageryProvider
* @see OpenStreetMapImageryProvider
* @see SingleTileImageryProvider
* @see TileMapServiceImageryProvider
* @see WebMapServiceImageryProvider
*
* @see {@link http://msdn.microsoft.com/en-us/library/ff701713.aspx|Bing Maps REST Services}
* @see {@link http://www.w3.org/TR/cors/|Cross-Origin Resource Sharing}
*
* @example
* var bing = new Cesium.BingMapsImageryProvider({
*     url : '//dev.virtualearth.net',
*     key : 'get-yours-at-https://www.bingmapsportal.com/',
*     mapStyle : Cesium.BingMapsStyle.AERIAL
* });
*/
public class BingMapsImageryProvider: ImageryProvider {
    
    public struct Options {
        
        public let queue: DispatchQueue? = nil
        
        public let url: String
        
        public let tileProtocol: String
        
        public let mapStyle: BingMapsStyle
        
        public let culture: String
        
        public let tileDiscardPolicy: TileDiscardPolicy?
        
        public let ellipsoid: Ellipsoid
        
        public init (url: String = "//dev.virtualearth.net", key: String? = nil, tileProtocol: String = "https:", mapStyle: BingMapsStyle = .Aerial, culture: String = "", tileDiscardPolicy: TileDiscardPolicy? = NeverTileDiscardPolicy(), ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
            self.url = url
            self.tileProtocol = tileProtocol
            self.mapStyle = mapStyle
            self.culture = culture
            self.tileDiscardPolicy = tileDiscardPolicy
            self.ellipsoid = ellipsoid
        }
    }
    
    /**
    * The default alpha blending value of this provider, with 0.0 representing fully transparent and
    * 1.0 representing fully opaque.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultAlpha: Float = 1.0
    /**
    * The default brightness of this provider.  1.0 uses the unmodified imagery color.  Less than 1.0
    * makes the imagery darker while greater than 1.0 makes it brighter.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultBrightness: Float = 1.0
    
    /**
    * The default contrast of this provider.  1.0 uses the unmodified imagery color.  Less than 1.0 reduces
    * the contrast while greater than 1.0 increases it.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultContrast: Float = 1.0
    
    /**
    * The default hue of this provider in radians. 0.0 uses the unmodified imagery color.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultHue: Float = 0.0
    
    /**
    * The default saturation of this provider. 1.0 uses the unmodified imagery color. Less than 1.0 reduces the
    * saturation while greater than 1.0 increases it.
    *
    * @type {Number}
    * @default undefined
    */
    public let defaultSaturation: Float = 1.0
    
    /**
     * The default {@link ImageryLayer#gamma} to use for imagery layers created for this provider.
     * By default, this is set to 1.3 for the "aerial" and "aerial with labels" map styles and 1.0 for
     * all others.  Changing this value after creating an {@link ImageryLayer} for this provider will have
     * no effect.  Instead, set the layer's {@link ImageryLayer#gamma} property.
     *
     * @type {Number}
     * @default 1.0
     */
    public let defaultGamma: Float
    
    public let queue: DispatchQueue? = nil
    
    /**
    * Gets a value indicating whether or not the provider is ready for use.
    * @memberof ImageryProvider.prototype
    * @type {Boolean}
    */
    public var ready: Bool {
        get {
            return _ready
        }
    }
    private var _ready: Bool = false
    
    /**
    * Gets the rectangle, in radians, of the imagery provided by this instance.  This function should
    * not be called before {@link BingMapsImageryProvider#ready} returns true.
    * @memberof BingMapsImageryProvider.prototype
    * @type {Rectangle}
    */
    public var rectangle: Rectangle {
        get  {
            //>>includeStart('debug', pragmas.debug);
            assert(_ready, "rectangle must not be called before the imagery provider is ready")
            return _tilingScheme.rectangle
        }
    }
    
    /**
    * Gets the width of each tile, in pixels.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Number}
    */
    public var tileWidth: Int {
        get {
            assert(_ready, "tileWidth must not be called before the imagery provider is ready.")
            return _tileWidth
        }
    }
    
    private var _tileWidth = 0
    
    /**
    * Gets the height of each tile, in pixels.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Number}
    */
    public var tileHeight: Int {
        get {
            assert(_ready, "tileHeight must not be called before the imagery provider is ready.")
            return _tileHeight
        }
    }
    
    private var _tileHeight = 0
    
    /**
    * Gets the maximum level-of-detail that can be requested.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {Number}
    */
    public var maximumLevel: Int {
        get {
            assert(_ready, "maximumLevel must not be called before the imagery provider is ready.")
            return _maximumLevel
        }
    }
    private var _maximumLevel = 0
    
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
     public var minimumLevel: Int? {
        get {
            assert(_ready, "minimumLevel must not be called before the imagery provider is ready.")
            return _minimumLevel
        }
    }
    private var _minimumLevel: Int? = nil
    
    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link ImageryProvider#ready} returns true.
    * @memberof ImageryProvider.prototype
    * @type {TilingScheme}
    */
    
    public var tilingScheme: TilingScheme {
        get {
            assert(_ready, "tilingScheme must not be called before the imagery provider is ready.")
            return _tilingScheme
        }
    }
    
    private var _tilingScheme: TilingScheme
    
    /**
    * Gets the tile discard policy.  If not undefined, the discard policy is responsible
    * for filtering out "missing" tiles via its shouldDiscardImage function.  If this function
    * returns undefined, no tiles are filtered.  This function should
    * not be called before {@link BingMapsImageryProvider#ready} returns true.
    * @memberof BingMapsImageryProvider.prototype
    * @type {TileDiscardPolicy}
    */
    public var tileDiscardPolicy: TileDiscardPolicy? {
        get {
            assert(_ready, "tileDiscardPolicy must not be called before the imagery provider is ready.")
            return _tileDiscardPolicy
        }
    }
    
    private var _tileDiscardPolicy: TileDiscardPolicy?
    
    /**
    * Gets an event that is raised when the imagery provider encounters an asynchronous error..  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof ImageryProvider.prototype
    * @type {Event}
    */
    public private (set) var errorEvent = Event()
    
    /**
    * Gets the credit to display when this imagery provider is active.  Typically this is used to credit
    * the source of the imagery.  This function should not be called before {@link BingMapsImageryProvider#ready} returns true.
    * @memberof BingMapsImageryProvider.prototype
    * @type {Credit}
    */
    public let credit: Credit?
    
    private var _attributionList = [Attribution]()
    
    /**
    * Gets the proxy used by this provider.
    * @memberof ImageryProvider.prototype
    * @type {Proxy}
    */
    /// FIXME: Disabled var proxy: Proxy { get }
    
    /**
    * Gets a value indicating whether or not the images provided by this imagery provider
    * include an alpha channel.  If this property is false, an alpha channel, if present, will
    * be ignored.  If this property is true, any images without an alpha channel will be treated
    * as if their alpha is 1.0 everywhere.  Setting this property to false reduces memory usage
    * and texture upload time.
    * @memberof BingMapsImageryProvider.prototype
    * @type {Boolean}
    */
    public let hasAlphaChannel: Bool = false
    
    /**
    * Gets the Bing Maps key.
    * @memberof BingMapsImageryProvider.prototype
    * @type {String}
    */
    public var key: String {
        get {
            return _key
        }
    }
    
    private let _key: String
    
    private let _url: String
    
    private let _tileProtocol: String
    
    /**
    * Gets the type of Bing Maps imagery to load.
    * @memberof BingMapsImageryProvider.prototype
    * @type {BingMapsStyle}
    */
    public var mapStyle: BingMapsStyle
    
    public let culture: String
    
    private var _imageUrlTemplate: String? = nil
    
    private var _imageUrlSubdomains: JSONArray? = nil
    
    public init(key: String? = nil, options: Options = Options()) {

        if options.mapStyle == .Aerial || options.mapStyle == .AerialWithLabels {
            defaultGamma = 1.3
        } else {
            defaultGamma = 1.0
        }
        
        mapStyle = options.mapStyle
        culture = options.culture
        
        _key = BingMapsAPI.getKey(key)
        
        _url = options.url
        
        _tileProtocol = options.tileProtocol
        
        _tileDiscardPolicy = options.tileDiscardPolicy
        //        this._proxy = options.proxy;
        credit = Credit(
            text: "Bing Imagery",
            imageUrl: nil/*BingMapsImageryProvider._logoData*/,
            link: "http://www.bing.com"
        )
        
        _tilingScheme = WebMercatorTilingScheme(
            numberOfLevelZeroTilesX : 2,
            numberOfLevelZeroTilesY : 2,
            ellipsoid: options.ellipsoid
        )
        
        
        
        errorEvent = Event()
        
        _ready = false
        
        //var metadataError;
        
        let metadataSuccess = { (data: Data) -> () in
            
            do {
                let metadata = try JSON.decode(data, strict: true)
                
                guard let resourceSet = try metadata.getArray("resourceSets").first else {
                    let error = try metadata.getArray("errorDetails")
                    print("metadata error: ")// + error.first?)
                    return
                }
                guard let resource = try resourceSet.getArray("resources").first else {
                    let error = try metadata.getString("errorDetails")
                    print("metadata error: " + error)
                    return
                }
                self._tileWidth = try resource.getInt("imageWidth")
                self._tileHeight = try resource.getInt("imageHeight")
                self._maximumLevel = try resource.getInt("zoomMax") - 1
                self._imageUrlSubdomains = try resource.getArray("imageUrlSubdomains")
                
                 let imageUrlTemplate = try resource
                    .getString("imageUrl")
                    .replace("{culture}", self.culture)
                 
                 // Force HTTPS
                 self._imageUrlTemplate = imageUrlTemplate.replace("http://", "https://")
                 
                 
                 // Install the default tile discard policy if none has been supplied.
                 //FIXME: Tile discard policy
                 /*if (!defined(that._tileDiscardPolicy)) {
                 that._tileDiscardPolicy = new DiscardMissingTileImagePolicy({
                 missingImageUrl : buildImageUrl(that, 0, 0, that._maximumLevel),
                 pixelsToCheck : [new Cartesian2(0, 0), new Cartesian2(120, 140), new Cartesian2(130, 160), new Cartesian2(200, 50), new Cartesian2(200, 200)],
                 disableCheckIfAllPixelsAreTransparent : true
                 });
                 }*/
                
                if let attributionList = try resource.getArrayOrNil("imageryProviders") {
                    
                    for jsonAttribution in attributionList {
                        
                        var attribution = Attribution(
                            attribution: Credit(text: try jsonAttribution.getString("attribution")),
                            areas: [AttributionArea]()
                        )
                        
                        let coverageAreas = try jsonAttribution.getArray("coverageAreas")
                        
                        for area in coverageAreas {
                            let bbox = try area.getArray("bbox")
                            let zoomMin = try area.getInt("zoomMin")
                            let zoomMax = try area.getInt("zoomMax")
                            attribution.areas.append(
                                AttributionArea(
                                    zoomMin: zoomMin,
                                    zoomMax: zoomMax, bbox:
                                    Rectangle(
                                        west: Math.toRadians(try bbox[1].getDouble()),
                                        south: Math.toRadians(try bbox[0].getDouble()),
                                        east: Math.toRadians(try bbox[3].getDouble()),
                                        north: Math.toRadians(try bbox[2].getDouble())
                                    )
                                )
                            )
                        }
                        self._attributionList.append(attribution)
                    }
                    
                }

                DispatchQueue.main.async(execute: {
                    self._ready = true
                })
                 //TileProviderError.handleSuccess(metadataError);*/
            } catch {
                print("Bing metadata decode failed - invalid JSON")
                return
            }
        }
        
        let metadataFailure = { (error: String) -> () in
            print(error)
            /*metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);*/
        }
        
        
        let metadataUrl = _tileProtocol + _url + "/REST/v1/Imagery/Metadata/" + mapStyle.rawValue
        
        let metadataParameters = [
            "incl" : "ImageryProviders",
            "key" : self._key
        ]
        
        let metadataHeaders = ["Accept": "application/json"]

        let metadataOperation = NetworkOperation(url: metadataUrl, headers: metadataHeaders, parameters: metadataParameters)
        metadataOperation.completionBlock = {
            DispatchQueue.main.async {
                if let error = metadataOperation.error {
                    metadataFailure("An error occurred while accessing \(metadataUrl): \(error)")
                    return
                }
                metadataSuccess(metadataOperation.data)
            }
        }
        metadataOperation.enqueue()
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
    public func requestImage(x: Int, y: Int, level: Int, completionBlock: ((CGImage?) -> Void)) {
        assert(_ready, "requestImage must not be called before the imagery provider is ready.")
        let url = buildImageUrl(x: x, y: y, level: level)
        loadImage(url, completionBlock: completionBlock)
        
    }

    /**
    * Loads an image from a given URL.  If the server referenced by the URL already has
    * too many requests pending, this function will instead return undefined, indicating
    * that the request should be retried later.
    *
    * @param {String} url The URL of the image.
    * @returns {Promise} A promise for the image that will resolve when the image is available, or
    *          undefined if there are too many active requests to the server, and the request
    *          should be retried later.  The resolved image may be either an
    *          Image or a Canvas DOM object.
    */
    public func loadImage (_ url: String, completionBlock: ((CGImage?) -> Void)) {
        
        let imageryOperation = NetworkOperation(url: url)
        imageryOperation.completionBlock = {
            if let error = imageryOperation.error {
                print("error: \(error.localizedDescription)")
                return
            }
            #if os(iOS)
                let image = UIImage(data: imageryOperation.data)?.cgImage
            #elseif os(OSX)
                let image = NSImage(data: imageryOperation.data)?.cgImage
            #endif
            DispatchQueue.main.async(execute: {
                completionBlock(image)
            })
        }
        imageryOperation.enqueue()
    }
    
    /*
    /**
    * Gets the proxy used by this provider.
    * @memberof BingMapsImageryProvider.prototype
    * @type {Proxy}
    */
    proxy : {
    get : function() {
    return this._proxy;
    }
    },
    
    
    /**
    * Gets an event that is raised when the imagery provider encounters an asynchronous error.  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof BingMapsImageryProvider.prototype
    * @type {Event}
    */
    errorEvent : {
    get : function() {
    return this._errorEvent;
    }
    },
    */

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
    public func tileCredits (x: Int, y: Int, level: Int) -> [Credit] {
        assert(ready, "getTileCredits must not be called before the imagery provider is ready")
        
        let rectangle = _tilingScheme.tileXYToRectangle(x: x, y: y, level: level)
        return getRectangleAttribution(level, rectangle: rectangle)
    }
    

    /*BingMapsImageryProvider._logoData = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAD0AAAAaCAYAAAAEy1RnAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH3gIDEgcPTMnXOQAAClZJREFUWMPdWGtsFNcV/u689uH1+sXaONhlWQzBENtxiUFBpBSLd60IpXHSNig4URtSYQUkRJNSi0igViVVVBJBaBsiAgKRQJSG8AgEHCCWU4iBCprY2MSgXfOI16y9D3s9Mzsztz9yB12WNU2i9Ecy0tHOzN4793zn3POdcy7BnRfJ8I7iB3SRDPeEExswLz8Y0DZIAYDIRGAgLQAm+7Xle31J3L3Anp1MZPY+BUBjorN332vgYhpgV1FRUd6TTz45ubq6OtDV1SXpuu5g//Oept9wNwlMyAi8IXDjyF245TsDTdivDMATCATGNDU1/WbhwoWPTZs2bWx1dXWhx+Oxrl+/PqTrus5t9W8KWEzjinTAYhro/xuBStwiIgBnJBLxKIoy1u/3V/r9/krDMMz3339/Z3t7e38ikUgCMDLEt8W+Q0cAI3McYTDDmZxh7DESG5Ni43jg9Gsa+X+OsxWxPSJTSj3JZFK5ZRVJErOzs8e6XC4fgGwALhbzDgAKU1hK28KEA6PMmTMn56233qpevnz5PQDcbJ7EzVUAuMrLy3MBeABkcWOEDELSyFe4y7iMoHkriZZlKYZh8ASHZDKpJJPJHAC5APIA5APIAeBlCjo5TwlpXnbOmTPHP3fu3KZVq1atZKBcDJQ9x7V48WJfc3Pzhp6enj+tXLnyR8w4MjdG4gyVDk7KICMClzKlLUrpbQMNw5AkScppbGz8cWdn57WjR4/2caw+DEBlYjO8wX1foZQWuN3uKZIklQD4G+fhlG0Yl8uVm5WVVW6app6dne0D0G8vnxbjJntHubCUOK/badZICyWanrJuAaeUknTQpmlKkUhEWbx48U8LCwtHhUKha+fPn+85fPhwV0tLyzUACSZx9jvMFhIByNFoVDEMw/qKB5HPvJfkUqBr9+7deklJyZ/j8bi5ffv2OAslieMLsG+m2DybT2QuzEQOsF5SUqJfvXo1yc2l6Xn6rgSRSCSEc+fOhVeuXLmwoqJixvTp0wcWLFgQ7unpudHR0dF97ty5z/fu3XseQJh5adjeerquy5ZlCalUivh8Pt8HH3ywzOPxyD09PZ81NjZ+2NnZaQEQx40b54vFYqaqquEVK1b4a2tr/WvWrDn18ssv144fP36SqqoD69ev371nz57rDLwAwHHkyJGfjRs3rtowDOv06dOnu7q6rs6bN2/s7Nmz9zIjDKenWoFZKg/AlMLCwl82Nzf/m3LX22+/fXb06NF/ALC8u7u7m6ZdkUhksL29/UpLS0vzunXrVgAoBzAaQBGAiY2NjUui0ei1RCLRFwwG/9PX19cVi8WCqqoOdHd3HysrK6sDMCccDl8IBoOtiqIsOnbs2D+i0eiV3t7ez8Ph8GeRSKRT07TB/v7+i1OnTp0HYBqABzs7O/+paVo0Fot1RyKRi/F4/Gp/f39XIpHoZnoUMn6wU+ZtRDaymwmxZFk2AWjvvvvuJ/F4PMn/n5+fn1VeXu6fOXNmbU1NzUOM4Bz8QqIoyg6HwxuLxfq3bdu2a+vWrW/09/dfKy0tffDVV199BEC20+n0ud3uQgBup9Pp83g8JYqieE+ePPnxxo0bt33xxRen8/Ly7n3hhRcWASh47bXX5pWVldWFw+GuXbt27XjzzTd3BoPBDq/XG1AUZRRHmAKPVfqaoKkgCCkA+oYNG84Eg0FHTU1N5ezZs8eWlJQ4CSF8/LvZYhJPQoQQpFKpwcrKyo1su9HBwUF99erVv588eXINgOOmacIwDEopdaZSKUIpxYkTJz6sr68/BMBav379RcMwZk2aNOl+AP+qq6t7xDTNVEVFxR+j0WgSAJk4ceKlTz/9tNzpdHpZvIvpjVW6pykhhBJCbkvwgiAQQogEQL558ybdtGlTsLm5OWJZdxZmlmWll5OUEEJN0zSGhob6GcOrALSzZ8/2apqWcLlc2axGACNRkRAimqaph0Kh68xIwwB0y7IMSZKcABz5+fkl8Xj8y2g0apOb5na7rYGBgS/JV54Q0qpAAoBKaS0jBWClg1ZVFeFw2AlgVF1dXeDpp5+eWVFRUVpcXOzgvQwAbrcbDJhdudlGpKZpGtx6JCcnRxIEQbQsS2PjbjM+AMvlchnMSBaXkr7ymCCIhmEYfMoVRVESBEHI0CaTTNubssUsQRBuubCtra33pZdeCk6YMCGwZs2aipqaGn9paWmuJEl3JP0bN258eeTIkRMABrm0YomiaImiKGVlZeWxLecAgBkzZvgdDkfWjRs3ggA0bpfpoiiahBCqKEqKAy2yULMA6MlkMp6Xl3cP1x2SWCwmFhQU+CmlFhfHNFOevpX4LcvSJUkyAeDQoUOh119//fpTTz01Zf78+UWBQCBHUZQ7yE/TNGPfvn0n33vvvSP79+//BECMeZsCMGRZNgRBgNPpHHXx4sVVDQ0Nf1+wYMGYJ554YikAevDgwUMA4oIgQJZlSggZdDqdBiGEZGdn6ww0tQlJURTT4/EMHz9+/MCjjz7622AwuHbZsmVbiouLvWvXrm1wOp3ZqVRqaKQTIInf1gAMl8ulU0q1CxcuBGOxmL5u3bryQCDgycrKEjORXGtra8eOHTsOHz169OyVK1cuA+hlRYrGlNRkWR7UNO2mYRiaz+cb3dLS8gYhhOi6Hj116tSOVatWHQNALcsaME0zLghClBDSZ9+zQsZ2SoJS2udwOKLPPffcvsrKyrJAIPDQ/v37txiGofX19V3r7e29UlBQMHqEVpjwnrYA6PF4PK6q6s2qqqqpZWVlitvtljOB7enpiWzbtu3wgQMHTre1tV0E0MeKkkGuIhMAqHv37u30er3Px+NxlyiKygMPPOAnhFiXLl0Kbd68uYPNsXbu3Lk6mUwaqqr2btmyZUdtbe3hd955pwvAEFNcO3jw4K/b2tqiqqpGIpGI4/HHH/9rQ0PDCa/XOyoSidDLly8PNTU1PcZ4QuNK1ju6NYHFRAGASXPnzv1Fa2vrxzTDpapqateuXR/Nnz+/SVGUhwFMBzCBFSLZLF75DsrJGpXRAH4EIABgPIBxAEoBFAPwARjFif1sNzZ25+VlOhaxufcCqAFQC+BhAPVLliz5XSqVUkOhUAuAKWnFyR3dlsw+fg+A+8eMGfPzTZs2bY9GozEb8JkzZ9qXLl36l+Li4l8B+AmAyQDGsGrOzfXNPGPawG2l85jksmcPm+vihH+2W1iF3bvZPN+sWbPuGx4eDrW3t+85fvz41o6OjmZN04Y0TYvV19cvYIbN5QqUjG2mwj5YAqDK4XDMe+aZZ55vbW09+sorr2yuqqpqYFatAuBn3uB7XzJCY297XeaUd2RoGzOJmHb6IjFj5D777LP3DQwMfDw8PBxSVbUvkUj0hEKhj1588cXH2O7zMSPdplumoxveMx5Zlj3jx4/39vb26gMDA4MsvgYZo+p8Pr7LqQX5Ds/U7d0jFxUVZS1atKg4Nzc317Isp67rZldXV6y5ufkmI78hFtcmrx8ZweMit6XsUs4+6kmlgbW+peLf9gyMZNCR374G0y/FxEzX8b/8+bkXEBxKFwAAAABJRU5ErkJggg==';
    */
    /**
    * Converts a tiles (x, y, level) position into a quadkey used to request an image
    * from a Bing Maps server.
    *
    * @param {Number} x The tile's x coordinate.
    * @param {Number} y The tile's y coordinate.
    * @param {Number} level The tile's zoom level.
    *
    * @see {@link http://msdn.microsoft.com/en-us/library/bb259689.aspx|Bing Maps Tile System}
    * @see BingMapsImageryProvider#quadKeyToTileXY
    */
    func tileXYToQuadKey (x: Int, y: Int, level: Int) -> String {
        
        var quadkey = ""
        
        for i in stride(from: level, through: 0, by: -1) {
            let bitmask = 1 << i
            var digit = 0
            
            if ((x & bitmask) != 0) {
                digit |= 1
            }
            
            if ((y & bitmask) != 0) {
                digit |= 2
            }
            
            quadkey += String(digit)
        }
        return quadkey
    }
    /*
    /**
    * Converts a tile's quadkey used to request an image from a Bing Maps server into the
    * (x, y, level) position.
    *
    * @param {String} quadkey The tile's quad key
    *
    * @see {@link http://msdn.microsoft.com/en-us/library/bb259689.aspx|Bing Maps Tile System}
    * @see BingMapsImageryProvider#tileXYToQuadKey
    */
    BingMapsImageryProvider.quadKeyToTileXY = function(quadkey) {
    var x = 0;
    var y = 0;
    var level = quadkey.length - 1;
    for ( var i = level; i >= 0; --i) {
    var bitmask = 1 << i;
    var digit = +quadkey[level - i];
    
    if ((digit & 1) !== 0) {
    x |= bitmask;
    }
    
    if ((digit & 2) !== 0) {
    y |= bitmask;
    }
    }
    return {
    x : x,
    y : y,
    level : level
    };
    };
    */
    func buildImageUrl(x: Int, y: Int, level: Int) -> String {
        var imageUrl = _imageUrlTemplate! // _ready already checked
        
        let quadkey = tileXYToQuadKey(x: x, y: y, level: level)
        imageUrl = imageUrl.replace("{quadkey}", quadkey)
        
        let subdomainIndex = (x + y + level) % _imageUrlSubdomains!.count
        imageUrl = imageUrl.replace("{subdomain}", _imageUrlSubdomains![subdomainIndex].string!)
        
        // FIXME: proxy
        /*var proxy = imageryProvider._proxy;
        if (defined(proxy)) {
        imageUrl = proxy.getURL(imageUrl);
        }
        */
        return imageUrl
    }
    
    func getRectangleAttribution(_ level: Int, rectangle: Rectangle) -> [Credit] {
        // Bing levels start at 1, while ours start at 0.
        let level = level + 1
        
        var result = [Credit]()
        
        for attribution in _attributionList {
            var included = false
            for area in attribution.areas {
                
                if level >= area.zoomMin && level <= area.zoomMax {
                    let intersection = rectangle.intersection(area.bbox)
                    if (intersection != nil) {
                        included = true
                        break
                    }
                }
            }
            if included {
                result.append(attribution.attribution)
            }
        }
        return result
    }
 }
 
 
 
