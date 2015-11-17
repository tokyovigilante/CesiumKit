//
//  Camera.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

private protocol DRU {
    var direction: Cartesian3 { get set }
    var right: Cartesian3 { get set }
    var up: Cartesian3 { get set }
}

import Foundation

/**
 * The camera is defined by a position, orientation, and view frustum.
 * <br /><br />
 * The orientation forms an orthonormal basis with a view, up and right = view x up unit vectors.
 * <br /><br />
 * The viewing frustum is defined by 6 planes.
 * Each plane is represented by a {@link Cartesian4} object, where the x, y, and z components
 * define the unit vector normal to the plane, and the w component is the distance of the
 * plane from the origin/camera position.
 *
 * @alias Camera
 *
 * @constructor
 *
 * @param {Scene} scene The scene.
 *
 * @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Camera.html|Cesium Sandcastle Camera Demo}
 * @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Camera%20Tutorial.html">Sandcastle Example</a> from the <a href="http://cesiumjs.org/2013/02/13/Cesium-Camera-Tutorial/|Camera Tutorial}
 *
 * @example
 * // Create a camera looking down the negative z-axis, positioned at the origin,
 * // with a field of view of 60 degrees, and 1:1 aspect ratio.
 * var camera = new Cesium.Camera(scene);
 * camera.position = new Cesium.Cartesian3();
 * camera.direction = Cesium.Cartesian3.negate(Cesium.Cartesian3.UNIT_Z, new Cesium.Cartesian3());
 * camera.up = Cesium.Cartesian3.clone(Cesium.Cartesian3.UNIT_Y);
 * camera.frustum.fov = Cesium.Math.PI_OVER_THREE;
 * camera.frustum.near = 1.0;
 * camera.frustum.far = 2.0;
 */
public class Camera: DRU {
    
    var isUpdated = false
    
    weak var scene: Scene!
    
    let maxRadii: Double = Ellipsoid.wgs84().maximumRadius
    
    /**
     * The position of the camera.
     *
     * @type {Cartesian3}
     */
    
    var position = Cartesian3()
    private var _position = Cartesian3()
    private var _positionWC = Cartesian3()
    
    /**
     * Gets the position of the camera in world coordinates.
     * @memberof Camera.prototype
     *
     * @type {Cartesian3}
     * @readonly
     */
    var positionWC: Cartesian3 {
        get {
            updateMembers()
            return _positionWC
        }
    }
    
    /**
     * Gets the {@link Cartographic} position of the camera, with longitude and latitude
     * expressed in radians and height in meters.  In 2D and Columbus View, it is possible
     * for the returned longitude and latitude to be outside the range of valid longitudes
     * and latitudes when the camera is outside the map.
     * @memberof Camera.prototype
     *
     * @type {Cartographic}
     */
    var positionCartographic: Cartographic {
        get {
            updateMembers()
            return _positionCartographic
        }
    }
    private var _positionCartographic = Cartographic()
    
    /**
     * The view direction of the camera.
     *
     * @type {Cartesian3}
     */
    var direction = Cartesian3()
    private var _direction = Cartesian3()
    private var _directionWC = Cartesian3()
    
    var directionWC: Cartesian3 {
        get {
            updateMembers()
            return _directionWC
        }
    }
    
    /**
     * The up direction of the camera.
     *
     * @type {Cartesian3}
     */
    var up = Cartesian3()
    var _up = Cartesian3()
    private var _upWC = Cartesian3()
    
    /**
     * Gets the up direction of the camera in world coordinates.
     * @memberof Camera.prototype
     *
     * @type {Cartesian3}
     * @readonly
     */
    var upWC: Cartesian3 {
        get {
            updateMembers()
            return _upWC
        }
    }
    
    /**
     * The right direction of the camera.
     *
     * @type {Cartesian3}
     */
    var right = Cartesian3()
    private var _right = Cartesian3()
    private var _rightWC = Cartesian3()
    
    /**
     * Gets the right direction of the camera in world coordinates.
     * @memberof Camera.prototype
     *
     * @type {Cartesian3}
     * @readonly
     */
    var rightWC: Cartesian3 {
        get {
            updateMembers()
            return _rightWC
        }
    }
    
    /**
     * Gets the camera heading in radians.
     * @memberof Camera.prototype
     *
     * @type {Number}
     * @readonly
     */
    var heading: Double? {
        if _mode != .Morphing {
            let oldTransform = _transform
            let transform = Transforms.eastNorthUpToFixedFrame(positionWC, ellipsoid: _projection.ellipsoid)
            _setTransform(transform)
            
            let heading = getHeading(direction: direction, up: up)
            
            _setTransform(oldTransform);
            
            return heading;
        }
        return nil
    }
    
    
    /**
     * Gets the camera pitch in radians.
     * @memberof Camera.prototype
     *
     * @type {Number}
     * @readonly
     */
    var pitch: Double? {
        if _mode != .Morphing {
            
            let oldTransform = _transform
            let transform = Transforms.eastNorthUpToFixedFrame(positionWC, ellipsoid: _projection.ellipsoid)
            _setTransform(transform)
            
            var pitch = getPitch(direction: direction)
            
            _setTransform(oldTransform)
            
            return pitch
        }
        
        return nil
    }
    
    
    /**
     * Gets the camera roll in radians.
     * @memberof Camera.prototype
     *
     * @type {Number}
     * @readonly
     */
    var roll: Double? {
        if _mode != .Morphing {
            let oldTransform = _transform
            let transform = Transforms.eastNorthUpToFixedFrame(positionWC, ellipsoid: _projection.ellipsoid)
            _setTransform(transform)
            
            let roll = getRoll(direction: direction, up: up, right: right)
            
            _setTransform(oldTransform)
            
            return roll
        }
        
        return nil
    }
    
    
    /**
     * Gets the event that will be raised at when the camera starts to move.
     * @memberof Camera.prototype
     * @type {Event}
     * @readonly
     */
    private (set) var moveStart = Event()
    
    /**
     * Gets the event that will be raised at when the camera has stopped moving.
     * @memberof Camera.prototype
     * @type {Event}
     * @readonly
     */
    private (set) var moveEnd = Event()
    
    /**
     * Gets the camera's reference frame. The inverse of this transformation is appended to the view matrix.
     * @memberof Camera.prototype
     *
     * @type {Matrix4}
     * @readonly
     *
     * @default {@link Matrix4.IDENTITY}
     */
    var transform: Matrix4 {
        return _transform
    }
    
    private var _transform = Matrix4.identity()
    private var _invTransform = Matrix4.identity()
    private var _actualTransform = Matrix4.identity()
    private var _actualInvTransform = Matrix4.identity()
    private var _transformChanged = false
    
    
    /**
     * Gets the inverse camera transform.
     * @memberof Camera.prototype
     *
     * @type {Matrix4}
     * @readonly
     *
     * @default {@link Matrix4.IDENTITY}
     */
    var inverseTransform: Matrix4 {
        get {
            updateMembers()
            return _invTransform
        }
    }
    
    /**
     * Gets the view matrix.
     * @memberof Camera.prototype
     *
     * @type {Matrix4}
     *
     * @see czm_view
     * @see Camera#inverseViewMatrix
     */
    var viewMatrix: Matrix4 {
        get {
            updateMembers()
            return _viewMatrix
        }
        set (value) {
            _viewMatrix = value
        }
    }
    
    private var _viewMatrix = Matrix4()
    
    /**
     * Gets the inverse view matrix.
     * @memberof Camera.prototype
     *
     * @type {Matrix4}
     *
     * @see czm_inverseView
     * @see Camera#viewMatrix
     */
    var inverseViewMatrix: Matrix4 {
        get {
            updateMembers()
            return _invViewMatrix
        }
    }
    
    private var _invViewMatrix = Matrix4()
    
    /**
     * The region of space in view.
     *
     * @type {Frustum}
     * @default PerspectiveFrustum()
     *
     * @see PerspectiveFrustum
     * @see PerspectiveOffCenterFrustum
     * @see OrthographicFrustum
     */
     //let frustum: PerspectiveFrustum
    var frustum: Frustum
    
    /**
     * The default amount to move the camera when an argument is not
     * provided to the move methods.
     * @type {Number}
     * @default 100000.0;
     */
    var defaultMoveAmount = 100000.0
    
    /**
     * The default amount to rotate the camera when an argument is not
     * provided to the look methods.
     * @type {Number}
     * @default Math.PI / 60.0
     */
    var defaultLookAmount: Double = M_PI / 60.0
    
    /**
     * The default amount to rotate the camera when an argument is not
     * provided to the rotate methods.
     * @type {Number}
     * @default Math.PI / 3600.0
     */
    var defaultRotateAmount = M_PI / 3600.0
    /**
     * The default amount to move the camera when an argument is not
     * provided to the zoom methods.
     * @type {Number}
     * @default 100000.0;
     */
    var defaultZoomAmount = 100000.0
    
    /**
     * If set, the camera will not be able to rotate past this axis in either direction.
     * @type {Cartesian3}
     * @default undefined
     */
    public var constrainedAxis: Cartesian3? = nil
    /**
     * The factor multiplied by the the map size used to determine where to clamp the camera position
     * when translating across the surface. The default is 1.5. Only valid for 2D and Columbus view.
     * @type {Number}
     * @default 1.5
     */
    var maximumTranslateFactor = 1.5
    /**
     * The factor multiplied by the the map size used to determine where to clamp the camera position
     * when zooming out from the surface. The default is 2.5. Only valid for 2D.
     * @type {Number}
     * @default 2.5
     */
    var maximumZoomFactor = 2.5
    
    private var _mode: SceneMode = .Scene3D
    
    private var _modeChanged = true
    
    private var _projection: MapProjection
    
    private var _maxCoord = Cartesian3()
    
    private var _max2Dfrustum: Frustum? = nil
    
    var transform2D = Matrix4(0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)
    
    var transform2DInverse: Matrix4
    
    /**
     * The default extent the camera will view on creation.
     * @type Rectangle
     */
    var defaultViewRectangle = Rectangle(fromDegreesWest: -95.0, south: -20.0, east: -70.0, north: 90.0)
    
    /**
     * A scalar to multiply to the camera position and add it back after setting the camera to view the rectangle.
     * A value of zero means the camera will view the entire {@link Camera#DEFAULT_VIEW_RECTANGLE}, a value greater than zero
     * will move it further away from the extent, and a value less than zero will move it close to the extent.
     * @type Number
     */
    var defaultViewFactor = 0.5
    
    init(projection: MapProjection, mode: SceneMode, initialWidth: Double, initialHeight: Double) {
        
        _projection = projection
        _maxCoord = _projection.project(Cartographic(longitude: M_PI, latitude: M_PI_2))
        _mode = mode
        
        transform2DInverse = transform2D.inverseTransformation()
        
        frustum = PerspectiveFrustum()
        frustum.aspectRatio = Double(initialWidth) / Double(initialHeight)
        frustum.fov = Math.toRadians(60.0)
        
        updateViewMatrix()
        
        // set default view
        viewRectangle(defaultViewRectangle, ellipsoid: projection.ellipsoid)
        
        var mag = position.magnitude()
        mag += mag * defaultViewFactor
        position  = position.normalize().multiplyByScalar(mag)
    }
    
