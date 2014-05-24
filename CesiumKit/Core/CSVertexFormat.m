//
//  CSVertexFormat.m
//  CesiumKit
//
//  Created by Ryan Walklin on 22/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSVertexFormat.h"

@implementation CSVertexFormat

-(instancetype)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        if (!options)
        {
            NSNumber *position = options[@"position"];
            position == nil ? _position = NO : (_position = position.boolValue);

            NSNumber *normal = options[@"normal"];
            normal == nil ? _normal = NO : (_normal = normal.boolValue);
            
            NSNumber *st = options[@"st"];
            st == nil ? _st = NO : (_st = st.boolValue);

            NSNumber *binormal = options[@"binormal"];
            binormal == nil ? _binormal = NO : (_binormal = binormal.boolValue);
            
            NSNumber *tangent = options[@"binormal"];
            tangent == nil ? _tangent = NO : (_tangent = tangent.boolValue);
        }
    }
    return self;
}

+(CSVertexFormat *)positionOnly
{
    return [[CSVertexFormat alloc] initWithOptions:@{ @"position" : @YES }];
}

+(CSVertexFormat *)positionAndNormal

{
    return [[CSVertexFormat alloc] initWithOptions:@{ @"position" : @YES,
                                                      @"normal" : @YES }];
}

+(CSVertexFormat *)positionNormalAndST
{
    return [[CSVertexFormat alloc] initWithOptions:@{ @"position" : @YES,
                                                      @"normal" : @YES,
                                                      @"st" : @YES }];
}

+(CSVertexFormat *)positionAndST
{
    return [[CSVertexFormat alloc] initWithOptions:@{ @"position" : @YES,
                                                      @"st" : @YES }];
}

+(CSVertexFormat *)all
{
    return [[CSVertexFormat alloc] initWithOptions:@{ @"position" : @YES,
                                                      @"normal" : @YES,
                                                      @"st" : @YES,
                                                      @"binormal" : @YES,
                                                      @"tangent" : @YES }];
}

+(CSVertexFormat *)default
{
    return [CSVertexFormat positionNormalAndST];
}

@end
