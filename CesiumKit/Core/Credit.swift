//
//  Credit.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 12/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

private var _nextCreditId = 0
private var _creditToId = [String: Int]()

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
public struct Credit: Equatable {

    public let text: String?

    public let imageUrl: String?

    public let link: String?

    var hasText: Bool {
        return text != nil
    }

    var hasImage: Bool {
        return imageUrl != nil
    }

    var hasLink: Bool {
        return link != nil
    }

    /**
    * @memberof Credit.prototype
    * @type {Number}
    *
    * @private
    */
    let id: Int

    init (text: String? = nil, imageUrl: String? = nil, link: String? = nil) {
        assert(text != nil || imageUrl != nil || link != nil, "text, imageUrl or link is required")

        if (text == nil && imageUrl == nil) {
            self.text = link
        } else {
            self.text = text
        }
        self.imageUrl = imageUrl
        self.link = link

        // Credits are immutable so generate an id to use to optimize equal()
        let key = "[\(text ?? ""):\(imageUrl ?? ""):\(link ?? "")]"
        if let creditToId = _creditToId[key] {
            id = creditToId
        } else {
            id = _nextCreditId
            _creditToId[key] = id
            _nextCreditId += 1
        }
    }
}
/**
* Returns true if the credits are equal
*
* @param {Credit} left The first credit
* @param {Credit} left The second credit
* @returns {Boolean} <code>true</code> if left and right are equal, <code>false</code> otherwise.
*/

public func == (left: Credit, right: Credit) -> Bool {
    return left.id == right.id
}
