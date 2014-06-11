//
//  CSHeightMapTessellator.m
//  CesiumKit
//
//  Created by Ryan Walklin on 2/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSHeightMapTessellator.h"

#import "CSFloat32Array.h"
#import "CSRectangle.h"
#import "CSHeightMapStructure.h"

@implementation CSHeightMapTessellator


+(NSDictionary *)defaultStructure
{
    return @{ @"heightScale" : @1.0,
              @"heightOffset" : @0.0,
              @"elementsPerHeight" : @1,
              @"stride" : @1,
              @"elementMultiplier" : @256.0,
              @"isBigEndian" : @NO };
}

inline Float64 toRadians(Float64 degrees)
{
    return degrees * M_PI / 180.0;
}

+(NSDictionary *)computeVertices:(NSDictionary *)options
{
    NSAssert(options[@"heightMap"] != nil, @"options.heightmap is required");
    CSArray *heightMap = options[@"heightMap"];
    UInt8 *heightMapBuffer = [heightMap values];

    NSAssert((options[@"height"] != nil && options[@"width"] != nil), @"options.width and options.height are required");
    UInt32 height = ((NSNumber *)options[@"height"]).unsignedIntValue;
    UInt32 width = ((NSNumber *)options[@"width"]).unsignedIntValue;

    NSAssert(options[@"vertices"] != nil, @"options.vertices is required");
    CSFloat32Array *vertices = options[@"vertices"];
    Float32 verticesBuffer[vertices.length * 6];
    
    NSAssert(options[@"nativeRectangle"] != nil, @"options.nativeRectangle is required");
    CSRectangle *nativeRectangle = options[@"nativeRectangle"];
    
    NSAssert(options[@"rectangle"] != nil, @"options.rectangle is required");
    CSRectangle *rectangle = options[@"rectangle"];

    Float64 skirtHeight = 0.0;
    if (options[@"skirtHeight"])
    {
        skirtHeight = ((NSNumber *)options[@"skirtHeight"]).doubleValue;
    }
    
    BOOL isGeographic = NO;
    if (options[@"isGeographic"])
    {
        isGeographic = ((NSNumber *)options[@"skirtHeight"]).boolValue;
    }

    Ellipsoid *ellipsoid = options[@"ellipsoid"];
    if (!ellipsoid)
    {
        ellipsoid = [Ellipsoid wgs84Ellipsoid];
    }
    Float64 oneOverGlobeSemimajorAxis = 1.0 / ellipsoid.maximumRadius;
    
    Float64 geographicWest;
    Float64 geographicSouth;
    Float64 geographicEast;
    Float64 geographicNorth;
    
    if (!rectangle)
    {
        if (isGeographic)
        {
            geographicWest = toRadians(nativeRectangle.west);
            geographicSouth = toRadians(nativeRectangle.south);
            geographicEast = toRadians(nativeRectangle.east);
            geographicNorth = toRadians(nativeRectangle.north);
        }
        else
        {
            geographicWest = nativeRectangle.west * oneOverGlobeSemimajorAxis;
            geographicSouth = M_PI_2 - (2.0 * atan(exp(-nativeRectangle.south * oneOverGlobeSemimajorAxis)));
            geographicEast = nativeRectangle.east * oneOverGlobeSemimajorAxis;
            geographicNorth = M_PI_2 - (2.0 * atan(exp(-nativeRectangle.north * oneOverGlobeSemimajorAxis)));
        }
    }
    else
    {
        geographicWest = rectangle.west;
        geographicSouth = rectangle.south;
        geographicEast = rectangle.east;
        geographicNorth = rectangle.north;
    }
    
    Cartesian3 *relativeToCenter = options[@"relativeToCenter"];
    if (!relativeToCenter)
    {
        relativeToCenter = [Cartesian3 zero];
    }
    
    CSHeightMapStructure *structure = options[@"structure"];
    if (!structure)
    {
        structure = [CSHeightMapStructure defaultStructure];
    }
    
    Float64 heightScale = structure.heightScale;
    Float64 heightOffset = structure.heightOffset;
    UInt32 elementsPerHeight = structure.elementsPerHeight;
    UInt32 stride = structure.stride;
    Float64 elementMultiplier = structure.elementMultiplier;
    BOOL isBigEndian = structure.isBigEndian;

    Float64 granularityX = (nativeRectangle.east - nativeRectangle.west) / (width - 1);
    Float64 granularityY = (nativeRectangle.north - nativeRectangle.south) / (height - 1);
    
    Float64 radiiSquaredX = ellipsoid.radiiSquared.x;
    Float64 radiiSquaredY = ellipsoid.radiiSquared.y;
    Float64 radiiSquaredZ = ellipsoid.radiiSquared.z;
    
    UInt32 vertexArrayIndex = 0;
    
    Float64 minimumHeight = 65536.0;
    Float64 maximumHeight = -65536.0;
    
    SInt32 startRow = 0;
    UInt32 endRow = height;
    SInt32 startCol = 0;
    UInt32 endCol = width;
    
    if (skirtHeight > 0)
    {
        startRow--;
        endRow++;
        startCol--;
        endCol++;
    }
    
    for (UInt32 rowIndex = startRow; rowIndex < endRow; ++rowIndex)
    {
        UInt32 row = MAX(rowIndex, 0);

        if (row >= height)
        {
            row = height - 1;
        }
        
        Float64 latitude = nativeRectangle.north - granularityY * row;
        
        if (!isGeographic)
        {
            latitude = M_PI_2 - (2.0 * atan(exp(-latitude * oneOverGlobeSemimajorAxis)));
        }
        else
        {
            latitude = toRadians(latitude);
        }
        
        Float64 cosLatitude = cos(latitude);
        Float64 nZ = sin(latitude);
        Float64 kZ = radiiSquaredZ * nZ;
        
        Float64 v = (latitude - geographicSouth) / (geographicNorth - geographicSouth);
        
        for (UInt32 colIndex = startCol; colIndex < endCol; ++colIndex) {
            UInt32 col = MAX(colIndex, 0);
            
            if (col >= width) {
                col = width - 1;
            }
            
            Float64 longitude = nativeRectangle.west + granularityX * col;
            
            if (!isGeographic)
            {
                longitude = longitude * oneOverGlobeSemimajorAxis;
            }
            else
            {
                longitude = toRadians(longitude);
            }
            
            UInt32 terrainOffset = row * (width * stride) + col * stride;
            
            UInt32 heightSample;
            if (elementsPerHeight == 1)
            {
                heightSample = heightMapBuffer[terrainOffset];
            }
            else
            {
                heightSample = 0;
                
                SInt32 elementOffset;
                if (isBigEndian)
                {
                    for (elementOffset = 0; elementOffset < elementsPerHeight; ++elementOffset)
                    {
                        heightSample = (heightSample * elementMultiplier) + heightMapBuffer[terrainOffset + elementOffset];
                    }
                }
                else
                {
                    for (elementOffset = elementsPerHeight - 1; elementOffset >= 0; --elementOffset)
                    {
                        heightSample = (heightSample * elementMultiplier) + heightMapBuffer[terrainOffset + elementOffset];
                    }
                }
            }
            
            heightSample = heightSample * heightScale + heightOffset;
            
            maximumHeight = MAX(maximumHeight, heightSample);
            minimumHeight = MIN(minimumHeight, heightSample);
            
            if (colIndex != col || rowIndex != row)
            {
                heightSample -= skirtHeight;
            }
            
            Float64 nX = cosLatitude * cos(longitude);
            Float64 nY = cosLatitude * sin(longitude);
            
            Float64 kX = radiiSquaredX * nX;
            Float64 kY = radiiSquaredY * nY;
            
            Float64 gamma = sqrt((kX * nX) + (kY * nY) + (kZ * nZ));
            Float64 oneOverGamma = 1.0 / gamma;
            
            Float64 rSurfaceX = kX * oneOverGamma;
            Float64 rSurfaceY = kY * oneOverGamma;
            Float64 rSurfaceZ = kZ * oneOverGamma;
            
            verticesBuffer[vertexArrayIndex++] = rSurfaceX + nX * heightSample - relativeToCenter.x;
            verticesBuffer[vertexArrayIndex++] = rSurfaceY + nY * heightSample - relativeToCenter.y;
            verticesBuffer[vertexArrayIndex++] = rSurfaceZ + nZ * heightSample - relativeToCenter.z;
            
            verticesBuffer[vertexArrayIndex++] = heightSample;
            
            Float64 u = (longitude - geographicWest) / (geographicEast - geographicWest);
            
            verticesBuffer[vertexArrayIndex++] = u;
            verticesBuffer[vertexArrayIndex++] = v;
        }
    }
    free(heightMapBuffer);
    heightMapBuffer = nil;
    [vertices bulkSetValues:verticesBuffer length:vertexArrayIndex];
    return @{ @"vertices" : vertices,
              @"maximumHeight" : [NSNumber numberWithDouble:maximumHeight],
              @"minimumHeight" : [NSNumber numberWithDouble:minimumHeight] };
};


@end
