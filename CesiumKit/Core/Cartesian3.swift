//
//  Cartesian3.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* A 3D Cartesian point.
* @alias Cartesian3
* @constructor
*
* @param {Number} [x=0.0] The X component.
* @param {Number} [y=0.0] The Y component.
* @param {Number} [z=0.0] The Z component.
*
* @see Cartesian2
* @see Cartesian4
* @see Packable
*/
struct Cartesian3: Packable {
    /**
    * The X component.
    * @type {Number}
    * @default 0.0
    */
    var x: Double = 0.0
    
    /**
    * The Y component.
    * @type {Number}
    * @default 0.0
    */
    var y: Double = 0.0
    
    /**
    * The Z component.
    * @type {Number}
    * @default 0.0
    */
    var z: Double = 0.0
    
    /**
    * The number of elements used to pack the object into an array.
    * @type {Number}
    */
    static var packedLength: UInt = 4
    
    /**
    * Converts the provided Spherical into Cartesian3 coordinates.
    *
    * @param {Spherical} spherical The Spherical to be converted to Cartesian3.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    init(fromSpherical spherical: Spherical) {
        var clock = spherical.clock
        var cone = spherical.cone
        var magnitude = spherical.magnitude
        var radial = magnitude * sin(cone);
        x = radial * cos(clock);
        y = radial * sin(clock);
        z = magnitude * cos(cone);
    }

    /**
    * Creates a Cartesian3 instance from x, y and z coordinates.
    *
    * @param {Number} x The x coordinate.
    * @param {Number} y The y coordinate.
    * @param {Number} z The z coordinate.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    init(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) {
        self.x = x;
        self.y = y;
        self.z = z;
    }

    /**
    * Creates a Cartesian3 instance from an existing Cartesian4.  This simply takes the
    * x, y, and z properties of the Cartesian4 and drops w.
    * @function
    *
    * @param {Cartesian4} cartesian The Cartesian4 instance to create a Cartesian3 instance from.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    init(fromCartesian4 cartesian4: Cartesian4) {
        x = cartesian4.x
        y = cartesian4.y
        z = cartesian4.z
    }
    
    /**
    * Stores the provided instance into the provided array.
    *
    * @param {Cartesian3} value The value to pack.
    * @param {Number[]} array The array to pack into.
    * @param {Number} [startingIndex=0] The index into the array at which to start packing the elements.
    */
    func pack(inout array: Float32[], startingIndex: Int) {
        if array.count < startingIndex - 4//Int(Cartesian3.packedLength)
        {
            array.append(Float32(x))
            array.append(Float32(y))
            array.append(Float32(z))
        }
        else
        {
            array[startingIndex] = Float32(x)
            array[startingIndex+1] = Float32(y)
            array[startingIndex+2] = Float32(z)
        }

    }
    
    /**
    * Retrieves an instance from a packed array.
    *
    * @param {Number[]} array The packed array.
    * @param {Number} [startingIndex=0] The starting index of the element to be unpacked.
    * @param {Cartesian3} [result] The object into which to store the result.
    */
    static func unpack(array: Float32[], startingIndex: Int = 0) -> Packable? {
        if array.count < startingIndex - 4//Int(Cartesian3.packedLength)
        {
            return nil
        }
        return Cartesian3(x: Double(array[startingIndex]), y: Double(array[startingIndex]), z: Double(array[startingIndex]))
    }


    /**
    * Creates a Cartesian3 from three consecutive elements in an array.
    * @function
    *
    * @param {Number[]} array The array whose three consecutive elements correspond to the x, y, and z components, respectively.
    * @param {Number} [startingIndex=0] The offset into the array of the first element, which corresponds to the x component.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    *
    * @example
    * // Create a Cartesian3 with (1.0, 2.0, 3.0)
    * var v = [1.0, 2.0, 3.0];
    * var p = Cesium.Cartesian3.fromArray(v);
    *
    * // Create a Cartesian3 with (1.0, 2.0, 3.0) using an offset into an array
    * var v2 = [0.0, 0.0, 1.0, 2.0, 3.0];
    * var p2 = Cesium.Cartesian3.fromArray(v2, 2);
    */
    init(fromArray array: Double[]) {
        x = array[0]
        y = array[1]
        z = array[2]
    }
    
    
    /**
    * Computes the value of the maximum component for the supplied Cartesian.
    *
    * @param {Cartesian3} cartesian The cartesian to use.
    * @returns {Number} The value of the maximum component.
    */
    func maximumComponent() -> Double {
        return max(x, y, z)
    }

