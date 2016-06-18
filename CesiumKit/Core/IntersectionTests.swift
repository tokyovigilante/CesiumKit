//
//  IntersectionTests.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 29/03/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation
import simd

/**
 * Functions for computing the intersection between geometries such as rays, planes, triangles, and ellipsoids.
 *
 * @namespace
 * @alias IntersectionTests
 */
class IntersectionTests {
    
    /**
     * Computes the intersection of a ray and a plane.
     *
     * @param {Ray} ray The ray.
     * @param {Plane} plane The plane.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The intersection point or undefined if there is no intersections.
     */
    static func rayPlane (ray: Ray, plane: Plane) -> Cartesian3? {
        
        let origin = ray.origin
        let direction = ray.direction
        let normal = plane.normal
        let denominator = normal.dot(direction)
        
        if abs(denominator) < Math.Epsilon15 {
            // Ray is parallel to plane.  The ray may be in the polygon's plane.
            return nil
        }
        let t = (-plane.distance - normal.dot(origin)) / denominator
        
        if t < 0 {
            return nil
        }
        return origin.add(direction.multiplyByScalar(t))
    }
    
    static private func _rayTriangle (ray: Ray, p0: Cartesian3, p1: Cartesian3, p2: Cartesian3, cullBackFaces: Bool = false) -> Double? {
        
        let origin = ray.origin
        let direction = ray.direction
        
        let edge0 = p1.subtract(p0)
        let edge1 = p2.subtract(p0)
        
        let p = direction.cross(edge1)
        let det = edge0.dot(p)
        
        let tvec: Cartesian3
        let q: Cartesian3
        
        var u, v, t: Double
        
        if cullBackFaces {
            if det < Math.Epsilon6 {
                return nil
            }
            
            tvec = origin.subtract(p0)
            u = tvec.dot(p)
            if u < 0.0 || u > det {
                return nil
            }
            
            q = tvec.cross(edge0)
            
            v = direction.dot(q)
            if (v < 0.0 || u + v > det) {
                return nil
            }
            
            t = edge1.dot(q) / det
        } else {
            if abs(det) < Math.Epsilon6 {
                return nil
            }
            let invDet = 1.0 / det
            
            tvec = origin.subtract(p0)
            u = tvec.dot(p) * invDet
            if u < 0.0 || u > 1.0 {
                return nil
            }
            
            q = tvec.cross(edge0)
            
            v = direction.dot(q) * invDet
            if v < 0.0 || u + v > 1.0 {
                return nil
            }
            
            t = edge1.dot(q) * invDet
        }
        
        return t
    }
    
    /**
     * Computes the intersection of a ray and a triangle.
     * @memberof IntersectionTests
     *
     * @param {Ray} ray The ray.
     * @param {Cartesian3} p0 The first vertex of the triangle.
     * @param {Cartesian3} p1 The second vertex of the triangle.
     * @param {Cartesian3} p2 The third vertex of the triangle.
     * @param {Boolean} [cullBackFaces=false] If <code>true</code>, will only compute an intersection with the front face of the triangle
     *                  and return undefined for intersections with the back face.
     * @param {Cartesian3} [result] The <code>Cartesian3</code> onto which to store the result.
     * @returns {Cartesian3} The intersection point or undefined if there is no intersections.
     */
    static func rayTriangle (ray: Ray, p0: Cartesian3, p1: Cartesian3, p2: Cartesian3, cullBackFaces: Bool = false) -> Cartesian3? {
        let t = _rayTriangle(ray, p0: p0, p1: p1, p2: p2, cullBackFaces: cullBackFaces)
        if t == nil || t < 0.0 {
            return nil
        }
        return ray.origin.add(ray.direction.multiplyByScalar(t!))
    }
    
