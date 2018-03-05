//
//  CameraTests.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 24/10/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import XCTest

class CameraTests: XCTestCase {

    var camera: Camera!
    var scene: (
    canvas: (clientWidth: Int, clientHeight: Int),
    drawingBufferWidth: Int,
    drawingBufferHeight: Int,
    mapProjection: Projection//,
    /* tweens = new TweenCollection();*/) = (
        canvas: (clientWidth: 512, clientHeight: 384),
        drawingBufferWidth: 1024,
        drawingBufferHeight: 768,
        mapProjection: GeographicProjection()//,
        /* tweens = new TweenCollection();*/
    )

    var position: Cartesian3!
    var up: Cartesian3!
    var dir: Cartesian3!
    var right: Cartesian3!

    var moveAmount = 3.0
    var turnAmount = .pi / 2
    var rotateAmount = .pi / 2
    var zoomAmount = 1.0

    override func setUp() {
        super.setUp()

        camera = Camera(fakeScene: scene)
        position = Cartesian3.unitZ()
        up = Cartesian3.unitY()
        dir = Cartesian3.unitZ().negate()
        right = dir.cross(up)

        camera.position = position
        camera.up = up
        camera.direction = dir
        camera.right = right

        //camera.minimumZoomDistance = 0.0
    }
/*
it('constructor throws an exception when there is no canvas', function() {
expect(function() {
return new Camera();
}).toThrowDeveloperError();
});*/

    func testGetViewMatrix () {
        let viewMatrix = camera.viewMatrix
        let position = camera.position
        let up = camera.up
        let dir = camera.direction
        let right = camera.right
        let rotation = Matrix4(
            right.x, right.y, right.z, 0.0,
            up.x,    up.y,    up.z, 0.0,
            -dir.x,  -dir.y,  -dir.z, 0.0,
            0.0,     0.0,     0.0, 1.0
        )
        let translation = Matrix4(
            1.0, 0.0, 0.0, -position.x,
            0.0, 1.0, 0.0, -position.y,
            0.0, 0.0, 1.0, -position.z,
            0.0, 0.0, 0.0,         1.0
        )
        var expected = rotation.multiply(translation)
        XCTAssertTrue(0.0 == -0.0, "signed zero")
        XCTAssertTrue(viewMatrix.equalsEpsilon(expected, epsilon: Math.Epsilon6), "get view matrix")
    }

