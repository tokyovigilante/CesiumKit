//
//  Intersections2D.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 2/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * Contains functions for operating on 2D triangles.
 *
 * @namespace
 * @alias Intersections2D
 */
class Intersections2D {

     /**
     * Splits a 2D triangle at given axis-aligned threshold value and returns the resulting
     * polygon on a given side of the threshold.  The resulting polygon may have 0, 1, 2,
     * 3, or 4 vertices.
     *
     * @param {Number} threshold The threshold coordinate value at which to clip the triangle.
     * @param {Boolean} keepAbove true to keep the portion of the triangle above the threshold, or false
     *                            to keep the portion below.
     * @param {Number} u0 The coordinate of the first vertex in the triangle, in counter-clockwise order.
     * @param {Number} u1 The coordinate of the second vertex in the triangle, in counter-clockwise order.
     * @param {Number} u2 The coordinate of the third vertex in the triangle, in counter-clockwise order.
     * @param {Number[]} [result] The array into which to copy the result.  If this parameter is not supplied,
     *                            a new array is constructed and returned.
     * @returns {Number[]} The polygon that results after the clip, specified as a list of
     *                     vertices.  The vertices are specified in counter-clockwise order.
     *                     Each vertex is either an index from the existing list (identified as
     *                     a 0, 1, or 2) or -1 indicating a new vertex not in the original triangle.
     *                     For new vertices, the -1 is followed by three additional numbers: the
     *                     index of each of the two original vertices forming the line segment that
     *                     the new vertex lies on, and the fraction of the distance from the first
     *                     vertex to the second one.
     *
     * @example
     * var result = Cesium.Intersections2D.clipTriangleAtAxisAlignedThreshold(0.5, false, 0.2, 0.6, 0.4);
     * // result === [2, 0, -1, 1, 0, 0.25, -1, 1, 2, 0.5]
     */
    class func clipTriangleAtAxisAlignedThreshold (threshold thresholdInt: Int, keepAbove: Bool, u0 u0Int: Int, u1 u1Int: Int, u2 u2Int: Int) -> [Double] {

        var result = [Double]()
        let threshold = Double(thresholdInt)
        let u0 = Double(u0Int)
        let u1 = Double(u1Int)
        let u2 = Double(u2Int)

        let u0Behind: Bool
        let u1Behind: Bool
        let u2Behind: Bool
        if keepAbove {
            u0Behind = u0 < threshold
            u1Behind = u1 < threshold
            u2Behind = u2 < threshold
        } else {
            u0Behind = u0 > threshold
            u1Behind = u1 > threshold
            u2Behind = u2 > threshold
        }

        let numBehind = Int(u0Behind) + Int(u1Behind) + Int(u2Behind)

        var u01Ratio: Double
        var u02Ratio: Double
        var u12Ratio: Double
        var u10Ratio: Double
        var u20Ratio: Double
        var u21Ratio: Double

