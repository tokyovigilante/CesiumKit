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

struct CubeMapSources {
    let sources: [CGImageRef]
}
extension CubeMapSources {

    var positiveX: CGImageRef {
        return sources[0]
    }
    
    var negativeX: CGImageRef {
        return sources[1]
    }

    var positiveY: CGImageRef {
        return sources[2]
    }

    var negativeY: CGImageRef {
        return sources[3]
    }

    var positiveZ: CGImageRef {
        return sources[4]
    }

    var negativeZ: CGImageRef {
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

class SkyBox {
    
    var sources: CubeMapSources {
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
    var show: Bool = true
    
    private var _command: DrawCommand
    
    private var _cubemap: Texture? = nil
    
    convenience init (sources: [String]) {
        self.init(sources: CubeMap.loadImagesForSources(sources))
    }

    
    init (sources: CubeMapSources) {
        self.sources = sources
        _cubemap = nil
        _command = DrawCommand(
            modelMatrix: Matrix4.identity
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
            let width = Int(CGImageGetWidth(sources.positiveX))
            _cubemap = Texture(
                context: context,
                options: TextureOptions(
                    source: .CubeMap(sources),
                    width: width,
                    height: width,
                    cubeMap: true,
                    flipY: true,
                    usage: .ShaderRead
                )
            )
            _sourcesUpdated = false
        }
        
        if _command.vertexArray == nil {
            
            let uniformMap = SkyBoxUniformMap()
            uniformMap.cubemap = _cubemap
            _command.uniformMap = uniformMap
            

            let geometry = BoxGeometry(
                fromDimensions: Cartesian3(x: 2.0, y: 2.0, z: 2.0),
                vertexFormat : VertexFormat.PositionOnly()
                ).createGeometry(context)
            
            let attributeLocations = GeometryPipeline.createAttributeLocations(geometry)
            
            _command.vertexArray = VertexArray(
                fromGeometry: geometry,
                context: context,
                attributeLocations: attributeLocations
            )
            
            _command.pipeline = RenderPipeline.fromCache(
                context: context,
                vertexShaderSource: ShaderSource(sources: [Shaders["SkyBoxVS"]!]),
                fragmentShaderSource: ShaderSource(sources: [Shaders["SkyBoxFS"]!]),
                vertexDescriptor: VertexDescriptor(attributes: _command.vertexArray!.attributes),
                depthStencil: context.depthTexture,
                blendingState: .AlphaBlend()

            )
            
            _command.renderState = RenderState(
                device: context.device
            )
        }
        if _cubemap == nil {
            return nil
        }
        
        return _command
    }
        
    class func getDefaultSkyBoxUrl (face: String) -> String {
        return "tycho2t3_80_" + face
    }
}

private class SkyBoxUniformMap: UniformMap {
    
    var cubemap : Texture?
    
    let floatUniforms: [String : FloatUniformFunc] = [:]
    
    func textureForUniform(uniform: UniformSampler) -> Texture? {
        return cubemap
    }
}