    /*
     var scratchLineSegmentTriangleRay = new Ray();
     
     /**
     * Computes the intersection of a line segment and a triangle.
     * @memberof IntersectionTests
     *
     * @param {Cartesian3} v0 The an end point of the line segment.
     * @param {Cartesian3} v1 The other end point of the line segment.
     * @param {Cartesian3} p0 The first vertex of the triangle.
     * @param {Cartesian3} p1 The second vertex of the triangle.
     * @param {Cartesian3} p2 The third vertex of the triangle.
     * @param {Boolean} [cullBackFaces=false] If <code>true</code>, will only compute an intersection with the front face of the triangle
     *                  and return undefined for intersections with the back face.
     * @param {Cartesian3} [result] The <code>Cartesian3</code> onto which to store the result.
     * @returns {Cartesian3} The intersection point or undefined if there is no intersections.
     */
     IntersectionTests.lineSegmentTriangle = function(v0, v1, p0, p1, p2, cullBackFaces, result) {
     //>>includeStart('debug', pragmas.debug);
     if (!defined(v0)) {
     throw new DeveloperError('v0 is required.');
     }
     if (!defined(v1)) {
     throw new DeveloperError('v1 is required.');
     }
     //>>includeEnd('debug');
     
     var ray = scratchLineSegmentTriangleRay;
     Cartesian3.clone(v0, ray.origin);
     Cartesian3.subtract(v1, v0, ray.direction);
     Cartesian3.normalize(ray.direction, ray.direction);
     
     var t = rayTriangle(ray, p0, p1, p2, cullBackFaces);
     if (!defined(t) || t < 0.0 || t > Cartesian3.distance(v0, v1)) {
     return undefined;
     }
     
     if (!defined(result)) {
     result = new Cartesian3();
     }
     
     Cartesian3.multiplyByScalar(ray.direction, t, result);
     return Cartesian3.add(ray.origin, result, result);
     };
     */
    private static func solveQuadratic(a a: Double, b: Double, c: Double)  -> Interval? {
        let det = b * b - 4.0 * a * c
        if det < 0.0 {
            return nil
        } else if det > 0.0 {
            let denom = 1.0 / (2.0 * a)
            let disc = sqrt(det)
            let root0 = (-b + disc) * denom
            let root1 = (-b - disc) * denom
            
            if root0 < root1 {
                return Interval(start: root0, stop: root1)
            } else {
                return Interval(start: root1, stop: root0)
            }
        }
        
        let root = -b / (2.0 * a)
        if root == 0.0 {
            return nil
        }
        return Interval(start: root, stop: root)
    }
    
    private static func _raySphere(ray: Ray, sphere: BoundingSphere) -> Interval? {
        
        let origin = ray.origin
        let direction = ray.direction
        
        let center = sphere.center
        let radiusSquared = sphere.radius * sphere.radius
        
        let diff = origin.subtract(center)
        
        let a = direction.dot(direction)
        let b = 2.0 * direction.dot(diff)
        let c = diff.magnitudeSquared - radiusSquared
        
        return solveQuadratic(a: a, b: b, c: c)
    }
    
    /**
     * Computes the intersection points of a ray with a sphere.
     * @memberof IntersectionTests
     *
     * @param {Ray} ray The ray.
     * @param {BoundingSphere} sphere The sphere.
     * @param {Object} [result] The result onto which to store the result.
     * @returns {Object} An object with the first (<code>start</code>) and the second (<code>stop</code>) intersection scalars for points along the ray or undefined if there are no intersections.
     */
    static func raySphere (ray: Ray, sphere: BoundingSphere) -> Interval? {
        
        var result = _raySphere(ray, sphere: sphere)
        
        if result == nil || result!.stop < 0.0 {
            return nil
        }
        result!.start = max(result!.start, 0.0)
        return result
    }
    
