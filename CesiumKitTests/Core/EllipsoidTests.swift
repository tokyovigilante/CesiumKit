//
//  EllipsoidTests.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import XCTest

class EllipsoidTests: XCTestCase {
    
    var radii = Cartesian3()
    var radiiSquared = Cartesian3()
    var radiiToTheFourth = Cartesian3()
    var oneOverRadii = Cartesian3()
    var oneOverRadiiSquared = Cartesian3()
    var minimumRadius: Double = 1.0
    var maximumRadius: Double = 1.0
    
    //All values computes using STK Components
    var spaceCartesian = Cartesian3()
    var spaceCartesianGeodeticSurfaceNormal = Cartesian3()
    
    var spaceCartographic = Cartographic()
    var spaceCartographicGeodeticSurfaceNormal = Cartesian3()
    
    var surfaceCartesian = Cartesian3()
    var surfaceCartographic = Cartographic()
    
    override func setUp() {
        radii = Cartesian3(x: 1.0, y: 2.0, z: 3.0)
        radiiSquared = radii.multiplyComponents(radii)
        radiiToTheFourth = radiiSquared.multiplyComponents(radiiSquared)
        oneOverRadii = Cartesian3(x: 1.0 / radii.x, y: 1.0 / radii.y, z: 1.0 / radii.z)
        oneOverRadiiSquared = Cartesian3(x: 1.0 / radiiSquared.x, y: 1.0 / radiiSquared.y, z: 1.0 / radiiSquared.z)
        
        spaceCartesian = Cartesian3(x: 4582719.8827300891, y: -4582719.8827300882, z: 1725510.4250797231)
        spaceCartesianGeodeticSurfaceNormal = Cartesian3(x: 0.6829975339864266, y: -0.68299753398642649, z: 0.25889908678270795);
        
        spaceCartographic = Cartographic(longitude: Math.toRadians(-45.0), latitude: Math.toRadians(15.0), height: 330000.0)
        spaceCartographicGeodeticSurfaceNormal = Cartesian3(x: 0.68301270189221941, y: -0.6830127018922193, z: 0.25881904510252074)
        
        surfaceCartesian = Cartesian3(x: 4094327.7921465295, y: 1909216.4044747739, z: 4487348.4088659193)
        surfaceCartographic = Cartographic(longitude: Math.toRadians(25.0), latitude: Math.toRadians(45.0), height: 0.0)
    }
    