    func testGetInverseViewMatrix () {
        var expected = camera.viewMatrix.inverse()
        XCTAssertTrue(expected.equalsEpsilon(camera.inverseViewMatrix, epsilon: Math.Epsilon15))
    }
    /*
it('get inverse view matrix', function() {
});

it('get inverse transform', function() {
camera.transform = new Matrix4(5.0, 0.0, 0.0, 1.0, 0.0, 5.0, 0.0, 2.0, 0.0, 0.0, 5.0, 3.0, 0.0, 0.0, 0.0, 1.0);
var expected = Matrix4.inverseTransformation(camera.transform, new Matrix4());
expect(expected).toEqual(camera.inverseTransform);
});

it('get heading is undefined when morphing', function() {
camera._mode = SceneMode.MORPHING;
expect(camera.heading).not.toBeDefined();
});

it('get heading in 2D', function() {
camera._mode = SceneMode.SCENE2D;

var heading = Math.atan2(camera.right.y, camera.right.x);
expect(camera.heading).toEqual(heading);
});

it('get heading in CV', function() {
camera._mode = SceneMode.COLUMBUS_VIEW;

var heading = Math.atan2(camera.right.y, camera.right.x);
expect(camera.heading).toEqual(heading);
});

it('get heading in 3D', function() {
camera._mode = SceneMode.SCENE3D;

var ellipsoid = Ellipsoid.WGS84;
var toFixedFrame = Transforms.eastNorthUpToFixedFrame(camera.position, ellipsoid);
var transform = Matrix4.getRotation(toFixedFrame, new Matrix3());
Matrix3.transpose(transform, transform);

var right = Matrix3.multiplyByVector(transform, camera.right, new Cartesian3());
var heading = Math.atan2(right.y, right.x);

expect(camera.heading).toEqual(heading);
});

it('set heading throws without angle', function() {
expect(function() {
camera.heading = undefined;
}).toThrowDeveloperError();
});

it('set heading in 2D', function() {
camera._mode = SceneMode.SCENE2D;

var heading = camera.heading;
var newHeading = CesiumMath.toRadians(45.0);
camera.heading = newHeading;

expect(camera.heading).not.toEqual(heading);
expect(camera.heading).toEqualEpsilon(newHeading, CesiumMath.EPSILON14);
});

it('set heading in CV', function() {
camera._mode = SceneMode.COLUMBUS_VIEW;

var heading = camera.heading;
var newHeading = CesiumMath.toRadians(45.0);
camera.heading = newHeading;

expect(camera.heading).not.toEqual(heading);
expect(camera.heading).toEqualEpsilon(newHeading, CesiumMath.EPSILON14);
});

it('set heading in 3D', function() {
camera._mode = SceneMode.SCENE3D;

camera.position = Cartesian3.clone(Cartesian3.UNIT_X);
camera.direction = Cartesian3.negate(Cartesian3.UNIT_X, new Cartesian3());
camera.up = Cartesian3.clone(Cartesian3.UNIT_Z);
camera.right = Cartesian3.cross(camera.direction, camera.up, new Cartesian3());

var heading = camera.heading;
var newHeading = CesiumMath.toRadians(45.0);
camera.heading = newHeading;

expect(camera.heading).not.toEqual(heading);
expect(camera.heading).toEqualEpsilon(newHeading, CesiumMath.EPSILON14);
});

it('tilt is undefined when mode is not 3D or Columbus view', function() {
camera._mode = SceneMode.MORPHING;
expect(camera.tilt).not.toBeDefined();
});

it('get tilt in CV', function() {
camera._mode = SceneMode.COLUMBUS_VIEW;

var tilt = CesiumMath.PI_OVER_TWO - Math.acos(-camera.direction.z);
expect(camera.tilt).toEqual(tilt);
});

it('get tilt in 3D', function() {
camera._mode = SceneMode.SCENE3D;

var direction = Cartesian3.normalize(camera.position, new Cartesian3());
Cartesian3.negate(direction, direction);
var tilt = CesiumMath.PI_OVER_TWO - Math.acos(Cartesian3.dot(camera.direction, direction));

expect(camera.tilt).toEqual(tilt);
});

it('set tilt throws without angle', function() {
expect(function() {
camera.tilt = undefined;
}).toThrowDeveloperError();
});

it('set tilt in CV', function() {
camera._mode = SceneMode.COLUMBUS_VIEW;

var tilt = camera.tilt;
var newTilt = CesiumMath.toRadians(45.0);
camera.tilt = newTilt;

expect(camera.tilt).not.toEqual(tilt);
expect(camera.tilt).toEqualEpsilon(newTilt, CesiumMath.EPSILON14);
});

it('set tilt in 3D', function() {
camera._mode = SceneMode.SCENE3D;

camera.position = Cartesian3.clone(Cartesian3.UNIT_X);
camera.direction = Cartesian3.negate(Cartesian3.UNIT_X, new Cartesian3());
camera.up = Cartesian3.clone(Cartesian3.UNIT_Z);
camera.right = Cartesian3.cross(camera.direction, camera.up, new Cartesian3());

var tilt = camera.tilt;
var newTilt = CesiumMath.toRadians(45.0);
camera.tilt = newTilt;

expect(camera.tilt).not.toEqual(tilt);
expect(camera.tilt).toEqualEpsilon(newTilt, CesiumMath.EPSILON14);
});

it('update throws without mode', function() {
expect(function() {
camera.update();
}).toThrowDeveloperError();
});

it('setTransform', function() {
var ellipsoid = Ellipsoid.WGS84;
var cartOrigin = Cartographic.fromDegrees(-75.59777, 40.03883);
var origin = ellipsoid.cartographicToCartesian(cartOrigin);
var transform = Transforms.eastNorthUpToFixedFrame(origin);

var height = 1000.0;
cartOrigin.height = height;

camera.position = ellipsoid.cartographicToCartesian(cartOrigin);
camera.direction = Cartesian3.negate(Cartesian3.fromCartesian4(Matrix4.getColumn(transform, 2, new Cartesian4())), new Cartesian3());
camera.up = Cartesian3.fromCartesian4(Matrix4.getColumn(transform, 1, new Cartesian4(), new Matrix4()));
camera.right = Cartesian3.fromCartesian4(Matrix4.getColumn(transform, 0, new Cartesian4()));

camera.setTransform(transform);

expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, 0.0, height), CesiumMath.EPSILON9);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Z, new Cartesian3()), CesiumMath.EPSILON9);
expect(camera.up).toEqualEpsilon(Cartesian3.UNIT_Y, CesiumMath.EPSILON9);
expect(camera.right).toEqualEpsilon(Cartesian3.UNIT_X, CesiumMath.EPSILON9);
});

it('worldToCameraCoordinates throws without cartesian', function() {
expect(function() {
camera.worldToCameraCoordinates();
}).toThrowDeveloperError();
});

it('worldToCameraCoordinates transforms to the cameras reference frame', function() {
camera.transform = new Matrix4(0.0, 0.0, 1.0, 0.0,
1.0, 0.0, 0.0, 0.0,
0.0, 1.0, 0.0, 0.0,
0.0, 0.0, 0.0, 1.0);
expect(camera.worldToCameraCoordinates(Cartesian4.UNIT_X)).toEqual(Cartesian4.UNIT_Z);
});

it('worldToCameraCoordinatesPoint throws without cartesian', function() {
expect(function() {
camera.worldToCameraCoordinatesPoint();
}).toThrowDeveloperError();
});

it('worldToCameraCoordinatesPoint transforms to the cameras reference frame', function() {
camera.transform = new Matrix4(0.0, 0.0, 1.0, 10.0,
1.0, 0.0, 0.0, 20.0,
0.0, 1.0, 0.0, 30.0,
0.0, 0.0, 0.0, 1.0);
var expected = Cartesian3.add(Matrix4.getColumn(camera.inverseTransform, 3, new Cartesian4()), Cartesian3.UNIT_Z, new Cartesian3());
expect(camera.worldToCameraCoordinatesPoint(Cartesian3.UNIT_X)).toEqual(expected);
});

it('worldToCameraCoordinatesVector throws without cartesian', function() {
expect(function() {
camera.worldToCameraCoordinatesVector();
}).toThrowDeveloperError();
});

it('worldToCameraCoordinatesVector transforms to the cameras reference frame', function() {
camera.transform = new Matrix4(0.0, 0.0, 1.0, 10.0,
1.0, 0.0, 0.0, 20.0,
0.0, 1.0, 0.0, 30.0,
0.0, 0.0, 0.0, 1.0);
expect(camera.worldToCameraCoordinatesVector(Cartesian3.UNIT_X)).toEqual(Cartesian3.UNIT_Z);
});

it('cameraToWorldCoordinates throws without cartesian', function() {
expect(function() {
camera.cameraToWorldCoordinates();
}).toThrowDeveloperError();
});

it('cameraToWorldCoordinates transforms from the cameras reference frame', function() {
camera.transform = new Matrix4(0.0, 0.0, 1.0, 0.0,
1.0, 0.0, 0.0, 0.0,
0.0, 1.0, 0.0, 0.0,
0.0, 0.0, 0.0, 1.0);
expect(camera.cameraToWorldCoordinates(Cartesian4.UNIT_Z)).toEqual(Cartesian4.UNIT_X);
});

it('cameraToWorldCoordinatesPoint throws without cartesian', function() {
expect(function() {
camera.cameraToWorldCoordinatesPoint();
}).toThrowDeveloperError();
});

it('cameraToWorldCoordinatesPoint transforms from the cameras reference frame', function() {
camera.transform = new Matrix4(0.0, 0.0, 1.0, 10.0,
1.0, 0.0, 0.0, 20.0,
0.0, 1.0, 0.0, 30.0,
0.0, 0.0, 0.0, 1.0);
var expected = Cartesian3.add(Cartesian3.UNIT_X, Matrix4.getColumn(camera.transform, 3, new Cartesian4()), new Cartesian3());
expect(camera.cameraToWorldCoordinatesPoint(Cartesian3.UNIT_Z)).toEqual(expected);
});

it('cameraToWorldCoordinatesVector throws without cartesian', function() {
expect(function() {
camera.cameraToWorldCoordinatesVector();
}).toThrowDeveloperError();
});

it('cameraToWorldCoordinatesVector transforms from the cameras reference frame', function() {
camera.transform = new Matrix4(0.0, 0.0, 1.0, 10.0,
1.0, 0.0, 0.0, 20.0,
0.0, 1.0, 0.0, 30.0,
0.0, 0.0, 0.0, 1.0);
expect(camera.cameraToWorldCoordinatesVector(Cartesian3.UNIT_Z)).toEqual(Cartesian3.UNIT_X);
});

it('move throws without an axis', function() {
expect(function() {
expect(camera.move());
}).toThrowDeveloperError();
});

it('moves', function() {
var direction = Cartesian3.normalize(new Cartesian3(1.0, 1.0, 0.0), new Cartesian3());
camera.move(direction, moveAmount);
expect(camera.position).toEqualEpsilon(new Cartesian3(direction.x * moveAmount, direction.y * moveAmount, 1.0), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('moves up', function() {
camera.moveUp(moveAmount);
expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, moveAmount, 1.0), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('moves down', function() {
camera.moveDown(moveAmount);
expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, -moveAmount, 1.0), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('moves right', function() {
camera.moveRight(moveAmount);
expect(camera.position).toEqual(new Cartesian3(moveAmount, 0.0, 1.0), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('moves left', function() {
camera.moveLeft(moveAmount);
expect(camera.position).toEqual(new Cartesian3(-moveAmount, 0.0, 1.0), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('moves forward', function() {
camera.moveForward(moveAmount);
expect(camera.position).toEqual(new Cartesian3(0.0, 0.0, 1.0 - moveAmount), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('moves backward', function() {
camera.moveBackward(moveAmount);
expect(camera.position).toEqual(new Cartesian3(0.0, 0.0, 1.0 + moveAmount), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('move clamps position in 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

var max = scene.mapProjection.project(new Cartographic(Math.PI, CesiumMath.toRadians(85.05112878)));
var factor = 1000.0;
var dx = max.x * factor;
var dy = max.y * factor;

camera.moveUp(dy);
camera.moveRight(dx);
expect(camera.position.x).toBeLessThan(dx);
expect(camera.position.y).toBeLessThan(dy);

camera.moveDown(dy);
camera.moveLeft(dx);
expect(camera.position.x).toBeGreaterThan(-dx);
expect(camera.position.y).toBeGreaterThan(-dy);
});

it('look throws without an axis', function() {
expect(function() {
expect(camera.look());
}).toThrowDeveloperError();
});

it('looks', function() {
camera.look(Cartesian3.UNIT_X, CesiumMath.PI);
expect(camera.position).toEqual(position);
expect(camera.right).toEqual(right);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON10);
expect(camera.direction).toEqualEpsilon(Cartesian3.UNIT_Z, CesiumMath.EPSILON10);
});

it('looks left', function() {
camera.lookLeft(turnAmount);
expect(camera.position).toEqual(position);
expect(camera.up).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(right, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(dir, CesiumMath.EPSILON15);
});

it('looks right', function() {
camera.lookRight(turnAmount);
expect(camera.position).toEqual(position);
expect(camera.up).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON15);
});

it('looks up', function() {
camera.lookUp(turnAmount);
expect(camera.position).toEqual(position);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON15);
});

it('looks down', function() {
camera.lookDown(turnAmount);
expect(camera.position).toEqual(position);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(up, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.up).toEqualEpsilon(dir, CesiumMath.EPSILON15);
});

it('twists left', function() {
camera.twistLeft(CesiumMath.PI_OVER_TWO);
expect(camera.position).toEqual(position);
expect(camera.direction).toEqualEpsilon(dir, CesiumMath.EPSILON15);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(right, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(up, CesiumMath.EPSILON15);
});

it('twists right', function() {
camera.twistRight(CesiumMath.PI_OVER_TWO);
expect(camera.position).toEqual(position);
expect(camera.direction).toEqualEpsilon(dir, CesiumMath.EPSILON15);
expect(camera.up).toEqualEpsilon(right, CesiumMath.EPSILON14);
expect(camera.right).toEqualEpsilon(Cartesian3.negate(up, new Cartesian3()), CesiumMath.EPSILON15);
});

it('rotate throws without an axis', function() {
expect(function() {
expect(camera.rotate());
}).toThrowDeveloperError();
});

it('rotates up', function() {
camera.rotateUp(rotateAmount);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON15);
});

it('rotates up with constrained axis 0', function() {
camera.constrainedAxis = Cartesian3.UNIT_Y;
camera.rotateUp(rotateAmount);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON15);
});

it('rotates up with constrained axis 1', function() {
camera.up = Cartesian3.negate(dir, new Cartesian3());
camera.direction = right;
camera.right = Cartesian3.cross(camera.direction, camera.up, new Cartesian3());

camera.constrainedAxis = Cartesian3.UNIT_Y;
camera.rotateUp(rotateAmount);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON14);
expect(camera.direction).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(dir, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON15);
});

it('rotates down', function() {
camera.rotateDown(rotateAmount);
expect(camera.up).toEqualEpsilon(dir, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(up, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.UNIT_Y, CesiumMath.EPSILON15);
});

it('rotates down with constrained axis 0 ', function() {
camera.constrainedAxis = Cartesian3.UNIT_Y;
camera.rotateDown(rotateAmount);
expect(camera.up).toEqualEpsilon(dir, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(up, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.UNIT_Y, CesiumMath.EPSILON15);
});

it('rotates down with constrained axis 1', function() {
camera.up = Cartesian3.negate(dir, new Cartesian3());
camera.direction = right;
camera.right = Cartesian3.cross(camera.direction, camera.up, new Cartesian3());

camera.constrainedAxis = Cartesian3.UNIT_Y;
camera.rotateDown(rotateAmount);
expect(camera.up).toEqualEpsilon(Cartesian3.UNIT_Y, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.UNIT_Y, CesiumMath.EPSILON15);
});

it('rotates left', function() {
camera.rotateLeft(rotateAmount);
expect(camera.up).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(right, CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_X, new Cartesian3()), CesiumMath.EPSILON15);
});

it('rotates left with contrained axis', function() {
camera.constrainedAxis = Cartesian3.UNIT_Z;
camera.rotateLeft(rotateAmount);
expect(camera.up).toEqualEpsilon(Cartesian3.UNIT_X, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Z, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.UNIT_Z, CesiumMath.EPSILON15);
});

it('rotates right', function() {
camera.rotateRight(rotateAmount);
expect(camera.up).toEqualEpsilon(up, CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(right, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(dir, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.UNIT_X, CesiumMath.EPSILON15);
});

it('rotates right with contrained axis', function() {
camera.constrainedAxis = Cartesian3.UNIT_Z;
camera.rotateRight(rotateAmount);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_X, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Z, new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(Cartesian3.UNIT_Y, CesiumMath.EPSILON15);
expect(camera.position).toEqualEpsilon(Cartesian3.UNIT_Z, CesiumMath.EPSILON15);
});

it('rotates', function() {
var axis = Cartesian3.normalize(new Cartesian3(Math.cos(CesiumMath.PI_OVER_FOUR), Math.sin(CesiumMath.PI_OVER_FOUR), 0.0), new Cartesian3());
var angle = CesiumMath.PI_OVER_TWO;
camera.rotate(axis, angle);

expect(camera.position).toEqualEpsilon(new Cartesian3(-axis.x, axis.y, 0.0), CesiumMath.EPSILON15);
expect(camera.direction).toEqualEpsilon(Cartesian3.negate(Cartesian3.normalize(camera.position, new Cartesian3()), new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.right).toEqualEpsilon(Cartesian3.normalize(new Cartesian3(0.5, 0.5, axis.x), new Cartesian3()), CesiumMath.EPSILON15);
expect(camera.up).toEqualEpsilon(Cartesian3.cross(camera.right, camera.direction, new Cartesian3()), CesiumMath.EPSILON15);
});

it('rotate past constrained axis stops at constained axis', function() {
camera.constrainedAxis = Cartesian3.UNIT_Y;
camera.rotateUp(Math.PI);
expect(camera.up).toEqualEpsilon(Cartesian3.negate(dir, new Cartesian3()), CesiumMath.EPSILON4);
expect(camera.direction).toEqualEpsilon(up, CesiumMath.EPSILON4);
expect(camera.right).toEqualEpsilon(right, CesiumMath.EPSILON4);
expect(camera.position).toEqualEpsilon(Cartesian3.negate(Cartesian3.UNIT_Y, new Cartesian3()), CesiumMath.EPSILON4);
});

it('zooms out 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

camera.zoomOut(zoomAmount);
expect(camera.frustum.right).toEqualEpsilon(2.5, CesiumMath.EPSILON10);
expect(camera.frustum.left).toEqual(-2.5, CesiumMath.EPSILON10);
expect(camera.frustum.top).toEqual(1.25, CesiumMath.EPSILON10);
expect(camera.frustum.bottom).toEqual(-1.25, CesiumMath.EPSILON10);
});

it('zooms in 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

camera.zoomIn(zoomAmount);
expect(camera.frustum.right).toEqualEpsilon(1.5, CesiumMath.EPSILON10);
expect(camera.frustum.left).toEqual(-1.5, CesiumMath.EPSILON10);
expect(camera.frustum.top).toEqual(0.75, CesiumMath.EPSILON10);
expect(camera.frustum.bottom).toEqual(-0.75, CesiumMath.EPSILON10);
});

it('clamps zoom out in 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

var max = scene.mapProjection.project(new Cartographic(Math.PI, CesiumMath.toRadians(85.05112878)));
var factor = 1000.0;
var dx = max.x * factor;
var ratio = frustum.top / frustum.right;

camera.zoomOut(dx);
expect(frustum.right).toBeLessThan(dx);
expect(frustum.left).toBeGreaterThan(-dx);
expect(frustum.top).toEqual(frustum.right * ratio);
expect(frustum.bottom).toEqual(-frustum.top);
});

it('clamps zoom in in 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

var max = scene.mapProjection.project(new Cartographic(Math.PI, CesiumMath.toRadians(85.05112878)));
var factor = 1000.0;
var dx = max.x * factor;

camera.zoomIn(dx * 2.0);
expect(frustum.right).toEqual(1.0);
expect(frustum.left).toEqual(-1.0);
});

it('zooms in 3D', function() {
camera.zoomIn(zoomAmount);
expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, 0.0, 1.0 - zoomAmount), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('zooms out in 3D', function() {
camera.zoomOut(zoomAmount);
expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, 0.0, 1.0 + zoomAmount), CesiumMath.EPSILON10);
expect(camera.up).toEqual(up);
expect(camera.direction).toEqual(dir);
expect(camera.right).toEqual(right);
});

it('zooms in throws with undefined OrthogrphicFrustum properties 2D', function() {
camera._mode = SceneMode.SCENE2D;
camera.frustum = new OrthographicFrustum();
expect(function () {
camera.zoomIn(zoomAmount);
}).toThrowDeveloperError();
});

it('lookAt', function() {
var target = new Cartesian3(-1.0, -1.0, 0.0);
var position = Cartesian3.clone(Cartesian3.UNIT_X);
var up = Cartesian3.clone(Cartesian3.UNIT_Z);

var tempCamera = camera.clone();
tempCamera.lookAt(position, target, up);
expect(tempCamera.position).toEqual(position);
expect(tempCamera.direction).toEqual(Cartesian3.normalize(Cartesian3.subtract(target, position, new Cartesian3()), new Cartesian3()));
expect(tempCamera.up).toEqual(up);
expect(tempCamera.right).toEqual(Cartesian3.normalize(Cartesian3.cross(tempCamera.direction, up, new Cartesian3()), new Cartesian3()));

expect(1.0 - Cartesian3.magnitude(tempCamera.direction)).toBeLessThan(CesiumMath.EPSILON14);
expect(1.0 - Cartesian3.magnitude(tempCamera.up)).toBeLessThan(CesiumMath.EPSILON14);
expect(1.0 - Cartesian3.magnitude(tempCamera.right)).toBeLessThan(CesiumMath.EPSILON14);
});

it('lookAt throws with no eye parameter', function() {
var target = Cartesian3.clone(Cartesian3.ZERO);
var up = Cartesian3.clone(Cartesian3.ZERO);
var tempCamera = camera.clone();
expect(function() {
tempCamera.lookAt(undefined, target, up);
}).toThrowDeveloperError();
});

it('lookAt throws with no target parameter', function() {
var eye = Cartesian3.clone(Cartesian3.ZERO);
var up = Cartesian3.clone(Cartesian3.ZERO);
var tempCamera = camera.clone();
expect(function() {
tempCamera.lookAt(eye, undefined, up);
}).toThrowDeveloperError();
});

it('lookAt throws with no up parameter', function() {
var eye = Cartesian3.clone(Cartesian3.ZERO);
var target = Cartesian3.clone(Cartesian3.ZERO);
var tempCamera = camera.clone();
expect(function() {
tempCamera.lookAt(eye, target, undefined);
}).toThrowDeveloperError();
});

it('lookAt in 2D mode', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;

var target = new Cartesian3();
var position = new Cartesian3(10000.0, 10000.0, 30000.0);
var up = Cartesian3.clone(Cartesian3.UNIT_Z);

var tempCamera = camera.clone();
tempCamera.frustum = frustum;
tempCamera.update(SceneMode.SCENE2D);
tempCamera.lookAt(position, target, up);
expect(Cartesian2.clone(tempCamera.position)).toEqual(Cartesian2.clone(target));
expect(tempCamera.direction).toEqual(Cartesian3.negate(Cartesian3.UNIT_Z, new Cartesian3()));
expect(tempCamera.up).toEqual(Cartesian3.UNIT_Y);
expect(tempCamera.right).toEqual(Cartesian3.UNIT_X);
expect(tempCamera.frustum.right).toEqual(position.z);
expect(tempCamera.frustum.left).toEqual(-position.z);
});

it('lookAt throws when morphing', function() {
camera.update(SceneMode.MORPHING);

expect(function() {
camera.lookAt(Cartesian3.UNIT_X, Cartesian3.ZERO, Cartesian3.UNIT_Y);
}).toThrowDeveloperError();
});

it('viewRectangle throws without rectangle', function() {
expect(function () {
camera.viewRectangle();
}).toThrowDeveloperError();
});
*/
    func testViewsRectangleIn3D1 () {
        var rectangle = Rectangle(west: -M_PI, south: -.pi / 2, east: M_PI, north: .pi / 2)
        camera.viewRectangle(rectangle)
        XCTAssertTrue(camera.position.equalsEpsilon(Cartesian3(x: 14680290.639204923, y: 0.0, z: 0.0), epsilon: Math.Epsilon6), "position equality")
        XCTAssertTrue(camera.direction.equalsEpsilon(Cartesian3.unitX().negate(), epsilon: Math.Epsilon10), "direction equality")
        XCTAssertTrue(camera.up.equalsEpsilon(Cartesian3.unitZ(), epsilon: Math.Epsilon10), "up equality")
        XCTAssertTrue(camera.right.equalsEpsilon(Cartesian3.unitY(), epsilon: Math.Epsilon10), "right equality")
    }

