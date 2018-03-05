//
//  LabelStyle.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 31/01/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * Describes how to draw a label.
 *
 * @namespace
 * @alias LabelStyle
 *
 * @see Label#style
 */
public enum LabelStyle {
    /**
     * Fill the text of the label, but do not outline.
     *
     * @type {Number}
     * @constant
     */
    case fill

    /**
     * Outline the text of the label, but do not fill.
     *
     * @type {Number}
     * @constant
     */
    case outline

    /**
     * Fill and outline the text of the label.
     *
     * @type {Number}
     * @constant
     */
    case fillAndOutline
}
