//
//  defaultValue.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 28/07/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

operator infix !! {}

@infix func !! <T> (value: T?, defaultValue: @auto_closure () -> T) -> T {
    return value ? value! : defaultValue()
}