    /**
    * Computes the value of the minimum component for the supplied Cartesian.
    *
    * @param {Cartesian3} cartesian The cartesian to use.
    * @returns {Number} The value of the minimum component.
    */
    func minimumComponent() -> Double {
        return min(x, y, z)
    }

    /**
    * Compares two Cartesians and computes a Cartesian which contains the minimum components of the supplied Cartesians.
    *
    * @param {Cartesian3} first A cartesian to compare.
    * @param {Cartesian3} second A cartesian to compare.
    * @param {Cartesian3} [result] The object into which to store the result.
    * @returns {Cartesian3} A cartesian with the minimum components.
    */
    func minimumByComponent(other: Cartesian3) -> Cartesian3 {
        return Cartesian3(x: min(x, other.x), y: min(x, other.x), z: min(x, other.x))
    }

    /**
    * Compares two Cartesians and computes a Cartesian which contains the maximum components of the supplied Cartesians.
    *
    * @param {Cartesian3} first A cartesian to compare.
    * @param {Cartesian3} second A cartesian to compare.
    * @param {Cartesian3} [result] The object into which to store the result.
    * @returns {Cartesian3} A cartesian with the maximum components.
    */
    func maximumByComponent(other: Cartesian3) -> Cartesian3 {
        return Cartesian3(x: max(x, other.x), y: max(x, other.x), z: max(x, other.x))
    }

    /**
    * Computes the provided Cartesian's squared magnitude.
    *
    * @param {Cartesian3} cartesian The Cartesian instance whose squared magnitude is to be computed.
    * @returns {Number} The squared magnitude.
    */
    func magnitudeSquared() -> Double {
        return x * x + y * y + z * z;
    }

    /**
    * Computes the Cartesian's magnitude (length).
    *
    * @param {Cartesian3} cartesian The Cartesian instance whose magnitude is to be computed.
    * @returns {Number} The magnitude.
    */
    func magnitude() -> Double {
        return sqrt(magnitudeSquared());
    }
    
    /**
    * Computes the distance between two points
    *
    * @param {Cartesian3} left The first point to compute the distance from.
    * @param {Cartesian3} right The second point to compute the distance to.
    * @returns {Number} The distance between two points.
    *
    * @example
    * // Returns 1.0
    * var d = Cesium.Cartesian3.distance(new Cesium.Cartesian3(1.0, 0.0, 0.0), new Cesium.Cartesian3(2.0, 0.0, 0.0));
    */
    func distance(other: Cartesian3) -> Double {
        return subtract(other).magnitude()
    }

    /**
    * Computes the normalized form of the supplied Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian to be normalized.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    
    func normalize() -> Cartesian3 {
        var magnitude = self.magnitude();
        return Cartesian3(x: x / magnitude, y: y / magnitude, z: z / magnitude)
    }

    /**
    * Computes the dot (scalar) product of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @returns {Number} The dot product.
    */
    func dot(other: Cartesian3) -> Double {
        
        return x * other.x + y * other.y + z * other.z;
    }

    /**
    * Computes the componentwise product of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func multiplyComponents(other: Cartesian3) -> Cartesian3 {
        return Cartesian3(x: x * other.x, y: y * other.y, z: z * other.z);
    }

    /**
    * Computes the componentwise sum of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func add(other: Cartesian3) -> Cartesian3 {
        return Cartesian3(x: x + other.x, y: y + other.y, z: z + other.z);
    }

    /**
    * Computes the componentwise difference of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func subtract(other: Cartesian3) -> Cartesian3 {
        return Cartesian3(x: x - other.x, y: y - other.y, z: z - other.z);
    }

    /**
    * Multiplies the provided Cartesian componentwise by the provided scalar.
    *
    * @param {Cartesian3} cartesian The Cartesian to be scaled.
    * @param {Number} scalar The scalar to multiply with.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func multiplyByScalar(scalar: Double) -> Cartesian3 {
        return  Cartesian3(x: x * scalar, y: y * scalar, z: z * scalar);
    }

    /**
    * Divides the provided Cartesian componentwise by the provided scalar.
    *
    * @param {Cartesian3} cartesian The Cartesian to be divided.
    * @param {Number} scalar The scalar to divide by.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func divideByScalar(scalar: Double) -> Cartesian3 {
        return  Cartesian3(x: x / scalar, y: y / scalar, z: z / scalar);
    }


    /**
    * Negates the provided Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian to be negated.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func negate() -> Cartesian3 {
        return Cartesian3(x: -x, y: -y, z: -z)
    }

    /**
    * Computes the absolute value of the provided Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian whose absolute value is to be computed.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func absolute() -> Cartesian3 {
        return Cartesian3(x: abs(x), y: abs(y), z: abs(z))
    }
    
    /**
    * Computes the linear interpolation or extrapolation at t using the provided cartesians.
    *
    * @param {Cartesian3} start The value corresponding to t at 0.0.
    * @param {Cartesian3} end The value corresponding to t at 1.0.
    * @param {Number} t The point along t at which to interpolate.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
    */
    func lerp(end: Cartesian3, t: Double) -> Cartesian3 {
        return self.multiplyByScalar(1.0 - t).add(end.multiplyByScalar(t));
    }

