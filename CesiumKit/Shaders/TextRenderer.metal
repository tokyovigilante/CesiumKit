//
//  TextRenderer.metal
//  CesiumKit
//
//  Created by Ryan Walklin on 26/02/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[ attribute(0) ]];
    float2 texCoords [[ attribute(1) ]];
};

struct TransformedVertex
{
    float4 position [[ position ]];
    float2 texCoords;
};

struct Uniforms
{
    float4x4 modelMatrix;
    float4x4 viewProjectionMatrix;
    float4 foregroundColor;
};

vertex TransformedVertex text_vertex_shade(Vertex inVert [[stage_in]], constant Uniforms &uniforms [[buffer(2)]])
{
    TransformedVertex outVert;
    outVert.position = uniforms.viewProjectionMatrix * uniforms.modelMatrix * float4(inVert.position);
    outVert.texCoords = inVert.texCoords;
    return outVert;
}

fragment half4 text_fragment_shade(TransformedVertex vert [[stage_in]], constant Uniforms &uniforms [[buffer(2)]], sampler samplr [[sampler(0)]], texture2d<float, access::sample> texture [[texture(0)]])
{
    float4 color = uniforms.foregroundColor;
    // Outline of glyph is the isocontour with value 50%
    float edgeDistance = 0.5;
    // Sample the signed-distance field to find distance from this fragment to the glyph outline
    float sampleDistance = texture.sample(samplr, vert.texCoords).r;
    // Use local automatic gradients to find anti-aliased anisotropic edge width, cf. Gustavson 2012
    float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
    //float edgeWidth = fwidth(sampleDistance);
    // Smooth the glyph edge by interpolating across the boundary in a band with the width determined above
    float insideness = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
    return half4(color.r, color.g, color.b, insideness);
}
