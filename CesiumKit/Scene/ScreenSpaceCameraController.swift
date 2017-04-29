//
//  ScreenSpaceCameraController.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Modifies the camera position and orientation based on mouse input to a canvas.
* @alias ScreenSpaceCameraController
* @constructor
*
* @param {Scene} scene The scene.
*/
open class ScreenSpaceCameraController {
    
    /**
    * If true, inputs are allowed conditionally with the flags enableTranslate, enableZoom,
    * enableRotate, enableTilt, and enableLook.  If false, all inputs are disabled.
    *
    * NOTE: This setting is for temporary use cases, such as camera flights and
    * drag-selection of regions (see Picking demo).  It is typically set to false at the
    * start of such events, and set true on completion.  To keep inputs disabled
    * past the end of camera flights, you must use the other booleans (enableTranslate,
    * enableZoom, enableRotate, enableTilt, and enableLook).
    * @type {Boolean}
    * @default true
    */
    var enableInputs = true
    
    /**
    * If true, allows the user to pan around the map.  If false, the camera stays locked at the current position.
    * This flag only applies in 2D and Columbus view modes.
    * @type {Boolean}
    * @default true
    */
    var enableTranslate = true
    
    /**
    * If true, allows the user to zoom in and out.  If false, the camera is locked to the current distance from the ellipsoid.
    * @type {Boolean}
    * @default true
    */
    var enableZoom = true
    
    /**
    * If true, allows the user to rotate the camera.  If false, the camera is locked to the current heading.
    * This flag only applies in 2D and 3D.
    * @type {Boolean}
    * @default true
    */
    var enableRotate = true
    
    /**
    * If true, allows the user to tilt the camera.  If false, the camera is locked to the current heading.
    * This flag only applies in 3D and Columbus view.
    * @type {Boolean}
    * @default true
    */
    var enableTilt = true
    
    /**
    * If true, allows the user to use free-look. If false, the camera view direction can only be changed through translating
    * or rotating. This flag only applies in 3D and Columbus view modes.
    * @type {Boolean}
    * @default true
    */
    var enableLook = true
    
    /**
    * A parameter in the range <code>[0, 1)</code> used to determine how long
    * the camera will continue to spin because of inertia.
    * With value of zero, the camera will have no inertia.
    * @type {Number}
    * @default 0.9
    */
    var inertiaSpin = 0.9
    
    /**
    * A parameter in the range <code>[0, 1)</code> used to determine how long
    * the camera will continue to translate because of inertia.
    * With value of zero, the camera will have no inertia.
    * @type {Number}
    * @default 0.9
    */
    var inertiaTranslate = 0.9
    
    /**
    * A parameter in the range <code>[0, 1)</code> used to determine how long
    * the camera will continue to zoom because of inertia.
    * With value of zero, the camera will have no inertia.
    * @type {Number}
    * @default 0.8
    */
    var inertiaZoom = 0.8
    
    /**
    * A parameter in the range <code>[0, 1)</code> used to limit the range
    * of various user inputs to a percentage of the window width/height per animation frame.
    * This helps keep the camera under control in low-frame-rate situations.
    * @type {Number}
    * @default 0.1
    */
    var maximumMovementRatio = 0.1
    
    /**
    * Sets the duration, in seconds, of the bounce back animations in 2D and Columbus view.
    * @type {Number}
    * @default 3.0
    */
    var bounceAnimationTime = 3.0
    
    /**
    * The minimum magnitude, in meters, of the camera position when zooming. Defaults to 20.0.
    * @type {Number}
    * @default 20.0
    */
    var minimumZoomDistance = 1.0
    
    /**
    * The maximum magnitude, in meters, of the camera position when zooming. Defaults to positive infinity.
    * @type {Number}
    * @default {@link Number.POSITIVE_INFINITY}
    */
    var maximumZoomDistance = Double.infinity
    
    /**
    * The input that allows the user to pan around the map. This only applies in 2D and Columbus view modes.
    * <p>
    * The type came be a {@link CameraEventType}, <code>undefined</code>, an object with <code>eventType</code>
    * and <code>modifier</code> properties with types <code>CameraEventType</code> and {@link KeyboardEventModifier},
    * or an array of any of the preceding.
    * </p>
    * @type {CameraEventType|Array|undefined}
    * @default {@link CameraEventType.LEFT_DRAG}
    */
    var translateEventTypes = CameraEventType.leftDrag
    
    /**
    * The input that allows the user to zoom in/out.
    * <p>
    * The type came be a {@link CameraEventType}, <code>undefined</code>, an object with <code>eventType</code>
    * and <code>modifier</code> properties with types <code>CameraEventType</code> and {@link KeyboardEventModifier},
    * or an array of any of the preceding.
    * </p>
    * @type {CameraEventType|Array|undefined}
    * @default [{@link CameraEventType.RIGHT_DRAG}, {@link CameraEventType.WHEEL}, {@link CameraEventType.PINCH}]
    */
    var zoomEventTypes: [CameraEvent] = [
        CameraEvent(type: .rightDrag, modifier: nil),
        CameraEvent(type: .wheel, modifier: nil),
        CameraEvent(type: .pinch, modifier: nil)]
    
    /**
    * The input that allows the user to rotate around the globe or another object. This only applies in 3D and Columbus view modes.
    * <p>
    * The type came be a {@link CameraEventType}, <code>undefined</code>, an object with <code>eventType</code>
    * and <code>modifier</code> properties with types <code>CameraEventType</code> and {@link KeyboardEventModifier},
    * or an array of any of the preceding.
    * </p>
    * @type {CameraEventType|Array|undefined}
    * @default {@link CameraEventType.LEFT_DRAG}
    */
    var rotateEventTypes: [CameraEvent] = [CameraEvent(type: .leftDrag, modifier: nil)]
    
    /**
    * The input that allows the user to tilt in 3D and Columbus view or twist in 2D.
    * <p>
    * The type came be a {@link CameraEventType}, <code>undefined</code>, an object with <code>eventType</code>
    * and <code>modifier</code> properties with types <code>CameraEventType</code> and {@link KeyboardEventModifier},
    * or an array of any of the preceding.
    * </p>
    * @type {CameraEventType|Array|undefined}
    * @default [{@link CameraEventType.MIDDLE_DRAG}, {@link CameraEventType.PINCH}, {
    *     eventType : {@link CameraEventType.LEFT_DRAG},
    *     modifier : {@link KeyboardEventModifier.CTRL}
    * }, {
    *     eventType : {@link CameraEventType.RIGHT_DRAG},
    *     modifier : {@link KeyboardEventModifier.CTRL}
    * }]
    * }]
    */
    var tiltEventTypes: [CameraEvent] = [
        //FIXME: middleDrag
        //CameraEvent(type: .middleDrag, modifier: nil),
        CameraEvent(type: .pinch, modifier: nil),
        CameraEvent(type: .leftDrag, modifier: .ctrl),
        CameraEvent(type: .rightDrag, modifier: .ctrl)
    ]
    /**
    * The input that allows the user to change the direction the camera is viewing. This only applies in 3D and Columbus view modes.
    * <p>
    * The type came be a {@link CameraEventType}, <code>undefined</code>, an object with <code>eventType</code>
    * and <code>modifier</code> properties with types <code>CameraEventType</code> and {@link KeyboardEventModifier},
    * or an array of any of the preceding.
    * </p>
    * @type {CameraEventType|Array|undefined}
    * @default { eventType : {@link CameraEventType.LEFT_DRAG}, modifier : {@link KeyboardEventModifier.SHIFT} }
    */
    var lookEventTypes: [CameraEvent] = [
        CameraEvent(type: .leftDrag, modifier: .shift)
    ]
    
    /**
    * The minimum height the camera must be before picking the terrain instead of the ellipsoid.
    * @type {Number}
    * @default 150000.0
    */
    var minimumPickingTerrainHeight = 150000.0
    
    /**
    * The minimum height the camera must be before testing for collision with terrain.
    * @type {Number}
    * @default 15000.0
    */
    var minimumCollisionTerrainHeight = 15000.0
    
    /**
    * The minimum height the camera must be before switching from rotating a track ball to
    * free look when clicks originate on the sky on in space.
    * @type {Number}
    * @default 7500000.0
    */
    var minimumTrackBallHeight = 7500000.0
    
    /**
    * Enables or disables camera collision detection with terrain.
    * @type {Boolean}
    * @default true
    */
    var enableCollisionDetection = true
    
