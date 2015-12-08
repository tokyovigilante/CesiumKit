//
//  SkyBox.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

enum CubeMapStringSourceReferenceType {
    case BundleResource
    case NetworkURL
    case FilePath
}


protocol CubeMapSourceReference {
    
}

extension String: CubeMapSourceReference {
    var referenceType: CubeMapStringSourceReferenceType {
        if self.hasPrefix("/") {
            return .FilePath
        } else if self.hasPrefix("http") {
            return .NetworkURL
        }
        return .BundleResource
    }
}

extension CGImageRef: CubeMapSourceReference {
    
}

struct CubeMapSources<T: CubeMapSourceReference> {
    let sources: [T]
    
    init (sourceReferences: [T]) {
        assert(sourceReferences.count == 6, "invalid source array")

        assertionFailure("convert")
        self.sources = sourceReferences
    }
}
extension CubeMapSources {

    var positiveX: T {
        return sources[0]
    }
    
    var negativeX: T {
        return sources[1]
    }

    var positiveY: T {
        return sources[2]
    }

    var negativeY: T {
        return sources[3]
    }

    var positiveZ: T {
        return sources[4]
    }

    var negativeZ: T {
        return sources[5]
    }

}
/*
struct SkyBoxResourceSources: SkyBoxSources {

}

struct SkyBoxFileSources: SkyBoxSources {

}

struct SkyBoxNetworkSources: SkyBoxSources {

}

struct SkyBoxImageSources: SkyBoxSources {

}*/

/**
 * A sky box around the scene to draw stars.  The sky box is defined using the True Equator Mean Equinox (TEME) axes.
 * <p>
 * This is only supported in 3D.  The sky box is faded out when morphing to 2D or Columbus view.  The size of
 * the sky box must not exceed {@link Scene#maximumCubeMapSize}.
 * </p>
 *
 * @alias SkyBox
 * @constructor
 *
 * @param {Object} options Object with the following properties:
 * @param {Object} [options.sources] The source URL or <code>Image</code> object for each of the six cube map faces.  See the example below.
 * @param {Boolean} [options.show=true] Determines if this primitive will be shown.
 *
 * @see Scene#skyBox
 * @see Transforms.computeTemeToPseudoFixedMatrix
 *
 * @example
 * scene.skyBox = new Cesium.SkyBox({
 *   sources : {
 *     positiveX : 'skybox_px.png',
 *     negativeX : 'skybox_nx.png',
 *     positiveY : 'skybox_py.png',
 *     negativeY : 'skybox_ny.png',
 *     positiveZ : 'skybox_pz.png',
 *     negativeZ : 'skybox_nz.png'
 *   }
 * });
 */

public class SkyBox {
    
    var sources: CubeMapSources<CGImageRef> {
        didSet {
            _sourcesUpdated = true
        }
    }
    private var _sourcesUpdated: Bool = true
    
    /**
     * Determines if the sky box will be shown.
     *
     * @type {Boolean}
     * @default true
     */
    var show: Bool
    
    private var _command: DrawCommand
    
    private var _cubeMap: CubeMap? = nil
    
    init (sources: CubeMapSources<CGImageRef>, show: Bool = true) {
        self.sources = sources
        self.show = show
        _cubeMap = nil
        _command = DrawCommand(
            modelMatrix: Matrix4.identity()
        )
        _command.owner = self
    }
    
    /**
    * Called when {@link Viewer} or {@link CesiumWidget} render the scene to
    * get the draw commands needed to render this primitive.
    * <p>
    * Do not call this function directly.  This is documented just to
    * list the exceptions that may be propagated when the scene is rendered:
    * </p>
    *
    * @exception {DeveloperError} this.sources is required and must have positiveX, negativeX, positiveY, negativeY, positiveZ, and negativeZ properties.
    * @exception {DeveloperError} this.sources properties must all be the same type.
    */
    func update (context: Context, frameState: FrameState) -> DrawCommand? {
        if !show {
            return nil
        }
        
        if frameState.mode != .Scene3D && frameState.mode != SceneMode.Morphing {
                return nil
        }
        
        // The sky box is only rendered during the render pass; it is not pickable, it doesn't cast shadows, etc.
        if !frameState.passes.render {
            return nil
        }
        
        if _sourcesUpdated {
            /*_cubeMap = CubeMap(
            context: context,
            source: sources
            )*/
        }
        /*
        var command = this._command;
        
        if (!defined(command.vertexArray)) {
            var that = this;
            
            command.uniformMap = {
                u_cubeMap: function() {
                    return that._cubeMap;
                }
            };
            
            var geometry = BoxGeometry.createGeometry(BoxGeometry.fromDimensions({
                dimensions : new Cartesian3(2.0, 2.0, 2.0),
                vertexFormat : VertexFormat.POSITION_ONLY
            }));
            var attributeLocations = GeometryPipeline.createAttributeLocations(geometry);
            
            command.vertexArray = VertexArray.fromGeometry({
                context : context,
                geometry : geometry,
                attributeLocations : attributeLocations,
                bufferUsage : BufferUsage.STATIC_DRAW
            });
            
            command.shaderProgram = ShaderProgram.fromCache({
                context : context,
                vertexShaderSource : SkyBoxVS,
                fragmentShaderSource : SkyBoxFS,
                attributeLocations : attributeLocations
            });
            
            command.renderState = RenderState.fromCache({
                blending : BlendingState.ALPHA_BLEND
            });
        }
        
        if (!defined(this._cubeMap)) {
            return undefined;
        }
        */
        return _command
    }
        
    private func loadImagesForSources (sources: [CubeMapSourceReference]) -> CubeMapSources<CGImageRef> {
        /*
        if let sources = sources as? SkyBoxResourceSources {
            let bundle = NSBundle.mainBundle()
            bundle.pathForResource(sources.positiveX, ofType: "jpg")
            return SkyBoxImageSources(
                positiveX: CGImageRef.fromFile(bundle.pathForResource(sources.positiveX, ofType:"jpg")),
                negativeX: CGImageRef.fromFile(bundle.pathForResource(sources.negativeX, ofType: "jpg")),
                positiveY: CGImageRef.fromFile(bundle.pathForResource(sources.positiveX, ofType: "jpg")),
                negativeY: CGImageRef.fromFile(bundle.pathForResource(sources.positiveX, ofType: "jpg")),
                positiveZ: CGImageRef.fromFile(bundle.pathForResource(sources.positiveX, ofType: "jpg")),
                negativeZ: CGImageRef.fromFile(bundle.pathForResource(sources.positiveX, ofType: "jpg"))
            )
        }*/
        return CubeMapSources<CGImageRef>(sourceReferences: [CGImageRef]())
    }

    public class func getDefaultSkyBoxUrl (face: String) -> String {
        return "tycho2t3_80_" + face
    }
}