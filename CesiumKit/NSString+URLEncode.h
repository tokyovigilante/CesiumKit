//
//  NSString_NSString_URLEncode.h
//  Karearea
//
//  Created by Ryan Walklin on 5/08/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import <Foundation/Foundation.h>

// From http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string/3426140#3426140
@interface NSString (NSString_Extended)

- (NSString *)urlencode;

@end
