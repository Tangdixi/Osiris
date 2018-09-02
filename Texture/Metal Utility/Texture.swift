//
//  Texturable.swift
//  Metal Utility
//
//  Created by 汤迪希 on 2018/9/1.
//  Copyright © 2018 DC. All rights reserved.
//

import MetalKit

protocol Texturable {}
extension Texturable {
    static func loadTexture(imageName: String, device: MTLDevice) throws -> MTLTexture? {

        guard let url = Bundle.main.urlForImageResource(imageName) else {
            fatalError("Load resource fail")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        let option: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft,
                                               .SRGB: false,
                                               .generateMipmaps: NSNumber(booleanLiteral: true)]
        let texture = try textureLoader.newTexture(URL: url,
                                                   options: option)
        return texture
    }
}

struct Texture: Texturable {
    var basicColor: MTLTexture?
    
    init(mdlSubmesh: MDLSubmesh, device: MTLDevice) {
        guard let property = mdlSubmesh.material?.property(with: MDLMaterialSemantic.baseColor) else {
            return
        }
        property.type = .string
        
        guard let fileName = property.stringValue else {
            return
        }
        guard let texture = try? Texture.loadTexture(imageName: fileName, device: device) else {
            return
        }
        print("Load texture: \(fileName)")
        
        self.basicColor = texture
    }
}
