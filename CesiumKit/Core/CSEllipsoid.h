//
//  CSEllipsoid.h
//  CesiumKit
//
//  Created by Ryan Walklin on 1/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//  Based on Openglobe C# virtual globe code - https://github.com/virtualglobebook/OpenGlobe
//

@import Foundation;

@class CSCartesian3, CSGeodetic2D, CSGeodetic3D;

@interface CSEllipsoid : NSObject

@property CSCartesian3 *radii;
@property CSCartesian3 *radiiSquared;
@property CSCartesian3 *oneOverRadiiSquared;

-(id)initWithX:(Float64)x Y:(Float64)y Z:(Float64)z;

+(CSEllipsoid *)wgs84Ellipsoid; // 6378.1km eq radius, 6356.8km polar radius
+(CSEllipsoid *)scaledwgs4ScaledEllipsoid;
+(CSEllipsoid *)unitSphereEllipsoid; // 1.0 unit radius

+(CSEllipsoid *)ellipsoidWithCartesian3:(CSCartesian3 *)cartesian3;

-(CSCartesian3 *)centricSurfaceNormal:(CSCartesian3 *)positionOnEllipsoid;
-(CSCartesian3 *)geodeticSurfaceNormalForPosition:(CSCartesian3 *)positionOnEllipsoid;
-(CSCartesian3 *)geodeticSurfaceNormalForGeodetic3D:(CSGeodetic3D *)geodetic3D;

-(Float64)minimumRadius;
-(Float64)maximumRadius;

// takes two double pointers, returns number of intersections,
-(UInt32)intersections:(CSCartesian3 *)origin direction:(CSCartesian3 *)direction first:(Float64 *)first second:(Float64 *)second;

-(CSCartesian3 *)vector3DfromGeodetic2D:(CSGeodetic2D *)geodetic2D;
-(CSCartesian3 *)vector3DfromGeodetic3D:(CSGeodetic3D *)geodetic3D;

-(NSArray *)geodetic2DArrayFromPositionArray:(NSArray *)positionArray;
-(NSArray *)geodetic3DArrayFromPositionArray:(NSArray *)positionArray;

-(CSGeodetic2D *)geodetic2DFromPosition:(CSCartesian3 *)position;
-(CSGeodetic3D *)geodetic3DFromPosition:(CSCartesian3 *)position;

-(CSCartesian3 *)scaleToGeodeticSurface:(CSCartesian3 *)position;
-(CSCartesian3 *)scaleToGeocentricSurface:(CSCartesian3 *)position;

-(NSArray *)computeCurve:(CSCartesian3 *)start stop:(CSCartesian3 *)stop granularity:(Float64)granularity;

@end


