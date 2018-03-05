//
//  PrimitiveCollection.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
 * A collection of primitives.  This is most often used with {@link Scene#primitives},
 * but <code>PrimitiveCollection</code> is also a primitive itself so collections can
 * be added to collections forming a hierarchy.
 *
 * @alias PrimitiveCollection
 * @constructor
 *
 * @param {Object} [options] Object with the following properties:
 * @param {Boolean} [options.show=true] Determines if the primitives in the collection will be shown.
 * @param {Boolean} [options.destroyPrimitives=true] Determines if primitives in the collection are destroyed when they are removed.
 *
 * @example
 * var billboards = new Cesium.BillboardCollection();
 * var labels = new Cesium.LabelCollection();
 *
 * var collection = new Cesium.PrimitiveCollection();
 * collection.add(billboards);
 *
 * scene.primitives.add(collection);  // Add collection
 * scene.primitives.add(labels);      // Add regular primitive
 */

open class PrimitiveCollection: Primitive {

    let guid: String

    fileprivate var _primitives = [Primitive]()

    override init () {
        guid = UUID().uuidString
    }
    /*

this._primitives = [];
this._guid = createGuid();

/**
* Determines if primitives in this collection will be shown.
*
* @type {Boolean}
* @default true
*/
this.show = defaultValue(options.show, true);

/**
* Determines if primitives in the collection are destroyed when they are removed by
* {@link PrimitiveCollection#destroy} or  {@link PrimitiveCollection#remove} or implicitly
* by {@link PrimitiveCollection#removeAll}.
*
* @type {Boolean}
* @default true
*
* @example
* // Example 1. Primitives are destroyed by default.
* var primitives = new Cesium.PrimitiveCollection();
* var labels = primitives.add(new Cesium.LabelCollection());
* primitives = primitives.destroy();
* var b = labels.isDestroyed(); // true
*
* @example
* // Example 2. Do not destroy primitives in a collection.
* var primitives = new Cesium.PrimitiveCollection();
* primitives.destroyPrimitives = false;
* var labels = primitives.add(new Cesium.LabelCollection());
* primitives = primitives.destroy();
* var b = labels.isDestroyed(); // false
* labels = labels.destroy();    // explicitly destroy
*/
this.destroyPrimitives = defaultValue(options.destroyPrimitives, true);
};

defineProperties(PrimitiveCollection.prototype, {
/**
* Gets the number of primitives in the collection.
*
* @memberof PrimitiveCollection.prototype
*
* @type {Number}
* @readonly
*/
length : {
get : function() {
return this._primitives.length;
}
}
});
*/
/**
* Adds a primitive to the collection.
*
* @param {Object} primitive The primitive to add.
* @returns {Object} The primitive added to the collection.
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @example
* var billboards = scene.primitives.add(new Cesium.BillboardCollection());
*/
    open func add (_ primitive: Primitive) -> Primitive {
        /*
         var external = (primitive._external = primitive._external || {});
         var composites = (external._composites = external._composites || {});
         composites[this._guid] = {
         collection : this
         };
         */
        _primitives.append(primitive)

        return primitive
    }
/*
/**
* Removes a primitive from the collection.
*
* @param {Object} [primitive] The primitive to remove.
* @returns {Boolean} <code>true</code> if the primitive was removed; <code>false</code> if the primitive is <code>undefined</code> or was not found in the collection.
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#destroyPrimitives
*
* @example
* var billboards = scene.primitives.add(new Cesium.BillboardCollection());
* scene.primitives.remove(p);  // Returns true
*/
PrimitiveCollection.prototype.remove = function(primitive) {
// PERFORMANCE_IDEA:  We can obviously make this a lot faster.
if (this.contains(primitive)) {
var index = this._primitives.indexOf(primitive);
if (index !== -1) {
this._primitives.splice(index, 1);

delete primitive._external._composites[this._guid];

if (this.destroyPrimitives) {
primitive.destroy();
}

return true;
}
// else ... this is not possible, I swear.
}

return false;
};
*/
/**
* Removes all primitives in the collection.
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#destroyPrimitives
*/
    open func removeAll () {
        _primitives.removeAll()
    }
/*
/**
* Determines if this collection contains a primitive.
*
* @param {Object} [primitive] The primitive to check for.
* @returns {Boolean} <code>true</code> if the primitive is in the collection; <code>false</code> if the primitive is <code>undefined</code> or was not found in the collection.
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#get
*/
PrimitiveCollection.prototype.contains = function(primitive) {
return !!(defined(primitive) &&
primitive._external &&
primitive._external._composites &&
primitive._external._composites[this._guid]);
};

function getPrimitiveIndex(compositePrimitive, primitive) {
//>>includeStart('debug', pragmas.debug);
if (!compositePrimitive.contains(primitive)) {
throw new DeveloperError('primitive is not in this collection.');
}
//>>includeEnd('debug');

return compositePrimitive._primitives.indexOf(primitive);
}

/**
* Raises a primitive "up one" in the collection.  If all primitives in the collection are drawn
* on the globe surface, this visually moves the primitive up one.
*
* @param {Object} [primitive] The primitive to raise.
*
* @exception {DeveloperError} primitive is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#raiseToTop
* @see PrimitiveCollection#lower
* @see PrimitiveCollection#lowerToBottom
*/
PrimitiveCollection.prototype.raise = function(primitive) {
if (defined(primitive)) {
var index = getPrimitiveIndex(this, primitive);
var primitives = this._primitives;

if (index !== primitives.length - 1) {
var p = primitives[index];
primitives[index] = primitives[index + 1];
primitives[index + 1] = p;
}
}
};

/**
* Raises a primitive to the "top" of the collection.  If all primitives in the collection are drawn
* on the globe surface, this visually moves the primitive to the top.
*
* @param {Object} [primitive] The primitive to raise the top.
*
* @exception {DeveloperError} primitive is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#raise
* @see PrimitiveCollection#lower
* @see PrimitiveCollection#lowerToBottom
*/
PrimitiveCollection.prototype.raiseToTop = function(primitive) {
if (defined(primitive)) {
var index = getPrimitiveIndex(this, primitive);
var primitives = this._primitives;

if (index !== primitives.length - 1) {
// PERFORMANCE_IDEA:  Could be faster
primitives.splice(index, 1);
primitives.push(primitive);
}
}
};

/**
* Lowers a primitive "down one" in the collection.  If all primitives in the collection are drawn
* on the globe surface, this visually moves the primitive down one.
*
* @param {Object} [primitive] The primitive to lower.
*
* @exception {DeveloperError} primitive is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#lowerToBottom
* @see PrimitiveCollection#raise
* @see PrimitiveCollection#raiseToTop
*/
PrimitiveCollection.prototype.lower = function(primitive) {
if (defined(primitive)) {
var index = getPrimitiveIndex(this, primitive);
var primitives = this._primitives;

if (index !== 0) {
var p = primitives[index];
primitives[index] = primitives[index - 1];
primitives[index - 1] = p;
}
}
};

/**
* Lowers a primitive to the "bottom" of the collection.  If all primitives in the collection are drawn
* on the globe surface, this visually moves the primitive to the bottom.
*
* @param {Object} [primitive] The primitive to lower to the bottom.
*
* @exception {DeveloperError} primitive is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#lower
* @see PrimitiveCollection#raise
* @see PrimitiveCollection#raiseToTop
*/
PrimitiveCollection.prototype.lowerToBottom = function(primitive) {
if (defined(primitive)) {
var index = getPrimitiveIndex(this, primitive);
var primitives = this._primitives;

if (index !== 0) {
// PERFORMANCE_IDEA:  Could be faster
primitives.splice(index, 1);
primitives.unshift(primitive);
}
}
};

/**
* Returns the primitive in the collection at the specified index.
*
* @param {Number} index The zero-based index of the primitive to return.
* @returns {Object} The primitive at the <code>index</code>.
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see PrimitiveCollection#length
*
* @example
* // Toggle the show property of every primitive in the collection.
* var primitives = scene.primitives;
* var length = primitives.length;
* for (var i = 0; i < length; ++i) {
*   var p = primitives.get(i);
*   p.show = !p.show;
* }
*/
PrimitiveCollection.prototype.get = function(index) {
//>>includeStart('debug', pragmas.debug);
if (!defined(index)) {
throw new DeveloperError('index is required.');
}
//>>includeEnd('debug');

return this._primitives[index];
};
*/
/**
* @private
*/
    override func update (_ frameState: inout FrameState) {
        if !show {
            return
        }

        for primitive in _primitives {
            primitive.update(&frameState)

        }
    }
}
