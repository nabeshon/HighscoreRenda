//
//  RankingViewController.swift
//  HighscoreRenda
//
//  Created by 渡邉昇 on 2022/09/03.
//

import UIKit

class RankingViewController: UIViewController {
    
    @IBOutlet var backButton: UIButton!
    
    var maxremain : Float = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backButton.layer.cornerRadius = 15.0
    }
    
    @IBAction func tapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
