//
//  Shaders.metal
//  Chapter 3
//
//  Created by DC on 2018/8/21.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

struct VertexOut {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexOut vertex_out [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(1) ]]) {
    return uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertex_out.position;
}

fragment float4 fragment_main(constant float &color [[ buffer(0) ]]) {
    return color;
}
