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
    class func makeTrain(device: MTLDevice) -> (MDLMesh, MTLVertexDescriptor) {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        guard let vertexAttribute = mdlVertexDescriptor.attributes[0] as? MDLVertexAttribute else {
            fatalError()
        }
        vertexAttribute.name = MDLVertexAttributePosition
        
        guard let assetURL = Bundle.main.url(forResource: "train", withExtension: "obj") else {
            fatalError("Load model failed")
        }
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlAsset = MDLAsset(url: assetURL, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: allocator)
        guard let mesh = mdlAsset.object(at: 0) as? MDLMesh else {
            fatalError()
        }
        return (mesh, vertexDescriptor)
    }
}