    weak fileprivate var _scene: Scene!
    weak fileprivate var _globe: Globe? = nil
    fileprivate var _ellipsoid: Ellipsoid!
    
    
    let _aggregator: CameraEventAggregator
    
    
    class MovementState: StartEndPosition {
        var startPosition = Cartesian2()
        var endPosition = Cartesian2()
        var motion = Cartesian2()
        var active = false
    }
    
    fileprivate var _intertiaMovementStates = [String: MovementState]()
    
    /*
    this._tweens = new TweenCollection();
    this._tween = undefined;
    */
    fileprivate var _horizontalRotationAxis: Cartesian3? = nil
    
    fileprivate var _tiltCenterMousePosition = Cartesian2(x: -1.0, y: -1.0)
    fileprivate var _tiltCenter = Cartesian3()
    fileprivate var _rotateMousePosition = Cartesian2(x: -1.0, y: -1.0)
    fileprivate var _rotateStartPosition = Cartesian3()
    fileprivate var _strafeStartPosition = Cartesian3()
    fileprivate var _zoomMouseStart = Cartesian2()
    fileprivate var _zoomWorldPosition = Cartesian3()
    fileprivate var _tiltCVOffMap = false
    fileprivate var _tiltOnEllipsoid = false
    fileprivate var _looking = false
    fileprivate var _rotating = false
    fileprivate var _strafing = false
    fileprivate var _zoomingOnVector = false
    fileprivate var _rotatingZoom = false
    
    var projection: MapProjection {
        return _scene.mapProjection
    }
    
    fileprivate var _maxCoord: Cartesian3
    
    // Constants, Make any of these public?*/
    fileprivate var _zoomFactor = 5.0
    fileprivate var _rotateFactor = 0.0
    fileprivate var _rotateRateRangeAdjustment = 0.0
    fileprivate var _maximumRotateRate = 1.77
    fileprivate var _minimumRotateRate = 1.0 / 5000.0
    fileprivate var _minimumZoomRate = 20.0
    fileprivate var _maximumZoomRate = 5906376272000.0  // distance from the Sun to Pluto in meters.
    
    init(scene: Scene) {
        _scene = scene
        _maxCoord = _scene.mapProjection.project(Cartographic(longitude: .pi, latitude: .pi/2))
        _aggregator = CameraEventAggregator(/*layer: _scene.context.layer*/)
    }
    
    func decay(_ time: Double, coefficient: Double) -> Double {
        if (time < 0) {
            return 0.0
        }
        
        let tau = (1.0 - coefficient) * 25.0
        return exp(-tau * time)
    }
    
    func sameMousePosition(_ movement: StartEndPosition) -> Bool {
        return movement.startPosition.equalsEpsilon(movement.endPosition, relativeEpsilon: Math.Epsilon14)
    }
    
    // If the time between mouse down and mouse up is not between
    // these thresholds, the camera will not move with inertia.
    // This value is probably dependent on the browser and/or the
    // hardware. Should be investigated further.
    var inertiaMaxClickTimeThreshold = 0.4
    
    func maintainInertia(_ type: CameraEventType, modifier: KeyboardEventModifier? = nil, decayCoef: Double, action: (_ startPosition: Cartesian2, _ movement: MouseMovement) -> (), lastMovementName: String) {
        
        var state = _intertiaMovementStates[lastMovementName]
        if state == nil {
            state = MovementState()
            _intertiaMovementStates[lastMovementName] = state!
        }
        let movementState = state!
        
        let ts = _aggregator.getButtonPressTime(type, modifier: modifier)
        let tr = _aggregator.getButtonReleaseTime(type, modifier: modifier)
        
        if let ts = ts, let tr = tr {
            let threshold = tr.timeIntervalSinceReferenceDate - ts.timeIntervalSinceReferenceDate
            let now = Date()
            let fromNow = now.timeIntervalSinceReferenceDate - tr.timeIntervalSinceReferenceDate
            
            if threshold < inertiaMaxClickTimeThreshold {
                let d = decay(fromNow, coefficient: decayCoef)
                if !movementState.active {
                    let lastMovement = _aggregator.getLastMovement(type, modifier: modifier)
                    if lastMovement == nil || sameMousePosition(lastMovement!) {
                        return
                    }
                    
                    movementState.motion.x = (lastMovement!.endPosition.x - lastMovement!.startPosition.x) * 0.5
                    movementState.motion.y = (lastMovement!.endPosition.y - lastMovement!.startPosition.y) * 0.5
                    
                    movementState.startPosition = lastMovement!.startPosition
                    
                    movementState.endPosition = movementState.startPosition.add(movementState.motion.multiplyBy(scalar: d))
                    
                    movementState.active = true
                } else {
                    movementState.startPosition = movementState.endPosition
                    movementState.endPosition = movementState.startPosition.add(movementState.motion.multiplyBy(scalar: d))
                    
                    movementState.motion = Cartesian2.zero
                }
                
                // If value from the decreasing exponential function is close to zero,
                // the end coordinates may be NaN.
                if (movementState.endPosition.x == Double.nan || movementState.endPosition.y == Double.nan) || sameMousePosition(movementState) {
                    movementState.active = false
                    return
                }
                
                if !_aggregator.isButtonDown(type, modifier: modifier) {
                    let startPosition = _aggregator.getStartMousePosition(type, modifier: modifier)
                    action(
                        startPosition,
                        MouseMovement(
                            startPosition: movementState.startPosition,
                            endPosition: movementState.endPosition,
                            angleStartPosition: Cartesian2(),
                            angleEndPosition: Cartesian2(),
                            prevAngle: 0.0,
                            valid: true
                        )
                    )
                }
            }
        } else {
            movementState.active = false
        }
        
    }
        
    func reactToInput(_ enabled: Bool, eventTypes: [CameraEvent], action: (_ startPosition: Cartesian2, _ movement: MouseMovement) -> (), inertiaConstant: Double, inertiaStateName: String? = nil) {

        var movement: MouseMovement? = nil
        
        for eventType in eventTypes {
            let type = eventType.type
            let modifier = eventType.modifier
            
            if _aggregator.isMoving(type, modifier: modifier) {
                movement = _aggregator.getMovement(type, modifier: modifier)
            }
            let startPosition = _aggregator.getStartMousePosition(type, modifier: modifier)
            
            if enableInputs && enabled {
                if movement != nil {
                    action(startPosition, movement!)
                } else if inertiaConstant < 1.0 && inertiaStateName != nil {
                    maintainInertia(type, modifier: modifier, decayCoef: inertiaConstant, action: action, lastMovementName: inertiaStateName!)
                }
            }
        }
    }
    
    /*var scratchZoomPickRay = new Ray();
    var scratchPickCartesian = new Cartesian3();
    var scratchZoomOffset = new Cartesian2();
    var scratchZoomDirection = new Cartesian3();
    var scratchCenterPixel = new Cartesian2();
    var scratchCenterPosition = new Cartesian3();
    var scratchPositionNormal = new Cartesian3();
    var scratchPickNormal = new Cartesian3();
    var scratchZoomAxis = new Cartesian3();
    var scratchCameraPositionNormal = new Cartesian3();*/
    