    func testViewsRectangleIn3D2 () {
        let rectangle = Rectangle(
            west: Math.toRadians(21.25),
            south: Math.toRadians(41.23),
            east: Math.toRadians(21.51),
            north: Math.toRadians(41.38)
        )
        camera.viewRectangle(rectangle, ellipsoid: Ellipsoid.wgs84())
        XCTAssertTrue(camera.position.equalsEpsilon(Cartesian3(x: 4481581.054168208, y: 1754494.5938935655, z: 4200573.072090136), epsilon: Math.Epsilon6), "position equality")
        XCTAssertTrue(camera.direction.equalsEpsilon(Cartesian3(x: -0.7015530983057745, y: -0.2746510892984876, z: -0.6575637074875123), epsilon: Math.Epsilon10), "direction equality")
        XCTAssertTrue(camera.up.equalsEpsilon(Cartesian3(x: -0.6123128513437499, y: -0.23971441651266895, z: 0.7533989451779698), epsilon: Math.Epsilon10), "up equality")
        XCTAssertTrue(camera.right.equalsEpsilon(Cartesian3(x: -0.36454934142973716, y: 0.9311840729217532, z: 0.0), epsilon: Math.Epsilon10), "right equality")
    }

    func testViewsRectangleIn3D3 () {
        let rectangle = Rectangle(
            west: Math.toRadians(90.0),
            south: Math.toRadians(-50.0),
            east: Math.toRadians(157.0),
            north: Math.toRadians(0.0))
        camera.viewRectangle(rectangle, ellipsoid: Ellipsoid.wgs84())
        XCTAssertTrue(camera.position.equalsEpsilon(Cartesian3(x: -7210721.873278953, y: 8105929.1576369405, z: -5972336.199381728), epsilon: Math.Epsilon6), "position equality")
        XCTAssertTrue(camera.direction.equalsEpsilon(Cartesian3(x: 0.5822498554483325, y: -0.6545358652367963, z: 0.48225294913469874), epsilon: Math.Epsilon10), "direction equality")
        XCTAssertTrue(camera.up.equalsEpsilon(Cartesian3(x: -0.32052676705406324, y: 0.3603199946588929, z: 0.8760320159964963), epsilon: Math.Epsilon10), "up equality")
        XCTAssertTrue(camera.right.equalsEpsilon(Cartesian3(x: -0.7471597536218517, y: -0.6646444933705039, z: 0.0), epsilon: Math.Epsilon10), "right equality")
    }

