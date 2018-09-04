//
//  ViewController.swift
//  Osiris (MacOS)
//
//  Created by 汤迪希 on 2018/9/4.
//  Copyright © 2018 DC. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    lazy var metalView: MTKView = makeMetalView()
    lazy var osiris: Osiris = makeOsiris()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        renderViews()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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
