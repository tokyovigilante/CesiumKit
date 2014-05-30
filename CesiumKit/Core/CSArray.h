//
//  CSArray.h
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Thin wrapper around NSMutableData to simulate JS arrays */

@interface CSArray : NSObject {
    @protected
    NSMutableData *_backingCache;
    size_t _elementSize;
}

-(instancetype)initWithCapacity:(UInt64)capacity elementSize:(size_t)elementSize;

-(UInt64)length;
-(void)expandArrayIfNeededForIndex:(UInt64)index;

-(void)bulkSetValues:(void *)values length:(UInt64)length;
-(void *)values;

@end
