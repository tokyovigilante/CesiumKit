//
//  OrthographicFrustum.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* The viewing frustum is defined by 6 planes.
* Each plane is represented by a {@link Cartesian4} object, where the x, y, and z components
* define the unit vector normal to the plane, and the w component is the distance of the
* plane from the origin/camera position.
*
* @alias OrthographicFrustum
* @constructor
*
* @example
* var maxRadii = ellipsoid.maximumRadius;
*
* var frustum = new Cesium.OrthographicFrustum();
* frustum.right = maxRadii * Cesium.Math.PI;
* frustum.left = -c.frustum.right;
* frustum.top = c.frustum.right * (canvas.clientHeight / canvas.clientWidth);
* frustum.bottom = -c.frustum.top;
* frustum.near = 0.01 * maxRadii;
* frustum.far = 50.0 * maxRadii;
*/

struct OrthographicFrustum: Frustum {

    var fov: Double = Double.NaN
    var fovy: Double = Double.NaN
    
    var aspectRatio: Double = Double.NaN
    
    let infiniteProjectionMatrix: Matrix4? = nil
    
    var projectionMatrix: Matrix4 {
        get {
            return _orthographicMatrix
        }
    }
    private var _orthographicMatrix = Matrix4()

    /**
    * Defines the left clipping plane.
    * @type {Number}
    * @default undefined
    */
    var left = Double.NaN
    private var _left = Double.NaN
    
    /**
    * Defines the right clipping plane.
    * @type {Number}
    * @default undefined
    */
    var right = Double.NaN
    private var _right = Double.NaN
    
    /**
    * Defines the top clipping plane.
    * @type {Number}
    * @default undefined
    */
    var top = Double.NaN
    private var _top = Double.NaN
    
    /**
    * Defines the bottom clipping plane.
    * @type {Number}
    * @default undefined
    */
    var bottom = Double.NaN
    private var _bottom = Double.NaN
    
    /**
    * The distance of the near plane.
    * @type {Number}
    * @default 1.0
    */
    var near = 1.0
    private var _near = 1.0
    
    /**
    * The distance of the far plane.
    * @type {Number}
    * @default 500000000.0
    */
    var far = 500000000.0
    private var _far = 500000000.0
    
    private var _cullingVolume = CullingVolume()
    
