//
//  ImageryLayerCollection.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 15/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* An ordered collection of imagery layers.
*
* @alias ImageryLayerCollection
* @constructor
*
* @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Imagery%20Adjustment.html|Cesium Sandcastle Imagery Adjustment Demo}
* @demo {@link http://cesiumjs.org/Cesium/Apps/Sandcastle/index.html?src=Imagery%20Layers%20Manipulation.html|Cesium Sandcastle Imagery Manipulation Demo}
*/
class ImageryLayerCollection {
    
    private var _layers = [ImageryLayer]()
    
    /**
    * An event that is raised when a layer is added to the collection.  Event handlers are passed the layer that
    * was added and the index at which it was added.
    * @type {Event}
    * @default Event()
    */
    var layerAdded = Event()
    
    /**
    * An event that is raised when a layer is removed from the collection.  Event handlers are passed the layer that
    * was removed and the index from which it was removed.
    * @type {Event}
    * @default Event()
    */
    var layerRemoved = Event()
    
    /**
    * An event that is raised when a layer changes position in the collection.  Event handlers are passed the layer that
    * was moved, its new index after the move, and its old index prior to the move.
    * @type {Event}
    * @default Event()
    */
    var layerMoved = Event()
    
    /**
    * An event that is raised when a layer is shown or hidden by setting the
    * {@link ImageryLayer#show} property.  Event handlers are passed a reference to this layer,
    * the index of the layer in the collection, and a flag that is true if the layer is now
    * shown or false if it is now hidden.
    *
    * @type {Event}
    * @default Event()
    */
    var layerShownOrHidden = Event()

    /**
    * Gets the number of layers in this collection.
    * @memberof ImageryLayerCollection.prototype
    * @type {Number}
    */
    var count: Int {
        get {
            return _layers.count
        }
    }
    
    /**
    * Adds a layer to the collection.
    *
    * @param {ImageryLayer} layer the layer to add.
    * @param {Number} [index] the index to add the layer at.  If omitted, the layer will
    *                         added on top of all existing layers.
    *
    * @exception {DeveloperError} index, if supplied, must be greater than or equal to zero and less than or equal to the number of the layers.
    */
    func add (layer: ImageryLayer, index: Int? = nil) {
        //FIXME: Unimplemented
        /*let hasIndex = index != nil
        
        if (hasIndex) {
            assert (index! >= 0, "index must be greater than or equal to zero")
            assert (index <= this._layers.length, "index must be less than or equal to the number of layers")
        }
        
        if (!hasIndex) {
            index = this._layers.length;
            this._layers.push(layer);
        } else {
            this._layers.splice(index, 0, layer);
        }
        
        this._update();
        this.layerAdded.raiseEvent(layer, index);*/
    }

    /**
    * Creates a new layer using the given ImageryProvider and adds it to the collection.
    *
    * @param {ImageryProvider} imageryProvider the imagery provider to create a new layer for.
    * @param {Number} [index] the index to add the layer at.  If omitted, the layer will
    *                         added on top of all existing layers.
    * @returns {ImageryLayer} The newly created layer.
    */
    // FIXME: ImageryProvider
    func addImageryProvider(imageryProvider: BingMapsImageryProvider, index: Int?) -> ImageryLayer {
        
        var layer = ImageryLayer(imageryProvider: imageryProvider)
        add(layer, index: index)
        return layer
    }
/*
/**
* Removes a layer from this collection, if present.
*
* @param {ImageryLayer} layer The layer to remove.
* @param {Boolean} [destroy=true] whether to destroy the layers in addition to removing them.
* @returns {Boolean} true if the layer was in the collection and was removed,
*                    false if the layer was not in the collection.
*/
ImageryLayerCollection.prototype.remove = function(layer, destroy) {
    destroy = defaultValue(destroy, true);
    
    var index = this._layers.indexOf(layer);
    if (index !== -1) {
        this._layers.splice(index, 1);
        
        this._update();
        
        this.layerRemoved.raiseEvent(layer, index);
        
        if (destroy) {
            layer.destroy();
        }
        
        return true;
    }
    
    return false;
};

/**
* Removes all layers from this collection.
*
* @param {Boolean} [destroy=true] whether to destroy the layers in addition to removing them.
*/
ImageryLayerCollection.prototype.removeAll = function(destroy) {
    destroy = defaultValue(destroy, true);
    
    var layers = this._layers;
    for ( var i = 0, len = layers.length; i < len; i++) {
        var layer = layers[i];
        this.layerRemoved.raiseEvent(layer, i);
        
        if (destroy) {
            layer.destroy();
        }
    }
    
    this._layers = [];
};

/**
* Checks to see if the collection contains a given layer.
*
* @param {ImageryLayer} layer the layer to check for.
*
* @returns {Boolean} true if the collection contains the layer, false otherwise.
*/
ImageryLayerCollection.prototype.contains = function(layer) {
    return this.indexOf(layer) !== -1;
};

/**
* Determines the index of a given layer in the collection.
*
* @param {ImageryLayer} layer The layer to find the index of.
*
* @returns {Number} The index of the layer in the collection, or -1 if the layer does not exist in the collection.
*/
ImageryLayerCollection.prototype.indexOf = function(layer) {
    return this._layers.indexOf(layer);
};
*/
    /**
    * Gets a layer by index from the collection.
    *
    * @param {Number} index the index to retrieve.
    *
    * @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
    */
    subscript(index: Int) -> ImageryLayer? {
        
        if index > _layers.count {
            return nil
        }
        return _layers[index]
    }

/*
function getLayerIndex(layers, layer) {
    //>>includeStart('debug', pragmas.debug);
    if (!defined(layer)) {
        throw new DeveloperError('layer is required.');
    }
    //>>includeEnd('debug');
    
    var index = layers.indexOf(layer);
    
    //>>includeStart('debug', pragmas.debug);
    if (index === -1) {
        throw new DeveloperError('layer is not in this collection.');
    }
    //>>includeEnd('debug');
    
    return index;
}

function swapLayers(collection, i, j) {
    var arr = collection._layers;
    i = CesiumMath.clamp(i, 0, arr.length - 1);
    j = CesiumMath.clamp(j, 0, arr.length - 1);
    
    if (i === j) {
        return;
    }
    
    var temp = arr[i];
    arr[i] = arr[j];
    arr[j] = temp;
    
    collection._update();
    
    collection.layerMoved.raiseEvent(temp, j, i);
}

/**
* Raises a layer up one position in the collection.
*
* @param {ImageryLayer} layer the layer to move.
*
* @exception {DeveloperError} layer is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*/
ImageryLayerCollection.prototype.raise = function(layer) {
    var index = getLayerIndex(this._layers, layer);
    swapLayers(this, index, index + 1);
};

/**
* Lowers a layer down one position in the collection.
*
* @param {ImageryLayer} layer the layer to move.
*
* @exception {DeveloperError} layer is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*/
ImageryLayerCollection.prototype.lower = function(layer) {
    var index = getLayerIndex(this._layers, layer);
    swapLayers(this, index, index - 1);
};

/**
* Raises a layer to the top of the collection.
*
* @param {ImageryLayer} layer the layer to move.
*
* @exception {DeveloperError} layer is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*/
ImageryLayerCollection.prototype.raiseToTop = function(layer) {
    var index = getLayerIndex(this._layers, layer);
    if (index === this._layers.length - 1) {
        return;
    }
    this._layers.splice(index, 1);
    this._layers.push(layer);
    
    this._update();
    
    this.layerMoved.raiseEvent(layer, this._layers.length - 1, index);
};

/**
* Lowers a layer to the bottom of the collection.
*
* @param {ImageryLayer} layer the layer to move.
*
* @exception {DeveloperError} layer is not in this collection.
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*/
ImageryLayerCollection.prototype.lowerToBottom = function(layer) {
    var index = getLayerIndex(this._layers, layer);
    if (index === 0) {
        return;
    }
    this._layers.splice(index, 1);
    this._layers.splice(0, 0, layer);
    
    this._update();
    
    this.layerMoved.raiseEvent(layer, 0, index);
};

/**
* Returns true if this object was destroyed; otherwise, false.
* <br /><br />
* If this object was destroyed, it should not be used; calling any function other than
* <code>isDestroyed</code> will result in a {@link DeveloperError} exception.
*
* @returns {Boolean} true if this object was destroyed; otherwise, false.
*
* @see ImageryLayerCollection#destroy
*/
ImageryLayerCollection.prototype.isDestroyed = function() {
    return false;
};

/**
* Destroys the WebGL resources held by all layers in this collection.  Explicitly destroying this
* object allows for deterministic release of WebGL resources, instead of relying on the garbage
* collector.
* <br /><br />
* Once this object is destroyed, it should not be used; calling any function other than
* <code>isDestroyed</code> will result in a {@link DeveloperError} exception.  Therefore,
* assign the return value (<code>undefined</code>) to the object as done in the example.
*
* @returns {undefined}
*
* @exception {DeveloperError} This object was destroyed, i.e., destroy() was called.
*
* @see ImageryLayerCollection#isDestroyed
*
* @example
* layerCollection = layerCollection && layerCollection.destroy();
*/
ImageryLayerCollection.prototype.destroy = function() {
    this.removeAll(true);
    return destroyObject(this);
};
*/
    func update() {
        var isBaseLayer = true
        var layersShownOrHidden = [ImageryLayer]()
        var layer: ImageryLayer
        
        for (index, layer) in enumerate(_layers) {
            layer.layerIndex = index
            
            if (layer.show) {
                layer.isBaseLayer = isBaseLayer
                isBaseLayer = false
            } else {
                layer.isBaseLayer = false
            }
            
            if (layer.show != layer._show) {
                //if (defined(layer._show)) {
                layersShownOrHidden.append(layer)
                //
                layer._show = layer.show
            }
        }
        for (index, layer) in enumerate(layersShownOrHidden) {
            //FIXME: RaiseEvent
            layerShownOrHidden.raiseEvent()//layer, layer._layerIndex, layer.show)
        }
    }

}