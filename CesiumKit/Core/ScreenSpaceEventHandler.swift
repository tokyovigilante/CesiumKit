//
//  ScreenSpaceEventHandler.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

// FIXME: reimport from cesium and try to merge touch and pointer

import Foundation

public enum MouseButton: Int {
    case left = 0,
    middle,
    right
}

protocol InputEvent {}

struct TouchStartEvent: InputEvent {
    var position: Cartesian2
}

struct Touch2StartEvent: InputEvent {
    var position1: Cartesian2
    var position2: Cartesian2
}

struct TouchMoveEvent: InputEvent {
    var startPosition: Cartesian2
    var endPosition: Cartesian2
}

struct TouchEndEvent: InputEvent {
    var position: Cartesian2
}

struct TouchClickEvent: InputEvent {
    var position: Cartesian2
}

struct TouchPinchMovementEvent: InputEvent {
    var distance = (
        startPosition: Cartesian2(),
        endPosition: Cartesian2()
    )
    var angleAndHeight = (
        startPosition: Cartesian2(),
        endPosition: Cartesian2()
    )
}

struct MouseDownEvent: InputEvent {
    var position: Cartesian2
}

struct MouseMoveEvent: InputEvent {
    var startPosition: Cartesian2
    var endPosition: Cartesian2
}

struct MouseUpEvent: InputEvent {
    var position: Cartesian2
}

struct MouseClickEvent: InputEvent {
    var position: Cartesian2
}

struct WheelEvent: InputEvent {
    var deltaX: Double
    var deltaY: Double
}


typealias EventAction = (_ event: InputEvent) -> ()

open class ScreenSpaceEventHandler {
    
    fileprivate var _inputEvents: [String: EventAction]
    var _buttonDown: MouseButton? = nil
    fileprivate var _isPinching = false
    fileprivate var _seenAnyTouchEvents = false
    
    fileprivate var _primaryStartPosition = Cartesian2()
    fileprivate var _primaryPosition = Cartesian2()
    fileprivate var _primaryPreviousPosition = Cartesian2()
    
    fileprivate var _positions = [Int: Cartesian2]()
    fileprivate var _previousPositions = [Int: Cartesian2]()
    
    //this._removalFunctions = [];
    
    // TODO: Revisit when doing mobile development. May need to be configurable
    // or determined based on the platform?
    fileprivate var _clickPixelTolerance = 5.0
    
    init(/*view: UIView, */_ something: Bool = false) {
        //self._view = view
        _inputEvents = Dictionary<String, EventAction>()
        
        registerListeners()
    }
    
    func getInputEventKey(_ type: ScreenSpaceEventType, modifier: KeyboardEventModifier? = nil) -> String {
        return "\(type.rawValue)" + (modifier != nil ? "+\(modifier!.rawValue)" : "")
    }
    /*
    function getModifier(event) {
    if (event.shiftKey) {
    return KeyboardEventModifier.SHIFT;
    } else if (event.ctrlKey) {
    return KeyboardEventModifier.CTRL;
    } else if (event.altKey) {
    return KeyboardEventModifier.ALT;
    }
    
    return undefined;
    }
    
    var MouseButton = {
    LEFT : 0,
    MIDDLE : 1,
    RIGHT : 2
    };
    */
    /*function registerListener(screenSpaceEventHandler, domType, element, callback) {
    var listener = function(e) {
    callback(screenSpaceEventHandler, e);
    };
    
    element.addEventListener(domType, listener, false);
    
    screenSpaceEventHandler._removalFunctions.push(function() {
    element.removeEventListener(domType, listener, false);
    });
    }*/
    