    func handleZoom(_ startPosition: Cartesian2, movement: MouseMovement, zoomFactor: Double, distanceMeasure: Double, unitPositionDotDirection: Double? = nil) {
        var percentage = 1.0
        if let unitPositionDotDirection = unitPositionDotDirection {
            percentage = Math.clamp(abs(unitPositionDotDirection), min: 0.25, max: 1.0)
        }
        // distanceMeasure should be the height above the ellipsoid.
        // The zoomRate slows as it approaches the surface and stops minimumZoomDistance above it.
        let minHeight = minimumZoomDistance * percentage
        let maxHeight = maximumZoomDistance
        
        let minDistance = distanceMeasure - minHeight
        let zoomRate = Math.clamp(zoomFactor * minDistance, min: _minimumZoomRate, max: _maximumZoomRate)
        
        let diff = movement.endPosition.y - movement.startPosition.y
        let rangeWindowRatio = min(diff / Double(_scene.drawableHeight), maximumMovementRatio)
        var distance = zoomRate * rangeWindowRatio
        
        if distance > 0.0 && abs(distanceMeasure - minHeight) < 1.0 {
            return
        }
        
        if distance < 0.0 && abs(distanceMeasure - maxHeight) < 1.0 {
            return
        }
        
        if distanceMeasure - distance < minHeight {
            distance = distanceMeasure - minHeight - 1.0
        } else if distanceMeasure - distance > maxHeight {
            distance = distanceMeasure - maxHeight
        }
        
        let camera = _scene.camera
        let mode = _scene.mode
        
        let pickedPosition: Cartesian3?
        if _globe != nil {
            pickedPosition = mode != .scene2D ? pickGlobe(startPosition) : camera.getPickRay(startPosition).origin
        } else {
            pickedPosition = nil
        }
        
        if pickedPosition == nil {
            camera.zoomIn(distance)
            return
        }
        
        let sameStartPosition = startPosition == _zoomMouseStart
        var zoomingOnVector = _zoomingOnVector
        var rotatingZoom = _rotatingZoom
        
        if !sameStartPosition {
            _zoomMouseStart = startPosition
            _zoomWorldPosition = pickedPosition!
            
            zoomingOnVector = _zoomingOnVector == false
            rotatingZoom = _rotatingZoom == false
        }
        
        var zoomOnVector = mode == .columbusView
        
        if !sameStartPosition || rotatingZoom {
            if mode == SceneMode.scene2D {
                let worldPosition = _zoomWorldPosition
                let endPosition = camera.position
                // FIXME: Object
                if !(worldPosition == endPosition) /*&& camera.positionCartographic.height < object._maxCoord.x * 2.0*/ {
                    let direction = worldPosition.subtract(endPosition).normalize()
                    
                    let d = worldPosition.distance(endPosition) * distance / (camera.getMagnitude() * 0.5)
                    camera.move(direction, amount: d * 0.5)
                    
                    // FIXME: savedX
                    /*if (camera.position.x < 0.0 && savedX > 0.0) || (camera.position.x > 0.0 && savedX < 0.0) {
                        pickedPosition = camera.getPickRay(startPosition, scratchZoomPickRay).origin;
                        object._zoomWorldPosition = Cartesian3.clone(pickedPosition, object._zoomWorldPosition);
                    }*/
                }
            } else if mode == .scene3D {
                let cameraPositionNormal = camera.position.normalize()
                if camera.positionCartographic.height < 3000.0 && abs(camera.direction.dot(cameraPositionNormal)) < 0.6 {
                    zoomOnVector = true
                } else {

                    let centerPixel = Cartesian2(x: Double(_scene.drawableWidth) / 2.0, y: Double(_scene.drawableHeight) / 2.0)
                    let centerPosition = pickGlobe(centerPixel)
                    if centerPosition != nil {
                        let positionNormal = centerPosition!.normalize()
                        let pickedNormal = _zoomWorldPosition.normalize()
                        let dotProduct = pickedNormal.dot(positionNormal)
                        
                        if dotProduct > 0.0 {
                            let angle = Math.acosClamped(dotProduct)
                            let axis = pickedNormal.cross(positionNormal)
                            
                            let denom = abs(angle) > Math.toRadians(20.0) ? camera.positionCartographic.height * 0.75 : camera.positionCartographic.height - distance
                            let scalar = distance / denom;
                            camera.rotate(axis, angle: angle * scalar)
                        }
                    } else {
                        zoomOnVector = true
                    }
                }
            }
            
            _rotatingZoom = !zoomOnVector
        }
        
        if (!sameStartPosition && zoomOnVector) || zoomingOnVector {

            let zoomMouseStart = SceneTransforms.wgs84ToWindowCoordinates(_scene, position: _zoomWorldPosition)
            let ray: Ray
            if mode != .columbusView && startPosition == _zoomMouseStart && zoomMouseStart != nil {
                ray = camera.getPickRay(zoomMouseStart!)
            } else {
                ray = camera.getPickRay(startPosition)
            }
            
            var rayDirection = ray.direction
            if mode == .columbusView {
                rayDirection = Cartesian3(x: rayDirection.y, y: rayDirection.z, z: rayDirection.x)
            }
            
            camera.move(rayDirection, amount: distance)
            
            _zoomingOnVector = true
        } else {
            camera.zoomIn(distance)
        }
    }
    
    /*
    var translate2DStart = new Ray();
    var translate2DEnd = new Ray();
    var scratchTranslateP0 = new Cartesian3();
    var scratchTranslateP1 = new Cartesian3();
    
    function translate2D(controller, startPosition, movement) {
    var scene = controller._scene;
    var camera = scene.camera;
    var start = camera.getPickRay(movement.startPosition, translate2DStart).origin;
    var end = camera.getPickRay(movement.endPosition, translate2DEnd).origin;
    var direction = Cartesian3.subtract(start, end, scratchTranslateP0);
    var distance = Cartesian3.magnitude(direction);
    
    if (distance > 0.0) {
    Cartesian3.normalize(direction, direction);
    camera.move(direction, distance);
    }
    }
    
    function zoom2D(controller, startPosition, movement) {
    if (defined(movement.distance)) {
    movement = movement.distance;
    }
    
    var scene = controller._scene;
    var camera = scene.camera;
    
    handleZoom(controller, startPosition, movement, controller._zoomFactor, camera.getMagnitude());
    }
    */
    func update2D() {
/*
         +        if (!Matrix4.equals(Matrix4.IDENTITY, controller._scene.camera.transform)) {
         +            reactToInput(controller, controller.enableZoom, controller.zoomEventTypes, zoom2D, controller.inertiaZoom, '_lastInertiaZoomMovement');
         +        } else {
         +            reactToInput(controller, controller.enableTranslate, controller.translateEventTypes, translate2D, controller.inertiaTranslate, '_lastInertiaTranslateMovement');
         +            reactToInput(controller, controller.enableZoom, controller.zoomEventTypes, zoom2D, controller.inertiaZoom, '_lastInertiaZoomMovement');
    }
    
    tweens.update();*/
    }

    func pickGlobe(_ mousePosition: Cartesian2) -> Cartesian3? {

        let camera = _scene.camera
        
        if _globe == nil {
            return nil
        }
        
        var depthIntersection: Cartesian3?
        if _scene.pickPositionSupported {
            depthIntersection = _scene.pickPosition(mousePosition)
        }
        
        let ray = camera.getPickRay(mousePosition)
        let rayIntersection = _globe!.pick(ray, scene: _scene)
        
        let pickDistance = depthIntersection?.distance(camera.positionWC) ?? Double.infinity
        let rayDistance = rayIntersection?.distance(camera.positionWC) ?? Double.infinity
        
        if pickDistance < rayDistance {
            return depthIntersection
        }
        return rayIntersection
    }
    
