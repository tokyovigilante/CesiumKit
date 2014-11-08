//
//  UniformState.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

class UniformState {
 
   /**
     * @private
     */
    private var _viewport = BoundingRectangle()
    private var _viewportCartesian4 = Cartesian4()
    private var _viewportDirty = false
    private var _viewportOrthographicMatrix = Matrix4.identity()
    private var _viewportTransformation = Matrix4.identity()
    
    private var _model = Matrix4.identity()
    private var _view = Matrix4.identity()
    private var _inverseView = Matrix4.identity()
    private var _projection = Matrix4.identity()
    private var _infiniteProjection = Matrix4.identity()
    
    private var _entireFrustum = Cartesian2()
    private var _currentFrustum = Cartesian2()
    
    /**
    * @memberof UniformState.prototype
    * @type {FrameState}
    * @readonly
    */
    var _frameState: FrameState? = nil
    
    private var _temeToPseudoFixed = Matrix3.fromMatrix4(Matrix4.identity())
    
    // Derived members
    private var _view3DDirty = true
    private var _view3D = Matrix4()
    
    private var _inverseView3DDirty = true
    private var _inverseView3D = Matrix4()
    
    private var _inverseModelDirty = true
    private var _inverseModel = Matrix4()
    
    private var _inverseTransposeModelDirty = true
    private var _inverseTransposeModel = Matrix3()
    
    private var _viewRotation = Matrix3()
    private var _inverseViewRotation = Matrix3()
    
    private var _viewRotation3D = Matrix3()
    private var _inverseViewRotation3D = Matrix3()
    
    private var _inverseProjectionDirty = true
    private var _inverseProjection = Matrix4()
    
    private var _inverseProjectionOITDirty = true
    private var _inverseProjectionOIT = Matrix4()
    
    private var _modelViewDirty = true
    private var _modelView = Matrix4()
    
    private var _modelView3DDirty = true
    private var _modelView3D = Matrix4()
    
    private var _modelViewRelativeToEyeDirty = true
    private var _modelViewRelativeToEye = Matrix4()
    
    private var _inverseModelViewDirty = true
    private var _inverseModelView = Matrix4()
    
    private var _inverseModelView3DDirty = true
    private var _inverseModelView3D = Matrix4()
    
    private var _viewProjectionDirty = true
    private var _viewProjection = Matrix4()
    
    private var _inverseViewProjectionDirty = true
    private var _inverseViewProjection = Matrix4()
    
    private var _modelViewProjectionDirty = true
    private var _modelViewProjection = Matrix4()
    
    private var _inverseModelViewProjectionDirty = true
    private var _inverseModelViewProjection = Matrix4()
    
    private var _modelViewProjectionRelativeToEyeDirty = true
    private var _modelViewProjectionRelativeToEye = Matrix4()
    
    private var _modelViewInfiniteProjectionDirty = true
    private var _modelViewInfiniteProjection = Matrix4()
    
    private var _normalDirty = true
    private var _normal = Matrix3()
    
    private var _normal3DDirty = true
    private var _normal3D = Matrix3()
    
    private var _inverseNormalDirty = true
    private var _inverseNormal = Matrix3()
    
    private var _inverseNormal3DDirty = true
    private var _inverseNormal3D = Matrix3()
    
    private var _encodedCameraPositionMCDirty = true
    private var _encodedCameraPositionMC = EncodedCartesian3()
    private var _cameraPosition = Cartesian3()
    
    private var _sunPositionWC = Cartesian3()
    private var _sunPositionColumbusView = Cartesian3()
    private var _sunDirectionWC = Cartesian3()
    private var _sunDirectionEC = Cartesian3()
    private var _moonDirectionEC = Cartesian3()
    
    private var _mode: SceneMode? = nil
    private var _mapProjection: Projection? = nil
    private var _cameraDirection = Cartesian3()
    private var _cameraRight = Cartesian3()
    private var _cameraUp = Cartesian3()
    private var _frustum2DWidth = 0.0
    private var _eyeHeight2D = Cartesian2()
    
