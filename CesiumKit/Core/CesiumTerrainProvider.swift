//
//  CesiumTerrainProvider.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/12/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
 * A {@link TerrainProvider} that access terrain data in a Cesium terrain format.
 * The format is described on the
 * {@link https://github.com/AnalyticalGraphicsInc/cesium/wiki/Cesium-Terrain-Server|Cesium wiki}.
 *
 * @alias CesiumTerrainProvider
 * @constructor
 *
 * @param {Object} options Object with the following properties:
 * @param {String} options.url The URL of the Cesium terrain server.
 * @param {Proxy} [options.proxy] A proxy to use for requests. This object is expected to have a getURL function which returns the proxied URL, if needed.
 * @param {Boolean} [options.requestVertexNormals=false] Flag that indicates if the client should request additional lighting information from the server, in the form of per vertex normals if available.
 * @param {Boolean} [options.requestWaterMask=false] Flag that indicates if the client should request per tile water masks from the server,  if available.
 * @param {Ellipsoid} [options.ellipsoid] The ellipsoid.  If not specified, the WGS84 ellipsoid is used.
 * @param {Credit|String} [options.credit] A credit for the data source, which is displayed on the canvas.
 *
 * @see TerrainProvider
 *
 * @example
 * // Construct a terrain provider that uses per vertex normals for lighting
 * // to add shading detail to an imagery provider.
 * var terrainProvider = new Cesium.CesiumTerrainProvider({
 *     url : '//assets.agi.com/stk-terrain/world',
 *     requestVertexNormals : true
 * });
 *
 * // Terrain geometry near the surface of the globe is difficult to view when using NaturalEarthII imagery,
 * // unless the TerrainProvider provides additional lighting information to shade the terrain (as shown above).
 * var imageryProvider = new Cesium.TileMapServiceImageryProvider({
 *        url : 'http://localhost:8080/Source/Assets/Textures/NaturalEarthII',
 *        fileExtension : 'jpg'
 *    });
 *
 * var viewer = new Cesium.Viewer('cesiumContainer', {
 *     imageryProvider : imageryProvider,
 *     baseLayerPicker : false,
 *     terrainProvider : terrainProvider
 * });
 *
 * // The globe must enable lighting to make use of the terrain's vertex normals
 * viewer.scene.globe.enableLighting = true;
 */
class CesiumTerrainProvider: TerrainProvider {
    
    let url: String

    //private var _proxy: Proxy
    
    /**
    * Gets an event that is raised when the terrain provider encounters an asynchronous error.  By subscribing
    * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
    * are passed an instance of {@link TileProviderError}.
    * @memberof EllipsoidTerrainProvider.prototype
    * @type {Event}
    */
    var errorEvent = Event()

    /**
    * Gets the tiling scheme used by the provider.  This function should
    * not be called before {@link TerrainProvider#ready} returns true.
    * @memberof TerrainProvider.prototype
    * @type {TilingScheme}
    */
    let tilingScheme: TilingScheme
    
    /**
     * Gets the ellipsoid used by the provider. Default is WGS84.
     */
    let ellipsoid: Ellipsoid
    
    /**
     * Gets the credit to display when this terrain provider is active.  Typically this is used to credit
     * the source of the terrain. This function should
     * not be called before {@link TerrainProvider#ready} returns true.
     * @memberof TerrainProvider.prototype
     * @type {Credit}
     */
    fileprivate (set) var credit: Credit? = nil
    
    /**
     * Gets a value indicating whether or not the provider is ready for use.
     * @memberof TerrainProvider.prototype
     * @type {Boolean}
     */
    fileprivate (set) var ready = false
    
    fileprivate let _levelZeroMaximumGeometricError: Double
    
    var heightmapTerrainQuality = 0.25
    
    fileprivate let _heightmapWidth = 65
    
    fileprivate var _heightmapStructure: HeightmapStructure? = nil
    
    fileprivate var _tileUrlTemplates = [String]()
    
    fileprivate var _availableTiles: [JSON]? = nil
    
    /**
     * Gets a value indicating whether or not the requested tiles include vertex normals.
     * This function should not be called before {@link CesiumTerrainProvider#ready} returns true.
     * @memberof CesiumTerrainProvider.prototype
     * @type {Boolean}
     * @exception {DeveloperError} This property must not be called before {@link CesiumTerrainProvider#ready}
     */
    var hasVertexNormals: Bool {
        assert(ready, "hasVertexNormals must not be called before the terrain provider is ready.")
        // returns true if we can request vertex normals from the server
        return _hasVertexNormals && requestVertexNormals
    }
    
    /**
     * Boolean flag that indicates if the Terrain Server can provide vertex normals.
     * @type {Boolean}
     * @default false
     * @private
     */
    fileprivate var _hasVertexNormals = false

    /**
     * Boolean flag that indicates if the client should request vertex normals from the server.
     * Vertex normals data is appended to the standard tile mesh data only if the client requests the vertex normals and
     * if the server provides vertex normals.
     * @memberof CesiumTerrainProvider.prototype
     * @type {Boolean}
     */
    fileprivate (set) var requestVertexNormals: Bool
    
    /**
     * Gets a value indicating whether or not the provider includes a water mask.  The water mask
     * indicates which areas of the globe are water rather than land, so they can be rendered
     * as a reflective surface with animated waves.  This function should not be
     * called before {@link CesiumTerrainProvider#ready} returns true.
     * @memberof CesiumTerrainProvider.prototype
     * @type {Boolean}
     * @exception {DeveloperError} This property must not be called before {@link CesiumTerrainProvider#ready}
     */
    var hasWaterMask: Bool {
        assert(ready, "hasWaterMask must not be called before the terrain provider is ready.")
        return _hasWaterMask && _requestWaterMask
    }
    
    fileprivate var _hasWaterMask = false
    
    /**
     * Boolean flag that indicates if the client should request tile watermasks from the server.
     * @type {Boolean}
     * @default false
     * @private
     */
    fileprivate var _requestWaterMask: Bool
    
    fileprivate var _littleEndianExtensionSize = true
    
    init (url: String, /*proxy: Proxy,*/ ellipsoid: Ellipsoid = Ellipsoid.wgs84(), tilingScheme: TilingScheme = GeographicTilingScheme(), requestVertexNormals: Bool = false, requestWaterMask: Bool = false) {
        
        self.url = url
        self.ellipsoid = ellipsoid
        self.tilingScheme = tilingScheme
        self.requestVertexNormals = requestVertexNormals
        _requestWaterMask = requestWaterMask
        
        _levelZeroMaximumGeometricError = CesiumTerrainProvider.estimatedLevelZeroGeometricErrorForAHeightmap(ellipsoid: self.ellipsoid, tileImageWidth: _heightmapWidth, numberOfTilesAtLevelZero: tilingScheme.numberOfXTilesAtLevel(0))
        
        
        //this._readyPromise = when.defer();
        
        let metadataUrl = url + "/layer.json"
        /*if (defined(this._proxy)) {
            metadataUrl = this._proxy.getURL(metadataUrl);
        }*/
        var metadataError: NSError? = nil
        
        let metadataSuccess = { (data: Data) in
            
            do {
                let metadata = try JSON.decode(string: String(data: data, encoding: .utf8)!, strict: true)
                
                guard let tiles = try metadata.getArrayOrNil(key: "tiles") else {
                    logPrint(level: .error, "The layer.json file does not specify any tile URL templates.")
                    //metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);
                    return
                }

                guard let format = try metadata.getStringOrNil(key: "format") else {
                    logPrint(level: .error, "The tile format is not specified in the layer.json file.")
                    //metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);
                    return
                }
                
                if format == "heightmap-1.0" {
                    self._heightmapStructure = HeightmapStructure(
                        heightScale: 1.0 / 5.0,
                        heightOffset: -1000.0,
                        elementsPerHeight: 1,
                        stride: 1,
                        elementMultiplier: 256.0,
                        isBigEndian: false
                    )
                    self._hasWaterMask = true
                    self._requestWaterMask = true
                } else if !format.hasPrefix("quantized-mesh-1.") {
                    logPrint(level: .warning, "The tile format '" + format + "' is invalid or not supported.")
                    //metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);
                    return
                }
                let version = try metadata.getString(key: "version")
                
                var baseURL: URLComponents = URLComponents(string: self.url)!
                self._tileUrlTemplates = tiles.map {
                    var templateString = $0.string!
                    let template = URLComponents(string: templateString)
                    if template?.host != nil && baseURL.host == nil {
                        baseURL.host = template!.host
                        baseURL.user = template!.user
                        baseURL.password = template!.password
                        baseURL.scheme = template!.scheme
                    }
                    if let string = template?.string {
                        templateString = string
                    }
                    guard let url = baseURL.url?.absoluteString else {
                        return ""
                    }
                    
                    let path = templateString.replace("{version}", version)
                    return url + "/" + path
                }
                
                self._availableTiles = try metadata.getArray(key: "available").map { $0 }
                
                if let attribution = try metadata.getStringOrNil(key: "attribution") {
                    self.credit = Credit(text: attribution)
                }
                
                // The vertex normals defined in the 'octvertexnormals' extension is identical to the original
                // contents of the original 'vertexnormals' extension.  'vertexnormals' extension is now
                // deprecated, as the extensionLength for this extension was incorrectly using big endian.
                // We maintain backwards compatibility with the legacy 'vertexnormal' implementation
                // by setting the _littleEndianExtensionSize to false. Always prefer 'octvertexnormals'
                // over 'vertexnormals' if both extensions are supported by the server.
                if let extensions = try metadata.getArrayOrNil(key: "extensions") {
                    if extensions.contains("octvertexnormals") {
                        self._hasVertexNormals = true
                    } else if extensions.contains("vertexnormals") {
                        self._hasVertexNormals = true
                        self._littleEndianExtensionSize = false
                    }
                    if extensions.contains("watermask") {
                        self._hasWaterMask = true
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.ready = true
                })
                //that._readyPromise.resolve(true);
            } catch {
                logPrint(level: .error, "invalid JSON from terrain provider")
                return
            }
        }
     
        let metadataFailure = { (data: Data) in
            // If the metadata is not found, assume this is a pre-metadata heightmap tileset.
            /*if (defined(data) && data.statusCode === 404) {
                metadataSuccess({
                    tilejson: '2.1.0',
                    format : 'heightmap-1.0',
                    version : '1.0.0',
                    scheme : 'tms',
                    tiles : [
                    '{z}/{x}/{y}.terrain?v={version}'
                    ]
                });
                return;
            }
            var message = 'An error occurred while accessing ' + metadataUrl + '.';
            metadataError = TileProviderError.handleError(metadataError, that, that._errorEvent, message, undefined, undefined, undefined, requestMetadata);*/
        }
        
        let metadataHeaders = ["Accept": "application/json"]
        
        let metadataOperation = NetworkOperation(url: metadataUrl, headers: metadataHeaders)
        
        metadataOperation.completionBlock = {
            if let error = metadataOperation.error {
                metadataFailure(metadataOperation.data)
                return
            }
            metadataSuccess(metadataOperation.data)
        }
        metadataOperation.enqueue()
    }

/**
* When using the Quantized-Mesh format, a tile may be returned that includes additional extensions, such as PerVertexNormals, watermask, etc.
* This enumeration defines the unique identifiers for each type of extension data that has been appended to the standard mesh data.
*
* @namespace
* @alias QuantizedMeshExtensionIds
* @see CesiumTerrainProvider
* @private
*/
    enum QuantizedMeshExtensionIds: UInt8 {
    /**
    * Oct-Encoded Per-Vertex Normals are included as an extension to the tile mesh
    *
    * @type {Number}
    * @constant
    * @default 1
    */
    case octVertexNormals = 1
    /**
    * A watermask is included as an extension to the tile mesh
    *
    * @type {Number}
    * @constant
    * @default 2
    */
    case waterMask
}
    
    fileprivate func getRequestHeader(_ extensionsList: [String]?) -> [String: String] {
        if extensionsList == nil || extensionsList!.count == 0 {
            return ["Accept": "application/vnd.quantized-mesh,application/octet-stream;q=0.9,*/*;q=0.01"]
        } else {
            let extensions = extensionsList!.joined(separator: "-")
            return ["Accept" : "application/vnd.quantized-mesh;extensions=" + extensions + ",application/octet-stream;q=0.9,*/*;q=0.01"]
        }
    }

    /*
     function createHeightmapTerrainData(provider, buffer, level, x, y, tmsY) {
     var heightBuffer = new Uint16Array(buffer, 0, provider._heightmapWidth * provider._heightmapWidth);
     return new HeightmapTerrainData({
     buffer : heightBuffer,
     childTileMask : new Uint8Array(buffer, heightBuffer.byteLength, 1)[0],
     waterMask : new Uint8Array(buffer, heightBuffer.byteLength + 1, buffer.byteLength - heightBuffer.byteLength - 1),
     width : provider._heightmapWidth,
     height : provider._heightmapWidth,
     structure : provider._heightmapStructure
     });
     }
     */
    
    func createQuantizedMeshTerrainData(_ data: Data, level: Int, x: Int, y: Int, tmsY: Int, completionBlock: (_ data: TerrainData) -> ()) {
        var pos = 0
        let cartesian3Elements = 3
        let boundingSphereElements = cartesian3Elements + 1
        let cartesian3Length = MemoryLayout<Double>.size * cartesian3Elements
        let boundingSphereLength = MemoryLayout<Double>.size * boundingSphereElements
        let encodedVertexElements = 3
        let encodedVertexLength = MemoryLayout<UInt16>.size * encodedVertexElements
        let triangleElements = 3
        var bytesPerIndex = MemoryLayout<UInt16>.size
        var triangleLength = bytesPerIndex * triangleElements
        
        let center = Cartesian3(
            x: data.getFloat64(pos: pos),
            y: data.getFloat64(pos: pos + 8),
            z: data.getFloat64(pos: pos + 16)
        )
        pos += cartesian3Length
        
        let minimumHeight = Double(data.getFloat32(pos: pos))
        pos += MemoryLayout<Float>.size
        let maximumHeight = Double(data.getFloat32(pos: pos))
        pos += MemoryLayout<Float>.size
        
        let boundingSphere = BoundingSphere(
            center: Cartesian3(
                x: data.getFloat64(pos: pos),
                y: data.getFloat64(pos: pos + 8),
                z: data.getFloat64(pos: pos + 16)),
            radius: data.getFloat64(pos: pos + cartesian3Length)
        )
        pos += boundingSphereLength
        
        let horizonOcclusionPoint = Cartesian3(
            x: data.getFloat64(pos: pos),
            y: data.getFloat64(pos: pos + 8),
            z: data.getFloat64(pos: pos + 16)
        )
        pos += cartesian3Length
        
        let vertexCount = Int(data.getUInt32(pos: pos))
        pos += MemoryLayout<UInt32>.size
        
        var encodedVertexBuffer = data.getUInt16Array(pos: pos, elementCount: vertexCount * encodedVertexElements)
        pos += vertexCount * encodedVertexLength
        
        if vertexCount > Math.SixtyFourKilobytes {
            // More than 64k vertices, so indices are 32-bit.
            bytesPerIndex = MemoryLayout<UInt32>.size
            triangleLength = bytesPerIndex * triangleElements
        }
        
        func zigZagDecode(_ value: UInt16) -> Int16 {
            let int32Value = Int32(value)
            return Int16((int32Value >> 1) ^ (-(int32Value & 1)))
        }
        
        var u: UInt16 = 0
        var v: UInt16 = 0
        var height: UInt16 = 0
        
        // Decode the vertex buffer.
        let uBuffer = encodedVertexBuffer[0..<vertexCount].map { (value) -> UInt16 in
            u = u &+ UInt16(bitPattern: zigZagDecode(value))
            return u
        }
        let vBuffer = encodedVertexBuffer[vertexCount..<(vertexCount * 2)].map { (value) -> UInt16 in
            v = v &+ UInt16(bitPattern: zigZagDecode(value))
            return v
        }
        let heightBuffer = encodedVertexBuffer[(vertexCount * 2)..<(vertexCount * 3)].map { (value) -> UInt16 in
            height = height &+ UInt16(bitPattern: zigZagDecode(value))
            return height
        }
        encodedVertexBuffer = uBuffer + vBuffer + heightBuffer
        // skip over any additional padding that was added for 2/4 byte alignment
        if pos % bytesPerIndex != 0 {
            pos += (bytesPerIndex - (pos % bytesPerIndex))
        }
        
        let triangleCount = Int(data.getUInt32(pos: pos))
        pos += MemoryLayout<UInt32>.stride
        
        // High water mark decoding based on decompressIndices_ in webgl-loader's loader.js.
        // https://code.google.com/p/webgl-loader/source/browse/trunk/samples/loader.js?r=99#55
        // Copyright 2012 Google Inc., Apache 2.0 license.
        var highest = 0
        
        let indices = IndexDatatype
            .createIntegerIndexArrayFromData(data, numberOfVertices: vertexCount, byteOffset: pos, length: triangleCount * triangleElements)
            .map { (value: Int) -> Int in
                let result = highest - Int(value)
                if value == 0 {
                    highest += 1
                }
                return result
        }
        
        pos += triangleCount * triangleLength
                
        let westVertexCount = Int(data.getUInt32(pos: pos))
        pos += MemoryLayout<UInt32>.size
        let westIndices = IndexDatatype.createIntegerIndexArrayFromData(data, numberOfVertices: vertexCount, byteOffset: pos, length: westVertexCount)
        pos += westVertexCount * bytesPerIndex
        
        let southVertexCount = Int(data.getUInt32(pos: pos))
        pos += MemoryLayout<UInt32>.size
        let southIndices = IndexDatatype.createIntegerIndexArrayFromData(data, numberOfVertices: vertexCount, byteOffset: pos, length: southVertexCount)
        pos += southVertexCount * bytesPerIndex
        
        let eastVertexCount = Int(data.getUInt32(pos: pos))
        pos += MemoryLayout<UInt32>.size
        let eastIndices = IndexDatatype.createIntegerIndexArrayFromData(data, numberOfVertices: vertexCount, byteOffset: pos, length: eastVertexCount)
        pos += eastVertexCount * bytesPerIndex
        
        let northVertexCount = Int(data.getUInt32(pos: pos))
        pos += MemoryLayout<UInt32>.size
        let northIndices = IndexDatatype.createIntegerIndexArrayFromData(data, numberOfVertices: vertexCount, byteOffset: pos, length: northVertexCount)
        pos += northVertexCount * bytesPerIndex
        
        var encodedNormalBuffer: [UInt8]? = nil
        var waterMaskBuffer: [UInt8]? = nil
        while pos < data.count {
            let extensionId = QuantizedMeshExtensionIds(rawValue: data.getUInt8(pos: pos))
            pos += MemoryLayout<UInt8>.size
            let extensionLength = Int(data.getUInt32(pos: pos, littleEndian: _littleEndianExtensionSize))
            pos += MemoryLayout<UInt32>.size
            
            if extensionId == .octVertexNormals && requestVertexNormals {
                encodedNormalBuffer = data.getUInt8Array(pos: pos, elementCount: vertexCount * 2)
            } else if extensionId == .waterMask && _requestWaterMask {
                waterMaskBuffer = data.getUInt8Array(pos: pos, elementCount: extensionLength)
            }
            pos += extensionLength
        }
        
        let skirtHeight = levelMaximumGeometricError(level) * 5.0
        
        let rectangle = tilingScheme.tileXYToRectangle(x: x, y: y, level: level)
        let orientedBoundingBox: OrientedBoundingBox?
        if (rectangle.width < M_PI_2 + Math.Epsilon5) {
            // Here, rectangle.width < pi/2, and rectangle.height < pi
            // (though it would still work with rectangle.width up to pi)
            
            // The skirt is not included in the OBB computation. If this ever
            // causes any rendering artifacts (cracks), they are expected to be
            // minor and in the corners of the screen. It's possible that this
            // might need to be changed - just change to `minimumHeight - skirtHeight`
            // A similar change might also be needed in `upsampleQuantizedTerrainMesh.js`.
            orientedBoundingBox = OrientedBoundingBox(
                fromRectangle: rectangle,
                minimumHeight: minimumHeight,
                maximumHeight: maximumHeight,
                ellipsoid: tilingScheme.ellipsoid
            )
        } else {
            orientedBoundingBox = nil
        }
       let terrainData = QuantizedMeshTerrainData(
            quantizedVertices: encodedVertexBuffer,
            indices: indices,
            encodedNormals: encodedNormalBuffer,
            minimumHeight: minimumHeight,
            maximumHeight: maximumHeight,
            boundingSphere: boundingSphere,
            orientedBoundingBox: orientedBoundingBox,
            horizonOcclusionPoint: horizonOcclusionPoint,
            westIndices: westIndices,
            southIndices: southIndices,
            eastIndices: eastIndices,
            northIndices: northIndices,
            westSkirtHeight: skirtHeight,
            southSkirtHeight: skirtHeight,
            eastSkirtHeight: skirtHeight,
            northSkirtHeight: skirtHeight,
            childTileMask: getChildMaskForTile(level, x: x, y: tmsY),
            waterMask: waterMaskBuffer
        )
        completionBlock(terrainData)
    }
 
    
    /**
     * Requests the geometry for a given tile.  This function should not be called before
     * {@link CesiumTerrainProvider#ready} returns true.  The result must include terrain data and
     * may optionally include a water mask and an indication of which child tiles are available.
     *
     * @param {Number} x The X coordinate of the tile for which to request geometry.
     * @param {Number} y The Y coordinate of the tile for which to request geometry.
     * @param {Number} level The level of the tile for which to request geometry.
     * @param {Boolean} [throttleRequests=true] True if the number of simultaneous requests should be limited,
     *                  or false if the request should be initiated regardless of the number of requests
     *                  already in progress.
     * @returns {Promise.<TerrainData>|undefined} A promise for the requested geometry.  If this method
     *          returns undefined instead of a promise, it is an indication that too many requests are already
     *          pending and the request will be retried later.
     *
     * @exception {DeveloperError} This function must not be called before {@link CesiumTerrainProvider#ready}
     *            returns true.
     */
    func requestTileGeometry(_ x: Int, y: Int, level: Int, throttleRequests: Bool = true, completionBlock: @escaping (TerrainData?) -> ()) {
        assert(ready, "requestTileGeometry must not be called before the terrain provider is ready.")
        
        if _tileUrlTemplates.isEmpty {
            completionBlock(nil)
        }
        
        let yTiles = tilingScheme.numberOfYTilesAtLevel(level)
        
        let tmsY = yTiles - y - 1
        
        let url = _tileUrlTemplates[(x + tmsY + level) % _tileUrlTemplates.count].replace("{z}", "\(level)").replace("{x}", "\(x)").replace("{y}", "\(tmsY)")
        
        /*
         var proxy = this._proxy;
         if (defined(proxy)) {
         url = proxy.getURL(url);
         }*/
        
        var extensionList = [String]()
        if hasVertexNormals {
            extensionList.append(_littleEndianExtensionSize ? "octvertexnormals" : "vertexnormals")
        }
        if _requestWaterMask && _hasWaterMask {
            extensionList.append("watermask")
        }
        
        let tileLoader = NetworkOperation(url: url, headers: getRequestHeader(extensionList))
        tileLoader.completionBlock = {
            if let error = tileLoader.error {
                print(error.localizedDescription)
                return
            }
            QueueManager.sharedInstance.processorQueue.async {
                var terrainData: TerrainData? = nil
                if self._heightmapStructure != nil {
                    terrainData = nil
                    //return createHeightmapTerrainData(that, buffer, level, x, y, tmsY);
                } else {
                    self.createQuantizedMeshTerrainData(tileLoader.data, level: level, x: x, y: y, tmsY: tmsY, completionBlock: { data in terrainData = data })
                }
                DispatchQueue.main.async {
                    completionBlock(terrainData)
                }
            }
        }
        tileLoader.enqueue()
    }
    
        /*
        defineProperties(CesiumTerrainProvider.prototype, {
        /**
        * Gets an event that is raised when the terrain provider encounters an asynchronous error.  By subscribing
        * to the event, you will be notified of the error and can potentially recover from it.  Event listeners
        * are passed an instance of {@link TileProviderError}.
        * @memberof CesiumTerrainProvider.prototype
        * @type {Event}
        */
        errorEvent : {
        get : function() {
        return this._errorEvent;
        }
        },
        
        /**
        * Gets the credit to display when this terrain provider is active.  Typically this is used to credit
        * the source of the terrain.  This function should not be called before {@link CesiumTerrainProvider#ready} returns true.
        * @memberof CesiumTerrainProvider.prototype
        * @type {Credit}
        */
        credit : {
        get : function() {
        //>>includeStart('debug', pragmas.debug)
        if (!this._ready) {
        throw new DeveloperError('credit must not be called before the terrain provider is ready.');
        }
        //>>includeEnd('debug');
        
        return this._credit;
        }
        },
        
        /**
        * Gets the tiling scheme used by this provider.  This function should
        * not be called before {@link CesiumTerrainProvider#ready} returns true.
        * @memberof CesiumTerrainProvider.prototype
        * @type {GeographicTilingScheme}
        */
        tilingScheme : {
        get : function() {
        //>>includeStart('debug', pragmas.debug)
        if (!this._ready) {
        throw new DeveloperError('tilingScheme must not be called before the terrain provider is ready.');
        }
        //>>includeEnd('debug');
        
        return this._tilingScheme;
        }
        },
        
        /**
        * Gets a value indicating whether or not the provider is ready for use.
        * @memberof CesiumTerrainProvider.prototype
        * @type {Boolean}
        */
        ready : {
        get : function() {
        return this._ready;
        }
        },
        
        /**
        * Gets a promise that resolves to true when the provider is ready for use.
        * @memberof CesiumTerrainProvider.prototype
        * @type {Promise.<Boolean>}
        * @readonly
        */
        readyPromise : {
        get : function() {
        return this._readyPromise.promise;
        }
        },
        */
/*
        /**
        * Boolean flag that indicates if the client should request a watermask from the server.
        * Watermask data is appended to the standard tile mesh data only if the client requests the watermask and
        * if the server provides a watermask.
        * @memberof CesiumTerrainProvider.prototype
        * @type {Boolean}
        */
        requestWaterMask : {
        get : function() {
        return this._requestWaterMask;
        }
        }
        });
        */
    
    /**
     * Gets the maximum geometric error allowed in a tile at a given level.
     *
     * @param {Number} level The tile level for which to get the maximum geometric error.
     * @returns {Number} The maximum geometric error.
     */
    func levelMaximumGeometricError (_ level: Int) -> Double {
        return _levelZeroMaximumGeometricError / Double(1 << level)
    }
    
    func calculateTileCount () {
        var tileCount = 0
        do {
            guard let availableTiles = _availableTiles else {
                return
            }
            for i in 0...15 {
                var thisLevelCount = 0
                guard let tileArray = availableTiles[i].array else { continue }
                do {
                    for tileBlock in tileArray {
                        let blockStartX = try tileBlock.getInt(key: "startX")
                        let blockStartY = try tileBlock.getInt(key: "startY")
                        let blockEndX = try tileBlock.getInt(key: "endX")
                        let blockEndY = try tileBlock.getInt(key: "endY")
                        let blockWidth = blockEndX - blockStartX + 1
                        let blockHeight = blockEndY - blockStartY + 1
                        let blockCount = blockWidth * blockHeight
                        thisLevelCount += blockCount
                    }
                }
                tileCount += thisLevelCount
                print("\(thisLevelCount) tiles at level \(i), \(tileCount) total")
                
            }
        } catch {
            return
        }
    }
    
    func getChildMaskForTile(_ level: Int, x: Int, y: Int) -> Int {
        guard let availableTiles = _availableTiles else {
            return 15
        }
        
        if availableTiles.count == 0 {
            return 15
        }
        
        let childLevel = level + 1
        if childLevel >= availableTiles.count {
            return 0
        }

        guard let levelAvailable = availableTiles[childLevel].array else {
            return 0
        }
        
        var mask = 0
        mask |= isTileInRange(levelAvailable, x: 2 * x, y: 2 * y) ? 1 : 0
        mask |= isTileInRange(levelAvailable, x: 2 * x + 1, y: 2 * y) ? 2 : 0
        mask |= isTileInRange(levelAvailable, x: 2 * x, y: 2 * y + 1) ? 4 : 0
        mask |= isTileInRange(levelAvailable, x: 2 * x + 1, y: 2 * y + 1) ? 8 : 0
        
        return mask
    }
    
    func isTileInRange(_ levelAvailable: JSONArray, x: Int, y: Int) -> Bool {
        for range in levelAvailable {
            do {
                let startX = try range.getInt(key: "startX")
                let endX = try range.getInt(key: "endX")
                let startY = try range.getInt(key: "startY")
                let endY = try range.getInt(key: "endY")
                
                if x >= startX && x <= endX && y >= startY && y <= endY {
                    return true
                }
                
            } catch {
                return false
            }

        }
        return false
    }
    /*
        /**
        * Determines whether data for a tile is available to be loaded.
        *
        * @param {Number} x The X coordinate of the tile for which to request geometry.
        * @param {Number} y The Y coordinate of the tile for which to request geometry.
        * @param {Number} level The level of the tile for which to request geometry.
        * @returns {Boolean} Undefined if not supported, otherwise true or false.
        */
        CesiumTerrainProvider.prototype.getTileDataAvailable = function(x, y, level) {
        var available = this._availableTiles;
        
        if (!available || available.length === 0) {
        return undefined;
        } else {
        if (level >= available.length) {
        return false;
        }
        var levelAvailable = available[level];
        var yTiles = this._tilingScheme.getNumberOfYTilesAtLevel(level);
        var tmsY = (yTiles - y - 1);
        return isTileInRange(levelAvailable, x, tmsY);
        }
        };
        
        return CesiumTerrainProvider;
        });

    */
    static func estimatedLevelZeroGeometricErrorForAHeightmap(
        _ ellipsoid: Ellipsoid,
        tileImageWidth: Int,
        numberOfTilesAtLevelZero: Int) -> Double {
            return ellipsoid.maximumRadius * Math.TwoPi * 0.25/*heightmapTerrainQuality*/ / Double(tileImageWidth * numberOfTilesAtLevelZero)
    }
    
}
