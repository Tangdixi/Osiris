//
//  Osiris.Filter.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/8.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

protocol Filterable: class {
    
    var kernalName: String { get set }
    var computePipelineState: MTLComputePipelineState? { get set }
    var sourceTexture: MTLTexture? { get set }
    var destinationTexture: MTLTexture? { get set }
}

extension Filterable {
    
    func performFilterWithCommandBuffer(_ commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        guard let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError()
        }
    
        // Set compute pipeline state
        //
        self.computePipelineState = makeComputePipelineState()
        guard let computePipelineState = self.computePipelineState else {
            fatalError()
        }
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setTexture(sourceTexture, index: Int(TextureIndexSource.rawValue))
        
        // Ensure the source texture is not nil
        guard let sourceTexture = sourceTexture else {
            fatalError()
        }
        
        // Set the destination texture
        //
        // TODO: Maybe use MTLHeap for creating the texture
        //
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
        //
        let width = computePipelineState.threadExecutionWidth
        let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSize(width: width, height: height, depth: 1)
        
        let threadgroupsPerGrid = MTLSize(width: (sourceTexture.width + width - 1)/width,
                                          height: (sourceTexture.height + height - 1)/height,
                                          depth: 1)
        computeCommandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup:
            threadsPerThreadgroup)
        
        // End encoding for proceed next command encoder
        //
        computeCommandEncoder.endEncoding()
        
        return destinationTexture
    }
 
    func makeComputePipelineState() -> MTLComputePipelineState {
        guard let kernelFunction = Osiris.library.makeFunction(name: kernalName) else {
            fatalError()
        }
        guard let computePipelineState = try? Osiris.device.makeComputePipelineState(function: kernelFunction) else {
            fatalError()
        }
        return computePipelineState
    }
}

enum FilterFactory: String {
    typealias RawValue = String
    
    case luma = "lumaKernel"
    case invert = "invertKernel"
    case blur = "gaussianblurKernel"
}
