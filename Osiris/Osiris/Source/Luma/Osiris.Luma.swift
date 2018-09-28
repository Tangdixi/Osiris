//
//  Osiris.Luma.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/28.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

class Luma: Filterable {
    var kernalName: String = FilterFactory.luma.rawValue
    var computePipelineState: MTLComputePipelineState?
    var sourceTexture: MTLTexture?
    var destinationTexture: MTLTexture?
}
