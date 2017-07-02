//
//  Occluder.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


/**
* Creates an Occluder derived from an object's position and radius, as well as the camera position.
* The occluder can be used to determine whether or not other objects are visible or hidden behind the
* visible horizon defined by the occluder and camera position.
*
* @alias Occluder
*
* @param {BoundingSphere} occluderBoundingSphere The bounding sphere surrounding the occluder.
* @param {Cartesian3} cameraPosition The coordinate of the viewer/camera.
*
* @constructor
*
* @example
* // Construct an occluder one unit away from the origin with a radius of one.
* var cameraPosition = new Cesium.Cartesian3.ZERO;
* var occluderBoundingSphere = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -1), 1);
* var occluder = new Cesium.Occluder(occluderBoundingSphere, cameraPosition);
*/
class Occluder {
    
    /**
    * The position of the occluder.
    * @memberof Occluder.prototype
    * @type {Cartesian3}
    */
    var occluderPosition: Cartesian3
    
    /**
    * The radius of the occluder.
    * @memberof Occluder.prototype
    * @type {Number}
    */
    var occluderRadius: Double
    
    /**
    * The position of the camera.
    * @memberof Occluder.prototype
    * @type {Cartesian3}
    */
    var cameraPosition: Cartesian3 {
    didSet { updateCameraPosition() }
    }
    
    var horizonDistance: Double
    
    var horizonPlaneNormal: Cartesian3
    
    var horizonPlanePosition: Cartesian3
    
    /**
    * Creates an occluder from a bounding sphere and the camera position.
    *
    * @param {BoundingSphere} occluderBoundingSphere The bounding sphere surrounding the occluder.
    * @param {Cartesian3} cameraPosition The coordinate of the viewer/camera.
    * @param {Occluder} [result] The object onto which to store the result.
    * @returns {Occluder} The occluder derived from an object's position and radius, as well as the camera position.
    */
    init(occluderBoundingSphere: BoundingSphere, cameraPosition: Cartesian3) {
        self.occluderPosition = occluderBoundingSphere.center
        self.occluderRadius = occluderBoundingSphere.radius
        
        self.horizonDistance = Double.infinity
        
        // cameraPosition fills in the above values
        self.cameraPosition = cameraPosition
        self.horizonPlaneNormal = Cartesian3.zero
        self.horizonPlanePosition = Cartesian3.zero
        updateCameraPosition()
    }
    
    func updateCameraPosition() {
        let cameraToOccluderVec = occluderPosition.subtract(cameraPosition)
        var invCameraToOccluderDistance = cameraToOccluderVec.magnitudeSquared
        let occluderRadiusSqrd = occluderRadius * occluderRadius
        
        if (invCameraToOccluderDistance > occluderRadiusSqrd) {
            
            horizonDistance = sqrt(invCameraToOccluderDistance - occluderRadiusSqrd)
            invCameraToOccluderDistance = 1.0 / sqrt(invCameraToOccluderDistance)
            horizonPlaneNormal = cameraToOccluderVec.multiplyBy(scalar: invCameraToOccluderDistance)
            let nearPlaneDistance = horizonDistance * horizonDistance * invCameraToOccluderDistance
            horizonPlanePosition = cameraPosition.add(horizonPlaneNormal.multiplyBy(scalar: nearPlaneDistance))
        }
        else {
            horizonDistance = Double.infinity
        }
    }
    
    /**
    * Determines whether or not a point, the <code>occludee</code>, is hidden from view by the occluder.
    *
    * @param {Cartesian3} occludee The point surrounding the occludee object.
    * @returns {Boolean} <code>true</code> if the occludee is visible; otherwise <code>false</code>.
    *
    * @see Occluder#getVisibility
    *
    * @example
    * var cameraPosition = new Cesium.Cartesian3(0, 0, 0);
    * var littleSphere = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -1), 0.25);
    * var occluder = new Cesium.Occluder(littleSphere, cameraPosition);
    * var point = new Cesium.Cartesian3(0, 0, -3);
    * occluder.isPointVisible(point); //returns true
    */
    func isPointVisible(_ occludee: Cartesian3) -> Bool {
        if horizonDistance < Double.infinity {
            var tempVec = occludee.subtract(occluderPosition)
            var temp = tempVec.magnitudeSquared - (occluderRadius * occluderRadius)
            if (temp > 0.0) {
                temp = sqrt(temp) + horizonDistance
                tempVec = occludee.subtract(cameraPosition)
                return temp * temp > tempVec.magnitudeSquared
            }
        }
        return false
    }

    
    
