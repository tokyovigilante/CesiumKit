//
//  CSCamera.h
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@class CSScene, CSFrustum, CSPerspectiveFrustum, CSOffCentrePerspectiveFrustum, CSOrthographicFrustum, CSCartesian2, Cartesian3, CSCartesian4, CSMatrix4, CSProjection, CSCartographic, Ellipsoid;

@interface CSCamera : NSObject <NSCopying>

/**
 * The camera is defined by a position, orientation, and view frustum.
 * <br /><br />
 * The orientation forms an orthonormal basis with a view, up and right = view x up unit vectors.
 * <br /><br />
 * The viewing frustum is defined by 6 planes.
 * Each plane is represented by a {Cartesian4} object, where the x, y, and z components
 * define the unit vector normal to the plane, and the w component is the distance of the
 * plane from the origin/camera position.
 *
 * @alias Camera
 *
 * @constructor
 *
 * @example
 * // Create a camera looking down the negative z-axis, positioned at the origin,
 * // with a field of view of 60 degrees, and 1:1 aspect ratio.
 * var camera = new Cesium.Camera(scene);
 * camera.position = new Cesium.Cartesian3();
 * camera.direction = Cesium.Cartesian3.negate(Cesium.Cartesian3.UNIT_Z);
 * camera.up = Cesium.Cartesian3.clone(Cesium.Cartesian3.UNIT_Y);
 * camera.frustum.fovy = Cesium.Math.PI_OVER_THREE;
 * camera.frustum.near = 1.0;
 * camera.frustum.far = 2.0;
 *
 * @demo <a href="http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Camera.html">Cesium Sandcastle Camera Demo</a>
 * @demo <a href="http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Camera.html">Sandcastle Example</a> from the <a href="http://cesiumjs.org/2013/02/13/Cesium-Camera-Tutorial/">Camera Tutorial</a>
 */


/**
 * Modifies the camera's reference frame. The inverse of this transformation is appended to the view matrix.
 *
 * @type {Matrix4}
 * @default {@link Matrix4.IDENTITY}
 *
 * @see Transforms
 * @see Camera#inverseTransform
 */
@property (nonatomic) CSMatrix4 *transform;

/**
 * Gets the inverse camera transform.
 * @memberof Camera.prototype
 *
 * @type {Matrix4}
 * @default {@link Matrix4.IDENTITY}
 */
@property (nonatomic, readonly) CSMatrix4 *inCSransform;

/**
 * The position of the camera.
 *
 * @type {Cartesian3}
 */
@property (nonatomic) Cartesian3 *position;
@property (nonatomic, readonly) Cartesian3 *positionWC; // world coordinates
/**
 * The up direction of the camera.
 *
 * @type {Cartesian3}
 */
@property (nonatomic) Cartesian3 *up;
@property (nonatomic, readonly) Cartesian3 *upWC; // world coordinates

/**
 * The up direction of the camera.
 *
 * @type {Cartesian3}
 */
@property (nonatomic) Cartesian3 *right;
@property (nonatomic, readonly) Cartesian3 *rightWC; // world coordinates

/**
 * Gets the view matrix.
 * @memberof Camera.prototype
 *
 * @type {Matrix4}
 *
 * @see UniformState#view
 * @see czm_view
 * @see Camera#inverseViewMatrix
 */
@property (nonatomic, readonly) CSMatrix4 *viewMatrix;

/**
 * Gets the inverse view matrix.
 * @memberof Camera.prototype
 *
 * @type {Matrix4}
 *
 * @see UniformState#inverseView
 * @see czm_inverseView
 * @see Camera#viewMatrix
 */
@property (nonatomic) CSMatrix4 *invViewMatrix;

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
@property (nonatomic) CSFrustum *frustum;

/**
 * The default amount to move the camera when an argument is not
 * provided to the move methods.
 * @type {Number}
 * @default 100000.0;
 */
@property Float64 defaultMoveAmount;

