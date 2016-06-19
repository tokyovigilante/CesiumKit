//
//  TouchEventAggregator.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 4/04/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import UIKit
import MetalKit

protocol TouchEvent {}

struct PanEvent: TouchEvent {
    
    let tapCount: Int
    let startPosition: Cartesian2
    let endPosition: Cartesian2
    
    init (tapCount: Int, startPosition: Cartesian2, endPosition: Cartesian2) {
        self.tapCount = tapCount
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
}

protocol EventAggregator {
    
    func reset ()
}

class TouchEventAggregator: EventAggregator {
    func reset() {
        
    }
}

class TouchEventHandler: NSObject, UIGestureRecognizerDelegate {
    
    /**
    * A parameter in the range <code>[0, 1)</code> used to limit the range
    * of various user inputs to a percentage of the window width/height per animation frame.
    * This helps keep the camera under control in low-frame-rate situations.
    * @type {Number}
    * @default 0.1
    */
    var maximumMovementRatio = 0.1
    
    /**
    * The minimum height the camera must be before picking the terrain instead of the ellipsoid.
    * @type {Number}
    * @default 150000.0
    */
    var minimumPickingTerrainHeight = 150000.0
    
    /**
    * The minimum magnitude, in meters, of the camera position when zooming. Defaults to 20.0.
    * @type {Number}
    * @default 20.0
    */
    var minimumZoomDistance = 20.0
    
    /**
    * The maximum magnitude, in meters, of the camera position when zooming. Defaults to positive infinity.
    * @type {Number}
    * @default {@link Number.POSITIVE_INFINITY}
    */
    var maximumZoomDistance = Double.infinity
    
    //private var _events = [TouchEvent]()
    
    //private var _panStartPosition: Cartesian2? = nil
    
    private var _panRecognizer: UIPanGestureRecognizer!
    private var _pinchRecognizer: UIPinchGestureRecognizer!
    
    private var _scene: Scene!
    private var _view: MTKView!
    
    // Constants, Make any of these public?*/
    private var _zoomFactor = 5.0
    private var _rotateFactor = 0.0
    private var _rotateRateRangeAdjustment = 0.0
    private var _maximumRotateRate = 1.77
    private var _minimumRotateRate = 1.0 / 5000.0
    /*this._translateFactor = 1.0;*/
    private var _minimumZoomRate = 20.0
    private var _maximumZoomRate = 5906376272000.0  // distance from the Sun to Pluto in meters.
    
    init (scene: Scene, view: MTKView) {
        _scene = scene
        _view = view
        super.init()
        addRecognizers()
    }
    
