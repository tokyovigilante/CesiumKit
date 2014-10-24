//
//  EllipsoidalOccluderTests.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 19/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import XCTest

class EllipsoidalOccluderTests: XCTestCase {
    
    var ellipsoid: Ellipsoid!
    var occluder: EllipsoidalOccluder!
    
    override func setUp() {
        ellipsoid = Ellipsoid(x: 2.0, y: 3.0, z: 4.0)
        occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
    }
    
    func testisPointVisibleExample () {
        var cameraPosition = Cartesian3(x: 0, y: 0, z: 2.5)
        var ellipsoid = Ellipsoid(x: 1.0, y: 1.1, z: 0.9)
        var occluder = EllipsoidalOccluder(ellipsoid: ellipsoid, cameraPosition: cameraPosition)
        var point = Cartesian3(x: 0, y: -3, z: -3)
        XCTAssert(occluder.isPointVisible(point) == true, "isPointVisible example works as claimed")
    }
    
    func testisScaledSpacePointVisibleExample () {
        var cameraPosition = Cartesian3(x: 0, y: 0, z: 2.5)
        var ellipsoid = Ellipsoid(x: 1.0, y: 1.1, z: 0.9)
        var occluder = EllipsoidalOccluder(ellipsoid: ellipsoid, cameraPosition: cameraPosition)
        var point = Cartesian3(x: 0, y: -3, z: -3)
        var scaledSpacePoint = ellipsoid.transformPositionToScaledSpace(point)
        XCTAssert(occluder.isScaledSpacePointVisible(scaledSpacePoint) == true, "isScaledSpacePointVisible example works as claimed")
    }
    
    func testReportsNotVisibleWhenPointDirectlyBehind () {
        var ellipsoid = Ellipsoid.wgs84()
        var occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        occluder.cameraPosition = Cartesian3(x: 7000000.0, y: 0.0, z: 0.0)
        
        var point = Cartesian3(x: -7000000, y: 0.0, z: 0.0)
        XCTAssert(occluder.isPointVisible(point) == false, "reports not visible when point is directly behind ellipsoid")
    }
    
    func testReportsVisibleWhenPointDirectlyInFront () {
        var ellipsoid = Ellipsoid.wgs84()
        var occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        occluder.cameraPosition = Cartesian3(x: 7000000.0, y: 0.0, z: 0.0)
        
        var point = Cartesian3(x: 6900000.0, y: 0.0, z: 0.0)
        XCTAssert(occluder.isPointVisible(point) == true, "reports visible when point is in front of ellipsoid")
    }
    
    func testReportsVisibleWhenPointOppositeDirection () {
        var ellipsoid = Ellipsoid.wgs84()
        var occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        occluder.cameraPosition = Cartesian3(x: 7000000.0, y: 0.0, z: 0.0)
        
        var point = Cartesian3(x: 7100000.0, y: 0.0, z: 0.0)
        XCTAssertTrue(occluder.isPointVisible(point), "reports visible when point is in opposite direction from ellipsoid")
    }
    
    func testReportsNotVisibleWhenPointOverHorizon () {
        var ellipsoid = Ellipsoid.wgs84()
        var occluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        occluder.cameraPosition = Cartesian3(x: 7000000.0, y: 0.0, z: 0.0)
        
        var point = Cartesian3(x: 4510635.0, y: 4510635.0, z: 0.0);
        XCTAssert(occluder.isPointVisible(point) == false, "reports not visible when point is over horizon")
        }
    
    func testcomputeHorizonCullingPointReturnsPointOnEllipsoidWhenSinglePositionOnCenterLine () {
        var ellipsoid = Ellipsoid(x: 12345.0, y: 4567.0, z: 8910.0)
        var ellipsoidalOccluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        var positions = [Cartesian3(x: 12345.0, y: 0.0, z: 0.0)]
        var directionToPoint = Cartesian3(x: 1.0, y: 0.0, z: 0.0)
        
        var result: Cartesian3? = ellipsoidalOccluder.computeHorizonCullingPoint(directionToPoint, positions: positions)
        XCTAssert(result != nil, "returns point on ellipsoid when single position is on center line")
        XCTAssert(Math.equalsEpsilon(result!.x, 1.0, epsilon: Math.Epsilon14), "returns point on ellipsoid when single position is on center line")
        XCTAssert(Math.equalsEpsilon(result!.y, 0.0, epsilon: Math.Epsilon14), "returns point on ellipsoid when single position is on center line")
        XCTAssert(Math.equalsEpsilon(result!.z, 0.0, epsilon: Math.Epsilon14), "returns point on ellipsoid when single position is on center line")
    }
    