    /*
    var translateCVStartRay = new Ray();
    var translateCVEndRay = new Ray();
    var translateCVStartPos = new Cartesian3();
    var translateCVEndPos = new Cartesian3();
    var translatCVDifference = new Cartesian3();
    var translateCVOrigin = new Cartesian3();
    var translateCVPlane = new Plane(Cartesian3.ZERO, 0.0);
    var translateCVStartMouse = new Cartesian2();
    var translateCVEndMouse = new Cartesian2();
    
    if (!Cartesian3.equals(startPosition, controller._translateMousePosition)) {
    controller._looking = false;
    }
    
    if (!Cartesian3.equals(startPosition, controller._strafeMousePosition)) {
    controller._strafing = false;
    }
    
    if (controller._looking) {
    look3D(controller, startPosition, movement);
    return;
    }
    
    if (controller._strafing) {
    strafe(controller, startPosition, movement);
    return;
    }
    
    var scene = controller._scene;
    var camera = scene.camera;
    var startMouse = Cartesian2.clone(movement.startPosition, translateCVStartMouse);
    var endMouse = Cartesian2.clone(movement.endPosition, translateCVEndMouse);
    var startRay = camera.getPickRay(startMouse, translateCVStartRay);
    
    var origin = Cartesian3.clone(Cartesian3.ZERO, translateCVOrigin);
    var normal = Cartesian3.UNIT_X;
    
    var globePos;
    if (camera.position.z < controller.minimumPickingTerrainHeight) {
    globePos = pickGlobe(controller, startMouse, translateCVStartPos);
    if (defined(globePos)) {
    origin.x = globePos.x;
    }
    }
    
    if (origin.x > camera.position.z && defined(globePos)) {
    Cartesian3.clone(globePos, controller._strafeStartPosition);
    controller._strafing = true;
    strafe(controller, startPosition, movement);
    controller._strafeMousePosition = Cartesian2.clone(startPosition, controller._strafeMousePosition);
    return;
    }
    
    var plane = Plane.fromPointNormal(origin, normal, translateCVPlane);
    
    startRay = camera.getPickRay(startMouse, translateCVStartRay);
    var startPlanePos = IntersectionTests.rayPlane(startRay, plane, translateCVStartPos);
    
    var endRay = camera.getPickRay(endMouse, translateCVEndRay);
    var endPlanePos = IntersectionTests.rayPlane(endRay, plane, translateCVEndPos);
    
    if (!defined(startPlanePos) || !defined(endPlanePos)) {
    controller._looking = true;
    look3D(controller, startPosition, movement);
    Cartesian2.clone(startPosition, controller._translateMousePosition);
    return;
    }
    
    var diff = Cartesian3.subtract(startPlanePos, endPlanePos, translatCVDifference);
    var temp = diff.x;
    diff.x = diff.y;
    diff.y = diff.z;
    diff.z = temp;
    var mag = Cartesian3.magnitude(diff);
    if (mag > CesiumMath.EPSILON6) {
    Cartesian3.normalize(diff, diff);
    camera.move(diff, mag);
    }
    
    var rotateCVWindowPos = new Cartesian2();
    var rotateCVWindowRay = new Ray();
    var rotateCVCenter = new Cartesian3();
    var rotateCVVerticalCenter = new Cartesian3();
    var rotateCVTransform = new Matrix4();
    var rotateCVVerticalTransform = new Matrix4();
    var rotateCVOrigin = new Cartesian3();
    var rotateCVPlane = new Plane(Cartesian3.ZERO, 0.0);
    var rotateCVCartesian3 = new Cartesian3();
    var rotateCVCart = new Cartographic();
    var rotateCVOldTransform = new Matrix4();
    var rotateCVQuaternion = new Quaternion();
    var rotateCVMatrix = new Matrix3();
    
    function rotateCV(controller, startPosition, movement) {
    if (defined(movement.angleAndHeight)) {
    movement = movement.angleAndHeight;
    }
    
    if (!Cartesian2.equals(startPosition, controller._tiltCenterMousePosition)) {
    controller._tiltCVOffMap = false;
    controller._looking = false;
    }
    
    if (controller._looking) {
    look3D(controller, startPosition, movement);
    return;
    }
    
    var scene = controller._scene;
    var camera = scene.camera;
    var maxCoord = controller._maxCoord;
    var onMap = Math.abs(camera.position.x) - maxCoord.x < 0 && Math.abs(camera.position.y) - maxCoord.y < 0;
    
    if (controller._tiltCVOffMap || !onMap || camera.position.z > controller.minimumPickingTerrainHeight) {
    controller._tiltCVOffMap = true;
    rotateCVOnPlane(controller, startPosition, movement);
    } else {
    rotateCVOnTerrain(controller, startPosition, movement);
    }
    }
    
    function rotateCVOnPlane(controller, startPosition, movement) {
    var scene = controller._scene;
    var camera = scene.camera;
    var canvas = scene.canvas;
    
    var windowPosition = rotateCVWindowPos;
    windowPosition.x = canvas.clientWidth / 2;
    windowPosition.y = canvas.clientHeight / 2;
    var ray = camera.getPickRay(windowPosition, rotateCVWindowRay);
    var normal = Cartesian3.UNIT_X;
    
    var position = ray.origin;
    var direction = ray.direction;
    var scalar;
    var normalDotDirection = Cartesian3.dot(normal, direction);
    if (Math.abs(normalDotDirection) > CesiumMath.EPSILON6) {
    scalar = -Cartesian3.dot(normal, position) / normalDotDirection;
    }
    
    if (!defined(scalar) || scalar <= 0.0) {
    controller._looking = true;
    look3D(controller, startPosition, movement);
    Cartesian2.clone(startPosition, controller._tiltCenterMousePosition);
    return;
    }
    
    var center = Cartesian3.multiplyBy(scalar: direction, scalar, rotateCVCenter);
    Cartesian3.add(position, center, center);
    
    var projection = scene.mapProjection;
    var ellipsoid = projection.ellipsoid;
    
    Cartesian3.fromElements(center.y, center.z, center.x, center);
    var cart = projection.unproject(center, rotateCVCart);
    ellipsoid.cartographicToCartesian(cart, center);
    
    var transform = Transforms.eastNorthUpToFixedFrame(center, ellipsoid, rotateCVTransform);
    
    var oldGlobe = controller._globe;
    var oldEllipsoid = controller._ellipsoid;
    controller._globe = undefined;
    controller._ellipsoid = Ellipsoid.UNIT_SPHERE;
    controller._rotateFactor = 1.0;
    controller._rotateRateRangeAdjustment = 1.0;
    
    var oldTransform = Matrix4.clone(camera.transform, rotateCVOldTransform);
    camera._setTransform(transform);
    
    rotate3D(controller, startPosition, movement, Cartesian3.UNIT_Z);
    
    camera._setTransform(oldTransform);
    controller._globe = oldGlobe;
    controller._ellipsoid = oldEllipsoid;
    
    var radius = oldEllipsoid.maximumRadius;
    controller._rotateFactor = 1.0 / radius;
    controller._rotateRateRangeAdjustment = radius;
    }
    
    function rotateCVOnTerrain(controller, startPosition, movement) {
    var ellipsoid = controller._ellipsoid;
    var scene = controller._scene;
    var camera = scene.camera;
    
    var center;
    var ray;
    var normal = Cartesian3.UNIT_X;
    
    if (Cartesian2.equals(startPosition, controller._tiltCenterMousePosition)) {
    center = Cartesian3.clone(controller._tiltCenter, rotateCVCenter);
    } else {
    if (camera.position.z < controller.minimumPickingTerrainHeight) {
        center = pickGlobe(controller, startPosition, rotateCVCenter);
    }
    
    if (!defined(center)) {
    ray = camera.getPickRay(startPosition, rotateCVWindowRay);
    var position = ray.origin;
    var direction = ray.direction;
    
    var scalar;
    var normalDotDirection = Cartesian3.dot(normal, direction);
    if (Math.abs(normalDotDirection) > CesiumMath.EPSILON6) {
    scalar = -Cartesian3.dot(normal, position) / normalDotDirection;
    }
    
    if (!defined(scalar) || scalar <= 0.0) {
    controller._looking = true;
    look3D(controller, startPosition, movement);
    Cartesian2.clone(startPosition, controller._tiltCenterMousePosition);
    return;
    }
    
    center = Cartesian3.multiplyBy(scalar: direction, scalar, rotateCVCenter);
    Cartesian3.add(position, center, center);
    }
    
    Cartesian2.clone(startPosition, controller._tiltCenterMousePosition);
    Cartesian3.clone(center, controller._tiltCenter);
    }
    
    var canvas = scene.canvas;
    
    var windowPosition = rotateCVWindowPos;
    windowPosition.x = canvas.clientWidth / 2;
    windowPosition.y = controller._tiltCenterMousePosition.y;
    ray = camera.getPickRay(windowPosition, rotateCVWindowRay);
    
    var origin = Cartesian3.clone(Cartesian3.ZERO, rotateCVOrigin);
    origin.x = center.x;
    
    var plane = Plane.fromPointNormal(origin, normal, rotateCVPlane);
    var verticalCenter = IntersectionTests.rayPlane(ray, plane, rotateCVVerticalCenter);
    
    var projection = camera._projection;
    ellipsoid = projection.ellipsoid;
    
    Cartesian3.fromElements(center.y, center.z, center.x, center);
    var cart = projection.unproject(center, rotateCVCart);
    ellipsoid.cartographicToCartesian(cart, center);
    
    var transform = Transforms.eastNorthUpToFixedFrame(center, ellipsoid, rotateCVTransform);
    
    var verticalTransform;
    if (defined(verticalCenter)) {
    Cartesian3.fromElements(verticalCenter.y, verticalCenter.z, verticalCenter.x, verticalCenter);
    cart = projection.unproject(verticalCenter, rotateCVCart);
    ellipsoid.cartographicToCartesian(cart, verticalCenter);
    
    verticalTransform = Transforms.eastNorthUpToFixedFrame(verticalCenter, ellipsoid, rotateCVVerticalTransform);
    } else {
    verticalTransform = transform;
    }
    
    var oldGlobe = controller._globe;
    var oldEllipsoid = controller._ellipsoid;
    controller._globe = undefined;
    controller._ellipsoid = Ellipsoid.UNIT_SPHERE;
    controller._rotateFactor = 1.0;
    controller._rotateRateRangeAdjustment = 1.0;
    
    var constrainedAxis = Cartesian3.UNIT_Z;
    
    var oldTransform = Matrix4.clone(camera.transform, rotateCVOldTransform);
    camera._setTransform(transform);
    
    var tangent = Cartesian3.cross(Cartesian3.UNIT_Z, Cartesian3.normalize(camera.position, rotateCVCartesian3), rotateCVCartesian3);
    var dot = Cartesian3.dot(camera.right, tangent);
    
    rotate3D(controller, startPosition, movement, constrainedAxis, false, true);
    
    camera._setTransform(verticalTransform);
    if (dot < 0.0) {
    if (movement.startPosition.y > movement.endPosition.y) {
    constrainedAxis = undefined;
    }
    
    var oldConstrainedAxis = camera.constrainedAxis;
    camera.constrainedAxis = undefined;
    
    rotate3D(controller, startPosition, movement, constrainedAxis, true, false);
    
    camera.constrainedAxis = oldConstrainedAxis;
    } else {
    rotate3D(controller, startPosition, movement, constrainedAxis, true, false);
    }
    
    if (defined(camera.constrainedAxis)) {
    var right = Cartesian3.cross(camera.direction, camera.constrainedAxis, tilt3DCartesian3);
    if (!Cartesian3.equalsEpsilon(right, Cartesian3.ZERO, CesiumMath.EPSILON6)) {
    if (Cartesian3.dot(right, camera.right) < 0.0) {
    Cartesian3.negate(right, right);
    }
    
    Cartesian3.cross(right, camera.direction, camera.up);
    Cartesian3.cross(camera.direction, camera.up, camera.right);
    
    Cartesian3.normalize(camera.up, camera.up);
    Cartesian3.normalize(camera.right, camera.right);
    }
    }
    
    camera.setTransform(oldTransform);
    controller._globe = oldGlobe;
    controller._ellipsoid = oldEllipsoid;
    
    var radius = oldEllipsoid.maximumRadius;
    controller._rotateFactor = 1.0 / radius;
    controller._rotateRateRangeAdjustment = radius;
    
    var originalPosition = Cartesian3.clone(camera.positionWC, rotateCVCartesian3);
    adjustHeightForTerrain(controller);
    
    if (!Cartesian3.equals(camera.positionWC, originalPosition)) {
    camera._setTransform(verticalTransform);
    camera.worldToCameraCoordinatesPoint(originalPosition, originalPosition);
    
    var magSqrd = Cartesian3.magnitudeSquared(originalPosition);
    if (Cartesian3.magnitudeSquared(camera.position) > magSqrd) {
    Cartesian3.normalize(camera.position, camera.position);
    Cartesian3.multiplyBy(scalar: camera.position, Math.sqrt(magSqrd), camera.position);
    }
    
    var angle = Cartesian3.angleBetween(originalPosition, camera.position);
    var axis = Cartesian3.cross(originalPosition, camera.position, originalPosition);
    Cartesian3.normalize(axis, axis);
    
    var quaternion = Quaternion.fromAxisAngle(axis, angle, rotateCVQuaternion);
    var rotation = Matrix3.fromQuaternion(quaternion, rotateCVMatrix);
    Matrix3.multiplyByVector(rotation, camera.direction, camera.direction);
    Matrix3.multiplyByVector(rotation, camera.up, camera.up);
    Cartesian3.cross(camera.direction, camera.up, camera.right);
    Cartesian3.cross(camera.right, camera.direction, camera.up);
    
    camera._setTransform(oldTransform);
    }
    }
    
    var zoomCVWindowPos = new Cartesian2();
    var zoomCVWindowRay = new Ray();
    var zoomCVIntersection = new Cartesian3();
    
    function zoomCV(controller, startPosition, movement) {
    if (defined(movement.distance)) {
    movement = movement.distance;
    }
    
    var scene = controller._scene;
    var camera = scene.camera;
    var canvas = scene.canvas;
    
    var windowPosition = zoomCVWindowPos;
    windowPosition.x = canvas.clientWidth / 2;
    windowPosition.y = canvas.clientHeight / 2;
    var ray = camera.getPickRay(windowPosition, zoomCVWindowRay);
    
    var intersection;
    if (camera.position.z < controller.minimumPickingTerrainHeight) {
    intersection = pickGlobe(controller, windowPosition, zoomCVIntersection);
    }
    
    var distance;
    if (defined(intersection)) {
    distance = Cartesian3.distance(ray.origin, intersection);
    } else {
    var normal = Cartesian3.UNIT_X;
    var position = ray.origin;
    var direction = ray.direction;
    distance = -Cartesian3.dot(normal, position) / Cartesian3.dot(normal, direction);
    }
    
    handleZoom(controller, startPosition, movement, controller._zoomFactor, distance);
    }
    */
    func updateCV() {
    /*var scene = controller._scene;
    var camera = scene.camera;
    
    if (!Matrix4.equals(Matrix4.IDENTITY, camera.transform)) {
    reactToInput(controller, controller.enableRotate, controller.rotateEventTypes, rotate3D, controller.inertiaSpin, '_lastInertiaSpinMovement');
    reactToInput(controller, controller.enableZoom, controller.zoomEventTypes, zoom3D, controller.inertiaZoom, '_lastInertiaZoomMovement');
    } else {
    var tweens = controller._tweens;
    
    if (controller._aggregator.anyButtonDown) {
    tweens.removeAll();
    }
    
    reactToInput(controller, controller.enableTilt, controller.tiltEventTypes, rotateCV, controller.inertiaSpin, '_lastInertiaTiltMovement');
    reactToInput(controller, controller.enableTranslate, controller.translateEventTypes, translateCV, controller.inertiaTranslate, '_lastInertiaTranslateMovement');
    reactToInput(controller, controller.enableZoom, controller.zoomEventTypes, zoomCV, controller.inertiaZoom, '_lastInertiaZoomMovement');
    reactToInput(controller, controller.enableLook, controller.lookEventTypes, look3D);
    
    if (!controller._aggregator.anyButtonDown &&
    (!defined(controller._lastInertiaZoomMovement) || !controller._lastInertiaZoomMovement.active) &&
    (!defined(controller._lastInertiaTranslateMovement) || !controller._lastInertiaTranslateMovement.active) &&
    !tweens.contains(controller._tween)) {
    var tween = camera.createCorrectPositionTween(controller.bounceAnimationTime);
    if (defined(tween)) {
    controller._tween = tweens.add(tween);
    }
    }
    
    tweens.update();
    }*/
    }
    /*
    var scratchStrafeRay = new Ray();
    var scratchStrafePlane = new Plane(Cartesian3.ZERO, 0.0);
    var scratchStrafeIntersection = new Cartesian3();
    var scratchStrafeDirection = new Cartesian3();
    */
    func strafe (_ startPosition: Cartesian2, movement: MouseMovement) {
        let camera = _scene.camera
        
        guard let mouseStartPosition = pickGlobe(movement.startPosition) else {
            return
        }
        
        let mousePosition = movement.endPosition
        let ray = camera.getPickRay(mousePosition)
        
        var direction = camera.direction
        if _scene.mode == .columbusView {
            direction = Cartesian3(x: direction.z, y: direction.x, z: direction.y)
        }
        
        let plane = Plane(fromPoint: mouseStartPosition, normal: direction)
        guard let intersection = IntersectionTests.rayPlane(ray, plane: plane) else {
            return
        }
        
        direction = mouseStartPosition.subtract(intersection)
        if _scene.mode == SceneMode.columbusView {
            direction = Cartesian3(x: direction.y, y: direction.z, z: direction.x)
        }
        camera.position = camera.position.add(direction)
    }

