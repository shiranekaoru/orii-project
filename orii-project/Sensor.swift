//
//  MotionManager.swift
//  orii-project
//
//  Created by shiranekaoru on 2024/04/12.
//
import SwiftUI
import Foundation
import CoreMotion

//IMUセンサを扱うクラス
class MotionSensor: NSObject, ObservableObject {
    
    @Published var isStarted = false
    //加速度センサ
    @Published var accxStr = "0.0"
    @Published var accyStr = "0.0"
    @Published var acczStr = "0.0"
    //ジャイロセンサ
    @Published var gyroxStr = "0.0"
    @Published var gyroyStr = "0.0"
    @Published var gyrozStr = "0.0"
    //姿勢
    @Published var attitudexStr = "0.0"
    @Published var attitudeyStr = "0.0"
    @Published var attitudezStr = "0.0"
    //重力
    @Published var gravityxStr = "0.0"
    @Published var gravityyStr = "0.0"
    @Published var gravityzStr = "0.0"
    //コンパス（磁力）コンパスを使う場合は注意が必要で、方向を決めるための基準を指定してあげる必要がある。基準はデータ取得開始時(StartDeviceMotionUpdates)に指定する（今回は.xMagneticNorthZVerticalとしているが自分のあった基準に変更する。詳しくは公式ドキュメント）。
    @Published var magnetxStr = "0.0"
    @Published var magnetyStr = "0.0"
    @Published var magnetzStr = "0.0"
    
    let motionManager = CMMotionManager()
    let GPSManager = CLLocationManager()
    
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(using:[.xMagneticNorthZVertical], to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        
        isStarted = true
    }
    
    func stop() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        accxStr = String(deviceMotion.userAcceleration.x)
        accyStr = String(deviceMotion.userAcceleration.y)
        acczStr = String(deviceMotion.userAcceleration.z)
        
        gyroxStr = String(deviceMotion.rotationRate.x)
        gyroyStr = String(deviceMotion.rotationRate.y)
        gyrozStr = String(deviceMotion.rotationRate.z)
        
        attitudexStr = String(deviceMotion.attitude.pitch)
        attitudeyStr = String(deviceMotion.attitude.roll)
        attitudezStr = String(deviceMotion.attitude.yaw)
        
        gravityxStr = String(deviceMotion.gravity.x)
        gravityyStr = String(deviceMotion.gravity.y)
        gravityzStr = String(deviceMotion.gravity.z)
        
        magnetxStr = String(deviceMotion.magneticField.field.x)
        magnetyStr = String(deviceMotion.magneticField.field.y)
        magnetzStr = String(deviceMotion.magneticField.field.z)
        
    }
    
}


//近接センサーを扱うクラス
class ProximitySensorManager: ObservableObject {
    @Published var isCloseToUser = false

    init() {
        // 近接センサーを有効にする
        UIDevice.current.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }

    @objc private func proximityChanged() {
        DispatchQueue.main.async {
            self.isCloseToUser = UIDevice.current.proximityState
        }
    }

    deinit {
        // 近接センサーを無効にする
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
    }
}

class BrightnessManager: ObservableObject {
    @Published var brightness: CGFloat = UIScreen.main.brightness

    init() {
        // NotificationCenterに輝度変更通知を登録
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(brightnessDidChange),
            name: UIScreen.brightnessDidChangeNotification,
            object: nil
        )
    }

    @objc func brightnessDidChange() {
        DispatchQueue.main.async {
            // UIScreenから輝度値を取得し更新
            self.brightness = UIScreen.main.brightness
        }
    }

    deinit {
        // NotificationCenterのオブザーバー登録を解除
        NotificationCenter.default.removeObserver(self)
    }
}
