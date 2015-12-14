//
//  OrientedBoundingBox.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

/**
* Creates an instance of an OrientedBoundingBox.
* An OrientedBoundingBox of some object is a closed and convex cuboid. It can provide a tighter bounding volume than {@link BoundingSphere} or {@link AxisAlignedBoundingBox} in many cases.
* @alias OrientedBoundingBox
* @constructor
*
* @param {Cartesian3} [center=Cartesian3.ZERO] The center of the box.
* @param {Matrix3} [halfAxes=Matrix3.ZERO] The three orthogonal half-axes of the bounding box.
*                                          Equivalently, the transformation matrix, to rotate and scale a 2x2x2
*                                          cube centered at the origin.
*
* @see BoundingSphere
* @see BoundingRectangle
*
* @example
* // Create an OrientedBoundingBox using a transformation matrix, a position where the box will be translated, and a scale.
* var center = new Cesium.Cartesian3(1.0, 0.0, 0.0);
* var halfAxes = Cesium.Matrix3.fromScale(new Cesium.Cartesian3(1.0, 3.0, 2.0), new Cesium.Matrix3());
*
* var obb = new Cesium.OrientedBoundingBox(center, halfAxes);
*/
struct OrientedBoundingBox: BoundingVolume {
    
    /**
    * The center of the box.
    * @type {Cartesian3}
    * @default {@link Cartesian3.ZERO}
    */
    private (set) var center = Cartesian3.zero
    /**
    * The transformation matrix, to rotate the box to the right position.
    * @type {Matrix3}
    * @default {@link Matrix3.IDENTITY}
    */
    private (set) var halfAxes = Matrix3.zero
    
    /**
    * Computes an instance of an OrientedBoundingBox of the given positions.
    * This is an implementation of Stefan Gottschalk's Collision Queries using Oriented Bounding Boxes solution (PHD thesis).
    * Reference: http://gamma.cs.unc.edu/users/gottschalk/main.pdf
    *
    * @param {Cartesian3[]} positions List of {@link Cartesian3} points that the bounding box will enclose.
    * @param {OrientedBoundingBox} [result] The object onto which to store the result.
    * @returns {OrientedBoundingBox} The modified result parameter or a new OrientedBoundingBox instance if one was not provided.
    *
    * @example
    * // Compute an object oriented bounding box enclosing two points.
    * var box = Cesium.OrientedBoundingBox.fromPoints([new Cesium.Cartesian3(2, 0, 0), new Cesium.Cartesian3(-2, 0, 0)]);
    */
    init(fromPoints positions: [Cartesian3]) {
        // FIXME: fromPoints
        /*
        if positions.count == 0 {
            //center = Cartesian3.zero()
            //halfAxes = Matrix3.zero()
            return
        }
        
        var length = positions.length;
        
        var meanPoint = Cartesian3.clone(positions[0], scratchCartesian1);
        for (i = 1; i < length; i++) {
            Cartesian3.add(meanPoint, positions[i], meanPoint);
        }
        var invLength = 1.0 / length;
        Cartesian3.multiplyByScalar(meanPoint, invLength, meanPoint);
        
        var exx = 0.0;
        var exy = 0.0;
        var exz = 0.0;
        var eyy = 0.0;
        var eyz = 0.0;
        var ezz = 0.0;
        var p;
        
        for (i = 0; i < length; i++) {
            p = Cartesian3.subtract(positions[i], meanPoint, scratchCartesian2);
            exx += p.x * p.x;
            exy += p.x * p.y;
            exz += p.x * p.z;
            eyy += p.y * p.y;
            eyz += p.y * p.z;
            ezz += p.z * p.z;
        }
        
        exx *= invLength;
        exy *= invLength;
        exz *= invLength;
        eyy *= invLength;
        eyz *= invLength;
        ezz *= invLength;
        
        var covarianceMatrix = scratchCovarianceResult;
        covarianceMatrix[0] = exx;
        covarianceMatrix[1] = exy;
        covarianceMatrix[2] = exz;
        covarianceMatrix[3] = exy;
        covarianceMatrix[4] = eyy;
        covarianceMatrix[5] = eyz;
        covarianceMatrix[6] = exz;
        covarianceMatrix[7] = eyz;
        covarianceMatrix[8] = ezz;
        
        var eigenDecomposition = Matrix3.computeEigenDecomposition(covarianceMatrix, scratchEigenResult);
        var rotation = Matrix3.transpose(eigenDecomposition.unitary, result.halfAxes);
        
        p = Cartesian3.subtract(positions[0], meanPoint, scratchCartesian2);
        var tempPoint = Matrix3.multiplyByVector(rotation, p, scratchCartesian3);
        var maxPoint = Cartesian3.clone(tempPoint, scratchCartesian4);
        var minPoint = Cartesian3.clone(tempPoint, scratchCartesian5);
        
        for (i = 1; i < length; i++) {
            p = Cartesian3.subtract(positions[i], meanPoint, p);
            Matrix3.multiplyByVector(rotation, p, tempPoint);
            Cartesian3.minimumByComponent(minPoint, tempPoint, minPoint);
            Cartesian3.maximumByComponent(maxPoint, tempPoint, maxPoint);
        }
        
        var center = Cartesian3.add(minPoint, maxPoint, scratchCartesian3);
        Cartesian3.multiplyByScalar(center, 0.5, center);
        Matrix3.multiplyByVector(rotation, center, center);
        Cartesian3.add(meanPoint, center, result.center);
        
        var scale = Cartesian3.subtract(maxPoint, minPoint, scratchCartesian3);
        Cartesian3.multiplyByScalar(scale, 0.5, scale);
        Matrix3.multiplyByScale(result.halfAxes, scale, result.halfAxes);
        
        return result;*/
    }
    
