//
//  BoundingSphere.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 8/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A bounding sphere with a center and a radius.
* @alias BoundingSphere
* @constructor
*
* @param {Cartesian3} [center=Cartesian3.ZERO] The center of the bounding sphere.
* @param {Number} [radius=0.0] The radius of the bounding sphere.
*
* @see AxisAlignedBoundingBox
* @see BoundingRectangle
* @see Packable
*/
struct BoundingSphere: BoundingVolume {
    /**
    * The center point of the sphere.
    * @type {Cartesian3}
    * @default {@link Cartesian3.ZERO}
    */
    var center: Cartesian3 = Cartesian3.zero
    
    /**
    * The radius of the sphere.
    * @type {Number}
    * @default 0.0
    */
    var radius: Double = 0.0
    
    init (center: Cartesian3 = Cartesian3.zero, radius: Double = 0.0) {
        self.center = center
        self.radius = radius
    }
    
    /**
    * Computes a tight-fitting bounding sphere enclosing a list of 3D Cartesian points.
    * The bounding sphere is computed by running two algorithms, a naive algorithm and
    * Ritter's algorithm. The smaller of the two spheres is used to ensure a tight fit.
    *
    * @param {Cartesian3[]} positions An array of points that the bounding sphere will enclose.  Each point must have <code>x</code>, <code>y</code>, and <code>z</code> properties.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if one was not provided.
    *
    * @see {@link http://blogs.agi.com/insight3d/index.php/2008/02/04/a-bounding/|Bounding Sphere computation article}
    */
    init(fromPoints points: [Cartesian3]) {
        
        self.init()

        if (points.count == 0) {
            return
        }
        
        var currentPos = points[points.startIndex]

        var xMin = currentPos
        var yMin = currentPos
        var zMin = currentPos
        
        var xMax = currentPos
        var yMax = currentPos
        var zMax = currentPos
        
        for i in 1..<points.count {
            
            currentPos = points[i]
            
            let x = currentPos.x
            let y = currentPos.y
            let z = currentPos.z
            
            // Store points containing the the smallest and largest components
            if (x < xMin.x) {
                xMin = currentPos
            }
            
            if (x > xMax.x) {
                xMax = currentPos
            }
            
            if (y < yMin.y) {
                yMin = currentPos
            }
            
            if (y > yMax.y) {
                yMax = currentPos
            }
            
            if (z < zMin.z) {
                zMin = currentPos
            }
            
            if (z > zMax.z) {
                zMax = currentPos
            }
        }
        
        // Compute x-, y-, and z-spans (Squared distances b/n each component's min. and max.).
        let xSpan = xMax.subtract(xMin).magnitudeSquared
        let ySpan = yMax.subtract(yMin).magnitudeSquared
        let zSpan = zMax.subtract(zMin).magnitudeSquared
        
        // Set the diameter endpoints to the largest span.
        var diameter1 = xMin
        var diameter2 = xMax
        var maxSpan = xSpan
        if (ySpan > maxSpan) {
            maxSpan = ySpan
            diameter1 = yMin
            diameter2 = yMax
        }
        if (zSpan > maxSpan) {
            maxSpan = zSpan
            diameter1 = zMin
            diameter2 = zMax
        }
        
        // Calculate the center of the initial sphere found by Ritter's algorithm
        var ritterCenter = Cartesian3();
        ritterCenter.x = (diameter1.x + diameter2.x) * 0.5
        ritterCenter.y = (diameter1.y + diameter2.y) * 0.5
        ritterCenter.z = (diameter1.z + diameter2.z) * 0.5
        
        // Calculate the radius of the initial sphere found by Ritter's algorithm
        var radiusSquared = diameter2.subtract(ritterCenter).magnitudeSquared
        var ritterRadius = sqrt(radiusSquared)
        
        // Find the center of the sphere found using the Naive method.
        let minBoxPt = Cartesian3(x: xMin.x, y: yMin.y, z: zMin.z)
        let maxBoxPt = Cartesian3(x: xMax.x, y: yMax.y, z: zMax.z)
        
        let naiveCenter = minBoxPt.add(maxBoxPt).multiplyByScalar(0.5)
        
        // Begin 2nd pass to find naive radius and modify the ritter sphere.
        var naiveRadius = 0.0;
        for i in 0..<points.count {
            currentPos = points[i]
            
            // Find the furthest point from the naive center to calculate the naive radius.
            let r = currentPos.subtract(naiveCenter).magnitude
            if (r > naiveRadius) {
                naiveRadius = r
            }
            
            // Make adjustments to the Ritter Sphere to include all points.
            let oldCenterToPointSquared = currentPos.subtract(ritterCenter).magnitudeSquared
            if (oldCenterToPointSquared > radiusSquared) {
                let oldCenterToPoint = sqrt(oldCenterToPointSquared)
                // Calculate new radius to include the point that lies outside
                ritterRadius = (ritterRadius + oldCenterToPoint) * 0.5
                radiusSquared = ritterRadius * ritterRadius
                // Calculate center of new Ritter sphere
                let oldToNew = oldCenterToPoint - ritterRadius
                ritterCenter.x = (ritterRadius * ritterCenter.x + oldToNew * currentPos.x) / oldCenterToPoint
                ritterCenter.y = (ritterRadius * ritterCenter.y + oldToNew * currentPos.y) / oldCenterToPoint
                ritterCenter.z = (ritterRadius * ritterCenter.z + oldToNew * currentPos.z) / oldCenterToPoint
            }
        }
        if ritterRadius < naiveRadius {
            center = ritterCenter
            radius = ritterRadius
        } else {
            center = naiveCenter
            radius = naiveRadius
        }
    }
   