/**
 * The default amount to rotate the camera when an argument is not
 * provided to the look methods.
 * @type {Number}
 * @default Math.PI / 60.0
 */
@property Float64 defaultLookAmount;

/**
 * The default amount to rotate the camera when an argument is not
 * provided to the rotate methods.
 * @type {Number}
 * @default Math.PI / 3600.0
 */
@property Float64 defaultRotateAmount;

/**
 * The default amount to move the camera when an argument is not
 * provided to the zoom methods.
 * @type {Number}
 * @default 100000.0;
 */
@property Float64 defaultZoomAmount;

/**
 * If set, the camera will not be able to rotate past this axis in either direction.
 * @type {Cartesian3}
 * @default undefined
 */
@property (nonatomic) Cartesian3 *constrainedAxis;

/**
 * The factor multiplied by the the map size used to determine where to clamp the camera position
 * when translating across the surface. The default is 1.5. Only valid for 2D and Columbus view.
 * @type {Number}
 * @default 1.5
 */
@property Float64 maximumTranslateFactor;

/**
 * The factor multiplied by the the map size used to determine where to clamp the camera position
 * when zooming out from the surface. The default is 2.5. Only valid for 2D.
 * @type {Number}
 * @default 2.5
 */
@property Float64 maximumZoomFactor;

-(void)updateViewMatrix;
-(void)updateMembers;

-(Float64)heading;
-(void)setHeading:(Float64)tilt;

-(Float64)tilt;
-(void)setTilt:(Float64)angle;

-(void)update:(BOOL)isScene3D projection:(CSProjection *)projection;

/**
 * Sets the camera's transform without changing the current view.
 *
 * @memberof Camera
 *
 * @param {Matrix4} The camera transform.
 */
-(void)setTransform:(CSMatrix4 *)transform;

/**
 * Transform a vector or point from world coordinates to the camera's reference frame.
 * @memberof Camera
 *
 * @param {Cartesian4} cartesian The vector or point to transform.
 * @param {Cartesian4} [result] The object onto which to store the result.
 *
 * @returns {Cartesian4} The transformed vector or point.
 */
-(CSCartesian4 *)worldToCameraCoordinates:(CSCartesian4 *)worldCartesian4;

/**
 * Transform a vector or point from the camera's reference frame to world coordinates.
 * @memberof Camera
 *
 * @param {Cartesian4} vector The vector or point to transform.
 * @param {Cartesian4} [result] The object onto which to store the result.
 *
 * @returns {Cartesian4} The transformed vector or point.
 */
-(CSCartesian4 *)cameraToWorldCoordinates:(CSCartesian4 *)cameraCartesian4;

-(void)clampMove2D:(Cartesian3 *)position;

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
-(void)move:(Cartesian3 *)direction amount:(Float64)amount;

/**
 * Translates the camera's position by <code>amount</code> along the camera's view vector.
 *
 * @memberof Camera
 *
 * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
 *
 * @see Camera#moveBackward
 */
-(void)moveForward:(Float64)amount;


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
-(void)moveBackward:(Float64)amount;

/**
 * Translates the camera's position by <code>amount</code> along the camera's up vector.
 *
 * @memberof Camera
 *
 * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
 *
 * @see Camera#moveDown
 */
-(void)moveUp:(Float64)amount;

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
-(void)moveDown:(Float64)amount;

/**
 * Translates the camera's position by <code>amount</code> along the camera's right vector.
 *
 * @memberof Camera
 *
 * @param {Number} [amount] The amount, in meters, to move. Defaults to <code>defaultMoveAmount</code>.
 *
 * @see Camera#moveLeft
 */
-(void)moveRight:(Float64)amount;

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
-(void)moveLeft:(Float64)amount;

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
-(void)lookLeft:(Float64)amount;

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
-(void)lookRight:(Float64)amount;

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
-(void)lookUp:(Float64)amount;


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
-(void)lookDown:(Float64)amount;

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
-(void)look:(Cartesian3 *)axis angle:(Float64)angle;

