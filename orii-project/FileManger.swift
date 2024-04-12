//
//  FileManger.swift
//  orii-project
//
//  Created by shiranekaoru on 2024/04/12.
//

import Foundation

//csvファイルに書き込むためのクラス
//parameter
//foler_name: ここに書かれているフォルダがDocument以下に作成される
//filename: インスタンスを生成する際に指定される変数。ここに入るのは、folder_name以下に生成されるファイル名（今はtest.csvになっている→ContentView参照）

class CSVFileManager{
    
    var filename: String
    var fileManager: FileManager
    
    var folder_name = "orii-project" //フォルダの名前
   
    
    //初期化:filenameのファイルがなかった場合新たにファイルを作製
    init(filename: String) {
        //fileの設定
        self.filename = filename
        fileManager = FileManager.default
        let docPath = NSHomeDirectory() + "/Documents/" + folder_name
        let filePath = docPath + "/" + self.filename
        //csvデータに書き込むデータを定義
        let csv = ""
        let data = csv.data(using: .utf8)
        
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: docPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // エラーの場合
    
        }
        //ファイルが存在するかチェック
        if !fileManager.fileExists(atPath: filePath){
            fileManager.createFile(atPath: filePath, contents:data,attributes: [:])
        }else{
            print("すでに存在します")
        }
    }
    
    //csvファイル書き込み
    func write(content: String){
        let path = NSHomeDirectory() + "/Documents/" + folder_name + "/" + self.filename
        let tmpFile: URL = URL(fileURLWithPath: path)
        if let strm = OutputStream(url: tmpFile,append: false){
            strm.open()
            let BOM = "\u{feff}"
            // U+FEFF：バイトオーダーマーク（Byte Order Mark, BOM）
            // Unicode の U+FEFFは、表示がない文字。「ZERO WIDTH NO-BREAK SPACE」（幅の無い改行しない空白）
            strm.write(BOM, maxLength: 3)// UTF-8 の BOM 3バイト 0xEF 0xBB 0xBF 書き込み
            
            let new_content = "user,touchX,touchY,accelerationX,accelerationY,accelerationZ,gyrometerX,gyrometerY,gyrometerZ,attitudeX,attitudeY,attitudeZ,gravityX,gravityY,gravityZ,magnetX,magnetY,magnetZ\r\n" + content
            
            let data = new_content.data(using: .utf8)
            // string.data(using: .utf8)メソッドで文字コード UTF-8 の
            // Data 構造体を得る
            _ = data?.withUnsafeBytes {//dataのバッファに直接アクセス
                strm.write($0.baseAddress!, maxLength: Int(data?.count ?? 0))
                // 【$0】
                // 連続したメモリ領域を指す UnsafeRawBufferPointer パラメーター
                // 【$0.baseAddress】
                // バッファへの最初のバイトへのポインタ
                // 【maxLength:】
                // 書き込むバイトdataバッファのバイト数（全長）
                // 【data?.count ?? 0】
                // ?? は、Nil結合演算子（Nil-Coalescing Operator）。
                // data?.count が nil の場合、0。
                // 【_ = data】
                // 戻り値を利用しないため、_で受け取る。
            }
            strm.close() // ストリームクローズ
        }

        
    }
    
    //csvファイル読み込み
    func read() -> String{
        
        let path = NSHomeDirectory() + "/Documents/" + folder_name + "/" + self.filename
        
        do{
            let csvString = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
            return csvString
        }catch let error as NSError{
            print("エラー：\(error)")
            return ""
        }
    }
    
}
