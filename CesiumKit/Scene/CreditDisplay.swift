//
//  CreditDisplay.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 11/06/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

import Foundation

class CreditDisplay {
    
    private func displayTextCredit(credit: Credit, delimiter: String) {
        if (!defined(credit.element)) {
            var text = credit.text;
            var link = credit.link;
            var span = document.createElement('span');
            if (credit.hasLink()) {
                var a = document.createElement('a');
                a.textContent = text;
                a.href = link;
                a.target = '_blank';
                span.appendChild(a);
            } else {
                span.textContent = text;
            }
            span.className = 'cesium-credit-text';
            credit.element = span;
        }
        if (container.hasChildNodes()) {
            var del = document.createElement('span');
            del.textContent = delimiter;
            del.className = 'cesium-credit-delimiter';
            container.appendChild(del);
        }
        container.appendChild(credit.element);
    }
    
    func displayImageCredit(credit: Credit) {
        if (!defined(credit.element)) {
            var text = credit.text;
            var link = credit.link;
            var span = document.createElement('span');
            var content = document.createElement('img');
            content.src = credit.imageUrl;
            content.style['vertical-align'] = 'bottom';
            if (defined(text)) {
                content.alt = text;
                content.title = text;
            }
            
            if (credit.hasLink()) {
                var a = document.createElement('a');
                a.appendChild(content);
                a.href = link;
                a.target = '_blank';
                span.appendChild(a);
            } else {
                span.appendChild(content);
            }
            span.className = 'cesium-credit-image';
            credit.element = span;
        }
        container.appendChild(credit.element);
    }
    
    func contains(credits, credit) {
        var len = credits.length;
        for ( var i = 0; i < len; i++) {
            var existingCredit = credits[i];
            if (Credit.equals(existingCredit, credit)) {
                return true;
            }
        }
        return false;
    }
    
    func removeCreditDomElement(credit) {
        var element = credit.element;
        if (defined(element)) {
            var container = element.parentNode;
            if (!credit.hasImage()) {
                var delimiter = element.previousSibling;
                if (delimiter === null) {
                    delimiter = element.nextSibling;
                }
                if (delimiter !== null) {
                    container.removeChild(delimiter);
                }
            }
            container.removeChild(element);
        }
    }
    
    func displayTextCredits(creditDisplay, textCredits) {
        var i;
        var index;
        var credit;
        var displayedTextCredits = creditDisplay._displayedCredits.textCredits;
        for (i = 0; i < textCredits.length; i++) {
            credit = textCredits[i];
            if (defined(credit)) {
                index = displayedTextCredits.indexOf(credit);
                if (index === -1) {
                    displayTextCredit(credit, creditDisplay._textContainer, creditDisplay._delimiter);
                } else {
                    displayedTextCredits.splice(index, 1);
                }
            }
        }
        for (i = 0; i < displayedTextCredits.length; i++) {
            credit = displayedTextCredits[i];
            if (defined(credit)) {
                removeCreditDomElement(credit);
            }
        }
        
    }
    
    func displayImageCredits(creditDisplay, imageCredits) {
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
    }
    
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
    init (container, delimiter) {
        //>>includeStart('debug', pragmas.debug);
        if (!defined(container)) {
            throw new DeveloperError('credit container is required');
        }
        //>>includeEnd('debug');
        
        var imageContainer = document.createElement('span');
        imageContainer.className = 'cesium-credit-imageContainer';
        var textContainer = document.createElement('span');
        textContainer.className = 'cesium-credit-textContainer';
        container.appendChild(imageContainer);
        container.appendChild(textContainer);
        
        this._delimiter = defaultValue(delimiter, ' • ');
        this._textContainer = textContainer;
        this._imageContainer = imageContainer;
        this._defaultImageCredits = [];
        this._defaultTextCredits = [];
        
        this._displayedCredits = {
            imageCredits : [],
            textCredits : []
        };
        this._currentFrameCredits = {
            imageCredits : [],
            textCredits : []
        }
        
        /**
         * The HTML element where credits will be displayed.
         * @type {HTMLElement}
         */
        this.container = container;
    }
    
    /**
     * Adds a credit to the list of current credits to be displayed in the credit container
     *
     * @param {Credit} credit The credit to display
     */
    func addCredit (credit: Credit) {
        //>>includeStart('debug', pragmas.debug);
        if (!defined(credit)) {
            throw new DeveloperError('credit must be defined');
        }
        //>>includeEnd('debug');
        
        if (credit.hasImage()) {
            var imageCredits = this._currentFrameCredits.imageCredits;
            if (!contains(this._defaultImageCredits, credit)) {
                imageCredits[credit.id] = credit;
            }
        } else {
            var textCredits = this._currentFrameCredits.textCredits;
            if (!contains(this._defaultTextCredits, credit)) {
                textCredits[credit.id] = credit;
            }
        }
    };
    
    /**
     * Adds credits that will persist until they are removed
     *
     * @param {Credit} credit The credit to added to defaults
     */
    func addDefaultCredit (credit: Credit) {
        //>>includeStart('debug', pragmas.debug);
        if (!defined(credit)) {
            throw new DeveloperError('credit must be defined');
        }
        //>>includeEnd('debug');
        
        if (credit.hasImage()) {
            var imageCredits = this._defaultImageCredits;
            if (!contains(imageCredits, credit)) {
                imageCredits.push(credit);
            }
        } else {
            var textCredits = this._defaultTextCredits;
            if (!contains(textCredits, credit)) {
                textCredits.push(credit);
            }
        }
    };
    
    /**
     * Removes a default credit
     *
     * @param {Credit} credit The credit to be removed from defaults
     */
    func removeDefaultCredit (credit: Credit) {
        //>>includeStart('debug', pragmas.debug);
        if (!defined(credit)) {
            throw new DeveloperError('credit must be defined');
        }
        //>>includeEnd('debug');
        
        var index;
        if (credit.hasImage()) {
            index = this._defaultImageCredits.indexOf(credit);
            if (index !== -1) {
                this._defaultImageCredits.splice(index, 1);
            }
        } else {
            index = this._defaultTextCredits.indexOf(credit);
            if (index !== -1) {
                this._defaultTextCredits.splice(index, 1);
            }
        }
    };
    
    /**
     * Resets the credit display to a beginning of frame state, clearing out current credits.
     *
     * @param {Credit} credit The credit to display
     */
    func beginFrame () {
        this._currentFrameCredits.imageCredits.length = 0;
        this._currentFrameCredits.textCredits.length = 0;
    }
    
    /**
     * Sets the credit display to the end of frame state, displaying current credits in the credit container
     *
     * @param {Credit} credit The credit to display
     */
    func endFrame () {
        var textCredits = this._defaultTextCredits.concat(this._currentFrameCredits.textCredits);
        var imageCredits = this._defaultImageCredits.concat(this._currentFrameCredits.imageCredits);
        
        displayTextCredits(this, textCredits);
        displayImageCredits(this, imageCredits);
        
        this._displayedCredits.textCredits = textCredits;
        this._displayedCredits.imageCredits = imageCredits;
    };
    
}