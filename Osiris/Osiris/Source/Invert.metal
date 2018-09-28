//
//  ColorInvert.metal
//  Osiris
//
//  Created by 汤迪希 on 2018/9/28.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "OsirisShaderBridge.h"

kernel
void invertKernel
(
 texture2d<half, access::read> source [[texture(TextureIndexSource)]],
 texture2d<half, access::write> destination [[texture(TextureIndexDestination)]],
 ushort2 grid [[thread_position_in_grid]]) {
    if(grid.x >= destination.get_width() || grid.y >= destination.get_height()) {
        return;
    }
    half4 color = source.read(grid);
    half4 result = half4((1-color.rgb), 1.0);
    destination.write(result, grid);
}