    /**
    * Returns the angle, in radians, between the provided Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @returns {Number} The angle between the Cartesians.
    */
    func angleBetween(other: Cartesian3) -> Double {
        var cosine = self.normalize().dot(other.normalize())
        var sine = self.normalize().cross(other.normalize()).magnitude()
        return atan2(sine, cosine)
    }

    /**
    * Returns the axis that is most orthogonal to the provided Cartesian.
    *
    * @param {Cartesian3} cartesian The Cartesian on which to find the most orthogonal axis.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The most orthogonal axis.
    */
    func mostOrthogonalAxis() -> Cartesian3 {
        
        let f = normalize().absolute();
        var result: Cartesian3
        
        if (f.x <= f.y) {
            if (f.x <= f.z) {
                result = Cartesian3.unitX
            } else {
                result = Cartesian3.unitZ
            }
        } else {
            if (f.y <= f.z) {
                result = Cartesian3.unitY
            } else {
                result = Cartesian3.unitZ
            }
        }
        
        return result;
    }

    /**
    * Compares the provided Cartesians componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {Cartesian3} [left] The first Cartesian.
    * @param {Cartesian3} [right] The second Cartesian.
    * @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
    */
    /*@infix func == (left: Cartesian3, right: Cartesian3) -> Bool {
    return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
    }*/

    /**
    * Compares the provided Cartesians componentwise and returns
    * <code>true</code> if they are within the provided epsilon,
    * <code>false</code> otherwise.
    *
    * @param {Cartesian3} [left] The first Cartesian.
    * @param {Cartesian3} [right] The second Cartesian.
    * @param {Number} epsilon The epsilon to use for equality testing.
    * @returns {Boolean} <code>true</code> if left and right are within the provided epsilon, <code>false</code> otherwise.
    */
    func equalsEpsilon(other: Cartesian3, epsilon: Double) -> Bool {
        return (abs(x - other.x) <= epsilon) && (abs(y - other.y) <= epsilon) && (abs(z - other.z) <= epsilon)
    }

    /**
    * Computes the cross (outer) product of two Cartesians.
    *
    * @param {Cartesian3} left The first Cartesian.
    * @param {Cartesian3} right The second Cartesian.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The cross product.
    */
    func cross(other: Cartesian3) -> Cartesian3 {
        
        var leftX = self.x;
        var leftY = self.y;
        var leftZ = self.z;
        var rightX = other.x;
        var rightY = other.y;
        var rightZ = other.z;
        
        var x = leftY * rightZ - leftZ * rightY;
        var y = leftZ * rightX - leftX * rightZ;
        var z = leftX * rightY - leftY * rightX;
        
        return Cartesian3(x: x, y: y, z: z);
    }

