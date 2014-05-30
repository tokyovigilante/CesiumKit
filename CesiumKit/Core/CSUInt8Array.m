//
//  CSUInt8Array.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSUInt8Array.h"

@implementation CSUInt8Array

-(instancetype)initWithCapacity:(UInt64)capacity
{
    self = [super initWithCapacity:capacity elementSize:sizeof(UInt8)];
    return self;
}

-(instancetype)initWithValues:(UInt8 *)values length:(UInt64)length
{
    self = [super initWithCapacity:length elementSize:sizeof(UInt8)];
    if (self)
    {
        [_backingCache replaceBytesInRange:NSMakeRange(0, length * _elementSize) withBytes:values];
    }
    return self;
}

-(UInt8)valueAtIndex:(UInt64)index
{
    UInt16 *result = _backingCache.mutableBytes;
    return result[index];
}

-(void)setValue:(UInt8)value atIndex:(UInt64)index
{
    [self expandArrayIfNeededForIndex:index];
    [_backingCache replaceBytesInRange:NSMakeRange(index * _elementSize, _elementSize) withBytes:&value];
}

@end
