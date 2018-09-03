//
//  ViewController.swift
//  Osiris
//
//  Created by DC on 2018/9/3.
//  Copyright © 2018 DC. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    lazy var metalView: MTKView = makeMetalView()
    lazy var osiris: Osiris = makeOsiris()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renderViews()
    }
}

extension ViewController {
    func setupViews() {
        view.addSubview(metalView)
    }
    func renderViews() {
        osiris.process()
    }
}

extension ViewController {
    
    func makeMetalView() -> MTKView {
        let metal = MTKView(frame: view.bounds)
        metal.clearColor = MTLClearColorMake(0, 0, 0, 1)
        return metal
    }
    
    func makeOsiris() -> Osiris {
        return Osiris(metalView: metalView)
    }
}
