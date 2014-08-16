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
    
    init(texture: Int, target: Int, targetFace: Int, pixelFormat: PixelFormat, pixelDatatype: PixelDatatype, size: Int, preMultiplyAlpha: Bool, flipY: Bool) {
        self.texture = texture
        self.target = target
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
        
        assert(xOffset + source.width <= size, "xOffset + source.width must be less than or equal to width")
        assert(yOffset + source.height <= size, "yOffset + source.height must be less than or equal to height")
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 4)
        //glpixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, this._preMultiplyAlpha);
        //gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, this._flipY);
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(target, texture)
        
        if source.arrayBufferView != nil {
            glTexSubImage2D(target, 0, xOffset, yOffset, source.width, source.height, pixelFormat, pixelDatatype, source.arrayBufferView)
            /*} else {
            gl.texSubImage2D(this._targetFace, 0, xOffset, yOffset, this._pixelFormat, this._pixelDatatype, source);
            }*/
            glBindTexture(target, 0)
        }
    }
    
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
    func copyFromFramebuffer(xOffset: Int = 0, yOffset: Int = 0, framebufferXOffset: Int = 0, framebufferYOffset: Int = 0, width: Int?, height: Int?) {
        
        let copyWidth = width ?? size
        let copyHeight = height ?? size
        
        assert(xOffset >= 0 && yOffset >= 0, "xOffset and yOffset must be greater than or equal to zero")
        assert(framebufferXOffset >= 0 && framebufferYOffset >= 0, "framebufferXOffset and framebufferYOffset must be greater than or equal to zero")
        
        assert(xOffset + copyWidth <= size, "xOffset + source.width must be less than or equal to width")
        assert(yOffset + copyHeight <= size, "yOffset + source.height must be less than or equal to height")
    
        assert(pixelDatatype != PixelDatatype.Float, "Cannot call copyFromFramebuffer when the texture pixel data type is FLOAT")
        
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(target, texture)
        glCopyTexSubImage2D(targetFace, 0, xOffset, yOffset, framebufferXOffset, framebufferYOffset, copyWidth, copyHeight)
        glBindTexture(target, 0)
    }

}