/**
 * Rotate the camera counter-clockwise around its direction vector by amount, in radians.
 *
 * @memberof Camera
 *
 * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
 *
 * @see Camera#twistRight
 */

-(void)twistLeft:(Float64)amount;

/**
 * Rotate the camera clockwise around its direction vector by amount, in radians.
 *
 * @memberof Camera
 *
 * @param {Number} [amount] The amount, in radians, to rotate by. Defaults to <code>defaultLookAmount</code>.
 *
 * @see Camera#twistLeft
 */
-(void)twistRight:(Float64)amount;

-(void)appendTransform:(CSMatrix4 *)transform;
-(void)revertTransform:(CSMatrix4 *)transform;

/**
 * Rotates the camera around <code>axis</code> by <code>angle</code>. The distance
 * of the camera's position to the center of the camera's reference frame remains the same.
 *
 * @memberof Camera
 *
 * @param {Cartesian3} axis The axis to rotate around given in world coordinates.
 * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
 * @param {Matrix4} [transform] A transform to append to the camera transform before the rotation. Does not alter the camera's transform.
 *
 * @see Camera#rotateUp
 * @see Camera#rotateDown
 * @see Camera#rotateLeft
 * @see Camera#rotateRight
 *
 * @example
 * // Rotate about a point on the earth.
 * var center = ellipsoid.cartographicToCartesian(cartographic);
 * var transform = Cesium.Matrix4.fromTranslation(center);
 * camera.rotate(axis, angle, transform);
 */
-(void)rotate:(Cartesian3 *)axis angle:(Float64)angle transform:(CSMatrix4 *)transform;

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
-(void)rotateDown:(Float64)angle transform:(CSMatrix4 *)transform;

/**
 * Rotates the camera around the center of the camera's reference frame by angle upwards.
 *
 * @memberof Camera
 *
 * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
 * @param {Matrix4} [transform] A transform to append to the camera transform before the rotation. Does not alter the camera's transform.
 *
 * @see Camera#rotateDown
 * @see Camera#rotate
 */
-(void)rotateUp:(Float64)angle transform:(CSMatrix4 *)transform;
    
-(void)rotateVertical:(Float64)angle transform:(CSMatrix4 *)transform;


    
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
-(void)rotateRight:(Float64)angle transform:(CSMatrix4 *)transform;

/**
 * Rotates the camera around the center of the camera's reference frame by angle to the left.
 *
 * @memberof Camera
 *
 * @param {Number} [angle] The angle, in radians, to rotate by. Defaults to <code>defaultRotateAmount</code>.
 * @param {Matrix4} [transform] A transform to append to the camera transform before the rotation. Does not alter the camera's transform.
 *
 * @see Camera#rotateRight
 * @see Camera#rotate
 */
-(void)rotateLeft:(Float64)angle transform:(CSMatrix4 *)transform;

-(void)rotateHorizontal:(Float64)angle transform:(CSMatrix4 *)transform;

-(void)zoom2D:(Float64)amount;
-(void)zoom3D:(Float64)amount;

/**
 * Zooms <code>amount</code> along the camera's view vector.
 *
 * @memberof Camera
 *
 * @param {Number} [amount] The amount to move. Defaults to <code>defaultZoomAmount</code>.
 *
 * @see Camera#zoomOut
 */
-(void)zoomIn:(Float64)amount;

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
-(void)zoomOut:(Float64)amount;

/**
 * Gets the magnitude of the camera position. In 3D, this is the vector magnitude. In 2D and
 * Columbus view, this is the distance to the map.
 *
 * @memberof Camera
 *
 * @returns {Number} The magnitude of the position.
 */
-(Float64)magnitude;

-(void)setPosition:(CSCartographic *)cartographic;