        /**
         * @memberof UniformState.prototype
         * @type {BoundingRectangle}
         */
    var viewport = BoundingRectangle() /*
        viewport: {
            get : function() {
                return this._viewport;
            },
            set : function(viewport) {
                if (!BoundingRectangle.equals(viewport, this._viewport)) {
                    BoundingRectangle.clone(viewport, this._viewport);

                    var v = this._viewport;
                    var vc = this._viewportCartesian4;
                    vc.x = v.x;
                    vc.y = v.y;
                    vc.z = v.width;
                    vc.w = v.height;

                    this._viewportDirty = true;
                }
            }
        },*/
/*
        /**
         * @memberof UniformState.prototype
         * @private
         */
        viewportCartesian4 : {
            get : function() {
                return this._viewportCartesian4;
            }
        },

        viewportOrthographic : {
            get : function() {
                cleanViewport(this);
                return this._viewportOrthographicMatrix;
            }
        },

        viewportTransformation : {
            get : function() {
                cleanViewport(this);
                return this._viewportTransformation;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        model : {
            get : function() {
                return this._model;
            },
            set : function(matrix) {
                Matrix4.clone(matrix, this._model);

                this._modelView3DDirty = true;
                this._inverseModelView3DDirty = true;
                this._inverseModelDirty = true;
                this._inverseTransposeModelDirty = true;
                this._modelViewDirty = true;
                this._inverseModelViewDirty = true;
                this._viewProjectionDirty = true;
                this._inverseViewProjectionDirty = true;
                this._modelViewRelativeToEyeDirty = true;
                this._inverseModelViewDirty = true;
                this._modelViewProjectionDirty = true;
                this._inverseModelViewProjectionDirty = true;
                this._modelViewProjectionRelativeToEyeDirty = true;
                this._modelViewInfiniteProjectionDirty = true;
                this._normalDirty = true;
                this._inverseNormalDirty = true;
                this._normal3DDirty = true;
                this._inverseNormal3DDirty = true;
                this._encodedCameraPositionMCDirty = true;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseModel : {
            get : function() {
                if (this._inverseModelDirty) {
                    this._inverseModelDirty = false;

                    Matrix4.inverse(this._model, this._inverseModel);
                }

                return this._inverseModel;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @private
         */
        inverseTranposeModel : {
            get : function() {
                var m = this._inverseTransposeModel;
                if (this._inverseTransposeModelDirty) {
                    this._inverseTransposeModelDirty = false;

                    Matrix4.getRotation(this.inverseModel, m);
                    Matrix3.transpose(m, m);
                }

                return m;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        view : {
            get : function() {
                return this._view;
            }
        },

        /**
         * The 3D view matrix.  In 3D mode, this is identical to {@link UniformState#view},
         * but in 2D and Columbus View it is a synthetic matrix based on the equivalent position
         * of the camera in the 3D world.
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        view3D : {
            get : function() {
                if (this._view3DDirty) {
                    if (this._mode === SceneMode.SCENE3D) {
                        Matrix4.clone(this._view, this._view3D);
                    } else {
                        view2Dto3D(this._cameraPosition, this._cameraDirection, this._cameraRight, this._cameraUp, this._frustum2DWidth, this._mode, this._mapProjection, this._view3D);
                    }
                    Matrix4.getRotation(this._view3D, this._viewRotation3D);
                    this._view3DDirty = false;
                }
                return this._view3D;
            }
        },

        /**
         * The 3x3 rotation matrix of the current view matrix ({@link UniformState#view}).
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        viewRotation : {
            get : function() {
                return this._viewRotation;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        viewRotation3D : {
            get : function() {
                var view3D = this.view3D;
                return this._viewRotation3D;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseView : {
            get : function() {
                return this._inverseView;
            }
        },

        /**
         * the 4x4 inverse-view matrix that transforms from eye to 3D world coordinates.  In 3D mode, this is
         * identical to {@link UniformState#inverseView}, but in 2D and Columbus View it is a synthetic matrix
         * based on the equivalent position of the camera in the 3D world.
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseView3D : {
            get : function() {
                if (this._inverseView3DDirty) {
                    Matrix4.inverseTransformation(this.view3D, this._inverseView3D);
                    Matrix4.getRotation(this._inverseView3D, this._inverseViewRotation3D);
                    this._inverseView3DDirty = false;
                }
                return this._inverseView3D;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        inverseViewRotation : {
            get : function() {
                return this._inverseViewRotation;
            }
        },

        /**
         * The 3x3 rotation matrix of the current 3D inverse-view matrix ({@link UniformState#inverseView3D}).
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        inverseViewRotation3D : {
            get : function() {
                var inverseView = this.inverseView3D;
                return this._inverseViewRotation3D;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        projection : {
            get : function() {
                return this._projection;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseProjection : {
            get : function() {
                cleanInverseProjection(this);
                return this._inverseProjection;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @private
         */
        inverseProjectionOIT : {
            get : function() {
                cleanInverseProjectionOIT(this);
                return this._inverseProjectionOIT;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        infiniteProjection : {
            get : function() {
                return this._infiniteProjection;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        modelView : {
            get : function() {
                cleanModelView(this);
                return this._modelView;
            }
        },

        /**
         * The 3D model-view matrix.  In 3D mode, this is equivalent to {@link UniformState#modelView}.  In 2D and
         * Columbus View, however, it is a synthetic matrix based on the equivalent position of the camera in the 3D world.
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        modelView3D : {
            get : function() {
                cleanModelView3D(this);
                return this._modelView3D;
            }
        },

        /**
         * Model-view relative to eye matrix.
         *
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        modelViewRelativeToEye : {
            get : function() {
                cleanModelViewRelativeToEye(this);
                return this._modelViewRelativeToEye;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseModelView : {
            get : function() {
                cleanInverseModelView(this);
                return this._inverseModelView;
            }
        },

        /**
         * The inverse of the 3D model-view matrix.  In 3D mode, this is equivalent to {@link UniformState#inverseModelView}.
         * In 2D and Columbus View, however, it is a synthetic matrix based on the equivalent position of the camera in the 3D world.
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseModelView3D : {
            get : function() {
                cleanInverseModelView3D(this);
                return this._inverseModelView3D;

            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        viewProjection : {
            get : function() {
                cleanViewProjection(this);
                return this._viewProjection;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseViewProjection : {
            get : function() {
                cleanInverseViewProjection(this);
                return this._inverseViewProjection;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        modelViewProjection : {
            get : function() {
                cleanModelViewProjection(this);
                return this._modelViewProjection;

            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        inverseModelViewProjection : {
            get : function() {
                cleanInverseModelViewProjection(this);
                return this._inverseModelViewProjection;

            }
        },

        /**
         * Model-view-projection relative to eye matrix.
         *
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        modelViewProjectionRelativeToEye : {
            get : function() {
                cleanModelViewProjectionRelativeToEye(this);
                return this._modelViewProjectionRelativeToEye;
            }
        },

        /**
         * @memberof UniformState.prototype
         * @type {Matrix4}
         */
        modelViewInfiniteProjection : {
            get : function() {
                cleanModelViewInfiniteProjection(this);
                return this._modelViewInfiniteProjection;
            }
        },

        /**
         * A 3x3 normal transformation matrix that transforms normal vectors in model coordinates to
         * eye coordinates.
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        normal : {
            get : function() {
                cleanNormal(this);
                return this._normal;
            }
        },

        /**
         * A 3x3 normal transformation matrix that transforms normal vectors in 3D model
         * coordinates to eye coordinates.  In 3D mode, this is identical to
         * {@link UniformState#normal}, but in 2D and Columbus View it represents the normal transformation
         * matrix as if the camera were at an equivalent location in 3D mode.
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        normal3D : {
            get : function() {
                cleanNormal3D(this);
                return this._normal3D;

            }
        },

        /**
         * An inverse 3x3 normal transformation matrix that transforms normal vectors in model coordinates
         * to eye coordinates.
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        inverseNormal : {
            get : function() {
                cleanInverseNormal(this);
                return this._inverseNormal;
            }
        },

        /**
         * An inverse 3x3 normal transformation matrix that transforms normal vectors in eye coordinates
         * to 3D model coordinates.  In 3D mode, this is identical to
         * {@link UniformState#inverseNormal}, but in 2D and Columbus View it represents the normal transformation
         * matrix as if the camera were at an equivalent location in 3D mode.
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        inverseNormal3D : {
            get : function() {
                cleanInverseNormal3D(this);
                return this._inverseNormal3D;
            }
        },

        /**
         * The near distance (<code>x</code>) and the far distance (<code>y</code>) of the frustum defined by the camera.
         * This is the largest possible frustum, not an individual frustum used for multi-frustum rendering.
         * @memberof UniformState.prototype
         * @type {Cartesian2}
         */
        entireFrustum : {
            get : function() {
                return this._entireFrustum;
            }
        },

        /**
         * The near distance (<code>x</code>) and the far distance (<code>y</code>) of the frustum defined by the camera.
         * This is the individual frustum used for multi-frustum rendering.
         * @memberof UniformState.prototype
         * @type {Cartesian2}
         */
        currentFrustum : {
            get : function() {
                return this._currentFrustum;
            }
        },

        /**
         * The the height (<code>x</code>) and the height squared (<code>y</code>)
         * in meters of the camera above the 2D world plane. This uniform is only valid
         * when the {@link SceneMode} equal to <code>SCENE2D</code>.
         * @memberof UniformState.prototype
         * @type {Cartesian2}
         */
        eyeHeight2D : {
            get : function() {
                return this._eyeHeight2D;
            }
        },

        /**
         * The sun position in 3D world coordinates at the current scene time.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        sunPositionWC : {
            get : function() {
                return this._sunPositionWC;
            }
        },

        /**
         * The sun position in 2D world coordinates at the current scene time.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        sunPositionColumbusView : {
            get : function(){
                return this._sunPositionColumbusView;
            }
        },

        /**
         * A normalized vector to the sun in 3D world coordinates at the current scene time.  Even in 2D or
         * Columbus View mode, this returns the position of the sun in the 3D scene.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        sunDirectionWC : {
            get : function() {
                return this._sunDirectionWC;
            }
        },

        /**
         * A normalized vector to the sun in eye coordinates at the current scene time.  In 3D mode, this
         * returns the actual vector from the camera position to the sun position.  In 2D and Columbus View, it returns
         * the vector from the equivalent 3D camera position to the position of the sun in the 3D scene.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        sunDirectionEC : {
            get : function() {
                return this._sunDirectionEC;
            }
        },

        /**
         * A normalized vector to the moon in eye coordinates at the current scene time.  In 3D mode, this
         * returns the actual vector from the camera position to the moon position.  In 2D and Columbus View, it returns
         * the vector from the equivalent 3D camera position to the position of the moon in the 3D scene.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        moonDirectionEC : {
            get : function() {
                return this._moonDirectionEC;
            }
        },

        /**
         * The high bits of the camera position.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        encodedCameraPositionMCHigh : {
            get : function() {
                cleanEncodedCameraPositionMC(this);
                return this._encodedCameraPositionMC.high;
            }
        },

        /**
         * The low bits of the camera position.
         * @memberof UniformState.prototype
         * @type {Cartesian3}
         */
        encodedCameraPositionMCLow : {
            get : function() {
                cleanEncodedCameraPositionMC(this);
                return this._encodedCameraPositionMC.low;
            }
        },

        /**
         * A 3x3 matrix that transforms from True Equator Mean Equinox (TEME) axes to the
         * pseudo-fixed axes at the Scene's current time.
         * @memberof UniformState.prototype
         * @type {Matrix3}
         */
        temeToPseudoFixedMatrix : {
            get : function() {
                return this._temeToPseudoFixed;
            }
        },

        /**
         * Gets the scaling factor for transforming from the canvas
         * pixel space to canvas coordinate space.
         * @memberof UniformState.prototype
         * @type {Number}
         */
        resolutionScale : {
            get : function() {
                return this._resolutionScale;
            }
        }
    });
*/
    func setView(matrix: Matrix4) {
        _view = matrix
        _viewRotation = _view.rotation()
        
        _view3DDirty = true
        _inverseView3DDirty = true
        _modelViewDirty = true
        _modelView3DDirty = true
        _modelViewRelativeToEyeDirty = true
        _inverseModelViewDirty = true
        _inverseModelView3DDirty = true
        _viewProjectionDirty = true
        _modelViewProjectionDirty = true
        _modelViewProjectionRelativeToEyeDirty = true
        _modelViewInfiniteProjectionDirty = true
        _normalDirty = true
        _inverseNormalDirty = true
        _normal3DDirty = true
        _inverseNormal3DDirty = true
    }

    func setInverseView(matrix: Matrix4) {
        _inverseView = matrix
        _inverseViewRotation = matrix.rotation()
    }

    func setProjection(matrix: Matrix4) {
        _projection = matrix

        _inverseProjectionDirty = true
        _inverseProjectionOITDirty = true
        _viewProjectionDirty = true
        _modelViewProjectionDirty = true
        _modelViewProjectionRelativeToEyeDirty = true
    }

    func setInfiniteProjection(matrix: Matrix4) {
        _infiniteProjection = matrix
        _modelViewInfiniteProjectionDirty = true
    }

    func setCamera(camera: Camera) {
        _cameraPosition = camera.positionWC
        _cameraDirection = camera.directionWC
        _cameraRight = camera.rightWC
        _cameraUp = camera.upWC
        _encodedCameraPositionMCDirty = true
    }
/*
    var transformMatrix = new Matrix3();
    var sunCartographicScratch = new Cartographic();
    function setSunAndMoonDirections(uniformState, frameState) {
        if (!defined(Transforms.computeIcrfToFixedMatrix(frameState.time, transformMatrix))) {
            transformMatrix = Transforms.computeTemeToPseudoFixedMatrix(frameState.time, transformMatrix);
        }

        var position = Simon1994PlanetaryPositions.computeSunPositionInEarthInertialFrame(frameState.time, uniformState._sunPositionWC);
        Matrix3.multiplyByVector(transformMatrix, position, position);

        Cartesian3.normalize(position, uniformState._sunDirectionWC);

        position = Matrix3.multiplyByVector(uniformState.viewRotation3D, position, uniformState._sunDirectionEC);
        Cartesian3.normalize(position, position);

        position = Simon1994PlanetaryPositions.computeMoonPositionInEarthInertialFrame(frameState.time, uniformState._moonDirectionEC);
        Matrix3.multiplyByVector(transformMatrix, position, position);
        Matrix3.multiplyByVector(uniformState.viewRotation3D, position, position);
        Cartesian3.normalize(position, position);

        var projection = frameState.mapProjection;
        var ellipsoid = projection.ellipsoid;
        var sunCartographic = ellipsoid.cartesianToCartographic(uniformState._sunPositionWC, sunCartographicScratch);
        projection.project(sunCartographic, uniformState._sunPositionColumbusView);
    }
*/
    /**
     * Synchronizes the frustum's state with the uniform state.  This is called
     * by the {@link Scene} when rendering to ensure that automatic GLSL uniforms
     * are set to the right value.
     *
     * @param {Object} frustum The frustum to synchronize with.
     */
    // FIXME: frustum
    func updateFrustum (frustum: Frustum) {
        setProjection(frustum.projectionMatrix)
        if frustum.infiniteProjectionMatrix != nil {
            setInfiniteProjection(frustum.infiniteProjectionMatrix!)
        }
        _currentFrustum.x = frustum.near
        _currentFrustum.y = frustum.far
    }
    
    /**
     * Synchronizes frame state with the uniform state.  This is called
     * by the {@link Scene} when rendering to ensure that automatic GLSL uniforms
     * are set to the right value.
     *
     * @param {FrameState} frameState The frameState to synchronize with.
     */
    func update(context: Context, frameState: FrameState) {

        _mode = frameState.mode
        _mapProjection = frameState.mapProjection

        var camera = frameState.camera!

        setView(camera.viewMatrix)
        setInverseView(camera.inverseViewMatrix)
        setCamera(camera)

        if frameState.mode == SceneMode.Scene2D {
            _frustum2DWidth = camera.frustum.right - camera.frustum.left
            _eyeHeight2D.x = _frustum2DWidth * 0.5
            _eyeHeight2D.y = _eyeHeight2D.x * _eyeHeight2D.x
        } else {
            _frustum2DWidth = 0.0
            _eyeHeight2D.x = 0.0
            _eyeHeight2D.y = 0.0
        }

        //FIXME: setSunAndMoonDirections
        //setSunAndMoonDirections(this, frameState);

        _entireFrustum.x = camera.frustum.near
        _entireFrustum.y = camera.frustum.far
        updateFrustum(camera.frustum)

        _frameState = frameState
        // FIXME: _temeToPseudoFixed
        //_temeToPseudoFixed = Transforms.computeTemeToPseudoFixedMatrix(frameState.time)
    };

    /*function cleanViewport(uniformState) {
        if (uniformState._viewportDirty) {
            var v = uniformState._viewport;
            Matrix4.computeOrthographicOffCenter(v.x, v.x + v.width, v.y, v.y + v.height, 0.0, 1.0, uniformState._viewportOrthographicMatrix);
            Matrix4.computeViewportTransformation(v, 0.0, 1.0, uniformState._viewportTransformation);
            uniformState._viewportDirty = false;
        }
    }

    function cleanInverseProjection(uniformState) {
        if (uniformState._inverseProjectionDirty) {
            uniformState._inverseProjectionDirty = false;

            Matrix4.inverse(uniformState._projection, uniformState._inverseProjection);
        }
    }

    function cleanInverseProjectionOIT(uniformState) {
        if (uniformState._inverseProjectionOITDirty) {
            uniformState._inverseProjectionOITDirty = false;

            if (uniformState._mode !== SceneMode.SCENE2D && uniformState._mode !== SceneMode.MORPHING) {
                Matrix4.inverse(uniformState._projection, uniformState._inverseProjectionOIT);
            } else {
                Matrix4.clone(Matrix4.IDENTITY, uniformState._inverseProjectionOIT);
            }
        }
    }

    // Derived
    function cleanModelView(uniformState) {
        if (uniformState._modelViewDirty) {
            uniformState._modelViewDirty = false;

            Matrix4.multiplyTransformation(uniformState._view, uniformState._model, uniformState._modelView);
        }
    }

    function cleanModelView3D(uniformState) {
        if (uniformState._modelView3DDirty) {
            uniformState._modelView3DDirty = false;

            Matrix4.multiplyTransformation(uniformState.view3D, uniformState._model, uniformState._modelView3D);
        }
    }

    function cleanInverseModelView(uniformState) {
        if (uniformState._inverseModelViewDirty) {
            uniformState._inverseModelViewDirty = false;

            Matrix4.inverse(uniformState.modelView, uniformState._inverseModelView);
        }
    }

    function cleanInverseModelView3D(uniformState) {
        if (uniformState._inverseModelView3DDirty) {
            uniformState._inverseModelView3DDirty = false;

            Matrix4.inverse(uniformState.modelView3D, uniformState._inverseModelView3D);
        }
    }

    function cleanViewProjection(uniformState) {
        if (uniformState._viewProjectionDirty) {
            uniformState._viewProjectionDirty = false;

            Matrix4.multiply(uniformState._projection, uniformState._view, uniformState._viewProjection);
        }
    }

    function cleanInverseViewProjection(uniformState) {
        if (uniformState._inverseViewProjectionDirty) {
            uniformState._inverseViewProjectionDirty = false;

            Matrix4.inverse(uniformState.viewProjection, uniformState._inverseViewProjection);
        }
    }

    function cleanModelViewProjection(uniformState) {
        if (uniformState._modelViewProjectionDirty) {
            uniformState._modelViewProjectionDirty = false;

            Matrix4.multiply(uniformState._projection, uniformState.modelView, uniformState._modelViewProjection);
        }
    }

    function cleanModelViewRelativeToEye(uniformState) {
        if (uniformState._modelViewRelativeToEyeDirty) {
            uniformState._modelViewRelativeToEyeDirty = false;

            var mv = uniformState.modelView;
            var mvRte = uniformState._modelViewRelativeToEye;
            mvRte[0] = mv[0];
            mvRte[1] = mv[1];
            mvRte[2] = mv[2];
            mvRte[3] = mv[3];
            mvRte[4] = mv[4];
            mvRte[5] = mv[5];
            mvRte[6] = mv[6];
            mvRte[7] = mv[7];
            mvRte[8] = mv[8];
            mvRte[9] = mv[9];
            mvRte[10] = mv[10];
            mvRte[11] = mv[11];
            mvRte[12] = 0.0;
            mvRte[13] = 0.0;
            mvRte[14] = 0.0;
            mvRte[15] = mv[15];
        }
    }

    function cleanInverseModelViewProjection(uniformState) {
        if (uniformState._inverseModelViewProjectionDirty) {
            uniformState._inverseModelViewProjectionDirty = false;

            Matrix4.inverse(uniformState.modelViewProjection, uniformState._inverseModelViewProjection);
        }
    }

    function cleanModelViewProjectionRelativeToEye(uniformState) {
        if (uniformState._modelViewProjectionRelativeToEyeDirty) {
            uniformState._modelViewProjectionRelativeToEyeDirty = false;

            Matrix4.multiply(uniformState._projection, uniformState.modelViewRelativeToEye, uniformState._modelViewProjectionRelativeToEye);
        }
    }

    function cleanModelViewInfiniteProjection(uniformState) {
        if (uniformState._modelViewInfiniteProjectionDirty) {
            uniformState._modelViewInfiniteProjectionDirty = false;

            Matrix4.multiply(uniformState._infiniteProjection, uniformState.modelView, uniformState._modelViewInfiniteProjection);
        }
    }

    function cleanNormal(uniformState) {
        if (uniformState._normalDirty) {
            uniformState._normalDirty = false;

            var m = uniformState._normal;
            Matrix4.getRotation(uniformState.inverseModelView, m);
            Matrix3.transpose(m, m);
        }
    }

    function cleanNormal3D(uniformState) {
        if (uniformState._normal3DDirty) {
            uniformState._normal3DDirty = false;

            var m = uniformState._normal3D;
            Matrix4.getRotation(uniformState.inverseModelView3D, m);
            Matrix3.transpose(m, m);
        }
    }

    function cleanInverseNormal(uniformState) {
        if (uniformState._inverseNormalDirty) {
            uniformState._inverseNormalDirty = false;

            Matrix4.getRotation(uniformState.inverseModelView, uniformState._inverseNormal);
        }
    }

    function cleanInverseNormal3D(uniformState) {
        if (uniformState._inverseNormal3DDirty) {
            uniformState._inverseNormal3DDirty = false;

            Matrix4.getRotation(uniformState.inverseModelView3D, uniformState._inverseNormal3D);
        }
    }

    var cameraPositionMC = new Cartesian3();

    function cleanEncodedCameraPositionMC(uniformState) {
        if (uniformState._encodedCameraPositionMCDirty) {
            uniformState._encodedCameraPositionMCDirty = false;

            Matrix4.multiplyByPoint(uniformState.inverseModel, uniformState._cameraPosition, cameraPositionMC);
            EncodedCartesian3.fromCartesian(cameraPositionMC, uniformState._encodedCameraPositionMC);
        }
    }

    var view2Dto3DPScratch = new Cartesian3();
    var view2Dto3DRScratch = new Cartesian3();
    var view2Dto3DUScratch = new Cartesian3();
    var view2Dto3DDScratch = new Cartesian3();
    var view2Dto3DCartographicScratch = new Cartographic();
    var view2Dto3DCartesian3Scratch = new Cartesian3();
    var view2Dto3DMatrix4Scratch = new Matrix4();

    function view2Dto3D(position2D, direction2D, right2D, up2D, frustum2DWidth, mode, projection, result) {
        // The camera position and directions are expressed in the 2D coordinate system where the Y axis is to the East,
        // the Z axis is to the North, and the X axis is out of the map.  Express them instead in the ENU axes where
        // X is to the East, Y is to the North, and Z is out of the local horizontal plane.
        var p = view2Dto3DPScratch;
        p.x = position2D.y;
        p.y = position2D.z;
        p.z = position2D.x;

        var r = view2Dto3DRScratch;
        r.x = right2D.y;
        r.y = right2D.z;
        r.z = right2D.x;

        var u = view2Dto3DUScratch;
        u.x = up2D.y;
        u.y = up2D.z;
        u.z = up2D.x;

        var d = view2Dto3DDScratch;
        d.x = direction2D.y;
        d.y = direction2D.z;
        d.z = direction2D.x;

        // In 2D, the camera height is always 12.7 million meters.
        // The apparent height is equal to half the frustum width.
        if (mode === SceneMode.SCENE2D) {
            p.z = frustum2DWidth * 0.5;
        }

        // Compute the equivalent camera position in the real (3D) world.
        // In 2D and Columbus View, the camera can travel outside the projection, and when it does so
        // there's not really any corresponding location in the real world.  So clamp the unprojected
        // longitude and latitude to their valid ranges.
        var cartographic = projection.unproject(p, view2Dto3DCartographicScratch);
        cartographic.longitude = CesiumMath.clamp(cartographic.longitude, -Math.PI, Math.PI);
        cartographic.latitude = CesiumMath.clamp(cartographic.latitude, -CesiumMath.PI_OVER_TWO, CesiumMath.PI_OVER_TWO);
        var ellipsoid = projection.ellipsoid;
        var position3D = ellipsoid.cartographicToCartesian(cartographic, view2Dto3DCartesian3Scratch);

        // Compute the rotation from the local ENU at the real world camera position to the fixed axes.
        var enuToFixed = Transforms.eastNorthUpToFixedFrame(position3D, ellipsoid, view2Dto3DMatrix4Scratch);

        // Transform each camera direction to the fixed axes.
        Matrix4.multiplyByPointAsVector(enuToFixed, r, r);
        Matrix4.multiplyByPointAsVector(enuToFixed, u, u);
        Matrix4.multiplyByPointAsVector(enuToFixed, d, d);

        // Compute the view matrix based on the new fixed-frame camera position and directions.
        if (!defined(result)) {
            result = new Matrix4();
        }

        result[0] = r.x;
        result[1] = u.x;
        result[2] = -d.x;
        result[3] = 0.0;
        result[4] = r.y;
        result[5] = u.y;
        result[6] = -d.y;
        result[7] = 0.0;
        result[8] = r.z;
        result[9] = u.z;
        result[10] = -d.z;
        result[11] = 0.0;
        result[12] = -Cartesian3.dot(r, position3D);
        result[13] = -Cartesian3.dot(u, position3D);
        result[14] = Cartesian3.dot(d, position3D);
        result[15] = 1.0;

        return result;
    }

    return UniformState;
});*/
}