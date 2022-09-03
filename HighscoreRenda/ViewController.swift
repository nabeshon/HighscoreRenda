//
//  ViewController.swift
//  HighscoreRenda
//
//  Created by 渡邉昇 on 2022/09/01.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    
    //タップ数を表示するLabelの変数を準備する
    @IBOutlet var countLabel: UILabel!
    
    //ゲーム名を表示するLabelの変数を準備する
    @IBOutlet var titleLabel: UILabel!
    
    //残り時間を表示するLabelの変数を準備する
    @IBOutlet var remainLabel: UILabel!
    
    //世界ハイスコアを表示するLabelの変数を準備する
    @IBOutlet var globalHighscoreLabel: UILabel!
    
    //自己ハイスコアを表示するLabelの変数を準備する
    @IBOutlet var personalHighscoreLabel: UILabel!
    
    //TAPボタンの変数を準備する
    @IBOutlet var tapButton: UIButton!
    
    //秒数切替ボタンの変数を準備する
    @IBOutlet var changeButton: UIButton!
    
    //タップ数を数える変数を準備する
    var tapCount = 0
    
    //最大残り時間を保存する変数を準備する
    var maxremain: Float = 5.0
    
    //残り時間用の変数を準備する
    var remain: Float = 5.0
    
    //クールタイム用の変数を準備する
    var cooltime: Float = 0.0
    
    //ゲームが始まっているかどうかの変数を準備する
    var isPlaying : Bool = false
    
    //ハイスコアを取得しているかどうかの変数を準備する
    var isGettingHighscore: Bool = false
    
    //世界ハイスコアを保存する変数を準備する
    var globalHighscore: Int = 0
    
    //自己ハイスコアを保存する変数を準備する
    var personalHighscore : Int = 0
    
    var timer: Timer = Timer()
    
    //Firestoreを扱うためのプロパティ
    let firestore = Firestore.firestore()
    
    
    var saveData: UserDefaults = UserDefaults.standard
    
    //TAPボタンがタップされた時に
    @IBAction func tapTapButton(){
        if(!isGettingHighscore){
            if(isPlaying && cooltime == 3.0){
                //タップを数える変数をプラス1する
                tapCount = tapCount + 1
                
                //タップされた和をラベルに反映する
                countLabel.text = String(tapCount)
            }else if(cooltime == 0.0){
                start()
            }
        }
    }
    
    //時間切替ボタンがタップされた時に
    @IBAction func tapChangeButton(){
        if(!isGettingHighscore){
            if(maxremain == 5.0){
                maxremain = 10.0
            }else if(maxremain == 10.0){
                maxremain = 15.0
            }else{
                maxremain = 5.0
            }
            stop()
            //カウント数を0に戻す
            tapCount = 0
            //タップされた和をラベルに反映する
            countLabel.text = String(tapCount)
            //ゲーム名を表示するラベルを設定する
            titleLabel.text = String(Int(maxremain)) + "秒連打ゲーム"
            
            getHighscore()
        }
    }
    
    @objc func up() {
        if remain > 0.0 {
            //remainから0.01引く
            remain = remain - 0.01
            //残り時間を表示するLabelに小数点以下2桁まで表示
            remainLabel.text = "残り時間:"+String(format: "%.2f", remain)+"秒"
        }else if cooltime > 0.0{
            //cooltimeから0.01引く
            cooltime -= 0.01
            //クールタイムを表示するLabelに小数点以下2桁まで表示
            remainLabel.text = "クールタイム:"+String(format: "%.2f", cooltime)+"秒"
        }else {
            //クールタイムと残り時間が両方0秒になったら停止
            stop()
        }
        if remain <= 0.0 && cooltime == 3.0 {
            //ボタンの文字変更
            tapButton.setTitle("計測終了", for: .normal)
            tapButton.titleLabel?.font = .systemFont(ofSize: 64)
            
            if personalHighscore < tapCount {
                //自己ハイスコア更新->世界ハイスコアと比較
                
                saveData.set(tapCount, forKey: String(Int(maxremain))+"sHighscore")
                personalHighscore = tapCount
                personalHighscoreLabel.text = "自己ハイスコア:" + String(personalHighscore)
                
                isGettingHighscore = true
                
                //Firestoreのデータを読み込む
                firestore.collection("highscore").document(String(Int(maxremain))+"s").addSnapshotListener {snapshot, error in
                    if error != nil {
                        print("エラーが発生しました")
                        print(error)
                        return
                    }
                    let data = snapshot?.data()
                    if data == nil {
                        print("データがありません")
                        return
                    }
                    let count = data!["count"] as? Int
                    if count == nil {
                        print(String(Int(self.maxremain))+"sという対応する値がありません")
                        return
                    }
                    self.globalHighscore = count!
                    if(self.globalHighscore < self.tapCount){
                        //世界ハイスコア更新
                        self.changeGlobalHighscore()
                        self.globalHighscoreLabel.text = "世界ハイスコア:" + String(self.tapCount)
                    }
                    self.isGettingHighscore = false
                }
            }
        }
    }
    
    @IBAction func start() {
        //ボタンの文字変更
        tapButton.setTitle("TAP!", for: .normal)
        tapButton.titleLabel?.font = .systemFont(ofSize: 64)
        
        //カウント数を0に戻す
        tapCount = 0
        
        //タップされた和をラベルに反映する
        countLabel.text = String(tapCount)
        
        //クールタイムを3.0秒に設定
        cooltime = 3.0
        
        isPlaying = true
        
        if !timer.isValid {
            //タイマーが動作していなかったら動かす
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.up), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func stop() {
        if timer.isValid {
            //タイマーが動作していたら停止する
            timer.invalidate()
        }
        //ボタンの文字変更
        tapButton.setTitle("START", for: .normal)
        tapButton.titleLabel?.font = .systemFont(ofSize: 64)
        
        //クールタイムを0.0に戻す
        cooltime = 0.0
        
        //remainを元に戻す
        remain = maxremain
        
        //残り時間を表示するLabelに小数点以下2桁まで表示
        remainLabel.text = "残り時間:"+String(format: "%.2f", remain)+"秒"
        
        isPlaying = false
    }
    
    @IBAction func getHighscore(){
        
        isGettingHighscore = true
        
        personalHighscore = (saveData.object(forKey: String(Int(maxremain))+"sHighscore") as? Int)!
        personalHighscoreLabel.text = "自己ハイスコア:" + String(personalHighscore)
        
        //Firestoreのデータを読み込む
        firestore.collection("highscore").document(String(Int(maxremain))+"s").addSnapshotListener {snapshot, error in
            if error != nil {
                print("エラーが発生しました")
                print(error)
                return
            }
            let data = snapshot?.data()
            if data == nil {
                print("データがありません")
                return
            }
            let count = data!["count"] as? Int
            if count == nil {
                print(String(Int(self.maxremain))+"sという対応する値がありません")
                return
            }
            self.globalHighscore = count!
            self.globalHighscoreLabel.text = "世界ハイスコア:" + String(self.globalHighscore)
            self.isGettingHighscore = false
        }
    }
    
    @IBAction func changeGlobalHighscore() {
        //FirestoreにtapCountを書き込む
        firestore.collection("highscore").document(String(Int(maxremain))+"s").setData(["count": tapCount])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view.
        
        saveData.register(defaults: ["5sHighscore" : 0,"10sHighscore" : 0,"15sHighscore" : 0])
        
        //ボタンを丸くする
        tapButton.layer.cornerRadius = 125
        changeButton.layer.cornerRadius = 15
        
        getHighscore()
    }
    
}

