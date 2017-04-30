//
//  QuadtreeNode.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/4/17.
//  Copyright © 2017 Test Toast. All rights reserved.
//

import Foundation

class QuadtreeNode {
    
    let tilingScheme: TilingScheme
    
    let parent: QuadtreeNode?
    
    let level: Int
    
    let x: Int
    
    let y: Int
    
    let extent: Rectangle
    
    var rectangles = [RectangleWithLevel]()
    
    lazy var nw: QuadtreeNode = {
        return QuadtreeNode(tilingScheme: self.tilingScheme, parent: self, level: self.level + 1, x: self.x * 2, y: self.y * 2)
    }()
    
    lazy var ne: QuadtreeNode = {
        return QuadtreeNode(tilingScheme: self.tilingScheme, parent: self, level: self.level + 1, x: self.x * 2 + 1, y: self.y * 2)
    }()
    
    lazy var sw: QuadtreeNode = {
        return QuadtreeNode(tilingScheme: self.tilingScheme, parent: self, level: self.level + 1, x: self.x * 2, y: self.y * 2 + 1)
    }()
    
    lazy var se: QuadtreeNode = {
        return QuadtreeNode(tilingScheme: self.tilingScheme, parent: self, level: self.level + 1, x: self.x * 2 + 1, y: self.y * 2 + 1)
    }()    
    
    init (tilingScheme: TilingScheme, parent: QuadtreeNode?, level: Int, x: Int, y: Int) {
        self.tilingScheme = tilingScheme
        self.parent = parent
        self.level = level
        self.x = x
        self.y = y
        
        extent = tilingScheme.tileXYToRectangle(x: x, y: y, level: level)
    }
    
}
