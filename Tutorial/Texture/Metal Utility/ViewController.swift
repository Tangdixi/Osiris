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
            let house = Model(name: "lowpoly-house", device: device, pixelFormat: metalView.colorPixelFormat)
            house.rotation = [0, radians(fromDegrees: 45), 0]
            
            let plane = Model(name: "plane", device: device, pixelFormat: metalView.colorPixelFormat)
            plane.scale = [40,1,40]
            plane.tiling = 16
            models.append(contentsOf: [house,plane])
        }
        
        renderer.depthStencilState = depthStencilState
        renderer.draw = { (renderCommandEncoder) in
            
            // Camera
            let viewMatrix = float4x4(translation: [0, 1, -4]).inverse
            let projectionMatrix = float4x4(projectionFov: radians(fromDegrees: 70),
                                            near: 0.01,
                                            far: 1000,
                                            aspect: Float(self.view.frame.width/self.view.frame.height))
            
            // Dynamic lighting
            self.timer += 0.01
            var lights = [Light]()
            var sunLight = self.lightFactory.sunLight
            sunLight.position = [sin(self.timer) * 3, 1, -4]
            
            let ambientLight = self.lightFactory.ambientLight
            var pointLight = self.lightFactory.pointLight
            pointLight.position = [0, 0.1, -0.7]
            
            var spotLight = self.lightFactory.spotLight
            spotLight.position = [-0.2, 0.3, -0.7]
            spotLight.coneDirection = [0.2, -0.3, 0.7]
            
            lights.append(contentsOf: [sunLight, ambientLight, spotLight])
            
            // Fragment shader
            let cameraPosition = float3(0, 0, 0)
            var fragmentUniforms = FragmentUniforms(lightCount: UInt32(lights.count), cameraPosition: cameraPosition, tiling: 1)
            
            renderCommandEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: Int(BufferIndexLights.rawValue))
            
            self.models.forEach({ (model) in
                
                // Setup pipeline state
                guard let renderPipelineState = model.renderPipelineState else {
                    fatalError("Render command encoder need a pipeline state")
                }
                renderCommandEncoder.setRenderPipelineState(renderPipelineState)
                
                // Texture
                if let textures = model.texture?.compactMap({ return $0.basicColor }) {
                    renderCommandEncoder.setFragmentTexture(textures.first, index: Int(BaseColorTexture.rawValue))
                }
                // Sampler
                if let samplerState = model.samplerState {
                    renderCommandEncoder.setFragmentSamplerState(samplerState, index: 0)
                }
                
                // Setup vertex buffer ( The [[buffer(0)]] attribute in shader)
                if let vertexBuffer = model.vertexBuffer {
                    renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(BufferIndexVertex.rawValue))
                }
                
                // Setup the uniform data in vertex shader
                let normalMatrix = float3x3(normalFrom4x4: model.modelMatrix)
                var uniforms = Uniforms(modelMatrix: model.modelMatrix, viewMatrix: viewMatrix, projectionMatrix: projectionMatrix, normalMatrix: normalMatrix)
                renderCommandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: Int(BufferIndexUniforms.rawValue))
                
                // Fragment Uniforms
                fragmentUniforms.tiling = model.tiling
                renderCommandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, index: Int(BufferIndexFragmentUniforms.rawValue))
                
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
            
            // Debug lighting
            // self.lightFactory.debugDirectionLight(sunLight, renderEncoder: renderCommandEncoder, uniforms: lightUniforms)
            // self.lightFactory.debugPointLight(pointLight, renderEncoder: renderCommandEncoder, uniforms: lightUniforms, color: pointLight.color)
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