    // Testing only
    init(fakeScene: (
        canvas: (width: Int, height: Int),
        width: Int,
        height: Int,
        mapProjection: MapProjection//,
        /* tweens = new TweenCollection();*/)) {
            
            _projection = fakeScene.mapProjection
            _maxCoord = _projection.project(Cartographic(longitude: M_PI, latitude: M_PI_2))
            
            transform2DInverse = transform2D.inverseTransformation()
            
            frustum = PerspectiveFrustum()
            frustum.aspectRatio = Double(fakeScene.canvas.width) / Double(fakeScene.canvas.height)
            frustum.fov = Math.toRadians(60.0)
            
            updateViewMatrix()
            
            // set default view
            viewRectangle(defaultViewRectangle)
            
            var mag = position.magnitude()
            mag += mag * defaultViewFactor
            position  = position.normalize().multiplyByScalar(mag)
    }
    
    
    func updateViewMatrix() {
        
        var newViewMatrix = Matrix4()
        
        newViewMatrix[0] = right.x
        newViewMatrix[1] = up.x
        newViewMatrix[2] = -direction.x
        newViewMatrix[3] = 0.0
        newViewMatrix[4] = right.y
        newViewMatrix[5] = up.y
        newViewMatrix[6] = -direction.y
        newViewMatrix[7] = 0.0
        newViewMatrix[8] = right.z
        newViewMatrix[9] = up.z
        newViewMatrix[10] = -direction.z
        newViewMatrix[11] = 0.0
        newViewMatrix[12] = -right.dot(position)
        newViewMatrix[13] = -up.dot(position)
        newViewMatrix[14] = direction.dot(position)
        newViewMatrix[15] = 1.0
        
        _viewMatrix = newViewMatrix.multiply(_actualInvTransform)
        _invViewMatrix = _viewMatrix.inverseTransformation()
    }
    /*
    var scratchCartographic = new Cartographic();
    var scratchCartesian3Projection = new Cartesian3();
    var scratchCartesian3 = new Cartesian3();
    var scratchCartesian4Origin = new Cartesian4();
    var scratchCartesian4NewOrigin = new Cartesian4();
    var scratchCartesian4NewXAxis = new Cartesian4();
    var scratchCartesian4NewYAxis = new Cartesian4();
    var scratchCartesian4NewZAxis = new Cartesian4();
    
    function convertTransformForColumbusView(camera) {
    var projection = camera._projection;
    var ellipsoid = projection.ellipsoid;
    
    var origin = Matrix4.getColumn(camera._transform, 3, scratchCartesian4Origin);
    var cartographic = ellipsoid.cartesianToCartographic(origin, scratchCartographic);
    
    var projectedPosition = projection.project(cartographic, scratchCartesian3Projection);
    var newOrigin = scratchCartesian4NewOrigin;
    newOrigin.x = projectedPosition.z;
    newOrigin.y = projectedPosition.x;
    newOrigin.z = projectedPosition.y;
    newOrigin.w = 1.0;
    
    var xAxis = Cartesian4.add(Matrix4.getColumn(camera._transform, 0, scratchCartesian3), origin, scratchCartesian3);
    ellipsoid.cartesianToCartographic(xAxis, cartographic);
    
    projection.project(cartographic, projectedPosition);
    var newXAxis = scratchCartesian4NewXAxis;
    newXAxis.x = projectedPosition.z;
    newXAxis.y = projectedPosition.x;
    newXAxis.z = projectedPosition.y;
    newXAxis.w = 0.0;
    
    Cartesian3.subtract(newXAxis, newOrigin, newXAxis);
    
    var yAxis = Cartesian4.add(Matrix4.getColumn(camera._transform, 1, scratchCartesian3), origin, scratchCartesian3);
    ellipsoid.cartesianToCartographic(yAxis, cartographic);
    
    projection.project(cartographic, projectedPosition);
    var newYAxis = scratchCartesian4NewYAxis;
    newYAxis.x = projectedPosition.z;
    newYAxis.y = projectedPosition.x;
    newYAxis.z = projectedPosition.y;
    newYAxis.w = 0.0;
    
    Cartesian3.subtract(newYAxis, newOrigin, newYAxis);
    
    var newZAxis = scratchCartesian4NewZAxis;
    Cartesian3.cross(newXAxis, newYAxis, newZAxis);
    Cartesian3.normalize(newZAxis, newZAxis);
    Cartesian3.cross(newYAxis, newZAxis, newXAxis);
    Cartesian3.normalize(newXAxis, newXAxis);
    Cartesian3.cross(newZAxis, newXAxis, newYAxis);
    Cartesian3.normalize(newYAxis, newYAxis);
    
    Matrix4.setColumn(camera._actualTransform, 0, newXAxis, camera._actualTransform);
    Matrix4.setColumn(camera._actualTransform, 1, newYAxis, camera._actualTransform);
    Matrix4.setColumn(camera._actualTransform, 2, newZAxis, camera._actualTransform);
    Matrix4.setColumn(camera._actualTransform, 3, newOrigin, camera._actualTransform);
    }
    
    function convertTransformFor2D(camera) {
    var projection = camera._projection;
    var ellipsoid = projection.ellipsoid;
    
    var origin = Matrix4.getColumn(camera._transform, 3, scratchCartesian4Origin);
    var cartographic = ellipsoid.cartesianToCartographic(origin, scratchCartographic);
    
    var projectedPosition = projection.project(cartographic, scratchCartesian3Projection);
    var newOrigin = scratchCartesian4NewOrigin;
    newOrigin.x = projectedPosition.z;
    newOrigin.y = projectedPosition.x;
    newOrigin.z = projectedPosition.y;
    newOrigin.w = 1.0;
    
    var newZAxis = Cartesian4.clone(Cartesian4.UNIT_X, scratchCartesian4NewZAxis);
    
    var xAxis = Cartesian4.add(Matrix4.getColumn(camera._transform, 0, scratchCartesian3), origin, scratchCartesian3);
    ellipsoid.cartesianToCartographic(xAxis, cartographic);
    
    projection.project(cartographic, projectedPosition);
    var newXAxis = scratchCartesian4NewXAxis;
    newXAxis.x = projectedPosition.z;
    newXAxis.y = projectedPosition.x;
    newXAxis.z = projectedPosition.y;
    newXAxis.w = 0.0;
    
    Cartesian3.subtract(newXAxis, newOrigin, newXAxis);
    newXAxis.x = 0.0;
    
    var newYAxis = scratchCartesian4NewYAxis;
    if (Cartesian3.magnitudeSquared(newXAxis) > CesiumMath.EPSILON10) {
    Cartesian3.cross(newZAxis, newXAxis, newYAxis);
    } else {
    var yAxis = Cartesian4.add(Matrix4.getColumn(camera._transform, 1, scratchCartesian3), origin, scratchCartesian3);
    ellipsoid.cartesianToCartographic(yAxis, cartographic);
    
    projection.project(cartographic, projectedPosition);
    newYAxis.x = projectedPosition.z;
    newYAxis.y = projectedPosition.x;
    newYAxis.z = projectedPosition.y;
    newYAxis.w = 0.0;
    
    Cartesian3.subtract(newYAxis, newOrigin, newYAxis);
    newYAxis.x = 0.0;
    
    if (Cartesian3.magnitudeSquared(newYAxis) < CesiumMath.EPSILON10) {
    Cartesian4.clone(Cartesian4.UNIT_Y, newXAxis);
    Cartesian4.clone(Cartesian4.UNIT_Z, newYAxis);
    }
    }
    
    Cartesian3.cross(newYAxis, newZAxis, newXAxis);
    Cartesian3.normalize(newXAxis, newXAxis);
    Cartesian3.cross(newZAxis, newXAxis, newYAxis);
    Cartesian3.normalize(newYAxis, newYAxis);
    
    Matrix4.setColumn(camera._actualTransform, 0, newXAxis, camera._actualTransform);
    Matrix4.setColumn(camera._actualTransform, 1, newYAxis, camera._actualTransform);
    Matrix4.setColumn(camera._actualTransform, 2, newZAxis, camera._actualTransform);
    Matrix4.setColumn(camera._actualTransform, 3, newOrigin, camera._actualTransform);
    }
    
    */
    func updateMembers() {
        
        var heightChanged = false
        var height = 0.0
        if _mode == .Scene2D {
            height = frustum.right - frustum.left;
            heightChanged = height != _positionCartographic.height
        }
        
        let positionChanged = _position != position || heightChanged
        if positionChanged {
            _position = position
        }
        
        let directionChanged = _direction != direction
        if directionChanged {
            _direction = direction
        }
        
        let upChanged = _up != up
        if upChanged {
            _up = up
        }
        
        let rightChanged = _right != right
        if rightChanged {
            _right = right
        }
        
        let transformChanged = _transformChanged || _modeChanged
        _transformChanged = false
        
        if transformChanged {
            _invTransform = _transform.inverseTransformation()
            
            if _mode == .ColumbusView || _mode == .Scene2D {
                if _transform.equals(Matrix4.identity()) {
                    _actualTransform = transform2D
                } else if _mode == .ColumbusView {
                    assert(false, "unimplemented")
                    /*convertTransformForColumbusView(camera);
                    } else {
                    convertTransformFor2D(camera);*/
                }
            } else {
                _actualTransform = _transform
            }
            _actualInvTransform = _actualTransform.inverseTransformation()
            _modeChanged = false
        }
        
        if positionChanged || transformChanged {
            _positionWC = _actualTransform.multiplyByPoint(_position)
            
            // Compute the Cartographic position of the camera.
            if _mode == .Scene3D || _mode == .Morphing {
                if let positionCartographic = _projection.ellipsoid.cartesianToCartographic(_positionWC) {
                    _positionCartographic = positionCartographic
                }
            } else {
                // The camera position is expressed in the 2D coordinate system where the Y axis is to the East,
                // the Z axis is to the North, and the X axis is out of the map.  Express them instead in the ENU axes where
                // X is to the East, Y is to the North, and Z is out of the local horizontal plane.
                var positionENU = Cartesian3(x: _positionWC.y, y: _positionWC.z, z: _positionWC.x)
                
                // In 2D, the camera height is always 12.7 million meters.
                // The apparent height is equal to half the frustum width.
                if _mode == .Scene2D {
                    positionENU.z = height
                }
                _positionCartographic = _projection.unproject(positionENU)
            }
        }
        
        if directionChanged || upChanged || rightChanged {
            let det = _direction.dot(up.cross(right))
            if abs(1.0 - det) > Math.Epsilon2 {
                //orthonormalize axes
                direction = _direction.normalize()
                
                let invUpMag = 1.0 / up.magnitudeSquared()
                let w0 = direction.multiplyByScalar(up.dot(direction) * invUpMag)
                _up = up.subtract(w0).normalize()
                up = _up
                
                _right = direction.cross(up)
                right = _right
            }
        }
        
        if directionChanged || transformChanged {
            _directionWC = _actualTransform.multiplyByPointAsVector(direction)
        }
        
        if upChanged || transformChanged {
            _upWC = _actualTransform.multiplyByPointAsVector(up)
        }
        
        if rightChanged || transformChanged {
            _rightWC = _actualTransform.multiplyByPointAsVector(right)
        }
        
        if positionChanged || directionChanged || upChanged || rightChanged || transformChanged {
            updateViewMatrix()
        }
    }
    
    func getHeading (direction direction: Cartesian3, up: Cartesian3) -> Double {
        let heading: Double
        if !Math.equalsEpsilon(abs(direction.z), 1.0, relativeEpsilon: Math.Epsilon3) {
            heading = atan2(direction.y, direction.x) - M_PI_2
        } else {
            heading = atan2(up.y, up.x) - M_PI_2
        }
        return M_2_PI - Math.zeroToTwoPi(heading)
    }
    
