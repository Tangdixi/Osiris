//
//  ViewController.swift
//  Chapter 3
//
//  Created by DC on 2018/8/19.
//  Copyright © 2018 DC. All rights reserved.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {

    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("Metal view setup failure")
        }
        
        renderer = Renderer(metalView: metalView)
        
    }
        // Do any additional setup after loading the view.
}

