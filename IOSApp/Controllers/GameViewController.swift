//
//  GameViewController.swift
//  IOSApp
//
//  Created by Dimitar on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var btnScissors: UIButton!
    @IBOutlet weak var btnPaper: UIButton!
    @IBOutlet weak var btnRock: UIButton!
    @IBOutlet weak var btnRandom: UIButton!
    @IBOutlet weak var lblGameStatus: UILabel!
    
    var game: Game?


    override func viewDidLoad() {
        super.viewDidLoad()
        setGameStatusListener()
        lblGameStatus.text = game?.state.rawValue
    }
    
    private func setGameStatusListener() {
        guard let game = game else { return }
        DataStore.shared.setGameStateListener(game: game) { [weak self] (updatedGame, error) in
            if let updatedGame = updatedGame {
                self?.updateGame(updatedGame: updatedGame)
            }
        }
    }
    
    private func updateGame(updatedGame: Game) {
        lblGameStatus.text = updatedGame.state.rawValue
        game = updatedGame

        if updatedGame.state  == Game.GameState.finished {
            //dismis
            showAlertForGameEnd(title: "Congratz", message: "You won")
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func onClose(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Are you sure u want to exit the game?", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
            //update GameState
            if let game = self?.game {
                DataStore.shared.updateGameStatus(game: game, newState: Game.GameState.finished.rawValue)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(exit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertForGameEnd(title: String?, message: String?) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let exit = UIAlertAction(title: "Ok",
                                     style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            alert.addAction(exit)
            present(alert, animated: true, completion: nil)
        }
    
    @IBAction func onRandom(_ sender: Any) {
        
    }
    @IBAction func onRock(_ sender: Any) {
    }
    
    @IBAction func onPaper(_ sender: Any) {
    }
    
    @IBAction func onScissors(_ sender: Any) {
    }
}
