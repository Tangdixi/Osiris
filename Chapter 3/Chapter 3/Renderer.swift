//
//  Renderer.swift
//  Chapter 3
//
//  Created by DC on 2018/8/19.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit
import Cocoa

class Renderer: NSObject {
    static var device: MTLDevice?
    static var commandQueue: MTLCommandQueue?
    
    var mesh: MTKMesh?
    var vertexBuffer: MTLBuffer?
    var pipelineState: MTLRenderPipelineState?
    
    var timer: Float = 0
    
    init(metalView: MTKView) {
        
        // Get device
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Create metal device failed")
        }
        metalView.device = device
        // Get command queue
        Renderer.commandQueue = device.makeCommandQueue()
        Renderer.device = device
        
        // Load shader
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Create library failed")
        }
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        // Render pass
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        // Load model
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
        guard let mdlMesh = mdlAsset.object(at: 0) as? MDLMesh else {
            fatalError()
        }
        guard let mtkMesh = try? MTKMesh(mesh: mdlMesh, device: device) else {
            fatalError()
        }
        
        renderPipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mtkMesh.vertexDescriptor)
        
        // Setup pipeline state
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            fatalError("Create pipeline state failed")
        }
        
        mesh = mtkMesh
        vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        pipelineState = renderPipelineState
        
        super.init()
        
        metalView.clearColor = MTLClearColorMake(1.0, 1.0, 0.8, 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Invalid render pass descriptor")
        }
        guard let commandBuffer = Renderer.commandQueue?.makeCommandBuffer() else {
            fatalError("Create command buffer failed")
        }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Create encoder failed")
        }
        
        guard let pipelineState = pipelineState, let vertexBuffer = vertexBuffer else {
            fatalError("Invalid pipeline state, vertex buffer")
        }
        
        timer += 0.05
        var currentTime: Float = sin(timer)
        commandEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1)
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Drawing
        mesh?.submeshes.forEach {
            commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                 indexCount: $0.indexCount,
                                                 indexType: $0.indexType,
                                                 indexBuffer: $0.indexBuffer.buffer,
                                                 indexBufferOffset: $0.indexBuffer.offset)
        }
        
        commandEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else {
            fatalError("Can't drawable")
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
