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

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_main(constant Vertex *vertices [[buffer(BufferIndexVertex)]],
                             const uint id [[vertex_id]]) {
    VertexOut vertexOut;
    vertexOut.position = vertices[id].position;
    vertexOut.uv = vertices[id].uv;
    return vertexOut;
}

fragment float4 fragment_main(const VertexOut in [[stage_in]],
                              texture2d<float> baseColorTexture [[texture(TextureIndexSource)]],
                              sampler textureSampler [[sampler(0)]]) {
    return is_null_texture(baseColorTexture)? float4(0.8,0.8,0.5,1) : float4(baseColorTexture.sample(textureSampler, in.uv).rgb, 1.0);
}
