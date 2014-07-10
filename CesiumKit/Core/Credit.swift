//
//  Credit.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 12/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

/**
* A credit contains data pertaining to how to display attributions/credits for certain content on the screen.
*
* @param {String} [text] The text to be displayed on the screen if no imageUrl is specified.
* @param {String} [imageUrl] The source location for an image
* @param {String} [link] A URL location for which the credit will be hyperlinked
*
* @alias Credit
* @constructor
*
* @example
* //Create a credit with a tooltip, image and link
* var credit = new Cesium.Credit('Cesium', '/images/cesium_logo.png', 'http://cesiumjs.org/');
*/
struct Credit/*: Equatable*/ {
    
    var text: String?
    var imageUrl: String?
    var link: String?
    
    init (text: String?, imageUrl: String?, link: String?) {
        assert(text != nil || imageUrl != nil || link != nil, "text, imageUrl or link is required")

        if (text == nil && imageUrl == nil) {
            self.text = link
        } else {
            self.text = text
        }
        self.imageUrl = imageUrl
        self.link = link
    }
}
/**
* Returns true if the credits are equal
*
* @param {Credit} left The first credit
* @param {Credit} left The second credit
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/
func == (left: Credit, right: Credit) -> Bool {
    return (left.text == right.text && left.imageUrl == right.imageUrl && left.link == right.link)
}

