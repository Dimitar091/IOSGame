//
//  WinViewController.swift
//  IOSApp
//
//  Created by Dimitar on 2.3.21.
//

import UIKit

class WinViewController: UIViewController {

    @IBOutlet weak var lblWinLose: UILabel!
    @IBOutlet weak var lblResults: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let winner = game?.winner {
            let loser = game?.players.filter({ $0.id != winner.id }).first
            lblWinLose.text = "Congratz"
//            let loser = game?.players.filter({ $0.id != winner.id }).first
//            lblWinLose.text = loser?.username
        }
    }
    @IBAction func onHome(_ sender: UIButton) {
        if let gameController = presentingViewController as? GameViewController {
            dismiss(animated: false) {
                gameController.dismiss(animated: false, completion: nil)
            }
        }
    }
    @IBAction func onRetry(_ sender: UIButton) {
    }
    
}
