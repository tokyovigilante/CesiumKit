//
//  ContextLimits.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation
import Metal

// see https://developer.apple.com/library/mac/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/MetalFeatureSetTables/MetalFeatureSetTables.html
class ContextLimits {
    
    private let _highestSupportedFeatureSet: MTLFeatureSet
    
    /**
    * The maximum number of texture units that can be used from the vertex and fragment
    * shader with this WebGL implementation.  The minimum is eight.  If both shaders access the
    * same texture unit, this counts as two texture units.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_COMBINED_TEXTURE_IMAGE_UNITS</code>.
    */
    var maximumCombinedTextureImageUnits: Int {
        #if os(OSX)
            switch(_highestSupportedFeatureSet) {
            case .OSX_GPUFamily1_v1:
                return 128
            default:
                fatalError("Unknown Metal GPU feature set")
            }
        #elseif os(iOS)
            switch(_highestSupportedFeatureSet) {
            case .iOS_GPUFamily1_v1:
                return 31
            case .iOS_GPUFamily2_v1:
                return 31
            case .iOS_GPUFamily1_v2:
                return 31
            case .iOS_GPUFamily2_v2:
                return 31
            case .iOS_GPUFamily3_v1:
                return 31
            default:
                fatalError("Unknown Metal GPU feature set")
            }
        #endif
    }
    
    /**
    * The approximate maximum cube mape width and height supported by this WebGL implementation.
    * The minimum is 16, but most desktop and laptop implementations will support much larger sizes like 8,192.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_CUBE_MAP_TEXTURE_SIZE</code>.
    */
    var maximumCubeMapSize: Int {
        return maximumTextureSize
    }
    
    /*
    /**
    * The maximum number of <code>vec4</code>, <code>ivec4</code>, and <code>bvec4</code>
    * uniforms that can be used by a fragment shader with this WebGL implementation.  The minimum is 16.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_FRAGMENT_UNIFORM_VECTORS</code>.
    */
    maximumFragmentUniformVectors : {
    get: function () {
    return ContextLimits._maximumFragmentUniformVectors;
    }
    },
    */
    /**
    * The maximum number of texture units that can be used from the fragment shader with this WebGL implementation.  The minimum is eight.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_TEXTURE_IMAGE_UNITS</code>.
    */
    var maximumTextureImageUnits: Int {
        return maximumCombinedTextureImageUnits
    }
    /*
    /**
    * The maximum renderbuffer width and height supported by this WebGL implementation.
    * The minimum is 16, but most desktop and laptop implementations will support much larger sizes like 8,192.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_RENDERBUFFER_SIZE</code>.
    */
    maximumRenderbufferSize : {
    get: function () {
    return ContextLimits._maximumRenderbufferSize;
    }
    },
    */
    /**
    * The approximate maximum texture width and height supported by this WebGL implementation.
    * The minimum is 64, but most desktop and laptop implementations will support much larger sizes like 8,192.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_TEXTURE_SIZE</code>.
    */
    var maximumTextureSize: Int {
        #if os(OSX)
            switch(_highestSupportedFeatureSet) {
            case .OSX_GPUFamily1_v1:
                return 16384
            default:
                fatalError("Unknown Metal GPU feature set")
            }
            #elseif os(iOS)
            switch(_highestSupportedFeatureSet) {
            case .iOS_GPUFamily1_v1:
                return 4096
            case .iOS_GPUFamily2_v1:
                return 8192
            case .iOS_GPUFamily1_v2:
                return 4096
            case .iOS_GPUFamily2_v2:
                return 8192
            case .iOS_GPUFamily3_v1:
                return 16384
            default:
                fatalError("Unknown Metal GPU feature set")
            }
        #endif
    }
    /*
    /**
    * The maximum number of <code>vec4</code> varying variables supported by this WebGL implementation.
    * The minimum is eight.  Matrices and arrays count as multiple <code>vec4</code>s.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_VARYING_VECTORS</code>.
    */
    maximumVaryingVectors : {
    get: function () {
    return ContextLimits._maximumVaryingVectors;
    }
    },
    
    /**
    * The maximum number of <code>vec4</code> vertex attributes supported by this WebGL implementation.  The minimum is eight.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_VERTEX_ATTRIBS</code>.
    */
    maximumVertexAttributes : {
    get: function () {
    return ContextLimits._maximumVertexAttributes;
    }
    },
    */
    /**
    * The maximum number of texture units that can be used from the vertex shader with this WebGL implementation.
    * The minimum is zero, which means the GL does not support vertex texture fetch.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_VERTEX_TEXTURE_IMAGE_UNITS</code>.
    */
    var maximumVertexTextureImageUnits: Int {
        return maximumCombinedTextureImageUnits
    }
    /*
    /**
    * The maximum number of <code>vec4</code>, <code>ivec4</code>, and <code>bvec4</code>
    * uniforms that can be used by a vertex shader with this WebGL implementation.  The minimum is 16.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_VERTEX_UNIFORM_VECTORS</code>.
    */
    maximumVertexUniformVectors : {
    get: function () {
    return ContextLimits._maximumVertexUniformVectors;
    }
    },
    */
    /**
    * The minimum aliased line width, in pixels, supported by this WebGL implementation.  It will be at most one.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>ALIASED_LINE_WIDTH_RANGE</code>.
    */
    var minimumAliasedLineWidth: Int {
        return 1
    }
    
