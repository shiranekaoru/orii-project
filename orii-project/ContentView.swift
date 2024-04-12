//
//  ContentView.swift
//  orii-project
//
//  Created by shiranekaoru on 2024/04/11.
//

import SwiftUI
import Foundation
import Combine

let MAX_COUNT = 10//何回タッチするか
let DO_FREQ = 0.01//データの取得するための周期(Hz)


struct ContentView: View {
    @State private var state: Bool = true // true(user1) or false(other)
    @State private var location = CGPoint() //タッチ位置
    @State private var user:String = "User1"//タッチしている人
    @State private var sendMessage:String = ""//csvファイルに送る内容
    @State private var count = 0//タッチした回数
    
    //Class一覧（センサー or csvfilemanager）
    @ObservedObject var motion = MotionSensor()
    @State var filemanager = CSVFileManager(filename: "test.csv")
    @StateObject var proximitySensor = ProximitySensorManager()
    @ObservedObject var brightnessManager = BrightnessManager()
    
    //timer指定した周期にてタイマーを動かす
    let timer = Timer.publish(every: DO_FREQ, on: .main, in: .common).autoconnect()
    
    //初期化
    init(){
        motion.start()//IMUセンサの値を取得
    }
    
    var body: some View {
        // countがMAX_COUNTよりも少ないかどうか
        if count < MAX_COUNT {
            VStack {
                //画面表示UI
                if state{
                    Text("User1")
                        .foregroundColor(.red)
                } else {
                    Text("User2")
                        .foregroundColor(.blue)
                }
                Text("は赤枠の画面をタップしてください")
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear) // ここで背景に透明な色を設定
            .contentShape(Rectangle())// 透明な四角形を描画
            .border(Color.red)// バックグラウンドを赤色に描画
            .onTapGesture(coordinateSpace: .global) { TapLocation in //タップした時のイベントをここに記載
                count += 1
                state.toggle()//状態の遷移
                
                if state{
                    user = "User2"
                } else {
                    user = "User1"
                }
                
                self.location = TapLocation//タッチ位置を更新
                
                
            }
            .onReceive(timer) { _ in //指定した周期にて以下のイベントを実行
                
                // csvファイルに書き込む内容を代入
                sendMessage += "\(self.user),\(self.location.x),\(self.location.y),\(self.motion.accxStr),\(self.motion.accyStr),\(self.motion.acczStr),\(self.motion.gyroxStr),\(self.motion.gyroyStr),\(self.motion.gyrozStr),\(self.motion.attitudexStr),\(self.motion.attitudeyStr),\(self.motion.attitudezStr),\(self.motion.gravityxStr),\(self.motion.gravityyStr),\(self.motion.gravityzStr),\(self.motion.magnetxStr),\(self.motion.magnetyStr),\(self.motion.magnetzStr)\r\n"
                
                // csvファイルに保存
                filemanager.write(content: sendMessage)
            }
        } else {
            Text("終了")
        }
        
    }
}

#Preview {
    ContentView()
}


