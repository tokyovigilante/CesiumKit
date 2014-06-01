//
//  CSHeightMapStructure.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * @param {Object} [options.structure] An object describing the structure of the height data.
 * @param {Number} [options.structure.heightScale=1.0] The factor by which to multiply height samples in order to obtain
 *                 the height above the heightOffset, in meters.  The heightOffset is added to the resulting
 *                 height after multiplying by the scale.
 * @param {Number} [options.structure.heightOffset=0.0] The offset to add to the scaled height to obtain the final
 *                 height in meters.  The offset is added after the height sample is multiplied by the
 *                 heightScale.
 * @param {Number} [options.structure.elementsPerHeight=1] The number of elements in the buffer that make up a single height
 *                 sample.  This is usually 1, indicating that each element is a separate height sample.  If
 *                 it is greater than 1, that number of elements together form the height sample, which is
 *                 computed according to the structure.elementMultiplier and structure.isBigEndian properties.
 * @param {Number} [options.structure.stride=1] The number of elements to skip to get from the first element of
 *                 one height to the first element of the next height.
 * @param {Number} [options.structure.elementMultiplier=256.0] The multiplier used to compute the height value when the
 *                 stride property is greater than 1.  For example, if the stride is 4 and the strideMultiplier
 *                 is 256, the height is computed as follows:
 *                 `height = buffer[index] + buffer[index + 1] * 256 + buffer[index + 2] * 256 * 256 + buffer[index + 3] * 256 * 256 * 256`
 *                 This is assuming that the isBigEndian property is false.  If it is true, the order of the
 *                 elements is reversed.
 * @param {Boolean} [options.structure.isBigEndian=false] Indicates endianness of the elements in the buffer when the
 *                  stride property is greater than 1.  If this property is false, the first element is the
 *                  low-order element.  If it is true, the first element is the high-order element.
 */
@interface CSHeightMapStructure : NSObject

@property (readonly) Float64 heightScale;
@property (readonly) Float64 heightOffset;
@property (readonly) UInt32 elementsPerHeight;
@property (readonly) UInt32 stride;
@property (readonly) Float64 elementMultiplier;
@property (readonly) BOOL isBigEndian;

-(instancetype)initWithDictionary:(NSDictionary *)options;

+(CSHeightMapStructure *)defaultStructure;

@end