    func spin3D(_ startPosition: Cartesian2, movement: MouseMovement) {
        
        let camera = _scene.camera
        
        if camera.transform != Matrix4.identity {
            rotate3D(startPosition, movement: movement)
            return
        }
        var magnitude: Double = 0.0
        
        let up = _ellipsoid.geodeticSurfaceNormal(camera.position)
        
        guard let height = _ellipsoid.cartesianToCartographic(camera.positionWC)?.height else {
            return
        }
        
        var mousePos: Cartesian3? = nil
        var tangentPick = false
        if _globe != nil && height < minimumPickingTerrainHeight {
            mousePos = pickGlobe(movement.startPosition)
            if let mousePos = mousePos {
                let ray = camera.getPickRay(movement.startPosition)
                let normal = _ellipsoid.geodeticSurfaceNormal(mousePos)
                tangentPick = abs(ray.direction.dot(normal)) < 0.05
                
                if tangentPick && !_looking {
                    _rotating = false
                    _strafing = true
                }
            }
        }
        
        if startPosition == _rotateMousePosition {
            if _looking {
                look3D(startPosition, movement: movement, rotationAxis: up)
            } else if _rotating {
                rotate3D(startPosition, movement: movement)
            } else if _strafing {
                _strafeStartPosition = mousePos!
                strafe(startPosition, movement: movement)
            } else {
                magnitude = _rotateStartPosition.magnitude
                let ellipsoid = Ellipsoid(x: magnitude, y: magnitude, z: magnitude)
                pan3D(startPosition, movement: movement, ellipsoid: ellipsoid)
            }
            return
        } else {
            _looking = false
            _rotating = false
            _strafing = false
        }
        
        if _globe != nil && height < minimumPickingTerrainHeight {
            if mousePos != nil {
                if camera.position.magnitude < mousePos!.magnitude {
                    _strafeStartPosition = mousePos!
                    _strafing = true
                    strafe(startPosition, movement: movement)
                } else {
                    magnitude = mousePos!.magnitude
                    let radii = Cartesian3(x: magnitude, y: magnitude, z: magnitude)
                    let ellipsoid = Ellipsoid(radii: radii)
                    pan3D(startPosition, movement: movement, ellipsoid: ellipsoid)
                    _rotateStartPosition = mousePos!
                }
            } else {
                _looking = true
                look3D(startPosition, movement: movement, rotationAxis: up)
            }
        } else if let spin3DPick = camera.pickEllipsoid(movement.startPosition, ellipsoid: _ellipsoid) {
            pan3D(startPosition, movement: movement, ellipsoid: _ellipsoid)
            _rotateStartPosition = spin3DPick
        } else if height > minimumTrackBallHeight {
            _rotating = true
            rotate3D(startPosition, movement: movement)
        } else {
            _looking = true
            look3D(startPosition, movement: movement, rotationAxis: up)
        }
        _rotateMousePosition = startPosition
    }
    
