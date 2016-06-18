//
//  TileBoundingBox.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * @param {Object} options Object with the following properties:
 * @param {Rectangle} options.rectangle
 * @param {Number} [options.minimumHeight=0.0]
 * @param {Number} [options.maximumHeight=0.0]
 * @param {Ellipsoid} [options.ellipsoid=Cesium.Ellipsoid.WGS84]
 *
 * @private
 */
struct TileBoundingBox {
    
    /**
     * The world coordinates of the southwest corner of the tile's rectangle.
     *
     * @type {Cartesian3}
     * @default Cartesian3()
     */
    private (set) var southwestCornerCartesian = Cartesian3()
    
    /**
     * The world coordinates of the northeast corner of the tile's rectangle.
     *
     * @type {Cartesian3}
     * @default Cartesian3()
     */
    private (set) var northeastCornerCartesian = Cartesian3()
    
    /**
     * A normal that, along with southwestCornerCartesian, defines a plane at the western edge of
     * the tile.  Any position above (in the direction of the normal) this plane is outside the tile.
     *
     * @type {Cartesian3}
     * @default Cartesian3()
     */
    private (set) var westNormal = Cartesian3()
    
    /**
     * A normal that, along with southwestCornerCartesian, defines a plane at the southern edge of
     * the tile.  Any position above (in the direction of the normal) this plane is outside the tile.
     * Because points of constant latitude do not necessary lie in a plane, positions below this
     * plane are not necessarily inside the tile, but they are close.
     *
     * @type {Cartesian3}
     * @default Cartesian3()
     */
    private (set) var southNormal = Cartesian3()
    
    /**
     * A normal that, along with northeastCornerCartesian, defines a plane at the eastern edge of
     * the tile.  Any position above (in the direction of the normal) this plane is outside the tile.
     *
     * @type {Cartesian3}
     * @default Cartesian3()
     */
    private (set) var eastNormal = Cartesian3()
    
    /**
     * A normal that, along with northeastCornerCartesian, defines a plane at the eastern edge of
     * the tile.  Any position above (in the direction of the normal) this plane is outside the tile.
     * Because points of constant latitude do not necessary lie in a plane, positions below this
     * plane are not necessarily inside the tile, but they are close.
     *
     * @type {Cartesian3}
     * @default Cartesian3()
     */
    private (set) var northNormal = Cartesian3()
    
    let rectangle: Rectangle
    
    let minimumHeight: Double
    
    let maximumHeight: Double
    
    let ellipsoid: Ellipsoid
    
    init (rectangle: Rectangle, ellipsoid: Ellipsoid = Ellipsoid.wgs84(), minimumHeight: Double = 0.0, maximumHeight: Double = 0.0) {
        self.rectangle = rectangle
        self.ellipsoid = ellipsoid
        self.minimumHeight = minimumHeight
        self.maximumHeight = maximumHeight

        computeBox()
    }
    
    private mutating func computeBox() {
        southwestCornerCartesian = ellipsoid.cartographicToCartesian(rectangle.southwest)
        northeastCornerCartesian = ellipsoid.cartographicToCartesian(rectangle.northeast)
        
        // The middle latitude on the western edge.
        let westernMidpointCartesian = ellipsoid.cartographicToCartesian(
            Cartographic(
                longitude: rectangle.west,
                latitude: (rectangle.south + rectangle.north) * 0.5,
                height: 0.0
            )
        )
        // Compute the normal of the plane on the western edge of the tile.
        westNormal = westernMidpointCartesian
            .cross(Cartesian3.unitZ)
            .normalize()
        
        // The middle latitude on the eastern edge.
        let easternMidpointCartesian = ellipsoid.cartographicToCartesian(
            Cartographic(
                longitude: rectangle.east,
                latitude: (rectangle.south + rectangle.north) * 0.5,
                height: 0.0
            )
        )
        
        // Compute the normal of the plane on the eastern edge of the tile.
        eastNormal = Cartesian3
            .unitZ
            .cross(easternMidpointCartesian)
            .normalize()
        
        // Compute the normal of the plane bounding the southern edge of the tile.
        let southeastCornerNormal = ellipsoid.geodeticSurfaceNormalCartographic(rectangle.southeast)
        let westVector = westernMidpointCartesian.subtract(easternMidpointCartesian)
        southNormal = southeastCornerNormal
            .cross(westVector)
            .normalize()
        
        // Compute the normal of the plane bounding the northern edge of the tile.
        let northwestCornerNormal = ellipsoid.geodeticSurfaceNormalCartographic(rectangle.northwest)
        northNormal = westVector
            .cross(northwestCornerNormal)
            .normalize()
    }
    
