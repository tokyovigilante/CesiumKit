//
//  TileAvailability.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/4/17.
//  Copyright © 2017 Test Toast. All rights reserved.
//

import Foundation

class TileAvailability {
    
    private let _tilingScheme: TilingScheme
    
    private let _maximumLevel: Int
    
    private var _rootNodes = [QuadtreeNode]()
    
    /**
     * Reports the availability of tiles in a {@link TilingScheme}.
    *
     * @alias TileAvailability
     * @constructor
     *
     * @param {TilingScheme} tilingScheme The tiling scheme in which to report availability.
    * @param {Number} maximumLevel The maximum tile level that is potentially available.
     */
    init (tilingScheme: TilingScheme, maximumLevel: Int) {
         _tilingScheme = tilingScheme
         _maximumLevel = maximumLevel
        
        for y in 0..<tilingScheme.numberOfXTilesAt(level: 0) {
            for x in 0..<tilingScheme.numberOfYTilesAt(level: 0) {
                _rootNodes.append(QuadtreeNode(tilingScheme: tilingScheme, parent: nil, level: 0, x: x, y: y))
            }
        }
    }
  
     /**
      * Marks a rectangular range of tiles in a particular level as being available.  For best performance,
      * add your ranges in order of increasing level.
      *
      * @param {Number} level The level.
      * @param {Number} startX The X coordinate of the first available tiles at the level.
      * @param {Number} startY The Y coordinate of the first available tiles at the level.
      * @param {Number} endX The X coordinate of the last available tiles at the level.
      * @param {Number} endY The Y coordinate of the last available tiles at the level.
      */
    func addAvailableTileRange (level: Int, startX: Int, startY: Int, endX: Int, endY: Int) {
 
         let startRectangle = _tilingScheme.tileXYToRectangle(x: startX, y: startY, level: level)
         let west = startRectangle.west
         let north = startRectangle.north
 
         let endRectangle = _tilingScheme.tileXYToRectangle(x: endX, y: endY, level: level)
         let east = endRectangle.east
         let south = endRectangle.south
 
        let rectangleWithLevel =
            RectangleWithLevel(
                level: level,
                west: west,
                south: south,
                east: east,
                north: north
        )
 
        for rootNode in _rootNodes {
             if rectanglesOverlap(rectangle1: rootNode.extent, rectangle2: rectangleWithLevel) {
                 putRectangleInQuadtree(maxDepth: _maximumLevel, node: rootNode, rectangle: rectangleWithLevel)
             }
         }
     };
 /*
     /**
 +     * Determines the level of the most detailed tile covering the position.  This function
 +     * usually completes in time logarithmic to the number of rectangles added with
 +     * {@link TileAvailability#addAvailableTileRange}.
 +     *
 +     * @param {Cartographic} position The position for which to determine the maximum available level.  The height component is ignored.
 +     * @return {Number} The level of the most detailed tile covering the position.
 +     * @throws {DeveloperError} If position is outside any tile according to the tiling scheme.
 +     */
 +    TileAvailability.prototype.computeMaximumLevelAtPosition = function(position) {
 +        // Find the root node that contains this position.
 +        var node;
 +        for (var nodeIndex = 0; nodeIndex < this._rootNodes.length; ++nodeIndex) {
 +            var rootNode = this._rootNodes[nodeIndex];
 +            if (rectangleContainsPosition(rootNode.extent, position)) {
 +                node = rootNode;
 +                break;
 +            }
 +        }
 +
 +        //>>includeStart('debug', pragmas.debug);
 +        if (!defined(node)) {
 +            throw new DeveloperError('The specified position does not exist in any root node of the tiling scheme.');
 +        }
 +        //>>includeEnd('debug');
 +
 +        return findMaxLevelFromNode(undefined, node, position);
 +    };
 +
 +    var rectanglesScratch = [];
 +    var remainingToCoverByLevelScratch = [];
 +    var westScratch = new Rectangle();
 +    var eastScratch = new Rectangle();
 +
 +    /**
 +     * Finds the most detailed level that is available _everywhere_ within a given rectangle.  More detailed
 +     * tiles may be available in parts of the rectangle, but not the whole thing.  The return value of this
 +     * function may be safely passed to {@link sampleTerrain} for any position within the rectangle.  This function
 +     * usually completes in time logarithmic to the number of rectangles added with
 +     * {@link TileAvailability#addAvailableTileRange}.
 +     *
 +     * @param {Rectangle} rectangle The rectangle.
 +     * @return {Number} The best available level for the entire rectangle.
 +     */
 +    TileAvailability.prototype.computeBestAvailableLevelOverRectangle = function(rectangle) {
 +        var rectangles = rectanglesScratch;
 +        rectangles.length = 0;
 +
 +        if (rectangle.east < rectangle.west) {
 +            // Rectangle crosses the IDL, make it two rectangles.
 +            rectangles.push(Rectangle.fromRadians(-Math.PI, rectangle.south, rectangle.east, rectangle.north, westScratch));
 +            rectangles.push(Rectangle.fromRadians(rectangle.west, rectangle.south, Math.PI, rectangle.north, eastScratch));
 +        } else {
 +            rectangles.push(rectangle);
 +        }
 +
 +        var remainingToCoverByLevel = remainingToCoverByLevelScratch;
 +        remainingToCoverByLevel.length = 0;
 +
 +        var i;
 +        for (i = 0; i < this._rootNodes.length; ++i) {
 +            updateCoverageWithNode(remainingToCoverByLevel, this._rootNodes[i], rectangles);
 +        }
 +
 +        for (i = remainingToCoverByLevel.length - 1; i >= 0; --i) {
 +            if (defined(remainingToCoverByLevel[i]) && remainingToCoverByLevel[i].length === 0) {
 +                return i;
 +            }
 +        }
 +
 +        return 0;
 +    };
 +
 +    var cartographicScratch = new Cartographic();
 +
 +    /**
 +     * Determines if a particular tile is available.
 +     * @param {Number} level The tile level to check.
 +     * @param {Number} x The X coordinate of the tile to check.
 +     * @param {Number} y The Y coordinate of the tile to check.
 +     * @return {Boolean} True if the tile is available; otherwise, false.
 +     */
 +    TileAvailability.prototype.isTileAvailable = function(level, x, y) {
 +        // Get the center of the tile and find the maximum level at that position.
 +        // Because availability is by tile, if the level is available at that point, it
 +        // is sure to be available for the whole tile.  We assume that if a tile at level n exists,
 +        // then all its parent tiles back to level 0 exist too.  This isn't really enforced
 +        // anywhere, but Cesium would never load a tile for which this is not true.
 +        var rectangle = this._tilingScheme.tileXYToRectangle(x, y, level, rectangleScratch);
 +        Rectangle.center(rectangle, cartographicScratch);
 +        return this.computeMaximumLevelAtPosition(cartographicScratch) >= level;
 +    };
 +
 +    /**
 +     * Computes a bit mask indicating which of a tile's four children exist.
 +     * If a child's bit is set, a tile is available for that child.  If it is cleared,
 +     * the tile is not available.  The bit values are as follows:
 +     * <table>
 +     *     <tr><th>Bit Position</th><th>Bit Value</th><th>Child Tile</th></tr>
 +     *     <tr><td>0</td><td>1</td><td>Southwest</td></tr>
 +     *     <tr><td>1</td><td>2</td><td>Southeast</td></tr>
 +     *     <tr><td>2</td><td>4</td><td>Northwest</td></tr>
 +     *     <tr><td>3</td><td>8</td><td>Northeast</td></tr>
 +     * </table>
 +     *
 +     * @param {Number} level The level of the parent tile.
 +     * @param {Number} x The X coordinate of the parent tile.
 +     * @param {Number} y The Y coordinate of the parent tile.
 +     * @return {Number} The bit mask indicating child availability.
 +     */
 +    TileAvailability.prototype.computeChildMaskForTile = function(level, x, y) {
 +        var childLevel = level + 1;
 +        if (childLevel >= this._maximumLevel) {
 +            return 0;
 +        }
 +
 +        var mask = 0;
 +
 +        mask |= this.isTileAvailable(childLevel, 2 * x, 2 * y + 1) ? 1 : 0;
 +        mask |= this.isTileAvailable(childLevel, 2 * x + 1, 2 * y + 1) ? 2 : 0;
 +        mask |= this.isTileAvailable(childLevel, 2 * x, 2 * y) ? 4 : 0;
 +        mask |= this.isTileAvailable(childLevel, 2 * x + 1, 2 * y) ? 8 : 0;
 +
 +        return mask;
 +    };
 +
 +    
 +
 +    defineProperties(QuadtreeNode.prototype, {
 +        nw: {
 +            get: function() {
 +                if (!this._nw) {
 +                    this._nw = new QuadtreeNode(this.tilingScheme, this, this.level + 1, this.x * 2, this.y * 2);
 +                }
 +                return this._nw;
 +            }
 +        },
 +
 +        ne: {
 +            get: function() {
 +                if (!this._ne) {
 +                    this._ne = new QuadtreeNode(this.tilingScheme, this, this.level + 1, this.x * 2 + 1, this.y * 2);
 +                }
 +                return this._ne;
 +            }
 +        },
 +
 +        sw: {
 +            get: function() {
 +                if (!this._sw) {
 +                    this._sw = new QuadtreeNode(this.tilingScheme, this, this.level + 1, this.x * 2, this.y * 2 + 1);
 +                }
 +                return this._sw;
 +            }
 +        },
 +
 +        se: {
 +            get: function() {
 +                if (!this._se) {
 +                    this._se = new QuadtreeNode(this.tilingScheme, this, this.level + 1, this.x * 2 + 1, this.y * 2 + 1);
 +                }
 +                return this._se;
 +            }
 +        }
 +    });
 */

 
    func rectanglesOverlap (rectangle1: Rectangle, rectangle2: RectangleWithLevel) -> Bool {
        let west = max(rectangle1.west, rectangle2.west)
        let south = max(rectangle1.south, rectangle2.south)
        let east = min(rectangle1.east, rectangle2.east)
        let north = min(rectangle1.north, rectangle2.north)
        return south < north && west < east
    }
 
