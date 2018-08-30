//
//  Lights.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/29.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

class LightFactory {
    lazy var sunLight: Light = makeSunLight()
    lazy var debugSunLightPipelineState = makePipelineState()
    
    lazy var ambientLight: Light = makeAmbientLight()
    lazy var pointLight: Light = makePointLight()
    lazy var debugPointLightPipelineState = makePipelineState()
    
    func debugDirectionLight(_ light: Light, renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms) {
        
        var vertices: [float3] = []
        for i in -5..<5 {
            let value = Float(i) * 0.4
            vertices.append(float3(value, 0, value))
            vertices.append(float3(light.position.x+value, light.position.y, light.position.z+value))
        }
        
        let buffer = renderEncoder.device.makeBuffer(bytes: &vertices,
                                                length: MemoryLayout<float3>.stride * vertices.count,
                                                options: [])
        var uniforms = uniforms
        uniforms.modelMatrix = float4x4.identity()
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride, index: 1)
        var lightColor = float3(0, 1, 0)
        renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<float3>.stride, index: 1)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        let renderPipelineState = debugSunLightPipelineState
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0,
                                     vertexCount: vertices.count)
    }
    
    func debugPointLight(_ light: Light, renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, color: float3) {
        var vertices = [light.position]
        let buffer = renderEncoder.device.makeBuffer(bytes: &vertices,
                                                length: MemoryLayout<float3>.stride * vertices.count,
                                                options: [])
        var uniforms = uniforms
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride, index: 1)
        var lightColor = color
        renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<float3>.stride, index: 1)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        let renderPipelineState = debugPointLightPipelineState
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0,
                                     vertexCount: vertices.count)
    }
}

extension LightFactory {
    
    func makeSunLight() -> Light {
        var light = makeDefaultLight()
        light.position = [1, -3, -3]
        return light
    }
    
    func makeAmbientLight() -> Light {
        var light = makeDefaultLight()
        light.intensity = 0.1
        light.color = [0.5, 1, 0]
        light.lightType = AmbientLight
        return light
    }
    
    func makeDefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.intensity = 1
        light.attenuation = [1, 0, 0]
        light.lightType = SunLight
        return light
    }
    
    func makePointLight() -> Light {
        var light = makeDefaultLight()
        light.attenuation = float3(1, 3, 4)
        light.color = [1, 0, 0]
        light.position = [0.3, 0.5, -0.5]
        light.lightType = PointLight
        return light
    }
    
    func makePipelineState() -> MTLRenderPipelineState {
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported in this device")
        }
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_light")
        let fragmentFunction = library?.makeFunction(name: "fragment_light")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        guard let lightPipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("")
        }
        return lightPipelineState
    }
}
