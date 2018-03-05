//
//  Command.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 10/10/2015.
//  Copyright © 2015 Test Toast. All rights reserved.
//

import Foundation

protocol Command {
    var pass: Pass { get }

    var boundingVolume: BoundingVolume? { get }
}

extension Command {
    var boundingVolume: BoundingVolume? { return nil }
}
