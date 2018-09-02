//
//  Primitive.swift
//  Chapter 3
//
//  Created by DC on 2018/8/19.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

class Primitive {
    class func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(boxWithExtent: [size,size,size], segments: [1,1,1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        return mesh
    }
    class func makeSphere(device: MTLDevice, size: Float, segment: UInt32) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(sphereWithExtent: [size, size, size], segments: [segment,segment], inwardNormals: false, geometryType: .lines, allocator: allocator)
        return mesh
    }
}
