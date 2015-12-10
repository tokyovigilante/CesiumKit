//
//  GeometryAttribute.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* Values and type information for geometry attributes.  A {@link Geometry}
* generally contains one or more attributes.  All attributes together form
* the geometry's vertices.
*
* @alias GeometryAttribute
* @constructor
*
* @param {Object} [options] Object with the following properties:
* @param {ComponentDatatype} [options.componentDatatype] The datatype of each component in the attribute, e.g., individual elements in values.
* @param {Number} [options.componentsPerAttribute] A number between 1 and 4 that defines the number of components in an attributes.
* @param {Boolean} [options.normalize=false] When <code>true</code> and <code>componentDatatype</code> is an integer format, indicate that the components should be mapped to the range [0, 1] (unsigned) or [-1, 1] (signed) when they are accessed as floating-point for rendering.
* @param {Number[TypedArray]} [options.values] The values for the attributes stored in a typed array.
*
* @exception {DeveloperError} options.componentsPerAttribute must be between 1 and 4.
*
* @see Geometry
*
* @example
* var geometry = new Cesium.Geometry({
*   attributes : {
*     position : new Cesium.GeometryAttribute({
*       componentDatatype : Cesium.ComponentDatatype.FLOAT,
*       componentsPerAttribute : 3,
*       values : new Float32Array([
*         0.0, 0.0, 0.0,
*         7500000.0, 0.0, 0.0,
*         0.0, 7500000.0, 0.0
*       ]
*     })
*   },
*   primitiveType : Cesium.PrimitiveType.LINE_LOOP
* });
*/

class GeometryAttribute {
    
    /**
    * The datatype of each component in the attribute, e.g., individual elements in
    * {@link GeometryAttribute#values}.
    *
    * @type ComponentDatatype
    *
    * @default undefined
    */
    var componentDatatype: ComponentDatatype
    
    /**
    * A number between 1 and 4 that defines the number of components in an attributes.
    * For example, a position attribute with x, y, and z components would have 3 as
    * shown in the code example.
    *
    * @type Number
    *
    * @default undefined
    *
    * @example
    * attribute.componentDatatype : Cesium.ComponentDatatype.FLOAT,
    * attribute.componentsPerAttribute : 3,
    * attribute.values = new Float32Array([
    *   0.0, 0.0, 0.0,
    *   7500000.0, 0.0, 0.0,
    *   0.0, 7500000.0, 0.0
    * ]);
    */
    var componentsPerAttribute: Int {
        didSet {
            assert(componentsPerAttribute >= 1 && componentsPerAttribute <= 4,"options.componentsPerAttribute must be between 1 and 4")
        }
    }
    
    /**
    * When <code>true</code> and <code>componentDatatype</code> is an integer format,
    * indicate that the components should be mapped to the range [0, 1] (unsigned)
    * or [-1, 1] (signed) when they are accessed as floating-point for rendering.
    * <p>
    * var is commonly used when storing colors using {@link ComponentDatatype.UNSIGNED_BYTE}.
    * </p>
    *
    * @type Boolean
    *
    * @default false
    *
    * @example
    * attribute.componentDatatype : Cesium.ComponentDatatype.UNSIGNED_BYTE,
    * attribute.componentsPerAttribute : 4,
    * attribute.normalize = true;
    * attribute.values = new Uint8Array([
    *   Cesium.Color.floatToByte(color.red)
    *   Cesium.Color.floatToByte(color.green)
    *   Cesium.Color.floatToByte(color.blue)
    *   Cesium.Color.floatToByte(color.alpha)
    * ]);
    */
    var normalize: Bool = false
    
    /**
    * The values for the attributes stored in a typed array.  In the code example,
    * every three elements in <code>values</code> defines one attributes since
    * <code>componentsPerAttribute</code> is 3.
    *
    * @type Array
    *
    * @default undefined
    *
    * @example
    * attribute.componentDatatype : Cesium.ComponentDatatype.FLOAT,
    * attribute.componentsPerAttribute : 3,
    * attribute.values = new Float32Array([
    *   0.0, 0.0, 0.0,
    *   7500000.0, 0.0, 0.0,
    *   0.0, 7500000.0, 0.0
    * ]);
    */
    var values: Buffer? = nil
    
    /**
    Optional name for custom attributes
    */
    var name: String? = nil
    
    var vertexCount: Int {
        if values == nil {
            return 0
        }
        return values!.count / componentsPerAttribute
    }
    
    var vertexArraySize: Int {
        if values == nil {
            return 0
        }
        return values!.length
    }

    /**
     Gets individual attribute size in bytes.
     
     - returns: Attribute size
     */
    var size: Int {
        return componentDatatype.elementSize * componentsPerAttribute
    }
    
    init(componentDatatype: ComponentDatatype, componentsPerAttribute: Int, normalize: Bool = false, values: Buffer? = nil) {
        assert(componentsPerAttribute >= 1 && componentsPerAttribute <= 4,"options.componentsPerAttribute must be between 1 and 4")
        self.componentDatatype = componentDatatype
        self.componentsPerAttribute = componentsPerAttribute
        self.normalize = normalize
        self.values = values
    }
    
}

