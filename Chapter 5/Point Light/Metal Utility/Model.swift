//
//  Model.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/29.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

class Model: Node {
    var renderPipelineState: MTLRenderPipelineState?
    var mesh: MTKMesh?
    var vertexBuffer: MTLBuffer?
    
    init(name: String, device: MTLDevice, pixelFormat: MTLPixelFormat) {
        
        let mdlVertexDescriptor = MDLVertexDescriptor()
        
        // vertex position
        mdlVertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        // vertex normal( The 12 offset is the size of vertex position, aka 3 float3 value)
        mdlVertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        // layout: -|v.x|v.y|v.z|n.x|n.y|n.z|-
        mdlVertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 24)
        
        // mesh
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: "obj") else {
            fatalError("Invalid asset path for \(name).obj")
        }
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlAsset = MDLAsset(url: assetURL, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: allocator)
        guard let mdlMesh = mdlAsset.object(at: 0) as? MDLMesh else {
            fatalError("Load model asset failed")
        }
        
        // shader info
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        guard let vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlVertexDescriptor) else {
            fatalError()
        }
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        // pipeline state
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            fatalError()
        }
        
        self.renderPipelineState = renderPipelineState
        self.mesh = try? MTKMesh(mesh: mdlMesh, device: device)
        self.vertexBuffer = mesh?.vertexBuffers[0].buffer
        super.init()
    }
}