    /**
    * Computes a bounding sphere from an rectangle projected in 2D.
    *
    * @param {Rectangle} rectangle The rectangle around which to create a bounding sphere.
    * @param {Object} [projection=GeographicProjection] The projection used to project the rectangle into 2D.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
    */
    init (fromRectangle2D rectangle: Rectangle?, projection: MapProjection = GeographicProjection()) {
        self.init(fromRectangleWithHeights2D: rectangle, projection: projection, minimumHeight: 0.0, maximumHeight: 0.0)
    }

    /**
    * Computes a bounding sphere from an rectangle projected in 2D.  The bounding sphere accounts for the
    * object's minimum and maximum heights over the rectangle.
    *
    * @param {Rectangle} rectangle The rectangle around which to create a bounding sphere.
    * @param {Object} [projection=GeographicProjection] The projection used to project the rectangle into 2D.
    * @param {Number} [minimumHeight=0.0] The minimum height over the rectangle.
    * @param {Number} [maximumHeight=0.0] The maximum height over the rectangle.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
    */
    init (
        fromRectangleWithHeights2D rectangle: Rectangle?,
        projection: MapProjection = GeographicProjection(),
        minimumHeight: Double = 0.0,
        maximumHeight: Double = 0.0) {

            self.init()

            if rectangle == nil {
                return
            }
            
            var fromRectangle2DSouthwest = rectangle!.southwest()
            fromRectangle2DSouthwest.height = minimumHeight
            var fromRectangle2DNortheast = rectangle!.northeast()
            fromRectangle2DNortheast.height = maximumHeight
            
            let lowerLeft = projection.project(fromRectangle2DSouthwest)
            let upperRight = projection.project(fromRectangle2DNortheast)
            
            let width = upperRight.x - lowerLeft.x
            let height = upperRight.y - lowerLeft.y
            let elevation = upperRight.z - lowerLeft.z
            
            center = Cartesian3(x: lowerLeft.x + width * 0.5, y: lowerLeft.y + height * 0.5, z: lowerLeft.z + elevation * 0.5)
            radius = sqrt(width * width + height * height + elevation * elevation) * 0.5
    }
    
    /**
    * Computes a bounding sphere from an rectangle in 3D. The bounding sphere is created using a subsample of points
    * on the ellipsoid and contained in the rectangle. It may not be accurate for all rectangles on all types of ellipsoids.
    *
    * @param {Rectangle} rectangle The valid rectangle used to create a bounding sphere.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid used to determine positions of the rectangle.
    * @param {Number} [surfaceHeight=0.0] The height above the surface of the ellipsoid.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
    */
    init (fromRectangle3D rectangle: Rectangle, ellipsoid: Ellipsoid = Ellipsoid.wgs84(), surfaceHeight: Double = 0) {
        let positions: [Cartesian3]
        positions = rectangle.subsample(ellipsoid, surfaceHeight: surfaceHeight)
        self.init(fromPoints: positions)
    }

