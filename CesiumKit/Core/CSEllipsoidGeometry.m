//
//  CSEllipsoidGeometry.m
//  CesiumKit
//
//  Created by Ryan Walklin on 22/05/14.
//  Copyright (c) 2014 Ryan Walklin. All rights reserved.
//

#import "CSEllipsoidGeometry.h"

#import "CSCartesian3.h"
#import "CSVertexFormat.h"
#import "CSEllipsoid.h"

@interface CSEllipsoidGeometry ()

@property (readonly) CSCartesian3 *radii;
@property (readonly) UInt32 stackPartitions;
@property (readonly) UInt32 slicePartitions;
@property (readonly) CSVertexFormat *vertexFormat;
@property (readonly) NSString *workerName;

@end

@implementation CSEllipsoidGeometry

-(id)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        _radii = options[@"radii"];
        if (!_radii)
        {
            _radii = [[CSCartesian3 alloc] initWithX:1.0 Y:1.0 Z:1.0];
        }
        
        NSNumber *stackPartitions = options[@"stackPartitions"];
        stackPartitions == nil ? _stackPartitions = 64 : (_stackPartitions = stackPartitions.unsignedIntValue);
        NSAssert(_stackPartitions >= 3, @"Need at least 3 stackPartitions");
        
        NSNumber *slicePartitions = options[@"slicePartitions"];
        slicePartitions == nil ? _slicePartitions = 64 : (_slicePartitions = slicePartitions.unsignedIntValue);
        NSAssert(_slicePartitions >= 3, @"Need at least 3 slicePartitions");

        _vertexFormat = options[@"vertexFormat"];
        if (!_vertexFormat)
        {
            _vertexFormat = [CSVertexFormat default];
        }
        
        _workerName = @"createEllipsoidGeometry";
    }
    return self;
}

