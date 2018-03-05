//
//  HeadingPitchRange.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/03/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation

/**
 * Defines a heading angle, pitch angle an range in a local frame.
 * Heading is the rotation from the local north direction where a positive angle is increasing eastward.
 * Pitch is the rotation from the local xy-plane. Positive pitch angles are above the plane. Negative pitch
 * angles are below the plane. Range is the distance from the center of the frame.
 * @alias HeadingPitchRange
 * @constructor
 *
 * @param {Number} [heading=0.0] The heading angle in radians.
 * @param {Number} [pitch=0.0] The pitch angle in radians.
 * @param {Number} [range=0.0] The distance from the center in meters.
 */

public struct HeadingPitchRange {

    /**
     * Heading is the rotation from the local north direction where a positive angle is increasing eastward.
     * @type {Number}
     */
    public var heading: Double = 0.0

    /**
     * Pitch is the rotation from the local xy-plane. Positive pitch angles
     * are above the plane. Negative pitch angles are below the plane.
     * @type {Number}
     */
    public var pitch: Double = 0.0

    /**
     * Range is the distance from the center of the local frame.
     * @type {Number}
     */
    public var range: Double = 0.0

    public init (heading: Double = 0.0, pitch: Double = 0.0, range: Double = 0.0) {
        self.heading = heading
        self.pitch = pitch
        self.range = range
    }
}

extension HeadingPitchRange: Offset {

    public var offset: Cartesian3 {
        let pitch = Math.clamp(self.pitch, min: -.pi/2, max: .pi/2)
        let heading = Math.zeroToTwoPi(self.heading) - .pi/2

        let pitchQuat = Quaternion(axis: Cartesian3.unitY, angle: -pitch)
        let headingQuat = Quaternion(axis: Cartesian3.unitZ, angle: -heading)
        let rotQuat = headingQuat.multiply(pitchQuat)
        let rotMatrix = Matrix3(quaternion: rotQuat)

        let offset = rotMatrix
            .multiplyByVector(Cartesian3.unitX)
            .negate()
            .multiplyBy(scalar: range)
        return offset
    }

}