    func registerListeners() {
        /*
        // some listeners may be registered on the document, so we still get events even after
        // leaving the bounds of element.
        // this is affected by the existence of an undocumented disableRootEvents property on element.
        var alternateElement = !defined(element.disableRootEvents) ? document : element;
        
        if (defined(window.PointerEvent)) {
        registerListener(screenSpaceEventHandler, 'pointerdown', element, handlePointerDown);
        registerListener(screenSpaceEventHandler, 'pointerup', element, handlePointerUp);
        registerListener(screenSpaceEventHandler, 'pointermove', element, handlePointerMove);
        } else {
        registerListener(screenSpaceEventHandler, 'mousedown', element, handleMouseDown);
        registerListener(screenSpaceEventHandler, 'mouseup', alternateElement, handleMouseUp);
        registerListener(screenSpaceEventHandler, 'mousemove', alternateElement, handleMouseMove);
        registerListener(screenSpaceEventHandler, 'touchstart', element, handleTouchStart);
        registerListener(screenSpaceEventHandler, 'touchend', alternateElement, handleTouchEnd);
        registerListener(screenSpaceEventHandler, 'touchmove', alternateElement, handleTouchMove);
        }
        
        registerListener(screenSpaceEventHandler, 'dblclick', element, handleDblClick);
        
        // detect available wheel event
        var wheelEvent;
        if ('onwheel' in element) {
        // spec event type
        wheelEvent = 'wheel';
        } else if (defined(document.onmousewheel)) {
        // legacy event type
        wheelEvent = 'mousewheel';
        } else {
        // older Firefox
        wheelEvent = 'DOMMouseScroll';
        }
        
        registerListener(screenSpaceEventHandler, wheelEvent, element, handleWheel);*/
    }
    /*
    func unregisterListeners() {
    if let recognizers = _view.gestureRecognizers {
    for recognizer in recognizers {
    _view.removeGestureRecognizer(recognizer as! UIGestureRecognizer)
    }
    }
    }
    
    func handlePan (gestureRecognizer: UIPanGestureRecognizer) {
    
    // moving single touch
    let position = gestureRecognizer.translationInView(_view)
    _primaryPosition.x = Double(position.x)
    _primaryPosition.y = Double(position.y)
    println("(\(_primaryPosition.x), \(_primaryPosition.y))")
    
    var previousPosition = _primaryPreviousPosition
    
    if let action = getInputAction(ScreenSpaceEventType.MouseMove, modifier: nil) {
    
    /*
    Cartesian2.clone(previousPosition, touchMoveEvent.startPosition);
    Cartesian2.clone(position, touchMoveEvent.endPosition);
    */
    //action(touchMoveEvent)
    }
    _primaryPreviousPosition = _primaryPosition
    
    //event.preventDefault()
    }*/
    
    open func handleMouseDown (_ button: MouseButton, position: Cartesian2, modifier: KeyboardEventModifier?) {
        if _seenAnyTouchEvents {
            return
        }
        
        _buttonDown = button
        
        let screenSpaceEventType: ScreenSpaceEventType
        switch button {
        case .left:
            screenSpaceEventType = .leftDown
        case .middle:
            screenSpaceEventType = .middleDown
        case .right:
            screenSpaceEventType = .rightDown
        }
        _primaryPosition = position
        _primaryStartPosition = position
        _primaryPreviousPosition = position
        
        if let action = getInputAction(screenSpaceEventType, modifier: modifier) {
            
            let mouseDownEvent = MouseDownEvent(position: position)
            action(mouseDownEvent)
            
        }
    }

    open func handleMouseUp (_ button: MouseButton, position: Cartesian2, modifier: KeyboardEventModifier?) {
        if _seenAnyTouchEvents {
            return
        }
        
        _buttonDown = nil
        
        let screenSpaceEventType: ScreenSpaceEventType
        let clickScreenSpaceEventType: ScreenSpaceEventType
        switch button {
        case .left:
            screenSpaceEventType = .leftDown
            clickScreenSpaceEventType = .leftClick
        case .middle:
            screenSpaceEventType = .middleDown
            clickScreenSpaceEventType = ScreenSpaceEventType.middleClick

        case .right:
            screenSpaceEventType = .rightDown
            clickScreenSpaceEventType = ScreenSpaceEventType.rightClick
        }
        
        if let action = getInputAction(screenSpaceEventType, modifier: modifier) {
            _primaryPosition = position
            action(MouseUpEvent(position: position))
        }
        
        if let clickAction = getInputAction(clickScreenSpaceEventType, modifier: modifier) {
            _primaryPosition = position
            let startPosition = _primaryStartPosition
            let xDiff = startPosition.x - position.x
            let yDiff = startPosition.y - position.y
            let totalPixels = sqrt(xDiff * xDiff + yDiff * yDiff)
            
            if totalPixels < _clickPixelTolerance {
                clickAction(MouseClickEvent(position: position))
            }
        }
    }
   
    open func handleMouseMove (_ button: MouseButton, position: Cartesian2, modifier: KeyboardEventModifier?) {
        if _seenAnyTouchEvents {
            return
        }
        
        _primaryPosition = position
        let previousPosition = _primaryPreviousPosition
        
        if let action = getInputAction(.mouseMove, modifier: modifier) {
            let mouseMoveEvent = MouseMoveEvent(startPosition: previousPosition, endPosition: position)
            action(mouseMoveEvent)
        }
        _primaryPreviousPosition = position
    }
    /*
    var mouseDblClickEvent = {
    position : new Cartesian2()
    };
    
    function handleDblClick(screenSpaceEventHandler, event) {
    var button = event.button;
    
    var screenSpaceEventType;
    if (button === MouseButton.LEFT) {
    screenSpaceEventType = ScreenSpaceEventType.LEFT_DOUBLE_CLICK;
    } else if (button === MouseButton.MIDDLE) {
    screenSpaceEventType = ScreenSpaceEventType.MIDDLE_DOUBLE_CLICK;
    } else if (button === MouseButton.RIGHT) {
    screenSpaceEventType = ScreenSpaceEventType.RIGHT_DOUBLE_CLICK;
    } else {
    return;
    }
    
    var modifier = getModifier(event);
    
    var action = screenSpaceEventHandler.getInputAction(screenSpaceEventType, modifier);
    
    if (defined(action)) {
    getPosition(screenSpaceEventHandler, event, mouseDblClickEvent.position);
    
    action(mouseDblClickEvent);
    }
    }
     */
    open func handleWheel (_ deltaX: Double, deltaY: Double) {
        
        // standard wheel event uses deltaY.  sign is opposite wheelDelta.
        // deltaMode indicates what unit it is in.
        /*if (defined(event.deltaY)) {
            var deltaMode = event.deltaMode;
            if (deltaMode === event.DOM_DELTA_PIXEL) {
                delta = -event.deltaY;
            } else if (deltaMode === event.DOM_DELTA_LINE) {
                delta = -event.deltaY * 40;
            } else {
                // DOM_DELTA_PAGE
                delta = -event.deltaY * 120;
            }
        } else if (event.detail > 0) {
            // old Firefox versions use event.detail to count the number of clicks. The sign
            // of the integer is the direction the wheel is scrolled.
            delta = event.detail * -120;
        } else {
            delta = event.wheelDelta;
        }*/
        
        if let action = getInputAction(.wheel, modifier: nil) {
            action(WheelEvent(deltaX: deltaX, deltaY: deltaY))
        }
    }
    
    open func handleTouchStart(_ touches: Set<NSObject>, screenScaleFactor: Double) {
        _seenAnyTouchEvents = true
        
        /*for (i, touch) in enumerate(touches) {
            if let touch = touch as? UITouch {
        
                let position = touch.locationInView(_view)
                _positions[i] = Cartesian2(x: Double(position.x) * screenScaleFactor, y: Double(position.y) * screenScaleFactor)
            }
        }
        
        fireTouchEvents()
        
        for (i, touch) in enumerate(touches) {
            if let touch = touch as? UITouch {
                
                let position = touch.locationInView(_view)
                _previousPositions[i] = Cartesian2(x: Double(position.x) * screenScaleFactor, y: Double(position.y) * screenScaleFactor)
            }
        }*/
    }
    
    open func handleTouchMove(_ touches: Set<NSObject>, screenScaleFactor: Double) {
        _seenAnyTouchEvents = true
        
        /*for (i, touch) in enumerate(touches) {
            if let touch = touch as? UITouch {
                let position = touch.locationInView(_view)
                println("\(i): \(position.x):\(position.y)")
                _positions[i] = Cartesian2(x: Double(position.x) * screenScaleFactor, y: Double(position.y) * screenScaleFactor)
            }
        }
        
        fireTouchMoveEvents()
        
        for (i, touch) in enumerate(touches) {
            if let touch = touch as? UITouch {
                
                let position = touch.locationInView(_view)
                _previousPositions[i] = Cartesian2(x: Double(position.x), y: Double(position.y))
            }
        }*/
    }
    
    open func handleTouchEnd(_ touches: Set<NSObject>) {
        _seenAnyTouchEvents = true
        
        _positions.removeAll()
        /*for touch in touches {
            if let touch = touch as? UITouch {
                let tapCount = touch.tapCount
                let position = touch.locationInView(_view)
                _positions[tapCount] = nil
            }
        }*/
        
        fireTouchEvents()
        
        _previousPositions.removeAll()

/*        for (i, touch) in enumerate(touches) {
            if let touch = touch as? UITouch {
                
                let position = touch.locationInView(_view)
                _previousPositions[i] = nil
            }
        }*/
        
    }
    
    func fireTouchEvents() {
        
        let modifier: KeyboardEventModifier? = nil// = getModifier(event);
        let numberOfTouches = _positions.count
        
        var action: EventAction?
        var clickAction: EventAction?
        
        if (numberOfTouches != 1 && _buttonDown == MouseButton.left) {
            // transitioning from single touch, trigger UP and might trigger CLICK
            _buttonDown = nil
            action = getInputAction(.leftUp, modifier: modifier)
            
            if action != nil {
                action!(TouchEndEvent(position: _primaryPosition))
            }
            
            if numberOfTouches == 0 {
                // releasing single touch, check for CLICK
                /*clickAction = screenSpaceEventHandler.getInputAction(ScreenSpaceEventType.LEFT_CLICK, modifier);
                
                if (defined(clickAction)) {
                var startPosition = screenSpaceEventHandler._primaryStartPosition;
                var endPosition = previousPositions.values[0];
                var xDiff = startPosition.x - endPosition.x;
                var yDiff = startPosition.y - endPosition.y;
                var totalPixels = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
                
                if (totalPixels < screenSpaceEventHandler._clickPixelTolerance) {
                Cartesian2.clone(screenSpaceEventHandler._primaryPosition, touchClickEvent.position);
                
                clickAction(touchClickEvent);
                }
                }*/
            }
            
            // Otherwise don't trigger CLICK, because we are adding more touches.*/
        }
        
        if numberOfTouches != 2 && _isPinching {
            // transitioning from pinch, trigger PINCH_END
            _isPinching = false
            
            if let action = getInputAction(.pinchEnd, modifier: modifier) {
                action(TouchEndEvent(position: _primaryPosition))
            }
        }
        
        if numberOfTouches == 1 {
            // transitioning to single touch, trigger DOWN
            if let position = _positions[0] {
                _buttonDown = .left

                _primaryPosition = position
                _primaryStartPosition = position
                _primaryPreviousPosition = position
                
                action = getInputAction(ScreenSpaceEventType.leftDown, modifier: modifier)
                
                if action != nil {
                    action!(TouchStartEvent(position: position))
                }
            }
        }
        
        if numberOfTouches == 2 {
            // transitioning to pinch, trigger PINCH_START
            _isPinching = true
            
            action = getInputAction(.pinchStart, modifier: modifier)
            
            if action != nil {
                action!(Touch2StartEvent(position1: _positions[0]!, position2: _positions[1]!))
            }
        }
    }
    
    func fireTouchMoveEvents() {
        let modifier: KeyboardEventModifier? = nil//  getModifier(event);
        /*var positions = screenSpaceEventHandler._positions;
        var previousPositions = screenSpaceEventHandler._previousPositions;
        var numberOfTouches = positions.length;*/
        var action: EventAction?
        
        let numberOfTouches = _positions.count
        
        if numberOfTouches == 1 && _buttonDown == .left {
            // moving single touch
            if let position = _positions[0] {
                _primaryPosition = position
                let previousPosition = _primaryPreviousPosition
                
                action = getInputAction(.mouseMove, modifier: modifier)
                
                if action != nil {
                    action!(TouchMoveEvent(
                        startPosition: previousPosition,
                        endPosition: position)
                    )
                }
                
                _primaryPreviousPosition = position
            }
        } else if numberOfTouches == 2 && _isPinching {
            // moving pinch
            
            action = getInputAction(.pinchMove, modifier: modifier)
            if action != nil {
                let position1 = _positions[0]!
                let position2 = _positions[1]!
                let previousPosition1 = _previousPositions[0] ?? _positions[0]!
                let previousPosition2 = _previousPositions[1] ?? _positions[1]!
                
                let dX = position2.x - position1.x
                let dY = position2.y - position1.y
                let dist = sqrt(dX * dX + dY * dY) * 0.25
                
                let prevDX = previousPosition2.x - previousPosition1.x;
                let prevDY = previousPosition2.y - previousPosition1.y;
                let prevDist = sqrt(prevDX * prevDX + prevDY * prevDY) * 0.25
                
                let cY = (position2.y + position1.y) * 0.125
                let prevCY = (previousPosition2.y + previousPosition1.y) * 0.125
                let angle = atan2(dY, dX)
                let prevAngle = atan2(prevDY, prevDX)
                
                let touchPinchMovementEvent = TouchPinchMovementEvent(
                    distance:
                    (startPosition: Cartesian2(x: 0.0, y: prevDist),
                        endPosition: Cartesian2(x: 0.0, y: dist)),
                    angleAndHeight:
                    (startPosition: Cartesian2(x: prevAngle, y: prevCY),
                        endPosition: Cartesian2(x: angle, y: cY))
                )
                action!(touchPinchMovementEvent)
            }
        }
    }
    /*
    function handlePointerDown(screenSpaceEventHandler, event) {
    event.target.setPointerCapture(event.pointerId);
    
    if (event.pointerType === 'touch') {
    var positions = screenSpaceEventHandler._positions;
    
    var identifier = event.pointerId;
    positions.set(identifier, getPosition(screenSpaceEventHandler, event, new Cartesian2()));
    
    fireTouchEvents(screenSpaceEventHandler, event);
    
    var previousPositions = screenSpaceEventHandler._previousPositions;
    previousPositions.set(identifier, Cartesian2.clone(positions.get(identifier)));
    } else {
    handleMouseDown(screenSpaceEventHandler, event);
    }
    }
    
    function handlePointerUp(screenSpaceEventHandler, event) {
    if (event.pointerType === 'touch') {
    var positions = screenSpaceEventHandler._positions;
    
    var identifier = event.pointerId;
    positions.remove(identifier);
    
    fireTouchEvents(screenSpaceEventHandler, event);
    
    var previousPositions = screenSpaceEventHandler._previousPositions;
    previousPositions.remove(identifier);
    } else {
    handleMouseUp(screenSpaceEventHandler, event);
    }
    }
    */
    
    
    /**
    * Set a function to be executed on an input event.
    *
    * @param {Function} action Function to be executed when the input event occurs.
    * @param {Number} type The ScreenSpaceEventType of input event.
    * @param {Number} [modifier] A KeyboardEventModifier key that is held when a <code>type</code>
    * event occurs.
    *
    * @see ScreenSpaceEventHandler#getInputAction
    * @see ScreenSpaceEventHandler#removeInputAction
    */
    func  setInputAction (_ type: ScreenSpaceEventType, modifier: KeyboardEventModifier?, action: @escaping EventAction) {
        let key = getInputEventKey(type, modifier: modifier)
        _inputEvents[key] = action
    }
    
    /**
    * Returns the function to be executed on an input event.
    *
    * @param {Number} type The ScreenSpaceEventType of input event.
    * @param {Number} [modifier] A KeyboardEventModifier key that is held when a <code>type</code>
    * event occurs.
    *
    * @see ScreenSpaceEventHandler#setInputAction
    * @see ScreenSpaceEventHandler#removeInputAction
    */
    func getInputAction (_ type: ScreenSpaceEventType, modifier: KeyboardEventModifier?) -> EventAction? {
        
        let key = getInputEventKey(type, modifier: modifier)
        return _inputEvents[key]
    }
    /*
    /**
    * Removes the function to be executed on an input event.
    *
    * @param {Number} type The ScreenSpaceEventType of input event.
    * @param {Number} [modifier] A KeyboardEventModifier key that is held when a <code>type</code>
    * event occurs.
    *
    * @see ScreenSpaceEventHandler#getInputAction
    * @see ScreenSpaceEventHandler#setInputAction
    */
    ScreenSpaceEventHandler.prototype.removeInputAction = function(type, modifier) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(type)) {
    throw new DeveloperError('type is required.');
    }
    //>>includeEnd('debug');
    
    var key = getInputEventKey(type, modifier);
    delete this._inputEvents[key];
    };
    
    /**
    * Returns true if this object was destroyed; otherwise, false.
    * <br /><br />
    * If this object was destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
    *
    * @returns {Boolean} <code>true</code> if this object was destroyed; otherwise, <code>false</code>.
    *
    * @see ScreenSpaceEventHandler#destroy
    */
    ScreenSpaceEventHandler.prototype.isDestroyed = function() {
    return false;
    };
    
    
    ScreenSpaceEventHandler.prototype.destroy = function() {
    unregisterListeners(this);
    
    return destroyObject(this);
    };
    
    return ScreenSpaceEventHandler;
    });
    */
    /*func handlePointerMove(screenSpaceEventHandler, event) {
    if (event.pointerType === 'touch') {
    var positions = screenSpaceEventHandler._positions;
    
    var identifier = event.pointerId;
    getPosition(screenSpaceEventHandler, event, positions.get(identifier));
    
    fireTouchMoveEvents(screenSpaceEventHandler, event);
    
    var previousPositions = screenSpaceEventHandler._previousPositions;
    Cartesian2.clone(positions.get(identifier), previousPositions.get(identifier));
    } else {
    handleMouseMove(screenSpaceEventHandler, event);
    }
    }*/
    /**
    * Removes listeners held by this object.
    * <br /><br />
    * Once an object is destroyed, it should not be used; calling any function other than
    * <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
    * assign the return value (<code>undefined</code>) to the object as done in the example.
    *
    * @returns {undefined}
    *
    * @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
    *
    * @see ScreenSpaceEventHandler#isDestroyed
    *
    * @example
    * handler = handler && handler.destroy();
    */
    deinit {
        //unregisterListeners()
    }
    
}