    /**
    * Determines whether or not a sphere, the <code>occludee</code>, is hidden from view by the occluder.
    *
    * @param {BoundingSphere} occludee The bounding sphere surrounding the occludee object.
    * @returns {Boolean} <code>true</code> if the occludee is visible; otherwise <code>false</code>.
    *
    * @see Occluder#getVisibility
    *
    * @example
    * var cameraPosition = new Cesium.Cartesian3(0, 0, 0);
    * var littleSphere = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -1), 0.25);
    * var occluder = new Cesium.Occluder(littleSphere, cameraPosition);
    * var bigSphere = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -3), 1);
    * occluder.isBoundingSphereVisible(bigSphere); //returns true
    */
    func isBoundingSphereVisible(_ occludee: BoundingSphere) -> Bool {
        let occludeePosition = occludee.center
        let occludeeRadius = occludee.radius
        
        if (self.horizonDistance < Double.infinity) {
            var tempVec = occludeePosition.subtract(occluderPosition)
            var temp = occluderRadius - occludeeRadius;
            temp = tempVec.magnitudeSquared - (temp * temp)
            if (occludeeRadius < occluderRadius) {
                if (temp > 0.0) {
                    temp = sqrt(temp) + horizonDistance
                    tempVec = occludeePosition.subtract(cameraPosition)
                    return (temp * temp) + (occludeeRadius * occludeeRadius) > tempVec.magnitudeSquared
                }
                return false
            }
            
            // Prevent against the case where the occludee radius is larger than the occluder's; since this is
            // an uncommon case, the following code should rarely execute.
            if (temp > 0.0) {
                tempVec = occludeePosition.subtract(cameraPosition)
                let tempVecMagnitudeSquared = tempVec.magnitudeSquared
                let occluderRadiusSquared = occluderRadius * occluderRadius
                let occludeeRadiusSquared = occludeeRadius * occludeeRadius
                if ((((horizonDistance * horizonDistance) + occluderRadiusSquared) * occludeeRadiusSquared) >
                    (tempVecMagnitudeSquared * occluderRadiusSquared)) {
                        // The occludee is close enough that the occluder cannot possible occlude the occludee
                        return true
                }
                temp = sqrt(temp) + horizonDistance
                return ((temp * temp) + occludeeRadiusSquared) > tempVecMagnitudeSquared
            }
            
            // The occludee completely encompasses the occluder
            return true
        }
        
        return false
    }
    
