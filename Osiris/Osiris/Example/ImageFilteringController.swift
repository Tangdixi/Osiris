//
//  ImageFilteringController.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/25.
//  Copyright © 2018 DC. All rights reserved.
//

import UIKit
import MetalKit

class ImageFilteringController: UIViewController {

    lazy var processor: Osiris = makeProcessor()
    lazy var metalView: MTKView = makeMetalView()
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        renderImage()
    }
    
}

extension ImageFilteringController {
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(metalView);
    }
    
    func renderImage() {
        guard let image = UIImage(named: "bridge.jpg") else {
            return
        }
        processor.processImage(image).presentOn(metalView: metalView)
    }
}

extension ImageFilteringController {
    
    func makeProcessor() -> Osiris {
        let osiris = Osiris(label: "Image Filter")
        
        osiris.addFilters([Invert()])
        
        return osiris
    }
    
    func makeMetalView() -> MTKView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 350, height: 500))
        metalView.clearColor = MTLClearColorMake(0, 0, 0, 1)
        metalView.center = view.center
        return metalView
    }
    
}

