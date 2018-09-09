//
//  ViewController.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/9.
//  Copyright © 2018 DC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var videoProcessor: Osiris = makeVideoProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
}

extension ViewController {
    func makeVideoProcessor() -> Osiris {
        let osiris = Osiris(source: .camera)
        return osiris
    }
}
