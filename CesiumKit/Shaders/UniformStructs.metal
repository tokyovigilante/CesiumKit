//
//  UniformStructs.metal
//  CesiumKit
//
//  Created by Ryan Walklin on 27/03/2016.
//  Copyright © 2016 Test Toast. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct AutomaticUniform
{
    float3x3 czm_a_viewRotation;
    float3x3 czm_a_temeToPseudoFixed;
    float3 czm_a_sunDirectionEC;
    float3 czm_a_sunDirectionWC;
    float3 czm_a_moonDirectionEC;
    float3 czm_a_viewerPositionWC;
    float czm_a_morphTime;
    float czm_a_fogDensity;
    float czm_a_frameNumber;
};

struct FrustumUniform
{
    float4x4 czm_f_viewportOrthographic;
    float4x4 czm_f_viewportTransformation;
    float4x4 czm_f_projection;
    float4x4 czm_f_inverseProjection;
    float4x4 czm_f_view;
    float4x4 czm_f_modelView;
    float4x4 czm_f_modelView3D;
    float4x4 czm_f_inverseModelView;
    float4x4 czm_f_modelViewProjection;
    float4 czm_f_viewport;
    float3x3 czm_f_normal;
    float3x3 czm_f_normal3D;
    float2 czm_f_entireFrustum;
};
