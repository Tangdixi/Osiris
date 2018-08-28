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
    lazy var model: (MDLMesh, MTLVertexDescriptor) = makeModel()
    
    var timer: Float = 0.0
    
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
        
        guard let mtkTrainMesh = try? MTKMesh(mesh: model.0, device: device) else {
            fatalError("Create mesh fail")
        }
        
        // Fragment buffer
        var color = float4(0.6,0.6,0.6,1)
        
        renderer.renderPipelineState = renderPipelineState
        renderer.draw = { (renderCommandEncoder) in
            
            self.timer += 0.05
            
            let translation = float4x4(translation: [0, 0.3, 0])
            let rotation = float4x4(rotation: [0, radians(fromDegrees: 45), 0])
            let modelMatrix = rotation * translation
            
            let viewMatrix = float4x4(translation: [0,0,-3]).inverse
            let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: 45),
                                            near: 0.001,
                                            far: 1000,
                                            aspect: Float(self.view.frame.width/self.view.frame.height))
            
            var uniforms = Uniforms(modelMatrix: modelMatrix, viewMatrix: viewMatrix, projectionMatrix: projectionMatrix)
            
            // Vertex shader
            renderCommandEncoder.setVertexBuffer(mtkTrainMesh.vertexBuffers[0].buffer, offset: 0, index: 0)
            renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
            // Fragment shader
            renderCommandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
            
            mtkTrainMesh.submeshes.forEach {
                renderCommandEncoder.drawIndexedPrimitives(type: .triangle,
                                                           indexCount: $0.indexCount,
                                                           indexType: $0.indexType,
                                                           indexBuffer: $0.indexBuffer.buffer,
                                                           indexBufferOffset: $0.indexBuffer.offset)
            }
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
        renderPipelineDescriptor.vertexDescriptor = model.1
        
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
    
    func makeModel() -> (MDLMesh, MTLVertexDescriptor) {
        guard let device = renderer.device else {
            fatalError("Metal is not supported in this device")
        }
        return Primitive.makeTrain(device: device)
    }
}