    /**
    * Computes a tight-fitting bounding sphere enclosing a list of 3D points, where the points are
    * stored in a flat array in X, Y, Z, order.  The bounding sphere is computed by running two
    * algorithms, a naive algorithm and Ritter's algorithm. The smaller of the two spheres is used to
    * ensure a tight fit.
    *
    * @param {Number[]} positions An array of points that the bounding sphere will enclose.  Each point
    *        is formed from three elements in the array in the order X, Y, Z.
    * @param {Cartesian3} [center=Cartesian3.ZERO] The position to which the positions are relative, which need not be the
    *        origin of the coordinate system.  This is useful when the positions are to be used for
    *        relative-to-center (RTC) rendering.
    * @param {Number} [stride=3] The number of array elements per vertex.  It must be at least 3, but it may
    *        be higher.  Regardless of the value of this parameter, the X coordinate of the first position
    *        is at array index 0, the Y coordinate is at array index 1, and the Z coordinate is at array index
    *        2.  When stride is 3, the X coordinate of the next position then begins at array index 3.  If
    *        the stride is 5, however, two array elements are skipped and the next position begins at array
    *        index 5.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if one was not provided.
    *
    * @see {@link http://blogs.agi.com/insight3d/index.php/2008/02/04/a-bounding/|Bounding Sphere computation article}
    *
    * @example
    * // Compute the bounding sphere from 3 positions, each specified relative to a center.
    * // In addition to the X, Y, and Z coordinates, the points array contains two additional
    * // elements per point which are ignored for the purpose of computing the bounding sphere.
    * var center = new Cesium.Cartesian3(1.0, 2.0, 3.0);
    * var points = [1.0, 2.0, 3.0, 0.1, 0.2,
    *               4.0, 5.0, 6.0, 0.1, 0.2,
    *               7.0, 8.0, 9.0, 0.1, 0.2];
    * var sphere = Cesium.BoundingSphere.fromVertices(points, center, 5);
    */
    
    /*var fromPointsXMin = new Cartesian3();
    var fromPointsYMin = new Cartesian3();
    var fromPointsZMin = new Cartesian3();
    var fromPointsXMax = new Cartesian3();
    var fromPointsYMax = new Cartesian3();
    var fromPointsZMax = new Cartesian3();
    var fromPointsCurrentPos = new Cartesian3();
    var fromPointsScratch = new Cartesian3();
    var fromPointsRitterCenter = new Cartesian3();
    var fromPointsMinBoxPt = new Cartesian3();
    var fromPointsMaxBoxPt = new Cartesian3();
    var fromPointsNaiveCenterScratch = new Cartesian3();*/
    
