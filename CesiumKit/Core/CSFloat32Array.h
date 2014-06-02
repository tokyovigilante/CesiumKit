//
//  CSFloat32Array.h
//  CesiumKit
//
//  Created by Ryan Walklin on 2/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSArray.h"

@interface CSFloat32Array : CSArray

-(instancetype)initWithCapacity:(UInt64)capacity;
-(instancetype)initWithValues:(Float32 *)values length:(UInt64)length;

-(Float32)valueAtIndex:(UInt64)index;

@end
