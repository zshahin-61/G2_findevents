//
//  AuthorizationHelper.swift
//  G2_findevents
//
//  Created by Golnaz Chehrazi on 2023-07-12.
//

import Foundation
import AVFoundation
import Photos
import Combine

class PhotoLibraryManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        isAuthorized = status == .authorized
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAuthorized = status == .authorized
            }
        }
    }
}
