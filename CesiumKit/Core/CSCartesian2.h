//
//  CSCartesian2.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe and Cesium.js - http://www.cesium.org
//

@import Foundation;

@interface CSCartesian2 : NSObject

@property (assign) Float64 x;
@property (assign) Float64 y;

-(id)initWithX:(Float64)x Y:(Float64)y;

@end