    func testReturnsUndefinedWhenHorizonOfSinglePointIsParallelToCenterLine () {
        var ellipsoid = Ellipsoid(x: 12345.0, y: 4567.0, z: 8910.0)
        var ellipsoidalOccluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        var positions = [Cartesian3(x: 0.0, y: 4567.0, z: 0.0)]
        var directionToPoint = Cartesian3(x: 1.0, y: 0.0, z: 0.0)
        
        var result = ellipsoidalOccluder.computeHorizonCullingPoint(directionToPoint, positions: positions)
        XCTAssert(result == nil, "returns undefined when horizon of single point is parallel to center line")
    }

    func testReturnsUndefinedWhenSinglePointIsInOppositeDirectionOfCenterLine () {
        var ellipsoid = Ellipsoid(x: 12345.0, y: 4567.0, z: 8910.0)
        var ellipsoidalOccluder = EllipsoidalOccluder(ellipsoid: ellipsoid)
        var positions = [Cartesian3(x: -14000.0, y: -1000.0, z: 0.0)]
        var directionToPoint = Cartesian3(x: 1.0, y: 0.0, z: 0.0)
        XCTAssertTrue(ellipsoidalOccluder.computeHorizonCullingPoint(directionToPoint, positions: positions) == nil, "returns undefined when single point is in the opposite direction of the center line")
    }
}
/*


                
                it('computes a point from a single position with a grazing altitude close to zero', function() {
                    var ellipsoid = new Ellipsoid(12345.0, 12345.0, 12345.0);
                    var ellipsoidalOccluder = new EllipsoidalOccluder(ellipsoid);
                    
                    var positions = [new Cartesian3(-12345.0, 12345.0, 12345.0), new Cartesian3(-12346.0, 12345.0, 12345.0)];
                    var boundingSphere = BoundingSphere.fromPoints(positions);
                    
                    var firstPositionArray = [positions[0]];
                    var result = ellipsoidalOccluder.computeHorizonCullingPoint(boundingSphere.center, firstPositionArray);
                    var unscaledResult = Cartesian3.multiplyComponents(result, ellipsoid.radii, new Cartesian3());
                    
                    // The grazing altitude of the ray from the horizon culling point to the
                    // position used to compute it should be very nearly zero.
                    var direction = Cartesian3.normalize(Cartesian3.subtract(positions[0], unscaledResult, new Cartesian3()), new Cartesian3());
                    var nearest = IntersectionTests.grazingAltitudeLocation(new Ray(unscaledResult, direction), ellipsoid);
                    var nearestCartographic = ellipsoid.cartesianToCartographic(nearest);
                    expect(nearestCartographic.height).toEqualEpsilon(0.0, CesiumMath.EPSILON5);
                    });
                
                it('computes a point from multiple positions with a grazing altitude close to zero for one of the positions and less than zero for the others', function() {
                    var ellipsoid = new Ellipsoid(12345.0, 12345.0, 12345.0);
                    var ellipsoidalOccluder = new EllipsoidalOccluder(ellipsoid);
                    
                    var positions = [new Cartesian3(-12345.0, 12345.0, 12345.0), new Cartesian3(-12346.0, 12345.0, 12345.0), new Cartesian3(-12446.0, 12445.0, 12445.0)];
                    var boundingSphere = BoundingSphere.fromPoints(positions);
                    
                    var result = ellipsoidalOccluder.computeHorizonCullingPoint(boundingSphere.center, positions);
                    var unscaledResult = Cartesian3.multiplyComponents(result, ellipsoid.radii, new Cartesian3());
                    
                    // The grazing altitude of the ray from the horizon culling point to the
                    // position used to compute it should be very nearly zero.
                    var foundOneNearZero = false;
                    for (var i = 0; i < positions.length; ++i) {
                        var direction = Cartesian3.normalize(Cartesian3.subtract(positions[i], unscaledResult, new Cartesian3()), new Cartesian3());
                        var nearest = IntersectionTests.grazingAltitudeLocation(new Ray(unscaledResult, direction), ellipsoid);
                        var nearestCartographic = ellipsoid.cartesianToCartographic(nearest);
                        if (Math.abs(nearestCartographic.height) < CesiumMath.EPSILON5) {
                            foundOneNearZero = true;
                        } else {
                            expect(nearestCartographic.height).toBeLessThan(0.0);
                        }
                    }
                    
                    expect(foundOneNearZero).toBe(true);
                    });
                });
            
            describe('computeHorizonCullingPointFromVertices', function() {
                it('requires directionToPoint, vertices, and stride', function() {
                    var ellipsoid = new Ellipsoid(12345.0, 12345.0, 12345.0);
                    var ellipsoidalOccluder = new EllipsoidalOccluder(ellipsoid);
                    
                    var positions = [new Cartesian3(-12345.0, 12345.0, 12345.0), new Cartesian3(-12346.0, 12345.0, 12345.0), new Cartesian3(-12446.0, 12445.0, 12445.0)];
                    var boundingSphere = BoundingSphere.fromPoints(positions);
                    
                    var vertices = [];
                    for (var i = 0; i < positions.length; ++i) {
                        var position = positions[i];
                        vertices.push(position.x);
                        vertices.push(position.y);
                        vertices.push(position.z);
                        vertices.push(1.0);
                        vertices.push(2.0);
                        vertices.push(3.0);
                        vertices.push(4.0);
                    }
                    
                    ellipsoidalOccluder.computeHorizonCullingPointFromVertices(boundingSphere.center, vertices, 7);
                    
                    expect(function() {
                        ellipsoidalOccluder.computeHorizonCullingPointFromVertices(undefined, vertices, 7);
                        }).toThrowDeveloperError();
                    
                    expect(function() {
                        ellipsoidalOccluder.computeHorizonCullingPointFromVertices(boundingSphere.center, undefined, 7);
                        }).toThrowDeveloperError();
                    
                    expect(function() {
                        ellipsoidalOccluder.computeHorizonCullingPointFromVertices(boundingSphere.center, vertices, undefined);
                        }).toThrowDeveloperError();
                    });
                
                it('produces same answers as computeHorizonCullingPoint', function() {
                    var ellipsoid = new Ellipsoid(12345.0, 12345.0, 12345.0);
                    var ellipsoidalOccluder = new EllipsoidalOccluder(ellipsoid);
                    
                    var positions = [new Cartesian3(-12345.0, 12345.0, 12345.0), new Cartesian3(-12346.0, 12345.0, 12345.0), new Cartesian3(-12446.0, 12445.0, 12445.0)];
                    var boundingSphere = BoundingSphere.fromPoints(positions);
                    
                    var center = new Cartesian3(-12000.0, 12000.0, 12000.0);
                    
                    var vertices = [];
                    for (var i = 0; i < positions.length; ++i) {
                        var position = positions[i];
                        vertices.push(position.x - center.x);
                        vertices.push(position.y - center.y);
                        vertices.push(position.z - center.z);
                        vertices.push(1.0);
                        vertices.push(2.0);
                        vertices.push(3.0);
                        vertices.push(4.0);
                    }
                    
                    var result1 = ellipsoidalOccluder.computeHorizonCullingPoint(boundingSphere.center, positions);
                    var result2 = ellipsoidalOccluder.computeHorizonCullingPointFromVertices(boundingSphere.center, vertices, 7, center);
                    
                    expect(result1.x).toEqualEpsilon(result2.x, CesiumMath.EPSILON14);
                    expect(result1.y).toEqualEpsilon(result2.y, CesiumMath.EPSILON14);
                    expect(result1.z).toEqualEpsilon(result2.z, CesiumMath.EPSILON14);
                    });
                });
            
            describe('computeHorizonCullingPointFromRectangle', function() {
                it('returns undefined for global rectangle', function() {
                    var ellipsoid = new Ellipsoid(12345.0, 12345.0, 12345.0);
                    var ellipsoidalOccluder = new EllipsoidalOccluder(ellipsoid);
                    var rectangle = Rectangle.MAX_VALUE;
                    var result = ellipsoidalOccluder.computeHorizonCullingPointFromRectangle(rectangle, ellipsoid);
                    expect(result).toBeUndefined();
                    });
                
                it('computes a point with a grazing altitude close to zero for one of the rectangle corners and less than or equal to zero for the others', function() {
                    var ellipsoid = new Ellipsoid(12345.0, 12345.0, 12345.0);
                    var ellipsoidalOccluder = new EllipsoidalOccluder(ellipsoid);
                    
                    var rectangle = new Rectangle(0.1, 0.2, 0.3, 0.4);
                    var result = ellipsoidalOccluder.computeHorizonCullingPointFromRectangle(rectangle, ellipsoid);
                    expect(result).toBeDefined();
                    var unscaledResult = Cartesian3.multiplyComponents(result, ellipsoid.radii, new Cartesian3());
                    
                    // The grazing altitude of the ray from the horizon culling point to the
                    // position used to compute it should be very nearly zero.
                    var positions = [ellipsoid.cartographicToCartesian(Rectangle.southwest(rectangle)),
                        ellipsoid.cartographicToCartesian(Rectangle.southeast(rectangle)),
                        ellipsoid.cartographicToCartesian(Rectangle.northwest(rectangle)),
                        ellipsoid.cartographicToCartesian(Rectangle.northeast(rectangle))];
                    
                    var foundOneNearZero = false;
                    for (var i = 0; i < positions.length; ++i) {
                        var direction = Cartesian3.normalize(Cartesian3.subtract(positions[i], unscaledResult, new Cartesian3()), new Cartesian3());
                        var nearest = IntersectionTests.grazingAltitudeLocation(new Ray(unscaledResult, direction), ellipsoid);
                        var nearestCartographic = ellipsoid.cartesianToCartographic(nearest);
                        if (Math.abs(nearestCartographic.height) < CesiumMath.EPSILON5) {
                            foundOneNearZero = true;
                        } else {
                            expect(nearestCartographic.height).toBeLessThanOrEqualTo(0.0);
                        }
                    }
                    
                    expect(foundOneNearZero).toBe(true);
                    });
                });
    });
*/