    /*var scratchLineSegmentRay = new Ray();
     
     /**
     * Computes the intersection points of a line segment with a sphere.
     * @memberof IntersectionTests
     *
     * @param {Cartesian3} p0 An end point of the line segment.
     * @param {Cartesian3} p1 The other end point of the line segment.
     * @param {BoundingSphere} sphere The sphere.
     * @param {Object} [result] The result onto which to store the result.
     * @returns {Object} An object with the first (<code>start</code>) and the second (<code>stop</code>) intersection scalars for points along the line segment or undefined if there are no intersections.
     */
     IntersectionTests.lineSegmentSphere = function(p0, p1, sphere, result) {
     //>>includeStart('debug', pragmas.debug);
     if (!defined(p0)) {
     throw new DeveloperError('p0 is required.');
     }
     if (!defined(p1)) {
     throw new DeveloperError('p1 is required.');
     }
     if (!defined(sphere)) {
     throw new DeveloperError('sphere is required.');
     }
     //>>includeEnd('debug');
     
     var ray = scratchLineSegmentRay;
     Cartesian3.clone(p0, ray.origin);
     var direction = Cartesian3.subtract(p1, p0, ray.direction);
     
     var maxT = Cartesian3.magnitude(direction);
     Cartesian3.normalize(direction, direction);
     
     result = raySphere(ray, sphere, result);
     if (!defined(result) || result.stop < 0.0 || result.start > maxT) {
     return undefined;
     }
     
     result.start = Math.max(result.start, 0.0);
     result.stop = Math.min(result.stop, maxT);
     return result;
     };
     
     var scratchQ = new Cartesian3();
     var scratchW = new Cartesian3();
     */
    /**
     * Computes the intersection points of a ray with an ellipsoid.
     *
     * @param {Ray} ray The ray.
     * @param {Ellipsoid} ellipsoid The ellipsoid.
     * @returns {Object} An object with the first (<code>start</code>) and the second (<code>stop</code>) intersection scalars for points along the ray or undefined if there are no intersections.
     */
    static func rayEllipsoid (ray: Ray, ellipsoid: Ellipsoid) -> Interval? {
        
        let inverseRadii = ellipsoid.oneOverRadii
        let q = inverseRadii.multiplyComponents(ray.origin)
        let w = inverseRadii.multiplyComponents(ray.direction)
        
        let q2 = q.magnitudeSquared
        let qw = q.dot(w)
        
        var difference, w2, product, discriminant, temp: Double
        
        if q2 > 1.0 {
            // Outside ellipsoid.
            if qw >= 0.0 {
                // Looking outward or tangent (0 intersections).
                return nil
            }
            
            // qw < 0.0.
            let qw2 = qw * qw
            difference = q2 - 1.0 // Positively valued.
            w2 = w.magnitudeSquared
            product = w2 * difference
            
            if qw2 < product {
                // Imaginary roots (0 intersections).
                return nil
            } else if qw2 > product {
                // Distinct roots (2 intersections).
                discriminant = qw * qw - product
                temp = -qw + sqrt(discriminant) // Avoid cancellation.
                let root0 = temp / w2
                let root1 = difference / temp
                if (root0 < root1) {
                    return Interval(start: root0, stop: root1)
                }
                return Interval(start : root1, stop : root0)
            } else {
                // qw2 == product.  Repeated roots (2 intersections).
                let root = sqrt(difference / w2)
                return Interval(start : root, stop : root)
            }
        } else if q2 < 1.0 {
            // Inside ellipsoid (2 intersections).
            difference = q2 - 1.0 // Negatively valued.
            w2 = w.magnitudeSquared
            product = w2 * difference // Negatively valued.
            
            discriminant = qw * qw - product
            temp = -qw + sqrt(discriminant) // Positively valued.
            return Interval(start : 0.0, stop: temp / w2)
        } else {
            // q2 == 1.0. On ellipsoid.
            if qw < 0.0 {
                // Looking inward.
                w2 = w.magnitudeSquared
                return Interval(start: 0.0, stop: -qw / w2)
            }
            // qw >= 0.0.  Looking outward or tangent.
            return nil
        }
    }
    
    
    func addWithCancellationCheck(left: Double, _ right: Double, tolerance: Double) -> Double {
        let difference = left + right
        if (Math.sign(left) != Math.sign(right)) &&
            abs(difference / max(abs(left), abs(right))) < tolerance {
            return 0.0
        }
        return difference
    }
    