    /**
    * Determine to what extent an occludee is visible (not visible, partially visible,  or fully visible).
    *
    * @param {BoundingSphere} occludeeBS The bounding sphere of the occludee.
    * @returns {Number} Visibility.NONE if the occludee is not visible,
    *                       Visibility.PARTIAL if the occludee is partially visible, or
    *                       Visibility.FULL if the occludee is fully visible.
    *
    * @see Occluder#isVisible
    *
    * @example
    * var sphere1 = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -1.5), 0.5);
    * var sphere2 = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -2.5), 0.5);
    * var cameraPosition = new Cesium.Cartesian3(0, 0, 0);
    * var occluder = new Cesium.Occluder(sphere1, cameraPosition);
    * occluder.getVisibility(sphere2); //returns Visibility.NONE
    */
    func getVisibility(_ occludeeBS: BoundingSphere) -> Visibility {
    
        // If the occludee radius is larger than the occluders, this will return that
        // the entire ocludee is visible, even though that may not be the case, though this should
        // not occur too often.
        let occludeePosition = occludeeBS.center
        let occludeeRadius = occludeeBS.radius
        
        if (occludeeRadius > occluderRadius) {
            return Visibility.full
        }
        
        if (self.horizonDistance < Double.infinity) {
            // The camera is outside the occluder
            var tempVec = occludeePosition.subtract(occluderPosition)
            var temp = occluderRadius - occludeeRadius
            let occluderToOccludeeDistSqrd = tempVec.magnitudeSquared
            temp = occluderToOccludeeDistSqrd - (temp * temp)
            if (temp > 0.0) {
                // The occludee is not completely inside the occluder
                // Check to see if the occluder completely hides the occludee
                temp = sqrt(temp) + horizonDistance;
                tempVec = occludeePosition.subtract(cameraPosition)
                let cameraToOccludeeDistSqrd = tempVec.magnitudeSquared
                if (((temp * temp) + (occludeeRadius * occludeeRadius)) < cameraToOccludeeDistSqrd) {
                    return Visibility.none
                }
                
                // Check to see whether the occluder is fully or partially visible
                // when the occludee does not intersect the occluder
                temp = occluderRadius + occludeeRadius
                temp = occluderToOccludeeDistSqrd - (temp * temp)
                if (temp > 0.0) {
                    // The occludee does not intersect the occluder.
                    temp = sqrt(temp) + horizonDistance
                    return (cameraToOccludeeDistSqrd < ((temp * temp)) + (occludeeRadius * occludeeRadius)) ? Visibility.full : Visibility.partial
                }
                
                //Check to see if the occluder is fully or partially visible when the occludee DOES
                //intersect the occluder
                tempVec = occludeePosition.subtract(horizonPlanePosition)
                return (tempVec.dot(horizonPlaneNormal) > -occludeeRadius) ? Visibility.partial : Visibility.full
            }
        }
        return Visibility.none
    };

    /**
     * Computes a point that can be used as the occludee position to the visibility functions.
     * Use a radius of zero for the occludee radius.  Typically, a user computes a bounding sphere around
     * an object that is used for visibility; however it is also possible to compute a point that if
     * seen/not seen would also indicate if an object is visible/not visible.  This function is better
     * called for objects that do not move relative to the occluder and is large, such as a chunk of
     * terrain.  You are better off not calling this and using the object's bounding sphere for objects
     * such as a satellite or ground vehicle.
     *
     * @param {BoundingSphere} occluderBoundingSphere The bounding sphere surrounding the occluder.
     * @param {Cartesian3} occludeePosition The point where the occludee (bounding sphere of radius 0) is located.
     * @param {Cartesian3[]} positions List of altitude points on the horizon near the surface of the occluder.
     * @returns {Cartesian3?} An optional Cartesian3 representing the <code>occludeePoint</code>.
     *
     * @exception {DeveloperError} <code>positions</code> must contain at least one element.
     * @exception {DeveloperError} <code>occludeePosition</code> must have a value other than <code>occluderBoundingSphere.center</code>.
     *
     * @example
     * var cameraPosition = new Cesium.Cartesian3(0, 0, 0);
     * var occluderBoundingSphere = new Cesium.BoundingSphere(new Cesium.Cartesian3(0, 0, -8), 2);
     * var occluder = new Cesium.Occluder(occluderBoundingSphere, cameraPosition);
     * var positions = [new Cesium.Cartesian3(-0.25, 0, -5.3), new Cesium.Cartesian3(0.25, 0, -5.3)];
     * var tileOccluderSphere = Cesium.BoundingSphere.fromPoints(positions);
     * var occludeePosition = tileOccluderSphere.center;
     * var occludeePt = occluder.getOccludeePoint(occluderBoundingSphere, occludeePosition, positions);
     */
    func computeOccludeePoint (_ occluderBoundingSphere: BoundingSphere, occludeePosition: Cartesian3, positions: [Cartesian3]) -> Cartesian3? {
        assert(!positions.isEmpty, "positions must contain at least one element")
        
        let occluderPosition = occluderBoundingSphere.center
        let occluderRadius = occluderBoundingSphere.radius
        
        assert(occluderPosition != occludeePosition, "occludeePosition must be different than occluderBoundingSphere.center")
        
        // Compute a plane with a normal from the occluder to the occludee position.
        let occluderPlaneNormal = occludeePosition.subtract(occluderPosition).normalize()
        let occluderPlaneD = -occluderPlaneNormal.dot(occluderPosition)
        
        //For each position, determine the horizon intersection. Choose the position and intersection
        //that results in the greatest angle with the occcluder plane.
        let aRotationVector = anyRotationVector(occluderPosition, occluderPlaneNormal: occluderPlaneNormal, occluderPlaneD: occluderPlaneD)
        
        var dot: Double! = horizonToPlaneNormalDotProduct(
            occluderBoundingSphere,
            occluderPlaneNormal: occluderPlaneNormal,
            occluderPlaneD: occluderPlaneD,
            anyRotationVector: aRotationVector,
            position: positions[0]
        )
        if dot == nil {
            //The position is inside the mimimum radius, which is invalid
            return nil
        }
        var tempDot: Double?
        for position in positions {
            tempDot = horizonToPlaneNormalDotProduct(
                occluderBoundingSphere,
                occluderPlaneNormal: occluderPlaneNormal,
                occluderPlaneD: occluderPlaneD,
                anyRotationVector: aRotationVector,
                position: position
            )
            if tempDot == nil  {
                //The position is inside the minimum radius, which is invalid
                return nil
            }
            if tempDot < dot {
                dot = tempDot!
            }
        }
        //Verify that the dot is not near 90 degress
        if dot < 0.00174532836589830883577820272085 {
            return nil
        }
        
        let distance = occluderRadius / dot
        return occluderPosition.add(occluderPlaneNormal.multiplyBy(scalar: distance))
    }