    static func fromVertices(positions: [Float], center: Cartesian3 = Cartesian3.zero, stride: Int = 3) -> BoundingSphere {
        
        var result = BoundingSphere()
        if (positions.count == 0) {
            return result
        }
        
        assert(stride >= 3, "stride must be 3 or greater")
        
        var currentPos = Cartesian3(x: Double(positions[0]) + center.x, y: Double(positions[1]) + center.y, z: Double(positions[2]) + center.z)
        
        var xMin = currentPos
        var yMin = currentPos
        var zMin = currentPos
        
        var xMax = currentPos
        var yMax = currentPos
        var zMax = currentPos
        
        let numElements = positions.count
        for i in 0.stride(to: numElements, by: stride) {
            let x = Double(positions[i]) + center.x
            let y = Double(positions[i + 1]) + center.y
            let z = Double(positions[i + 2]) + center.z
            
            currentPos.x = x
            currentPos.y = y
            currentPos.z = z
            
            // Store points containing the the smallest and largest components
            if (x < xMin.x) {
                xMin = currentPos
            }
            
            if (x > xMax.x) {
                xMax = currentPos
            }
            
            if (y < yMin.y) {
                yMin = currentPos
            }
            
            if (y > yMax.y) {
                yMax = currentPos
            }
            
            if (z < zMin.z) {
                zMin = currentPos
            }
            
            if (z > zMax.z) {
                zMax = currentPos
            }
        }
        
        // Compute x-, y-, and z-spans (Squared distances b/n each component's min. and max.).
        let xSpan = xMax.subtract(xMin).magnitudeSquared
        let ySpan = yMax.subtract(yMin).magnitudeSquared
        let zSpan = zMax.subtract(zMin).magnitudeSquared
        
        // Set the diameter endpoints to the largest span.
        var diameter1 = xMin
        var diameter2 = xMax
        var maxSpan = xSpan
        if (ySpan > maxSpan) {
            maxSpan = ySpan
            diameter1 = yMin
            diameter2 = yMax
        }
        if (zSpan > maxSpan) {
            maxSpan = zSpan
            diameter1 = zMin
            diameter2 = zMax
        }
        
        // Calculate the center of the initial sphere found by Ritter's algorithm
        var ritterCenter = Cartesian3();
        ritterCenter.x = (diameter1.x + diameter2.x) * 0.5
        ritterCenter.y = (diameter1.y + diameter2.y) * 0.5
        ritterCenter.z = (diameter1.z + diameter2.z) * 0.5

        
        // Calculate the radius of the initial sphere found by Ritter's algorithm
        var radiusSquared = diameter2.subtract(ritterCenter).magnitudeSquared
        var ritterRadius = sqrt(radiusSquared)
        
        // Find the center of the sphere found using the Naive method.
        var minBoxPt = Cartesian3()
        minBoxPt.x = xMin.x
        minBoxPt.y = yMin.y
        minBoxPt.z = zMin.z
        
        var maxBoxPt = Cartesian3()
        maxBoxPt.x = xMax.x
        maxBoxPt.y = yMax.y
        maxBoxPt.z = zMax.z
        
        let naiveCenter = minBoxPt.add(maxBoxPt).multiplyByScalar(0.5)
        
        // Begin 2nd pass to find naive radius and modify the ritter sphere.
        var naiveRadius = 0.0
        for i in 0.stride(to: numElements, by: stride) {
            currentPos.x = Double(positions[i]) + center.x
            currentPos.y = Double(positions[i + 1]) + center.y
            currentPos.z = Double(positions[i + 2]) + center.z
            
            // Find the furthest point from the naive center to calculate the naive radius.
            let r = currentPos.subtract(naiveCenter).magnitude
            if (r > naiveRadius) {
                naiveRadius = r
            }
            
            // Make adjustments to the Ritter Sphere to include all points.
            let oldCenterToPointSquared = currentPos.subtract(ritterCenter).magnitudeSquared
            if (oldCenterToPointSquared > radiusSquared) {
                let oldCenterToPoint = sqrt(oldCenterToPointSquared)
                // Calculate new radius to include the point that lies outside
                ritterRadius = (ritterRadius + oldCenterToPoint) * 0.5
                radiusSquared = ritterRadius * ritterRadius
                // Calculate center of new Ritter sphere
                let oldToNew = oldCenterToPoint - ritterRadius
                ritterCenter.x = (ritterRadius * ritterCenter.x + oldToNew * currentPos.x) / oldCenterToPoint
                ritterCenter.y = (ritterRadius * ritterCenter.y + oldToNew * currentPos.y) / oldCenterToPoint
                ritterCenter.z = (ritterRadius * ritterCenter.z + oldToNew * currentPos.z) / oldCenterToPoint
            }
        }
        if (ritterRadius < naiveRadius) {
            result.center = ritterCenter
            result.radius = ritterRadius
        } else {
            result.center = naiveCenter
            result.radius = naiveRadius
        }
        return result

    }
/*
/**
* Computes a bounding sphere from the corner points of an axis-aligned bounding box.  The sphere
* tighly and fully encompases the box.
*
* @param {Cartesian3} [corner] The minimum height over the rectangle.
* @param {Cartesian3} [oppositeCorner] The maximum height over the rectangle.
* @param {BoundingSphere} [result] The object onto which to store the result.
*
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
*
* @example
* // Create a bounding sphere around the unit cube
* var sphere = Cesium.BoundingSphere.fromCornerPoints(new Cesium.Cartesian3(-0.5, -0.5, -0.5), new Cesium.Cartesian3(0.5, 0.5, 0.5));
*/
BoundingSphere.fromCornerPoints = function(corner, oppositeCorner, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(corner) || !defined(oppositeCorner)) {
        throw new DeveloperError('corner and oppositeCorner are required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    var center = result.center;
    Cartesian3.add(corner, oppositeCorner, center);
    Cartesian3.multiplyByScalar(center, 0.5, center);
    result.radius = Cartesian3.distance(center, oppositeCorner);
    return result;
};
*/
    /**
    * Creates a bounding sphere encompassing an ellipsoid.
    *
    * @param {Ellipsoid} ellipsoid The ellipsoid around which to create a bounding sphere.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    *
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
    *
    * @example
    * var boundingSphere = Cesium.BoundingSphere.fromEllipsoid(ellipsoid);
    */
    init (ellipsoid: Ellipsoid) {
        self.init(center: Cartesian3.zero, radius: ellipsoid.maximumRadius)
    }
    /*
    /**
    * Computes a tight-fitting bounding sphere enclosing the provided array of bounding spheres.
    *
    * @param {BoundingSphere[]} boundingSpheres The array of bounding spheres.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
    */
    BoundingSphere.fromBoundingSpheres = function(boundingSpheres, result) {
    if (!defined(result)) {
    result = new BoundingSphere();
    }
    
    if (!defined(boundingSpheres) || boundingSpheres.length === 0) {
    result.center = Cartesian3.clone(Cartesian3.ZERO, result.center);
    result.radius = 0.0;
    return result;
    }
    
    var length = boundingSpheres.length;
    if (length === 1) {
    return BoundingSphere.clone(boundingSpheres[0], result);
    }
    
    if (length === 2) {
    return BoundingSphere.union(boundingSpheres[0], boundingSpheres[1], result);
    }
    
    var positions = [];
    for (var i = 0; i < length; i++) {
    positions.push(boundingSpheres[i].center);
    }
    
    result = BoundingSphere.fromPoints(positions, result);
    
    var center = result.center;
    var radius = result.radius;
    for (i = 0; i < length; i++) {
    var tmp = boundingSpheres[i];
    radius = Math.max(radius, Cartesian3.distance(center, tmp.center, fromBoundingSpheresScratch) + tmp.radius);
    }
    result.radius = radius;
    
    return result;
    };

        +var fromBoundingSpheresScratch = new Cartesian3();
    
        /**
         * Computes a tight-fitting bounding sphere enclosing the provided array of bounding spheres.
         *
         * @param {BoundingSphere[]} boundingSpheres The array of bounding spheres.
         * @param {BoundingSphere} [result] The object onto which to store the result.
         * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
        */
        BoundingSphere.fromBoundingSpheres = function(boundingSpheres, result) {
            if (!defined(result)) {
                result = new BoundingSphere();
            }
    
/**
* Duplicates a BoundingSphere instance.
*
* @param {BoundingSphere} sphere The bounding sphere to duplicate.
* @param {BoundingSphere} [result] The object onto which to store the result.
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided. (Returns undefined if sphere is undefined)
*/
BoundingSphere.clone = function(sphere, result) {
    if (!defined(sphere)) {
        return undefined;
    }
    
    if (!defined(result)) {
        return new BoundingSphere(sphere.center, sphere.radius);
    }
    
    result.center = Cartesian3.clone(sphere.center, result.center);
    result.radius = sphere.radius;
    return result;
};

/**
* The number of elements used to pack the object into an array.
* @type {Number}
*/
BoundingSphere.packedLength = 4;

/**
* Stores the provided instance into the provided array.
*
* @param {BoundingSphere} value The value to pack.
* @param {Number[]} array The array to pack into.
* @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
*/
BoundingSphere.pack = function(value, array, startingIndex) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(value)) {
        throw new DeveloperError('value is required');
    }
    
    if (!defined(array)) {
        throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    var center = value.center;
    array[startingIndex++] = center.x;
    array[startingIndex++] = center.y;
    array[startingIndex++] = center.z;
    array[startingIndex] = value.radius;
};

/**
* Retrieves an instance from a packed array.
*
* @param {Number[]} array The packed array.
* @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
* @param {BoundingSphere} [result] The object into which to store the result.
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if one was not provided.*/
BoundingSphere.unpack = function(array, startingIndex, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(array)) {
        throw new DeveloperError('array is required');
    }
    //>>includeEnd('debug');
    
    startingIndex = defaultValue(startingIndex, 0);
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    var center = result.center;
    center.x = array[startingIndex++];
    center.y = array[startingIndex++];
    center.z = array[startingIndex++];
    result.radius = array[startingIndex];
    return result;
};
*/
    /**
    * Computes a bounding sphere that contains both the left and right bounding spheres.
    *
    * @param {BoundingSphere} left A sphere to enclose in a bounding sphere.
    * @param {BoundingSphere} right A sphere to enclose in a bounding sphere.
    * @param {BoundingSphere} [result] The object onto which to store the result.
    * @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
    */
    func union(other: BoundingSphere) -> BoundingSphere {
        
        let leftCenter = self.center
        let leftRadius = self.radius
        let rightCenter = other.center
        let rightRadius = other.radius
        
        let toRightCenter = rightCenter.subtract(leftCenter)
        let centerSeparation = toRightCenter.magnitude
        
        if leftRadius >= (centerSeparation + rightRadius) {
            return self
        }
        
        if rightRadius >= (centerSeparation + leftRadius) {
            return other
        }
        
        // There are two tangent points, one on far side of each sphere.
        let halfDistanceBetweenTangentPoints = (leftRadius + centerSeparation + rightRadius) * 0.5
        
        // Compute the center point halfway between the two tangent points.
        let center = toRightCenter.multiplyByScalar((-leftRadius + halfDistanceBetweenTangentPoints) / centerSeparation)
        return BoundingSphere(center: center.add(leftCenter), radius: halfDistanceBetweenTangentPoints)
    }
/*
var expandScratch = new Cartesian3();
/**
* Computes a bounding sphere by enlarging the provided sphere to contain the provided point.
*
* @param {BoundingSphere} sphere A sphere to expand.
* @param {Cartesian3} point A point to enclose in a bounding sphere.
* @param {BoundingSphere} [result] The object onto which to store the result.
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
*/
BoundingSphere.expand = function(sphere, point, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(point)) {
        throw new DeveloperError('point is required.');
    }
    //>>includeEnd('debug');
    