    func quadraticVectorExpression(A: Matrix3, b: Cartesian3, c: Double, x: Double, w: Double) -> [Double] {
        let xSquared = x * x
        let wSquared = w * w
        return [Double]()
        /*
        let l2 = (A[1,1] - A[2,2] * wSquared
        let l1: Double = w * (x * addWithCancellationCheck(A[1,0], A[0,1], tolerance: Math.Epsilon15) + b.y)
        let l0 = (A[0,0] * xSquared + A[2,2] * wSquared) + x * b.x + c
        
         let r1 = wSquared * addWithCancellationCheck(A[2,1], A[1,2], tolerance: Math.Epsilon15)
         let r0 = w * (x * addWithCancellationCheck(A[2,0], A[0,2]) + b.z)
        
         let cosines
         var solutions = [Double]
         if (r0 === 0.0 && r1 === 0.0) {
         cosines = QuadraticRealPolynomial.computeRealRoots(l2, l1, l0);
         if (cosines.length === 0) {
         return solutions;
         }
         
         var cosine0 = cosines[0];
         var sine0 = Math.sqrt(Math.max(1.0 - cosine0 * cosine0, 0.0));
         solutions.push(new Cartesian3(x, w * cosine0, w * -sine0));
         solutions.push(new Cartesian3(x, w * cosine0, w * sine0));
         
         if (cosines.length === 2) {
         var cosine1 = cosines[1];
         var sine1 = Math.sqrt(Math.max(1.0 - cosine1 * cosine1, 0.0));
         solutions.push(new Cartesian3(x, w * cosine1, w * -sine1));
         solutions.push(new Cartesian3(x, w * cosine1, w * sine1));
         }
         
         return solutions;
         }
         
         var r0Squared = r0 * r0;
         var r1Squared = r1 * r1;
         var l2Squared = l2 * l2;
         var r0r1 = r0 * r1;
         
         var c4 = l2Squared + r1Squared;
         var c3 = 2.0 * (l1 * l2 + r0r1);
         var c2 = 2.0 * l0 * l2 + l1 * l1 - r1Squared + r0Squared;
         var c1 = 2.0 * (l0 * l1 - r0r1);
         var c0 = l0 * l0 - r0Squared;
         
         if (c4 === 0.0 && c3 === 0.0 && c2 === 0.0 && c1 === 0.0) {
         return solutions;
         }
         
         cosines = QuarticRealPolynomial.computeRealRoots(c4, c3, c2, c1, c0);
         var length = cosines.length;
         if (length === 0) {
         return solutions;
         }
         
         for ( var i = 0; i < length; ++i) {
         var cosine = cosines[i];
         var cosineSquared = cosine * cosine;
         var sineSquared = Math.max(1.0 - cosineSquared, 0.0);
         var sine = Math.sqrt(sineSquared);
         
         //var left = l2 * cosineSquared + l1 * cosine + l0;
         var left;
         if (CesiumMath.sign(l2) === CesiumMath.sign(l0)) {
         left = addWithCancellationCheck(l2 * cosineSquared + l0, l1 * cosine, CesiumMath.EPSILON12);
         } else if (CesiumMath.sign(l0) === CesiumMath.sign(l1 * cosine)) {
         left = addWithCancellationCheck(l2 * cosineSquared, l1 * cosine + l0, CesiumMath.EPSILON12);
         } else {
         left = addWithCancellationCheck(l2 * cosineSquared + l1 * cosine, l0, CesiumMath.EPSILON12);
         }
         
         var right = addWithCancellationCheck(r1 * cosine, r0, CesiumMath.EPSILON15);
         var product = left * right;
         
         if (product < 0.0) {
         solutions.push(new Cartesian3(x, w * cosine, w * sine));
         } else if (product > 0.0) {
         solutions.push(new Cartesian3(x, w * cosine, w * -sine));
         } else if (sine !== 0.0) {
         solutions.push(new Cartesian3(x, w * cosine, w * -sine));
         solutions.push(new Cartesian3(x, w * cosine, w * sine));
         ++i;
         } else {
         solutions.push(new Cartesian3(x, w * cosine, w * sine));
         }
         }
         
         return solutions;*/
    }
    /*
     var firstAxisScratch = new Cartesian3();
     var secondAxisScratch = new Cartesian3();
     var thirdAxisScratch = new Cartesian3();
     var referenceScratch = new Cartesian3();
     var bCart = new Cartesian3();
     var bScratch = new Matrix3();
     var btScratch = new Matrix3();
     var diScratch = new Matrix3();
     var dScratch = new Matrix3();
     var cScratch = new Matrix3();
     var tempMatrix = new Matrix3();
     var aScratch = new Matrix3();
     var sScratch = new Cartesian3();
     var closestScratch = new Cartesian3();
     var surfPointScratch = new Cartographic();
     */
    
