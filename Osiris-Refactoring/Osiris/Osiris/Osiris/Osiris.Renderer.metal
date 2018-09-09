//
//  Osiris.Renderer.metal
//  Osiris
//
//  Created by DC on 2018/9/14.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Osiris_Bridging.h"

struct RasterizeDatas {
    float4 position [[position]];
    float2 uv;
};

vertex
RasterizeDatas vertex_main(constant Vertex *vertices [[buffer(BufferIndexVertex)]],
                           const uint id [[vertex_id]]) {
    RasterizeDatas datas;
    datas.position = vertices[id].position;
    datas.uv = vertices[id].uv;
    return datas;
}

fragment
half4 fragment_main(const RasterizeDatas datas [[stage_in]],
                     texture2d<half> sourceTexture [[texture(TextureIndexSource)]],
                     sampler textureSampler [[sampler(SamplerIndexTexture)]]) {
    half3 rgb = sourceTexture.sample(textureSampler, datas.uv).rgb;
    return half4(rgb, 1.0);
}