    result = BoundingSphere.clone(sphere, result);
    
    var radius = Cartesian3.magnitude(Cartesian3.subtract(point, result.center, expandScratch));
    if (radius > result.radius) {
        result.radius = radius;
    }
    
    return result;
};
*/
    /**
    * Determines which side of a plane a sphere is located.
    *
    * @param {BoundingSphere} sphere The bounding sphere to test.
    * @param {Plane} plane The plane to test against.
    * @returns {Intersect} {@link Intersect.INSIDE} if the entire sphere is on the side of the plane
    *                      the normal is pointing, {@link Intersect.OUTSIDE} if the entire sphere is
    *                      on the opposite side, and {@link Intersect.INTERSECTING} if the sphere
    *                      intersects the plane.
    */
    func intersectPlane(plane: Plane) -> Intersect {

        let distanceToPlane = plane.normal.dot(center) + plane.distance
        
        if distanceToPlane < -radius {
            // The center point is negative side of the plane normal
            return Intersect.Outside
        } else if distanceToPlane < radius {
            // The center point is positive side of the plane, but radius extends beyond it; partial overlap
            return Intersect.Intersecting
        }
        return Intersect.Inside
    }
/*
/**
* Applies a 4x4 affine transformation matrix to a bounding sphere.
*
* @param {BoundingSphere} sphere The bounding sphere to apply the transformation to.
* @param {Matrix4} transform The transformation matrix to apply to the bounding sphere.
* @param {BoundingSphere} [result] The object onto which to store the result.
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
*/
BoundingSphere.transform = function(sphere, transform, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(transform)) {
        throw new DeveloperError('transform is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    result.center = Matrix4.multiplyByPoint(transform, sphere.center, result.center);
    result.radius = Matrix4.getMaximumScale(transform) * sphere.radius;
    
    return result;
};

*/
/**
* Computes the estimated distance squared from the closest point on a bounding sphere to a point.
*
* @param {BoundingSphere} sphere The sphere.
* @param {Cartesian3} cartesian The point
* @returns {Number} The estimated distance squared from the bounding sphere to the point.
*
* @example
* // Sort bounding spheres from back to front
* spheres.sort(function(a, b) {
*     return BoundingSphere.distanceSquaredTo(b, camera.positionWC) - BoundingSphere.distanceSquaredTo(a, camera.positionWC);
* });
*/
    func distanceSquaredTo(cartesian: Cartesian3) -> Double {
        let diff = center.subtract(cartesian)
        return diff.magnitudeSquared - radius * radius
    }
/*
/**
* Applies a 4x4 affine transformation matrix to a bounding sphere where there is no scale
* The transformation matrix is not verified to have a uniform scale of 1.
* This method is faster than computing the general bounding sphere transform using {@link BoundingSphere.transform}.
*
* @param {BoundingSphere} sphere The bounding sphere to apply the transformation to.
* @param {Matrix4} transform The transformation matrix to apply to the bounding sphere.
* @param {BoundingSphere} [result] The object onto which to store the result.
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
*
* @example
* var modelMatrix = Cesium.Transforms.eastNorthUpToFixedFrame(positionOnEllipsoid);
* var boundingSphere = new Cesium.BoundingSphere();
* var newBoundingSphere = Cesium.BoundingSphere.transformWithoutScale(boundingSphere, modelMatrix);
*/
BoundingSphere.transformWithoutScale = function(sphere, transform, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    
    if (!defined(transform)) {
        throw new DeveloperError('transform is required.');
    }
    //>>includeEnd('debug');
    
    if (!defined(result)) {
        result = new BoundingSphere();
    }
    
    result.center = Matrix4.multiplyByPoint(transform, sphere.center, result.center);
    result.radius = sphere.radius;
    
    return result;
};
*/
    /**
    * The distances calculated by the vector from the center of the bounding sphere to position projected onto direction
    * plus/minus the radius of the bounding sphere.
    * <br>
    * If you imagine the infinite number of planes with normal direction, this computes the smallest distance to the
    * closest and farthest planes from position that intersect the bounding sphere.
    *
    * @param {BoundingSphere} sphere The bounding sphere to calculate the distance to.
    * @param {Cartesian3} position The position to calculate the distance from.
    * @param {Cartesian3} direction The direction from position.
    * @returns {Interval} The nearest and farthest distances on the bounding sphere from position in direction.
    */
    func computePlaneDistances(position: Cartesian3, direction: Cartesian3) -> Interval {
        
        let toCenter = center.subtract(position)
        let proj = direction.multiplyByScalar(direction.dot(toCenter))
        let mag = proj.magnitude
        
        return Interval(start: mag - radius, stop: mag + radius)
    }
/*
var projectTo2DNormalScratch = new Cartesian3();
var projectTo2DEastScratch = new Cartesian3();
var projectTo2DNorthScratch = new Cartesian3();
var projectTo2DWestScratch = new Cartesian3();
var projectTo2DSouthScratch = new Cartesian3();
var projectTo2DCartographicScratch = new Cartographic();
var projectTo2DPositionsScratch = new Array(8);
for (var n = 0; n < 8; ++n) {
    projectTo2DPositionsScratch[n] = new Cartesian3();
}
var projectTo2DProjection = new GeographicProjection();
/**
* Creates a bounding sphere in 2D from a bounding sphere in 3D world coordinates.
*
* @param {BoundingSphere} sphere The bounding sphere to transform to 2D.
* @param {Object} [projection=GeographicProjection] The projection to 2D.
* @param {BoundingSphere} [result] The object onto which to store the result.
* @returns {BoundingSphere} The modified result parameter or a new BoundingSphere instance if none was provided.
*/
BoundingSphere.projectTo2D = function(sphere, projection, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(sphere)) {
        throw new DeveloperError('sphere is required.');
    }
    //>>includeEnd('debug');
    
    projection = defaultValue(projection, projectTo2DProjection);
    
    var ellipsoid = projection.ellipsoid;
    var center = sphere.center;
    var radius = sphere.radius;
    
    var normal = ellipsoid.geodeticSurfaceNormal(center, projectTo2DNormalScratch);
    var east = Cartesian3.cross(Cartesian3.UNIT_Z, normal, projectTo2DEastScratch);
    Cartesian3.normalize(east, east);
    var north = Cartesian3.cross(normal, east, projectTo2DNorthScratch);
    Cartesian3.normalize(north, north);
    
    Cartesian3.multiplyByScalar(normal, radius, normal);
    Cartesian3.multiplyByScalar(north, radius, north);
    Cartesian3.multiplyByScalar(east, radius, east);
    
    var south = Cartesian3.negate(north, projectTo2DSouthScratch);
    var west = Cartesian3.negate(east, projectTo2DWestScratch);
    
    var positions = projectTo2DPositionsScratch;
    
    // top NE corner
    var corner = positions[0];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, east, corner);
    
    // top NW corner
    corner = positions[1];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, west, corner);
    
    // top SW corner
    corner = positions[2];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, west, corner);
    
    // top SE corner
    corner = positions[3];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, east, corner);
    
    Cartesian3.negate(normal, normal);
    
    // bottom NE corner
    corner = positions[4];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, east, corner);
    
    // bottom NW corner
    corner = positions[5];
    Cartesian3.add(normal, north, corner);
    Cartesian3.add(corner, west, corner);
    
    // bottom SW corner
    corner = positions[6];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, west, corner);
    
    // bottom SE corner
    corner = positions[7];
    Cartesian3.add(normal, south, corner);
    Cartesian3.add(corner, east, corner);
    
    var length = positions.length;
    for (var i = 0; i < length; ++i) {
        var position = positions[i];
        Cartesian3.add(center, position, position);
        var cartographic = ellipsoid.cartesianToCartographic(position, projectTo2DCartographicScratch);
        projection.project(cartographic, position);
    }
    
    result = BoundingSphere.fromPoints(positions, result);
    
    // swizzle center components
    center = result.center;
    var x = center.x;
    var y = center.y;
    var z = center.z;
    center.x = z;
    center.y = x;
    center.z = y;
    
    return result;
};

