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

-(Float64)interpolateHeightAtLongitude:(Float64)longitude latitude:(Float64)latitude
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

/**
 * Gets a value indicating whether or not this terrain data was created by upsampling lower resolution
 * terrain data.  If this value is false, the data was obtained from some other source, such
 * as by downloading it from a remote server.  This method should return true for instances
 * returned from a call to {@link TerrainData#upsample}.
 * @memberof TerrainData
 * @function
 *
 * @returns {Boolean} True if this instance was created by upsampling; otherwise, false.
 */
-(BOOL)wasCreatedByUpsampling
{
    NSAssert(NO, @"Invalid base class");
    return NO;
}

@end