    func getPitch(direction direction: Cartesian3) -> Double {
        return M_PI_2 - Math.acosClamped(direction.z)
    }
    
    func getRoll (direction direction: Cartesian3, up: Cartesian3, right: Cartesian3) -> Double {
        var roll = 0.0
        if Math.equalsEpsilon(abs(direction.z), 1.0, relativeEpsilon: Math.Epsilon3) {
            roll = Math.zeroToTwoPi(atan2(-right.z, up.z) + M_2_PI)
        }
        return roll
    }
    
    
    
    
    //var scratchUpdateCartographic = new Cartographic(Math.PI, CesiumMath.PI_OVER_TWO);
    /**
    * @private
    */
    func update (mode: SceneMode) {
        var updateFrustum = false
        
        if mode != _mode {
            _mode = mode
            _modeChanged = mode != .Morphing
            updateFrustum = _mode == .Scene2D
        }
        
        if updateFrustum {
            // FIXME: updateFrustum
            /*_max2Dfrustum = frustum
            var frustum = this._max2Dfrustum = this.frustum.clone()
            
            //>>includeStart('debug', pragmas.debug);
            if (!defined(frustum.left) || !defined(frustum.right) ||
            !defined(frustum.top) || !defined(frustum.bottom)) {
            throw new DeveloperError('The camera frustum is expected to be orthographic for 2D camera control.');
            }
            //>>includeEnd('debug');
            
            var maxZoomOut = 2.0;
            var ratio = frustum.top / frustum.right;
            frustum.right = this._maxCoord.x * maxZoomOut;
            frustum.left = -frustum.right;
            frustum.top = ratio * frustum.right;
            frustum.bottom = -frustum.top;*/
        }
    }
    
    func _setTransform (transform: Matrix4) {
        let position = positionWC
        let up = upWC
        let direction = directionWC
        
        _transform = transform
        _transformChanged = true
        updateMembers()
        let inverse = _actualInvTransform
        
        self.position = inverse.multiplyByPoint(position)
        self.direction = inverse.multiplyByPointAsVector(direction)
        self.up = inverse.multiplyByPointAsVector(up)
        self.right = direction.cross(up)
    }
    
    private func setView3D(
        position cartesianIn: Cartesian3? = nil,
        positionCartographic cartographicIn: Cartographic? = nil,
        heading headingIn: Double? = nil,
        pitch pitchIn: Double? = nil,
        roll rollIn: Double? = nil,
        ellipsoid: Ellipsoid? = nil)
    {
        
        let cartesian: Cartesian3
        
        if cartesianIn == nil {
            if cartographicIn != nil {
                cartesian = (ellipsoid ?? _projection.ellipsoid).cartographicToCartesian(cartographicIn!)
            } else {
                cartesian = positionWC
            }
        } else {
            cartesian = cartesianIn!
        }
        
        let currentTransform = transform
        let localTransform = Transforms.eastNorthUpToFixedFrame(cartesian, ellipsoid: ellipsoid ?? _projection.ellipsoid)
        _setTransform(localTransform)
        
        position = Cartesian3.zero()
        
        let rotQuat = Quaternion(fromHeading: heading! - M_PI_2, pitch: pitch!, roll: roll!)
        let rotMat = Matrix3(fromQuaternion: rotQuat)
        
        direction = rotMat.column(0)
        up = rotMat.column(2)
        
        right = direction.cross(up)
        
        _setTransform(currentTransform)
    }
    
    private func setViewCV(
        position cartesianIn: Cartesian3? = nil,
        positionCartographic cartographicIn: Cartographic? = nil,
        heading headingIn: Double? = nil,
        pitch pitchIn: Double? = nil,
        roll rollIn: Double? = nil,
        ellipsoid: Ellipsoid,
        projection: MapProjection)
    {
        
        let currentTransform = transform
        _setTransform(Matrix4.identity())
        
        var cartesian: Cartesian3! = cartesianIn
        var cartographic: Cartographic! = cartographicIn
        
        if cartesianIn != nil && cartesianIn! != positionWC {
            cartographic = ellipsoid.cartesianToCartographic(cartesianIn!)
        }
        
        if cartographic != nil {
            cartesian = projection.project(cartographic)
        }
        position = cartesian
        
        let rotQuat = Quaternion(fromHeading: heading! - M_PI_2, pitch: pitch!, roll: roll!)
        let rotMat = Matrix3(fromQuaternion: rotQuat)
        
        direction = rotMat.column(0)
        up = rotMat.column(2)
        
        right = direction.cross(up)
        
        _setTransform(currentTransform)
    }
    
    private func setView2D(
        position cartesianIn: Cartesian3? = nil,
        positionCartographic cartographicIn: Cartographic? = nil,
        heading headingIn: Double? = nil,
        pitch pitchIn: Double? = nil,
        roll rollIn: Double? = nil,
        ellipsoid: Ellipsoid,
        projection: MapProjection)
    {
        var pitch = -M_PI_2
        var roll = 0.0
        
        var cartesian: Cartesian3! = cartesianIn
        var cartographic: Cartographic! = cartographicIn
        
        let currentTransform = transform
        _setTransform(Matrix4.identity())
        
        if cartesian != nil && cartesian! != positionWC {
            cartographic = ellipsoid.cartesianToCartographic(cartesian)
        }
        
        if cartographic != nil {
            cartesian = projection.project(cartographic)
            position = cartesian
            
            let newLeft = -cartographic.height * 0.5
            let newRight = -newLeft
            
            if (newRight > newLeft) {
                let ratio = frustum.top / frustum.right
                frustum.right = newRight
                frustum.left = newLeft
                frustum.top = frustum.right * ratio
                frustum.bottom = -frustum.top
            }
        }
        
        let rotQuat = Quaternion(fromHeading: heading! - M_PI_2, pitch: pitch, roll: roll)
        let rotMat = Matrix3(fromQuaternion: rotQuat)
        
        direction = rotMat.column(0)
        up = rotMat.column(2)
        
        right = direction.cross(up)
        
        _setTransform(currentTransform)
    }
    
    /**
     * Sets the camera position and orientation with heading, pitch and roll angles.
     *
     * The position can be given as either a cartesian or a cartographic. If both are given,
     * then the cartesian will be used. If neither is given, then the current camera position
     * will be used.
     *
     * @param {Object} options Object with the following properties:
     * @param {Cartesian3} [options.position] The cartesian position of the camera.
     * @param {Cartographic} [options.positionCartographic] The cartographic position of the camera.
     * @param {Number} [options.heading] The heading in radians or the current heading will be used if undefined.
     * @param {Number} [options.pitch] The pitch in radians or the current pitch will be used if undefined.
     * @param {Number} [options.roll] The roll in radians or the current roll will be used if undefined.
     *
     * @example
     * // 1. Set view with heading, pitch and roll
     * camera.setView({
     *     position : cartesianPosition,
     *     heading : Cesium.Math.toRadians(90.0), // east, default value is 0.0 (north)
     *     pitch : Cesium.Math.toRadians(-90),    // default value (looking down)
     *     roll : 0.0                             // default value
     * });
     *
     * // 2. Set default top-down view with a cartographic position
     * camera.setView({
     *     positionCartographic : cartographic
     * });
     *
     * // 3. Change heading, pitch and roll with the camera position remaining the same.
     * camera.setView({
     *     heading : Cesium.Math.toRadians(90.0), // east, default value is 0.0 (north)
     *     pitch : Cesium.Math.toRadians(-90),    // default value (looking down)
     *     roll : 0.0                             // default value
     * });
     */
    func setView (
        position cartesianIn: Cartesian3? = nil,
        positionCartographic cartographicIn: Cartographic? = nil,
        heading headingIn: Double? = nil,
        pitch pitchIn: Double? = nil,
        roll rollIn: Double? = nil)
    {
        if _mode == .Morphing {
            return
        }
        
        let heading = headingIn ?? self.heading
        let pitch = pitchIn ?? self.pitch
        let roll = rollIn ?? self.roll
        
        let projection = _projection
        let ellipsoid = projection.ellipsoid
        
        if _mode == .Scene3D {
            setView3D(position: cartesianIn, positionCartographic: cartographicIn, heading: heading, pitch: pitch, roll: roll, ellipsoid: ellipsoid)
        } else if _mode == SceneMode.Scene2D {
            setView2D(position: cartesianIn, positionCartographic: cartographicIn, heading: heading, pitch: pitch, roll: roll, ellipsoid: ellipsoid, projection: projection)
        } else {
            setViewCV(position: cartesianIn, positionCartographic: cartographicIn, heading: heading, pitch: pitch, roll: roll, ellipsoid: ellipsoid, projection: projection)
        }
    }
    
    /**
     * Transform a vector or point from world coordinates to the camera's reference frame.
     * @memberof Camera
     *
     * @param {Cartesian4} cartesian The vector or point to transform.
     * @param {Cartesian4} [result] The object onto which to store the result.
     *
     * @returns {Cartesian4} The transformed vector or point.
     */
    func worldToCameraCoordinates(cartesian: Cartesian4) -> Cartesian4 {
        updateMembers()
        return _actualInvTransform.multiplyByVector(cartesian)
    }
    /*
    /**
    * Transform a point from world coordinates to the camera's reference frame.
    * @memberof Camera
    *
    * @param {Cartesian3} cartesian The point to transform.
    * @param {Cartesian3} [result] The object onto which to store the result.
    *
    * @returns {Cartesian3} The transformed point.
    */
    Camera.prototype.worldToCameraCoordinatesPoint = function(cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    updateMembers(this);
    return Matrix4.multiplyByPoint(this._actualInvTransform, cartesian, result);
    };
    
    /**
    * Transform a vector from world coordinates to the camera's reference frame.
    * @memberof Camera
    *
    * @param {Cartesian3} cartesian The vector to transform.
    * @param {Cartesian3} [result] The object onto which to store the result.
    *
    * @returns {Cartesian3} The transformed vector.
    */
    Camera.prototype.worldToCameraCoordinatesVector = function(cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    updateMembers(this);
    return Matrix4.multiplyByPointAsVector(this._actualInvTransform, cartesian, result);
    };
    
    /**
    * Transform a vector or point from the camera's reference frame to world coordinates.
    * @memberof Camera
    *
    * @param {Cartesian4} cartesian The vector or point to transform.
    * @param {Cartesian4} [result] The object onto which to store the result.
    *
    * @returns {Cartesian4} The transformed vector or point.
    */
    Camera.prototype.cameraToWorldCoordinates = function(cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    updateMembers(this);
    return Matrix4.multiplyByVector(this._actualTransform, cartesian, result);
    };
    
    /**
    * Transform a point from the camera's reference frame to world coordinates.
    * @memberof Camera
    *
    * @param {Cartesian3} cartesian The point to transform.
    * @param {Cartesian3} [result] The object onto which to store the result.
    *
    * @returns {Cartesian3} The transformed point.
    */
    Camera.prototype.cameraToWorldCoordinatesPoint = function(cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    updateMembers(this);
    return Matrix4.multiplyByPoint(this._actualTransform, cartesian, result);
    };
    
    /**
    * Transform a vector from the camera's reference frame to world coordinates.
    * @memberof Camera
    *
    * @param {Cartesian3} cartesian The vector to transform.
    * @param {Cartesian3} [result] The object onto which to store the result.
    *
    * @returns {Cartesian3} The transformed vector.
    */
    Camera.prototype.cameraToWorldCoordinatesVector = function(cartesian, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    updateMembers(this);
    return Matrix4.multiplyByPointAsVector(this._actualTransform, cartesian, result);
    };
    
