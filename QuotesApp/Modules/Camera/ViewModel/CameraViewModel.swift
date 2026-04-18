//
//  CameraViewModel.swift
//  QuotesApp
//
//  Created by gokul gokul on 18/04/26.
//
import UIKit
import AVFoundation

final class CameraViewModel {
    
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    func viewDidLoad() {
        checkCameraPermission()
    }
    
    func didCapturePhoto(_ image: UIImage) {
        onPhotoCaptured?(image)
    }
}


private extension CameraViewModel {
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            onPermissionGranted?()
            
        case .notDetermined:
            requestPermission()
            
        case .denied, .restricted:
            onPermissionDenied?()
            
        @unknown default:
            onPermissionDenied?()
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                granted ? self?.onPermissionGranted?() : self?.onPermissionDenied?()
            }
        }
    }
}
