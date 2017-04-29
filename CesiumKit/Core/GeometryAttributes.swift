//
//  GeometryAttributes.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 21/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* Attributes, which make up a geometry's vertices.  Each property in this object corresponds to a
* {@link GeometryAttribute} containing the attribute's data.
* <p>
* Attributes are always stored non-interleaved in a Geometry.
* </p>
*
* @alias GeometryAttributes
* @constructor
*/
class GeometryAttributes {
    
    fileprivate var _maxAttributes = 6
    
    fileprivate var _attributes = [String: GeometryAttribute]()
    
    /**
    * The 3D position attribute.
    * <p>
    * 64-bit floating-point (for precision).  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var position: GeometryAttribute? {
        get {
            return _attributes["position"]
        }
        set (position) {
            position?.name = "position"
            _attributes["position"] = position
        }
    }
    
    /**
    * The normal attribute (normalized), which is commonly used for lighting.
    * <p>
    * 32-bit floating-point.  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var normal: GeometryAttribute? {
        get {
            return _attributes["normal"]
        }
        set (normal) {
            normal?.name = "normal"
            _attributes["normal"] = normal
        }
    }
    
    /**
    * The 2D texture coordinate attribute.
    * <p>
    * 32-bit floating-point.  2 components per attribute
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
     var st: GeometryAttribute? {
        get {
            return _attributes["st"]
        }
        set (st) {
            st?.name = "st"
            _attributes["st"] = st
        }
    }
    
    /**
    * The tangent attribute (normalized), which is used for tangent-space effects like bump mapping.
    * <p>
    * 32-bit floating-point.  3 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var tangent: GeometryAttribute? {
        get {
            return _attributes["tangent"]
        }
        set (tangent) {
            tangent?.name = "tangent"
            _attributes["tangent"] = tangent
        }
    }
    
    /**
     * The bitangent attribute (normalized), which is used for tangent-space effects like bump mapping.
     * <p>
     * 32-bit floating-point.  3 components per attribute.
     * </p>
     *
     * @type GeometryAttribute
     *
     * @default undefined
     */
    var bitangent: GeometryAttribute? {
        get {
            return _attributes["bitangent"]
        }
        set (bitangent) {
            bitangent?.name = "bitangent"
            _attributes["bitangent"] = bitangent
        }
    }
    
    /**
    * The color attribute.
    * <p>
    * 8-bit unsigned integer. 4 components per attribute.
    * </p>
    *
    * @type GeometryAttribute
    *
    * @default undefined
    */
    var color: GeometryAttribute? {
        get {
            return _attributes["color"]
        }
        set (color) {
            color?.name = "color"
            _attributes["color"] = color
        }
    }
    
    init(
        position: GeometryAttribute? = nil,
        normal: GeometryAttribute? = nil,
        st: GeometryAttribute? = nil,
        binormal: GeometryAttribute? = nil,
        tangent: GeometryAttribute? = nil,
        color: GeometryAttribute? = nil) {
            _attributes["position"] = position
            _attributes["normal"] = normal
            _attributes["st"] = st
            _attributes["tangent"] = tangent
            _attributes["bitangent"] = bitangent
            _attributes["color"] = color
            for (name, attribute) in _attributes {
                attribute.name = name
            }
    }
    
    subscript(index: Int) -> GeometryAttribute? {
        switch index {
        case 0:
            return position
        case 1:
            return normal
        case 2:
            return st
        case 3:
            return tangent
        case 4:
            return bitangent
        case 5:
            return color
        default:
            assert(false, "invalid attribute")
            return nil
        }
    }
    
    subscript(name: String) -> GeometryAttribute? {
        return _attributes[name]
    }

}

extension GeometryAttributes: Sequence {
    
    typealias Iterator = AnyIterator<GeometryAttribute>
    
    func makeIterator() -> Iterator {
        var index = 0
        return AnyIterator {
            while index < self._maxAttributes {
                let attribute = self[index]
                index += 1
                if attribute != nil {
                    return attribute
                }
            }
            return nil
        }
    }
}

