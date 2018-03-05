//
//  CFRange+Comparison.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/05/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

extension CFRange: Equatable {}

public func == (lhs: CFRange, rhs: CFRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}