    /**
    * Returns a Cartesian3 position from longitude and latitude values given in degrees.
    *
    * @param {Number} longitude The longitude, in degrees
    * @param {Number} latitude The latitude, in degrees
    * @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The position
    *
    * @example
    * var position = Cartesian3.fromDegrees(-115.0, 37.0);
    */
    static func fromDegrees(longitude: Double, latitude: Double, height: Double = 0.0, ellipsoid: Ellipsoid = Ellipsoid.wgs84Ellipsoid()) -> Cartesian3 {
    
        var lon = CSMath.toRadians(longitude)
        var lat = CSMath.toRadians(latitude)
        return Cartesian3.fromRadians(longitude: lon, latitude: lat, height: height, ellipsoid: ellipsoid)
    }
/*
    
    /**
    * Returns a Cartesian3 position from longitude and latitude values given in radians.
    *
    * @param {Number} longitude The longitude, in radians
    * @param {Number} latitude The latitude, in radians
    * @param {Number} [height=0.0] The height, in meters, above the ellipsoid.
    * @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
    * @param {Cartesian3} [result] The object onto which to store the result.
    * @returns {Cartesian3} The position
    *
    * @example
    * var position = Cartesian3.fromRadians(-2.007, 0.645);
    */
    static func fromRadians(#longitude: Double, latitude: Double, height: Double = 0.0, ellipsoid: Ellipsoid = Ellipsoid.wgs84Ellipsoid()) -> Cartesian3 {
        
        var radiiSquared = ellipsoid.radiiSquared
        
        var cosLatitude = cos(latitude);
        scratchN.x = cosLatitude * Math.cos(longitude);
        scratchN.y = cosLatitude * Math.sin(longitude);
        scratchN.z = Math.sin(latitude);
        scratchN = Cartesian3.normalize(scratchN, scratchN);
        
        Cartesian3.multiplyComponents(radiiSquared, scratchN, scratchK);
        var gamma = Math.sqrt(Cartesian3.dot(scratchN, scratchK));
        scratchK = Cartesian3.divideByScalar(scratchK, gamma, scratchK);
        scratchN = Cartesian3.multiplyByScalar(scratchN, height, scratchN);
        return Cartesian3.add(scratchK, scratchN, result);
    }

/**
* Returns an array of Cartesian3 positions given an array of longitude and latitude values given in degrees.
*
* @param {Number[]} coordinates A list of longitude and latitude values. Values alternate [longitude, latitude, longitude, latitude...].
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the coordinates lie.
* @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
* @returns {Cartesian3[]} The array of positions.
*
* @example
* var positions = Cartesian3.fromDegreesArray([-115.0, 37.0, -107.0, 33.0]);
*/
Cartesian3.fromDegreesArray = function(coordinates, ellipsoid, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(coordinates)) {
        throw new DeveloperError('positions is required.');
    }
    //>>includeEnd('debug');
    
    var pos = new Array(coordinates.length);
    for (var i = 0; i < coordinates.length; i++) {
        pos[i] = CesiumMath.toRadians(coordinates[i]);
    }
    
    return Cartesian3.fromRadiansArray(pos, ellipsoid, result);
};

/**
* Returns an array of Cartesian3 positions given an array of longitude and latitude values given in radians.
*
* @param {Number[]} coordinates A list of longitude and latitude values. Values alternate [longitude, latitude, longitude, latitude...].
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the coordinates lie.
* @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
* @returns {Cartesian3[]} The array of positions.
*
* @example
* var positions = Cartesian3.fromRadiansArray([-2.007, 0.645, -1.867, .575]);
*/
Cartesian3.fromRadiansArray = function(coordinates, ellipsoid, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(coordinates)) {
        throw new DeveloperError('positions is required.');
    }
    if (coordinates.length < 2) {
        throw new DeveloperError('positions length cannot be less than 2.');
    }
    if (coordinates.length % 2 !== 0) {
        throw new DeveloperError('positions length must be a multiple of 2.');
    }
    //>>includeEnd('debug');
    
    var length = coordinates.length;
    if (!defined(result)) {
        result = new Array(length/2);
    } else {
        result.length = length/2;
    }
    
    for ( var i = 0; i < length; i+=2) {
        var lon = coordinates[i];
        var lat = coordinates[i+1];
        result[i/2] = Cartesian3.fromRadians(lon, lat, 0, ellipsoid, result[i/2]);
    }
    
    return result;
};

/**
* Returns an array of Cartesian3 positions given an array of longitude, latitude and height values where longitude and latitude are given in degrees.
*
* @param {Number[]} coordinates A list of longitude, latitude and height values. Values alternate [longitude, latitude, height,, longitude, latitude, height...].
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
* @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
* @returns {Cartesian3[]} The array of positions.
*
* @example
* var positions = Cartesian3.fromDegreesArrayHeights([-115.0, 37.0, 100000.0, -107.0, 33.0, 150000.0]);
*/
Cartesian3.fromDegreesArrayHeights = function(coordinates, ellipsoid, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(coordinates)) {
        throw new DeveloperError('positions is required.');
    }
    if (coordinates.length < 3) {
        throw new DeveloperError('positions length cannot be less than 3.');
    }
    if (coordinates.length % 3 !== 0) {
        throw new DeveloperError('positions length must be a multiple of 3.');
    }
    //>>includeEnd('debug');
    
    var pos = new Array(coordinates.length);
    for (var i = 0; i < coordinates.length; i+=3) {
        pos[i] = CesiumMath.toRadians(coordinates[i]);
        pos[i+1] = CesiumMath.toRadians(coordinates[i+1]);
        pos[i+2] = coordinates[i+2];
    }
    
    return Cartesian3.fromRadiansArrayHeights(pos, ellipsoid, result);
};

