//
//  Primitive.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/25.
//  Copyright © 2018 DC. All rights reserved.
//

import Foundation
import MetalKit

class Primitive {
    class func makeCube(device: MTLDevice, extent: vector_float3, segments: vector_uint3) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(boxWithExtent: extent, segments: segments, inwardNormals: false, geometryType: .triangles, allocator: allocator)
        return mesh
    }
}
