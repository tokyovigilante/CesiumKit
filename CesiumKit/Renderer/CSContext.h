//
//  CSContext.h
//  CesiumKit
//
//  Created by Ryan Walklin on 7/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

@import Foundation;

@import OpenGLES.ES3.gl;
@import CoreGraphics.CGGeometry;

@class GLKView, CSShaderCache, CSUniformState, CSPassState, CSRenderState, CSTexture, CSCubeMap, CSShaderProgram, CSBuffer, CSVertexBuffer, CSIndexBuffer, CSCartesian4;


typedef enum CSBufferUsage{
    STREAM_DRAW = 0x88E0,
    STATIC_DRAW = 0x88E4,
    DYNAMIC_DRAW = 0x88E8
} CSBufferUsage;

enum CSIndexDataType;

@interface CSContext : NSObject

#warning EAGLLayer
@property (nonatomic, weak) GLKView *glkView;

/**
 * DOC_TBA
 * @memberof Context.prototype
 * @type {ShaderCache}
 */
@property (nonatomic) CSShaderCache *shaderCache;
@property (nonatomic) NSString *guid;
/**
 * The WebGL version or release number of the form &lt;WebGL&gt;&lt;space&gt;&lt;version number&gt;&lt;space&gt;&lt;vendor-specific information&gt;.
 * @memberof Context.prototype
 * @type {String}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetString.xml'>glGetString</a> with <code>VERSION</code>.
 */
@property (readonly) NSString *glVersion;
/**
 * The version or release number for the shading language of the form WebGL&lt;space&gt;GLSL&lt;space&gt;ES&lt;space&gt;&lt;version number&gt;&lt;space&gt;&lt;vendor-specific information&gt;.
 * @memberof Context.prototype
 * @type {String}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetString.xml'>glGetString</a> with <code>SHADING_LANGUAGE_VERSION</code>.
 */
@property (readonly) NSString *shadingLanguageVersion;

/**
 * The company responsible for the WebGL implementation.
 * @memberof Context.prototype
 * @type {String}
 */
@property (readonly) NSString *vendor;

/**
 * The name of the renderer/configuration/hardware platform. For example, this may be the model of the
 * video card, e.g., 'GeForce 8800 GTS/PCI/SSE2', or the browser-dependent name of the GL implementation, e.g.
 * 'Mozilla' or 'ANGLE.'
 * @memberof Context.prototype
 * @type {String}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetString.xml'>glGetString</a> with <code>RENDERER</code>.
 * @see <a href='http://code.google.com/p/angleproject/'>ANGLE</a>
 */
@property (readonly) NSString *renderer;

/**
 * The number of red bits per component in the default framebuffer's color buffer.  The minimum is eight.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>RED_BITS</code>.
 */
@property (readonly) GLint redBits;

/**
 * The number of green bits per component in the default framebuffer's color buffer.  The minimum is eight.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>GREEN_BITS</code>.
 */
@property (readonly) GLint greenBits;

/**
 * The number of blue bits per component in the default framebuffer's color buffer.  The minimum is eight.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>BLUE_BITS</code>.
 */
@property (readonly) GLint blueBits;

/**
 * The number of alpha bits per component in the default framebuffer's color buffer.  The minimum is eight.
 * <br /><br />
 * The alpha channel is used for GL destination alpha operations and by the HTML compositor to combine the color buffer
 * with the rest of the page.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>ALPHA_BITS</code>.
 */
@property (readonly) GLint alphaBits;

/**
 * The number of depth bits per pixel in the default bound framebuffer.  The minimum is 16 bits; most
 * implementations will have 24 bits.
 * @memberof Context.protoytpe
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>DEPTH_BITS</code>.
 */
@property (readonly) GLint depthBits;

/**
 * The number of stencil bits per pixel in the default bound framebuffer.  The minimum is eight bits.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>STENCIL_BITS</code>.
 */
@property (readonly) GLint stencilBits;

/**
 * The maximum number of texture units that can be used from the vertex and fragment
 * shader with this WebGL implementation.  The minimum is eight.  If both shaders access the
 * same texture unit, this counts as two texture units.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_COMBINED_TEXTURE_IMAGE_UNITS</code>.
 */
@property (readonly) GLint maximumCombinedTextureImageUnits; // min 8