        if numBehind == 1 {
            if u0Behind {
                u01Ratio = (threshold - u0) / (u1 - u0)
                u02Ratio = (threshold - u0) / (u2 - u0)

                result.append(1)

                result.append(2)

                if u02Ratio != 1.0 {
                    result.append(-1)
                    result.append(0)
                    result.append(2)
                    result.append(u02Ratio)
                }

                if u01Ratio != 1.0 {
                    result.append(-1)
                    result.append(0)
                    result.append(1)
                    result.append(u01Ratio)
                }
            } else if u1Behind {
                u12Ratio = (threshold - u1) / (u2 - u1)
                u10Ratio = (threshold - u1) / (u0 - u1)

                result.append(2);

                result.append(0);

                if u10Ratio != 1.0 {
                    result.append(-1)
                    result.append(1)
                    result.append(0)
                    result.append(u10Ratio)
                }

                if u12Ratio != 1.0 {
                    result.append(-1)
                    result.append(1)
                    result.append(2)
                    result.append(u12Ratio)
                }
            } else if (u2Behind) {
                u20Ratio = (threshold - u2) / (u0 - u2);
                u21Ratio = (threshold - u2) / (u1 - u2);

                result.append(0)

                result.append(1)

                if u21Ratio != 1.0 {
                    result.append(-1)
                    result.append(2)
                    result.append(1)
                    result.append(u21Ratio)
                }

                if u20Ratio != 1.0 {
                    result.append(-1)
                    result.append(2)
                    result.append(0)
                    result.append(u20Ratio)
                }
            }
        } else if numBehind == 2 {
            if !u0Behind && u0 != threshold {
                u10Ratio = (threshold - u1) / (u0 - u1)
                u20Ratio = (threshold - u2) / (u0 - u2)

                result.append(0)

                result.append(-1)
                result.append(1)
                result.append(0)
                result.append(u10Ratio)

                result.append(-1)
                result.append(2)
                result.append(0)
                result.append(u20Ratio)
            } else if !u1Behind && u1 != threshold {
                u21Ratio = (threshold - u2) / (u1 - u2)
                u01Ratio = (threshold - u0) / (u1 - u0)

                result.append(1)

                result.append(-1)
                result.append(2)
                result.append(1)
                result.append(u21Ratio)

                result.append(-1)
                result.append(0)
                result.append(1)
                result.append(u01Ratio)
            } else if !u2Behind && u2 != threshold {
                u02Ratio = (threshold - u0) / (u2 - u0)
                u12Ratio = (threshold - u1) / (u2 - u1)

                result.append(2);

                result.append(-1)
                result.append(0)
                result.append(2)
                result.append(u02Ratio)

                result.append(-1)
                result.append(1)
                result.append(2)
                result.append(u12Ratio)
            }
        } else if numBehind != 3 {
            // Completely in front of threshold
            result.append(0)
            result.append(1)
            result.append(2)
        }
        // else Completely behind threshold
        return result
    }

     /**
     * Compute the barycentric coordinates of a 2D position within a 2D triangle.
     *
     * @param {Number} x The x coordinate of the position for which to find the barycentric coordinates.
     * @param {Number} y The y coordinate of the position for which to find the barycentric coordinates.
     * @param {Number} x1 The x coordinate of the triangle's first vertex.
     * @param {Number} y1 The y coordinate of the triangle's first vertex.
     * @param {Number} x2 The x coordinate of the triangle's second vertex.
     * @param {Number} y2 The y coordinate of the triangle's second vertex.
     * @param {Number} x3 The x coordinate of the triangle's third vertex.
     * @param {Number} y3 The y coordinate of the triangle's third vertex.
     * @param {Cartesian3} [result] The instance into to which to copy the result.  If this parameter
     *                     is undefined, a new instance is created and returned.
     * @returns {Cartesian3} The barycentric coordinates of the position within the triangle.
     *
     * @example
     * var result = Cesium.Intersections2D.computeBarycentricCoordinates(0.0, 0.0, 0.0, 1.0, -1, -0.5, 1, -0.5);
     * // result === new Cesium.Cartesian3(1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0);
     */
    static func computeBarycentricCoordinates (x: Double, y: Double, x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) -> Cartesian3 {

        let x1mx3 = x1 - x3
        let x3mx2 = x3 - x2
        let y2my3 = y2 - y3
        let y1my3 = y1 - y3
        let inverseDeterminant = 1.0 / (y2my3 * x1mx3 + x3mx2 * y1my3)
        let ymy3 = y - y3
        let xmx3 = x - x3
        let l1 = (y2my3 * xmx3 + x3mx2 * ymy3) * inverseDeterminant
        let l2 = (-y1my3 * xmx3 + x1mx3 * ymy3) * inverseDeterminant
        let l3 = 1.0 - l1 - l2

        return Cartesian3(x: l1, y: l2, z: l3)
    }


}
