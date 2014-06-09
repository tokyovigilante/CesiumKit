//
//  CSCartographic.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe
//

@import Foundation;

@interface CSCartographic : NSObject

@property (readonly) Float64 latitude;
@property (readonly) Float64 longitude;
@property (nonatomic) Float64 height; // metres

-(id)initWithLatitude:(Float64)latitude longitude:(Float64)longitude height:(Float64)height;
-(id)initWithLatitude:(Float64)latitude longitude:(Float64)longitude;

-(BOOL)equals:(CSCartographic *)other;

@end
