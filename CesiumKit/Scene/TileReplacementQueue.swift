//
//  TileReplacementQueue.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//


/**
* A priority queue of tiles to be replaced, if necessary, to make room for new tiles.  The queue
* is implemented as a linked list.
*
* @alias TileReplacementQueue
* @private
*/
class TileReplacementQueue {
    
    var head: QuadtreeTile? = nil
    
    var tail: QuadtreeTile? = nil
    
    var count = 0
    
    private var _lastBeforeStartOfFrame: QuadtreeTile? = nil

    /**
    * Marks the start of the render frame.  Tiles before (closer to the head) this tile in the
    * list were used last frame and must not be unloaded.
    */
    func markStartOfRenderFrame() {
        _lastBeforeStartOfFrame = head
    }
    
    /**
    * Reduces the size of the queue to a specified size by unloading the least-recently used
    * tiles.  Tiles that were used last frame will not be unloaded, even if that puts the number
    * of tiles above the specified maximum.
    *
    * @param {Number} maximumTiles The maximum number of tiles in the queue.
    */
    func trimTiles(context: Context, maximumTiles: Int) {
        var tileToTrim = tail
        var keepTrimming = true
        while keepTrimming && _lastBeforeStartOfFrame != nil && count > maximumTiles && tileToTrim != nil {
            // Stop trimming after we process the last tile not used in the
            // current frame.
            keepTrimming = tileToTrim! != _lastBeforeStartOfFrame
            
            let previous = tileToTrim!.replacementPrevious
            
            if tileToTrim!.eligibleForUnloading {
                tileToTrim!.freeResources(context)
                remove(tileToTrim!)
            }
            tileToTrim = previous
        }
    }
    
    func remove(item: QuadtreeTile) {
        let previous = item.replacementPrevious
        let next = item.replacementNext
        
        if item == _lastBeforeStartOfFrame {
            _lastBeforeStartOfFrame = next
        }
        
        if (item == head) {
            head = next
        } else {
            previous!.replacementNext = next
        }
        
        if (item == tail) {
            tail = previous
        } else {
            next!.replacementPrevious = previous
        }
        
        item.replacementPrevious = nil
        item.replacementNext = nil
        
        --count
    }
    
    /**
    * Marks a tile as rendered this frame and moves it before the first tile that was not rendered
    * this frame.
    *
    * @param {TileReplacementQueue} item The tile that was rendered.
    */
    func markTileRendered (item: QuadtreeTile) {
        if head == item {
            if (item == _lastBeforeStartOfFrame) {
                _lastBeforeStartOfFrame = item.replacementNext
            }
            return;
        }
        
        ++count
        
        if head == nil {
            // no other tiles in the list
            item.replacementPrevious = nil
            item.replacementNext = nil
            head = item
            tail = item
            return
        }
        
        if item.replacementPrevious != nil || item.replacementNext != nil {
            // tile already in the list, remove from its current location
            remove(item)
        }
        
        item.replacementPrevious = nil
        item.replacementNext = head
        head!.replacementPrevious = item
        
        head = item
    }
    
}