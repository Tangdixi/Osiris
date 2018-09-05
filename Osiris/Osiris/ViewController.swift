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
    lazy var osiris: Osiris = makeOsiris()
    
    lazy var captureSession = makeCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
    }
}

// MARK: Layouts
extension ViewController {
    func setupViews() {
        view.addSubview(metalView)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        osiris.grayFilter().processVideo(pixelBuffer)
    }
}

extension ViewController {
    
    func makeMetalView() -> MTKView {
        let metal = MTKView(frame: view.bounds)
        metal.clearColor = MTLClearColorMake(0, 0, 0, 0)
        metal.framebufferOnly = false
        return metal
    }
    
    func makeOsiris() -> Osiris {
        return Osiris(metalView: metalView)
    }
    
    func makeCaptureSession() -> AVCaptureSession {
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080
        
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