    function clampMove2D(camera, position) {
    var maxX = camera._maxCoord.x * camera.maximumTranslateFactor;
    if (position.x > maxX) {
    position.x = maxX;
    }
    if (position.x < -maxX) {
    position.x = -maxX;
    }
    
    var maxY = camera._maxCoord.y * camera.maximumTranslateFactor;
    if (position.y > maxY) {
    position.y = maxY;
    }
    if (position.y < -maxY) {
    position.y = -maxY;
    }
    }
    */
    
    /**
    * Translates the camera's position by <code>amount</code> along <code>direction</code>.
    *
    * @memberof Camera
    *
    * @param {Cartesian3} direction The direction to move.
    * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
    *
    * @see Camera#moveBackward
    * @see Camera#moveForward
    * @see Camera#moveLeft
    * @see Camera#moveRight
    * @see Camera#moveUp
    * @see Camera#moveDown
    */
    func move (direction: Cartesian3, amount: Double) {
        var cameraPosition = position
        position = position.add(direction.multiplyByScalar(amount))
        if _mode == SceneMode.Scene2D {
            assertionFailure("unimplemented")
            //clampMove2D(this, cameraPosition);
        }
    }
    
    /**
     * Translates the camera's position by <code>amount</code> along the camera's view vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
     *
     * @see Camera#moveBackward
     */
     /*Camera.prototype.moveForward = function(amount) {
     amount = defaultValue(amount, this.defaultMoveAmount);
     this.move(this.direction, amount);
     };*/
     
     /**
     * Translates the camera's position by <code>amount</code> along the opposite direction
     * of the camera's view vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
     *
     * @see Camera#moveForward
     */
     /*Camera.prototype.moveBackward = function(amount) {
     amount = defaultValue(amount, this.defaultMoveAmount);
     this.move(this.direction, -amount);
     };
     
     /**
     * Translates the camera's position by <code>amount</code> along the camera's up vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
     *
     * @see Camera#moveDown
     */
     Camera.prototype.moveUp = function(amount) {
     amount = defaultValue(amount, this.defaultMoveAmount);
     this.move(this.up, amount);
     };
     
     /**
     * Translates the camera's position by <code>amount</code> along the opposite direction
     * of the camera's up vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
     *
     * @see Camera#moveUp
     */
     Camera.prototype.moveDown = function(amount) {
     amount = defaultValue(amount, this.defaultMoveAmount);
     this.move(this.up, -amount);
     };
     
     /**
     * Translates the camera's position by <code>amount</code> along the camera's right vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
     *
     * @see Camera#moveLeft
     */
     Camera.prototype.moveRight = function(amount) {
     amount = defaultValue(amount, this.defaultMoveAmount);
     this.move(this.right, amount);
     };
     
     /**
     * Translates the camera's position by <code>amount</code> along the opposite direction
     * of the camera's right vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
     *
     * @see Camera#moveRight
     */
     Camera.prototype.moveLeft = function(amount) {
     amount = defaultValue(amount, this.defaultMoveAmount);
     this.move(this.right, -amount);
     };
     
     /**
     * Rotates the camera around its up vector by amount, in radians, in the opposite direction
     * of its right vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
     *
     * @see Camera#lookRight
     */
     Camera.prototype.lookLeft = function(amount) {
     amount = defaultValue(amount, this.defaultLookAmount);
     this.look(this.up, -amount);
     };
     
     /**
     * Rotates the camera around its up vector by amount, in radians, in the direction
     * of its right vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
     *
     * @see Camera#lookLeft
     */
     Camera.prototype.lookRight = function(amount) {
     amount = defaultValue(amount, this.defaultLookAmount);
     this.look(this.up, amount);
     };
     */
     /**
     * Rotates the camera around its right vector by amount, in radians, in the direction
     * of its up vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
     *
     * @see Camera#lookDown
     */
    public func lookUp (amount: Double?) {
        look(axis: right, angle: -(amount ?? defaultLookAmount))
    }
    /*
    /**
    * Rotates the camera around its right vector by amount, in radians, in the opposite direction
    * of its up vector.
    *
    * @memberof Camera
    *
    * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
    *
    * @see Camera#lookUp
    */
    Camera.prototype.lookDown = function(amount) {
    amount = defaultValue(amount, this.defaultLookAmount);
    this.look(this.right, amount);
    };
    */
    
    /**
    * Rotate each of the camera's orientation vectors around <code>axis</code> by <code>angle</code>
    *
    * @memberof Camera
    *
    * @param {Cartesian3} axis The axis to rotate around.
    * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
    *
    * @see Camera#lookUp
    * @see Camera#lookDown
    * @see Camera#lookLeft
    * @see Camera#lookRight
    */
    public func look (axis axis: Cartesian3, angle: Double? = nil) {
        
        let turnAngle = angle ?? defaultLookAmount
        let quaternion = Quaternion(fromAxis: axis, angle: -turnAngle)
        let rotation = Matrix3(fromQuaternion: quaternion)
        
        direction = rotation.multiplyByVector(direction)
        up = rotation.multiplyByVector(up)
        right = rotation.multiplyByVector(right)
    }
    /*
    /**
    * Rotate the camera counter-clockwise around its direction vector by amount, in radians.
    *
    * @memberof Camera
    *
    * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
    *
    * @see Camera#twistRight
    */
    Camera.prototype.twistLeft = function(amount) {
    amount = defaultValue(amount, this.defaultLookAmount);
    this.look(this.direction, amount);
    };
    
    /**
    * Rotate the camera clockwise around its direction vector by amount, in radians.
    *
    * @memberof Camera
    *
    * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
    *
    * @see Camera#twistLeft
    */
    Camera.prototype.twistRight = function(amount) {
    amount = defaultValue(amount, this.defaultLookAmount);
    this.look(this.direction, -amount);
    };
    */
    
    /**
    * Rotates the camera around <code>axis</code> by <code>angle</code>. The distance
    * of the camera's position to the center of the camera's reference frame remains the same.
    *
    * @memberof Camera
    *
    * @param {Cartesian3} axis The axis to rotate around given in world coordinates.
    * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
    *
    * @see Camera#rotateUp
    * @see Camera#rotateDown
    * @see Camera#rotateLeft
    * @see Camera#rotateRight
    *
    * @example
    * // Rotate about a point on the earth.
    * var center = ellipsoid.cartographicToCartesian(cartographic);
    * camera.rotate(axis, angle);
    */
    func rotate (axis: Cartesian3, angle: Double? = nil) {
        
        let turnAngle = angle ?? defaultRotateAmount
        let quaternion = Quaternion(fromAxis: axis, angle: -turnAngle)
        let rotation = Matrix3(fromQuaternion: quaternion)
        position = rotation.multiplyByVector(position)
        direction = rotation.multiplyByVector(direction)
        up = rotation.multiplyByVector(up)
        right = direction.cross(up)
        up = right.cross(direction)
    }
    /*
    /**
    * Rotates the camera around the center of the camera's reference frame by angle downwards.
    *
    * @memberof Camera
    *
    * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
    * @param {Matrix4} [transform] A transform to append to the camera transform before the rotation. Does not alter the camera's transform.
    *
    * @see Camera#rotateUp
    * @see Camera#rotate
    */
    Camera.prototype.rotateDown = function(angle, transform) {
    angle = defaultValue(angle, this.defaultRotateAmount);
    rotateVertical(this, angle, transform);
    };
    */
    /**
    * Rotates the camera around the center of the camera's reference frame by angle upwards.
    *
    * @memberof Camera
    *
    * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
    *
    * @see Camera#rotateDown
    * @see Camera#rotate
    */
    func rotateUp (angle: Double?) {
        let rotateAngle = angle ?? defaultRotateAmount
        rotateVertical(-rotateAngle)
    }
    
    func rotateVertical(angle: Double) {
        
        var angle = angle
        let p = position.normalize()
        
        if constrainedAxis != nil {
            let northParallel = p.equalsEpsilon(constrainedAxis!, relativeEpsilon: Math.Epsilon2)
            let southParallel = p.equalsEpsilon(constrainedAxis!.negate(), relativeEpsilon: Math.Epsilon2)
            if !northParallel && !southParallel {
                let constrainedAxis = self.constrainedAxis!.normalize()
                var dot = p.dot(constrainedAxis)
                var angleToAxis = acos(dot)
                if angle > 0 && angle > angleToAxis {
                    angle = angleToAxis
                }
                
                dot = p.dot(constrainedAxis.negate())
                angleToAxis = acos(dot)
                if angle < 0 && -angle > angleToAxis {
                    angle = -angleToAxis
                }
                
                let tangent = constrainedAxis.cross(p)
                rotate(tangent, angle: angle)
            } else if (northParallel && angle < 0 || southParallel && angle > 0) {
                rotate(right, angle: angle)
            }
        } else {
            rotate(right, angle: angle)
        }
    }
    
    /**
     * Rotates the camera around the center of the camera's reference frame by angle to the right.
     *
     * @memberof Camera
     *
     * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
     * @param {Matrix4} [transform] A transform to append to the camera transform before the rotation. Does not alter the camera's transform.
     *
     * @see Camera#rotateLeft
     * @see Camera#rotate
     */
    func rotateRight (angle: Double) {
        rotateHorizontal(-angle)
    }
    /*
    /**
    * Rotates the camera around the center of the camera's reference frame by angle to the left.
    *
    * @memberof Camera
    *
    * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
    *
    * @see Camera#rotateRight
    * @see Camera#rotate
    */
    Camera.prototype.rotateLeft = function(angle) {
    angle = defaultValue(angle, this.defaultRotateAmount);
    rotateHorizontal(this, angle);
    };
    */
    
    func rotateHorizontal(angle: Double) {
        if constrainedAxis != nil {
            rotate(constrainedAxis!, angle: angle)
        } else {
            rotate(up, angle: angle)
        }
    }
    
    func zoom2D(amount: Double) {
        assertionFailure("unimplemented")
        /*var frustum = camera.frustum;
        
        //>>includeStart('debug', pragmas.debug);
        if (!defined(frustum.left) || !defined(frustum.right) || !defined(frustum.top) || !defined(frustum.bottom)) {
        throw new DeveloperError('The camera frustum is expected to be orthographic for 2D camera control.');
        }
        //>>includeEnd('debug');
        
        amount = amount * 0.5;
        var newRight = frustum.right - amount;
        var newLeft = frustum.left + amount;
        
        var maxRight = camera._maxCoord.x * camera.maximumZoomFactor;
        if (newRight > maxRight) {
        newRight = maxRight;
        newLeft = -maxRight;
        }
        
        if (newRight <= newLeft) {
        newRight = 1.0;
        newLeft = -1.0;
        }
        
        var ratio = frustum.top / frustum.right;
        frustum.right = newRight;
        frustum.left = newLeft;
        frustum.top = frustum.right * ratio;
        frustum.bottom = -frustum.top;*/
    }
    
    func zoom3D(amount: Double) {
        move(direction, amount: amount)
    }
    
    /**
     * Zooms <code>amount</code> along the camera's view vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount to move. Defaults to <code>defaultZoomAmount</code>.
     *
     * @see Camera#zoomOut
     */
    public func zoomIn (amount: Double? = nil) {
        let amount = amount ?? defaultZoomAmount
        if _mode == .Scene2D {
            zoom2D(amount)
        } else {
            zoom3D(amount)
        }
    }
    
