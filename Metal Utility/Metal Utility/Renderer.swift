//
//  Renderer.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/8/24.
//  Copyright © 2018 DC. All rights reserved.
//

import Foundation
import MetalKit
import Metal

class Renderer: NSObject {
    
    typealias DrawPhase = (MTLRenderCommandEncoder)->Void
    
    lazy var device: MTLDevice? = makeDevice()
    lazy var commandQueue: MTLCommandQueue? = makeCommandQueue()
    
    var draw: DrawPhase?
    var renderPipelineState: MTLRenderPipelineState?
    
    init(metalView: MTKView) {
        super.init()
        metalView.delegate = self
        metalView.device = device
        metalView.clearColor = MTLClearColorMake(1.0, 1.0, 0.8, 1.0)
    }
}

extension Renderer {
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    func draw(in view: MTKView) {
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Invalid render pass descriptor in \(view)")
        }
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            fatalError("Create command buffer fail")
        }
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Create render command encoder fail")
        }
        guard let renderPipelineState = renderPipelineState else {
            fatalError("Renderer need a pipeline state and a vertex buffer")
        }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        
        if let draw = draw {
            draw(renderCommandEncoder)
        }
        
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
extension Renderer {
    func makeDevice() -> MTLDevice? {
        return MTLCreateSystemDefaultDevice()
    }
    func makeCommandQueue() -> MTLCommandQueue? {
        guard let device = device else {
            fatalError("Metal is not supported in this device")
        }
        return device.makeCommandQueue()
    }
}
