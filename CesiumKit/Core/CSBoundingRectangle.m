//
//  CSBoundingRectangle.m
//  CesiumKit
//
//  Created by Ryan Walklin on 11/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSBoundingRectangle.h"

#import "CSRectangle.h"
#import "CSProjection.h"
#import "CSGeographicProjection.h"
#import "CSCartesian2.h"
#import "CSCartesian3.h"

@import UIKit.UIGeometry;

@implementation CSBoundingRectangle 

-(id)initWithX:(Float64)x Y:(Float64)y width:(Float64)width height:(Float64)height
{
    self = [super init];
    if (self)
    {
        _rect.origin.x = x;
        _rect.origin.y = y;
        _rect.size.width = width;
        _rect.size.height = height;
    }
    return self;
}

-(id)initWithRect:(CGRect)rect
{
    self = [super init];
    if (self)
    {
        _rect = rect;
    }
    return self;
}

+(CSBoundingRectangle *)fromPoints:(NSArray *)points
{
    NSAssert(points != nil, @"No points provided");
    
    Float64 minimumX = 0.0;
    Float64 minimumY = 0.0;
    
    Float64 maximumX = 0.0;
    Float64 maximumY = 0.0;
    
    
    for (NSNumber *point in points)
    {
        CGPoint pointCG = [point CGPointValue];
        
        minimumX = MIN(pointCG.x, minimumX);
        minimumY = MIN(pointCG.y, minimumY);
        
        maximumX = MAX(pointCG.x, maximumX);
        maximumX = MAX(pointCG.y, maximumX);
    }
    
    return [[CSBoundingRectangle alloc] initWithRect:CGRectMake(minimumX, minimumY, maximumX - minimumX, maximumY - minimumY)];
}


+(CSBoundingRectangle *)fromRectangle:(CSRectangle *)rectangle projection:(CSProjection *)projection
{
    NSAssert(rectangle != nil, @"No rectangle provided");
    
    if (!projection)
    {
        projection = [[CSGeographicProjection alloc] initWithEllipsoid:nil];
    }
    CSCartesian3 *lowerLeft = [projection project:rectangle.southwest];
    CSCartesian3 *upperRight = [projection project:rectangle.northeast];
    
    upperRight = [upperRight subtract:lowerLeft];
    
    return [[CSBoundingRectangle alloc] initWithX:lowerLeft.x Y:lowerLeft.y width:upperRight.x height:upperRight.y];
}

-(CSBoundingRectangle *)unionRect:(CSBoundingRectangle *)other
{
    return [[CSBoundingRectangle alloc] initWithRect:CGRectUnion(self.rect, other.rect)];
}

-(CSBoundingRectangle *)expandToPoint:(CSCartesian2 *)point
{
    NSAssert(point != nil, @"No point provided");
    
    CGRect result = self.rect;
    
    Float64 width = point.x - result.origin.x;
    Float64 height  = point.y - result.origin.y;
    
    if (width > result.size.width)
    {
        result.size.width = width;
    }
    else if (width < 0)
    {
        result.size.width -= width;
        result.origin.x = point.x;
    }
    
    if (height > result.size.height)
    {
        result.size.height = height;
    }
    else if (height < 0)
    {
        result.size.height -= height;
        result.origin.y = point.y;
    }
    
    return [[CSBoundingRectangle alloc] initWithRect:result];
}

-(BOOL)intersects:(CSBoundingRectangle *)other
{
    return (CGRectIntersectsRect(self.rect, other.rect) == true);
}

-(BOOL)equals:(CSBoundingRectangle *)other
{
    return (CGRectEqualToRect(self.rect, other.rect) == true);
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[CSBoundingRectangle alloc] initWithRect:self.rect];
}

@end

