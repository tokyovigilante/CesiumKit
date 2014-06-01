//
//  CSHeightMapStructure.m
//  CesiumKit
//
//  Created by Ryan Walklin on 1/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSHeightMapStructure.h"


@implementation CSHeightMapStructure

-(instancetype)initWithDictionary:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        NSDictionary *defaultOptions = @{ @"heightScale" : @1.0,
                                          @"heightOffset" : @0.0,
                                          @"elementsPerHeight" : @1,
                                          @"stride" : @1,
                                          @"elementMultiplier" : @256.0,
                                          @"isBigEndian" : @NO };
        if (!options)
        {
            options = defaultOptions;
        }
        NSNumber *heightScale = options[@"heightScale"];
        if (heightScale)
        {
            _heightScale = heightScale.doubleValue;
        }
        else
        {
            _heightScale = ((NSNumber *)(defaultOptions[@"heightScale"])).doubleValue;
        }
        NSNumber *heightOffset = options[@"heightOffset"];
        if (heightOffset)
        {
            _heightOffset = heightOffset.doubleValue;
        }
        else
        {
            _heightOffset = ((NSNumber *)(defaultOptions[@"heightOffset"])).doubleValue;
        }
        NSNumber *elementsPerHeight = options[@"elementsPerHeight"];
        if (elementsPerHeight)
        {
            _elementsPerHeight = elementsPerHeight.doubleValue;
        }
        else
        {
            _elementsPerHeight = ((NSNumber *)(defaultOptions[@"elementsPerHeight"])).unsignedIntValue;
        }
        NSNumber *stride = options[@"stride"];
        if (stride)
        {
            _stride = stride.doubleValue;
        }
        else
        {
            _stride = ((NSNumber *)(defaultOptions[@"stride"])).unsignedIntValue;
        }
        NSNumber *elementMultiplier = options[@"elementMultiplier"];
        if (elementMultiplier)
        {
            _elementMultiplier = elementMultiplier.doubleValue;
        }
        else
        {
            _elementMultiplier = ((NSNumber *)(defaultOptions[@"elementMultiplier"])).doubleValue;
        }
        NSNumber *isBigEndian = options[@"isBigEndian"];
        if (isBigEndian)
        {
            _isBigEndian = isBigEndian.doubleValue;
        }
        else
        {
            _isBigEndian = ((NSNumber *)(defaultOptions[@"isBigEndian"])).doubleValue;
        }
    }
    return self;
}

+(CSHeightMapStructure *)defaultStructure
{
    return [[CSHeightMapStructure alloc] initWithDictionary:nil];
}

@end