    /**
     * Zooms <code>amount</code> along the opposite direction of
     * the camera's view vector.
     *
     * @memberof Camera
     *
     * @param {Number} [amount] The amount to move. Defaults to <code>defaultZoomAmount</code>.
     *
     * @see Camera#zoomIn
     */
     /*Camera.prototype.zoomOut = function(amount) {
     amount = defaultValue(amount, this.defaultZoomAmount);
     if (this._mode === SceneMode.SCENE2D) {
     zoom2D(this, -amount);
     } else {
     zoom3D(this, -amount);
     }
     };
     
     /**
     * Gets the magnitude of the camera position. In 3D, this is the vector magnitude. In 2D and
     * Columbus view, this is the distance to the map.
     *
     * @memberof Camera
     *
     * @returns {Number} The magnitude of the position.
     */
     Camera.prototype.getMagnitude = function() {
     if (this._mode === SceneMode.SCENE3D) {
     return Cartesian3.magnitude(this.position);
     } else if (this._mode === SceneMode.COLUMBUS_VIEW) {
     return Math.abs(this.position.z);
     } else if (this._mode === SceneMode.SCENE2D) {
     return  Math.max(this.frustum.right - this.frustum.left, this.frustum.top - this.frustum.bottom);
     }
     };
     */
     
     /**
     * Sets the camera position and orientation using a target and offset. The target must be given in
     * world coordinates. The offset can be either a cartesian or heading/pitch/range in the local east-north-up reference frame centered at the target.
     * If the offset is a cartesian, then it is an offset from the center of the reference frame defined by the transformation matrix. If the offset
     * is heading/pitch/range, then the heading and the pitch angles are defined in the reference frame defined by the transformation matrix.
     * The heading is the angle from y axis and increasing towards the x axis. Pitch is the rotation from the xy-plane. Positive pitch
     * angles are above the plane. Negative pitch angles are below the plane. The range is the distance from the center.
     *
     * In 2D, there must be a top down view. The camera will be placed above the target looking down. The height above the
     * target will be the magnitude of the offset. The heading will be determined from the offset. If the heading cannot be
     * determined from the offset, the heading will be north.
     *
     * @param {Cartesian3} target The target position in world coordinates.
     * @param {Cartesian3|HeadingPitchRange} offset The offset from the target in the local east-north-up reference frame centered at the target.
     *
     * @exception {DeveloperError} lookAt is not supported while morphing.
     *
     * @example
     * // 1. Using a cartesian offset
     * var center = Cesium.Cartesian3.fromDegrees(-98.0, 40.0);
     * viewer.camera.lookAt(center, new Cesium.Cartesian3(0.0, -4790000.0, 3930000.0));
     *
     * // 2. Using a HeadingPitchRange offset
     * var center = Cartesian3.fromDegrees(-72.0, 40.0);
     * var heading = Cesium.Math.toRadians(50.0);
     * var pitch = Cesium.Math.toRadians(-20.0);
     * var range = 5000.0;
     * viewer.camera.lookAt(center, new Cesium.HeadingPitchRange(heading, pitch, range));
     */
    public func lookAt (target: Cartesian3, offsetCartesian: Cartesian3? = nil, offsetHPR: HeadingPitchRange? = nil) {
        
        let transform = Transforms.eastNorthUpToFixedFrame(target, ellipsoid: Ellipsoid.wgs84())
        lookAtTransform(transform, offsetCartesian: offsetCartesian, offsetHPR: offsetHPR)
    }
    
    func offsetFromHeadingPitchRange(heading: Double, pitch: Double, range: Double) -> Cartesian3 {
        let clampPitch = Math.clamp(pitch, min: -M_PI_2, max: M_PI_2)
        let clampHeading = Math.zeroToTwoPi(heading) - M_PI_2
        
        let pitchQuat = Quaternion(fromAxis: Cartesian3.unitY(), angle: -clampPitch)
        let headingQuat = Quaternion(fromAxis: Cartesian3.unitZ(), angle: -clampHeading)
        let rotQuat = pitchQuat.multiply(headingQuat)
        let rotMatrix = Matrix3(fromQuaternion: rotQuat)
        
        return rotMatrix.multiplyByVector(Cartesian3.unitX()).negate().multiplyByScalar(range)
    }
    
    /**
     -     * Sets the camera position and orientation with an eye position, target, and up vector.
     -     * This method is not supported in 2D mode because there is only one direction to look.
     * Sets the camera position and orientation using a target and transformation matrix. The offset can be either a cartesian or heading/pitch/range.
     * If the offset is a cartesian, then it is an offset from the center of the reference frame defined by the transformation matrix. If the offset
     * is heading/pitch/range, then the heading and the pitch angles are defined in the reference frame defined by the transformation matrix.
     * The heading is the angle from y axis and increasing towards the x axis. Pitch is the rotation from the xy-plane. Positive pitch
     * angles are above the plane. Negative pitch angles are below the plane. The range is the distance from the center.
     *
     -     * @param {Cartesian3} eye The position of the camera.
     -     * @param {Cartesian3} target The position to look at.
     -     * @param {Cartesian3} up The up vector.
     * In 2D, there must be a top down view. The camera will be placed above the center of the reference frame. The height above the
     * target will be the magnitude of the offset. The heading will be determined from the offset. If the heading cannot be
     * determined from the offset, the heading will be north.
     *
     -     * @exception {DeveloperError} lookAt is not supported while morphing.
     * @param {Matrix4} transform The transformation matrix defining the reference frame.
     * @param {Cartesian3|HeadingPitchRange} offset The offset from the target in a reference frame centered at the target.
     *
     * @exception {DeveloperError} lookAtTransform is not supported while morphing.
     *
     * @example
     * // 1. Using a cartesian offset
     * var transform = Cesium.Transforms.eastNorthUpToFixedFrame(Cesium.Cartesian3.fromDegrees(-98.0, 40.0));
     * viewer.camera.lookAtTransform(transform, new Cesium.Cartesian3(0.0, -4790000.0, 3930000.0));
     *
     * // 2. Using a HeadingPitchRange offset
     * var transform = Cesium.Transforms.eastNorthUpToFixedFrame(Cartesian3.fromDegrees(-72.0, 40.0));
     * var heading = Cesium.Math.toRadians(50.0);
     * var pitch = Cesium.Math.toRadians(-20.0);
     * var range = 5000.0;
     * viewer.camera.lookAtTransform(transform, new Cesium.HeadingPitchRange(heading, pitch, range));
     */
    
    public func lookAtTransform (transform: Matrix4, offsetCartesian: Cartesian3? = nil, offsetHPR: HeadingPitchRange? = nil) {
        
        assert(_mode != .Morphing, "lookAtTransform is not supported while morphing.")
        
        _setTransform(transform)
        
        if offsetCartesian == nil && offsetHPR == nil {
            return
        }
        
        let offset: Cartesian3
        if offsetCartesian == nil {
            offset = offsetFromHeadingPitchRange(offsetHPR!.heading, pitch: offsetHPR!.pitch, range: offsetHPR!.range)
        } else {
            offset = offsetCartesian!
        }
        
        if _mode == .Scene2D {
            position.x = 0.0
            position.y = 0.0
            
            up = offset.negate()
            up.z = 0.0
            
            if up.magnitudeSquared() < Math.Epsilon10 {
                up = Cartesian3.unitY()
            }
            
            up = up.normalize()
            
            _setTransform(Matrix4.identity())
            direction = Cartesian3.unitZ().negate()
            right = direction.cross(self.up).normalize()
            
            let ratio = frustum.top / frustum.right
            frustum.right = offset.magnitude() * 0.5
            frustum.left = -frustum.right
            frustum.top = ratio * frustum.right
            frustum.bottom = -frustum.top
            _setTransform(transform)
            
            return
        }
        position = offset
        direction = position.negate().normalize()
        right = direction.cross(Cartesian3.unitZ()).normalize()
        if right.magnitudeSquared() < Math.Epsilon10 {
            right = Cartesian3.unitX()
        }
        up = right.cross(direction).normalize()
    }
    
    /*
    var viewRectangle3DCartographic1 = new Cartographic();
    var viewRectangle3DCartographic2 = new Cartographic();
    var viewRectangle3DNorthEast = new Cartesian3();
    var viewRectangle3DSouthWest = new Cartesian3();
    var viewRectangle3DNorthWest = new Cartesian3();
    var viewRectangle3DSouthEast = new Cartesian3();
    var viewRectangle3DNorthCenter = new Cartesian3();
    var viewRectangle3DSouthCenter = new Cartesian3();
    var viewRectangle3DCenter = new Cartesian3();
    var viewRectangle3DEquator = new Cartesian3();
    var defaultRF = {direction: new Cartesian3(), right: new Cartesian3(), up: new Cartesian3()};*/
    var viewRectangle3DEllipsoidGeodesic: EllipsoidGeodesic! = nil
    
    private struct DefaultRF: DRU {
        var direction: Cartesian3
        var right: Cartesian3
        var up: Cartesian3
    }
    
