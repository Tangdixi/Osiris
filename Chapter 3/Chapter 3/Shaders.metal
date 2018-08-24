//
//  Shaders.metal
//  Chapter 3
//
//  Created by DC on 2018/8/21.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertexIn [[ stage_in ]],
                          constant float &timer [[ buffer(1) ]]) {
    float4 position = vertexIn.position;
    position.x += timer;
    return position;
}

fragment float4 fragment_main() {
    return float4(1,0.6,0.5,1.0);
}
