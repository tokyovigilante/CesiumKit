//
//  CreditDisplay.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

/**
 * The credit display is responsible for displaying credits on screen.
 *
 * @param {HTMLElement} container The HTML element where credits will be displayed
 * @param {String} [delimiter= ' • '] The string to separate text credits
 *
 * @alias CreditDisplay
 * @constructor
 *
 * @example
 * var creditDisplay = new Cesium.CreditDisplay(creditContainer);
 */
class CreditDisplay {
    
    private var _creditRenderer: TextRenderer
    
    /*func displayImageCredits(creditDisplay, imageCredits) {
        var i;
        var index;
        var credit;
        var displayedImageCredits = creditDisplay._displayedCredits.imageCredits;
        for (i = 0; i < imageCredits.length; i++) {
            credit = imageCredits[i];
            if (defined(credit)) {
                index = displayedImageCredits.indexOf(credit);
                if (index === -1) {
                    displayImageCredit(credit, creditDisplay._imageContainer);
                } else {
                    displayedImageCredits.splice(index, 1);
                }
            }
        }
        for (i = 0; i < displayedImageCredits.length; i++) {
            credit = displayedImageCredits[i];
            if (defined(credit)) {
                removeCreditDomElement(credit);
            }
        }
    }*/
    
    let delimiter: String
    
    
    private var _defaultImageCredits = [Credit]()
    private var _defaultTextCredits = [Credit]()
    
    
    
    private var _displayedCredits = (
        imageCredits: [Credit](),
        textCredits: [Credit]()
    )
    
    private var _currentFrameCredits = (
        imageCredits: [Int: Credit](),
        textCredits: [Int: Credit]()
    )
    
    init (delimiter: String = ". ") {
        self.delimiter = delimiter
        
        _creditRenderer = TextRenderer(
            string: "CesiumKit",
            fontName: "HelveticaNeue",
            color: Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            pointSize: 40,
            viewportRect: Cartesian4(x: 40, y: 40, width: 2000, height: 240)
        )
    }
    
    func update(_ frameState: inout FrameState) {
        //_creditRenderer.update(&frameState)
        let context = frameState.context
        var meshSize = _creditRenderer.computeSize(Double(context.width - 80))
        var viewPortRect = Cartesian4(
            x: 40,
            y: Double(context.height - 40) - Double(meshSize.height),
            width: min(Double(meshSize.width), Double(context.width - 80)),
            height: Double(meshSize.height)
        )
        _creditRenderer.viewportRect = viewPortRect
        _creditRenderer.update(&frameState)
    }
    
    private func contains(_ credit: Credit, inCredits credits: [Credit]) -> Bool {
        for existingCredit in credits {
            if credit == existingCredit {
                return true
            }
        }
        return false
    }
    
    /**
     * Adds a credit to the list of current credits to be displayed in the credit container
     *
     * @param {Credit} credit The credit to display
     */
    func addCredit (_ credit: Credit) {
        if false/*credit.hasImage*/ {
            if !contains(credit, inCredits: _defaultImageCredits) {
                _currentFrameCredits.imageCredits[credit.id] = credit
            }
        } else {
            if !contains(credit, inCredits: _defaultTextCredits) {
                _currentFrameCredits.textCredits[credit.id] = credit
            }
        }
    }
    
    /**
     * Adds credits that will persist until they are removed
     *
     * @param {Credit} credit The credit to added to defaults
     */
    func addDefaultCredit (_ credit: Credit) {
        
        if false/*credit.hasImage*/ {
            if !contains(credit, inCredits: _defaultImageCredits) {
                _defaultImageCredits.append(credit)
            }
        } else {
            if !contains(credit, inCredits: _defaultTextCredits) {
                _defaultTextCredits.append(credit)
            }
        }
    }
    
    
    /**
     * Removes a default credit
     *
     * @param {Credit} credit The credit to be removed from defaults
     */
    func removeDefaultCredit (_ credit: Credit) {
        /*
        var index;
        if false/*credit.hasImage*/ {
            index = this._defaultImageCredits.indexOf(credit);
            if (index !== -1) {
                this._defaultImageCredits.splice(index, 1);
            }
        } else {
            index = this._defaultTextCredits.indexOf(credit);
            if (index !== -1) {
                this._defaultTextCredits.splice(index, 1);
            }
        }*/
    }
    
    /**
     * Resets the credit display to a beginning of frame state, clearing out current credits.
     *
     * @param {Credit} credit The credit to display
     */
    func beginFrame () {
        _currentFrameCredits.imageCredits.removeAll()
        _currentFrameCredits.textCredits.removeAll()
    }
    
    /**
     * Sets the credit display to the end of frame state, displaying current credits in the credit container
     *
     * @param {Credit} credit The credit to display
     */
    func endFrame () {
        //var textCredits = _defaultTextCredits.concat(this._currentFrameCredits.textCredits);
        //var imageCredits = _defaultImageCredits.concat(this._currentFrameCredits.imageCredits);
        _creditRenderer.string = _currentFrameCredits.textCredits.values
            .filter { $0.hasText }
            .reduce("") { $0 + $1.text! + delimiter }
        //displayTextCredits(_currentFrameCredits.textCredits)//textCredits)
        //displayImageCredits(imageCredits)
        
        //_displayedCredits.textCredits = textCredits
        //_displayedCredits.imageCredits = imageCredits
    }
    
}
