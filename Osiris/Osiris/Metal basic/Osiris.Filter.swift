//
//  Osiris.Filter.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/8.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

protocol Filter {}

extension Filter {
    
}

enum FilterType: String {
    typealias RawValue = String
    
    case luma = "luma"
    case brightness = "brightness"
}
