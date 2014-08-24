//
//  PerspectiveOffCenterFrustum.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 23/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* The viewing frustum is defined by 6 planes.
* Each plane is represented by a {@link Cartesian4} object, where the x, y, and z components
* define the unit vector normal to the plane, and the w component is the distance of the
* plane from the origin/camera position.
*
* @alias PerspectiveOffCenterFrustum
* @constructor
*
* @see PerspectiveFrustum
*
* @example
* var frustum = new Cesium.PerspectiveOffCenterFrustum();
* frustum.right = 1.0;
* frustum.left = -1.0;
* frustum.top = 1.0;
* frustum.bottom = -1.0;
* frustum.near = 1.0;
* frustum.far = 2.0;
*/
struct PerspectiveOffCenterFrustum: Frustum {
    

    /**
    * Defines the left clipping plane.
    * @type {Number}
    * @default undefined
    */
    var left = 0.0
    private var _left = 0.0
    
    /**
    * Defines the right clipping plane.
    * @type {Number}
    * @default undefined
    */
    var right = 0.0
    private var _right = 0.0
    
    /**
    * Defines the top clipping plane.
    * @type {Number}
    * @default undefined
    */
    var top = 0.0
    private var _top = 0.0
    
    /**
    * Defines the bottom clipping plane.
    * @type {Number}
    * @default undefined
    */
    var bottom = 0.0
    private var _bottom = 0.0
    
    /**
    * The distance of the near plane.
    * @type {Number}
    * @default 1.0
    */
    var near = 1.0;
    private var _near = 1.0
    
    /**
    * The distance of the far plane.
    * @type {Number}
    * @default 500000000.0
    */
    var far = 500000000.0
    private var _far = 500000000.0
    
    private var _cullingVolume = CullingVolume()

    private var _perspectiveMatrix = Matrix4()

    private var _infinitePerspective = Matrix4()

    mutating func update () {
        
        var t = top
        var b = frustum.bottom
        var r = frustum.right
        var l = frustum.left
        var n = frustum.near
        var f = frustum.far
        
        if t != frustum._top || b != frustum._bottom || l != frustum._left ||
            r != frustum._right || n != frustum._near || f != frustum._far {
                assert(frustum.near > 0 && frustum.near < frustum.far, "near must be greater than zero and less than far")
                
                _left = l
                _right = r
                _top = t
                _bottom = b
                _near = n
                _far = f
                _perspectiveMatrix = Matrix4.computePerspectiveOffCenter(l, r, b, t, n, f)
                _infinitePerspective = Matrix4.computeInfinitePerspectiveOffCenter(l, r, b, t, n)
        }
    }
    
    /**
    * Gets the perspective projection matrix computed from the view frustum.
    * @memberof PerspectiveOffCenterFrustum.prototype
    * @type {Matrix4}
    *
    * @see PerspectiveOffCenterFrustum#infiniteProjectionMatrix
    */
    var projectionMatrix: Matrix4 {
        get {
            update()
            return _perspectiveMatrix
        }
    }
    