    /**
    * The maximum aliased line width, in pixels, supported by this WebGL implementation.  It will be at least one.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>ALIASED_LINE_WIDTH_RANGE</code>.
    */
    var maximumAliasedLineWidth: Int {
        return 511
    }
    
    /**
    * The minimum aliased point size, in pixels, supported by this WebGL implementation.  It will be at most one.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>ALIASED_POINT_SIZE_RANGE</code>.
    */
    var minimumAliasedPointSize: Int {
        return 1
    }
    
    /**
    * The maximum aliased point size, in pixels, supported by this WebGL implementation.  It will be at least one.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>ALIASED_POINT_SIZE_RANGE</code>.
    */
    var maximumAliasedPointSize: Int {
        return 511
    }
    
    /**
    * The maximum supported width of the viewport.  It will be at least as large as the visible width of the associated canvas.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_VIEWPORT_DIMS</code>.
    */
    var maximumViewportWidth: Int {
        return maximumTextureSize
    }
    
    /**
    * The maximum supported height of the viewport.  It will be at least as large as the visible height of the associated canvas.
    * @memberof ContextLimits
    * @type {Number}
    * @see {@link https://www.khronos.org/opengles/sdk/docs/man/xhtml/glGet.xml|glGet} with <code>MAX_VIEWPORT_DIMS</code>.
    */
    var maximumViewportHeight: Int {
        return maximumTextureSize
    }
    
    /**
    * The maximum degree of anisotropy for texture filtering
    * @memberof ContextLimits
    * @type {Number}
    */
    var maximumTextureFilterAnisotropy: Int {
        return 16
    }
    /*
    /**
    * The maximum number of simultaneous outputs that may be written in a fragment shader.
    * @memberof ContextLimits
    * @type {Number}
    */
    maximumDrawBuffers : {
    get: function () {
    return ContextLimits._maximumDrawBuffers;
    }
    },
    */
    
    /**
    * The maximum number of color attachments supported.
    * @memberof ContextLimits
    * @type {Number}
    */
    var maximumColorAttachments: Int {
        #if os(OSX)
            switch(_highestSupportedFeatureSet) {
            case .OSX_GPUFamily1_v1:
                return 8
            default:
                fatalError("Unknown Metal GPU feature set")
            }
        #elseif os(iOS)
            switch(_highestSupportedFeatureSet) {
            case .iOS_GPUFamily1_v1:
                return 4
            case .iOS_GPUFamily2_v1:
                return 4
            case .iOS_GPUFamily1_v2:
                return 8
            case .iOS_GPUFamily2_v2:
                return 8
            case .iOS_GPUFamily3_v1:
                return 8
            default:
                fatalError("Unknown Metal GPU feature set")
            }
        #endif
        
    }
    
    /**
    * High precision float supported (<code>highp</code>) in fragment shaders.
    * @memberof ContextLimits
    * @type {Boolean}
    */
    var highpFloatSupported: Bool {
        return true
    }
    
    /**
    * High precision int supported (<code>highp</code>) in fragment shaders.
    * @memberof ContextLimits
    * @type {Boolean}
    */
    var highpIntSupported: Bool {
        return true
    }
    
    init (device: MTLDevice) {
        
        var highestSupportedFeatureSet: MTLFeatureSet
        #if os(OSX)
            let maxKnownFeatureSet: MTLFeatureSet = MTLFeatureSet.OSX_GPUFamily1_v1
            highestSupportedFeatureSet = .OSX_GPUFamily1_v1
            
            #elseif os(iOS)
            let maxKnownFeatureSet: MTLFeatureSet = MTLFeatureSet.iOS_GPUFamily1_v1
            highestSupportedFeatureSet = .iOS_GPUFamily1_v1
            
        #endif
        for featureSet in maxKnownFeatureSet.rawValue.stride(through: 0, by: -1) {
            let currentFeatureSet = MTLFeatureSet(rawValue: featureSet)!
            if device.supportsFeatureSet(currentFeatureSet)
            {
                highestSupportedFeatureSet = currentFeatureSet
                break
            }
        }
        _highestSupportedFeatureSet = highestSupportedFeatureSet
    }
    
}