//
//  Globe.metal
//  CesiumKit
//
//  Created by Ryan Walklin on 24/05/2015.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct InVertex
{
    float4 position3DAndHeight [[attribute(0)]];
    float2 textureCoordAndEncodedNormals [[attribute(1)]];
};

struct OutVertex
{
    float4 position3DAndHeight [[position]];
    float2 textureCoordAndEncodedNormals;
};

struct Uniforms
{
    float4x4 czm_projection;
    float4x4 u_modifiedModelView;
    float4 u_initialColor;
};

vertex OutVertex globeVS(constant InVertex *vert [[buffer(0)]],
                         constant Uniforms &uniforms [[buffer(1)]],
                         uint vid [[vertex_id]])
{
    OutVertex outVertex;
    outVertex.position3DAndHeight = uniforms.czm_projection * (uniforms.u_modifiedModelView * float4(vert[vid].position3DAndHeight.xyz, 1.0));
    outVertex.textureCoordAndEncodedNormals = vert[vid].textureCoordAndEncodedNormals;
    return outVertex;
}

fragment half4 globeFS(OutVertex vert [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]
                       /*texture2d<float, access::sample> diffuseTexture [[texture(0)]],
                       sampler samplr [[sampler(0)]]*/)
{
    float4 color = uniforms.u_initialColor;
    return half4(color.r, color.g, color.b, 1);

/*#ifdef SHOW_TILE_BOUNDARIES
    if (v_textureCoordinates.x < (1.0/256.0) || v_textureCoordinates.x > (255.0/256.0) ||
        v_textureCoordinates.y < (1.0/256.0) || v_textureCoordinates.y > (255.0/256.0))
    {
        color = vec4(1.0, 0.0, 0.0, 1.0);
    }
#endif*/
}


