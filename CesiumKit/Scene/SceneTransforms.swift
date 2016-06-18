//
//  SceneTransforms.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/11/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

struct SceneTransforms {
    /*
    /*global define*/
    define([
    '../Core/BoundingRectangle',
    '../Core/Cartesian2',
    '../Core/Cartesian3',
    '../Core/Cartesian4',
    '../Core/Cartographic',
    '../Core/defined',
    '../Core/DeveloperError',
    '../Core/Math',
    '../Core/Matrix4',
    './SceneMode'
    ], function(
    BoundingRectangle,
    Cartesian2,
    Cartesian3,
    Cartesian4,
    Cartographic,
    defined,
    DeveloperError,
    CesiumMath,
    Matrix4,
    SceneMode) {
    "use strict";
    
    /**
    * Functions that do scene-dependent transforms between rendering-related coordinate systems.
    *
    * @namespace
    * @alias SceneTransforms
    */
    var SceneTransforms = {};
    
    var actualPositionScratch = new Cartesian4(0, 0, 0, 1);
    var positionCC = new Cartesian4();
    var viewProjectionScratch = new Matrix4();
    */
    /**
    * Transforms a position in WGS84 coordinates to window coordinates.  This is commonly used to place an
    * HTML element at the same screen position as an object in the scene.
    *
    * @param {Scene} scene The scene.
    * @param {Cartesian3} position The position in WGS84 (world) coordinates.
    * @param {Cartesian2} [result] An optional object to return the input position transformed to window coordinates.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.  This may be <code>undefined</code> if the input position is near the center of the ellipsoid.
    *
    * @example
    * // Output the window position of longitude/latitude (0, 0) every time the mouse moves.
    * var scene = widget.scene;
    * var ellipsoid = scene.globe.ellipsoid;
    * var position = Cesium.Cartesian3.fromDegrees(0.0, 0.0);
    * var handler = new Cesium.ScreenSpaceEventHandler(scene.canvas);
    * handler.setInputAction(function(movement) {
    *     console.log(Cesium.SceneTransforms.wgs84ToWindowCoordinates(scene, position));
    * }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);
    */
    static func wgs84ToWindowCoordinates (_ scene: Scene, position: Cartesian3) -> Cartesian2? {
        return SceneTransforms.wgs84WithEyeOffsetToWindowCoordinates(scene, position: position, eyeOffset: Cartesian3.zero)
    }
    
    
    private static func worldToClip(_ position: Cartesian3, eyeOffset: Cartesian3, camera: Camera) -> Cartesian4 {
        let viewMatrix = camera.viewMatrix
        
        var positionEC = viewMatrix.multiplyByVector(Cartesian4(x: position.x, y: position.y, z: position.z, w: 1.0))
        
        let zEyeOffset = eyeOffset.multiplyComponents(Cartesian3(cartesian4: positionEC.normalize()))
        positionEC.x += eyeOffset.x + zEyeOffset.x
        positionEC.y += eyeOffset.y + zEyeOffset.y
        positionEC.z += zEyeOffset.z
        
        return camera.frustum.projectionMatrix.multiplyByVector(positionEC)
    }
    
    static func wgs84WithEyeOffsetToWindowCoordinates (_ scene: Scene, position: Cartesian3, eyeOffset: Cartesian3) -> Cartesian2? {
        // Transform for 3D, 2D, or Columbus view
        let frameState = scene.frameState
        guard let actualPosition = SceneTransforms.computeActualWgs84Position(frameState, position: position) else {
            return nil
        }
        // Assuming viewport takes up the entire canvas...
        let sceneWidth = Double(scene.drawableWidth)
        let sceneHeight = Double(scene.drawableHeight)
        var viewport = Cartesian4(x: 0, y: 0, width: sceneWidth, height: sceneHeight)
        
        let camera = scene.camera
        var cameraCentered = false
        
        var positionCC = Cartesian4()
        var result = Cartesian2()
        var windowCoord0 = Cartesian2()
        var windowCoord1 = Cartesian2()
        
        if frameState.mode == .scene2D {
            let projection = scene.mapProjection
            let maxCartographic = Cartographic(longitude: M_PI, latitude: M_PI_2)
            let maxCoord = projection.project(maxCartographic)
            
            let cameraPosition = camera.position
            let frustum = camera.frustum
            
            let viewportTransformation = Matrix4.computeViewportTransformation(viewport, nearDepthRange: 0.0, farDepthRange: 1.0)
            let projectionMatrix = camera.frustum.projectionMatrix
            
            let x = camera.positionWC.y
            let eyePoint = Cartesian3(x: Double(Math.sign(x)) * maxCoord.x - x, y: 0.0, z: -camera.positionWC.x)
            let windowCoordinates = Transforms.pointToGLWindowCoordinates(modelViewProjectionMatrix: projectionMatrix, viewportTransformation: viewportTransformation, point: eyePoint)
            
            if x == 0.0 || windowCoordinates.x <= 0.0 || windowCoordinates.x >= sceneWidth {
                cameraCentered = true
            } else {
                if windowCoordinates.x > sceneWidth * 0.5 {
                    viewport.width = windowCoordinates.x
                    
                    camera.frustum.right = maxCoord.x - x
                    
                    positionCC = worldToClip(actualPosition, eyeOffset: eyeOffset, camera: camera)
                    let windowCoord0 = SceneTransforms.clipToGLWindowCoordinates(viewport, position: positionCC)
                    
                    viewport.x += windowCoordinates.x
                    
                    camera.position.x = -camera.position.x
                
                    var right = camera.frustum.right
                    camera.frustum.right = -camera.frustum.left
                    camera.frustum.left = -right
                    
                    positionCC = worldToClip(actualPosition, eyeOffset: eyeOffset, camera: camera)
                    windowCoord1 = SceneTransforms.clipToGLWindowCoordinates(viewport, position: positionCC)
                } else {
                    viewport.x += windowCoordinates.x
                    viewport.width -= windowCoordinates.x
                    
                    camera.frustum.left = -maxCoord.x - x
                    
                    positionCC = worldToClip(actualPosition, eyeOffset: eyeOffset, camera: camera)
                    windowCoord0 = SceneTransforms.clipToGLWindowCoordinates(viewport, position: positionCC)
                    
                    viewport.x -= viewport.width
                    camera.position.x = -camera.position.x
                    let left = camera.frustum.left
                    camera.frustum.left = -camera.frustum.right
                    camera.frustum.right = -left
                    
                    positionCC = worldToClip(actualPosition, eyeOffset: eyeOffset, camera: camera)
                    windowCoord1 = SceneTransforms.clipToGLWindowCoordinates(viewport, position: positionCC)
                }
                
                camera.position = cameraPosition
                camera.frustum = frustum
                
                result = windowCoord0
                if result.x < 0.0 || result.x > sceneWidth {
                    result.x = windowCoord1.x
                }
            }
        }
        if frameState.mode != SceneMode.scene3D || cameraCentered {
            // View-projection matrix to transform from world coordinates to clip coordinates
            positionCC = worldToClip(actualPosition, eyeOffset: eyeOffset, camera: camera)
            if positionCC.z < 0 && frameState.mode != .scene2D {
                return nil
            }
            
            result = SceneTransforms.clipToGLWindowCoordinates(viewport, position: positionCC)
        }
        
        result.y = sceneHeight - result.y
        return result
    }
    /*
    /**
    * Transforms a position in WGS84 coordinates to drawing buffer coordinates.  This may produce different
    * results from SceneTransforms.wgs84ToWindowCoordinates when the browser zoom is not 100%, or on high-DPI displays.
    *
    * @param {Scene} scene The scene.
    * @param {Cartesian3} position The position in WGS84 (world) coordinates.
    * @param {Cartesian2} [result] An optional object to return the input position transformed to window coordinates.
    * @returns {Cartesian2} The modified result parameter or a new Cartesian2 instance if one was not provided.  This may be <code>undefined</code> if the input position is near the center of the ellipsoid.
    *
    * @example
    * // Output the window position of longitude/latitude (0, 0) every time the mouse moves.
    * var scene = widget.scene;
    * var ellipsoid = scene.globe.ellipsoid;
    * var position = Cesium.Cartesian3.fromDegrees(0.0, 0.0));
    * var handler = new Cesium.ScreenSpaceEventHandler(scene.canvas);
    * handler.setInputAction(function(movement) {
    *     console.log(Cesium.SceneTransforms.wgs84ToWindowCoordinates(scene, position));
    * }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);
    */
     SceneTransforms.wgs84ToDrawingBufferCoordinates = function(scene, position, result) {
     result = SceneTransforms.wgs84ToWindowCoordinates(scene, position, result);
     if (!defined(result)) {
     return undefined;
     }
     
     return SceneTransforms.transformWindowToDrawingBuffer(scene, result, result);
     };
    */
    
    /**
    * @private
    */
    private static func computeActualWgs84Position (_ frameState: FrameState, position: Cartesian3) -> Cartesian3? {
        
        let mode = frameState.mode
        
        if mode == .scene3D {
            return position
        }
        
        let projection = frameState.mapProjection
        guard let cartographic = projection.ellipsoid.cartesianToCartographic(position) else {
            return nil
        }
        
        let projectedPosition = projection.project(cartographic)
        
        if mode == .columbusView {
            return Cartesian3(x: projectedPosition.z, y: projectedPosition.x, z: projectedPosition.y)
        }
        
        if mode == .scene2D {
            return Cartesian3(x: 0.0, y: projectedPosition.x, z: projectedPosition.y)
        }
        
        // mode === SceneMode.MORPHING
        let morphTime = frameState.morphTime
        return Cartesian3(
            x: Math.lerp(p: projectedPosition.z, q: position.x, time: morphTime),
            y: Math.lerp(p: projectedPosition.x, q: position.y, time: morphTime),
            z: Math.lerp(p: projectedPosition.y, q: position.z, time: morphTime)
        )
    }
    
    /*var positionNDC = new Cartesian3();
    var positionWC = new Cartesian3();
    var viewport = new BoundingRectangle();
    var viewportTransform = new Matrix4();*/
    
    /**
    * @private
    */
    private static func clipToGLWindowCoordinates (_ viewport: Cartesian4, position: Cartesian4) -> Cartesian2 {
        
        // Perspective divide to transform from clip coordinates to normalized device coordinates
        let positionNDC = position.divideByScalar(position.w)
        
        // Viewport transform to transform from clip coordinates to window coordinates
        let viewportTransform = Matrix4.computeViewportTransformation(viewport)
        
        let positionWC = viewportTransform.multiplyByPoint(Cartesian3(cartesian4: positionNDC))
        
        return Cartesian2(cartesian3: positionWC)
    }
    
    /*
    /**
    * @private
    */
    SceneTransforms.clipToDrawingBufferCoordinates = function(viewport, position, result) {
    // Perspective divide to transform from clip coordinates to normalized device coordinates
    Cartesian3.divideByScalar(position, position.w, positionNDC);
    
    Matrix4.computeViewportTransformation(viewport, 0.0, 1.0, viewportTransform);
    
    // Viewport transform to transform from clip coordinates to drawing buffer coordinates
    Matrix4.multiplyByPoint(viewportTransform, positionNDC, positionWC);
    
    return Cartesian2.fromCartesian3(positionWC, result);
    };
    
    /**
    * @private
    */
    SceneTransforms.transformWindowToDrawingBuffer = function(scene, windowPosition, result) {
    var canvas = scene.canvas;
    var xScale = scene.drawingBufferWidth / canvas.clientWidth;
    var yScale = scene.drawingBufferHeight / canvas.clientHeight;
    return Cartesian2.fromElements(windowPosition.x * xScale, windowPosition.y * yScale, result);
    };
    
    var scratchNDC = new Cartesian4();
    var scratchWorldCoords = new Cartesian4();
    
    /**
    * @private
    */
    SceneTransforms.drawingBufferToWgs84Coordinates = function(scene, drawingBufferPosition, depth, result) {
    var context = scene.context;
    
     var viewport = scene._passState.viewport;    
    var viewportTransformation = uniformState.viewportTransformation;
    
    var ndc = Cartesian4.clone(Cartesian4.UNIT_W, scratchNDC);
    ndc.x = (drawingBufferPosition.x - viewport.x) / viewport.width * 2.0 - 1.0;
    ndc.y = (drawingBufferPosition.y - viewport.y) / viewport.height * 2.0 - 1.0;
    ndc.z = (depth * 2.0) - 1.0;
    ndc.w = 1.0;
    
    var worldCoords = Matrix4.multiplyByVector(uniformState.inverseViewProjection, ndc, scratchWorldCoords);
    
    // Reverse perspective divide
    var w = 1.0 / worldCoords.w;
    Cartesian3.multiplyByScalar(worldCoords, w, worldCoords);
    
    return Cartesian3.fromCartesian4(worldCoords, result);
    };
    
    return SceneTransforms;
    });

    */
}
