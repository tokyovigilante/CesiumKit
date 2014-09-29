//
//  Queue.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 27/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//


/**
* A queue that can enqueue items at the end, and dequeue items from the front.
*
* @alias Queue
* @constructor
*/
class Queue<T: Equatable> {
    private var _array = [T]()
    
    /**
    * Enqueues the specified item.
    *
    * @param {Object} item The item to enqueue.
    */
    func enqueue(item: T) {
        _array.append(item)
    }
    
    /**
    * Dequeues an item.  Returns undefined if the queue is empty.
    */
    func dequeue() -> T? {
        if _array.count == 0 {
            return nil
        }
        return _array.removeAtIndex(0)
    }
    
    var count: Int {
        get {
            return _array.count
        }
    }
    
    /**
    * Check whether this queue contains the specified item.
    *
    * @param {Object} item the item to search for.
    */
    func contains(item: T) -> Bool {
        for object in _array {
            if object == item {
                return true
            }
        }
        return false
    }
    
    /**
    * Remove all items from the queue.
    */
    func clear() {
        _array.removeAll()
    }

/*
    /**
    * Sort the items in the queue in-place.
    *
    * @param {Queue~Comparator} compareFunction A function that defines the sort order.
    */
    Queue.prototype.sort = function(compareFunction) {
        if (this._offset > 0) {
            //compact array
            this._array = this._array.slice(this._offset);
            this._offset = 0;
        }
        
        this._array.sort(compareFunction);
    };
    */
    /**
    * A function used to compare two items while sorting a queue.
    * @callback Queue~Comparator
    *
    * @param {Object} a An item in the array.
    * @param {Object} b An item in the array.
    * @returns {Number} Returns a negative value if <code>a</code> is less than <code>b</code>,
    *          a positive value if <code>a</code> is greater than <code>b</code>, or
    *          0 if <code>a</code> is equal to <code>b</code>.
    *
    * @example
    * function compareNumbers(a, b) {
    *     return a - b;
    * }
    */

}