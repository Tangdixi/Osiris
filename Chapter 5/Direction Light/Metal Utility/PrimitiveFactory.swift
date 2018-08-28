//
//  Primitive.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/25.
//  Copyright © 2018 DC. All rights reserved.
//

import Foundation
import MetalKit

class PrimitiveFactory {
    
    class func makeCube(device: MTLDevice, extent: vector_float3, segments: vector_uint3) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(boxWithExtent: extent, segments: segments, inwardNormals: false, geometryType: .triangles, allocator: allocator)
        return mesh
    }
    
    class func makeTrain(device: MTLDevice) -> (MDLMesh, MTLVertexDescriptor) {
        
        let mdlVertexDescriptor = MDLVertexDescriptor()
        
        mdlVertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        mdlVertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        
        mdlVertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 24)
        
        guard let assetURL = Bundle.main.url(forResource: "train", withExtension: "obj") else {
            fatalError("Load model failed")
        }
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlAsset = MDLAsset(url: assetURL, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: allocator)
        guard let mesh = mdlAsset.object(at: 0) as? MDLMesh else {
            fatalError()
        }
        guard let vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlVertexDescriptor) else {
            fatalError()
        }
        
        return (mesh, vertexDescriptor)
    }
    
}
