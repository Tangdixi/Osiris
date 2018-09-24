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
    
    // Non Transient Object
    static var device = makeDevice()
    static var library = makeLibrary()
    
    typealias DrawPhase = (MTLRenderCommandEncoder)->Void
    
    // For using customer device
    lazy var device: MTLDevice = Osiris.device
    lazy var library: MTLLibrary = Osiris.library
    
    lazy var commandQueue: MTLCommandQueue = makeCommandQueue()
    lazy var vertexBuffer: MTLBuffer = makeVertexBuffer()
    lazy var renderPipelineState: MTLRenderPipelineState = makeRenderPipelineState()
    
    // For converting sample buffer to texture
    lazy var textureCache: CVMetalTextureCache = makeTextureCache()
    lazy var sampler: MTLSamplerState = makeSampler()
    
    var draw: DrawPhase?
    
    var shouldProcess: Bool = false
    
    var pixelFormat: MTLPixelFormat = .bgra8Unorm
    
    var viewportSize: CGSize?
    var sourceTexture: MTLTexture?
    var destinationTexture: MTLTexture?
    
    var filter: MTLComputePipelineState?
    
    var label: String = ""
    
    init(label: String) {
        self.label = label
        super.init()
    }
    var filters:[Filter] = [Filter]()
}

extension Osiris {
    
    func processImage(_ image:UIImage) -> Osiris {
        // Set the input texture
        if sourceTexture == nil {
            let textureLoader = MTKTextureLoader(device: device)
            
            guard let cgImage = image.cgImage else {
                fatalError("Load image fail")
            }
            let options: [MTKTextureLoader.Option: Any] = [
                .origin: MTKTextureLoader.Origin.topLeft,
                .SRGB: false,
                ]
            guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options:options) else {
                fatalError("Load texture fail")
            }
            self.sourceTexture = texture
        }
        return self
    }
    
    func presentOn(metalView: MTKView) {
        self.pixelFormat = metalView.colorPixelFormat
        self.viewportSize = metalView.drawableSize
        
        metalView.delegate = self
        metalView.device = self.device
        
        self.shouldProcess = true
    }
    
    func addFilters(_ filters: [Filter]?) {
        
        guard let filters = filters else {
            fatalError("[Osiris]")
        }
        guard self.filters.count == 0 else {
            fatalError("Please add the filters only once")
        }
        
        self.filters = filters
    }
    
    func processVideo(_ pixelBuffer: CVPixelBuffer) -> Osiris {
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var tempTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, pixelFormat, width, height, 0, &tempTexture)
        guard status == kCVReturnSuccess else {
            fatalError("Create CVMetalTexture faile")
        }
        guard let result = tempTexture else {
            fatalError()
        }
        
        sourceTexture = CVMetalTextureGetTexture(result)
        shouldProcess = true
        
        return self
    }
    
}

extension Osiris: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = view.drawableSize
        shouldProcess = true
    }
    func draw(in view: MTKView) {
        
        guard shouldProcess else {
            return
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Invalid render pass descriptor in \(view)")
        }
        
        // Filters
        //
        
        var finalTexture = sourceTexture
        
        if finalTexture != nil {
            
            // A command buffer for compute pipeline
            guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                fatalError("Create command buffer fail")
            }
            
            self.filters.forEach {
                $0.sourceTexture = finalTexture
                finalTexture = $0.performFilterWithCommandBuffer(commandBuffer)
            }
            commandBuffer.commit()
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Create command buffer fail")
        }
        
        // Render pipeline
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Create render command encoder fail")
        }
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        
        let viewPort = MTLViewport(originX: 0, originY: 0, width: Double(view.drawableSize.width), height: Double(view.drawableSize.height), znear: -1, zfar: 1)
        renderCommandEncoder.setViewport(viewPort)
        
        // Vertex
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(BufferIndexVertex.rawValue))
        // Fragment
        renderCommandEncoder.setFragmentTexture(finalTexture, index: 0)
        renderCommandEncoder.setFragmentSamplerState(sampler, index: 0)
        // Issue draw
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderCommandEncoder.endEncoding()
        
        // GPU take over
        //
        guard let drawable = view.currentDrawable else {
            fatalError("Invalid drawable object in \(view)")
        }
        commandBuffer.addCompletedHandler { (_) in
            self.shouldProcess = false
            self.sourceTexture = nil
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        // Reset resources
    }
}

// MARK: Lazy Loading
extension Osiris {
    
    class func makeDevice() -> MTLDevice {
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
            Vertex(position: float4(1.0, -1.0, 0.0, 1.0), uv: float2(1.0, 1.0)),
            Vertex(position: float4(-1.0, -1.0, 0.0, 1.0), uv: float2(0.0, 1.0)),
            Vertex(position: float4(-1.0, 1.0, 0.0, 1.0), uv: float2(0.0, 0.0)),
            Vertex(position: float4(1.0, -1.0, 0.0, 1.0), uv: float2(1.0, 1.0)),
            Vertex(position: float4(-1.0, 1.0, 0.0, 1.0), uv: float2(0.0, 0.0)),
            Vertex(position: float4(1.0, 1.0, 0.0, 1.0), uv: float2(1.0, 0.0)),
        ]
        
        guard let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: .storageModeShared) else {
            fatalError("Create vertex buffer faile")
        }
        return vertexBuffer
    }
    
    func makeRenderPipelineState() -> MTLRenderPipelineState {

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
    
    func makeTextureCache() -> CVMetalTextureCache {
        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        guard let result = cache else {
            fatalError("Cannot create texture cache")
        }
        return result
    }
    
    func makeSampler() -> MTLSamplerState {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        
        guard let sampler = device.makeSamplerState(descriptor: samplerDescriptor) else {
            fatalError("Create sampler fail")
        }
        return sampler
    }
    
    class func makeLibrary() -> MTLLibrary {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Metal need a shader file")
        }
        return library
    }
}
