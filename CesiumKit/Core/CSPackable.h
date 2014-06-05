//
//  CSPackable.h
//  CesiumKit
//
//  Created by Ryan on 5/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

@import Foundation;

@class CSFloat32Array;

@interface CSPackable : NSObject {
    UInt32 _packedLength;
}

@property (readonly) UInt32 packedLength;

-(void)pack:(CSFloat32Array *)array startingIndex:(UInt32)index;
-(instancetype)unpack:(CSFloat32Array *)array startingIndex:(UInt32)index;

@end
