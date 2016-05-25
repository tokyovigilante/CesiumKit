//
//  Array.swift
//  Cent
//
//  Created by Ankur Patel on 6/28/14.
//  Copyright (c) 2014 Encore Dev Labs LLC. All rights reserved.
//

import Foundation

public func deleteDuplicates<S:RangeReplaceableCollectionType where S.Generator.Element: Equatable>(seq:S)-> S {
    let s = seq.reduce(S()){
        ac, x in ac.contains(x) ? ac : ac + [x]
    }
    return s
}

extension Array {
    var sizeInBytes: Int {
        return count == 0 ? 0 : count * strideofValue(self[0])
    }
    
    /**
    * Finds an item in a sorted array.
    *
    * @exports binarySearch
    *
    * @param {Array} array The sorted array to search.
    * @param {Object} itemToFind The item to find in the array.
    * @param {binarySearch~Comparator} comparator The function to use to compare the item to
    *        elements in the array.
    * @returns {Number} The index of <code>itemToFind</code> in the array, if it exists.  If <code>itemToFind</code>
    *        does not exist, the return value is a negative number which is the bitwise complement (~)
    *        of the index before which the itemToFind should be inserted in order to maintain the
    *        sorted order of the array.
    *
    * @example
    * // Create a comparator function to search through an array of numbers.
    * var comparator = function(a, b) {
    *     return a - b;
    * };
    * var numbers = [0, 2, 4, 6, 8];
    * var index = Cesium.binarySearch(numbers, 6, comparator); // 3
    */
    func binarySearch (itemToFind: Element, comparator: BinarySearchComparator) -> Int {
        var low = 0
        var high = self.count - 1
        var i: Int
        var comparison: Int
        
        while low <= high {
            i = Int(trunc(Double(low + high) / 2.0))
            comparison = comparator(a: self[i], b: itemToFind)
            if comparison < 0 {
                low = i + 1
                continue
            }
            if comparison > 0 {
                high = i - 1
                continue
            }
            return i;
        }
        return ~(high + 1)
    }
    
    /**
    * A function used to compare two items while performing a binary search.
    * @callback binarySearch~Comparator
    *
    * @param {Object} a An item in the array.
    * @param {Object} b The item being searched for.
    * @returns {Number} Returns a negative value if <code>a</code> is less than <code>b</code>,
    *          a positive value if <code>a</code> is greater than <code>b</code>, or
    *          0 if <code>a</code> is equal to <code>b</code>.
    *
    * @example
    * function compareNumbers(a, b) {
    *     return a - b;
    * }
    */
    typealias BinarySearchComparator = (a: Element, b: Element) -> Int

}



