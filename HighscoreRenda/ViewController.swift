//
//  ViewController.swift
//  HighscoreRenda
//
//  Created by 渡邉昇 on 2022/09/01.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var shortButton: UIButton!
    @IBOutlet var normalButton: UIButton!
    @IBOutlet var longButton: UIButton!
    
    var maxremain: Float = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        shortButton.layer.cornerRadius = 35
        normalButton.layer.cornerRadius = 35
        longButton.layer.cornerRadius = 35
    }
    
    @IBAction func tapShortButton() {
        maxremain = 5.0
        performSegueToGame()
    }
    
    @IBAction func tapNormalButton() {
        maxremain = 10.0
        performSegueToGame()
    }
    
    @IBAction func tapLongButton() {
        maxremain = 15.0
        performSegueToGame()
    }
    
    func performSegueToGame() {
        performSegue(withIdentifier: "toGameView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameView" {
            let gameViewController = segue.destination as! GameViewController
            gameViewController.maxremain = self.maxremain
        }
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