/**
 * The approximate maximum cube mape width and height supported by this WebGL implementation.
 * The minimum is 16, but most desktop and laptop implementations will support much larger sizes like 8,192.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_CUBE_MAP_TEXTURE_SIZE</code>.
 */
@property (readonly) GLint maximumCubeMapSize; // min 16

/**
 * Rhe maximum number of <code>vec4</code>, <code>ivec4</code>, and <code>bvec4</code>
 * uniforms that can be used by a fragment shader with this WebGL implementation.  The minimum is 16.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_FRAGMENT_UNIFORM_VECTORS</code>.
 */
@property (readonly) GLint maximumFragmentUniformVectors; // min 16

/**
 * The maximum number of texture units that can be used from the fragment shader with this WebGL implementation.  The minimum is eight.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_TEXTURE_IMAGE_UNITS</code>.
 */
@property (readonly) GLint maximumTextureImageUnits; // min 8

/**
 * The maximum renderbuffer width and height supported by this WebGL implementation.
 * The minimum is 16, but most desktop and laptop implementations will support much larger sizes like 8,192.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_RENDERBUFFER_SIZE</code>.
 */
@property (readonly) GLint maximumRenderBufferSize; // min 1

/**
 * The approximate maximum texture width and height supported by this WebGL implementation.
 * The minimum is 64, but most desktop and laptop implementations will support much larger sizes like 8,192.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_TEXTURE_SIZE</code>.
 */
@property (readonly) GLint maximumTextureSize; // min 64

/**
 * The maximum number of <code>vec4</code> varying variables supported by this WebGL implementation.
 * The minimum is eight.  Matrices and arrays count as multiple <code>vec4</code>s.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_VARYING_VECTORS</code>.
 */
@property (readonly) GLint maximumVaryingVectors; // min 8

/**
 * The maximum number of <code>vec4</code> vertex attributes supported by this WebGL implementation.  The minimum is eight.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_VERTEX_ATTRIBS</code>.
 */
@property (readonly) GLint maximumVertexAttributes; // min 8

/**
 * The maximum number of texture units that can be used from the vertex shader with this WebGL implementation.
 * The minimum is zero, which means the GL does not support vertex texture fetch.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_VERTEX_TEXTURE_IMAGE_UNITS</code>.
 */
@property (readonly) GLint maximumVertexTextureImageUnits; // min 0

/**
 * The maximum number of <code>vec4</code>, <code>ivec4</code>, and <code>bvec4</code>
 * uniforms that can be used by a vertex shader with this WebGL implementation.  The minimum is 16.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_VERTEX_UNIFORM_VECTORS</code>.
 */
@property (readonly) GLint maximumVertexUniformVectors;

/**
 * The minimum aliased line width, in pixels, supported by this WebGL implementation.  It will be at most one.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>ALIASED_LINE_WIDTH_RANGE</code>.
 */
@property (readonly) GLint aliasedLineWidthRange; // must include 1;

/**
 * The minimum aliased point size, in pixels, supported by this WebGL implementation.  It will be at most one.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>ALIASED_POINT_SIZE_RANGE</code>.
 */
@property (readonly) GLint aliasedPointSizeRange;

/**
 * The maximum supported width of the viewport.  It will be at least as large as the visible width of the associated canvas.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGet.xml'>glGet</a> with <code>MAX_VIEWPORT_DIMS</code>.
 */
@property (readonly) CGSize maximumViewportDimensions;

/**
 * <code>true</code> if the WebGL context supports antialiasing.  By default
 * antialiasing is requested, but it is not supported by all systems.
 * @memberof Context.prototype
 * @type {Boolean}
 */
@property (readonly) BOOL antialias;

/**
 * <code>true</code> if the OES_standard_derivatives extension is supported.  This
 * extension provides access to <code>dFdx<code>, <code>dFdy<code>, and <code>fwidth<code>
 * functions from GLSL.  A shader using these functions still needs to explicitly enable the
 * extension with <code>#extension GL_OES_standard_derivatives : enable</code>.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/gles/extensions/OES/OES_standard_derivatives.txt'>OES_standard_derivatives</a>
 */
@property (readonly) BOOL standardDerivatives;

/**
 * <code>true</code> if the OES_element_index_uint extension is supported.  This
 * extension allows the use of unsigned int indices, which can improve performance by
 * eliminating batch breaking caused by unsigned short indices.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/webgl/extensions/OES_element_index_uint/'>OES_element_index_uint</a>
 */
