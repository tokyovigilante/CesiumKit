//
//  CubeMapFace.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 13/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import OpenGLES

class CubeMapFace {
    
    let texture: Int
    let target: Int
    let targetFace: Int
    let pixelFormat: PixelFormat
    let pixelDatatype: PixelDatatype
    private let size: Int
    private let preMultiplyAlpha: Bool
    private let flipY: Bool
    
    init(texture: Texture, target: Int, targetFace: Int, pixelFormat: PixelFormat, pixelDatatype: PixelDatatype, size: Int, preMultiplyAlpha: Bool, flipY: Bool) {
        self.texture = texture
        self.target = textureTarget
        self.targetFace = targetFace
        self.pixelFormat = pixelFormat
        self.pixelDatatype = pixelDatatype
        self.size = size
        self.preMultiplyAlpha = preMultiplyAlpha
        self.flipY = flipY
    }

    
    /**
    * Copies texels from the source to the cubemap's face.
    *
    * @param {Object} source The source ImageData, HTMLImageElement, HTMLCanvasElement, HTMLVideoElement, or an object with a width, height, and typed array as shown in the example.
    * @param {Number} [xOffset=0] An offset in the x direction in the cubemap where copying begins.
    * @param {Number} [yOffset=0] An offset in the y direction in the cubemap where copying begins.
    *
    * @exception {DeveloperError} xOffset must be greater than or equal to zero.
    * @exception {DeveloperError} yOffset must be greater than or equal to zero.
    * @exception {DeveloperError} xOffset + source.width must be less than or equal to width.
    * @exception {DeveloperError} yOffset + source.height must be less than or equal to height.
    * @exception {DeveloperError} This CubeMap was destroyed, i.e., destroy() was called.
    *
    * @example
    * // Create a cubemap with 1x1 faces, and make the +x face red.
    * var cubeMap = context.createCubeMap({
    *   width : 1,
    *   height : 1
    * });
    * cubeMap.positiveX.copyFrom({
    *   width : 1,
    *   height : 1,
    *   arrayBufferView : new Uint8Array([255, 0, 0, 255])
    * });
    */
    func copyFrom(source: ImageBuffer, xOffset: Int = 0, yOffset: Int = 0) {
        
        assert(xOffset >= 0 && yOffset >= 0, "xOffset and yOffset must be greater than or equal to zero")
        
        assert(xOffset + source.width <= this._size, "xOffset + source.width must be less than or equal to width")
        assert(yOffset + source.height <= this._size, "yOffset + source.height must be less than or equal to height")
        
        var gl = this._gl;
        var target = this._textureTarget;
        
        // TODO: gl.pixelStorei(gl._UNPACK_ALIGNMENT, 4);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 4)
        //glpixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, this._preMultiplyAlpha);
        //gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, this._flipY);
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(target, texture)
        
        if source.arrayBufferView {
            glTexSubImage2D(target, 0, xOffset, yOffset, width, height, pixelFormat, PixelDatatype, source.arrayBufferView)
            /*} else {
            gl.texSubImage2D(this._targetFace, 0, xOffset, yOffset, this._pixelFormat, this._pixelDatatype, source);
            }*/
            glBindTexture(target, 0)
        }
    }
    /*
    /**
    * Copies texels from the framebuffer to the cubemap's face.
    *
    * @param {Number} [xOffset=0] An offset in the x direction in the cubemap where copying begins.
    * @param {Number} [yOffset=0] An offset in the y direction in the cubemap where copying begins.
    * @param {Number} [framebufferXOffset=0] An offset in the x direction in the framebuffer where copying begins from.
    * @param {Number} [framebufferYOffset=0] An offset in the y direction in the framebuffer where copying begins from.
    * @param {Number} [width=CubeMap's width] The width of the subimage to copy.
    * @param {Number} [height=CubeMap's height] The height of the subimage to copy.
    *
    * @exception {DeveloperError} Cannot call copyFromFramebuffer when the texture pixel data type is FLOAT.
    * @exception {DeveloperError} This CubeMap was destroyed, i.e., destroy() was called.
    * @exception {DeveloperError} xOffset must be greater than or equal to zero.
    * @exception {DeveloperError} yOffset must be greater than or equal to zero.
    * @exception {DeveloperError} framebufferXOffset must be greater than or equal to zero.
    * @exception {DeveloperError} framebufferYOffset must be greater than or equal to zero.
    * @exception {DeveloperError} xOffset + source.width must be less than or equal to width.
    * @exception {DeveloperError} yOffset + source.height must be less than or equal to height.
    * @exception {DeveloperError} This CubeMap was destroyed, i.e., destroy() was called.
    *
    * @example
    * // Copy the framebuffer contents to the +x cube map face.
    * cubeMap.positiveX.copyFromFramebuffer();
    */
    CubeMapFace.prototype.copyFromFramebuffer = function(xOffset, yOffset, framebufferXOffset, framebufferYOffset, width, height) {
    xOffset = defaultValue(xOffset, 0);
    yOffset = defaultValue(yOffset, 0);
    framebufferXOffset = defaultValue(framebufferXOffset, 0);
    framebufferYOffset = defaultValue(framebufferYOffset, 0);
    width = defaultValue(width, this._size);
    height = defaultValue(height, this._size);
    
    //>>includeStart('debug', pragmas.debug);
    if (xOffset < 0) {
    throw new DeveloperError('xOffset must be greater than or equal to zero.');
    }
    if (yOffset < 0) {
    throw new DeveloperError('yOffset must be greater than or equal to zero.');
    }
    if (framebufferXOffset < 0) {
    throw new DeveloperError('framebufferXOffset must be greater than or equal to zero.');
    }
    if (framebufferYOffset < 0) {
    throw new DeveloperError('framebufferYOffset must be greater than or equal to zero.');
    }
    if (xOffset + width > this._size) {
    throw new DeveloperError('xOffset + source.width must be less than or equal to width.');
    }
    if (yOffset + height > this._size) {
    throw new DeveloperError('yOffset + source.height must be less than or equal to height.');
    }
    if (this._pixelDatatype === PixelDatatype.FLOAT) {
    throw new DeveloperError('Cannot call copyFromFramebuffer when the texture pixel data type is FLOAT.');
    }
    //>>includeEnd('debug');
    
    var gl = this._gl;
    var target = this._textureTarget;
    
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(target, this._texture);
    gl.copyTexSubImage2D(this._targetFace, 0, xOffset, yOffset, framebufferXOffset, framebufferYOffset, width, height);
    gl.bindTexture(target, null);
    };
    
    return CubeMapFace;
    });
*/
    
}