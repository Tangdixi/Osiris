//
//  Renderer.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/24.
//  Copyright © 2018 DC. All rights reserved.
//

import Foundation
import MetalKit

class Osiris: NSObject {
    
    typealias DrawPhase = (MTLRenderCommandEncoder)->Void
    
    lazy var device: MTLDevice = makeDevice()
    lazy var commandQueue: MTLCommandQueue = makeCommandQueue()
    lazy var vertexBuffer: MTLBuffer = makeVertexBuffer()
    lazy var renderPipelineState: MTLRenderPipelineState = makeRenderPipelineState()
    
    var draw: DrawPhase?
    
    var shouldProcess: Bool = false
    var pixelFormat: MTLPixelFormat
    var viewportSize: vector_uint2?
    
    init(metalView: MTKView) {
        self.pixelFormat = metalView.colorPixelFormat
//        self.viewportSize = vector2(UInt32(metalView.drawableSize.width), UInt32(metalView.drawableSize.height))
        super.init()
        
        metalView.delegate = self
        metalView.device = device
    }
}

extension Osiris {
    func process() {
        shouldProcess = true
    }
}

extension Osiris: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        viewportSize = vector2(UInt32(view.drawableSize.width), UInt32(view.drawableSize.height))
    }
    func draw(in view: MTKView) {
        
        guard shouldProcess else {
            return
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Invalid render pass descriptor in \(view)")
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Create command buffer fail")
        }
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Create render command encoder fail")
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(BufferIndexVertex.rawValue))
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderCommandEncoder.endEncoding()
        
        // GPU take over
        //
        guard let drawable = view.currentDrawable else {
            fatalError("Invalid drawable object in \(view)")
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: Lazy Loading
extension Osiris {
    func makeDevice() -> MTLDevice {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported in this device")
        }
        return device
    }
    func makeCommandQueue() -> MTLCommandQueue {
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Create command queue fail")
        }
        return commandQueue
    }
    
    func makeVertexBuffer() -> MTLBuffer {
        var vertices = [
            Vertexs(position: float3(0.5, -0.5, 0.0), uv: float2(1.0, 1.0)),
            Vertexs(position: float3(-0.5, -0.5, 0.0), uv: float2(0.0, 1.0)),
            Vertexs(position: float3(-0.5, 0.5, 0.0), uv: float2(0.0, 0.0)),
            Vertexs(position: float3(0.5, -0.5, 0.0), uv: float2(1.0, 1.0)),
            Vertexs(position: float3(-0.5, 0.5, 0.0), uv: float2(0.0, 0.0)),
            Vertexs(position: float3(0.5, 0.5, 0.0), uv: float2(1.0, 0.0))
        ]
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertexs>.stride * vertices.count, options: []) else {
            fatalError("Create vertex fail")
        }
        return vertexBuffer
    }
    
    func makeRenderPipelineState() -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Metal need a shader file")
        }
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        
        guard let pipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            fatalError("Create pipeline fail")
        }
        return pipelineState
    }
}