    func rotate3D(_ startPosition: Cartesian2, movement: MouseMovement, constrainedAxis: Cartesian3? = nil, rotateOnlyVertical: Bool = false, rotateOnlyHorizontal: Bool = false) {
    
        let camera = _scene.camera
    
        let oldAxis = camera.constrainedAxis
        if constrainedAxis != nil {
            camera.constrainedAxis = constrainedAxis
        }
    
        let rho = camera.position.magnitude
        var rotateRate = _rotateFactor * (rho - _rotateRateRangeAdjustment)
    
        if rotateRate > _maximumRotateRate {
            rotateRate = _maximumRotateRate
        }
    
        if rotateRate < _minimumRotateRate {
            rotateRate = _minimumRotateRate
        }
        var phiWindowRatio = (movement.startPosition.x - movement.endPosition.x) / Double(_scene.context.width)
        var thetaWindowRatio = (movement.startPosition.y - movement.endPosition.y) / Double(_scene.context.width)
        phiWindowRatio = min(phiWindowRatio, maximumMovementRatio)
        thetaWindowRatio = min(thetaWindowRatio, maximumMovementRatio)
        
        let deltaPhi = rotateRate * phiWindowRatio * .pi * 2.0
        let deltaTheta = rotateRate * thetaWindowRatio * .pi
        
        if !rotateOnlyVertical {
            camera.rotateRight(deltaPhi)
        }
        
        if !rotateOnlyHorizontal {
            camera.rotateUp(deltaTheta)
        }
        
        camera.constrainedAxis = oldAxis
    }

    func pan3D(_ startPosition: Cartesian2, movement: MouseMovement, ellipsoid: Ellipsoid) {
        
        let camera = _scene.camera
        
        let startMousePosition = movement.startPosition
        let endMousePosition = movement.endPosition
        
        var p0: Cartesian3! = camera.pickEllipsoid(startMousePosition, ellipsoid: ellipsoid)
        var p1: Cartesian3! = camera.pickEllipsoid(endMousePosition, ellipsoid: ellipsoid)
        
        if p0 == nil || p1 == nil {
            _rotating = true
            rotate3D(startPosition, movement: movement)
            return
        }
        
        let c0 = camera.worldToCameraCoordinates(Cartesian4(x: p0.x, y: p0.y, z: p0.z, w: 1.0)) //var pan3DP0 = Cartesian4.clone(Cartesian4.UNIT_W);
        let c1 = camera.worldToCameraCoordinates(Cartesian4(x: p1.x, y: p1.y, z: p1.z, w: 1.0)) //var pan3DP1 = Cartesian4.clone(Cartesian4.UNIT_W);
        p0 = Cartesian3(cartesian4: c0)
        p1 = Cartesian3(cartesian4: c1)

        if camera.constrainedAxis == nil {
            p0 = p0.normalize()
            p1 = p1.normalize()
            let dot = p0.dot(p1)
            let axis = p0.cross(p1)
            
            if dot < 1.0 && !axis.equalsEpsilon(Cartesian3.zero, relativeEpsilon: Math.Epsilon14) { // dot is in [0, 1]
                let angle = acos(dot)
                camera.rotate(axis, angle: angle)
            }
        } else {
            let basis0 = camera.constrainedAxis!
            let basis1 = basis0.mostOrthogonalAxis().cross(basis0).normalize()
            let basis2 = basis0.cross(basis1)
            
            let startRho = p0.magnitude
            let startDot = basis0.dot(p0)
            let startTheta = acos(startDot / startRho)
            let startRej = p0.subtract(basis0.multiplyBy(scalar: startDot)).normalize()
            
            let endRho = p1.magnitude
            let endDot = basis0.dot(p1)
            let endTheta = acos(endDot / endRho)
            let endRej = p1.subtract(basis0.multiplyBy(scalar: endDot)).normalize()
            
            var startPhi = acos(startRej.dot(basis1))
            if startRej.dot(basis2) < 0 {
                startPhi = Math.TwoPi - startPhi
            }
            
            var endPhi = acos(endRej.dot(basis1))
            if endRej.dot(basis2) < 0 {
                endPhi = Math.TwoPi - endPhi
            }
            
            let deltaPhi = startPhi - endPhi
            
            let east: Cartesian3
            if basis0.equalsEpsilon(camera.position, relativeEpsilon: Math.Epsilon2) {
                east = camera.right
            } else {
                east = basis0.cross(camera.position)
            }
            
            let planeNormal = basis0.cross(east)
            let side0 = planeNormal.dot(p0.subtract(basis0))
            let side1 = planeNormal.dot(p1.subtract(basis0))
            
            let deltaTheta: Double
            if side0 > 0 && side1 > 0 {
                deltaTheta = endTheta - startTheta
            } else if side0 > 0 && side1 <= 0 {
                if camera.position.dot(basis0) > 0 {
                    deltaTheta = -startTheta - endTheta
                } else {
                    deltaTheta = startTheta + endTheta
                }
            } else {
                deltaTheta = startTheta - endTheta;
            }
            
            camera.rotateRight(deltaPhi)
            camera.rotateUp(deltaTheta)
        }
    }
    
    func zoom3D(_ startPosition: Cartesian2, movement: MouseMovement) {
        
        //FIXME: movement.distance
        /*if (defined(movement.distance)) {
            movement = movement.distance;
        }*/
        
        let camera = _scene.camera
        
        let windowPosition = Cartesian2(
            x: Double(_scene.drawableWidth) / 2.0,
            y: Double(_scene.drawableHeight) / 2.0
        )
        let ray = _scene.camera.getPickRay(windowPosition)
        
        guard let height = _ellipsoid.cartesianToCartographic(camera.position)?.height else {
            return
        }
        var intersection: Cartesian3? = nil
        if _globe != nil && height < minimumPickingTerrainHeight {
            intersection = pickGlobe(windowPosition)
        }
        
        let distance: Double
        if intersection != nil {
            distance = ray.origin.distance(intersection!)
        } else {
            distance = height
        }
        let unitPosition = camera.position.normalize()
        handleZoom(startPosition, movement: movement, zoomFactor: _zoomFactor, distanceMeasure: distance, unitPositionDotDirection: unitPosition.dot(camera.direction))
    }
    /*
    var tilt3DWindowPos = new Cartesian2();
    var tilt3DRay = new Ray();
    var tilt3DCenter = new Cartesian3();
    var tilt3DVerticalCenter = new Cartesian3();
    var tilt3DTransform = new Matrix4();
    var tilt3DVerticalTransform = new Matrix4();
    var tilt3DCartesian3 = new Cartesian3();
    var tilt3DOldTransform = new Matrix4();
    var tilt3DQuaternion = new Quaternion();
    var tilt3DMatrix = new Matrix3();
    var tilt3DCart = new Cartographic();
    var tilt3DLookUp = new Cartesian3();
    */
    func tilt3D(_ startPosition: Cartesian2, movement: MouseMovement) {

        let camera = _scene.camera
    
        if camera.transform != Matrix4.identity {
            return
        }
        
        /*if (defined(movement.angleAndHeight)) {
            movement = movement.angleAndHeight;
        }*/
        
        if startPosition != _tiltCenterMousePosition {
            _tiltOnEllipsoid = false
            _looking = false
        }
        
        if _looking {
            let up = _ellipsoid.geodeticSurfaceNormal(camera.position)
            look3D(startPosition, movement: movement, rotationAxis: up)
            return
        }
        
        guard let cartographic = _ellipsoid.cartesianToCartographic(camera.position) else {
            return
        }
        
        if _tiltOnEllipsoid || cartographic.height > minimumCollisionTerrainHeight {
            _tiltOnEllipsoid = true
            tilt3DOnEllipsoid(startPosition, movement: movement)
        } else {
            tilt3DOnTerrain(startPosition, movement: movement)
        }
    }
    
