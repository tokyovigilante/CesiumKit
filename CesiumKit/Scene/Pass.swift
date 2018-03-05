//
//  Pass.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 17/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* The render pass for a command.
*
* @private
*/
enum Pass: Int {
    // Commands are executed in order by pass up to the translucent pass.
    // Translucent geometry needs special handling (sorting/OIT). Overlays
    // are also special (they're executed last, they're not sorted by frustum).
    case environment = 0,
    compute,
    offscreenQuad,
    globe,
    ground,
    opaque,
    translucent,
    overlay,
    overlayText

    static let count = 8
}