     /**
* Computes a point that can be used as the occludee position to the visibility functions from an rectangle.
*
* @param {Rectangle} rectangle The rectangle used to create a bounding sphere.
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid used to determine positions of the rectangle.
* @returns {Object} An object containing two attributes: <code>occludeePoint</code> and <code>valid</code>
* which is a boolean value.
*/
    func computeOccludeePointFromRectangle (_ rectangle: Rectangle, ellipsoid: Ellipsoid = Ellipsoid.wgs84) -> Cartesian3? {
        
        let positions = rectangle.subsample(ellipsoid, surfaceHeight: 0.0)
        let bs = BoundingSphere(fromPoints: positions)
        
        // TODO: get correct ellipsoid center
        let ellipsoidCenter = Cartesian3.zero
        if ellipsoidCenter != bs.center {
            return computeOccludeePoint(
                BoundingSphere(
                    center: ellipsoidCenter,
                    radius: ellipsoid.minimumRadius),
                occludeePosition: bs.center,
                positions: positions)
        }
        
        return nil
    }

    fileprivate func anyRotationVector (_ occluderPosition: Cartesian3, occluderPlaneNormal: Cartesian3, occluderPlaneD: Double) -> Cartesian3 {
        var tempVec0 = occluderPlaneNormal.absolute()
        var majorAxis = tempVec0.x > tempVec0.y ? 0 : 1
        if (majorAxis == 0 && tempVec0.z > tempVec0.x) || (majorAxis == 1 && tempVec0.z > tempVec0.y) {
            majorAxis = 2
        }
        let tempVec1: Cartesian3
        if majorAxis == 0 {
            tempVec0.x = occluderPosition.x
            tempVec0.y = occluderPosition.y + 1.0
            tempVec0.z = occluderPosition.z + 1.0
            tempVec1 = Cartesian3.unitX
        } else if majorAxis == 1 {
            tempVec0.x = occluderPosition.x + 1.0
            tempVec0.y = occluderPosition.y
            tempVec0.z = occluderPosition.z + 1.0
            tempVec1 = Cartesian3.unitY
        } else {
            tempVec0.x = occluderPosition.x + 1.0
            tempVec0.y = occluderPosition.y + 1.0
            tempVec0.z = occluderPosition.z
            tempVec1 = Cartesian3.unitZ
        }
        let u = (occluderPlaneNormal.dot(tempVec0) + occluderPlaneD) / -occluderPlaneNormal.dot(tempVec1)
        return tempVec0
            .add(tempVec1.multiplyBy(scalar: u))
            .subtract(occluderPosition)
            .normalize()
    }

