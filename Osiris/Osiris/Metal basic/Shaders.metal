//
//  Shaders.metal
//  Chapter 3
//
//  Created by DC on 2018/8/21.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#import "OsirisShaderBridge.h"

struct VertexIn {
    float4 position [[attribute(Position)]];
    float2 uv [[attribute(UV)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             const uint vid [[vertex_id]]) {
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.uv = vertexIn.uv;
    return vertexOut;
}

fragment float4 fragment_main(const VertexOut in [[stage_in]],
                              texture2d<float> baseColorTexture [[texture(BaseColorTexture)]],
                              sampler textureSampler [[sampler(0)]]) {
//    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    return float4(1,1,1,1);
}

