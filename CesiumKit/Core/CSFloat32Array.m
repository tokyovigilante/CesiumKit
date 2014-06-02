//
//  CSFloat32Array.m
//  CesiumKit
//
//  Created by Ryan Walklin on 2/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSFloat32Array.h"

@implementation CSFloat32Array

-(instancetype)initWithCapacity:(UInt64)capacity
{
    self = [super initWithCapacity:capacity elementSize:sizeof(Float32)];
    return self;
}

-(instancetype)initWithValues:(Float32 *)values length:(UInt64)length
{
    self = [super initWithCapacity:length elementSize:sizeof(Float32)];
    if (self)
    {
        [_backingCache replaceBytesInRange:NSMakeRange(0, length * _elementSize) withBytes:values];
    }
    return self;
}

-(Float32)valueAtIndex:(UInt64)index
{
    Float32 *result = _backingCache.mutableBytes;
    return result[index];
}

-(void)setValue:(Float32)value atIndex:(UInt64)index
{
    [self expandArrayIfNeededForIndex:index];
    [_backingCache replaceBytesInRange:NSMakeRange(index * _elementSize, _elementSize) withBytes:&value];
}

@end
