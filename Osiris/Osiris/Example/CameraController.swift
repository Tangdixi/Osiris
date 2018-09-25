//
//  CameraController.swift
//  Osiris
//
//  Created by 汤迪希 on 2018/9/25.
//  Copyright © 2018 DC. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation

class CameraController: UIViewController {

    lazy var processor: Osiris = makeProcessor()
    lazy var metalView: MTKView = makeMetalView()
    lazy var captureSession = makeCaptureSession()
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.stopRunning()
    }
}

extension CameraController {
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(metalView);
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        processor.processVideo(pixelBuffer).presentOn(metalView: metalView)
    }
}

extension CameraController {
    
    func makeProcessor() -> Osiris {
        let osiris = Osiris(label: "Image Filter")
        let reverse = Filter(kernalName: "lumaKernel")
        osiris.addFilters([reverse])
        
        return osiris
    }
    
    func makeMetalView() -> MTKView {
        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 350, height: 500))
        metalView.clearColor = MTLClearColorMake(0, 0, 0, 1)
        metalView.center = view.center
        return metalView
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

