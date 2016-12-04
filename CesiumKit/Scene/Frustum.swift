//
//  Frustum.swift
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
* @alias Frustum
* @constructor
*
* @see PerspectiveOffCenterFrustum
*
*
* @example
* var frustum = new Cesium.PerspectiveFrustum();
* frustum.aspectRatio = canvas.clientWidth / canvas.clientHeight;
* frustum.fov = Cesium.Math.PI_OVER_THREE;
* frustum.near = 1.0;
* frustum.far = 2.0;
*/
protocol Frustum {

    /**
    * The angle of the field of view (FOV), in radians.  This angle will be used
    * as the horizontal FOV if the width is greater than the height, otherwise
    * it will be the vertical FOV.
    * @type {Number}
    * @default undefined
    */
    var fov: Double { get set }
    
    var fovy: Double { get set }

    /**
    * The aspect ratio of the frustum's width to it's height.
    * @type {Number}
    * @default undefined
    */
    var aspectRatio: Double { get set }
    
    /**
    * Defines the left clipping plane.
    * @type {Number}
    * @default undefined
    */
    var left: Double { get set }
    
    /**
    * Defines the right clipping plane.
    * @type {Number}
    * @default undefined
    */
    var right: Double { get set }
    
    /**
    * Defines the top clipping plane.
    * @type {Number}
    * @default undefined
    */
    var top: Double { get set }
    
    /**
    * Defines the bottom clipping plane.
    * @type {Number}
    * @default undefined
    */
    var bottom: Double { get set }

    /**
    * The distance of the near plane.
    * @type {Number}
    * @default 1.0
    */
    var near: Double { get set }
    
    /**
    * The distance of the far plane.
    * @type {Number}
    * @default 500000000.0
    */
    var far: Double { get set }
    
    mutating func update ()
        
    /**
    * Gets the perspective projection matrix computed from the view frustum.
    * @memberof PerspectiveFrustum.prototype
    * @type {Matrix4}
    *
    * @see PerspectiveFrustum#infiniteProjectionMatrix
    */
    var projectionMatrix: Matrix4 { get }

    /**
    * The perspective projection matrix computed from the view frustum with an infinite far plane.
    * @memberof PerspectiveFrustum.prototype
    * @type {Matrix4}
    *
    * @see PerspectiveFrustum#projectionMatrix
    */
    var infiniteProjectionMatrix: Matrix4? { get }
    
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
    func computeCullingVolume (position: Cartesian3, direction: Cartesian3, up: Cartesian3) -> CullingVolume
    
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
    * var pixelSize = camera.frustum.getPixelSize({
    *     width : canvas.clientWidth,
    *     height : canvas.clientHeight
    * });
    *
    * @example
    * // Example 2
    * // Get the width and height of a pixel if the near plane was set to 'distance'.
    * // For example, get the size of a pixel of an image on a billboard.
    * var position = camera.position;
    * var direction = camera.direction;
    * var toCenter = Cesium.Cartesian3.subtract(primitive.boundingVolume.center, position, new Cesium.Cartesian3());      // vector from camera to a primitive
    * var toCenterProj = Cesium.Cartesian3.multiplyBy(scalar: direction, Cesium.Cartesian3.dot(direction, toCenter)); // project vector onto camera direction vector
    * var distance = Cesium.Cartesian3.magnitude(toCenterProj);
    * var pixelSize = camera.frustum.getPixelSize({
    *     width : canvas.clientWidth,
    *     height : canvas.clientHeight
    * }, distance);
    */
    func pixelDimensions (drawingBufferWidth width: Int, drawingBufferHeight height: Int, distance: Double) -> Cartesian2
    
    /**
    * Returns a duplicate of a PerspectiveFrustum instance.
    *
    * @param {PerspectiveFrustum} [result] The object onto which to store the result.
    * @returns {PerspectiveFrustum} The modified result parameter or a new PerspectiveFrustum instance if one was not provided.
    */
    func clone (_ target: Frustum?) -> Frustum
    
    /**
    * Compares the provided PerspectiveFrustum componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {PerspectiveFrustum} [other] The right hand side PerspectiveFrustum.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
}

/*func == (lhs: Frustum, rhs: Frustum) -> Bool {
    assert("Invalid base class")
    return false
}*/


