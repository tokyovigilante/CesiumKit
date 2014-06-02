//
//  CSArray.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSArray.h"

@implementation CSArray

-(id)initWithCapacity:(UInt64)capacity elementSize:(size_t)elementSize
{
    self = [super init];
    if (self)
    {
        _elementSize = elementSize;
        _backingCache = [[NSMutableData alloc] initWithLength:capacity * elementSize];
    }
    return self;
}

-(UInt64)length
{
    return _backingCache.length / _elementSize;
}

-(void)expandArrayIfNeededForIndex:(UInt64)index
{
    UInt64 length = self.length;
    if (length < index)
    {
        UInt64 extraBytes = (index - length) * _elementSize;
        [_backingCache increaseLengthBy:extraBytes];
    }
}

-(void)bulkSetValues:(void *)values length:(UInt64)length
{
    [self expandArrayIfNeededForIndex:length];
    [_backingCache replaceBytesInRange:NSMakeRange(0, length * _elementSize) withBytes:values];
}

-(void *)values
{
    void *result = malloc(_backingCache.length);
    [_backingCache getBytes:result];
    return result;
}

@end