/**
* Returns an array of Cartesian3 positions given an array of longitude, latitude and height values where longitude and latitude are given in radians.
*
* @param {Number[]} coordinates A list of longitude, latitude and height values. Values alternate [longitude, latitude, height,, longitude, latitude, height...].
* @param {Ellipsoid} [ellipsoid=Ellipsoid.WGS84] The ellipsoid on which the position lies.
* @param {Cartesian3[]} [result] An array of Cartesian3 objects to store the result.
* @returns {Cartesian3[]} The array of positions.
*
* @example
* var positions = Cartesian3.fromradiansArrayHeights([-2.007, 0.645, 100000.0, -1.867, .575, 150000.0]);
*/
Cartesian3.fromRadiansArrayHeights = function(coordinates, ellipsoid, result) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(coordinates)) {
        throw new DeveloperError('positions is required.');
    }
    if (coordinates.length < 3) {
        throw new DeveloperError('positions length cannot be less than 3.');
    }
    if (coordinates.length % 3 !== 0) {
        throw new DeveloperError('positions length must be a multiple of 3.');
    }
    //>>includeEnd('debug');
    
    var length = coordinates.length;
    if (!defined(result)) {
        result = new Array(length/3);
    } else {
        result.length = length/3;
    }
    
    for ( var i = 0; i < length; i+=3) {
        var lon = coordinates[i];
        var lat = coordinates[i+1];
        var alt = coordinates[i+2];
        result[i/3] = Cartesian3.fromRadians(lon, lat, alt, ellipsoid, result[i/3]);
    }
    
    return result;
};
*/
    /**
    * An immutable Cartesian3 instance initialized to (0.0, 0.0, 0.0).
    *
    * @type {Cartesian3}
    * @constant
    */
    
    static func zero() -> Cartesian3 {
        return Cartesian3(x: 0.0, y: 0.0, z: 0.0)
    }
/*
/**
* An immutable Cartesian3 instance initialized to (1.0, 0.0, 0.0).
*
* @type {Cartesian3}
* @constant
*/
Cartesian3.UNIT_X = freezeObject(new Cartesian3(1.0, 0.0, 0.0));

/**
* An immutable Cartesian3 instance initialized to (0.0, 1.0, 0.0).
*
* @type {Cartesian3}
* @constant
*/
Cartesian3.UNIT_Y = freezeObject(new Cartesian3(0.0, 1.0, 0.0));

/**
* An immutable Cartesian3 instance initialized to (0.0, 0.0, 1.0).
*
* @type {Cartesian3}
* @constant
*/
Cartesian3.UNIT_Z = freezeObject(new Cartesian3(0.0, 0.0, 1.0));

/**
* Duplicates this Cartesian3 instance.
*
* @param {Cartesian3} [result] The object onto which to store the result.
* @returns {Cartesian3} The modified result parameter or a new Cartesian3 instance if one was not provided.
*/
Cartesian3.prototype.clone = function(result) {
    return Cartesian3.clone(this, result);
};

/**
* Compares this Cartesian against the provided Cartesian componentwise and returns
* <code>true</code> if they are equal, <code>false</code> otherwise.
*
* @param {Cartesian3} [right] The right hand side Cartesian.
* @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
*/
Cartesian3.prototype.equals = function(right) {
    return Cartesian3.equals(this, right);
};

/**
* Compares this Cartesian against the provided Cartesian componentwise and returns
* <code>true</code> if they are within the provided epsilon,
* <code>false</code> otherwise.
*
* @param {Cartesian3} [right] The right hand side Cartesian.
* @param {Number} epsilon The epsilon to use for equality testing.
* @returns {Boolean} <code>true</code> if they are within the provided epsilon, <code>false</code> otherwise.
*/
Cartesian3.prototype.equalsEpsilon = function(right, epsilon) {
    return Cartesian3.equalsEpsilon(this, right, epsilon);
};
*/
    /**
    * Creates a string representing this Cartesian in the format '(x, y, z)'.
    *
    * @returns {String} A string representing this Cartesian in the format '(x, y, z)'.
    */
    func toString() -> String {
        return "(\(x)), (\(y)), (\(z))"
    }

}