    func rectangleCameraPosition3D (rectangle: Rectangle, ellipsoid: Ellipsoid, positionOnly: Bool = false) -> Cartesian3 {
        
        var cameraRF: DRU = self
        if positionOnly {
            cameraRF = DefaultRF(direction: Cartesian3(), right: Cartesian3(), up: Cartesian3())
        }
        
        var north = rectangle.north
        var south = rectangle.south
        var east = rectangle.east
        var west = rectangle.west
        
        // If we go across the International Date Line
        if (west > east) {
            east += M_2_PI
        }
        
        // Find the midpoint latitude.
        //
        // EllipsoidGeodesic will fail if the north and south edges are very close to being on opposite sides of the ellipsoid.
        // Ideally we'd just call EllipsoidGeodesic.setEndPoints and let it throw when it detects this case, but sadly it doesn't
        // even look for this case in optimized builds, so we have to test for it here instead.
        //
        // Fortunately, this case can only happen (here) when north is very close to the north pole and south is very close to the south pole,
        // so handle it just by using 0 latitude as the center.  It's certainliy possible to use a smaller tolerance
        // than one degree here, but one degree is safe and putting the center at 0 latitude should be good enough for any
        // rectangle that spans 178+ of the 180 degrees of latitude.
        let longitude = (west + east) * 0.5
        let latitude: Double
        if south < -M_PI_2 + Math.RadiansPerDegree && north > M_PI_2 - Math.RadiansPerDegree {
            latitude = 0.0
        } else {
            var northCartographic = Cartographic(longitude: longitude, latitude: north, height: 0.0)
            var southCartographic = Cartographic(longitude: longitude, latitude: south, height: 0.0)
            
            var ellipsoidGeodesic = viewRectangle3DEllipsoidGeodesic
            if ellipsoidGeodesic == nil || ellipsoidGeodesic.ellipsoid != ellipsoid {
                ellipsoidGeodesic = EllipsoidGeodesic(ellipsoid: ellipsoid)
                viewRectangle3DEllipsoidGeodesic = ellipsoidGeodesic
            }
            
            ellipsoidGeodesic.setEndPoints(start: northCartographic, end: southCartographic)
            latitude = ellipsoidGeodesic.interpolateUsingFraction(0.5).latitude
        }
        
        let centerCartographic = Cartographic(longitude: longitude, latitude: latitude)
        
        let center = ellipsoid.cartographicToCartesian(centerCartographic)
        
        var cart = Cartographic(longitude: east, latitude: north)
        
        var northEast = ellipsoid.cartographicToCartesian(cart)
        cart.longitude = west
        var northWest = ellipsoid.cartographicToCartesian(cart)
        cart.longitude = longitude
        var northCenter = ellipsoid.cartographicToCartesian(cart)
        cart.latitude = south
        var southCenter = ellipsoid.cartographicToCartesian(cart)
        cart.longitude = east
        var southEast = ellipsoid.cartographicToCartesian(cart)
        cart.longitude = west;
        var southWest = ellipsoid.cartographicToCartesian(cart)
        
        northWest = northWest.subtract(center)
        southEast = southEast.subtract(center)
        northEast = northEast.subtract(center)
        southWest = southWest.subtract(center)
        northCenter = northCenter.subtract(center)
        southCenter = southCenter.subtract(center)
        
        let direction = ellipsoid.geodeticSurfaceNormal(center).negate()
        cameraRF.direction = direction
        let right = direction.cross(Cartesian3.unitZ()).normalize()
        cameraRF.right = right
        let up = right.cross(direction)
        cameraRF.up = up
        
        var tanPhi = tan(frustum.fovy * 0.5)
        var tanTheta = frustum.aspectRatio * tanPhi
        
        func computeD(direction: Cartesian3, upOrRight: Cartesian3, corner: Cartesian3, tanThetaOrPhi: Double) -> Double {
            let opposite = abs(upOrRight.dot(corner))
            return opposite / tanThetaOrPhi - direction.dot(corner)
        }
        
        var d = max(
            computeD(direction, upOrRight: up, corner: northWest, tanThetaOrPhi: tanPhi),
            computeD(direction, upOrRight: up, corner: southEast, tanThetaOrPhi: tanPhi),
            computeD(direction, upOrRight: up, corner: northEast, tanThetaOrPhi: tanPhi),
            computeD(direction, upOrRight: up, corner: southWest, tanThetaOrPhi: tanPhi),
            computeD(direction, upOrRight: up, corner: northCenter, tanThetaOrPhi: tanPhi),
            computeD(direction, upOrRight: up, corner: southCenter, tanThetaOrPhi: tanPhi),
            computeD(direction, upOrRight: right, corner: northWest, tanThetaOrPhi: tanTheta),
            computeD(direction, upOrRight: right, corner: southEast, tanThetaOrPhi: tanTheta),
            computeD(direction, upOrRight: right, corner: northEast, tanThetaOrPhi: tanTheta),
            computeD(direction, upOrRight: right, corner: southWest, tanThetaOrPhi: tanTheta),
            computeD(direction, upOrRight: right, corner: northCenter, tanThetaOrPhi: tanTheta),
            computeD(direction, upOrRight: right, corner: southCenter, tanThetaOrPhi: tanTheta)
        )
        
        // If the rectangle crosses the equator, compute D at the equator, too, because that's the
        // widest part of the rectangle when projected onto the globe.
        if south < 0 && north > 0 {
            var equatorCartographic = Cartographic(longitude: west, latitude: 0.0, height: 0.0)
            var equatorPosition = ellipsoid.cartographicToCartesian(equatorCartographic).subtract(center)
            d = max(
                d,
                computeD(direction, upOrRight: up, corner: equatorPosition, tanThetaOrPhi: tanPhi),
                computeD(direction, upOrRight: right, corner: equatorPosition, tanThetaOrPhi: tanTheta)
            )
            
            equatorCartographic.longitude = east
            equatorPosition = ellipsoid.cartographicToCartesian(equatorCartographic).subtract(center)
            d = max(d,
                computeD(direction, upOrRight: up, corner: equatorPosition, tanThetaOrPhi: tanPhi),
                computeD(direction, upOrRight: right, corner: equatorPosition, tanThetaOrPhi: tanTheta)
            )
        }
        return center.add(direction.multiplyByScalar(-d))
    }
    
    /*
    var viewRectangleCVCartographic = new Cartographic();
    var viewRectangleCVNorthEast = new Cartesian3();
    var viewRectangleCVSouthWest = new Cartesian3();
    function rectangleCameraPositionColumbusView(camera, rectangle, projection, result, positionOnly) {
    var north = rectangle.north;
    var south = rectangle.south;
    var east = rectangle.east;
    var west = rectangle.west;
    var transform = camera._actualTransform;
    var invTransform = camera._actualInvTransform;
    
    var cart = viewRectangleCVCartographic;
    cart.longitude = east;
    cart.latitude = north;
    var northEast = projection.project(cart, viewRectangleCVNorthEast);
    Matrix4.multiplyByPoint(transform, northEast, northEast);
    Matrix4.multiplyByPoint(invTransform, northEast, northEast);
    
    cart.longitude = west;
    cart.latitude = south;
    var southWest = projection.project(cart, viewRectangleCVSouthWest);
    Matrix4.multiplyByPoint(transform, southWest, southWest);
    Matrix4.multiplyByPoint(invTransform, southWest, southWest);
    
    var tanPhi = Math.tan(camera.frustum.fovy * 0.5);
    var tanTheta = camera.frustum.aspectRatio * tanPhi;
    if (!defined(result)) {
    result = new Cartesian3();
    }
    
    result.x = (northEast.x - southWest.x) * 0.5 + southWest.x;
    result.y = (northEast.y - southWest.y) * 0.5 + southWest.y;
    result.z = Math.max((northEast.x - southWest.x) / tanTheta, (northEast.y - southWest.y) / tanPhi) * 0.5;
    
    if (!positionOnly) {
    var direction = Cartesian3.clone(Cartesian3.UNIT_Z, camera.direction);
    Cartesian3.negate(direction, direction);
    Cartesian3.clone(Cartesian3.UNIT_X, camera.right);
    Cartesian3.clone(Cartesian3.UNIT_Y, camera.up);
    }
    
    return result;
    }
    
    var viewRectangle2DCartographic = new Cartographic();
    var viewRectangle2DNorthEast = new Cartesian3();
    var viewRectangle2DSouthWest = new Cartesian3();
    function rectangleCameraPosition2D (camera, rectangle, projection, result, positionOnly) {
    var north = rectangle.north;
    var south = rectangle.south;
    var east = rectangle.east;
    var west = rectangle.west;
    
    var cart = viewRectangle2DCartographic;
    cart.longitude = east;
    cart.latitude = north;
    var northEast = projection.project(cart, viewRectangle2DNorthEast);
    cart.longitude = west;
    cart.latitude = south;
    var southWest = projection.project(cart, viewRectangle2DSouthWest);
    
    var width = Math.abs(northEast.x - southWest.x) * 0.5;
    var height = Math.abs(northEast.y - southWest.y) * 0.5;
    
    var right, top;
    var ratio = camera.frustum.right / camera.frustum.top;
    var heightRatio = height * ratio;
    if (width > heightRatio) {
    right = width;
    top = right / ratio;
    } else {
    top = height;
    right = heightRatio;
    }
    
    height = Math.max(2.0 * right, 2.0 * top);
    
    if (!defined(result)) {
    result = new Cartesian3();
    }
    result.x = (northEast.x - southWest.x) * 0.5 + southWest.x;
    result.y = (northEast.y - southWest.y) * 0.5 + southWest.y;
    
    if (positionOnly) {
    cart = projection.unproject(result, cart);
    cart.height = height;
    result = projection.project(cart, result);
    } else {
    var frustum = camera.frustum;
    frustum.right = right;
    frustum.left = -right;
    frustum.top = top;
    frustum.bottom = -top;
    
    var direction = Cartesian3.clone(Cartesian3.UNIT_Z, camera.direction);
    Cartesian3.negate(direction, direction);
    Cartesian3.clone(Cartesian3.UNIT_X, camera.right);
    Cartesian3.clone(Cartesian3.UNIT_Y, camera.up);
    }
    
    return result;
    }
    /**
    * Get the camera position needed to view an rectangle on an ellipsoid or map
    *
    * @memberof Camera
    *
    * @param {Rectangle} rectangle The rectangle to view.
    * @param {Cartesian3} [result] The camera position needed to view the rectangle
    *
    * @returns {Cartesian3} The camera position needed to view the rectangle
    */
    Camera.prototype.getRectangleCameraCoordinates = function(rectangle, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(rectangle)) {
    throw new DeveloperError('rectangle is required');
    }
    //>>includeEnd('debug');
    
    if (this._mode === SceneMode.SCENE3D) {
    return rectangleCameraPosition3D(this, rectangle, this._projection.ellipsoid, result, true);
    } else if (this._mode === SceneMode.COLUMBUS_VIEW) {
    return rectangleCameraPositionColumbusView(this, rectangle, this._projection, result, true);
    } else if (this._mode === SceneMode.SCENE2D) {
    return rectangleCameraPosition2D(this, rectangle, this._projection, result, true);
    }
    
