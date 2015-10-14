//
//  VertexArray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

class VertexArray {
    
    let vertexBuffers: [Buffer]
    
    let attributes: [VertexAttributes]
    
    var vertexCount: Int
    
    let indexBuffer: Buffer?
    
    let indexType: MTLIndexType
    
    
    var numberOfIndices: Int {
        return indexBuffer == nil ? 0 : indexBuffer!.length / indexBuffer!.componentDatatype.elementSize
    }
    
    init(buffers: [Buffer], attributes: [VertexAttributes], vertexCount: Int, indexType: MTLIndexType = .UInt16, indexBuffer: Buffer? = nil) {
        self.vertexBuffers = buffers
        self.attributes = vertexAttributes
        self.vertexCount = vertexCount
        self.indexType = indexType
        self.indexBuffer = indexBuffer
    }
    
    /**
    * Creates a vertex array from a geometry.  A geometry contains vertex attributes and optional index data
    * in system memory, whereas a vertex array contains vertex buffers and an optional index buffer in WebGL
    * memory for use with rendering.
    * <br /><br />
    * The <code>geometry</code> argument should use the standard layout like the geometry returned by {@link BoxGeometry}.
    * <br /><br />
    * <code>options</code> can have four properties:
    * <ul>
    *   <li><code>geometry</code>:  The source geometry containing data used to create the vertex array.</li>
    *   <li><code>attributeLocations</code>:  An object that maps geometry attribute names to vertex shader attribute locations.</li>
    *   <li><code>bufferUsage</code>:  The expected usage pattern of the vertex array's buffers.  On some WebGL implementations, this can significantly affect performance.  See {@link BufferUsage}.  Default: <code>BufferUsage.DYNAMIC_DRAW</code>.</li>
    *   <li><code>interleave</code>:  Determines if all attributes are interleaved in a single vertex buffer or if each attribute is stored in a separate vertex buffer.  Default: <code>false</code>.</li>
    * </ul>
    * <br />
    * If <code>options</code> is not specified or the <code>geometry</code> contains no data, the returned vertex array is empty.
    *
    * @param {Object} options An object defining the geometry, attribute indices, buffer usage, and vertex layout used to create the vertex array.
    *
    * @exception {RuntimeError} Each attribute list must have the same number of vertices.
    * @exception {DeveloperError} The geometry must have zero or one index lists.
    * @exception {DeveloperError} Index n is used by more than one attribute.
    *
    * @see Buffer#createVertexBuffer
    * @see Buffer#createIndexBuffer
    * @see GeometryPipeline.createAttributeLocations
    * @see ShaderProgram
    *
    * @example
    * // Example 1. Creates a vertex array for rendering a box.  The default dynamic draw
    * // usage is used for the created vertex and index buffer.  The attributes are not
    * // interleaved by default.
    * var geometry = new BoxGeometry();
    * var va = VertexArray.fromGeometry({
    *     context            : context,
    *     geometry           : geometry,
    *     attributeLocations : GeometryPipeline.createAttributeLocations(geometry),
    * });
    *
    * @example
    * // Example 2. Creates a vertex array with interleaved attributes in a
    * // single vertex buffer.  The vertex and index buffer have static draw usage.
    * var va = VertexArray.fromGeometry({
    *     context            : context,
    *     geometry           : geometry,
    *     attributeLocations : GeometryPipeline.createAttributeLocations(geometry),
    *     bufferUsage        : BufferUsage.STATIC_DRAW,
    *     interleave         : true
    * });
    *
    * @example
    * // Example 3.  When the caller destroys the vertex array, it also destroys the
    * // attached vertex buffer(s) and index buffer.
    * va = va.destroy();
    */
    convenience init(fromGeometry geometry: Geometry, interleave: Bool = false) {
        
        
        /*var context = options.context;
        var geometry = defaultValue(options.geometry, defaultValue.EMPTY_OBJECT);
        
        var bufferUsage = defaultValue(options.bufferUsage, BufferUsage.DYNAMIC_DRAW);
        
        var attributeLocations = defaultValue(options.attributeLocations, defaultValue.EMPTY_OBJECT);
        var interleave = defaultValue(options.interleave, false);
        var createdVAAttributes = options.vertexArrayAttributes;
        
        var name;
        var attribute;
        var vertexBuffer;
        var vaAttributes = (defined(createdVAAttributes)) ? createdVAAttributes : [];*/
        //let attributes = geometry.attributes
        let vertexAttributes = GeometryPipeline.createAttributeLocations(geometry)
        
        if (interleave) {
            // Use a single vertex buffer with interleaved vertices.
            /*var interleavedAttributes = interleaveAttributes(attributes);
            if (defined(interleavedAttributes)) {
            vertexBuffer = Buffer.createVertexBuffer({
            context : context,
            typedArray : interleavedAttributes.buffer,
            usage : bufferUsage
            });
            var offsetsInBytes = interleavedAttributes.offsetsInBytes;
            var strideInBytes = interleavedAttributes.vertexSizeInBytes;
            
            for (name in attributes) {
            if (attributes.hasOwnProperty(name) && defined(attributes[name])) {
            attribute = attributes[name];
            
            if (defined(attribute.values)) {
            // Common case: per-vertex attributes
            vaAttributes.push({
            index : attributeLocations[name],
            vertexBuffer : vertexBuffer,
            componentDatatype : attribute.componentDatatype,
            componentsPerAttribute : attribute.componentsPerAttribute,
            normalize : attribute.normalize,
            offsetInBytes : offsetsInBytes[name],
            strideInBytes : strideInBytes
            });
            } else {
            // Constant attribute for all vertices
            vaAttributes.push({
            index : attributeLocations[name],
            value : attribute.value,
            componentDatatype : attribute.componentDatatype,
            normalize : attribute.normalize
            });
            }
            }
            }
            }*/
        } else {
            // One vertex buffer per attribute.
            for attribute in attributes {
                /*if (attributes.hasOwnProperty(name) && defined(attributes[name])) {
                attribute = attributes[name];
                
                var componentDatatype = attribute.componentDatatype;
                if (componentDatatype === ComponentDatatype.DOUBLE) {
                componentDatatype = ComponentDatatype.FLOAT;
                }
                
                vertexBuffer = undefined;
                if (defined(attribute.values)) {
                vertexBuffer = Buffer.createVertexBuffer({
                context : context,
                typedArray : ComponentDatatype.createTypedArray(componentDatatype, attribute.values),
                usage : bufferUsage
                });
                }
                
                vaAttributes.push({
                index : attributeLocations[name],
                vertexBuffer : vertexBuffer,
                value : attribute.value,
                componentDatatype : componentDatatype,
                componentsPerAttribute : attribute.componentsPerAttribute,
                normalize : attribute.normalize
                });
                }*/
            }
        }
        /*
        var indexBuffer;
        var indices = geometry.indices;
        if (defined(indices)) {
        if ((Geometry.computeNumberOfVertices(geometry) > CesiumMath.SIXTY_FOUR_KILOBYTES) && context.elementIndexUint) {
        indexBuffer = Buffer.createIndexBuffer({
        context : context,
        typedArray : new Uint32Array(indices),
        usage : bufferUsage,
        indexDatatype : IndexDatatype.UNSIGNED_INT
        });
        } else{
        indexBuffer = Buffer.createIndexBuffer({
        context : context,
        typedArray : new Uint16Array(indices),
        usage : bufferUsage,
        indexDatatype : IndexDatatype.UNSIGNED_SHORT
        });
        }
    }*/
    
    self.init(vertexAttributes: vertexAttributes, vertexCount: 0)
    //    attributes : vaAttributes,
    //  indexBuffer : indexBuffer
    // }
    }
    
    
}