    func putRectangleInQuadtree(maxDepth: Int, node: QuadtreeNode, rectangle: RectangleWithLevel) {
        var node = node
        while node.level < maxDepth {
            if rectangleFullyContainsRectangle(potentialContainer: node.nw.extent, rectangleToTest: rectangle) {
                node = node.nw
            } else if (rectangleFullyContainsRectangle(potentialContainer: node.ne.extent, rectangleToTest: rectangle)) {
                node = node.ne
            } else if (rectangleFullyContainsRectangle(potentialContainer: node.sw.extent, rectangleToTest: rectangle)) {
                node = node.sw
            } else if (rectangleFullyContainsRectangle(potentialContainer: node.se.extent, rectangleToTest: rectangle)) {
                node = node.se
            } else {
                break
            }
        }

        if node.rectangles.isEmpty || node.rectangles.last!.level <= rectangle.level {
            node.rectangles.append(rectangle)
        } else {
           // Maintain ordering by level when inserting.
            var index = node.rectangles.binarySearch(rectangle) { a, b in
                return a.level - b.level
            }
            if (index <= 0) {
                index = ~index
            }
            node.rectangles.insert(rectangle, at: index)
        }
    }

    func rectangleFullyContainsRectangle(potentialContainer: Rectangle, rectangleToTest: RectangleWithLevel) -> Bool {
        return rectangleToTest.west >= potentialContainer.west &&
            rectangleToTest.east <= potentialContainer.east &&
            rectangleToTest.south >= potentialContainer.south &&
            rectangleToTest.north <= potentialContainer.north
    }
/*
 +    function rectangleContainsPosition(potentialContainer, positionToTest) {
 +        return positionToTest.longitude >= potentialContainer.west &&
 +               positionToTest.longitude <= potentialContainer.east &&
 +               positionToTest.latitude >= potentialContainer.south &&
 +               positionToTest.latitude <= potentialContainer.north;
 +    }
 +
 +    function findMaxLevelFromNode(stopNode, node, position) {
 +        var maxLevel = 0;
 +
 +        // Find the deepest quadtree node containing this point.
 +        while (true) {
 +            var nw = node._nw && rectangleContainsPosition(node._nw.extent, position);
 +            var ne = node._ne && rectangleContainsPosition(node._ne.extent, position);
 +            var sw = node._sw && rectangleContainsPosition(node._sw.extent, position);
 +            var se = node._se && rectangleContainsPosition(node._se.extent, position);
 +
 +            // The common scenario is that the point is in only one quadrant and we can simply
 +            // iterate down the tree.  But if the point is on a boundary between tiles, it is
 +            // in multiple tiles and we need to check all of them, so use recursion.
 +            if (nw + ne + sw + se > 1) {
 +                if (nw) {
 +                    maxLevel = Math.max(maxLevel, findMaxLevelFromNode(node, node._nw, position));
 +                }
 +                if (ne) {
 +                    maxLevel = Math.max(maxLevel, findMaxLevelFromNode(node, node._ne, position));
 +                }
 +                if (sw) {
 +                    maxLevel = Math.max(maxLevel, findMaxLevelFromNode(node, node._sw, position));
 +                }
 +                if (se) {
 +                    maxLevel = Math.max(maxLevel, findMaxLevelFromNode(node, node._se, position));
 +                }
 +                break;
 +            } else if (nw) {
 +                node = node._nw;
 +            } else if (ne) {
 +                node = node._ne;
 +            } else if (sw) {
 +                node = node._sw;
 +            } else if (se) {
 +                node = node._se;
 +            } else {
 +                break;
 +            }
 +        }
 +
 +        // Work up the tree until we find a rectangle that contains this point.
 +        while (node !== stopNode) {
 +            var rectangles = node.rectangles;
 +
 +            // Rectangles are sorted by level, lowest first.
 +            for (var i = rectangles.length - 1; i >= 0 && rectangles[i].level > maxLevel; --i) {
 +                var rectangle = rectangles[i];
 +                if (rectangleContainsPosition(rectangle, position)) {
 +                    maxLevel = rectangle.level;
 +                }
 +            }
 +
 +            node = node.parent;
 +        }
 +
 +        return maxLevel;
 +    }
 +
 +    function updateCoverageWithNode(remainingToCoverByLevel, node, rectanglesToCover) {
 +        if (!node) {
 +            return;
 +        }
 +
 +        var i;
 +        var anyOverlap = false;
 +        for (i = 0; i < rectanglesToCover.length; ++i) {
 +            anyOverlap = anyOverlap || rectanglesOverlap(node.extent, rectanglesToCover[i]);
 +        }
 +
 +        if (!anyOverlap) {
 +            // This node is not applicable to the rectangle(s).
 +            return;
 +        }
 +
 +        var rectangles = node.rectangles;
 +        for (i = 0; i < rectangles.length; ++i) {
 +            var rectangle = rectangles[i];
 +
 +            if (!remainingToCoverByLevel[rectangle.level]) {
 +                remainingToCoverByLevel[rectangle.level] = rectanglesToCover;
 +            }
 +
 +            remainingToCoverByLevel[rectangle.level] = subtractRectangle(remainingToCoverByLevel[rectangle.level], rectangle);
 +        }
 +
 +        // Update with child nodes.
 +        updateCoverageWithNode(remainingToCoverByLevel, node._nw, rectanglesToCover);
 +        updateCoverageWithNode(remainingToCoverByLevel, node._ne, rectanglesToCover);
 +        updateCoverageWithNode(remainingToCoverByLevel, node._sw, rectanglesToCover);
 +        updateCoverageWithNode(remainingToCoverByLevel, node._se, rectanglesToCover);
 +    }
 +
 +    function subtractRectangle(rectangleList, rectangleToSubtract) {
 +        var result = [];
 +        for (var i = 0; i < rectangleList.length; ++i) {
 +            var rectangle = rectangleList[i];
 +            if (!rectanglesOverlap(rectangle, rectangleToSubtract)) {
 +                // Disjoint rectangles.  Original rectangle is unmodified.
 +                result.push(rectangle);
 +            } else {
 +                // rectangleToSubtract partially or completely overlaps rectangle.
 +                if (rectangle.west < rectangleToSubtract.west) {
 +                    result.push(new Rectangle(rectangle.west, rectangle.south, rectangleToSubtract.west, rectangle.north));
 +                }
 +                if (rectangle.east > rectangleToSubtract.east) {
 +                    result.push(new Rectangle(rectangleToSubtract.east, rectangle.south, rectangle.east, rectangle.north));
 +                }
 +                if (rectangle.south < rectangleToSubtract.south) {
 +                    result.push(new Rectangle(Math.max(rectangleToSubtract.west, rectangle.west), rectangle.south, Math.min(rectangleToSubtract.east, rectangle.east), rectangleToSubtract.south));
 +                }
 +                if (rectangle.north > rectangleToSubtract.north) {
 +                    result.push(new Rectangle(Math.max(rectangleToSubtract.west, rectangle.west), rectangleToSubtract.north, Math.min(rectangleToSubtract.east, rectangle.east), rectangle.north));
 +                }
 +            }
 +        }
 +
 +        return result;
 +    }
 +
 +    return TileAvailability;
 +});
 */
}