    /**
     * Provides the point along the ray which is nearest to the ellipsoid.
     *
     * @param {Ray} ray The ray.
     * @param {Ellipsoid} ellipsoid The ellipsoid.
     * @returns {Cartesian} The nearest planetodetic point on the ray.
     */
    static func grazingAltitudeLocation (ray: Ray, ellipsoid: Ellipsoid) -> Cartesian3? {
        
        let position = ray.origin
        let direction = ray.direction
        
        let normal = ellipsoid.geodeticSurfaceNormal(position)
        
        if direction.dot(normal) >= 0.0 {
            // The location provided is the closest point in altitude
            return position;
        }
        
        let intersects = IntersectionTests.rayEllipsoid(ray, ellipsoid: ellipsoid)
        
        // Compute the scaled direction vector.
        let f = ellipsoid.transformPositionToScaledSpace(direction)
        
        // Constructs a basis from the unit scaled direction vector. Construct its rotation and transpose.
        let firstAxis = f.normalize()
        let reference = f.mostOrthogonalAxis()
        let secondAxis = reference.cross(firstAxis).normalize()
        let thirdAxis  = firstAxis.cross(secondAxis).normalize()
        
        let B = Matrix3(simd: double3x3([
            firstAxis.simdType,
            secondAxis.simdType,
            thirdAxis.simdType
            ])
        )
        let B_T = B.transpose
        
        // Get the scaling matrix and its inverse.
        let D_I = Matrix3(scale: ellipsoid.radii)
        let D = Matrix3(scale: ellipsoid.oneOverRadii)
        
        let C = Matrix3(
            0.0, direction.z, -direction.y,
            -direction.z, 0.0, direction.x,
            direction.y, -direction.x, 0.0
        )
        
        let temp = B_T
            .multiply(D)
            .multiply(C)
        let A = temp
            .multiply(D_I)
            .multiply(B)
        //let b = temp.multiply(position)
        
        // Solve for the solutions to the expression in standard form:
        /*var solutions = quadraticVectorExpression(A, Cartesian3.negate(b, firstAxisScratch), 0.0, 0.0, 1.0)
        
        var s;
        var altitude;
        var length = solutions.length;
        if (length > 0) {
            var closest = Cartesian3.clone(Cartesian3.ZERO, closestScratch);
            var maximumValue = Number.NEGATIVE_INFINITY;
            
            for ( var i = 0; i < length; ++i) {
                s = Matrix3.multiplyByVector(D_I, Matrix3.multiplyByVector(B, solutions[i], sScratch), sScratch);
                var v = Cartesian3.normalize(Cartesian3.subtract(s, position, referenceScratch), referenceScratch);
                var dotProduct = Cartesian3.dot(v, direction);
                
                if (dotProduct > maximumValue) {
                    maximumValue = dotProduct;
                    closest = Cartesian3.clone(s, closest);
                }
            }
            
            var surfacePoint = ellipsoid.cartesianToCartographic(closest, surfPointScratch);
            maximumValue = Math.clamp(maximumValue, 0.0, 1.0);
            altitude = Cartesian3.magnitude(Cartesian3.subtract(closest, position, referenceScratch)) * Math.sqrt(1.0 - maximumValue * maximumValue);
            altitude = intersects ? -altitude : altitude;
            surfacePoint.height = altitude;
            return ellipsoid.cartographicToCartesian(surfacePoint)
        }*/
        
        return nil
    }
    /*
     var lineSegmentPlaneDifference = new Cartesian3();
     
     /**
     * Computes the intersection of a line segment and a plane.
     *
     * @param {Cartesian3} endPoint0 An end point of the line segment.
     * @param {Cartesian3} endPoint1 The other end point of the line segment.
     * @param {Plane} plane The plane.
     * @param {Cartesian3} [result] The object onto which to store the result.
     * @returns {Cartesian3} The intersection point or undefined if there is no intersection.
     *
     * @example
     * var origin = Cesium.Cartesian3.fromDegrees(-75.59777, 40.03883);
     * var normal = ellipsoid.geodeticSurfaceNormal(origin);
     * var plane = Cesium.Plane.fromPointNormal(origin, normal);
     *
     * var p0 = new Cesium.Cartesian3(...);
     * var p1 = new Cesium.Cartesian3(...);
     *
     * // find the intersection of the line segment from p0 to p1 and the tangent plane at origin.
     * var intersection = Cesium.IntersectionTests.lineSegmentPlane(p0, p1, plane);
     */
     IntersectionTests.lineSegmentPlane = function(endPoint0, endPoint1, plane, result) {
     //>>includeStart('debug', pragmas.debug);
     if (!defined(endPoint0)) {
     throw new DeveloperError('endPoint0 is required.');
     }
     if (!defined(endPoint1)) {
     throw new DeveloperError('endPoint1 is required.');
     }
     if (!defined(plane)) {
     throw new DeveloperError('plane is required.');
     }
     //>>includeEnd('debug');
     
     if (!defined(result)) {
     result = new Cartesian3();
     }
     
     var difference = Cartesian3.subtract(endPoint1, endPoint0, lineSegmentPlaneDifference);
     var normal = plane.normal;
     var nDotDiff = Cartesian3.dot(normal, difference);
     
     // check if the segment and plane are parallel
     if (Math.abs(nDotDiff) < CesiumMath.EPSILON6) {
     return undefined;
     }
     
     var nDotP0 = Cartesian3.dot(normal, endPoint0);
     var t = -(plane.distance + nDotP0) / nDotDiff;
     
     // intersection only if t is in [0, 1]
     if (t < 0.0 || t > 1.0) {
     return undefined;
     }
     
     // intersection is endPoint0 + t * (endPoint1 - endPoint0)
     Cartesian3.multiplyByScalar(difference, t, result);
     Cartesian3.add(endPoint0, result, result);
     return result;
     };
     
