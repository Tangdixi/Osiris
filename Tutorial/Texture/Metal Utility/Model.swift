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
    var texture: [Texture]?
    var tiling: UInt32 = 1
    var samplerState: MTLSamplerState?
    
    init(name: String, device: MTLDevice, pixelFormat: MTLPixelFormat) {
        
        let mdlVertexDescriptor = MDLVertexDescriptor()
        
        // vertex position
        mdlVertexDescriptor.attributes[Int(Position.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: Int(BufferIndexVertex.rawValue))
        // vertex normal( The 12 offset is the size of vertex position, aka 3 float3 value)
        mdlVertexDescriptor.attributes[Int(Normal.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: Int(BufferIndexVertex.rawValue))
        mdlVertexDescriptor.attributes[Int(UV.rawValue)] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 24, bufferIndex: Int(BufferIndexVertex.rawValue))
        
        // layout: -|v.x|v.y|v.z|n.x|n.y|n.z|u|v|-
        mdlVertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 32)
        
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
        
        // texture
        if let mdlSubmeshs = mdlMesh.submeshes as? [MDLSubmesh] {
            self.texture = mdlSubmeshs.compactMap {
                return Texture(mdlSubmesh: $0, device: device)
            }
            
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.tAddressMode = .repeat
            samplerDescriptor.sAddressMode = .repeat
            samplerDescriptor.mipFilter = .linear
            samplerDescriptor.maxAnisotropy = 8
            
            guard let samplerState = device.makeSamplerState(descriptor: samplerDescriptor) else {
                fatalError("Create sampler failed")
            }
            self.samplerState = samplerState
        }
        
        super.init()
    }
    
    init(mdlMesh: MDLMesh, device: MTLDevice, pixelFormat: MTLPixelFormat) {
        guard let mtkMesh = try? MTKMesh(mesh: mdlMesh, device: device) else {
            fatalError("Load primitive fail")
        }
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        guard let vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mtkMesh.vertexDescriptor) else {
            fatalError()
        }
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
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

