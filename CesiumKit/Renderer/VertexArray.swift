//
//  VertexArray.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Metal

class VertexArray {
    
    //let vertexBuffers: [Buffer]
    
    var attributes: [VertexAttributes]
    
    var vertexCount: Int
    
    let indexBuffer: Buffer?
    
    let indexType: MTLIndexType
    
    
    var numberOfIndices: Int {
        return indexBuffer == nil ? 0 : indexBuffer!.length / indexBuffer!.componentDatatype.elementSize
    }
    
    init(attributes: [VertexAttributes], vertexCount: Int, indexType: MTLIndexType = .UInt16, indexBuffer: Buffer? = nil) {
        self.attributes = attributes
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
    convenience init(fromGeometry geometry: Geometry, context: Context, attributeLocations: [String: Int], interleave: Bool = false) {
        
        /*
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
        //let vertexAttributes = GeometryPipeline.createAttributeLocations(geometry)
        var vertexCount = 0
        var vertexAttributes = [VertexAttributes]()
        if (interleave) {
            // Use a single vertex buffer with interleaved vertices.
            if let interleavedAttributes = VertexArray.interleaveAttributes(context, attributes: geometry.attributes) {
                let vertexBuffer = interleavedAttributes.buffer
                let offsetsInBytes = interleavedAttributes.offsetsInBytes
                //var strideInBytes = interleavedAttributes.vertexSizeInBytes
                var vaCount = 0

                for geometryAttribute in geometry.attributes {
                    
                    /*guard let geometryAttribute = geometry.attributes[i] else {
                        continue
                    }*/
                    
                    if geometryAttribute.values != nil {
                        // Common case: per-vertex attributes
                        vertexAttributes.append(VertexAttributes(
                            buffer: vaCount == 0 ? vertexBuffer : nil,
                            bufferIndex: 1,
                            index: vaCount,
                            format: geometryAttribute.componentDatatype.toVertexType(geometryAttribute.componentsPerAttribute),
                            offset: offsetsInBytes[vaCount],
                            size: geometryAttribute.size,
                            normalize: geometryAttribute.normalize
                        ))
                        vaCount++
                    } else {
                        // Constant attribute for all vertices
                        assertionFailure("unimplemented")
                        /*vaAttributes.push({
                        index : attributeLocations[name],
                        value : attribute.value,
                        componentDatatype : attribute.componentDatatype,
                        normalize : attribute.normalize
                        });
                        }*/
                    }
                }
            }
        } else {
            // One vertex buffer per attribute.
            var vaCount = 0
            for geometryAttribute in geometry.attributes {
                
                var componentDatatype = geometryAttribute.componentDatatype
                if componentDatatype == .Float64 {
                    componentDatatype = .Float32
                }
                
                let vertexBuffer = geometryAttribute.values
                if let vertexBuffer = vertexBuffer {
                    vertexCount = max(vertexCount, vertexBuffer.count)
                }
                
                vertexAttributes.append(VertexAttributes(
                    buffer: vertexBuffer,
                    bufferIndex: vaCount+1, // uniform buffer is [0]
                    index: 0,
                    format: componentDatatype.toVertexType(geometryAttribute.componentsPerAttribute),
                    offset: 0,
                    size: geometryAttribute.size,
                    normalize: geometryAttribute.normalize
                    )
                )
                vaCount++
            }
        }
        let indexBuffer: Buffer?
        let indices = geometry.indices
        if indices != nil {
            if indices!.count < Math.SixtyFourKilobytes {
                let indicesShort = indices!.map({ UInt16($0) })
                indexBuffer = Buffer(
                    device: context.device,
                    array: indicesShort,
                    componentDatatype: ComponentDatatype.UnsignedShort,
                    sizeInBytes: indicesShort.sizeInBytes)
            } else {
                let indicesInt = indices!.map({ UInt32($0) })
                indexBuffer = Buffer(
                    device: context.device,
                    array: indicesInt,
                    componentDatatype: ComponentDatatype.UnsignedInt,
                    sizeInBytes: indicesInt.sizeInBytes)
            }
        } else {
            indexBuffer = nil
        }
        self.init(attributes: vertexAttributes, vertexCount: vertexCount, indexBuffer: indexBuffer)
    }
    
    class func computeNumberOfVertices(attribute: GeometryAttribute) -> Int {
        guard let values = attribute.values else {
            return 0
        }
        return values.count / attribute.componentsPerAttribute
    }
    
    class func interleaveAttributes(context: Context, attributes: GeometryAttributes) -> (
        buffer : Buffer,
        offsetsInBytes : [Int],
        vertexSizeInBytes : Int
        )? {
            
            // Extract attribute names.
            var attributeIndices = [Int]()
            for (i, geometryAttribute) in attributes.enumerate() {
                
                // Attribute needs to have per-vertex values; not a constant value for all vertices.
                attributeIndices.append(i)
                
                if (geometryAttribute.componentDatatype == ComponentDatatype.Float64) {
                    geometryAttribute.componentDatatype = ComponentDatatype.Float32
                    var doubleArray = [Double](count: geometryAttribute.vertexCount, repeatedValue: 0.0)
                    let geometryArraySize = geometryAttribute.vertexArraySize
                    doubleArray.withUnsafeMutableBufferPointer({ (inout pointer: UnsafeMutableBufferPointer<Double>) in
                        memcpy(pointer.baseAddress, geometryAttribute.values!.data, geometryArraySize)
                    })
                    geometryAttribute.values = Buffer(device: context.device, array: doubleArray.map({ Float($0) }), componentDatatype: .Float32, sizeInBytes: doubleArray.count * strideof(Float))
                }
            }
            
            // Validation.  Compute number of vertices.
            var numberOfVertices = 0
            
            if (attributeIndices.count > 0) {
                numberOfVertices = VertexArray.computeNumberOfVertices(attributes[attributeIndices.first!]!)
                
                for j in 1..<attributeIndices.count {
                    let currentNumberOfVertices = computeNumberOfVertices(attributes[attributeIndices[j]]!)
                    
                    assert(currentNumberOfVertices == numberOfVertices, "Each attribute list must have the same number of vertices.")
                }
            }
            
            // Sort attributes by the size of their components.  From left to right, a vertex stores floats, shorts, and then bytes.
            attributeIndices.sortInPlace({ a, b in
                return attributes[a]!.componentDatatype.elementSize > attributes[b]!.componentDatatype.elementSize
            })
            // Compute sizes and strides.
            var vertexSizeInBytes = 0
            var offsetsInBytes = [Int]()
            
            for index in attributeIndices {
                let attribute = attributes[index]!
                offsetsInBytes.append(vertexSizeInBytes)
                vertexSizeInBytes += attribute.size
            }
            
            if (vertexSizeInBytes > 0) {
                // Pad each vertex to be a multiple of the largest component datatype so each
                // attribute can be addressed using typed arrays.
                let maxComponentSizeInBytes = attributes[attributeIndices.first!]!.componentDatatype.elementSize // Sorted large to small
                let remainder = vertexSizeInBytes % maxComponentSizeInBytes
                if remainder != 0 {
                    vertexSizeInBytes += maxComponentSizeInBytes - remainder
                }
                
                // Total vertex buffer size in bytes, including per-vertex padding.
                let vertexBufferSizeInBytes = numberOfVertices * vertexSizeInBytes
                
                // Create array for interleaved vertices.  Each attribute has a different view (pointer) into the array.
                let buffer = Buffer(
                    device: context.device,
                    array: nil,
                    componentDatatype: .Float32,
                    sizeInBytes: vertexBufferSizeInBytes)
                for i in 0..<numberOfVertices {
                    var attributeIndex = 0
                    for index in attributeIndices {
                        let attribute = attributes[index]!
                        //let array = attribute.values as! [UInt8]
                        let elementSize = attribute.size
                        let source = attribute.values!.data
                        let target = buffer.data
                        let sourceOffset = i * elementSize
                        let targetOffset = i * vertexSizeInBytes + attributeIndex
                        
                        memcpy(target+targetOffset, source+sourceOffset, elementSize)
                        attributeIndex += elementSize
                    }
                }
                let vertexBuffer = buffer
                
                /*
                var views = {};
                
                for (j = 0; j < namesLength; ++j) {
                name = names[j];
                var sizeInBytes = ComponentDatatype.getSizeInBytes(attributes[name].componentDatatype);
                
                views[name] = {
                pointer : ComponentDatatype.createTypedArray(attributes[name].componentDatatype, buffer),
                index : offsetsInBytes[name] / sizeInBytes, // Offset in ComponentType
                strideInComponentType : vertexSizeInBytes / sizeInBytes
                };
                }
                
                // Copy attributes into one interleaved array.
                // PERFORMANCE_IDEA:  Can we optimize these loops?
                for (j = 0; j < numberOfVertices; ++j) {
                for ( var n = 0; n < namesLength; ++n) {
                name = names[n];
                attribute = attributes[name];
                var values = attribute.values;
                var view = views[name];
                var pointer = view.pointer;
                
                var numberOfComponents = attribute.componentsPerAttribute;
                for ( var k = 0; k < numberOfComponents; ++k) {
                pointer[view.index + k] = values[(j * numberOfComponents) + k];
                }
                
                view.index += view.strideInComponentType;
                }
                }*/
                
                return (
                    buffer : vertexBuffer,
                    offsetsInBytes : offsetsInBytes,
                    vertexSizeInBytes : vertexSizeInBytes
                )
            }
            
            // No attributes to interleave.
            return nil
    }
    
}