    func tilt3DOnEllipsoid(_ startPosition: Cartesian2, movement: MouseMovement) {
        
        /*let camera = _scene.camera
        let minHeight = minimumZoomDistance * 0.25
        let height = _ellipsoid.cartesianToCartographic(camera.positionWC)!.height
        if height - minHeight - 1.0 < Math.Epsilon3 &&
            movement.endPosition.y - movement.startPosition.y < 0 {
            return
        }
        
        let windowPosition = Cartesian2(x: Double(_scene.drawableWidth) / 2.0, y: Double(_scene.drawableHeight) / 2.0)
        let ray = camera.getPickRay(windowPosition)
        
        let center: Cartesian3
        if let intersection = IntersectionTests.rayEllipsoid(ray, ellipsoid: _ellipsoid) {
            center = ray.getPoint(intersection.start)
        } else if height > minimumTrackBallHeight {
            guard let grazingAltitudeLocation = IntersectionTests.grazingAltitudeLocation(ray, _ellipsoid) else {
                return
            }
            let grazingAltitudeCart = ellipsoid.cartesianToCartographic(grazingAltitudeLocation)
            grazingAltitudeCart.height = 0.0
            center = ellipsoid.cartographicToCartesian(grazingAltitudeCart)
        } else {
            controller._looking = true;
            var up = controller._ellipsoid.geodeticSurfaceNormal(camera.position, tilt3DLookUp);
            look3D(controller, startPosition, movement, up);
            Cartesian2.clone(startPosition, controller._tiltCenterMousePosition);
            return;
        }
        
        var transform = Transforms.eastNorthUpToFixedFrame(center, ellipsoid, tilt3DTransform);
        
        var oldGlobe = controller._globe;
        var oldEllipsoid = controller._ellipsoid;
        controller._globe = undefined;
        controller._ellipsoid = Ellipsoid.UNIT_SPHERE;
        controller._rotateFactor = 1.0;
        controller._rotateRateRangeAdjustment = 1.0;
        
        var oldTransform = Matrix4.clone(camera.transform, tilt3DOldTransform);
        camera._setTransform(transform);
        
        rotate3D(controller, startPosition, movement, Cartesian3.UNIT_Z);
        
        camera._setTransform(oldTransform);
        controller._globe = oldGlobe;
        controller._ellipsoid = oldEllipsoid;
        
        var radius = oldEllipsoid.maximumRadius;
        controller._rotateFactor = 1.0 / radius;
        controller._rotateRateRangeAdjustment = radius;*/
    }
    
    func tilt3DOnTerrain(_ startPosition: Cartesian2, movement: MouseMovement) {
        /*var ellipsoid = controller._ellipsoid;
        var scene = controller._scene;
        var camera = scene.camera;
        
        var center;
        var ray;
        var intersection;
        
        if (Cartesian2.equals(startPosition, controller._tiltCenterMousePosition)) {
            center = Cartesian3.clone(controller._tiltCenter, tilt3DCenter);
        } else {
            center = pickGlobe(controller, startPosition, tilt3DCenter);
            
            if (!defined(center)) {
                ray = camera.getPickRay(startPosition, tilt3DRay);
                intersection = IntersectionTests.rayEllipsoid(ray, ellipsoid);
                if (!defined(intersection)) {
                    var cartographic = ellipsoid.cartesianToCartographic(camera.position, tilt3DCart);
                    if (cartographic.height <= controller.minimumTrackBallHeight) {
                        controller._looking = true;
                        var up = controller._ellipsoid.geodeticSurfaceNormal(camera.position, tilt3DLookUp);
                        look3D(controller, startPosition, movement, up);
                        Cartesian2.clone(startPosition, controller._tiltCenterMousePosition);
                    }
                    return;
                }
                center = Ray.getPoint(ray, intersection.start, tilt3DCenter);
            }
            
            Cartesian2.clone(startPosition, controller._tiltCenterMousePosition);
            Cartesian3.clone(center, controller._tiltCenter);
        }
        
        var canvas = scene.canvas;
        
        var windowPosition = tilt3DWindowPos;
        windowPosition.x = canvas.clientWidth / 2;
        windowPosition.y = controller._tiltCenterMousePosition.y;
        ray = camera.getPickRay(windowPosition, tilt3DRay);
        
        var mag = Cartesian3.magnitude(center);
        var radii = Cartesian3.fromElements(mag, mag, mag, scratchRadii);
        var newEllipsoid = Ellipsoid.fromCartesian3(radii, scratchEllipsoid);
        
        intersection = IntersectionTests.rayEllipsoid(ray, newEllipsoid);
        if (!defined(intersection)) {
            return;
        }
        
        var t = Cartesian3.magnitude(ray.origin) > mag ? intersection.start : intersection.stop;
        var verticalCenter = Ray.getPoint(ray, t, tilt3DVerticalCenter);
        
        var transform = Transforms.eastNorthUpToFixedFrame(center, ellipsoid, tilt3DTransform);
        var verticalTransform = Transforms.eastNorthUpToFixedFrame(verticalCenter, newEllipsoid, tilt3DVerticalTransform);
        
        var oldGlobe = controller._globe;
        var oldEllipsoid = controller._ellipsoid;
        controller._globe = undefined;
        controller._ellipsoid = Ellipsoid.UNIT_SPHERE;
        controller._rotateFactor = 1.0;
        controller._rotateRateRangeAdjustment = 1.0;
        
        var constrainedAxis = Cartesian3.UNIT_Z;
        
        var oldTransform = Matrix4.clone(camera.transform, tilt3DOldTransform);
        camera._setTransform(transform);
        
        var tangent = Cartesian3.cross(verticalCenter, camera.positionWC, tilt3DCartesian3);
        var dot = Cartesian3.dot(camera.rightWC, tangent);
        
        rotate3D(controller, startPosition, movement, constrainedAxis, false, true);
        
        camera._setTransform(verticalTransform);
        
        if (dot < 0.0) {
            if (movement.startPosition.y > movement.endPosition.y) {
                constrainedAxis = undefined;
            }
            
            var oldConstrainedAxis = camera.constrainedAxis;
            camera.constrainedAxis = undefined;
            
            rotate3D(controller, startPosition, movement, constrainedAxis, true, false);
            
            camera.constrainedAxis = oldConstrainedAxis;
        } else {
            rotate3D(controller, startPosition, movement, constrainedAxis, true, false);
        }
        
        if (defined(camera.constrainedAxis)) {
            var right = Cartesian3.cross(camera.direction, camera.constrainedAxis, tilt3DCartesian3);
            if (!Cartesian3.equalsEpsilon(right, Cartesian3.ZERO, CesiumMath.EPSILON6)) {
                if (Cartesian3.dot(right, camera.right) < 0.0) {
                    Cartesian3.negate(right, right);
                }
                
                Cartesian3.cross(right, camera.direction, camera.up);
                Cartesian3.cross(camera.direction, camera.up, camera.right);
                
                Cartesian3.normalize(camera.up, camera.up);
                Cartesian3.normalize(camera.right, camera.right);
            }
        }
        
        camera._setTransform(oldTransform);
        controller._globe = oldGlobe;
        controller._ellipsoid = oldEllipsoid;
        
        var radius = oldEllipsoid.maximumRadius;
        controller._rotateFactor = 1.0 / radius;
        controller._rotateRateRangeAdjustment = radius;
        
        var originalPosition = Cartesian3.clone(camera.positionWC, tilt3DCartesian3);
        adjustHeightForTerrain(controller);
        
        if (!Cartesian3.equals(camera.positionWC, originalPosition)) {
            camera._setTransform(verticalTransform);
            camera.worldToCameraCoordinatesPoint(originalPosition, originalPosition);
            
            var magSqrd = Cartesian3.magnitudeSquared(originalPosition);
            if (Cartesian3.magnitudeSquared(camera.position) > magSqrd) {
                Cartesian3.normalize(camera.position, camera.position);
                Cartesian3.multiplyBy(scalar: camera.position, Math.sqrt(magSqrd), camera.position);
            }
            
            var angle = Cartesian3.angleBetween(originalPosition, camera.position);
            var axis = Cartesian3.cross(originalPosition, camera.position, originalPosition);
            Cartesian3.normalize(axis, axis);
            
            var quaternion = Quaternion.fromAxisAngle(axis, angle, tilt3DQuaternion);
            var rotation = Matrix3.fromQuaternion(quaternion, tilt3DMatrix);
            Matrix3.multiplyByVector(rotation, camera.direction, camera.direction);
            Matrix3.multiplyByVector(rotation, camera.up, camera.up);
            Cartesian3.cross(camera.direction, camera.up, camera.right);
            Cartesian3.cross(camera.right, camera.direction, camera.up);
            
            camera._setTransform(oldTransform);
        }*/
    }
    
