//
//  ViewController.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/24.
//  Copyright © 2018 DC. All rights reserved.
//

import Cocoa
import MetalKit
import Metal

class ViewController: NSViewController {

    lazy var renderer: Renderer = makeRenderer()
    lazy var renderPipelineState: MTLRenderPipelineState = makeRenderPipelineState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
}

extension ViewController {
    
    func setup() {
        guard let device = renderer.device else {
            fatalError("Metal is not supported in this device")
        }
        
        // Vertex buffer
        var vertices: [float3] = [
            [-0.7, 0.8, 1],
            [-0.7, -0.4, 1],
            [0.4, 0.2, 1]
        ]
        guard let vertexBuffer = device.makeBuffer(bytes:&vertices, length: MemoryLayout<float3>.stride * vertices.count, options: []) else {
            fatalError("Invalid vertex buffer")
        }
        
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = float4(0.5,0,0,1)
        
        // Fragment buffer
        var color = float4(0.6,0.6,0.6,1)
        
        renderer.renderPipelineState = renderPipelineState
        renderer.draw = { (renderCommandEncoder) in
            // Vertex shader
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBytes(&matrix, length: MemoryLayout<float4x4>.stride, index: 1)
            // Fragment shader
            renderCommandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
            
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
            
        }
    }
}

extension ViewController {
    
    func makeRenderer() -> Renderer {
        guard let metalView = view as? MTKView else {
            fatalError("Metal need a render view")
        }
        
        let renderer = Renderer(metalView: metalView)
        return renderer
    }
    
    func makeRenderPipelineState() -> MTLRenderPipelineState {
        guard let device = renderer.device, let library = renderer.device?.makeDefaultLibrary() else {
            fatalError("Can't get a valid Metal library")
        }
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        // Shader
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        // Pixel format
        guard let metalView = view as? MTKView else {
            fatalError("Metal need a render view")
        }
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            fatalError("Create pipeline state fail")
        }
        
        return renderPipelineState
    }
    
    func makeVertexBuffer() -> MTLBuffer {
        guard let device = renderer.device else {
            fatalError("Metal is not supported in this device")
        }
        var vertices = [float3(0,0,0.5)]
        guard let vertexBuffer = device.makeBuffer(bytes:&vertices, length: MemoryLayout<float3>.stride, options: []) else {
            fatalError("Invalid vertex buffer")
        }
        return vertexBuffer
    }
}