    func addRecognizers () {
        _view.isUserInteractionEnabled = true
        _view.isMultipleTouchEnabled = true
        
        //var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        _panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TouchEventHandler.handlePanGesture(_:)))
        _panRecognizer.delegate = self
        _view.addGestureRecognizer(_panRecognizer)
        
        _pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TouchEventHandler.handlePinchGesture(_:)))
        _pinchRecognizer.delegate = self
        _view.addGestureRecognizer(_pinchRecognizer)
    }
    
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: _view)
        let offset = recognizer.translation(in: _view)
        
        var event: TouchEvent? = nil
        switch recognizer.state {
        //case .Began:
            //println("panstart, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
            /*event = PanStartEvent(
            tapCount: recognizer.numberOfTouches(),
            startPosition: [Cartesian2(x: Double(location.x), y: Double(location.y))])*/
        case .changed:
            //println("panchanged, x: \(location.x) - \(offset.x), y: \(location.y) - \(offset.y), fingers: \(recognizer.numberOfTouches())")
            
            var movement = MouseMovement()
            movement.startPosition = Cartesian2(x: Double((location.x - offset.x) * _view.contentScaleFactor), y: Double((location.y - offset.y) * _view.contentScaleFactor))
            movement.endPosition = Cartesian2(x: Double(location.x * _view.contentScaleFactor), y: Double(location.y * _view.contentScaleFactor))
            //let view = _view as! MetalView
            //dispatch_async(view.renderQueue, {
            self._scene.screenSpaceCameraController.spin3D(movement.startPosition, movement: movement)
            //})
            
            /*event = PanMoveEvent(
            tapCount: recognizer.numberOfTouches(),
            startPosition: Cartesian2(x: Double(location.x), y: Double(location.y)),
            endPosition: Cartesian2(x: Double(location.x + offset.x), y: Double(location.y + offset.y)))*/
        //case .Ended:
            //println("panended, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
            // do velocity here
            //globe?.eventHandler.handlePanEnd(Cartesian2(x: Double(location.x), y: Double(location.y)))
            //let event = PanEndEvent(tapCount: recognizer.numberOfTouches())
        //case .Cancelled:
            //println("pancancelled, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
        default:
            return
        }
        recognizer.setTranslation(CGPoint.zero, in: _view)
        /*if let touchHandler = globe?.eventAggregator as? TouchEventAggregator {
        touchHander.addEvent(event)
        }*/
    }
    
    func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        let fingerOne = recognizer.location(ofTouch: 0, in: _view)
        /*let fingerTwo = recognizer.locationOfTouch(1, inView: view)
        let diff = Cartesian2(x: Double(fingerOne.x), y: Double(fingerOne.x)).distance(Cartesian2(x: Double(fingerTwo.x), y: Double(fingerTwo.x)))*/
        switch recognizer.state {
        //case .Began:
            //println("pinchstart, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
            //globe?.eventHandler.handlePanStart(Cartesian2(x: Double(location.x), y: Double(location.y)))
        case .changed:
            //println("pinchchanged, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
            //let view = _view as! MetalView
            let scale = Double(recognizer.scale)
            recognizer.scale = 1
            //dispatch_async(view.renderQueue, {
                self.zoomToPosition(Cartesian2(x: Double(fingerOne.x), y: Double(fingerOne.y)), scale: scale)
            //})
            //globe?.eventHandler.handlePanMove(Cartesian2(x: Double(location.x), y: Double(location.y)))
        //case .Ended:
            //println("pinchended, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
            //globe?.eventHandler.handlePanEnd(Cartesian2(x: Double(location.x), y: Double(location.y)))
        //case .Cancelled:
            //println("pinchcancelled, x: \(location.x), y: \(location.y), fingers: \(recognizer.numberOfTouches())")
        default:
            return
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == _panRecognizer && otherGestureRecognizer == _pinchRecognizer {
            return true
        }
        return false
    }

    // MARK: Zoom
    
    func zoomToPosition (_ position: Cartesian2, scale: Double) {
        
        let ray = _scene.camera.getPickRay(position)
        
        var intersection: Cartesian3? = nil
        let height = _scene.globe.ellipsoid.cartesianToCartographic(_scene.camera.position)!.height
        if height < minimumPickingTerrainHeight {
            intersection = _scene.globe.pick(ray, scene: _scene)
        }
        
        var distance: Double
        if intersection != nil {
            distance = ray.origin.distance(intersection!)
        } else {
            distance = height
        }
        let newDistance = distance * scale
        let diff = newDistance - distance
        /*let unitPosition = _scene.camera.position.normalize()
        let unitPositionDotDirection = unitPosition.dot(_scene.camera.direction)
        var distanceMeasure = distance
        //handleZoom(startPosition, movement: movement, zoomFactor: _zoomFactor, distanceMeasure: distance, unitPositionDotDirection: unitPosition.dot(_scene.camera.direction))
        var percentage = 1.0
        //if unitPositionDotDirection != nil {
            percentage = Math.clamp(abs(unitPositionDotDirection), min: 0.25, max: 1.0)
        //}
        
        // distanceMeasure should be the height above the ellipsoid.
        // The zoomRate slows as it approaches the surface and stops minimumZoomDistance above it.
        let minHeight = minimumZoomDistance * percentage
        var maxHeight = maximumZoomDistance
        
        let minDistance = distanceMeasure - minHeight
        var zoomRate = _zoomFactor * minDistance
        zoomRate = Math.clamp(zoomRate, min: _minimumZoomRate, max: _maximumZoomRate)
        
        /*let diff = movement.endPosition.y - movement.startPosition.y
        var rangeWindowRatio = diff / Double(_scene.drawableHeight)*/
        //var rangeWindowRatio = //min(scale, maximumMovementRatio)
        distance *= scale
        
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
        }*/
        
        _scene.camera.zoomIn(diff)

    }

    func appendEvent(_ event: TouchEvent) {
        //_events.append(event)
    }
    
    func reset () {
        //_events.removeAll()
    }
    
}
