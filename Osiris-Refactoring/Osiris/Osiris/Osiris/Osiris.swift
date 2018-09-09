//
//  Osiris.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/9.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

final class Osiris: NSObject {
    
    static var device: MTLDevice = makeDevice()
    
    var source: Osiris.Source!
    var fillMode: FillMode = .fill
    
    // MARK: - Lazy loading
    lazy var library: MTLLibrary = makeLibrary()
    lazy var commandQueue: MTLCommandQueue = makeCommandQueue()
    lazy var renderPipelineState: MTLRenderPipelineState = makeRenderPipelineState()
    lazy var vertexBuffer: MTLBuffer = makeVertexBuffer()
    
    var inputTexture: MTLTexture?
    var destinationTexture: MTLTexture?
    
    init(source: Osiris.Source) {
        self.source = source
    }
    
    enum Source {
        case camera
        case picture
        case video
    }
    
    enum FillMode {
        case aspectRatio
        case fill
    }
}

// MARK: - Public
extension Osiris {
    
    func presentOn(metalView: MTKView, fillMode: FillMode) {
        metalView.delegate = self
        
    }
    
}

// MARK: - MTKViewDelegate
extension Osiris: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError()
        }

        // Render command encoder
        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError()
        }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        // Vertex Buffer
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(BufferIndexVertex.rawValue))
        // We have two triangle for creating a rect
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderCommandEncoder.endEncoding()
        
        // Texture
        
        
        // Commit to GPU
        guard let drawable = view.currentDrawable else {
            fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Lazy Loading
extension Osiris {
    
    // MARK: - None transient object
    class func makeDevice() -> MTLDevice {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }
        return device
    }
    
    func makeLibrary() -> MTLLibrary {
        guard let library = Osiris.device.makeDefaultLibrary() else {
            fatalError()
        }
        return library
    }
    
    func makeCommandQueue() -> MTLCommandQueue {
        guard let commandQueue = Osiris.device.makeCommandQueue() else {
            fatalError()
        }
        return commandQueue
    }
    
    func makeRenderPipelineState() -> MTLRenderPipelineState {
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        
        guard let renderPipelineState = try? Osiris.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            fatalError()
        }
        return renderPipelineState
    }
    
    func makeVertexBuffer() -> MTLBuffer {
        // Vertex attribute layout:
        // |x,y,z,w|u,v|
        var vertices = [
            Vertex(position: float4(1.0, -1.0, 0.0, 1.0), uv: float2(1.0, 1.0)),
            Vertex(position: float4(-1.0, -1.0, 0.0, 1.0), uv: float2(0.0, 1.0)),
            Vertex(position: float4(-1.0, 1.0, 0.0, 1.0), uv: float2(0.0, 0.0)),
            Vertex(position: float4(1.0, -1.0, 0.0, 1.0), uv: float2(1.0, 1.0)),
            Vertex(position: float4(-1.0, 1.0, 0.0, 1.0), uv: float2(0.0, 0.0)),
            Vertex(position: float4(1.0, 1.0, 0.0, 1.0), uv: float2(1.0, 0.0)),
            ]
        
        guard let vertexBuffer = Osiris.device.makeBuffer(bytes: &vertices,
                                                          length: MemoryLayout<Vertex>.stride * vertices.count,
                                                          options: .storageModeShared) else {
            fatalError()
        }
        return vertexBuffer
    }
}