    return undefined;
    };
    */
    /**
    * View a rectangle on an ellipsoid or map.
    *
    * @memberof Camera
    *
    * @param {Rectangle} rectangle The rectangle to view.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid to view.
    */
    public func viewRectangle(rectangle: Rectangle, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        if _mode == .Scene3D {
            position = rectangleCameraPosition3D(rectangle, ellipsoid: ellipsoid)
        } else { assert(false, "not implemented") }/*if mode == .ColumbusView {
        rectangleCameraPositionColumbusView( rectangle, _projection, position)
        } else if mode == .Scene2D {
        rectangleCameraPosition2D(rectangle, _projection, position)
        }*/
    }
    
    func pickEllipsoid3D(windowPosition: Cartesian2, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) -> Cartesian3? {
        
        let ray = getPickRay(windowPosition)
        let intersection = IntersectionTests.rayEllipsoid(ray, ellipsoid: ellipsoid)
        if intersection == nil {
            return nil
        }
        
        return ray.getPoint(intersection!.start)
    }
    /*
    var pickEllipsoid2DRay = new Ray();
    function pickMap2D(camera, windowPosition, projection, result) {
    var ray = camera.getPickRay(windowPosition, pickEllipsoid2DRay);
    var position = ray.origin;
    position.z = 0.0;
    var cart = projection.unproject(position);
    
    if (cart.latitude < -CesiumMath.PI_OVER_TWO || cart.latitude > CesiumMath.PI_OVER_TWO ||
    cart.longitude < - Math.PI || cart.longitude > Math.PI) {
    return undefined;
    }
    
    return projection.ellipsoid.cartographicToCartesian(cart, result);
    }
    
    var pickEllipsoidCVRay = new Ray();
    function pickMapColumbusView(camera, windowPosition, projection, result) {
    var ray = camera.getPickRay(windowPosition, pickEllipsoidCVRay);
    var scalar = -ray.origin.x / ray.direction.x;
    Ray.getPoint(ray, scalar, result);
    
    var cart = projection.unproject(new Cartesian3(result.y, result.z, 0.0));
    
    if (cart.latitude < -CesiumMath.PI_OVER_TWO || cart.latitude > CesiumMath.PI_OVER_TWO ||
    cart.longitude < - Math.PI || cart.longitude > Math.PI) {
    return undefined;
    }
    
    return projection.ellipsoid.cartographicToCartesian(cart, result);
    }
    */
    /**
    * Pick an ellipsoid or map.
    *
    * @memberof Camera
    *
    * @param {Cartesian2} windowPosition The x and y coordinates of a pixel.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid to pick.
    * @param {Cartesian3} [result] The object onto which to store the result.
    *
    * @returns {Cartesian3} If the ellipsoid or map was picked, returns the point on the surface of the ellipsoid or map
    * in world coordinates. If the ellipsoid or map was not picked, returns undefined.
    */
    func pickEllipsoid (windowPosition: Cartesian2, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) -> Cartesian3? {
        
        if _mode == .Scene3D {
            return pickEllipsoid3D(windowPosition, ellipsoid: ellipsoid)
        } else if _mode == .Scene2D {
            assertionFailure("Unimplemented")
            //result = pickMap2D(this, windowPosition, this._projection, result);
        } else if _mode == .ColumbusView {
            assertionFailure("Unimplemented")
            //result = pickMapColumbusView(this, windowPosition, this._projection, result);
        }
        return nil
    }
    
    func getPickRayPerspective(windowPosition: Cartesian2) -> Ray {
        
        let width = Double(scene!.context.width)
        let height = Double(scene!.context.height)
        
        let tanPhi = tan(frustum.fovy * 0.5)
        let tanTheta = frustum.aspectRatio * tanPhi
        let near = frustum.near
        
        let x = (2.0 / width) * windowPosition.x - 1.0
        let y = (2.0 / height) * (height - windowPosition.y) - 1.0
        
        let position = positionWC
        
        var nearCenter = directionWC.multiplyByScalar(near)
        nearCenter = position.add(nearCenter)
        
        let xDir = rightWC.multiplyByScalar(x * near * tanTheta)
        let yDir = upWC.multiplyByScalar(y * near * tanPhi)
        
        let direction = nearCenter.add(xDir).add(yDir).subtract(position).normalize()
        
        return Ray(origin: position, direction: direction)
    }
    /*
    var scratchDirection = new Cartesian3();
    
    function getPickRayOrthographic(camera, windowPosition, result) {
    var width = camera._scene.canvas.clientWidth;
    var height = camera._scene.canvas.clientHeight;
    
    var x = (2.0 / width) * windowPosition.x - 1.0;
    x *= (camera.frustum.right - camera.frustum.left) * 0.5;
    var y = (2.0 / height) * (height - windowPosition.y) - 1.0;
    y *= (camera.frustum.top - camera.frustum.bottom) * 0.5;
    
    var origin = result.origin;
    Cartesian3.clone(camera.position, origin);
    
    Cartesian3.multiplyByScalar(camera.right, x, scratchDirection);
    Cartesian3.add(scratchDirection, origin, origin);
    Cartesian3.multiplyByScalar(camera.up, y, scratchDirection);
    Cartesian3.add(scratchDirection, origin, origin);
    
    Cartesian3.clone(camera.directionWC, result.direction);
    
    return result;
    }
    */
    /**
    * Create a ray from the camera position through the pixel at <code>windowPosition</code>
    * in world coordinates.
    *
    * @memberof Camera
    *
    * @param {Cartesian2} windowPosition The x and y coordinates of a pixel.
    *
    * @returns {Ray} Returns the {@link Cartesian3} position and direction of the ray.
    */
    func getPickRay (windowPosition: Cartesian2) -> Ray {
        
        if frustum.aspectRatio != Double.NaN && frustum.fovy != Double.NaN && frustum.near != Double.NaN {
            return getPickRayPerspective(windowPosition)
        }
        assertionFailure("unimplemented")
        return Ray()
        //return getPickRayOrthographic(windowPosition)
    }
    /*
    function createAnimation2D(camera, duration) {
    var position = camera.position;
    var translateX = position.x < -camera._maxCoord.x || position.x > camera._maxCoord.x;
    var translateY = position.y < -camera._maxCoord.y || position.y > camera._maxCoord.y;
    var animatePosition = translateX || translateY;
    
    var frustum = camera.frustum;
    var top = frustum.top;
    var bottom = frustum.bottom;
    var right = frustum.right;
    var left = frustum.left;
    var startFrustum = camera._max2Dfrustum;
    var animateFrustum = right > camera._max2Dfrustum.right;
    
    if (animatePosition || animateFrustum) {
    var translatedPosition = Cartesian3.clone(position);
    
    if (translatedPosition.x > camera._maxCoord.x) {
    translatedPosition.x = camera._maxCoord.x;
    } else if (translatedPosition.x < -camera._maxCoord.x) {
    translatedPosition.x = -camera._maxCoord.x;
    }
    
    if (translatedPosition.y > camera._maxCoord.y) {
    translatedPosition.y = camera._maxCoord.y;
    } else if (translatedPosition.y < -camera._maxCoord.y) {
    translatedPosition.y = -camera._maxCoord.y;
    }
    
    var update2D = function(value) {
    if (animatePosition) {
    camera.position = Cartesian3.lerp(position, translatedPosition, value.time);
    }
    if (animateFrustum) {
    camera.frustum.top = CesiumMath.lerp(top, startFrustum.top, value.time);
    camera.frustum.bottom = CesiumMath.lerp(bottom, startFrustum.bottom, value.time);
    camera.frustum.right = CesiumMath.lerp(right, startFrustum.right, value.time);
    camera.frustum.left = CesiumMath.lerp(left, startFrustum.left, value.time);
    }
    };
    
    return {
    easingFunction : Tween.Easing.Exponential.Out,
    startValue : {
    time : 0.0
    },
    stopValue : {
    time : 1.0
    },
    duration : duration,
    onUpdate : update2D
    };
    }
    
    return undefined;
    }
    
    function createAnimationTemplateCV(camera, position, center, maxX, maxY, duration) {
    var newPosition = Cartesian3.clone(position);
    
    if (center.y > maxX) {
    newPosition.y -= center.y - maxX;
    } else if (center.y < -maxX) {
    newPosition.y += -maxX - center.y;
    }
    
    if (center.z > maxY) {
    newPosition.z -= center.z - maxY;
    } else if (center.z < -maxY) {
    newPosition.z += -maxY - center.z;
    }
    
    var updateCV = function(value) {
    var interp = Cartesian3.lerp(position, newPosition, value.time);
    camera.worldToCameraCoordinatesPoint(interp, camera.position);
    };
    
    return {
    easingFunction : Tween.Easing.Exponential.Out,
    startValue : {
    time : 0.0
    },
    stopValue : {
    time : 1.0
    },
    duration : duration,
    onUpdate : updateCV
    };
    }
    
    var normalScratch = new Cartesian3();
    var centerScratch = new Cartesian3();
    var posScratch = new Cartesian3();
    var scratchCartesian3Subtract = new Cartesian3();
    
    function createAnimationCV(camera, duration) {
    var position = camera.position;
    var direction = camera.direction;
    
    var normal = camera.worldToCameraCoordinatesVector(Cartesian3.UNIT_X, normalScratch);
    var scalar = -Cartesian3.dot(normal, position) / Cartesian3.dot(normal, direction);
    var center = Cartesian3.add(position, Cartesian3.multiplyByScalar(direction, scalar, centerScratch), centerScratch);
    camera.cameraToWorldCoordinatesPoint(center, center);
    
    position = camera.cameraToWorldCoordinatesPoint(camera.position, posScratch);
    
    var tanPhi = Math.tan(camera.frustum.fovy * 0.5);
    var tanTheta = camera.frustum.aspectRatio * tanPhi;
    var distToC = Cartesian3.magnitude(Cartesian3.subtract(position, center, scratchCartesian3Subtract));
    var dWidth = tanTheta * distToC;
    var dHeight = tanPhi * distToC;
    
    var mapWidth = camera._maxCoord.x;
    var mapHeight = camera._maxCoord.y;
    
    var maxX = Math.max(dWidth - mapWidth, mapWidth);
    var maxY = Math.max(dHeight - mapHeight, mapHeight);
    
    if (position.z < -maxX || position.z > maxX || position.y < -maxY || position.y > maxY) {
    var translateX = center.y < -maxX || center.y > maxX;
    var translateY = center.z < -maxY || center.z > maxY;
    if (translateX || translateY) {
    return createAnimationTemplateCV(camera, position, center, maxX, maxY, duration);
    }
    }
    
    return undefined;
    }
    
    /**
    * Create an animation to move the map into view. This method is only valid for 2D and Columbus modes.
    *
    * @memberof Camera
    *
    * @param {Number} duration The duration, in milliseconds, of the animation.
    *
    * @exception {DeveloperException} duration is required.
    *
    * @returns {Object} The animation or undefined if the scene mode is 3D or the map is already ion view.
    */
    Camera.prototype.createCorrectPositionAnimation = function(duration) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(duration)) {
    throw new DeveloperError('duration is required.');
    }
    //>>includeEnd('debug');
    
    if (this._mode === SceneMode.SCENE2D) {
    return createAnimation2D(this, duration);
    } else if (this._mode === SceneMode.COLUMBUS_VIEW) {
    return createAnimationCV(this, duration);
    }
    
    return undefined;
    };
    */
    
    /*var scratchFlyToDestination = new Cartesian3();
    var scratchFlyToQuaternion = new Quaternion();
    var scratchFlyToMatrix3 = new Matrix3();
    var scratchFlyToDirection = new Cartesian3();
    var scratchFlyToUp = new Cartesian3();
    var scratchFlyToMatrix4 = new Matrix4();
    var newOptions = {
    destination : undefined,
    heading : undefined,
    pitch : undefined,
    roll : undefined,
    duration : undefined,
    complete : undefined,
    cancel : undefined,
    endTransform : undefined,
    maximumHeight : undefined,
    easingFunction : undefined
    };
    
    var scratchFlyDirection = new Cartesian3();
    var scratchFlyUp = new Cartesian3();
    var scratchFlyRight = new Cartesian3();
    */
    
    /**
    * Flies the camera from its current position to a new position.
    *
    * @param {Object} options Object with the following properties:
    * @param {Cartesian3|Rectangle} options.destination The final position of the camera in WGS84 (world) coordinates or a rectangle that would be visible from a top-down view.
    * @param {Object} [options.orientation] An object that contains either direction and up properties or heading, pith and roll properties. By default, the direction will point
    * towards the center of the frame in 3D and in the negative z direction in Columbus view or 2D. The up direction will point towards local north in 3D and in the positive
    * y direction in Columbus view or 2D.
    * @param {Number} [options.duration] The duration of the flight in seconds. If ommitted, Cesium attempts to calculate an ideal duration based on the distance to be traveled by the flight.
    * @param {Camera~FlightCompleteCallback} [options.complete] The function to execute when the flight is complete.
    * @param {Camera~FlightCancelledCallback} [options.cancel] The function to execute if the flight is cancelled.
    * @param {Matrix4} [options.endTransform] Transform matrix representing the reference frame the camera will be in when the flight is completed.
    * @param {Boolean} [options.convert=true] When <code>true</code>, the destination is converted to the correct coordinate system for each scene mode. When <code>false</code>, the destination is expected
    *                  to be in the correct coordinate system.
    * @param {Number} [options.maximumHeight] The maximum height at the peak of the flight.
    * @param {EasingFunction|EasingFunction~Callback} [options.easingFunction] Controls how the time is interpolated over the duration of the flight.
    *
    * @exception {DeveloperError} If either direction or up is given, then both are required.
    *
    * @example
    * // 1. Fly to a position with a top-down view
    * viewer.camera.flyTo({
    *     destination : Cesium.Cartesian3.fromDegrees(-117.16, 32.71, 15000.0)
    * });
    *
    * // 2. Fly to a Rectangle with a top-down view
    * viewer.camera.flyTo({
    *     destination : Cesium.Rectangle.fromDegrees(west, south, east, north)
    * });
    *
    * // 3. Fly to a position with an orientation using unit vectors.
    * viewer.camera.flyTo({
    *     destination : Cesium.Cartesian3.fromDegrees(-122.19, 46.25, 5000.0),
    *     orientation : {
    *         direction : new Cesium.Cartesian3(-0.04231243104240401, -0.20123236049443421, -0.97862924300734),
    *         up : new Cesium.Cartesian3(-0.47934589305293746, -0.8553216253114552, 0.1966022179118339)
    *     }
    * });
    *
    * // 4. Fly to a position with an orientation using heading, pitch and roll.
    * viewer.camera.flyTo({
    *     destination : Cesium.Cartesian3.fromDegrees(-122.19, 46.25, 5000.0),
    *     orientation : {
    *         heading : Cesium.Math.toRadians(175.0),
    *         pitch : Cesium.Math.toRadians(-35.0),
    *         roll : 0.0
    *     }
    * });
    */
    func flyTo (/*options*/) {
    /*options = defaultValue(options, defaultValue.EMPTY_OBJECT);
    
    var destination = options.destination;
    //>>includeStart('debug', pragmas.debug);
    if (!defined(destination)) {
    throw new DeveloperError('destination is required.');
    }
    //>>includeEnd('debug');
    
    var scene = this._scene;
    
    var isRectangle = defined(destination.west);
    if (isRectangle) {
    if (scene.mode !== SceneMode.SCENE3D && destination.west > destination.east) {
    destination = Rectangle.MAX_VALUE;
    }
    destination = scene.camera.getRectangleCameraCoordinates(destination, scratchFlyToDestination);
    }
    
    var heading;
    var pitch;
    var roll;
    
    var orientation = defaultValue(options.orientation, defaultValue.EMPTY_OBJECT);
    if (defined(orientation.heading)) {
    heading = orientation.heading;
    pitch = orientation.pitch;
    roll = orientation.roll;
    } else if (defined(orientation.direction)) {
    var direction = Cartesian3.clone(orientation.direction, scratchFlyDirection);
    var up = Cartesian3.clone(orientation.up, scratchFlyUp);
    
    if (scene.mode === SceneMode.SCENE3D) {
    var ellipsoid = this._projection.ellipsoid;
    var transform = Transforms.eastNorthUpToFixedFrame(destination, ellipsoid, scratchHPRMatrix1);
    var invTransform = Matrix4.inverseTransformation(transform, scratchHPRMatrix2);
    
    Matrix4.multiplyByPointAsVector(invTransform, direction, direction);
    Matrix4.multiplyByPointAsVector(invTransform, up, up);
    }
    
    var right = Cartesian3.cross(direction, up, scratchFlyRight);
    
    heading = getHeading(direction, up);
    pitch = getPitch(direction);
    roll = getRoll(direction, up, right);
    }
    
    newOptions.destination = destination;
    newOptions.heading = heading;
    newOptions.pitch = pitch;
    newOptions.roll = roll;
    newOptions.duration = options.duration;
    newOptions.complete = options.complete;
    newOptions.cancel = options.cancel;
    newOptions.endTransform = options.endTransform;
    newOptions.convert = isRectangle ? false : options.convert;
    newOptions.maximumHeight = options.maximumHeight;
    newOptions.easingFunction = options.easingFunction;
    
    scene.tweens.add(CameraFlightPath.createTween(scene, newOptions));*/
    }
    
    /*function distanceToBoundingSphere3D(camera, radius) {
    var frustum = camera.frustum;
    var tanPhi = Math.tan(frustum.fovy * 0.5);
    var tanTheta = frustum.aspectRatio * tanPhi;
    return Math.max(radius / tanTheta, radius / tanPhi);
    }
    
    function distanceToBoundingSphere2D(camera, radius) {
    var frustum = camera.frustum;
    
    var right, top;
    var ratio = frustum.right / frustum.top;
    var heightRatio = radius * ratio;
    if (radius > heightRatio) {
    right = radius;
    top = right / ratio;
    } else {
    top = radius;
    right = heightRatio;
    }
    
    return Math.max(right, top) * 1.50;
    }
    
    var scratchDefaultOffset = new HeadingPitchRange(0.0, -CesiumMath.PI_OVER_FOUR, 0.0);
    var MINIMUM_ZOOM = 100.0;
    
    function adjustBoundingSphereOffset(camera, boundingSphere, offset) {
    if (!defined(offset)) {
    offset = HeadingPitchRange.clone(scratchDefaultOffset);
    }
    
    var range = offset.range;
    if (!defined(range) || range === 0.0) {
    var radius = boundingSphere.radius;
    if (radius === 0.0) {
    offset.range = MINIMUM_ZOOM;
    } else {
    offset.range = camera._mode === SceneMode.SCENE2D ? distanceToBoundingSphere2D(camera, radius) : distanceToBoundingSphere3D(camera, radius);
    }
    }
    
    return offset;
    }
    
    /**
    * Sets the camera so that the current view contains the provided bounding sphere.
    *
    * <p>The offset is heading/pitch/range in the local east-north-up reference frame centered at the center of the bounding sphere.
    * The heading and the pitch angles are defined in the local east-north-up reference frame.
    * The heading is the angle from y axis and increasing towards the x axis. Pitch is the rotation from the xy-plane. Positive pitch
    * angles are above the plane. Negative pitch angles are below the plane. The range is the distance from the center. If the range is
    * zero, a range will be computed such that the whole bounding sphere is visible.</p>
    *
    * <p>In 2D, there must be a top down view. The camera will be placed above the target looking down. The height above the
    * target will be the range. The heading will be determined from the offset. If the heading cannot be
    * determined from the offset, the heading will be north.</p>
    *
    * @param {BoundingSphere} boundingSphere The bounding sphere to view, in world coordinates.
    * @param {HeadingPitchRange} [offset] The offset from the target in the local east-north-up reference frame centered at the target.
    *
    * @exception {DeveloperError} viewBoundingSphere is not supported while morphing.
    */
    Camera.prototype.viewBoundingSphere = function(boundingSphere, offset) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(boundingSphere)) {
    throw new DeveloperError('boundingSphere is required.');
    }
    //>>includeEnd('debug');
    
    if (this._mode === SceneMode.MORPHING) {
    throw new DeveloperError('viewBoundingSphere is not supported while morphing.');
    }
    
    offset = adjustBoundingSphereOffset(this, boundingSphere, offset);
    this.lookAt(boundingSphere.center, offset);
    };
    
    var scratchflyToBoundingSphereTransform = new Matrix4();
    var scratchflyToBoundingSphereDestination = new Cartesian3();
    var scratchflyToBoundingSphereDirection = new Cartesian3();
    var scratchflyToBoundingSphereUp = new Cartesian3();
    var scratchflyToBoundingSphereRight = new Cartesian3();
    var scratchFlyToBoundingSphereCart4 = new Cartesian4();
    var scratchFlyToBoundingSphereQuaternion = new Quaternion();
    var scratchFlyToBoundingSphereMatrix3 = new Matrix3();
    
    /**
    * Flies the camera to a location where the current view contains the provided bounding sphere.
    *
    * <p> The offset is heading/pitch/range in the local east-north-up reference frame centered at the center of the bounding sphere.
    * The heading and the pitch angles are defined in the local east-north-up reference frame.
    * The heading is the angle from y axis and increasing towards the x axis. Pitch is the rotation from the xy-plane. Positive pitch
    * angles are above the plane. Negative pitch angles are below the plane. The range is the distance from the center. If the range is
    * zero, a range will be computed such that the whole bounding sphere is visible.</p>
    *
    * <p>In 2D and Columbus View, there must be a top down view. The camera will be placed above the target looking down. The height above the
    * target will be the range. The heading will be aligned to local north.</p>
    *
    * @param {BoundingSphere} boundingSphere The bounding sphere to view, in world coordinates.
    * @param {Object} [options] Object with the following properties:
    * @param {Number} [options.duration] The duration of the flight in seconds. If ommitted, Cesium attempts to calculate an ideal duration based on the distance to be traveled by the flight.
    * @param {HeadingPitchRange} [options.offset] The offset from the target in the local east-north-up reference frame centered at the target.
    * @param {Camera~FlightCompleteCallback} [options.complete] The function to execute when the flight is complete.
    * @param {Camera~FlightCancelledCallback} [options.cancel] The function to execute if the flight is cancelled.
    * @param {Matrix4} [options.endTransform] Transform matrix representing the reference frame the camera will be in when the flight is completed.
    * @param {Number} [options.maximumHeight] The maximum height at the peak of the flight.
    * @param {EasingFunction|EasingFunction~Callback} [options.easingFunction] Controls how the time is interpolated over the duration of the flight.
    */
    Camera.prototype.flyToBoundingSphere = function(boundingSphere, options) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(boundingSphere)) {
    throw new DeveloperError('boundingSphere is required.');
    }
    //>>includeEnd('debug');
    
    options = defaultValue(options, defaultValue.EMPTY_OBJECT);
    
    var scene2D = this._mode === SceneMode.SCENE2D || this._mode === SceneMode.COLUMBUS_VIEW;
    this._setTransform(Matrix4.IDENTITY);
    var offset = adjustBoundingSphereOffset(this, boundingSphere, options.offset);
    
    var position;
    if (scene2D) {
    position = Cartesian3.multiplyByScalar(Cartesian3.UNIT_Z, offset.range, scratchflyToBoundingSphereDestination);
    } else {
    position = offsetFromHeadingPitchRange(offset.heading, offset.pitch, offset.range);
    }
    
    var transform = Transforms.eastNorthUpToFixedFrame(boundingSphere.center, Ellipsoid.WGS84, scratchflyToBoundingSphereTransform);
    Matrix4.multiplyByPoint(transform, position, position);
    
    var direction;
    var up;
    
    if (!scene2D) {
    direction = Cartesian3.subtract(boundingSphere.center, position, scratchflyToBoundingSphereDirection);
    Cartesian3.normalize(direction, direction);
    
    up = Matrix4.multiplyByPointAsVector(transform, Cartesian3.UNIT_Z, scratchflyToBoundingSphereUp);
    if (1.0 - Math.abs(Cartesian3.dot(direction, up)) < CesiumMath.EPSILON6) {
    var rotateQuat = Quaternion.fromAxisAngle(direction, offset.heading, scratchFlyToBoundingSphereQuaternion);
    var rotation = Matrix3.fromQuaternion(rotateQuat, scratchFlyToBoundingSphereMatrix3);
    
    Cartesian3.fromCartesian4(Matrix4.getColumn(transform, 1, scratchFlyToBoundingSphereCart4), up);
    Matrix3.multiplyByVector(rotation, up, up);
    }
    
    var right = Cartesian3.cross(direction, up, scratchflyToBoundingSphereRight);
    Cartesian3.cross(right, direction, up);
    Cartesian3.normalize(up, up);
    }
    
    this.flyTo({
    destination : position,
    orientation : {
    direction : direction,
    up : up
    },
    duration : options.duration,
    complete : options.complete,
    cancel : options.cancel,
    endTransform : options.endTransform,
    maximumHeight : options.maximumHeight,
    easingFunction : options.easingFunction
    });
    };
    */
    /**
    * @private
    */
    func clone () -> Camera {
        
        let camera = Camera(projection: _projection, mode: _mode, initialWidth: 0, initialHeight: 0)
        camera.position = position
        camera.direction = direction
        camera.up = up
        camera.right = right
        // FIXME: Clone
        //camera.transform = transform
        
        return camera
    }
    
    /*
    /**
    * A function that will execute when a flight completes.
    * @callback Camera~FlightCompleteCallback
    */
    
    /**
    * A function that will execute when a flight is cancelled.
    * @callback Camera~FlightCancelledCallback
    */
    
    return Camera;*/
    
}
