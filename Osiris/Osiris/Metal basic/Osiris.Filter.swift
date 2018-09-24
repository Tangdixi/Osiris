//
//  Osiris.Filter.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/8.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

class Filter {
    var kernalName: String
    lazy var computePipelineState: MTLComputePipelineState = makeComputePipelineState()
    
    init(kernalName: String) {
        self.kernalName = kernalName
    }
    
    var sourceTexture: MTLTexture! {
        willSet {
            newValue.label = self.kernalName+"<source>"
        }
    }
    var destinationTexture: MTLTexture! {
        willSet {
            newValue.label = self.kernalName+"<destination>"
        }
    }
    
    func performFilterWithCommandBuffer(_ commandBuffer: MTLCommandBuffer) -> MTLTexture {
        guard let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError()
        }
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setTexture(sourceTexture, index: Int(TextureIndexSource.rawValue))
        
        if destinationTexture == nil {
            let destinationTextureDescriptor = MTLTextureDescriptor()
            destinationTextureDescriptor.pixelFormat = sourceTexture.pixelFormat
            destinationTextureDescriptor.width = sourceTexture.width
            destinationTextureDescriptor.height = sourceTexture.height
            destinationTextureDescriptor.usage = [.shaderRead, .shaderWrite]
            
            destinationTexture = Osiris.device.makeTexture(descriptor: destinationTextureDescriptor)
        }
        computeCommandEncoder.setTexture(destinationTexture, index: Int(TextureIndexDestination.rawValue))
        
        // Optimize GPU computation
        let width = computePipelineState.threadExecutionWidth
        let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSize(width: width, height: height, depth: 1)
        
        let threadgroupsPerGrid = MTLSize(width: (sourceTexture.width + width - 1)/width,
                                          height: (sourceTexture.height + height - 1)/height,
                                          depth: 1)
        
        computeCommandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup:
            threadsPerThreadgroup)
        
        computeCommandEncoder.endEncoding()
        
        return destinationTexture
    }
    
    func makeComputePipelineState() -> MTLComputePipelineState {
        guard let kernalFunction = Osiris.library.makeFunction(name: kernalName) else {
            fatalError()
        }
        guard let computePipelineState = try? Osiris.device.makeComputePipelineState(function: kernalFunction) else {
            fatalError()
        }
        return computePipelineState
    }
}

enum FilterType: String {
    typealias RawValue = String
    
    case luma = "lumaKernal"
    case reverse = "reverseKernel"
    case blur = "gaussianblurKernal"
}

protocol Filterable {
    
}

extension Filterable {
    
}
