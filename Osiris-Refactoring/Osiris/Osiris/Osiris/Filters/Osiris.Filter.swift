//
//  Filter.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/9.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

enum BuiltInFilterName: String {
    typealias RawValue = String
    
    case brightness = "brightness"
    case unknown = "unknown"
}

protocol Filter {
    var name: String { get set }
    var inTexture: MTLTexture { get set }
    var outTexture: MTLTexture { get set }
    
    init(name: String, inTexture: MTLTexture, outTexture: MTLTexture)
}
