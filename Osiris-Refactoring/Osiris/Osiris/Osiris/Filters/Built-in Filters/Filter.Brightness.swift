//
//  Brightness.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/9.
//  Copyright © 2018 DC. All rights reserved.
//

import Foundation
import MetalKit

final class Brightness: Filter {
    
    var name: String
    var inTexture: MTLTexture
    var outTexture: MTLTexture
    
    init(name: String, inTexture: MTLTexture, outTexture: MTLTexture) {
        self.name = BuiltInFilterName.brightness.rawValue
        self.inTexture = inTexture
        self.outTexture = outTexture
    }
}