-(void)lookAt:(Cartesian3 *)eye target:(Cartesian3 *)target up:(Cartesian3 *)up;


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
-(Cartesian3 *)getRectangleCameraCoordinates:(Cartesian3 *)rectangle;

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

-(Cartesian3 *)pickEllipsoid:(Ellipsoid *)ellipsoid windowPosition:(CSCartesian2 *)windowPosition;

/*
var pickPerspCenter = new Cartesian3();
var pickPerspXDir = new Cartesian3();
var pickPerspYDir = new Cartesian3();
function getPickRayPerspective(camera, windowPosition, result) {
    var width = camera._scene.canvas.clientWidth;
    var height = camera._scene.canvas.clientHeight;
    
    var tanPhi = Math.tan(camera.frustum.fovy * 0.5);
    var tanTheta = camera.frustum.aspectRatio * tanPhi;
    var near = camera.frustum.near;
    
    var x = (2.0 / width) * windowPosition.x - 1.0;
    var y = (2.0 / height) * (height - windowPosition.y) - 1.0;
    
    var position = camera.positionWC;
    Cartesian3.clone(position, result.origin);
    
    var nearCenter = Cartesian3.multiplyByScalar(camera.directionWC, near, pickPerspCenter);
    Cartesian3.add(position, nearCenter, nearCenter);
    var xDir = Cartesian3.multiplyByScalar(camera.rightWC, x * near * tanTheta, pickPerspXDir);
    var yDir = Cartesian3.multiplyByScalar(camera.upWC, y * near * tanPhi, pickPerspYDir);
    var direction = Cartesian3.add(nearCenter, xDir, result.direction);
    Cartesian3.add(direction, yDir, direction);
    Cartesian3.subtract(direction, position, direction);
    Cartesian3.normalize(direction, direction);
    
    return result;
}

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

/**
 * Create a ray from the camera position through the pixel at <code>windowPosition</code>
 * in world coordinates.
 *
 * @memberof Camera
 *
 * @param {Cartesian2} windowPosition The x and y coordinates of a pixel.
 * @param {Ray} [result] The object onto which to store the result.
 *
 * @returns {Object} Returns the {@link Cartesian3} position and direction of the ray.
 */
/*Camera.prototype.getPickRay = function(windowPosition, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(windowPosition)) {
        throw new DeveloperError('windowPosition is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new Ray();
    }
    
    var frustum = this.frustum;
    if (defined(frustum.aspectRatio) && defined(frustum.fovy) && defined(frustum.near)) {
        return getPickRayPerspective(this, windowPosition, result);
    }
    
    return getPickRayOrthographic(this, windowPosition, result);
};

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
        camera.position = Matrix4.multiplyByPoint(camera.inverseTransform, interp, camera.position);
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
var scratchCartesian3 = new Cartesian3();
function createAnimationCV(camera, duration) {
    var position = camera.position;
    var direction = camera.direction;
    
    var normal = Matrix4.multiplyByPointAsVector(camera.inverseTransform, Cartesian3.UNIT_X, normalScratch);
    var scalar = -Cartesian3.dot(normal, position) / Cartesian3.dot(normal, direction);
    var center = Cartesian3.add(position, Cartesian3.multiplyByScalar(direction, scalar, centerScratch), centerScratch);
    center = Matrix4.multiplyByPoint(camera.transform, center, center);
    
    position = Matrix4.multiplyByPoint(camera.transform, camera.position, posScratch);
    
    var tanPhi = Math.tan(camera.frustum.fovy * 0.5);
    var tanTheta = camera.frustum.aspectRatio * tanPhi;
    var distToC = Cartesian3.magnitude(Cartesian3.subtract(position, center, scratchCartesian3));
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
/*Camera.prototype.createCorrectPositionAnimation = function(duration) {
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

/**
 * Returns a duplicate of a Camera instance.
 *
 * @memberof Camera
 *
 * @returns {Camera} A new copy of the Camera instance.
 */
-(id)copyWithZone:(NSZone *)zone;

@end