    func testViewsRectangleIn3DAcrossIDL () {
        let rectangle = Rectangle(west: 0.1, south: -.pi / 2, east: -0.1, north: .pi / 2)
        camera.viewRectangle(rectangle)
        XCTAssertTrue(camera.position.equalsEpsilon(Cartesian3(x: -14680290.639204923, y: 0.0, z: 0.0), epsilon: Math.Epsilon6), "position equality")
        XCTAssertTrue(camera.direction.equalsEpsilon(Cartesian3.unitX(), epsilon: Math.Epsilon10), "direction equality")
        XCTAssertTrue(camera.up.equalsEpsilon(Cartesian3.unitZ(), epsilon: Math.Epsilon10), "up equality")
        XCTAssertTrue(camera.right.equalsEpsilon(Cartesian3.unitY().negate(), epsilon: Math.Epsilon10), "right equality")
    }
/*

it('views rectangle in 2D with larger longitude', function() {
var frustum = new OrthographicFrustum();
frustum.left = -10.0;
frustum.right = 10.0;
frustum.bottom = -10.0;
frustum.top = 10.0;
frustum.near = 1.0;
frustum.far = 21.0;
camera.frustum = frustum;

var rectangle = new Rectangle(
-CesiumMath.PI_OVER_TWO,
-CesiumMath.PI_OVER_FOUR,
CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_FOUR);
var projection = new GeographicProjection();
var edge = projection.project(new Cartographic(CesiumMath.PI_OVER_TWO, CesiumMath.PI_OVER_FOUR));
var expected = Math.max(edge.x, edge.y);

camera._mode = SceneMode.SCENE2D;
camera._projection = projection;
camera.viewRectangle(rectangle);

expect(camera.position.x).toEqual(0);
expect(camera.position.y).toEqual(0);
expect(frustum.right - expected <= CesiumMath.EPSILON14).toEqual(true);
expect(frustum.left + expected <= CesiumMath.EPSILON14).toEqual(true);
expect(frustum.top - expected <= CesiumMath.EPSILON14).toEqual(true);
expect(frustum.bottom + expected <= CesiumMath.EPSILON14).toEqual(true);
});

it('views rectangle in 2D with larger latitude', function() {
var frustum = new OrthographicFrustum();
frustum.left = -10.0;
frustum.right = 10.0;
frustum.bottom = -10.0;
frustum.top = 10.0;
frustum.near = 1.0;
frustum.far = 21.0;
camera.frustum = frustum;

var rectangle = new Rectangle(
-CesiumMath.PI_OVER_FOUR,
-CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_FOUR,
CesiumMath.PI_OVER_TWO);
var projection = new GeographicProjection();
var edge = projection.project(new Cartographic(CesiumMath.PI_OVER_FOUR, CesiumMath.PI_OVER_TWO));
var expected = Math.max(edge.x, edge.y);

camera._mode = SceneMode.SCENE2D;
camera._projection = projection;
camera.viewRectangle(rectangle);

expect(camera.position.x).toEqual(0);
expect(camera.position.y).toEqual(0);
expect(frustum.right - expected <= CesiumMath.EPSILON14).toEqual(true);
expect(frustum.left + expected <= CesiumMath.EPSILON14).toEqual(true);
expect(frustum.top - expected <= CesiumMath.EPSILON14).toEqual(true);
expect(frustum.bottom + expected <= CesiumMath.EPSILON14).toEqual(true);
});

it('views rectangle in Columbus View', function() {
var rectangle = new Rectangle(
-CesiumMath.PI_OVER_TWO,
-CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_TWO);
var projection = new GeographicProjection();
camera._mode = SceneMode.COLUMBUS_VIEW;
camera._projection = projection;
camera.viewRectangle(rectangle);
expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, 0.0, 23137321.67119748), CesiumMath.EPSILON8);
expect(camera.direction).toEqualEpsilon(new Cartesian3(0.0, 0.0, -1.0), CesiumMath.EPSILON2);
expect(camera.up).toEqualEpsilon(new Cartesian3(0.0, 1.0, 0.0), CesiumMath.EPSILON2);
expect(camera.right).toEqualEpsilon(new Cartesian3(1.0, 0.0, 0.0), CesiumMath.EPSILON10);
});

it('getRectangleCameraCoordinates throws without rectangle', function() {
expect(function () {
camera.getRectangleCameraCoordinates();
}).toThrowDeveloperError();
});

it('getRectangleCameraCoordinates rectangle in 3D', function() {
var rectangle = new Rectangle(
-Math.PI,
-CesiumMath.PI_OVER_TWO,
Math.PI,
CesiumMath.PI_OVER_TWO);
var position = Cartesian3.clone(camera.position);
var direction = Cartesian3.clone(camera.direction);
var up = Cartesian3.clone(camera.up);
var right = Cartesian3.clone(camera.right);
camera._mode = SceneMode.SCENE3D;
camera.getRectangleCameraCoordinates(rectangle, position);
expect(position).toEqualEpsilon(new Cartesian3(14680290.639204923, 0.0, 0.0), CesiumMath.EPSILON6);
expect(camera.direction).toEqual(direction);
expect(camera.up).toEqual(up);
expect(camera.right).toEqual(right);
});

it('gets coordinates for rectangle in 3D across IDL', function() {
var rectangle = new Rectangle(
0.1,
-CesiumMath.PI_OVER_TWO,
-0.1,
CesiumMath.PI_OVER_TWO);
var position = new Cartesian3();
var direction = Cartesian3.clone(camera.direction);
var up = Cartesian3.clone(camera.up);
var right = Cartesian3.clone(camera.right);
camera._mode = SceneMode.SCENE3D;
position = camera.getRectangleCameraCoordinates(rectangle);
expect(position).toEqualEpsilon(new Cartesian3(-14680290.639204923, 0.0, 0.0), CesiumMath.EPSILON6);
expect(camera.direction).toEqual(direction);
expect(camera.up).toEqual(up);
expect(camera.right).toEqual(right);
});

it('views rectangle in 2D with larger latitude', function() {
var rectangle = new Rectangle(
-CesiumMath.PI_OVER_FOUR,
-CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_FOUR,
CesiumMath.PI_OVER_TWO);
var projection = new GeographicProjection();
var cam = new Camera(scene);
var frustum = new OrthographicFrustum();
frustum.right = 1.0;
frustum.left = -1.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
frustum.near = 1.0;
frustum.far = 2.0;
cam.frustum = frustum;
var z = cam.position.z;

cam._mode = SceneMode.SCENE2D;
cam._projection = projection;
camera.position = cam.getRectangleCameraCoordinates(rectangle);

expect(camera.position.x).toEqual(0);
expect(camera.position.y).toEqual(0);
expect(camera.position.z).not.toEqual(z);

expect(cam.frustum.left).toEqual(-1.0);
expect(cam.frustum.far).toEqual(2.0);

});

it('gets coordinates for rectangle in Columbus View', function() {
var rectangle = new Rectangle(
-CesiumMath.PI_OVER_TWO,
-CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_TWO);
var projection = new GeographicProjection();
camera._mode = SceneMode.COLUMBUS_VIEW;
camera._projection = projection;
var direction = Cartesian3.clone(camera.direction);
var up = Cartesian3.clone(camera.up);
var right = Cartesian3.clone(camera.right);
camera.position = camera.getRectangleCameraCoordinates(rectangle);
expect(camera.position).toEqualEpsilon(new Cartesian3(0.0, 0.0, 23137321.67119748), CesiumMath.EPSILON8);
expect(camera.direction).toEqual(direction);
expect(camera.up).toEqual(up);
expect(camera.right).toEqual(right);
});


it('get rectangle coordinate returns camera position if scene mode is morphing', function() {
var rectangle = new Rectangle(
-CesiumMath.PI_OVER_TWO,
-CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_TWO,
CesiumMath.PI_OVER_TWO);
var projection = new GeographicProjection();
camera._mode = SceneMode.MORPHING;
camera._projection = projection;
var position = Cartesian3.clone(camera.position);
var direction = Cartesian3.clone(camera.direction);
var up = Cartesian3.clone(camera.up);
var right = Cartesian3.clone(camera.right);
camera.getRectangleCameraCoordinates(rectangle, camera.position);
expect(camera.position).toEqual(position);
expect(camera.direction).toEqual(direction);
expect(camera.up).toEqual(up);
expect(camera.right).toEqual(right);
});

it('pick ellipsoid thows without a position', function() {
expect(function() {
camera.pickEllipsoid();
}).toThrowDeveloperError();
});

it('pick ellipsoid', function() {
var ellipsoid = Ellipsoid.WGS84;
var maxRadii = ellipsoid.maximumRadius;

camera.position = Cartesian3.multiplyBy(scalar: Cartesian3.UNIT_X, 2.0 * maxRadii, new Cartesian3());
camera.direction = Cartesian3.normalize(Cartesian3.negate(camera.position, new Cartesian3()), new Cartesian3());
camera.up = Cartesian3.clone(Cartesian3.UNIT_Z);
camera.right = Cartesian3.cross(camera.direction, camera.up, new Cartesian3());

var frustum = new PerspectiveFrustum();
frustum.fov = CesiumMath.toRadians(60.0);
frustum.aspectRatio = scene.drawingBufferWidth / scene.drawingBufferHeight;
frustum.near = 100;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

var windowCoord = new Cartesian2(scene.canvas.clientWidth * 0.5, scene.canvas.clientHeight * 0.5);
var p = camera.pickEllipsoid(windowCoord, ellipsoid);
var c = ellipsoid.cartesianToCartographic(p);
expect(c).toEqual(new Cartographic(0.0, 0.0, 0.0));

p = camera.pickEllipsoid(Cartesian2.ZERO, ellipsoid);
expect(p).toBeUndefined();
});

it('pickEllipsoid works near the surface', function() {
var ellipsoid = Ellipsoid.WGS84;
var minRadii = ellipsoid.minimumRadius;

// Ten meters above the surface at the north pole, looking down.
camera.position = new Cartesian3(0.0, 0.0, minRadii + 10.0);
camera.direction = new Cartesian3(0.0, 0.0, -1.0);
camera.up = new Cartesian3(1.0, 0.0, 0.0);
camera.right = new Cartesian3(0.0, 1.0, 0.0);

var p = camera.pickEllipsoid(Cartesian2.ZERO, ellipsoid);
expect(p.z).toEqualEpsilon(minRadii, 1e-4);
});

it('pick map in 2D', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);
var maxRadii = ellipsoid.maximumRadius;

camera.position = new Cartesian3(0.0, 0.0, 2.0 * maxRadii);
camera.direction = Cartesian3.normalize(Cartesian3.negate(camera.position, new Cartesian3()), new Cartesian3());
camera.up = Cartesian3.clone(Cartesian3.UNIT_Y);

var frustum = new OrthographicFrustum();
frustum.right = maxRadii * Math.PI;
frustum.left = -frustum.right;
frustum.top = frustum.right * (scene.drawingBufferHeight / scene.drawingBufferWidth);
frustum.bottom = -frustum.top;
frustum.near = 0.01 * maxRadii;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

camera._mode = SceneMode.SCENE2D;
camera._projection = projection;

var windowCoord = new Cartesian2(scene.canvas.clientWidth * 0.5, scene.canvas.clientHeight * 0.5);
var p = camera.pickEllipsoid(windowCoord);
var c = ellipsoid.cartesianToCartographic(p);
expect(c).toEqual(new Cartographic(0.0, 0.0, 0.0));

p = camera.pickEllipsoid(Cartesian2.ZERO);
expect(p).toBeUndefined();
});

it('pick rotated map in 2D', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);
var maxRadii = ellipsoid.maximumRadius;

camera.position = new Cartesian3(0.0, 0.0, 2.0 * maxRadii);
camera.direction = Cartesian3.normalize(Cartesian3.negate(camera.position, new Cartesian3()), new Cartesian3());
camera.up = Cartesian3.clone(Cartesian3.UNIT_Y);

var frustum = new OrthographicFrustum();
frustum.right = maxRadii * Math.PI;
frustum.left = -frustum.right;
frustum.top = frustum.right * (scene.drawingBufferHeight / scene.drawingBufferWidth);
frustum.bottom = -frustum.top;
frustum.near = 0.01 * maxRadii;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

camera._mode = SceneMode.SCENE2D;
camera._projection = projection;

var windowCoord = new Cartesian2(scene.canvas.clientWidth * 0.5, scene.canvas.clientHeight * 0.5 + 1.0);
var p = camera.pickEllipsoid(windowCoord);
var c = ellipsoid.cartesianToCartographic(p);
expect(c.longitude).toEqual(0.0);
expect(c.latitude).toBeLessThan(0.0);

camera.up = Cartesian3.negate(Cartesian3.UNIT_X, new Cartesian3());
camera.right = Cartesian3.clone(Cartesian3.UNIT_Y);

p = camera.pickEllipsoid(windowCoord);
c = ellipsoid.cartesianToCartographic(p);
expect(c.latitude).toEqual(0.0);
expect(c.longitude).toBeGreaterThan(0.0);
});

it('pick map in columbus view', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);
var maxRadii = ellipsoid.maximumRadius;

camera.position = Cartesian3.multiplyBy(scalar: Cartesian3.normalize(new Cartesian3(0.0, -1.0, 1.0), new Cartesian3()), 5.0 * maxRadii, new Cartesian3());
camera.direction = Cartesian3.normalize(Cartesian3.subtract(Cartesian3.ZERO, camera.position, new Cartesian3()), new Cartesian3());
camera.right = Cartesian3.normalize(Cartesian3.cross(camera.direction, Cartesian3.UNIT_Z, new Cartesian3()), new Cartesian3());
camera.up = Cartesian3.cross(camera.right, camera.direction, new Cartesian3());

var frustum = new PerspectiveFrustum();
frustum.fov = CesiumMath.toRadians(60.0);
frustum.aspectRatio = scene.drawingBufferWidth / scene.drawingBufferHeight;
frustum.near = 0.01 * maxRadii;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

camera.update(SceneMode.COLUMBUS_VIEW);

var windowCoord = new Cartesian2(scene.canvas.clientWidth * 0.5, scene.canvas.clientHeight * 0.5);
var p = camera.pickEllipsoid(windowCoord);
var c = ellipsoid.cartesianToCartographic(p);
expect(c).toEqual(new Cartographic(0.0, 0.0, 0.0));

p = camera.pickEllipsoid(Cartesian2.ZERO);
expect(p).toBeUndefined();
});

it('pick map in morph', function() {
var ellipsoid = Ellipsoid.WGS84;
var maxRadii = ellipsoid.maximumRadius;

camera.position = Cartesian3.multiplyBy(scalar: Cartesian3.UNIT_X, 2.0 * maxRadii, new Cartesian3());
camera.direction = Cartesian3.normalize(Cartesian3.negate(camera.position, new Cartesian3()), new Cartesian3());
camera.up = Cartesian3.clone(Cartesian3.UNIT_Z);
camera.right = Cartesian3.cross(camera.direction, camera.up, new Cartesian3());

var frustum = new PerspectiveFrustum();
frustum.fov = CesiumMath.toRadians(60.0);
frustum.aspectRatio = scene.drawingBufferWidth / scene.drawingBufferHeight;
frustum.near = 100;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

camera.update(SceneMode.MORPHING);

var windowCoord = new Cartesian2(scene.canvas.clientWidth * 0.5, scene.canvas.clientHeight * 0.5);
var p = camera.pickEllipsoid(windowCoord);
expect(p).toBeUndefined();
});

it('set position cartographic throws without a cartographic', function() {
expect(function() {
camera.setPositionCartographic();
}).toThrowDeveloperError();
});

it('set position cartographic in 2D', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);
var maxRadii = ellipsoid.maximumRadius;

camera._mode = SceneMode.SCENE2D;
camera._projection = projection;

var frustum = new OrthographicFrustum();
frustum.right = maxRadii * Math.PI;
frustum.left = -frustum.right;
frustum.top = frustum.right * (scene.drawingBufferHeight / scene.drawingBufferWidth);
frustum.bottom = -frustum.top;
frustum.near = 0.01 * maxRadii;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

var ratio = frustum.top / frustum.right;
var cart = new Cartographic(-75.0, 42.0, 100.0);
camera.setPositionCartographic(cart);

expect(Cartesian2.fromCartesian3(camera.position, new Cartesian2())).toEqual(Cartesian2.fromCartesian3(projection.project(cart), new Cartesian2()));
expect(camera.direction).toEqual(Cartesian3.negate(Cartesian3.UNIT_Z, new Cartesian3()));
expect(camera.up).toEqual(Cartesian3.UNIT_Y);
expect(camera.right).toEqual(Cartesian3.UNIT_X);
expect(frustum.right - frustum.left).toEqual(cart.height);
expect(frustum.top / frustum.right).toEqual(ratio);
});

it('set position cartographic in Columbus View', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);

camera._mode = SceneMode.COLUMBUS_VIEW;
camera._projection = projection;

var cart = new Cartographic(-75.0, 42.0, 100.0);
camera.setPositionCartographic(cart);
expect(camera.position).toEqual(projection.project(cart));
expect(camera.direction).toEqual(Cartesian3.negate(Cartesian3.UNIT_Z, new Cartesian3()));
expect(camera.up).toEqual(Cartesian3.UNIT_Y);
expect(camera.right).toEqual(Cartesian3.UNIT_X);
});

it('set position cartographic in 3D', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);

camera._mode = SceneMode.SCENE3D;
camera._projection = projection;

var cart = new Cartographic(-75.0, 0.0, 100.0);
camera.setPositionCartographic(cart);

expect(camera.position).toEqual(ellipsoid.cartographicToCartesian(cart));
expect(camera.direction).toEqual(Cartesian3.normalize(Cartesian3.negate(camera.position, new Cartesian3()), new Cartesian3()));
expect(camera.up).toEqualEpsilon(Cartesian3.UNIT_Z, CesiumMath.EPSILON15);
expect(camera.right).toEqual(Cartesian3.cross(camera.direction, camera.up, new Cartesian3()), new Cartesian3());
});

it('get pick ray throws without a position', function() {
expect(function () {
camera.getPickRay();
}).toThrowDeveloperError();
});

it('get pick ray perspective', function() {
var windowCoord = new Cartesian2(scene.canvas.clientWidth / 2, scene.canvas.clientHeight);
var ray = camera.getPickRay(windowCoord);

var windowHeight = camera.frustum.near * Math.tan(camera.frustum.fovy * 0.5);
var expectedDirection = Cartesian3.normalize(new Cartesian3(0.0, -windowHeight, -1.0), new Cartesian3());
expect(ray.origin).toEqual(camera.position);
expect(ray.direction).toEqualEpsilon(expectedDirection, CesiumMath.EPSILON15);
});

it('get pick ray orthographic', function() {
var frustum = new OrthographicFrustum();
frustum.left = -10.0;
frustum.right = 10.0;
frustum.bottom = -10.0;
frustum.top = 10.0;
frustum.near = 1.0;
frustum.far = 21.0;
camera.frustum = frustum;

var windowCoord = new Cartesian2((3.0 / 5.0) * scene.canvas.clientWidth, (1.0 - (3.0 / 5.0)) * scene.canvas.clientHeight);
var ray = camera.getPickRay(windowCoord);

var cameraPosition = camera.position;
var expectedPosition = new Cartesian3(cameraPosition.x + 2.0, cameraPosition.y + 2, cameraPosition.z);
expect(ray.origin).toEqualEpsilon(expectedPosition, CesiumMath.EPSILON14);
expect(ray.direction).toEqual(camera.direction);
});

it('gets magnitude in 2D', function() {
var ellipsoid = Ellipsoid.WGS84;
var projection = new GeographicProjection(ellipsoid);
var maxRadii = ellipsoid.maximumRadius;

camera._mode = SceneMode.SCENE2D;
camera._projection = projection;

var frustum = new OrthographicFrustum();
frustum.right = maxRadii * Math.PI;
frustum.left = -frustum.right;
frustum.top = frustum.right * (scene.drawingBufferHeight / scene.drawingBufferWidth);
frustum.bottom = -frustum.top;
frustum.near = 0.01 * maxRadii;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;

expect(camera.getMagnitude()).toEqual(frustum.right - frustum.left);
});

it('gets magnitude in Columbus view', function() {
camera._mode = SceneMode.COLUMBUS_VIEW;
expect(camera.getMagnitude()).toEqual(camera.position.z);
});

it('gets magnitude in 3D', function() {
expect(camera.getMagnitude()).toEqual(Cartesian3.magnitude(camera.position));
});

it('create animation throws without a duration', function() {
expect(function() {
camera.createCorrectPositionTween();
}).toThrowDeveloperError();
});

it('does not animate in 3D', function() {
expect(camera.createCorrectPositionTween(0.05)).not.toBeDefined();
});

it('animates position to visible map in 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

var max = scene.mapProjection.project(new Cartographic(Math.PI, CesiumMath.PI_OVER_TWO));
var factor = 1000.0;
var dx = max.x * factor;
var dy = max.y * factor;
var tweens = new TweenCollection();

camera.moveUp(dy);
camera.moveRight(dx);

var correctAnimation = camera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
var animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(camera.position.x).toEqual(max.x);
expect(camera.position.y).toEqual(max.y);

camera.moveDown(dy);
camera.moveLeft(dx);

correctAnimation = camera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(camera.position.x).toEqual(-max.x);
expect(camera.position.y).toEqual(-max.y);
});

it('animates frustum in 2D', function() {
var frustum = new OrthographicFrustum();
frustum.near = 1.0;
frustum.far = 2.0;
frustum.left = -2.0;
frustum.right = 2.0;
frustum.top = 1.0;
frustum.bottom = -1.0;
camera.frustum = frustum;

camera.update(SceneMode.SCENE2D);

var max = scene.mapProjection.project(new Cartographic(Math.PI, CesiumMath.toRadians(85.05112878)));
var factor = 1000.0;
var dx = max.x * factor;
var tweens = new TweenCollection();

camera.zoomOut(dx);

var right = frustum.right;
var top = frustum.top;

var correctAnimation = camera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
var animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(frustum.right).toBeLessThan(right);
expect(frustum.right).toBeGreaterThan(max.x);
expect(frustum.left).toEqual(-frustum.right);
expect(frustum.top).toBeLessThan(top);
expect(frustum.top).toBeGreaterThan(max.y);
expect(frustum.bottom).toEqual(-frustum.top);
});

it('animates position to visible map in Columbus view', function() {
var maxRadii = Ellipsoid.WGS84.maximumRadius;
var frustum = new PerspectiveFrustum();
frustum.fov = CesiumMath.toRadians(60.0);
frustum.aspectRatio = scene.drawingBufferWidth / scene.drawingBufferHeight;
frustum.near = 100;
frustum.far = 60.0 * maxRadii;
camera.frustum = frustum;
camera.position = Cartesian3.multiplyBy(scalar: Cartesian3.UNIT_Z, maxRadii * 5.0, new Cartesian3());

camera.update(SceneMode.COLUMBUS_VIEW);

var max = scene.mapProjection.project(new Cartographic(Math.PI, CesiumMath.PI_OVER_TWO));
var factor = 1000.0;
var dx = max.x * factor;
var dy = max.y * factor;
var tweens = new TweenCollection();

camera.moveUp(dy);
camera.moveRight(dx);

var correctAnimation = camera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
var animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(camera.position.x).toEqualEpsilon(max.x, CesiumMath.EPSILON6);
expect(camera.position.y).toEqualEpsilon(max.y, CesiumMath.EPSILON6);

camera.moveDown(dy);
camera.moveLeft(dx);

correctAnimation = camera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(camera.position.x).toEqualEpsilon(-max.x, CesiumMath.EPSILON6);
expect(camera.position.y).toEqualEpsilon(-max.y, CesiumMath.EPSILON6);
});

it('animates position to visible map in Columbus view with web mercator projection', function() {
var projection = new WebMercatorProjection();
var mercatorCamera = new Camera(new FakeScene(projection));
mercatorCamera.position = Cartesian3.clone(position);
mercatorCamera.up = Cartesian3.clone(up);
mercatorCamera.direction = Cartesian3.clone(dir);
mercatorCamera.right = Cartesian3.clone(right);
mercatorCamera.minimumZoomDistance = 0.0;
mercatorCamera.update(SceneMode.COLUMBUS_VIEW);

var maxRadii = Ellipsoid.WGS84.maximumRadius;
var frustum = new PerspectiveFrustum();
frustum.fov = CesiumMath.toRadians(60.0);
frustum.aspectRatio = scene.drawingBufferWidth / scene.drawingBufferHeight;
frustum.near = 100;
frustum.far = 60.0 * maxRadii;
mercatorCamera.frustum = frustum;
mercatorCamera.position = Cartesian3.multiplyBy(scalar: Cartesian3.UNIT_Z, maxRadii * 5.0, new Cartesian3());

var max = projection.project(new Cartographic(Math.PI, CesiumMath.PI_OVER_TWO));
var factor = 1000.0;
var dx = max.x * factor;
var dy = max.y * factor;
var tweens = new TweenCollection();

mercatorCamera.moveUp(dy);
mercatorCamera.moveRight(dx);

var correctAnimation = mercatorCamera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
var animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(mercatorCamera.position.x).toEqualEpsilon(max.x, CesiumMath.EPSILON6);
expect(mercatorCamera.position.y).toEqualEpsilon(max.y, CesiumMath.EPSILON6);

mercatorCamera.moveDown(dy);
mercatorCamera.moveLeft(dx);

correctAnimation = mercatorCamera.createCorrectPositionTween(0.05);
expect(correctAnimation).toBeDefined();
animation = tweens.add(correctAnimation);
while(tweens.contains(animation)) {
tweens.update();
}

expect(mercatorCamera.position.x).toEqualEpsilon(-max.x, CesiumMath.EPSILON6);
expect(mercatorCamera.position.y).toEqualEpsilon(-max.y, CesiumMath.EPSILON6);
});

it('flyTo uses CameraFlightPath', function() {
spyOn(CameraFlightPath, 'createTween').andReturn({
startObject : {},
stopObject: {},
duration : 0.0
});

var options = {
destination : Cartesian3.fromDegrees(-117.16, 32.71, 15000.0)
};
camera.flyTo(options);

expect(CameraFlightPath.createTween).toHaveBeenCalledWith(scene, options);
});

it('flyToRectangle uses createTweenRectangle', function() {
spyOn(CameraFlightPath, 'createTweenRectangle').andReturn({
startObject : {},
stopObject: {},
duration : 0.0
});

var options = {
destination : Rectangle.fromDegrees(0.0, 20.0, 10.0, 30.0)
};
camera.flyToRectangle(options);

expect(CameraFlightPath.createTweenRectangle).toHaveBeenCalledWith(scene, options);
});
*/
}

