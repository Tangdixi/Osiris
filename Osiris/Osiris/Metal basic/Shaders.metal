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
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    return float4(baseColor,1);
}

constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);

kernel void grayKernel(texture2d<float, access::read> sourceTexture [[texture(TextureIndexSource)]],
                       texture2d<float, access::write> destTexture [[texture(TextureIndexDestination)]],
                       uint2 grid [[thread_position_in_grid]]) {
    if(grid.x > destTexture.get_width() || grid.y > destTexture.get_height()) {
        return;
    }
    float4 color = sourceTexture.read(grid);
    float gray = dot(color.rgb, kRec709Luma);
    destTexture.write(float4(gray, gray, gray, 1.0), grid);
}
