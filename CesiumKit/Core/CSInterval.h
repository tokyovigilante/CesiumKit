//
//  CSInterval.h
//  CesiumKit
//
//  Created by Ryan Walklin on 5/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSInterval : NSObject

@property Float64 start;
@property Float64 stop;

-(id)initWithStart:(Float64)start stop:(Float64)stop;
+(CSInterval *)interval;

@end
