//
//  Shaders.metal
//  Chapter 3
//
//  Created by DC on 2018/8/21.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
    float point_size [[ point_size ]];
};

vertex VertexOut vertex_main(constant float3 *vertices [[ buffer(0) ]],
                             constant float4x4 &matrix [[ buffer(1) ]],
                             uint id [[ vertex_id ]]){
    VertexOut vertex_out;
    vertex_out.position = matrix * float4(vertices[id], 1);
    vertex_out.point_size = 20;
    return vertex_out;
}

fragment float4 fragment_main(constant float &color [[ buffer(0) ]]) {
    return color;
}