-(CSGeometry *)createGeometry
{
    CSEllipsoid *ellipsoid = [CSEllipsoid ellipsoidWithCartesian3:self.radii];
    
    // The extra slice and stack are for duplicating points at the x axis and poles.
    // We need the texture coordinates to interpolate from (2 * pi - delta) to 2 * pi instead of
    // (2 * pi - delta) to 0.
    UInt32 slicePartitions = self.slicePartitions + 1;
    UInt32 stackPartitions = self.stackPartitions + 1;
    
    
    UInt32 vertexCount = stackPartitions * slicePartitions;
    Float64 positions[vertexCount * 3];
    
    UInt32 numIndices = 6 * (slicePartitions - 1) * (stackPartitions - 1);
    
    var indices = IndexDatatype.createTypedArray(vertexCount, numIndices);
    
    var normals = (vertexFormat.normal) ? new Float32Array(vertexCount * 3) : undefined;
    var tangents = (vertexFormat.tangent) ? new Float32Array(vertexCount * 3) : undefined;
    var binormals = (vertexFormat.binormal) ? new Float32Array(vertexCount * 3) : undefined;
    var st = (vertexFormat.st) ? new Float32Array(vertexCount * 2) : undefined;
    
    var cosTheta = new Array(slicePartitions);
    var sinTheta = new Array(slicePartitions);
    
    var i;
    var j;
    var index = 0;
    
    for (i = 0; i < slicePartitions; i++) {
        var theta = CesiumMath.TWO_PI * i / (slicePartitions - 1);
        cosTheta[i] = cos(theta);
        sinTheta[i] = sin(theta);
        
        // duplicate first point for correct
        // texture coordinates at the north pole.
        positions[index++] = 0.0;
        positions[index++] = 0.0;
        positions[index++] = radii.z;
    }
    
    for (i = 1; i < stackPartitions - 1; i++) {
        var phi = Math.PI * i / (stackPartitions - 1);
        var sinPhi = sin(phi);
        
        var xSinPhi = radii.x * sinPhi;
        var ySinPhi = radii.y * sinPhi;
        var zCosPhi = radii.z * cos(phi);
        
        for (j = 0; j < slicePartitions; j++) {
            positions[index++] = cosTheta[j] * xSinPhi;
            positions[index++] = sinTheta[j] * ySinPhi;
            positions[index++] = zCosPhi;
        }
    }
    
    for (i = 0; i < slicePartitions; i++) {
        // duplicate first point for correct
        // texture coordinates at the north pole.
        positions[index++] = 0.0;
        positions[index++] = 0.0;
        positions[index++] = -radii.z;
    }
    
    var attributes = new GeometryAttributes();
    
    if (vertexFormat.position) {
        attributes.position = new GeometryAttribute({
            componentDatatype : ComponentDatatype.DOUBLE,
            componentsPerAttribute : 3,
            values : positions
        });
    }
    
    var stIndex = 0;
    var normalIndex = 0;
    var tangentIndex = 0;
    var binormalIndex = 0;
    
    if (vertexFormat.st || vertexFormat.normal || vertexFormat.tangent || vertexFormat.binormal) {
        for( i = 0; i < vertexCount; i++) {
            var position = Cartesian3.fromArray(positions, i * 3, scratchPosition);
            var normal = ellipsoid.geodeticSurfaceNormal(position, scratchNormal);
            
            if (vertexFormat.st) {
                var normalST = Cartesian2.negate(normal, scratchNormalST);
                
                // if the point is at or close to the pole, find a point along the same longitude
                // close to the xy-plane for the s coordinate.
                if (Cartesian2.magnitude(normalST) < CesiumMath.EPSILON6) {
                    index = (i + slicePartitions * Math.floor(stackPartitions * 0.5)) * 3;
                    if (index > positions.length) {
                        index = (i - slicePartitions * Math.floor(stackPartitions * 0.5)) * 3;
                    }
                    Cartesian3.fromArray(positions, index, normalST);
                    ellipsoid.geodeticSurfaceNormal(normalST, normalST);
                    Cartesian2.negate(normalST, normalST);
                }
                
                st[stIndex++] = (Math.atan2(normalST.y, normalST.x) / CesiumMath.TWO_PI) + 0.5;
                st[stIndex++] = (Math.asin(normal.z) / Math.PI) + 0.5;
            }
            
            if (vertexFormat.normal) {
                normals[normalIndex++] = normal.x;
                normals[normalIndex++] = normal.y;
                normals[normalIndex++] = normal.z;
            }
            
            if (vertexFormat.tangent || vertexFormat.binormal) {
                var tangent = scratchTangent;
                if (i < slicePartitions || i > vertexCount - slicePartitions - 1) {
                    Cartesian3.cross(Cartesian3.UNIT_X, normal, tangent);
                    Cartesian3.normalize(tangent, tangent);
                } else {
                    Cartesian3.cross(Cartesian3.UNIT_Z, normal, tangent);
                    Cartesian3.normalize(tangent, tangent);
                }
                
                if (vertexFormat.tangent) {
                    tangents[tangentIndex++] = tangent.x;
                    tangents[tangentIndex++] = tangent.y;
                    tangents[tangentIndex++] = tangent.z;
                }
                
                if (vertexFormat.binormal) {
                    var binormal = Cartesian3.cross(normal, tangent, scratchBinormal);
                    Cartesian3.normalize(binormal, binormal);
                    
                    binormals[binormalIndex++] = binormal.x;
                    binormals[binormalIndex++] = binormal.y;
                    binormals[binormalIndex++] = binormal.z;
                }
            }
        }
        
        if (vertexFormat.st) {
            attributes.st = new GeometryAttribute({
                componentDatatype : ComponentDatatype.FLOAT,
                componentsPerAttribute : 2,
                values : st
            });
        }
        
        if (vertexFormat.normal) {
            attributes.normal = new GeometryAttribute({
                componentDatatype : ComponentDatatype.FLOAT,
                componentsPerAttribute : 3,
                values : normals
            });
        }
        
        if (vertexFormat.tangent) {
            attributes.tangent = new GeometryAttribute({
                componentDatatype : ComponentDatatype.FLOAT,
                componentsPerAttribute : 3,
                values : tangents
            });
        }
        
        if (vertexFormat.binormal) {
            attributes.binormal = new GeometryAttribute({
                componentDatatype : ComponentDatatype.FLOAT,
                componentsPerAttribute : 3,
                values : binormals
            });
        }
    }
    
    index = 0;
    for (i = 0; i < stackPartitions; i++) {
        var topOffset = i * slicePartitions;
        var bottomOffset = (i + 1) * slicePartitions;
        
        for (j = 0; j < slicePartitions - 1; j++) {
            indices[index++] = bottomOffset + j;
            indices[index++] = bottomOffset + j + 1;
            indices[index++] = topOffset + j + 1;
            
            indices[index++] = bottomOffset + j;
            indices[index++] = topOffset + j + 1;
            indices[index++] = topOffset + j;
        }
    }
    
    return new Geometry({
        attributes : attributes,
        indices : indices,
        primitiveType : PrimitiveType.TRIANGLES,
        boundingSphere : BoundingSphere.fromEllipsoid(ellipsoid)
    });
}

@end
