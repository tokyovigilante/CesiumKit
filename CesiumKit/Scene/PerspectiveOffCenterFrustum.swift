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
// FIXME: Frustum protocol
// FIXME: Struct
class PerspectiveOffCenterFrustum: Frustum {

    var fov = Double.nan
    var fovy = Double.nan

    var aspectRatio = Double.nan

    /**
    * Defines the left clipping plane.
    * @type {Number}
    * @default undefined
    */
    var left = Double.nan
    fileprivate var _left = Double.nan

    /**
    * Defines the right clipping plane.
    * @type {Number}
    * @default undefined
    */
    var right = Double.nan
    fileprivate var _right = Double.nan

    /**
    * Defines the top clipping plane.
    * @type {Number}
    * @default undefined
    */
    var top = Double.nan
    fileprivate var _top = Double.nan

    /**
    * Defines the bottom clipping plane.
    * @type {Number}
    * @default undefined
    */
    var bottom = Double.nan
    fileprivate var _bottom = Double.nan

    /**
    * The distance of the near plane.
    * @type {Number}
    * @default 1.0
    */
    var near = 1.0

    fileprivate var _near = Double.nan

    /**
    * The distance of the far plane.
    * @type {Number}
    * @default 500000000.0
    */
    var far = 500000000.0

    fileprivate var _far = Double.nan

    fileprivate var _cullingVolume = CullingVolume()

    fileprivate var _perspectiveMatrix = Matrix4()

    fileprivate var _infinitePerspective = Matrix4()

    func update () {

        if top != _top || bottom != _bottom || left != _left ||
            right != _right || near != _near || far != _far {
                assert(near > 0 && near < far, "near must be greater than zero and less than far")

                _left = left
                _right = right
                _top = top
                _bottom = bottom
                _near = near
                _far = far
                _perspectiveMatrix = Matrix4.computePerspectiveOffCenter(left: left, right: right, bottom: bottom, top: top, near: near, far: far)
                _infinitePerspective = Matrix4.computeInfinitePerspectiveOffCenter(left: left, right: right, bottom: bottom, top: top, near: near)
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
    var infiniteProjectionMatrix: Matrix4? {
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

        let right2 = direction.cross(up)

        let nearCenter = direction.multiplyBy(scalar: near).add(position)

        let farCenter = direction.multiplyBy(scalar: far).add(position)

        var planes = [Cartesian4]()

        //Left plane computation
        let leftPlane = right2.multiplyBy(scalar: left).add(nearCenter).subtract(position).normalize().cross(up)
        planes.append(Cartesian4(x: leftPlane.x, y: leftPlane.y, z: leftPlane.z, w: -leftPlane.dot(position)))

        //Right plane computation
        let rightPlane = up.cross(right2.multiplyBy(scalar: right).add(nearCenter).subtract(position).normalize())
        planes.append(Cartesian4(x: rightPlane.x, y: rightPlane.y, z: rightPlane.z, w: -rightPlane.dot(position)))

        //Bottom plane computation
        let bottomPlane = right2.cross(up.multiplyBy(scalar: bottom).add(nearCenter).subtract(position).normalize())
        planes.append(Cartesian4(x: bottomPlane.x, y: bottomPlane.y, z: bottomPlane.z, w: -bottomPlane.dot(position)))

        //Top plane computation
        let topPlane = up.multiplyBy(scalar: top).add(nearCenter).subtract(position).normalize().cross(right2)
        planes.append(Cartesian4(x: topPlane.x, y: topPlane.y, z: topPlane.z, w: -topPlane.dot(position)))

        //Near plane computation
        let nearPlane = Cartesian4(x: direction.x, y: direction.y, z: direction.z, w: -direction.dot(nearCenter))
        planes.append(nearPlane)

        //Far plane computation
        let farPlane = direction.negate()
        planes.append(Cartesian4(x: farPlane.x, y: farPlane.y, z: farPlane.z, w: -farPlane.dot(farCenter)))

        _cullingVolume = CullingVolume(planes: planes)
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
    *
    * @example
    * // Example 2
    * // Get the width and height of a pixel if the near plane was set to 'distance'.
    * // For example, get the size of a pixel of an image on a billboard.
    * var position = camera.position;
    * var direction = camera.direction;
    * var toCenter = Cesium.Cartesian3.subtract(primitive.boundingVolume.center, position, new Cesium.Cartesian3());      // vector from camera to a primitive
    * var toCenterProj = Cesium.Cartesian3.multiplyBy(scalar: direction, Cesium.Cartesian3.dot(direction, toCenter), new Cesium.Cartesian3()); // project vector onto camera direction vector
    * var distance = Cesium.Cartesian3.magnitude(toCenterProj);
    * var pixelSize = camera.frustum.getPixelSize(new Cesium.Cartesian2(canvas.clientWidth, canvas.clientHeight), distance);
    */
    func pixelDimensions (drawingBufferWidth width: Int, drawingBufferHeight height: Int, distance: Double) -> Cartesian2 {
        update()

        assert(width > 0 && height > 0, "drawingBufferDimensions.y must be greater than zero")

        let localDistance = distance ?? near

        let inverseNear = 1.0 / near
        var tanTheta = top * inverseNear
        let pixelHeight = 2.0 * localDistance * tanTheta / Double(height)
        tanTheta = right * inverseNear
        let pixelWidth = 2.0 * localDistance * tanTheta / Double(width)

        return Cartesian2(x: pixelWidth, y: pixelHeight)
    }

    /**
    * Returns a duplicate of a PerspectiveOffCenterFrustum instance.
    *
    * @param {PerspectiveOffCenterFrustum} [result] The object onto which to store the result.
    * @returns {PerspectiveOffCenterFrustum} The modified result parameter or a new PerspectiveFrustum instance if one was not provided.
    */
    func clone(_ target: Frustum?) -> Frustum {

        var result = target ?? PerspectiveOffCenterFrustum()

        // force update of clone to compute matrices
        result.right = right
        result.left = left
        result.top = top
        result.bottom = bottom
        result.near = near
        result.far = far

        return result
    }

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
