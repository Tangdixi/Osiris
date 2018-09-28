//
//  Luma.metal
//  Osiris
//
//  Created by 汤迪希 on 2018/9/28.
//  Copyright © 2018 DC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "OsirisShaderBridge.h"

constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

kernel
void lumaKernel
(
 texture2d<half, access::read> source [[texture(TextureIndexSource)]],
 texture2d<half, access::write> destination [[texture(TextureIndexDestination)]],
 ushort2 grid [[thread_position_in_grid]]
) {
    if(grid.x >= destination.get_width() || grid.y >= destination.get_height()) {
        return;
    }
    half4 color = source.read(grid);
    half luma = dot(color.rgb, kRec709Luma);
    destination.write(luma, grid);
}