@property (readonly) BOOL elementIndexUint;

/**
 * <code>true</code> if WEBGL_depth_texture is supported.  This extension provides
 * access to depth textures that, for example, can be attached to framebuffers for shadow mapping.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/webgl/extensions/WEBGL_depth_texture/'>WEBGL_depth_texture</a>
 */
@property (readonly) BOOL depthTexture;

/**
 * <code>true</code> if OES_texture_float is supported.  This extension provides
 * access to floating point textures that, for example, can be attached to framebuffers for high dynamic range.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/gles/extensions/OES/OES_texture_float.txt'>OES_texture_float</a>
 */
@property (readonly) BOOL floatingPointTexture;

/**
 * DOC_TBA
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/webgl/extensions/EXT_texture_filter_anisotropic/'>EXT_texture_filter_anisotropic</a>
 */
@property (readonly) BOOL textureFilterAnisotropic;
@property (readonly) GLint maximumTextureFilterAnisotropy;

/**
 * <code>true</code> if the OES_vertex_array_object extension is supported.  This
 * extension can improve performance by reducing the overhead of switching vertex arrays.
 * When enabled, this extension is automatically used by {@link VertexArray}.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/webgl/extensions/OES_vertex_array_object/'>OES_vertex_array_object</a>
 */
@property (readonly) BOOL vertexArrayObject;


/**
 * <code>true</code> if the EXT_frag_depth extension is supported.  This
 * extension provides access to the <code>gl_FragDepthEXT<code> built-in output variable
 * from GLSL fragment shaders.  A shader using these functions still needs to explicitly enable the
 * extension with <code>#extension GL_EXT_frag_depth : enable</code>.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/webgl/extensions/EXT_frag_depth/'>EXT_frag_depth</a>
 */
@property (readonly) BOOL fragmentDepth;

/**
 * <code>true</code> if the WEBGL_draw_buffers extension is supported. This
 * extensions provides support for multiple render targets. The framebuffer object can have mutiple
 * color attachments and the GLSL fragment shader can write to the built-in output array <code>gl_FragData</code>.
 * A shader using this feature needs to explicitly enable the extension with
 * <code>#extension GL_EXT_draw_buffers : enable</code>.
 * @memberof Context.prototype
 * @type {Boolean}
 * @see <a href='http://www.khronos.org/registry/webgl/extensions/WEBGL_draw_buffers/'>WEBGL_draw_buffers</a>
 */
@property (readonly) BOOL drawBuffers;

/**
 * The maximum number of simultaneous outputs that may be written in a fragment shader.
 * @memberof Context.prototype
 * @type {Number}
 */
@property (readonly) UInt32 maximumDrawBuffers;

/**
 * The maximum number of color attachments supported.
 * @memberof Context.prototype
 * @type {Number}
 */
@property (readonly) UInt32 maximumColorAttachments;

@property (nonatomic) CSCartesian4 *clearColor;
@property (readonly) GLfloat clearDepth;
@property (readonly) GLint clearStencil;

@property (readonly) CSUniformState *uniformState;
@property (readonly) CSPassState *passState;
@property (readonly) CSRenderState *renderState;
    
@property (readonly) CSPassState *defaultPassState;
@property (readonly) CSRenderState *defaultRenderState;

/**
 * A 1x1 RGBA texture initialized to [255, 255, 255, 255].  This can
 * be used as a placeholder texture while other textures are downloaded.
 * @memberof Context.prototype
 * @type {Texture}
 */
@property (readonly) CSTexture *defaultTexture;

/**
 * A cube map, where each face is a 1x1 RGBA texture initialized to
 * [255, 255, 255, 255].  This can be used as a placeholder cube map while
 * other cube maps are downloaded.
 * @memberof Context.prototype
 * @type {CubeMap}
 */
@property (readonly) CSCubeMap *defaultCubeMap;

/**
 * A cache of objects tied to this context.  Just before the Context is destroyed,
 * <code>destroy</code> will be invoked on each object in this object literal that has
 * such a method.  This is useful for caching any objects that might otherwise
 * be stored globally, except they're tied to a particular context, and to manage
 * their lifetime.
 *
 * @private
 * @type {Object}
 */