    /**
    * Computes an OrientedBoundingBox given extents in the east-north-up space of the tangent plane.
    *
    * @param {Number} minimumX Minimum X extent in tangent plane space.
    * @param {Number} maximumX Maximum X extent in tangent plane space.
    * @param {Number} minimumY Minimum Y extent in tangent plane space.
    * @param {Number} maximumY Maximum Y extent in tangent plane space.
    * @param {Number} minimumZ Minimum Z extent in tangent plane space.
    * @param {Number} maximumZ Maximum Z extent in tangent plane space.
    * @param {OrientedBoundingBox} [result] The object onto which to store the result.
    * @returns {OrientedBoundingBox} The modified result parameter or a new OrientedBoundingBox instance if one was not provided.
    */
    init (fromTangentPlaneExtents tangentPlane: EllipsoidTangentPlane, minimumX: Double, maximumX: Double, minimumY: Double, maximumY: Double, minimumZ: Double, maximumZ: Double) {
        
        var halfAxes = Matrix3()
        halfAxes = halfAxes.setColumn(0, cartesian: tangentPlane.xAxis)
        halfAxes = halfAxes.setColumn(1, cartesian: tangentPlane.yAxis)
        halfAxes = halfAxes.setColumn(2, cartesian: tangentPlane.zAxis)
        
        var centerOffset = Cartesian3(x: (minimumX + maximumX) / 2.0, y: (minimumY + maximumY) / 2.0, z: (minimumZ + maximumZ) / 2.0)
        let scale = Cartesian3(x: (maximumX - minimumX) / 2.0, y: (maximumY - minimumY) / 2.0, z: (maximumZ - minimumZ) / 2.0)
        
        centerOffset = halfAxes.multiplyByVector(centerOffset)
        center = tangentPlane.origin.add(centerOffset)
        halfAxes = halfAxes.multiplyByScale(scale)
        
        self.halfAxes = halfAxes
    }
    