/**
* Compares the provided BoundingSphere componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {BoundingSphere} [left] The first BoundingSphere.
* @param {BoundingSphere} [right] The second BoundingSphere.
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
BoundingSphere.equals = function(left, right) {
    return (left === right) ||
        ((defined(left)) &&
            (defined(right)) &&
            Cartesian3.equals(left.center, right.center) &&
            left.radius === right.radius);
};

/**
* Determines which side of a plane the sphere is located.
*
* @param {Cartesian4} plane The coefficients of the plane in the for ax + by + cz + d = 0
*                           where the coefficients a, b, c, and d are the components x, y, z,
*                           and w of the {@link Cartesian4}, respectively.
* @returns {Intersect} {@link Intersect.INSIDE} if the entire sphere is on the side of the plane
*                      the normal is pointing, {@link Intersect.OUTSIDE} if the entire sphere is
*                      on the opposite side, and {@link Intersect.INTERSECTING} if the sphere
*                      intersects the plane.
*/
BoundingSphere.prototype.intersect = function(plane) {
    return BoundingSphere.intersect(this, plane);
};
*/
    /**
    * Determines whether or not a sphere is hidden from view by the occluder.
    *
    * @param {BoundingSphere} sphere The bounding sphere surrounding the occludee object.
    * @param {Occluder} occluder The occluder.
    * @returns {Boolean} <code>true</code> if the sphere is not visible; otherwise <code>false</code>.
    */
    func isOccluded (occluder: Occluder) -> Bool {
        return !occluder.isBoundingSphereVisible(self)
    }
    /*
    /**
* Compares this BoundingSphere against the provided BoundingSphere componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {BoundingSphere} [right] The right hand side BoundingSphere.
* @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
*/
BoundingSphere.prototype.equals = function(right) {
    return BoundingSphere.equals(this, right);
};

};*/

}