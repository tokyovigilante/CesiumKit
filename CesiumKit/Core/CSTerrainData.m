//
//  CSTerrainData.m
//  CesiumKit
//
//  Created by Ryan Walklin on 30/05/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSTerrainData.h"

@implementation CSTerrainData

-(id)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(void)createMesh:(CSTilingScheme *)tilingScheme X:(UInt32)x Y:(UInt32)y level:(UInt32)level completionBlock:(void (^)(CSTerrainMesh *terrainMesh))completionBlock
{
    NSAssert(NO, @"Invalid base class");
}

-(Float64)interpolateHeightForRectangle:(CSRectangle *)rectangle longitude:(Float64)longitude latitude:(Float64)latitude
{
    NSAssert(NO, @"Invalid base class");
    return 0.0;
}

-(BOOL)isChildAvailableForThisX:(UInt32)thisX thisY:(UInt32)thisY childX:(UInt32)childX childY:(UInt32)childY
{
    NSAssert(NO, @"Invalid base class");
    return NO;
}

-(void)upsample:(CSTilingScheme *)tilingScheme thisX:(UInt32)thisX thisY:(UInt32)thisY thisLevel:(UInt32)thisLevel descendantX:(UInt32)descendantX descendantY:(UInt32)descendantY descendantLevelcompletionBlock:(void (^)(CSTerrainData *terrainData))completionBlock
{
    NSAssert(NO, @"Invalid base class");
}

-(BOOL)wasCreatedByUpsampling
{
    NSAssert(NO, @"Invalid base class");
    return NO;
}

@end


