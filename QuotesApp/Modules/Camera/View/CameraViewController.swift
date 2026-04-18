//
//  CameraViewController.swift
//  QuotesApp
//
//  Created by gokul gokul on 16/04/26.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    private let viewModel: CameraViewModel
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CameraViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    
    @IBAction func didTapCapture(_ sender: UIButton) {
        capturePhoto()
    }

    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

private extension CameraViewController {
    
    func setupUI() {
        view.backgroundColor = .black
        captureButton.layer.cornerRadius = 35
        captureButton.clipsToBounds = true
    }
}

private extension CameraViewController {
    
    func bindViewModel() {
        
        viewModel.onPermissionGranted = { [weak self] in
            guard let self = self else { return }
            self.setupCamera()
            self.startCamera()
        }
        
        viewModel.onPermissionDenied = { [weak self] in
            self?.showPermissionAlert()
        }
        
        viewModel.onPhotoCaptured = { [weak self] image in
            self?.navigateToPreview(with: image)
        }
    }
    
}

private extension CameraViewController {
    
    func setupCamera() {
        if captureSession != nil { return }
        
        let session = AVCaptureSession()
        
        sessionQueue.async {
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                session.commitConfiguration()
                return
            }
            
            session.addInput(input)
            if session.canAddOutput(self.photoOutput) {
                session.addOutput(self.photoOutput)
            }
            session.commitConfiguration()
            session.startRunning()
            DispatchQueue.main.async {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                self.previewView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                self.previewView.layer.addSublayer(previewLayer)
                self.captureSession = session
                self.previewLayer = previewLayer
                self.previewLayer?.frame = self.previewView.bounds
            }
        }
    }
}

private extension CameraViewController {
    
    func startCamera() {
        guard let session = captureSession else {
            return
        }
        
        if session.isRunning {
            return
        }
        
        sessionQueue.async {
            session.startRunning()
        }
    }
    
    func stopCamera() {
        guard let session = captureSession, session.isRunning else { return }
        sessionQueue.async {
            session.stopRunning()
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        
        viewModel.didCapturePhoto(image)
    }
}

private extension CameraViewController {
    
    func navigateToPreview(with image: UIImage) {
        let previewVC = PreviewViewController(image: image)
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
}