    private let negativeUnitY = Cartesian3(x: 0.0, y: -1.0, z: 0.0)
    private let negativeUnitZ = Cartesian3(x: 0.0, y: 0.0, z: -1.0)
    
    /**
     * Gets the distance from the camera to the closest point on the tile.  This is used for level-of-detail selection.
     *
     * @param {FrameState} frameState The state information of the current rendering frame.
     *
     * @returns {Number} The distance from the camera to the closest point on the tile, in meters.
     */
    func distanceToCamera (_ frameState: FrameState) -> Double {
        let camera = frameState.camera!
        let cameraCartesianPosition = camera.positionWC
        let cameraCartographicPosition = camera.positionCartographic
        
        var result = 0.0
        if !rectangle.contains(cameraCartographicPosition) {
            var southwestCornerCartesian = self.southwestCornerCartesian
            var northeastCornerCartesian = self.northeastCornerCartesian
            var westNormal = self.westNormal
            var southNormal = self.southNormal
            var eastNormal = self.eastNormal
            var northNormal = self.northNormal
            
            if frameState.mode != .scene3D {
                southwestCornerCartesian = frameState.mapProjection.project(rectangle.southwest)
                southwestCornerCartesian.z = southwestCornerCartesian.y
                southwestCornerCartesian.y = southwestCornerCartesian.x
                southwestCornerCartesian.x = 0.0
                northeastCornerCartesian = frameState.mapProjection.project(rectangle.northeast)
                northeastCornerCartesian.z = northeastCornerCartesian.y
                northeastCornerCartesian.y = northeastCornerCartesian.x
                northeastCornerCartesian.x = 0.0
                westNormal = negativeUnitY
                eastNormal = Cartesian3.unitY
                southNormal = negativeUnitZ
                northNormal = Cartesian3.unitZ
            }
            
            let vectorFromSouthwestCorner = cameraCartesianPosition.subtract(southwestCornerCartesian)
            let distanceToWestPlane = vectorFromSouthwestCorner.dot(westNormal)
            let distanceToSouthPlane = vectorFromSouthwestCorner.dot(southNormal)
            
            let vectorFromNortheastCorner = cameraCartesianPosition.subtract(northeastCornerCartesian)
            let distanceToEastPlane = vectorFromNortheastCorner.dot(eastNormal)
            let distanceToNorthPlane = vectorFromNortheastCorner.dot(northNormal)
            
            if distanceToWestPlane > 0.0 {
                result += distanceToWestPlane * distanceToWestPlane
            } else if distanceToEastPlane > 0.0 {
                result += distanceToEastPlane * distanceToEastPlane
            }
            
            if distanceToSouthPlane > 0.0 {
                result += distanceToSouthPlane * distanceToSouthPlane
            } else if distanceToNorthPlane > 0.0 {
                result += distanceToNorthPlane * distanceToNorthPlane
            }
        }
        
        let cameraHeight: Double
        if frameState.mode == SceneMode.scene3D {
            cameraHeight = cameraCartographicPosition.height
        } else {
            cameraHeight = cameraCartesianPosition.x
        }
        
        let maximumHeight = frameState.mode == SceneMode.scene3D ? self.maximumHeight : 0.0
        let distanceFromTop = cameraHeight - maximumHeight
        if distanceFromTop > 0.0 {
            result += distanceFromTop * distanceFromTop
        }
        
        return sqrt(result)
    }
    
}
