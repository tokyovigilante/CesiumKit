//
//  CameraEventAggregator.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/03/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation

/**
* Aggregates input events. For example, suppose the following inputs are received between frames:
* left mouse button down, mouse move, mouse move, left mouse button up. These events will be aggregated into
* one event with a start and end position of the mouse.
*
* @alias CameraEventAggregator
* @constructor
*
* @param {Canvas} [element=document] The element to handle events for.
*
* @see ScreenSpaceEventHandler
*/

protocol StartEndPosition {
    var startPosition: Cartesian2 { get set }
    var endPosition: Cartesian2 { get set }
}

struct MouseMovement: StartEndPosition {
    var startPosition = Cartesian2()
    var endPosition = Cartesian2()
    var angleStartPosition = Cartesian2()
    var angleEndPosition = Cartesian2()
    var prevAngle = 0.0
    var valid: Bool = false
}

class CameraEventAggregator {
    
    let eventHandler: ScreenSpaceEventHandler
    
    var _update = [String: Bool]()
    var _movement = [String: MouseMovement]()
    var _lastMovement = [String: MouseMovement]()
    var _isDown = [String: Bool]()
    var _eventStartPosition = [String: Cartesian2]()
    var _pressTime = [String: NSDate]()
    var _releaseTime = [String: NSDate]()
    
    var _buttonsDown = 0
    
    var _currentMousePosition = Cartesian2()
    
    #if (iOS)
    private var _view: UIView!
    #elseif (OSX)
    private var _view: NSView!
    #endif
    
    init (/*view: UIView*/) {
        
        eventHandler = ScreenSpaceEventHandler(/*layer: layer,*/ true)
        // FIXME: eventaggregator view
        //_view = view
        //listenToWheel(this, undefined);
        listenToPinch()
        listenMouseButtonDownUp(CameraEventType.LeftDrag)
        //listenMouseButtonDownUp(this, undefined, CameraEventType.RIGHT_DRAG);
        //listenMouseButtonDownUp(this, undefined, CameraEventType.MIDDLE_DRAG);
        listenMouseMove()
        //listenTouchEvents()
        
        // FIXME: Modifiers disabled
        /*for ( var modifierName in KeyboardEventModifier) {
            if (KeyboardEventModifier.hasOwnProperty(modifierName)) {
                var modifier = KeyboardEventModifier[modifierName];
                if (defined(modifier)) {
                    //listenToWheel(this, undefined);
                    //listenToPinch(this, undefined, canvas);
                    listenMouseButtonDownUp(nil, CameraEventType.LeftDrag)
                    //listenMouseButtonDownUp(this, undefined, CameraEventType.RIGHT_DRAG);
                    //listenMouseButtonDownUp(this, undefined, CameraEventType.MIDDLE_DRAG);
                    listenMouseMove(nil)
                }
            }
        }*/
        
        //listenTouchPanStart()
    }
    
