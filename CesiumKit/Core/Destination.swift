//
//  Destination.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/04/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

public enum Destination {
    case cartesian(Cartesian3)

    case rectangle(Rectangle)

    var cartesian: Cartesian3? {
        switch self {
        case let .cartesian(cartesian):
            return cartesian
        default:
            return nil
        }
    }

    var rectangle: Rectangle? {
        switch self {
        case let .rectangle(rectangle):
            return rectangle
        default:
            return nil
        }
    }
}