    // FIXME: OrthographicFrustum
    /*
    this._cullingVolume = new CullingVolume();
    this._orthographicMatrix = new Matrix4();
    };
    */
    func update() {
    //>>includeStart('debug', pragmas.debug);
    /*if (!defined(frustum.right) || !defined(frustum.left) ||
    !defined(frustum.top) || !defined(frustum.bottom) ||
    !defined(frustum.near) || !defined(frustum.far)) {
    throw new DeveloperError('right, left, top, bottom, near, or far parameters are not set.');
    }
    //>>includeEnd('debug');
    
    if (frustum.top !== frustum._top || frustum.bottom !== frustum._bottom ||
    frustum.left !== frustum._left || frustum.right !== frustum._right ||
    frustum.near !== frustum._near || frustum.far !== frustum._far) {
    
    //>>includeStart('debug', pragmas.debug);
    if (frustum.left > frustum.right) {
    throw new DeveloperError('right must be greater than left.');
    }
    if (frustum.bottom > frustum.top) {
    throw new DeveloperError('top must be greater than bottom.');
    }
    if (frustum.near <= 0 || frustum.near > frustum.far) {
    throw new DeveloperError('near must be greater than zero and less than far.');
    }
    //>>includeEnd('debug');
    
    frustum._left = frustum.left;
    frustum._right = frustum.right;
    frustum._top = frustum.top;
    frustum._bottom = frustum.bottom;
    frustum._near = frustum.near;
    frustum._far = frustum.far;
    frustum._orthographicMatrix = Matrix4.computeOrthographicOffCenter(frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.near, frustum.far, frustum._orthographicMatrix);
    }*/
    }
    /*
    defineProperties(OrthographicFrustum.prototype, {
    /**
    * Gets the orthographic projection matrix computed from the view frustum.
    * @memberof OrthographicFrustum.prototype
    * @type {Matrix4}
    */
    projectionMatrix : {
    get : function() {
    update(this);*/
    /*
    var getPlanesRight = new Cartesian3();
    var getPlanesNearCenter = new Cartesian3();
    var getPlanesPoint = new Cartesian3();
    var negateScratch = new Cartesian3();
    */
    /**
    * Creates a culling volume for this frustum.
    *
    * @param {Cartesian3} position The eye position.
    * @param {Cartesian3} direction The view direction.
    * @param {Cartesian3} up The up direction.
    * @returns {CullingVolume} A culling volume at the given position and orientation.
    *
    * @example
    * // Check if a bounding volume intersects the frustum.
    * var cullingVolume = frustum.computeCullingVolume(cameraPosition, cameraDirection, cameraUp);
    * var intersect = cullingVolume.computeVisibility(boundingVolume);
    */
    func computeCullingVolume (position position: Cartesian3, direction: Cartesian3, up: Cartesian3) -> CullingVolume  {
        /*if (!defined(position)) {
    throw new DeveloperError('position is required.');
    }
    if (!defined(direction)) {
    throw new DeveloperError('direction is required.');
    }
    if (!defined(up)) {
    throw new DeveloperError('up is required.');
    }
    //>>includeEnd('debug');
    
    var planes = this._cullingVolume.planes;
    var t = this.top;
    var b = this.bottom;
    var r = this.right;
    var l = this.left;
    var n = this.near;
    var f = this.far;
    
    var right = Cartesian3.cross(direction, up, getPlanesRight);
    var nearCenter = getPlanesNearCenter;
    Cartesian3.multiplyByScalar(direction, n, nearCenter);
    Cartesian3.add(position, nearCenter, nearCenter);
    
    var point = getPlanesPoint;
    
    // Left plane
    Cartesian3.multiplyByScalar(right, l, point);
    Cartesian3.add(nearCenter, point, point);
    
    var plane = planes[0];
    if (!defined(plane)) {
    plane = planes[0] = new Cartesian4();
    }
    plane.x = right.x;
    plane.y = right.y;
    plane.z = right.z;
    plane.w = -Cartesian3.dot(right, point);
    
    // Right plane
    Cartesian3.multiplyByScalar(right, r, point);
    Cartesian3.add(nearCenter, point, point);
    
    plane = planes[1];
    if (!defined(plane)) {
    plane = planes[1] = new Cartesian4();
    }
    plane.x = -right.x;
    plane.y = -right.y;
    plane.z = -right.z;
    plane.w = -Cartesian3.dot(Cartesian3.negate(right, negateScratch), point);
    
    // Bottom plane
    Cartesian3.multiplyByScalar(up, b, point);
    Cartesian3.add(nearCenter, point, point);
    
    plane = planes[2];
    if (!defined(plane)) {
    plane = planes[2] = new Cartesian4();
    }
    plane.x = up.x;
    plane.y = up.y;
    plane.z = up.z;
    plane.w = -Cartesian3.dot(up, point);
    
    // Top plane
    Cartesian3.multiplyByScalar(up, t, point);
    Cartesian3.add(nearCenter, point, point);
    
    plane = planes[3];
    if (!defined(plane)) {
    plane = planes[3] = new Cartesian4();
    }
    plane.x = -up.x;
    plane.y = -up.y;
    plane.z = -up.z;
    plane.w = -Cartesian3.dot(Cartesian3.negate(up, negateScratch), point);
    
    // Near plane
    plane = planes[4];
    if (!defined(plane)) {
    plane = planes[4] = new Cartesian4();
    }
    plane.x = direction.x;
    plane.y = direction.y;
    plane.z = direction.z;
    plane.w = -Cartesian3.dot(direction, nearCenter);
    
    // Far plane
    Cartesian3.multiplyByScalar(direction, f, point);
    Cartesian3.add(position, point, point);
    
    plane = planes[5];
    if (!defined(plane)) {
    plane = planes[5] = new Cartesian4();
    }
    plane.x = -direction.x;
    plane.y = -direction.y;
    plane.z = -direction.z;
    plane.w = -Cartesian3.dot(Cartesian3.negate(direction, negateScratch), point);
    
    return this._cullingVolume*/
        return _cullingVolume
    }
    
    /**
    * Returns the pixel's width and height in meters.
    *
    * @param {Cartesian2} drawingBufferDimensions A {@link Cartesian2} with width and height in the x and y properties, respectively.
    * @param {Number} [distance=near plane distance] The distance to the near plane in meters.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new instance of {@link Cartesian2} with the pixel's width and height in the x and y properties, respectively.
    *
    * @exception {DeveloperError} drawingBufferDimensions.x must be greater than zero.
    * @exception {DeveloperError} drawingBufferDimensions.y must be greater than zero.
    *
    * @example
    * // Example 1
    * // Get the width and height of a pixel.
    * var pixelSize = camera.frustum.getPixelSize(new Cesium.Cartesian2(canvas.clientWidth, canvas.clientHeight));
    */
    func pixelDimensions (drawingBufferWidth width: Int, drawingBufferHeight height: Int, distance: Double) -> Cartesian2 {
/*    update(this);

    
    var frustumWidth = this.right - this.left;
    var frustumHeight = this.top - this.bottom;
    var pixelWidth = frustumWidth / drawingBufferDimensions.x;
    var pixelHeight = frustumHeight / drawingBufferDimensions.y;
    
    if (!defined(result)) {
    return new Cartesian2(pixelWidth, pixelHeight);
    }
    
    result.x = pixelWidth;
    result.y = pixelHeight;
    return result;*/return Cartesian2()
    }
    
    /**
    * Returns a duplicate of a OrthographicFrustum instance.
    *
    * @param {OrthographicFrustum} [result] The object onto which to store the result.
    * @returns {OrthographicFrustum} The modified result parameter or a new PerspectiveFrustum instance if one was not provided.
    */
    func clone (target: Frustum?) -> Frustum {
        
        var result = target ?? OrthographicFrustum()
        
        result.left = left
        result.right = right
        result.top = top
        result.bottom = bottom
        result.near = near
        result.far = far
        
        // force update of clone to compute matrices
        /*result._left = undefined;
        result._right = undefined;
        result._top = undefined;
        result._bottom = undefined;
        result._near = undefined;
        result._far = undefined;*/
        
        return result
    }
    
    /**
    * Compares the provided OrthographicFrustum componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {OrthographicFrustum} [other] The right hand side OrthographicFrustum.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    /*
    OrthographicFrustum.prototype.equals = function(other) {
    return (defined(other) &&
    this.right === other.right &&
    this.left === other.left &&
    this.top === other.top &&
    this.bottom === other.bottom &&
    this.near === other.near &&
    this.far === other.far);
    };
    
    return OrthographicFrustum;
    });

*/
}