    /*
    var look3DStartPos = new Cartesian2();
    var look3DEndPos = new Cartesian2();
    var look3DStartRay = new Ray();
    var look3DEndRay = new Ray();
    var look3DNegativeRot = new Cartesian3();
    var look3DTan = new Cartesian3();
    */
    func look3D(_ startPosition: Cartesian2, movement: MouseMovement, rotationAxis: Cartesian3) {
    /*var scene = controller._scene;
    var camera = scene.camera;
    
    var startPos = look3DStartPos;
    startPos.x = movement.startPosition.x;
    startPos.y = 0.0;
    var endPos = look3DEndPos;
    endPos.x = movement.endPosition.x;
    endPos.y = 0.0;
    var start = camera.getPickRay(startPos, look3DStartRay).direction;
    var end = camera.getPickRay(endPos, look3DEndRay).direction;
    
    var angle = 0.0;
    var dot = Cartesian3.dot(start, end);
    if (dot < 1.0) { // dot is in [0, 1]
    angle = Math.acos(dot);
    }
    angle = (movement.startPosition.x > movement.endPosition.x) ? -angle : angle;
    
    var horizontalRotationAxis = controller._horizontalRotationAxis;
    if (defined(rotationAxis)) {
    camera.look(rotationAxis, -angle);
    } else if (defined(horizontalRotationAxis)) {
    camera.look(horizontalRotationAxis, -angle);
    } else {
    camera.lookLeft(angle);
    }
    
    startPos.x = 0.0;
    startPos.y = movement.startPosition.y;
    endPos.x = 0.0;
    endPos.y = movement.endPosition.y;
    start = camera.getPickRay(startPos, look3DStartRay).direction;
    end = camera.getPickRay(endPos, look3DEndRay).direction;
    
    angle = 0.0;
    dot = Cartesian3.dot(start, end);
    if (dot < 1.0) { // dot is in [0, 1]
    angle = Math.acos(dot);
    }
    angle = (movement.startPosition.y > movement.endPosition.y) ? -angle : angle;
    
    rotationAxis = defaultValue(rotationAxis, horizontalRotationAxis);
    if (defined(rotationAxis)) {
    var direction = camera.direction;
    var negativeRotationAxis = Cartesian3.negate(rotationAxis, look3DNegativeRot);
    var northParallel = Cartesian3.equalsEpsilon(direction, rotationAxis, CesiumMath.EPSILON2);
    var southParallel = Cartesian3.equalsEpsilon(direction, negativeRotationAxis, CesiumMath.EPSILON2);
    if ((!northParallel && !southParallel)) {
    dot = Cartesian3.dot(direction, rotationAxis);
    var angleToAxis = CesiumMath.acosClamped(dot);
    if (angle > 0 && angle > angleToAxis) {
    angle = angleToAxis - CesiumMath.EPSILON4;
    }
    
    dot = Cartesian3.dot(direction, negativeRotationAxis);
    angleToAxis = CesiumMath.acosClamped(dot);
    if (angle < 0 && -angle > angleToAxis) {
    angle = -angleToAxis + CesiumMath.EPSILON4;
    }
    
    var tangent = Cartesian3.cross(rotationAxis, direction, look3DTan);
    camera.look(tangent, angle);
    } else if ((northParallel && angle < 0) || (southParallel && angle > 0)) {
    camera.look(camera.right, -angle);
    }
    } else {
    camera.lookUp(angle);
    }*/
    }

    func update3D() {
        reactToInput(enableRotate, eventTypes: rotateEventTypes, action: spin3D, inertiaConstant: inertiaSpin, inertiaStateName: "_lastInertiaSpinMovement")
        reactToInput(enableZoom, eventTypes: zoomEventTypes, action: zoom3D, inertiaConstant: inertiaZoom, inertiaStateName: "_lastInertiaZoomMovement")
        reactToInput(enableTilt, eventTypes: tiltEventTypes, action: tilt3D, inertiaConstant: inertiaSpin, inertiaStateName: "_lastInertiaTiltMovement")
        //reactToInput(enableLook, lookEventTypes, look3D)
    }
    
    func adjustHeightForTerrain() {
        if !enableCollisionDetection {
            return
        }
        
        let mode = _scene.mode
        
        if _globe == nil || mode == .scene2D || mode == .morphing {
            return
        }
        
        let camera = _scene.camera
        guard let ellipsoid = _ellipsoid else {
            return
        }
        let projection = _scene.mapProjection
        
        var transform: Matrix4? = nil
        var mag: Double = 0.0
        if (camera.transform != Matrix4.identity) {
            transform = camera.transform
            mag = camera.position.magnitude
            camera._setTransform(Matrix4.identity)
        }
        
        var cartographic: Cartographic
        if mode == SceneMode.scene3D {
            cartographic = ellipsoid.cartesianToCartographic(camera.position)!
        } else {
            cartographic = projection.unproject(camera.position)
        }
        
        var heightUpdated = false
        if cartographic.height < minimumCollisionTerrainHeight {
            if let height = _globe!.getHeight(cartographic) {
                var height = height
                height += minimumZoomDistance
                if cartographic.height < height {
                    cartographic.height = height
                    if mode == .scene3D {
                        camera.position = ellipsoid.cartographicToCartesian(cartographic)
                    } else {
                        camera.position = projection.project(cartographic)
                    }
                    heightUpdated = true
                }
            }
        }
        
        if transform != nil {
            camera._setTransform(transform!)
            
            if (heightUpdated) {
                camera.position = camera.position.normalize()
                camera.direction = camera.position.negate()
                camera.position = camera.position.multiplyBy(scalar: max(mag, minimumZoomDistance))
                camera.direction = camera.direction.normalize()
                camera.right = camera.direction.cross(camera.up)
                camera.up = camera.right.cross(camera.direction)
            }
        }
    }

    /**
    * @private
    */
    func update () {
        if _scene.camera.transform != Matrix4.identity {
            _globe = nil
            _ellipsoid = Ellipsoid.unitSphere()
        } else {
            _globe = _scene.globe
            _ellipsoid = (_globe != nil ? _globe!.ellipsoid : _scene.mapProjection.ellipsoid)
        }
        
        let radius = _ellipsoid.maximumRadius
        _rotateFactor = 1.0 / radius
        _rotateRateRangeAdjustment = radius
        
        let mode = _scene.mode
        if mode == .scene2D {
            update2D()
        } else if mode == .columbusView {
            _horizontalRotationAxis = Cartesian3.unitZ
            updateCV()
        } else if mode == .scene3D {
            _horizontalRotationAxis = nil
            update3D()
        }
        
        adjustHeightForTerrain()
        
        _aggregator.reset()
    }
    /*
    /**
    * Returns true if this object was destroyed; otherwise, false.
    * <br /><br />
    * If this object was destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
    *
    * @returns {Boolean} <code>true</code> if this object was destroyed; otherwise, <code>false</code>.
    *
    * @see ScreenSpaceCameraController#destroy
    */
    ScreenSpaceCameraController.prototype.isDestroyed = function() {
    return false;
    };
    
    /**
    * Removes mouse listeners held by this object.
    * <br /><br />
    * Once an object is destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
    * assign the return value (<code>undefined</code>) to the object as done in the example.
    *
    * @returns {undefined}
    *
    * @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
    *
    * @see ScreenSpaceCameraController#isDestroyed
    *
    * @example
    * controller = controller && controller.destroy();
    */
    ScreenSpaceCameraController.prototype.destroy = function() {
    this._tweens.removeAll();
    this._pinchHandler = this._pinchHandler && this._pinchHandler.destroy();
    return destroyObject(this);
    };
    
    return ScreenSpaceCameraController;
    });
*/
}