    /**
    * Gets the perspective projection matrix computed from the view frustum with an infinite far plane.
    * @memberof PerspectiveOffCenterFrustum.prototype
    * @type {Matrix4}
    *
    * @see PerspectiveOffCenterFrustum#projectionMatrix
    */
    var infiniteProjectionMatrix: Matrix4 {
        get {
            update()
            return _infinitePerspective
        }
    }
    
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
    func computeCullingVolume (position: Cartesian3, direction: Cartesian3, up: Cartesian3) -> CullingVolume {
        
        var t = this.top
        var b = this.bottom
        var r = this.right
        var l = this.left
        var n = this.near
        var f = this.far
        
        var right = direction.cross(up)
        
        var nearCenter = direction.multiplyByScalar(n).add(position)
        
        var farCenter = direction.multiplyByScalar(f).add(position)
        
        var planes = [Cartesian4]()
        
        //Left plane computation
        var leftPlane = right.multiplyByScalar(l).add(nearCenter).subtract(position).normalize().cross(up)
        planes.append(Cartesian4(x: leftPlane.x, y: leftPlane.y, z: leftPlane.z, w: leftPlane.dot(position)))
        
        //Right plane computation
        var rightPlane = right.multiplyByScalar(r).add(nearCenter).subtract(position).normalize().cross(up)
        planes.append(Cartesian4(x: rightPlane.x, y: rightPlane.y, leftPlane.z, w: leftPlane.dot(position)))
        
        //Bottom plane computation
        var bottomPlane = up.multiplyByScalar(b).add(nearCenter).subtract(position).normalize().cross(right)
        planes.append(Cartesian4(x: bottomPlane.x, y: bottomPlane.y, z: bottomPlane.z, w: bottomPlane.dot(position)))
        
        //Top plane computation
        var topPlane = up.multiplyByScalar(t).add(nearCenter).subtract(position).normalize().cross(right)
        planes.append(Cartesian4(x: topPlane.x, y: topPlane.y, z: topPlane.z, w: -topPlane.dot(position)))
        
        //Near plane computation
        var nearPlane = Cartesian4(x: direction.x, y: direction.y, z: direction.z, w: -direction.dot(nearCenter))
        planes.append(nearPlane)
        
        //Far plane computation
        var farPlane = direction.negate()
        planes.append(Cartesian4(x: farPlane.x, y: farPlane.y, z: farPlane, w: -farPlane.dot(farCenter)))
        
        _cullingVolume = CullingVolume(planes: planes)
        return this._cullingVolume
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
    *
    * @example
    * // Example 2
    * // Get the width and height of a pixel if the near plane was set to 'distance'.
    * // For example, get the size of a pixel of an image on a billboard.
    * var position = camera.position;
    * var direction = camera.direction;
    * var toCenter = Cesium.Cartesian3.subtract(primitive.boundingVolume.center, position, new Cesium.Cartesian3());      // vector from camera to a primitive
    * var toCenterProj = Cesium.Cartesian3.multiplyByScalar(direction, Cesium.Cartesian3.dot(direction, toCenter), new Cesium.Cartesian3()); // project vector onto camera direction vector
    * var distance = Cesium.Cartesian3.magnitude(toCenterProj);
    * var pixelSize = camera.frustum.getPixelSize(new Cesium.Cartesian2(canvas.clientWidth, canvas.clientHeight), distance);
    */
    func pixelSize (drawingBufferDimensions: Cartesian2, distance: Double?) -> Cartesian2 {
        update()
        
        var width = drawingBufferDimensions.x
        var height = drawingBufferDimensions.y
        
        assert(width > 0 && height > 0, "drawingBufferDimensions.y must be greater than zero")
        
        distance = distance ?? this.near
        
        var inverseNear = 1.0 / near
        var tanTheta = top * inverseNear
        var pixelHeight = 2.0 * distance * tanTheta / height;
        tanTheta = right * inverseNear
        var pixelWidth = 2.0 * distance * tanTheta / width
        
        return Cartesian2(x: pixelWidth, y: pixelHeight);
    }

    /**
    * Returns a duplicate of a PerspectiveOffCenterFrustum instance.
    *
    * @param {PerspectiveOffCenterFrustum} [result] The object onto which to store the result.
    * @returns {PerspectiveOffCenterFrustum} The modified result parameter or a new PerspectiveFrustum instance if one was not provided.
    */
    /*PerspectiveOffCenterFrustum.prototype.clone = function(result) {
    if (!defined(result)) {
    result = new PerspectiveOffCenterFrustum();
    }
    
    result.right = this.right;
    result.left = this.left;
    result.top = this.top;
    result.bottom = this.bottom;
    result.near = this.near;
    result.far = this.far;
    
    // force update of clone to compute matrices
    result._left = undefined;
    result._right = undefined;
    result._top = undefined;
    result._bottom = undefined;
    result._near = undefined;
    result._far = undefined;
    
    return result;
    };*/
    
    /**
    * Compares the provided PerspectiveOffCenterFrustum componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {PerspectiveOffCenterFrustum} [other] The right hand side PerspectiveOffCenterFrustum.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    /*PerspectiveOffCenterFrustum.prototype.equals = function(other) {
    return (defined(other) &&
    this.right === other.right &&
    this.left === other.left &&
    this.top === other.top &&
    this.bottom === other.bottom &&
    this.near === other.near &&
    this.far === other.far);
    };*/
}