    /**
    * Computes an OrientedBoundingBox that bounds a {@link Rectangle} on the surface of an {@link Ellipsoid}.
    * There are no guarantees about the orientation of the bounding box.
    *
    * @param {Rectangle} rectangle The cartographic rectangle on the surface of the ellipsoid.
    * @param {Number} [minimumHeight=0.0] The minimum height (elevation) within the tile.
    * @param {Number} [maximumHeight=0.0] The maximum height (elevation) within the tile.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the rectangle is defined.
    * @param {OrientedBoundingBox} [result] The object onto which to store the result.
    * @returns {OrientedBoundingBox} The modified result parameter or a new OrientedBoundingBox instance if none was provided.
    *
    * @exception {DeveloperError} rectangle.width must be between 0 and pi.
    * @exception {DeveloperError} rectangle.height must be between 0 and pi.
    * @exception {DeveloperError} ellipsoid must be an ellipsoid of revolution (<code>radii.x == radii.y</code>)
    */
    
    init (fromRectangle rectangle: Rectangle, minimumHeight: Double = 0.0, maximumHeight: Double = 0.0, ellipsoid: Ellipsoid = Ellipsoid.wgs84()) {
        
        if rectangle.width < 0.0 || rectangle.width > M_PI {
            fatalError("Rectangle width must be between 0 and pi")
        }
        if rectangle.height < 0.0 || rectangle.height > M_PI {
            fatalError("Rectangle height must be between 0 and pi")
        }
        if !Math.equalsEpsilon(ellipsoid.radii.x, ellipsoid.radii.y, relativeEpsilon: Math.Epsilon15) {
            fatalError("Ellipsoid must be an ellipsoid of revolution (radii.x == radii.y)")
        }
        
        // The bounding box will be aligned with the tangent plane at the center of the rectangle.
        let tangentPointCartographic = rectangle.center()
        let tangentPoint = ellipsoid.cartographicToCartesian(tangentPointCartographic)
        let tangentPlane = EllipsoidTangentPlane(origin: tangentPoint, ellipsoid: ellipsoid)
        let plane = tangentPlane.plane
        
        let lonCenter = tangentPointCartographic.longitude
        let latCenter = (rectangle.south < 0.0 && rectangle.north > 0.0) ? 0.0 : tangentPointCartographic.latitude
        
        // Corner arrangement:
        //          N/+y
        //      [0] [1] [2]
        // W/-x [7]     [3] E/+x
        //      [6] [5] [4]
        //          S/-y
        // "C" refers to the central lat/long, which by default aligns with the tangent point (above).
        // If the rectangle spans the equator, CW and CE are instead aligned with the equator.
        // Compute XY extents using the rectangle at maximum height

        let cartographicArray = [
            Cartographic(longitude: rectangle.west, latitude: rectangle.north, height: maximumHeight), // perimeterNW
            Cartographic(longitude: lonCenter, latitude: rectangle.north, height: maximumHeight), // perimeterNC
            Cartographic(longitude: rectangle.east, latitude: rectangle.north, height: maximumHeight), // perimeterNE
            Cartographic(longitude: rectangle.east, latitude: latCenter, height: maximumHeight), // perimeterCE
            Cartographic(longitude: rectangle.east, latitude: rectangle.south, height: maximumHeight), // perimeterSE
            Cartographic(longitude: lonCenter, latitude: rectangle.south, height: maximumHeight), // perimeterSC
            Cartographic(longitude: rectangle.west, latitude: rectangle.south, height: maximumHeight), // perimeterSW
            Cartographic(longitude: rectangle.west, latitude: latCenter, height: maximumHeight) // perimeterCW
        ]
        
        let perimeterCartesian = ellipsoid.cartographicArrayToCartesianArray(cartographicArray)
        let perimeterProjected = tangentPlane.projectPointsToNearestOnPlane(perimeterCartesian)
        
        assert(perimeterProjected.count == 8, "invalid perimeter")
        // See the `perimeterXX` definitions above for what these are
        let minX = min(perimeterProjected[6].x, perimeterProjected[7].x, perimeterProjected[0].x)
        let maxX = max(perimeterProjected[2].x, perimeterProjected[3].x, perimeterProjected[4].x)
        let minY = min(perimeterProjected[4].y, perimeterProjected[5].y, perimeterProjected[6].y)
        let maxY = max(perimeterProjected[0].y, perimeterProjected[1].y, perimeterProjected[2].y)
        
        // Compute minimum Z using the rectangle at minimum height
        let cartographicMinHeightArray = cartographicArray.map({ Cartographic(longitude: $0.longitude, latitude: $0.latitude, height: minimumHeight) })
        let perimeterMinHeightCartesian = ellipsoid.cartographicArrayToCartesianArray(cartographicMinHeightArray)
        let minZ = min(
            plane.getPointDistance(perimeterMinHeightCartesian[0]),
            plane.getPointDistance(perimeterMinHeightCartesian[2]),
            plane.getPointDistance(perimeterMinHeightCartesian[4]),
            plane.getPointDistance(perimeterMinHeightCartesian[6]))
        let maxZ = maximumHeight  // Since the tangent plane touches the surface at height = 0, this is okay
        
        self.init(fromTangentPlaneExtents: tangentPlane, minimumX: minX, maximumX: maxX, minimumY: minY, maximumY: maxY, minimumZ: minZ, maximumZ: maxZ)
    }
    /*
    /**
    * Duplicates a OrientedBoundingBox instance.
    *
    * @param {OrientedBoundingBox} box The bounding box to duplicate.
    * @param {OrientedBoundingBox} [result] The object onto which to store the result.
    * @returns {OrientedBoundingBox} The modified result parameter or a new OrientedBoundingBox instance if none was provided. (Returns undefined if box is undefined)
    */
    OrientedBoundingBox.clone = function(box, result) {
    if (!defined(box)) {
    return undefined;
    }
    
    if (!defined(result)) {
    return new OrientedBoundingBox(box.center, box.halfAxes);
    }
    
    Cartesian3.clone(box.center, result.center);
    Matrix3.clone(box.halfAxes, result.halfAxes);
    
    return result;
    };
    */
    /**
    * Determines which side of a plane the oriented bounding box is located.
    *
    * @param {OrientedBoundingBox} box The oriented bounding box to test.
    * @param {Plane} plane The plane to test against.
    * @returns {Intersect} {@link Intersect.INSIDE} if the entire box is on the side of the plane
    *                      the normal is pointing, {@link Intersect.OUTSIDE} if the entire box is
    *                      on the opposite side, and {@link Intersect.INTERSECTING} if the box
    *                      intersects the plane.
    */
    func intersectPlane(plane: Plane) -> Intersect {
        
        let normal = plane.normal
        let normalX = normal.x, normalY = normal.y, normalZ = normal.z
        
        // plane is used as if it is its normal; the first three components are assumed to be normalized
        let radEffective1 = abs(normalX * halfAxes[0,0] + normalY * halfAxes[0,1] + normalZ * halfAxes[0,2])
        let radEffective2 = abs(normalX * halfAxes[1,0] + normalY * halfAxes[1,1] + normalZ * halfAxes[1,2])
        let radEffective3 = abs(normalX * halfAxes[2,0] + normalY * halfAxes[2,1] + normalZ * halfAxes[2,2])
        let radEffective = radEffective1 + radEffective2 + radEffective3
        let distanceToPlane = normal.dot(center) + plane.distance
        
        if distanceToPlane <= -radEffective {
            // The entire box is on the negative side of the plane normal
            return .Outside
        } else if distanceToPlane >= radEffective {
            // The entire box is on the positive side of the plane normal
            return .Inside
        }
        return .Intersecting
    }
    /*
    var scratchCartesianU = new Cartesian3();
    var scratchCartesianV = new Cartesian3();
    var scratchCartesianW = new Cartesian3();
    var scratchPPrime = new Cartesian3();
    */
    /**
    * Computes the estimated distance squared from the closest point on a bounding box to a point.
    *
    * @param {OrientedBoundingBox} box The box.
    * @param {Cartesian3} cartesian The point
    * @returns {Number} The estimated distance squared from the bounding sphere to the point.
    *
    * @example
    * // Sort bounding boxes from back to front
    * boxes.sort(function(a, b) {
    *     return Cesium.OrientedBoundingBox.distanceSquaredTo(b, camera.positionWC) - Cesium.OrientedBoundingBox.distanceSquaredTo(a, camera.positionWC);
    * });
    */
    func distanceSquaredTo (cartesian: Cartesian3) -> Double {
        assertionFailure("not implemented")
        let distanceSquared = 0.0
    // See Geometric Tools for Computer Graphics 10.4.2
    /*
    //>>includeStart('debug', pragmas.debug);
    if (!defined(box)) {
    throw new DeveloperError('box is required.');
    }
    if (!defined(cartesian)) {
    throw new DeveloperError('cartesian is required.');
    }
    //>>includeEnd('debug');
    
    var offset = Cartesian3.subtract(cartesian, box.center, scratchOffset);
    
    var halfAxes = box.halfAxes;
    var u = Matrix3.getColumn(halfAxes, 0, scratchCartesianU);
    var v = Matrix3.getColumn(halfAxes, 1, scratchCartesianV);
    var w = Matrix3.getColumn(halfAxes, 2, scratchCartesianW);
    
    var uHalf = Cartesian3.magnitude(u);
    var vHalf = Cartesian3.magnitude(v);
    var wHalf = Cartesian3.magnitude(w);
    
    Cartesian3.normalize(u, u);
    Cartesian3.normalize(v, v);
    Cartesian3.normalize(w, w);
    
    var pPrime = scratchPPrime;
    pPrime.x = Cartesian3.dot(offset, u);
    pPrime.y = Cartesian3.dot(offset, v);
    pPrime.z = Cartesian3.dot(offset, w);
    
    var distanceSquared = 0.0;
    var d;
    
    if (pPrime.x < -uHalf) {
    d = pPrime.x + uHalf;
    distanceSquared += d * d;
    } else if (pPrime.x > uHalf) {
    d = pPrime.x - uHalf;
    distanceSquared += d * d;
    }
    
    if (pPrime.y < -vHalf) {
    d = pPrime.y + vHalf;
    distanceSquared += d * d;
    } else if (pPrime.y > vHalf) {
    d = pPrime.y - vHalf;
    distanceSquared += d * d;
    }
    
    if (pPrime.z < -wHalf) {
    d = pPrime.z + wHalf;
    distanceSquared += d * d;
    } else if (pPrime.z > wHalf) {
    d = pPrime.z - wHalf;
    distanceSquared += d * d;
    }
    */
    return distanceSquared
    }
    