@property (nonatomic) NSMutableArray *cache;

/**
 * The drawingBufferWidth of the underlying GL context.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='https://www.khronos.org/registry/webgl/specs/1.0/#DOM-WebGLRenderingContext-drawingBufferWidth'>drawingBufferWidth</a>
 */
@property (readonly) UInt32 drawingBufferHeight;

/**
 * The drawingBufferHeight of the underlying GL context.
 * @memberof Context.prototype
 * @type {Number}
 * @see <a href='https://www.khronos.org/registry/webgl/specs/1.0/#DOM-WebGLRenderingContext-drawingBufferHeight'>drawingBufferHeight</a>
 */
@property (readonly) UInt32 drawingBufferWidth;


-(id)initWithGLKView:(GLKView *)glView;

/**
 * Creates a shader program given the GLSL source for a vertex and fragment shader.
 * <br /><br />
 * The vertex and fragment shader are individually compiled, and then linked together
 * to create a shader program.  An exception is thrown if any errors are encountered,
 * as described below.
 * <br /><br />
 * The program's active uniforms and attributes are queried and can be accessed using
 * the returned shader program.  The caller can explicitly define the vertex
 * attribute indices using the optional <code>attributeLocations</code> argument as
 * shown in example two below.
 *
 * @memberof Context
 *
 * @param {String} vertexShaderSource The GLSL source for the vertex shader.
 * @param {String} fragmentShaderSource The GLSL source for the fragment shader.
 * @param {Object} [attributeLocations=undefined] An optional object that maps vertex attribute names to indices for use with vertex arrays.
 *
 * @returns {ShaderProgram} The compiled and linked shader program, ready for use in a draw call.
 *
 * @exception {RuntimeError} Vertex shader failed to compile.
 * @exception {RuntimeError} Fragment shader failed to compile.
 * @exception {RuntimeError} Program failed to link.
 *
 * @see Context#draw
 * @see Context#createVertexArray
 * @see Context#getShaderCache
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glCreateShader.xml'>glCreateShader</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glShaderSource.xml'>glShaderSource</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glCompileShader.xml'>glCompileShader</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glCreateProgram.xml'>glCreateProgram</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glAttachShader.xml'>glAttachShader</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glLinkProgram.xml'>glLinkProgram</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetShaderiv.xml'>glGetShaderiv</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetActiveUniform.xml'>glGetActiveUniform</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetUniformLocation.xml'>glGetUniformLocation</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetUniform.xml'>glGetUniform</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glBindAttribLocation.xml'>glBindAttribLocation</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetActiveAttrib.xml'>glGetActiveAttrib</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGetAttribLocation.xml'>glGetAttribLocation</a>
 *
 * @example
 * // Example 1. Create a shader program allowing the GL to determine
 * // attribute indices.
 * var vs = 'attribute vec4 position; void main() { gl_Position = position; }';
 * var fs = 'void main() { gl_FragColor = vec4(1.0); }';
 * var sp = context.createShaderProgram(vs, fs);
 *
 * ////////////////////////////////////////////////////////////////////////////////
 *
 * // Example 2. Create a shader program with explicit attribute indices.
 * var vs = 'attribute vec4 position;' +
 *          'attribute vec3 normal;' +
 *          'void main() { ... }';
 * var fs = 'void main() { gl_FragColor = vec4(1.0); }';
 * var attributes = {
 *     position : 0,
 *     normal   : 1
 * };
 * sp = context.createShaderProgram(vs, fs, attributes);
 */
-(CSShaderProgram *)createShaderProgramWithVertexShader:(NSString *)vertexShaderSource fragmentShader:(NSString *)fragmentShaderSource attributeLocations:(id)attributeLocations;

