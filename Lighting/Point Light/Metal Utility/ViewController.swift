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
    lazy var depthStencilState: MTLDepthStencilState = makeDepthStencilState()
    lazy var lightFactory: LightFactory = LightFactory()
    
    lazy var lights = [Light]()
    lazy var models = [Model]()
    
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
        guard let metalView = view as? MTKView else {
            fatalError("Metal need a render view")
        }
        
        // Setup models
        if models.count == 0 {
            let train = Model(name: "train",
                              device: device,
                              pixelFormat: metalView.colorPixelFormat)
            train.position = [0, 0, 0]
            train.rotation = [0, radians(fromDegrees: 90), 0]
            
            let tree = Model(name: "treefir",
                             device: device,
                             pixelFormat: metalView.colorPixelFormat)
            tree.position = [1.4, -1, 0]
            
            models.append(contentsOf: [train])
        }
        
        renderer.depthStencilState = depthStencilState
        renderer.draw = { (renderCommandEncoder) in
            
            // Camera
            let viewMatrix = float4x4(translation: [0, 0.5, -1.5]).inverse
            let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: 70),
                                            near: 0.01,
                                            far: 100,
                                            aspect: Float(self.view.frame.width/self.view.frame.height))
            
            // Dynamic lighting
            var lights = [Light]()
            var sunLight = self.lightFactory.sunLight
            sunLight.position = [-1, 1.5, -3]
            
            let ambientLight = self.lightFactory.ambientLight
            let pointLight = self.lightFactory.pointLight
            lights.append(contentsOf: [sunLight, ambientLight, pointLight])
            
            // Fragment shader
            let cameraPosition = float3(0, 0, 0)
            var fragmentUniforms = FragmentUniforms(lightCount: UInt32(lights.count), cameraPosition: cameraPosition)
            
            renderCommandEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: 2)
            renderCommandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: 3)
            
            self.models.forEach({ (model) in
                
                // Setup pipeline state
                guard let renderPipelineState = model.renderPipelineState else {
                    fatalError("Render command encoder need a pipeline state")
                }
                renderCommandEncoder.setRenderPipelineState(renderPipelineState)
                
                // Setup vertex buffer ( The [[buffer(0)]] attribute in shader)
                if let vertexBuffer = model.vertexBuffer {
                    renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                }
                
                // Setup the uniform data in vertex shader
                let normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
                var uniforms = Uniforms(modelMatrix: model.modelMatrix, viewMatrix: viewMatrix, projectionMatrix: projectionMatrix, normalMatrix: normalMatrix)
                renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
                
                // Draw all primitives in the model by index
                model.mesh?.submeshes.forEach({ (subMesh) in
                    renderCommandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: subMesh.indexCount, indexType: subMesh.indexType, indexBuffer: subMesh.indexBuffer.buffer, indexBufferOffset: subMesh.indexBuffer.offset)
                })
            })
            
            // Visiable light
            var lightUniforms = Uniforms()
            lightUniforms.modelMatrix = float4x4.identity()
            lightUniforms.viewMatrix = viewMatrix
            lightUniforms.projectionMatrix = projectionMatrix
            
            self.lightFactory.debugDirectionLight(sunLight, renderEncoder: renderCommandEncoder, uniforms: lightUniforms)
            self.lightFactory.debugPointLight(pointLight, renderEncoder: renderCommandEncoder, uniforms: lightUniforms, color: pointLight.color)
        }
    }
}

extension ViewController {
    
    func makeRenderer() -> Renderer {
        guard let metalView = view as? MTKView else {
            fatalError("Metal need a render view")
        }
        metalView.depthStencilPixelFormat = .depth32Float
        
        let renderer = Renderer(metalView: metalView)
        return renderer
    }
    
    func makeDepthStencilState() -> MTLDepthStencilState {
        guard let device = renderer.device else {
            fatalError("Metal is not supported in this device")
        }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        guard let depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor) else {
            fatalError("Create depth stencil state fail")
        }
        return depthStencilState
    }
}