    /*var scratchCorner = new Cartesian3();
    var scratchToCenter = new Cartesian3();
    var scratchProj = new Cartesian3();
    */
    /**
    * The distances calculated by the vector from the center of the bounding box to position projected onto direction.
    * <br>
    * If you imagine the infinite number of planes with normal direction, this computes the smallest distance to the
    * closest and farthest planes from position that intersect the bounding box.
    *
    * @param {OrientedBoundingBox} box The bounding box to calculate the distance to.
    * @param {Cartesian3} position The position to calculate the distance from.
    * @param {Cartesian3} direction The direction from position.
    * @param {Interval} [result] A Interval to store the nearest and farthest distances.
    * @returns {Interval} The nearest and farthest distances on the bounding box from position in direction.
    */
    func computePlaneDistances (position: Cartesian3, direction: Cartesian3) -> Interval {
    
    let minDist = Double.infinity
    let maxDist = Double.infinity * -1.0
        assertionFailure("not implemented")
    /*
    var center = box.center;
    var halfAxes = box.halfAxes;
    
    var u = Matrix3.getColumn(halfAxes, 0, scratchCartesianU);
    var v = Matrix3.getColumn(halfAxes, 1, scratchCartesianV);
    var w = Matrix3.getColumn(halfAxes, 2, scratchCartesianW);
    
    // project first corner
    var corner = Cartesian3.add(u, v, scratchCorner);
    Cartesian3.add(corner, w, corner);
    Cartesian3.add(corner, center, corner);
    
    var toCenter = Cartesian3.subtract(corner, position, scratchToCenter);
    var mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project second corner
    Cartesian3.add(center, u, corner);
    Cartesian3.add(corner, v, corner);
    Cartesian3.subtract(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project third corner
    Cartesian3.add(center, u, corner);
    Cartesian3.subtract(corner, v, corner);
    Cartesian3.add(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project fourth corner
    Cartesian3.add(center, u, corner);
    Cartesian3.subtract(corner, v, corner);
    Cartesian3.subtract(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project fifth corner
    Cartesian3.subtract(center, u, corner);
    Cartesian3.add(corner, v, corner);
    Cartesian3.add(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project sixth corner
    Cartesian3.subtract(center, u, corner);
    Cartesian3.add(corner, v, corner);
    Cartesian3.subtract(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project seventh corner
    Cartesian3.subtract(center, u, corner);
    Cartesian3.subtract(corner, v, corner);
    Cartesian3.add(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    
    // project eighth corner
    Cartesian3.subtract(center, u, corner);
    Cartesian3.subtract(corner, v, corner);
    Cartesian3.subtract(corner, w, corner);
    
    Cartesian3.subtract(corner, position, toCenter);
    mag = Cartesian3.dot(direction, toCenter);
    
    minDist = Math.min(mag, minDist);
    maxDist = Math.max(mag, maxDist);
    */
        return Interval(start: minDist, stop: maxDist)
    }