/**
 * Creates a vertex buffer, which contains untyped vertex data in GPU-controlled memory.
 * <br /><br />
 * A vertex array defines the actual makeup of a vertex, e.g., positions, normals, texture coordinates,
 * etc., by interpreting the raw data in one or more vertex buffers.
 *
 * @memberof Context
 *
 * @param {ArrayBufferView|Number} typedArrayOrSizeInBytes A typed array containing the data to copy to the buffer, or a <code>Number</code> defining the size of the buffer in bytes.
 * @param {BufferUsage} usage Specifies the expected usage pattern of the buffer.  On some GL implementations, this can significantly affect performance.  See {@link BufferUsage}.
 *
 * @returns {VertexBuffer} The vertex buffer, ready to be attached to a vertex array.
 *
 * @exception {DeveloperError} The size in bytes must be greater than zero.
 * @exception {DeveloperError} Invalid <code>usage</code>.
 *
 * @see Context#createVertexArray
 * @see Context#createIndexBuffer
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGenBuffer.xml'>glGenBuffer</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glBindBuffer.xml'>glBindBuffer</a> with <code>ARRAY_BUFFER</code>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glBufferData.xml'>glBufferData</a> with <code>ARRAY_BUFFER</code>
 *
 * @example
 * // Example 1. Create a dynamic vertex buffer 16 bytes in size.
 * var buffer = context.createVertexBuffer(16, BufferUsage.DYNAMIC_DRAW);
 *
 * ////////////////////////////////////////////////////////////////////////////////
 *
 * // Example 2. Create a dynamic vertex buffer from three floating-point values.
 * // The data copied to the vertex buffer is considered raw bytes until it is
 * // interpreted as vertices using a vertex array.
 * var positionBuffer = context.createVertexBuffer(new Float32Array([0, 0, 0]),
 *     BufferUsage.STATIC_DRAW);
 */
-(CSVertexBuffer *)createVertexBufferWithData:(Float32 *)data size:(UInt32)size usage:(enum CSBufferUsage)usage;
-(CSVertexBuffer *)createVertexBufferWithSize:(UInt32)size usage:(enum CSBufferUsage)usage;

/**
 * Creates an index buffer, which contains typed indices in GPU-controlled memory.
 * <br /><br />
 * An index buffer can be attached to a vertex array to select vertices for rendering.
 * <code>Context.draw</code> can render using the entire index buffer or a subset
 * of the index buffer defined by an offset and count.
 *
 * @memberof Context
 *
 * @param {ArrayBufferView|Number} typedArrayOrSizeInBytes A typed array containing the data to copy to the buffer, or a <code>Number</code> defining the size of the buffer in bytes.
 * @param {BufferUsage} usage Specifies the expected usage pattern of the buffer.  On some GL implementations, this can significantly affect performance.  See {@link BufferUsage}.
 * @param {IndexDatatype} indexDatatype The datatype of indices in the buffer.
 *
 * @returns {IndexBuffer} The index buffer, ready to be attached to a vertex array.
 *
 * @exception {RuntimeError} IndexDatatype.UNSIGNED_INT requires OES_element_index_uint, which is not supported on this system.
 * @exception {DeveloperError} The size in bytes must be greater than zero.
 * @exception {DeveloperError} Invalid <code>usage</code>.
 * @exception {DeveloperError} Invalid <code>indexDatatype</code>.
 *
 * @see Context#createVertexArray
 * @see Context#createVertexBuffer
 * @see Context#draw
 * @see VertexArray
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glGenBuffer.xml'>glGenBuffer</a>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glBindBuffer.xml'>glBindBuffer</a> with <code>ELEMENT_ARRAY_BUFFER</code>
 * @see <a href='http://www.khronos.org/opengles/sdk/2.0/docs/man/glBufferData.xml'>glBufferData</a> with <code>ELEMENT_ARRAY_BUFFER</code>
 *
 * @example
 * // Example 1. Create a stream index buffer of unsigned shorts that is
 * // 16 bytes in size.
 * var buffer = context.createIndexBuffer(16, BufferUsage.STREAM_DRAW,
 *     IndexDatatype.UNSIGNED_SHORT);
 *
 * ////////////////////////////////////////////////////////////////////////////////
 *
 * // Example 2. Create a static index buffer containing three unsigned shorts.
 * var buffer = context.createIndexBuffer(new Uint16Array([0, 1, 2]),
 *     BufferUsage.STATIC_DRAW, IndexDatatype.UNSIGNED_SHORT)
 */
-(CSVertexBuffer *)createIndexBufferWithData:(void *)data size:(UInt32)size usage:(enum CSBufferUsage)usage indexDataType:(enum CSIndexDataType)indexDataType;
-(CSVertexBuffer *)createIndexBufferWithSize:(UInt32)size usage:(enum CSBufferUsage)usage indexDataType:(enum CSIndexDataType)indexDataType;

@end

