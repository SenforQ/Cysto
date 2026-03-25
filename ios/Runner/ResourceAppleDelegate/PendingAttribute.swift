// __DEBUG__
// __CLOSE_PRINT__
//
//  PendingAttribute.swift
//  OverseaH5
//
//  Created by young on 2025/9/23.
//

//: import Foundation
import Foundation
//: import Photos
import Photos
//: import UIKit
import UIKit

//: class AppPermissionTool {
class PendingAttribute {
    //: static let shared = AppPermissionTool()
    static let shared = PendingAttribute()

    /// 获取麦克风权限
    //: func requestMicPermission(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
    func device(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
        //: switch AVAudioSession.sharedInstance().recordPermission {
        switch AVAudioSession.sharedInstance().recordPermission {
        //: case .granted:
        case .granted:
            //: authBlock(true, false)
            authBlock(true, false)
        //: case .undetermined:
        case .undetermined:
            //: AVAudioSession.sharedInstance().requestRecordPermission { auth in
            AVAudioSession.sharedInstance().requestRecordPermission { auth in
                //: authBlock(auth, true)
                authBlock(auth, true)
            }
        //: case .denied:
        case .denied:
            //: authBlock(false, false)
            authBlock(false, false)
        //: default:
        default:
            //: authBlock(false, false)
            authBlock(false, false)
        }
    }

    /// 获取相册权限
    //: func requestPhotoPermission(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
    func withModel(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
        //: if #available(iOS 14, *) {
        if #available(iOS 14, *) {
            //: switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            //: case .authorized:
            case .authorized:
                //: authBlock(true, false)
                authBlock(true, false)
            //: case .notDetermined:
            case .notDetermined:
                //: PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    //: if status == .authorized || status == .limited {
                    if status == .authorized || status == .limited {
                        //: authBlock(true, true)
                        authBlock(true, true)
                    //: } else {
                    } else {
                        //: authBlock(false, true)
                        authBlock(false, true)
                    }
                }
            //: case .restricted:
            case .restricted:
                //: authBlock(false, false)
                authBlock(false, false)
            //: case .denied:
            case .denied:
                //: authBlock(false, false)
                authBlock(false, false)
            //: case .limited:
            case .limited:
                //: authBlock(true, false)
                authBlock(true, false)
            //: default:
            default:
                //: authBlock(false, false)
                authBlock(false, false)
            }
        //: } else {
        } else {
            //: switch PHPhotoLibrary.authorizationStatus() {
            switch PHPhotoLibrary.authorizationStatus() {
            //: case .notDetermined:
            case .notDetermined:
                //: PHPhotoLibrary.requestAuthorization { status in
                PHPhotoLibrary.requestAuthorization { status in
                    //: if status == .authorized {
                    if status == .authorized {
                        //: authBlock(true, false)
                        authBlock(true, false)
                    //: } else {
                    } else {
                        //: authBlock(false, false)
                        authBlock(false, false)
                    }
                }
            //: case .restricted:
            case .restricted:
                //: authBlock(false, false)
                authBlock(false, false)
            //: case .denied:
            case .denied:
                //: authBlock(false, false)
                authBlock(false, false)
            //: case .authorized:
            case .authorized:
                //: authBlock(true, false)
                authBlock(true, false)
            //: case .limited:
            case .limited:
                //: authBlock(false, false)
                authBlock(false, false)
            //: @unknown default:
            @unknown default:
                //: authBlock(false, false)
                authBlock(false, false)
            }
        }
    }

    /// 获取相机权限
    //: func requestCameraPermission(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
    func request(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
        //: switch AVCaptureDevice.authorizationStatus(for: .video) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        //: case .authorized:
        case .authorized:
            //: authBlock(true, false)
            authBlock(true, false)
        //: case .notDetermined:
        case .notDetermined:
            //: AVCaptureDevice.requestAccess(for: .video) { auth in
            AVCaptureDevice.requestAccess(for: .video) { auth in
                //: authBlock(auth, true)
                authBlock(auth, true)
            }
        //: case .restricted:
        case .restricted:
            //: authBlock(false, false)
            authBlock(false, false)
        //: case .denied:
        case .denied:
            //: authBlock(false, false)
            authBlock(false, false)
        //: default:
        default:
            //: authBlock(false, false)
            authBlock(false, false)
        }
    }
    
    /// 获取通知权限
    //: func requestNotificationPermission(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
    func ratingOff(authBlock: @escaping (_ auth: Bool, _ isFirst: Bool) -> Void) {
        //: UNUserNotificationCenter.current().getNotificationSettings { (setttings) in
        UNUserNotificationCenter.current().getNotificationSettings { (setttings) in
            //: switch setttings.authorizationStatus {
            switch setttings.authorizationStatus {
            //: case .authorized:
            case .authorized:
                //: authBlock(true, false)
                authBlock(true, false)
            //: case .denied:
            case .denied:
                //: authBlock(false, false)
                authBlock(false, false)
            //: case .notDetermined:
            case .notDetermined:
                //: authBlock(false, true)
                authBlock(false, true)
            //: case .provisional:
            case .provisional:
                //: authBlock(false, false)
                authBlock(false, false)
            //: case .ephemeral:
            case .ephemeral:
                //: authBlock(false, false)
                authBlock(false, false)
            //: @unknown default:
            @unknown default:
                //: authBlock(false, false)
                authBlock(false, false)
            }
        }
    }
}