//
//  defaultValue.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 9/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

func defaultValue<T>(a: T?, b: T) -> T {
    if a {
        return a!
    }
    return b
}