    /**
    * Determines whether or not a bounding box is hidden from view by the occluder.
    *
    * @param {Occluder} occluder The occluder.
    * @returns {Boolean} <code>true</code> if the sphere is not visible; otherwise <code>false</code>.
    */
    func isOccluded (occluder: Occluder) -> Bool {

        let uHalf = halfAxes.column(0).magnitude
        let vHalf = halfAxes.column(1).magnitude
        let wHalf = halfAxes.column(2).magnitude

        return !occluder.isBoundingSphereVisible(BoundingSphere(center: center, radius: max(uHalf, vHalf, wHalf)))
    }
    
    /*
       

        
    /**
    * Compares the provided OrientedBoundingBox componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {OrientedBoundingBox} left The first OrientedBoundingBox.
    * @param {OrientedBoundingBox} right The second OrientedBoundingBox.
    * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
    */
    OrientedBoundingBox.equals = function(left, right) {
    return (left === right) ||
    ((defined(left)) &&
    (defined(right)) &&
    Cartesian3.equals(left.center, right.center) &&
    Matrix3.equals(left.halfAxes, right.halfAxes));
    };
    
    /**
    * Duplicates this OrientedBoundingBox instance.
    *
    * @param {OrientedBoundingBox} [result] The object onto which to store the result.
    * @returns {OrientedBoundingBox} The modified result parameter or a new OrientedBoundingBox instance if one was not provided.
    */
    OrientedBoundingBox.prototype.clone = function(result) {
    return OrientedBoundingBox.clone(this, result);
    };
    
    /**
    * Compares this OrientedBoundingBox against the provided OrientedBoundingBox componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {OrientedBoundingBox} [right] The right hand side OrientedBoundingBox.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    OrientedBoundingBox.prototype.equals = function(right) {
    return OrientedBoundingBox.equals(this, right);
    };
    

    */
}