    //func testisPointVisibleExample () {
/*global jasmine,describe,xdescribe,it,xit,expect,beforeEach,afterEach,beforeAll,afterAll,spyOn,runs,waits,waitsFor





it('default constructor creates zero Ellipsoid', function() {
var ellipsoid = new Ellipsoid();
expect(ellipsoid.radii).toEqual(Cartesian3.ZERO);
expect(ellipsoid.radiiSquared).toEqual(Cartesian3.ZERO);
expect(ellipsoid.radiiToTheFourth).toEqual(Cartesian3.ZERO);
expect(ellipsoid.oneOverRadii).toEqual(Cartesian3.ZERO);
expect(ellipsoid.oneOverRadiiSquared).toEqual(Cartesian3.ZERO);
expect(ellipsoid.minimumRadius).toEqual(0.0);
expect(ellipsoid.maximumRadius).toEqual(0.0);
});

it('fromCartesian3 creates zero Ellipsoid with no parameters', function() {
var ellipsoid = Ellipsoid.fromCartesian3();
expect(ellipsoid.radii).toEqual(Cartesian3.ZERO);
expect(ellipsoid.radiiSquared).toEqual(Cartesian3.ZERO);
expect(ellipsoid.radiiToTheFourth).toEqual(Cartesian3.ZERO);
expect(ellipsoid.oneOverRadii).toEqual(Cartesian3.ZERO);
expect(ellipsoid.oneOverRadiiSquared).toEqual(Cartesian3.ZERO);
expect(ellipsoid.minimumRadius).toEqual(0.0);
expect(ellipsoid.maximumRadius).toEqual(0.0);
});

it('constructor computes correct values', function() {
var ellipsoid = new Ellipsoid(radii.x, radii.y, radii.z);
expect(ellipsoid.radii).toEqual(radii);
expect(ellipsoid.radiiSquared).toEqual(radiiSquared);
expect(ellipsoid.radiiToTheFourth).toEqual(radiiToTheFourth);
expect(ellipsoid.oneOverRadii).toEqual(oneOverRadii);
expect(ellipsoid.oneOverRadiiSquared).toEqual(oneOverRadiiSquared);
expect(ellipsoid.minimumRadius).toEqual(minimumRadius);
expect(ellipsoid.maximumRadius).toEqual(maximumRadius);
});

it('fromCartesian3 computes correct values', function() {
var ellipsoid = Ellipsoid.fromCartesian3(radii);
expect(ellipsoid.radii).toEqual(radii);
expect(ellipsoid.radiiSquared).toEqual(radiiSquared);
expect(ellipsoid.radiiToTheFourth).toEqual(radiiToTheFourth);
expect(ellipsoid.oneOverRadii).toEqual(oneOverRadii);
expect(ellipsoid.oneOverRadiiSquared).toEqual(oneOverRadiiSquared);
expect(ellipsoid.minimumRadius).toEqual(minimumRadius);
expect(ellipsoid.maximumRadius).toEqual(maximumRadius);
});

it('geodeticSurfaceNormalCartographic works without a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.geodeticSurfaceNormalCartographic(spaceCartographic);
expect(returnedResult).toEqualEpsilon(spaceCartographicGeodeticSurfaceNormal, CesiumMath.EPSILON15);
});

it('geodeticSurfaceNormalCartographic works with a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var result = new Cartesian3();
var returnedResult = ellipsoid.geodeticSurfaceNormalCartographic(spaceCartographic, result);
expect(returnedResult).toBe(result);
expect(returnedResult).toEqualEpsilon(spaceCartographicGeodeticSurfaceNormal, CesiumMath.EPSILON15);
});

it('geodeticSurfaceNormal works without a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.geodeticSurfaceNormal(spaceCartesian);
expect(returnedResult).toEqualEpsilon(spaceCartesianGeodeticSurfaceNormal, CesiumMath.EPSILON15);
});

it('geodeticSurfaceNormal works with a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var result = new Cartesian3();
var returnedResult = ellipsoid.geodeticSurfaceNormal(spaceCartesian, result);
expect(returnedResult).toBe(result);
expect(returnedResult).toEqualEpsilon(spaceCartesianGeodeticSurfaceNormal, CesiumMath.EPSILON15);
});
*/
    func testCartographicToCartesianWithoutResultParameter () {
        let ellipsoid = Ellipsoid.wgs84()
        let returnedResult = ellipsoid.cartographicToCartesian(spaceCartographic)
        XCTAssertTrue(returnedResult.equalsEpsilon(spaceCartesian, epsilon: Math.Epsilon7), "cartographicToCartesian works without a result parameter")
    }
/*
it('cartographicToCartesian works with a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var result = new Cartesian3();
var returnedResult = ellipsoid.cartographicToCartesian(spaceCartographic, result);
expect(result).toBe(returnedResult);
expect(returnedResult).toEqualEpsilon(spaceCartesian, CesiumMath.EPSILON7);
});

it('cartographicArrayToCartesianArray works without a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.cartographicArrayToCartesianArray([spaceCartographic, surfaceCartographic]);
expect(returnedResult.length).toEqual(2);
expect(returnedResult[0]).toEqualEpsilon(spaceCartesian, CesiumMath.EPSILON7);
expect(returnedResult[1]).toEqualEpsilon(surfaceCartesian, CesiumMath.EPSILON7);
});

it('cartographicArrayToCartesianArray works with a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var resultCartesian = new Cartesian3();
var result = [resultCartesian];
var returnedResult = ellipsoid.cartographicArrayToCartesianArray([spaceCartographic, surfaceCartographic], result);
expect(result).toBe(returnedResult);
expect(result[0]).toBe(resultCartesian);
expect(returnedResult.length).toEqual(2);
expect(returnedResult[0]).toEqualEpsilon(spaceCartesian, CesiumMath.EPSILON7);
expect(returnedResult[1]).toEqualEpsilon(surfaceCartesian, CesiumMath.EPSILON7);
});

it('cartesianToCartographic works without a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.cartesianToCartographic(surfaceCartesian);
expect(returnedResult).toEqualEpsilon(surfaceCartographic, CesiumMath.EPSILON8);
});

it('cartesianToCartographic works with a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var result = new Cartographic();
var returnedResult = ellipsoid.cartesianToCartographic(surfaceCartesian, result);
expect(result).toBe(returnedResult);
expect(returnedResult).toEqualEpsilon(surfaceCartographic, CesiumMath.EPSILON8);
});

it('cartesianToCartographic works close to center', function() {
var expected = new Cartographic(9.999999999999999e-11, 1.0067394967422763e-20, -6378137.0);
var returnedResult = Ellipsoid.WGS84.cartesianToCartographic(new Cartesian3(1e-50, 1e-60, 1e-70));
expect(returnedResult).toEqual(expected);
});

it('cartesianToCartographic return undefined very close to center', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.cartesianToCartographic(new Cartesian3(1e-150, 1e-150, 1e-150));
expect(returnedResult).toBeUndefined();
});

it('cartesianToCartographic return undefined at center', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.cartesianToCartographic(Cartesian3.ZERO);
expect(returnedResult).toBeUndefined();
});

it('cartesianArrayToCartographicArray works without a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var returnedResult = ellipsoid.cartesianArrayToCartographicArray([spaceCartesian, surfaceCartesian]);
expect(returnedResult.length).toEqual(2);
expect(returnedResult[0]).toEqualEpsilon(spaceCartographic, CesiumMath.EPSILON7);
expect(returnedResult[1]).toEqualEpsilon(surfaceCartographic, CesiumMath.EPSILON7);
});

it('cartesianArrayToCartographicArray works with a result parameter', function() {
var ellipsoid = Ellipsoid.WGS84;
var resultCartographic = new Cartographic();
var result = [resultCartographic];
var returnedResult = ellipsoid.cartesianArrayToCartographicArray([spaceCartesian, surfaceCartesian], result);
expect(result).toBe(returnedResult);
expect(result.length).toEqual(2);
expect(result[0]).toBe(resultCartographic);
expect(result[0]).toEqualEpsilon(spaceCartographic, CesiumMath.EPSILON7);
expect(result[1]).toEqualEpsilon(surfaceCartographic, CesiumMath.EPSILON7);
});

it('scaleToGeodeticSurface scaled in the x direction', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(1.0, 0.0, 0.0);
var cartesian = new Cartesian3(9.0, 0.0, 0.0);
var returnedResult = ellipsoid.scaleToGeodeticSurface(cartesian);
expect(returnedResult).toEqual(expected);
});

it('scaleToGeodeticSurface scaled in the y direction', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.0, 2.0, 0.0);
var cartesian = new Cartesian3(0.0, 8.0, 0.0);
var returnedResult = ellipsoid.scaleToGeodeticSurface(cartesian);
expect(returnedResult).toEqual(expected);
});

it('scaleToGeodeticSurface scaled in the z direction', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.0, 0.0, 3.0);
var cartesian = new Cartesian3(0.0, 0.0, 8.0);
var returnedResult = ellipsoid.scaleToGeodeticSurface(cartesian);
expect(returnedResult).toEqual(expected);
});

it('scaleToGeodeticSurface works without a result parameter', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.2680893773941855, 1.1160466902266495, 2.3559801120411263);
var cartesian = new Cartesian3(4.0, 5.0, 6.0);
var returnedResult = ellipsoid.scaleToGeodeticSurface(cartesian);
expect(returnedResult).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('scaleToGeodeticSurface works with a result parameter', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.2680893773941855, 1.1160466902266495, 2.3559801120411263);
var cartesian = new Cartesian3(4.0, 5.0, 6.0);
var result = new Cartesian3();
var returnedResult = ellipsoid.scaleToGeodeticSurface(cartesian, result);
expect(returnedResult).toBe(result);
expect(result).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('scaleToGeocentricSurface scaled in the x direction', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(1.0, 0.0, 0.0);
var cartesian = new Cartesian3(9.0, 0.0, 0.0);
var returnedResult = ellipsoid.scaleToGeocentricSurface(cartesian);
expect(returnedResult).toEqual(expected);
});

it('scaleToGeocentricSurface scaled in the y direction', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.0, 2.0, 0.0);
var cartesian = new Cartesian3(0.0, 8.0, 0.0);
var returnedResult = ellipsoid.scaleToGeocentricSurface(cartesian);
expect(returnedResult).toEqual(expected);
});

it('scaleToGeocentricSurface scaled in the z direction', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.0, 0.0, 3.0);
var cartesian = new Cartesian3(0.0, 0.0, 8.0);
var returnedResult = ellipsoid.scaleToGeocentricSurface(cartesian);
expect(returnedResult).toEqual(expected);
});

it('scaleToGeocentricSurface works without a result parameter', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.7807200583588266, 0.9759000729485333, 1.1710800875382399);
var cartesian = new Cartesian3(4.0, 5.0, 6.0);
var returnedResult = ellipsoid.scaleToGeocentricSurface(cartesian);
expect(returnedResult).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('scaleToGeocentricSurface works with a result parameter', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var expected = new Cartesian3(0.7807200583588266, 0.9759000729485333, 1.1710800875382399);
var cartesian = new Cartesian3(4.0, 5.0, 6.0);
var result = new Cartesian3();
var returnedResult = ellipsoid.scaleToGeocentricSurface(cartesian, result);
expect(returnedResult).toBe(result);
expect(result).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('scaleToGeodeticSurface returns undefined at center', function() {
var ellipsoid = new Ellipsoid(1.0, 2.0, 3.0);
var cartesian = new Cartesian3(0.0, 0.0, 0.0);
var returnedResult = ellipsoid.scaleToGeodeticSurface(cartesian);
expect(returnedResult).toBeUndefined();
});

it('transformPositionToScaledSpace works without a result parameter', function() {
var ellipsoid = new Ellipsoid(2.0, 3.0, 4.0);
var expected = new Cartesian3(2.0, 2.0, 2.0);
var cartesian = new Cartesian3(4.0, 6.0, 8.0);
var returnedResult = ellipsoid.transformPositionToScaledSpace(cartesian);
expect(returnedResult).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('transformPositionToScaledSpace works with a result parameter', function() {
var ellipsoid = new Ellipsoid(2.0, 3.0, 4.0);
var expected = new Cartesian3(3.0, 3.0, 3.0);
var cartesian = new Cartesian3(6.0, 9.0, 12.0);
var result = new Cartesian3();
var returnedResult = ellipsoid.transformPositionToScaledSpace(cartesian, result);
expect(returnedResult).toBe(result);
expect(result).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('transformPositionFromScaledSpace works without a result parameter', function() {
var ellipsoid = new Ellipsoid(2.0, 3.0, 4.0);
var expected = new Cartesian3(4.0, 6.0, 8.0);
var cartesian = new Cartesian3(2.0, 2.0, 2.0);
var returnedResult = ellipsoid.transformPositionFromScaledSpace(cartesian);
expect(returnedResult).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('transformPositionFromScaledSpace works with a result parameter', function() {
var ellipsoid = new Ellipsoid(2.0, 3.0, 4.0);
var expected = new Cartesian3(6.0, 9.0, 12.0);
var cartesian = new Cartesian3(3.0, 3.0, 3.0);
var result = new Cartesian3();
var returnedResult = ellipsoid.transformPositionFromScaledSpace(cartesian, result);
expect(returnedResult).toBe(result);
expect(result).toEqualEpsilon(expected, CesiumMath.EPSILON16);
});

it('equals works in all cases', function() {
var ellipsoid = new Ellipsoid(1.0, 0.0, 0.0);
expect(ellipsoid.equals(new Ellipsoid(1.0, 0.0, 0.0))).toEqual(true);
expect(ellipsoid.equals(new Ellipsoid(1.0, 1.0, 0.0))).toEqual(false);
expect(ellipsoid.equals(undefined)).toEqual(false);
});

it('toString produces expected values', function() {
var expected = "(1, 2, 3)";
var ellipsoid = new Ellipsoid(1, 2, 3);
expect(ellipsoid.toString()).toEqual(expected);
});

it('constructor throws if x less than 0', function() {
expect(function() {
return new Ellipsoid(-1, 0, 0);
}).toThrowDeveloperError();
});

it('constructor throws if y less than 0', function() {
expect(function() {
return new Ellipsoid(0, -1, 0);
}).toThrowDeveloperError();
});

it('constructor throws if z less than 0', function() {
expect(function() {
return new Ellipsoid(0, 0, -1);
}).toThrowDeveloperError();
});

it('expect Ellipsoid.geocentricSurfaceNormal is be Cartesian3.normalize', function() {
expect(Ellipsoid.WGS84.geocentricSurfaceNormal).toBe(Cartesian3.normalize);
});

it('geodeticSurfaceNormalCartographic throws with no cartographic', function() {
expect(function() {
Ellipsoid.WGS84.geodeticSurfaceNormalCartographic(undefined);
}).toThrowDeveloperError();
});

it('geodeticSurfaceNormal throws with no cartesian', function() {
expect(function() {
Ellipsoid.WGS84.geodeticSurfaceNormal(undefined);
}).toThrowDeveloperError();
});


it('cartographicArrayToCartesianArray throws with no cartographics', function() {
expect(function() {
Ellipsoid.WGS84.cartographicArrayToCartesianArray(undefined);
}).toThrowDeveloperError();
});

it('cartesianToCartographic throws with no cartesian', function() {
expect(function() {
Ellipsoid.WGS84.cartesianToCartographic(undefined);
}).toThrowDeveloperError();
});

it('cartesianArrayToCartographicArray throws with no cartesians', function() {
expect(function() {
Ellipsoid.WGS84.cartesianArrayToCartographicArray(undefined);
}).toThrowDeveloperError();
});

it('scaleToGeodeticSurface throws with no cartesian', function() {
expect(function() {
Ellipsoid.WGS84.scaleToGeodeticSurface(undefined);
}).toThrowDeveloperError();
});

it('scaleToGeocentricSurface throws with no cartesian', function() {
expect(function() {
Ellipsoid.WGS84.scaleToGeocentricSurface(undefined);
}).toThrowDeveloperError();
});

it('clone copies any object with the proper structure', function() {
var myEllipsoid = {
_radii : { x : 1.0, y : 2.0, z : 3.0 },
_radiiSquared : { x : 4.0, y : 5.0, z : 6.0 },
_radiiToTheFourth : { x: 7.0, y : 8.0, z : 9.0 },
_oneOverRadii : { x : 10.0, y : 11.0, z : 12.0 },
_oneOverRadiiSquared : { x : 13.0, y : 14.0, z : 15.0 },
_minimumRadius : 16.0,
_maximumRadius : 17.0,
_centerToleranceSquared : 18.0
};

var cloned = Ellipsoid.clone(myEllipsoid);
expect(cloned instanceof Ellipsoid).toBe(true);
expect(cloned).toEqual(myEllipsoid);
});

it('clone uses result parameter if provided', function() {
var myEllipsoid = {
_radii : { x : 1.0, y : 2.0, z : 3.0 },
_radiiSquared : { x : 4.0, y : 5.0, z : 6.0 },
_radiiToTheFourth : { x: 7.0, y : 8.0, z : 9.0 },
_oneOverRadii : { x : 10.0, y : 11.0, z : 12.0 },
_oneOverRadiiSquared : { x : 13.0, y : 14.0, z : 15.0 },
_minimumRadius : 16.0,
_maximumRadius : 17.0,
_centerToleranceSquared : 18.0
};

var result = new Ellipsoid();
var cloned = Ellipsoid.clone(myEllipsoid, result);
expect(cloned).toBe(result);
expect(cloned).toEqual(myEllipsoid);
);*/
}