    func getKey(type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> String {
        return "\(type.rawValue)" + (modifier != nil ? "\(modifier!.rawValue)" : "")
    }
    /*
    function clonePinchMovement(pinchMovement, result) {
    Cartesian2.clone(pinchMovement.distance.startPosition, result.distance.startPosition);
    Cartesian2.clone(pinchMovement.distance.endPosition, result.distance.endPosition);
    
    Cartesian2.clone(pinchMovement.angleAndHeight.startPosition, result.angleAndHeight.startPosition);
    Cartesian2.clone(pinchMovement.angleAndHeight.endPosition, result.angleAndHeight.endPosition);
    }
    */
    func listenToPinch(modifier: KeyboardEventModifier? = nil) {
        let key = getKey(.Pinch, modifier: modifier)
        
        _update[key] = true
        _isDown[key] = false
        _eventStartPosition[key] = Cartesian2()
        
        var movement = _movement[key]
        if movement == nil {
            movement = MouseMovement()
            _movement[key] = movement
        }
        
        eventHandler.setInputAction(.PinchStart, modifier: modifier, action: { (geometry: EventGeometry) in
            self._buttonsDown++
            self._isDown[key] = true
            self._pressTime[key] = NSDate()
            //self._eventStartPosition[key] = (geometry as! Touch2StartEventGeometry).position1
        })
        
        eventHandler.setInputAction(.PinchEnd, modifier: modifier, action: { (geometry: EventGeometry) in
            self._buttonsDown = max(self._buttonsDown - 1, 0)
            self._isDown[key] = false
            self._releaseTime[key] = NSDate()
        })
        
        eventHandler.setInputAction(.PinchMove, modifier: modifier, action: { (geometry: EventGeometry) in
            if self._isDown[key]! {
                // Aggregate several input events into a single animation frame.
                let geometry = (geometry as! TouchPinchMovementEventGeometry)
                var movement = self._movement[key]
                if movement == nil {
                    movement = MouseMovement()
                }
                if !self._update[key]! {
                    movement!.endPosition = geometry.distance.endPosition
                    movement!.angleEndPosition = geometry.angleAndHeight.endPosition
                } else {
                    movement!.startPosition = geometry.distance.startPosition
                    movement!.endPosition = geometry.distance.startPosition
                    movement!.angleStartPosition = geometry.angleAndHeight.startPosition
                    movement!.angleEndPosition = geometry.angleAndHeight.startPosition
                    self._update[key] = false
                    movement!.prevAngle = movement!.angleStartPosition.x
                }
                // Make sure our aggregation of angles does not "flip" over 360 degrees.
                var angle = movement!.angleEndPosition.x
                let prevAngle = movement!.prevAngle
                while angle >= (prevAngle + M_PI) {
                    angle -= Math.TwoPi
                }
                while angle < (prevAngle - M_PI) {
                    angle += Math.TwoPi
                }
                //movement.angleAndHeight.endPosition.x = -angle * canvas.clientWidth / 12
                //movement.angleAndHeight.startPosition.x = -prevAngle * canvas.clientWidth / 12
                self._movement[key] = movement!
            }
        })
    }
    /*
    function listenToWheel(aggregator, modifier) {
    var key = getKey(CameraEventType.WHEEL, modifier);
    
    var update = aggregator._update;
    update[key] = true;
    
    var movement = aggregator._movement[key];
    if (!defined(movement)) {
    movement = aggregator._movement[key] = {};
    }
    
    movement.startPosition = new Cartesian2();
    movement.endPosition = new Cartesian2();
    
    aggregator._eventHandler.setInputAction(function(delta) {
    // TODO: magic numbers
    var arcLength = 15.0 * CesiumMath.toRadians(delta);
    if (!update[key]) {
    movement.endPosition.y = movement.endPosition.y + arcLength;
    } else {
    Cartesian2.clone(Cartesian2.ZERO, movement.startPosition);
    movement.endPosition.x = 0.0;
    movement.endPosition.y = arcLength;
    update[key] = false;
    }
    }, ScreenSpaceEventType.WHEEL, modifier);
    }
    */
    func listenMouseButtonDownUp(type: CameraEventType, modifier: KeyboardEventModifier? = nil) {
        let key = getKey(type, modifier: modifier)
        
        _isDown[key] = false
        _eventStartPosition[key] = Cartesian2()
        
        var lastMovement = _lastMovement[key]
        if lastMovement == nil {
            lastMovement = MouseMovement()
            _lastMovement[key] = lastMovement
        }
        
        let down: ScreenSpaceEventType
        let up: ScreenSpaceEventType
        
        if type == .LeftDrag {
            down = .LeftDown
            up = .LeftUp
        } else if type == .RightDrag {
            down = .RightDown
            up = .RightUp
        } else /*if type == .MiddleDrag*/ {
            down = .MiddleDown
            up = .MiddleUp
        }
        
        eventHandler.setInputAction(down, modifier: modifier, action: { (geometry: EventGeometry) in
            self._buttonsDown++
            //var lastMovement = self._lastMovement[key]
            self._lastMovement[key] = MouseMovement(
                startPosition: lastMovement!.startPosition,
                endPosition:  lastMovement!.endPosition,
                angleStartPosition: Cartesian2(),
                angleEndPosition: Cartesian2(),
                prevAngle: 0.0,
                valid: false)
            self._isDown[key] = true
            self._pressTime[key] = NSDate()
            self._eventStartPosition[key] = (geometry as! TouchStartEventGeometry).position
        })
        
        eventHandler.setInputAction(up, modifier: modifier, action: { (geometry: EventGeometry) in
            self._buttonsDown = max(self._buttonsDown - 1, 0)
            self._isDown[key] = false
            self._releaseTime[key] = NSDate()
        })
    }
    
    func listenMouseMove(modifier: KeyboardEventModifier? = nil) {
        //var update = aggregator._update;
        //var movement = aggregator._movement;
        //var lastMovement = aggregator._lastMovement;
        //var isDown = aggregator._isDown;
        
        for i in 0..<CameraEventType.COUNT.rawValue {
            let key = getKey(CameraEventType(rawValue: i)!, modifier: modifier)
            _update[key] = true
        
            if _lastMovement[key] == nil {
                _lastMovement[key] = MouseMovement(
                    startPosition: Cartesian2(),
                    endPosition: Cartesian2(),
                    angleStartPosition: Cartesian2(),
                    angleEndPosition: Cartesian2(),
                    prevAngle: 0.0,
                    valid: false)
            }
            
            if _movement[key] == nil {
                _movement[key] = MouseMovement(
                    startPosition: Cartesian2(),
                    endPosition: Cartesian2(),
                    angleStartPosition: Cartesian2(),
                    angleEndPosition: Cartesian2(),
                    prevAngle: 0.0,
                    valid: true)
            }
        }
        
        eventHandler.setInputAction(.MouseMove, modifier: modifier, action: { (geometry: EventGeometry) in
            for i in 0..<CameraEventType.COUNT.rawValue {
                let type = CameraEventType(rawValue: i)!
                let key = self.getKey(type, modifier: modifier)
                if self._isDown[key] != nil && self._isDown[key]! {
                    if !(self._update[key]!) {
                        var movement = self._movement[key]!
                        movement.endPosition = (geometry as! TouchMoveEventGeometry).endPosition
                        self._movement[key] = movement
                    } else {
                        let geometry = (geometry as! TouchMoveEventGeometry)
                        var movement = self._movement[key]!
                        movement.valid = true
                        self._lastMovement[key] = movement
                        self._movement[key] = MouseMovement(
                            startPosition: geometry.startPosition,
                            endPosition: geometry.endPosition,
                            angleStartPosition: Cartesian2(),
                            angleEndPosition: Cartesian2(),
                            prevAngle: 0.0,
                            valid: true)
                        self._update[key] = false
                    }
                }
            }
            self._currentMousePosition = (geometry as! TouchMoveEventGeometry).endPosition
        })
    }
    
    /*defineProperties(CameraEventAggregator.prototype, {
    /**
    * Gets the current mouse position.
    * @memberof CameraEventAggregator.prototype
    * @type {Cartesian2}
    */
    currentMousePosition : {
    get : function() {
    return this._currentMousePosition;
    }
    },
    
    /**
    * Gets whether any mouse button is down, a touch has started, or the wheel has been moved.
    * @memberof CameraEventAggregator.prototype
    * @type {Boolean}
    */
    anyButtonDown : {
    get : function() {
    var wheelMoved = !this._update[getKey(CameraEventType.WHEEL)] ||
    !this._update[getKey(CameraEventType.WHEEL, KeyboardEventModifier.SHIFT)] ||
    !this._update[getKey(CameraEventType.WHEEL, KeyboardEventModifier.CTRL)] ||
    !this._update[getKey(CameraEventType.WHEEL, KeyboardEventModifier.ALT)];
    return this._buttonsDown > 0 || wheelMoved;
    }
    }
    });
    */
    /**
    * Gets if a mouse button down or touch has started and has been moved.
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Boolean} Returns <code>true</code> if a mouse button down or touch has started and has been moved; otherwise, <code>false</code>
    */
    func isMoving (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> Bool {
        let key = getKey(type, modifier: modifier)
        return !_update[key]!
    }
    
    /**
    * Gets the aggregated start and end position of the current event.
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Object} An object with two {@link Cartesian2} properties: <code>startPosition</code> and <code>endPosition</code>.
    */
    func getMovement (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> MouseMovement {
        let key = getKey(type, modifier: modifier)
        return _movement[key]!
    }
    
    /**
    * Gets the start and end position of the last move event (not the aggregated event).
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Object|undefined} An object with two {@link Cartesian2} properties: <code>startPosition</code> and <code>endPosition</code> or <code>undefined</code>.
    */
    func getLastMovement (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> MouseMovement? {
        let key = getKey(type, modifier: modifier)
        let lastMovement = _lastMovement[key]
        if lastMovement != nil && lastMovement!.valid {
            return lastMovement!
        }
        return nil
    }
    
    
    /**
    * Gets whether the mouse button is down or a touch has started.
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Boolean} Whether the mouse button is down or a touch has started.
    */
    func isButtonDown (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> Bool {
        let key = getKey(type, modifier: modifier)
        return _isDown[key]!
    }
    
    /**
    * Gets the mouse position that started the aggregation.
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Cartesian2} The mouse position.
    */
    func getStartMousePosition (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> Cartesian2 {
    
        if type == .Wheel || type == .Pinch {
            return _currentMousePosition
        }
        
        let key = getKey(type, modifier: modifier)
        return _eventStartPosition[key]!
    }
    
    /**
    * Gets the time the button was pressed or the touch was started.
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Date} The time the button was pressed or the touch was started.
    */
    func getButtonPressTime (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> NSDate? {
        let key = getKey(type, modifier: modifier)
        return _pressTime[key]
    }
    
    /**
    * Gets the time the button was released or the touch was ended.
    *
    * @param {CameraEventType} type The camera event type.
    * @param {KeyboardEventModifier} [modifier] The keyboard modifier.
    * @returns {Date} The time the button was released or the touch was ended.
    */
    func getButtonReleaseTime (type: CameraEventType, modifier: KeyboardEventModifier? = nil) -> NSDate? {
        let key = getKey(type, modifier: modifier)
        return _releaseTime[key]
    }
    
    /**
    * Signals that all of the events have been handled and the aggregator should be reset to handle new events.
    */
    func reset () {
        for (name, update) in _update {
            _update[name] = true
        }
        //_touchEvents.removeAll()
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
    * @see CameraEventAggregator#destroy
    */
    CameraEventAggregator.prototype.isDestroyed = function() {
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
    * @see CameraEventAggregator#isDestroyed
    *
    * @example
    * handler = handler && handler.destroy();
    */
    CameraEventAggregator.prototype.destroy = function() {
    this._eventHandler = this._eventHandler && this._eventHandler.destroy();
    return destroyObject(this);
    };
    
    return CameraEventAggregator;
    */
}