     /**
     * Computes the intersection of a triangle and a plane
     *
     * @param {Cartesian3} p0 First point of the triangle
     * @param {Cartesian3} p1 Second point of the triangle
     * @param {Cartesian3} p2 Third point of the triangle
     * @param {Plane} plane Intersection plane
     * @returns {Object} An object with properties <code>positions</code> and <code>indices</code>, which are arrays that represent three triangles that do not cross the plane. (Undefined if no intersection exists)
     *
     * @example
     * var origin = Cesium.Cartesian3.fromDegrees(-75.59777, 40.03883);
     * var normal = ellipsoid.geodeticSurfaceNormal(origin);
     * var plane = Cesium.Plane.fromPointNormal(origin, normal);
     *
     * var p0 = new Cesium.Cartesian3(...);
     * var p1 = new Cesium.Cartesian3(...);
     * var p2 = new Cesium.Cartesian3(...);
     *
     * // convert the triangle composed of points (p0, p1, p2) to three triangles that don't cross the plane
     * var triangles = Cesium.IntersectionTests.trianglePlaneIntersection(p0, p1, p2, plane);
     */
     IntersectionTests.trianglePlaneIntersection = function(p0, p1, p2, plane) {
     //>>includeStart('debug', pragmas.debug);
     if ((!defined(p0)) ||
     (!defined(p1)) ||
     (!defined(p2)) ||
     (!defined(plane))) {
     throw new DeveloperError('p0, p1, p2, and plane are required.');
     }
     //>>includeEnd('debug');
     
     var planeNormal = plane.normal;
     var planeD = plane.distance;
     var p0Behind = (Cartesian3.dot(planeNormal, p0) + planeD) < 0.0;
     var p1Behind = (Cartesian3.dot(planeNormal, p1) + planeD) < 0.0;
     var p2Behind = (Cartesian3.dot(planeNormal, p2) + planeD) < 0.0;
     // Given these dots products, the calls to lineSegmentPlaneIntersection
     // always have defined results.
     
     var numBehind = 0;
     numBehind += p0Behind ? 1 : 0;
     numBehind += p1Behind ? 1 : 0;
     numBehind += p2Behind ? 1 : 0;
     
     var u1, u2;
     if (numBehind === 1 || numBehind === 2) {
     u1 = new Cartesian3();
     u2 = new Cartesian3();
     }
     
     if (numBehind === 1) {
     if (p0Behind) {
     IntersectionTests.lineSegmentPlane(p0, p1, plane, u1);
     IntersectionTests.lineSegmentPlane(p0, p2, plane, u2);
     
     return {
     positions : [p0, p1, p2, u1, u2 ],
     indices : [
     // Behind
     0, 3, 4,
     
     // In front
     1, 2, 4,
     1, 4, 3
     ]
     };
     } else if (p1Behind) {
     IntersectionTests.lineSegmentPlane(p1, p2, plane, u1);
     IntersectionTests.lineSegmentPlane(p1, p0, plane, u2);
     
     return {
     positions : [p0, p1, p2, u1, u2 ],
     indices : [
     // Behind
     1, 3, 4,
     
     // In front
     2, 0, 4,
     2, 4, 3
     ]
     };
     } else if (p2Behind) {
     IntersectionTests.lineSegmentPlane(p2, p0, plane, u1);
     IntersectionTests.lineSegmentPlane(p2, p1, plane, u2);
     
     return {
     positions : [p0, p1, p2, u1, u2 ],
     indices : [
     // Behind
     2, 3, 4,
     
     // In front
     0, 1, 4,
     0, 4, 3
     ]
     };
     }
     } else if (numBehind === 2) {
     if (!p0Behind) {
     IntersectionTests.lineSegmentPlane(p1, p0, plane, u1);
     IntersectionTests.lineSegmentPlane(p2, p0, plane, u2);
     
     return {
     positions : [p0, p1, p2, u1, u2 ],
     indices : [
     // Behind
     1, 2, 4,
     1, 4, 3,
     
     // In front
     0, 3, 4
     ]
     };
     } else if (!p1Behind) {
     IntersectionTests.lineSegmentPlane(p2, p1, plane, u1);
     IntersectionTests.lineSegmentPlane(p0, p1, plane, u2);
     
     return {
     positions : [p0, p1, p2, u1, u2 ],
     indices : [
     // Behind
     2, 0, 4,
     2, 4, 3,
     
     // In front
     1, 3, 4
     ]
     };
     } else if (!p2Behind) {
     IntersectionTests.lineSegmentPlane(p0, p2, plane, u1);
     IntersectionTests.lineSegmentPlane(p1, p2, plane, u2);
     
     return {
     positions : [p0, p1, p2, u1, u2 ],
     indices : [
     // Behind
     0, 1, 4,
     0, 4, 3,
     
     // In front
     2, 3, 4
     ]
     };
     }
     }
     
     // if numBehind is 3, the triangle is completely behind the plane;
     // otherwise, it is completely in front (numBehind is 0).
     return undefined;
     };
     
     */
}