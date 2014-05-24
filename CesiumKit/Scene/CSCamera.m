//
//  CSCamera.m
//  CesiumKit
//
//  Created by Ryan Walklin on 8/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSCamera.h"

#import "CSCartesian3.h"
#import "CSMatrix4.h"
#import "CSGeographicProjection.h"

@interface CSCamera ()

@property (nonatomic, weak) CSScene *scene;
@property BOOL sceneIs3D;
@property (nonatomic) CSProjection *projection;
@property (nonatomic) CSCartesian3 *maxCoord;
@property (nonatomic) CSFrustum *max2DFrustum;

-(Float64)getHeading2D;
-(Float64)getHeading3D;
-(void)setHeading2D:(Float64)angle;
-(void)setHeading3D:(Float64)angle;
-(Float64)getTiltCV;
-(Float64)getTilt3D;

@end

@implementation CSCamera

@end
