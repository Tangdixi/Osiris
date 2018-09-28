//
//  ViewController.swift
//  Osiris
//
//  Created by DC on 2018/9/3.
//  Copyright © 2018 DC. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation

class ViewController: UIViewController {

    lazy var metalView: MTKView = makeMetalView()
    lazy var metalView2: MTKView = makeMetalView()
    
    var imageRenderer: Osiris!
    var osiris2: Osiris!
    
    lazy var captureSession = makeCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
//        osiris2.processImage(UIImage(named: "example")!)
//        imageRenderer.processImage(UIImage(named: "example")!).presentOn(metalView: metalView)
    }
}

// MARK: Layouts
extension ViewController {
    func setupViews() {
        view.addSubview(metalView)
//        view.addSubview(metalView2)
//
        imageRenderer = makeRenderer(metalView)
//        osiris2 = makeRenderer(metalView2)
//
//        metalView.center = CGPoint(x: view.center.x, y: 200)
//        metalView2.center = CGPoint(x: view.center.x, y: 400)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        imageRenderer.processVideo(pixelBuffer).presentOn(metalView: metalView)
    }
}

extension ViewController {
    
    func makeMetalView() -> MTKView {
        let metal = MTKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        metal.clearColor = MTLClearColorMake(0, 0, 0, 1)
        metal.framebufferOnly = false
        return metal
    }
    
    func makeRenderer(_ metalView: MTKView) -> Osiris {
        let renderer = Osiris(label: "Image Process")
        
//        let reverse = Filterable(kernalName: "reverseKernel")
//        let luma = Filterable(kernalName: "lumaKernel")
//        
//        renderer.addFilters([reverse, luma])
        
        return renderer
    }
    
    func makeCaptureSession() -> AVCaptureSession {
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        
        // Get the back camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            fatalError("Can not get a valid input")
        }
        // Configure input
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError("Can not get a valid input")
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Configure output
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        let queue = DispatchQueue(label: "com.captureVideo.dc")
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // Configure connection
        guard let connection = output.connection(with: .video) else {
            fatalError("No connection found")
        }
        connection.videoOrientation = .portrait
        
        return session
    }
}