    func rotationVector (_ occluderPosition: Cartesian3, occluderPlaneNormal: Cartesian3, occluderPlaneD: Double, position: Cartesian3, anyRotationVector: Cartesian3) -> Cartesian3 {
        //Determine the angle between the occluder plane normal and the position direction
        let positionDirection = position.subtract(occluderPosition).normalize()
        if occluderPlaneNormal.dot(positionDirection) < 0.99999998476912904932780850903444 {
            let crossProduct = occluderPlaneNormal.cross(positionDirection)
            let length = crossProduct.magnitude
            if length > Math.Epsilon13 {
                return crossProduct.normalize()
            }
        }
        //The occluder plane normal and the position direction are colinear. Use any
        //vector in the occluder plane as the rotation vector
        return anyRotationVector
    }


    fileprivate func horizonToPlaneNormalDotProduct (_ occluderBS: BoundingSphere, occluderPlaneNormal: Cartesian3, occluderPlaneD: Double, anyRotationVector: Cartesian3, position: Cartesian3) -> Double? {

        let occluderPosition = occluderBS.center
        let occluderRadius = occluderBS.radius
        
        //Verify that the position is outside the occluder
        var positionToOccluder = occluderPosition.subtract(position)
        let occluderToPositionDistanceSquared = positionToOccluder.magnitudeSquared
        let occluderRadiusSquared = occluderRadius * occluderRadius
        if occluderToPositionDistanceSquared < occluderRadiusSquared {
            return nil
        }
        
        //Horizon parameters
        let horizonDistanceSquared = occluderToPositionDistanceSquared - occluderRadiusSquared
        let horizonDistance = sqrt(horizonDistanceSquared)
        let occluderToPositionDistance = sqrt(occluderToPositionDistanceSquared)
        let invOccluderToPositionDistance = 1.0 / occluderToPositionDistance
        let cosTheta = horizonDistance * invOccluderToPositionDistance
        let horizonPlaneDistance = cosTheta * horizonDistance
        positionToOccluder = positionToOccluder.normalize()
        let horizonPlanePosition = position.add(positionToOccluder.multiplyBy(scalar: horizonPlaneDistance))
        let horizonCrossDistance = sqrt(horizonDistanceSquared - (horizonPlaneDistance * horizonPlaneDistance))
        
        //Rotate the position to occluder vector 90 degrees
        var tempVec = rotationVector(occluderPosition, occluderPlaneNormal: occluderPlaneNormal, occluderPlaneD: occluderPlaneD, position: position, anyRotationVector: anyRotationVector)
        let x = (tempVec.x * tempVec.x * positionToOccluder.x) + ((tempVec.x * tempVec.y - tempVec.z) * positionToOccluder.y) + ((tempVec.x * tempVec.z + tempVec.y) * positionToOccluder.z)
        let y = ((tempVec.x * tempVec.y + tempVec.z) * positionToOccluder.x) + (tempVec.y * tempVec.y * positionToOccluder.y) + ((tempVec.y * tempVec.z - tempVec.x) * positionToOccluder.z)
        let z = ((tempVec.x * tempVec.z - tempVec.y) * positionToOccluder.x) + ((tempVec.y * tempVec.z + tempVec.x) * positionToOccluder.y) + (tempVec.z * tempVec.z * positionToOccluder.z)
        let horizonCrossDirection = Cartesian3(x: x, y: y, z: z).normalize()
        
        //Horizon positions
        let offset = horizonCrossDirection.multiplyBy(scalar: horizonCrossDistance)
        tempVec = horizonPlanePosition
            .add(offset)
            .subtract(occluderPosition)
            .normalize()
        let dot0 = occluderPlaneNormal.dot(tempVec)
        tempVec = horizonPlanePosition
            .subtract(offset)
            .subtract(occluderPosition)
            .normalize()
        let dot1 = occluderPlaneNormal.dot(tempVec)
        return (dot0 < dot1) ? dot0 : dot1
    }

}
