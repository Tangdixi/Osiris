//
//  ColorInvert.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/28.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

class Invert: Filterable {
    var kernalName: String = FilterFactory.invert.rawValue
    var computePipelineState: MTLComputePipelineState?
    var sourceTexture: MTLTexture?
    var destinationTexture: MTLTexture?
}
