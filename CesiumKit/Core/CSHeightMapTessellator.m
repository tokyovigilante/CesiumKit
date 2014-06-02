//
//  CSHeightMapTessellator.m
//  CesiumKit
//
//  Created by Ryan Walklin on 2/06/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

#import "CSHeightMapTessellator.h"

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

+(NSDictionary *)computeVertices:(NSDictionary *)options
{
    //>>includeStart('debug', pragmas.debug);
    if (!defined(options) || !defined(options.heightmap)) {
        throw new DeveloperError('options.heightmap is required.');
    }
    if (!defined(options.width) || !defined(options.height)) {
        throw new DeveloperError('options.width and options.height are required.');
    }
    if (!defined(options.vertices)) {
        throw new DeveloperError('options.vertices is required.');
    }
    if (!defined(options.nativeRectangle)) {
        throw new DeveloperError('options.nativeRectangle is required.');
    }
    if (!defined(options.skirtHeight)) {
        throw new DeveloperError('options.skirtHeight is required.');
    }
    //>>includeEnd('debug');
    
    // This function tends to be a performance hotspot for terrain rendering,
    // so it employs a lot of inlining and unrolling as an optimization.
    // In particular, the functionality of Ellipsoid.cartographicToCartesian
    // is inlined.
    
    var cos = Math.cos;
    var sin = Math.sin;
    var sqrt = Math.sqrt;
    var atan = Math.atan;
    var exp = Math.exp;
    var piOverTwo = CesiumMath.PI_OVER_TWO;
    var toRadians = CesiumMath.toRadians;
    
    var vertices = options.vertices;
    var heightmap = options.heightmap;
    var width = options.width;
    var height = options.height;
    var skirtHeight = options.skirtHeight;
    
    var isGeographic = defaultValue(options.isGeographic, true);
    var ellipsoid = defaultValue(options.ellipsoid, Ellipsoid.WGS84);
    
    var oneOverGlobeSemimajorAxis = 1.0 / ellipsoid.maximumRadius;
    
    var nativeRectangle = options.nativeRectangle;
    
    var geographicWest;
    var geographicSouth;
    var geographicEast;
    var geographicNorth;
    
    var rectangle = options.rectangle;
    if (!defined(rectangle)) {
        if (isGeographic) {
            geographicWest = toRadians(nativeRectangle.west);
            geographicSouth = toRadians(nativeRectangle.south);
            geographicEast = toRadians(nativeRectangle.east);
            geographicNorth = toRadians(nativeRectangle.north);
        } else {
            geographicWest = nativeRectangle.west * oneOverGlobeSemimajorAxis;
            geographicSouth = piOverTwo - (2.0 * atan(exp(-nativeRectangle.south * oneOverGlobeSemimajorAxis)));
            geographicEast = nativeRectangle.east * oneOverGlobeSemimajorAxis;
            geographicNorth = piOverTwo - (2.0 * atan(exp(-nativeRectangle.north * oneOverGlobeSemimajorAxis)));
        }
    } else {
        geographicWest = rectangle.west;
        geographicSouth = rectangle.south;
        geographicEast = rectangle.east;
        geographicNorth = rectangle.north;
    }
    
    var relativeToCenter = defaultValue(options.relativeToCenter, Cartesian3.ZERO);
    
    var structure = defaultValue(options.structure, HeightmapTessellator.DEFAULT_STRUCTURE);
    var heightScale = defaultValue(structure.heightScale, HeightmapTessellator.DEFAULT_STRUCTURE.heightScale);
    var heightOffset = defaultValue(structure.heightOffset, HeightmapTessellator.DEFAULT_STRUCTURE.heightOffset);
    var elementsPerHeight = defaultValue(structure.elementsPerHeight, HeightmapTessellator.DEFAULT_STRUCTURE.elementsPerHeight);
    var stride = defaultValue(structure.stride, HeightmapTessellator.DEFAULT_STRUCTURE.stride);
    var elementMultiplier = defaultValue(structure.elementMultiplier, HeightmapTessellator.DEFAULT_STRUCTURE.elementMultiplier);
    var isBigEndian = defaultValue(structure.isBigEndian, HeightmapTessellator.DEFAULT_STRUCTURE.isBigEndian);
    
    var granularityX = (nativeRectangle.east - nativeRectangle.west) / (width - 1);
    var granularityY = (nativeRectangle.north - nativeRectangle.south) / (height - 1);
    
    var radiiSquared = ellipsoid.radiiSquared;
    var radiiSquaredX = radiiSquared.x;
    var radiiSquaredY = radiiSquared.y;
    var radiiSquaredZ = radiiSquared.z;
    
    var vertexArrayIndex = 0;
    
    var minimumHeight = 65536.0;
    var maximumHeight = -65536.0;
    
    var startRow = 0;
    var endRow = height;
    var startCol = 0;
    var endCol = width;
    
    if (skirtHeight > 0) {
        --startRow;
        ++endRow;
        --startCol;
        ++endCol;
    }
    
    for ( var rowIndex = startRow; rowIndex < endRow; ++rowIndex) {
        var row = rowIndex;
        if (row < 0) {
            row = 0;
        }
        if (row >= height) {
            row = height - 1;
        }
        
        var latitude = nativeRectangle.north - granularityY * row;
        
        if (!isGeographic) {
            latitude = piOverTwo - (2.0 * atan(exp(-latitude * oneOverGlobeSemimajorAxis)));
        } else {
            latitude = toRadians(latitude);
        }
        
        var cosLatitude = cos(latitude);
        var nZ = sin(latitude);
        var kZ = radiiSquaredZ * nZ;
        
        var v = (latitude - geographicSouth) / (geographicNorth - geographicSouth);
        
        for ( var colIndex = startCol; colIndex < endCol; ++colIndex) {
            var col = colIndex;
            if (col < 0) {
                col = 0;
            }
            if (col >= width) {
                col = width - 1;
            }
            
            var longitude = nativeRectangle.west + granularityX * col;
            
            if (!isGeographic) {
                longitude = longitude * oneOverGlobeSemimajorAxis;
            } else {
                longitude = toRadians(longitude);
            }
            
            var terrainOffset = row * (width * stride) + col * stride;
            
            var heightSample;
            if (elementsPerHeight === 1) {
                heightSample = heightmap[terrainOffset];
            } else {
                heightSample = 0;
                
                var elementOffset;
                if (isBigEndian) {
                    for (elementOffset = 0; elementOffset < elementsPerHeight; ++elementOffset) {
                        heightSample = (heightSample * elementMultiplier) + heightmap[terrainOffset + elementOffset];
                    }
                } else {
                    for (elementOffset = elementsPerHeight - 1; elementOffset >= 0; --elementOffset) {
                        heightSample = (heightSample * elementMultiplier) + heightmap[terrainOffset + elementOffset];
                    }
                }
            }
            
            heightSample = heightSample * heightScale + heightOffset;
            
            maximumHeight = Math.max(maximumHeight, heightSample);
            minimumHeight = Math.min(minimumHeight, heightSample);
            
            if (colIndex !== col || rowIndex !== row) {
                heightSample -= skirtHeight;
            }
            
            var nX = cosLatitude * cos(longitude);
            var nY = cosLatitude * sin(longitude);
            
            var kX = radiiSquaredX * nX;
            var kY = radiiSquaredY * nY;
            
            var gamma = sqrt((kX * nX) + (kY * nY) + (kZ * nZ));
            var oneOverGamma = 1.0 / gamma;
            
            var rSurfaceX = kX * oneOverGamma;
            var rSurfaceY = kY * oneOverGamma;
            var rSurfaceZ = kZ * oneOverGamma;
            
            vertices[vertexArrayIndex++] = rSurfaceX + nX * heightSample - relativeToCenter.x;
            vertices[vertexArrayIndex++] = rSurfaceY + nY * heightSample - relativeToCenter.y;
            vertices[vertexArrayIndex++] = rSurfaceZ + nZ * heightSample - relativeToCenter.z;
            
            vertices[vertexArrayIndex++] = heightSample;
            
            var u = (longitude - geographicWest) / (geographicEast - geographicWest);
            
            vertices[vertexArrayIndex++] = u;
            vertices[vertexArrayIndex++] = v;
        }
    }
    
    return {
        maximumHeight : maximumHeight,
        minimumHeight : minimumHeight
    };
};


@end
