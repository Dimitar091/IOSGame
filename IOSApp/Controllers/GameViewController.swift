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
            if let game = game {
                shouldEnableButtons(enable: (game.state == .inprogress))
            }
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
        shouldEnableButtons(enable: (updatedGame.state == .inprogress))
        lblGameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        checkForWinner(game: updatedGame)
        if updatedGame.state  == Game.GameState.finished {
            //dismis
            showAlertForGameEnd(title: "Congratz", message: "You won")
        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        btnRock.isEnabled = enable
        btnPaper.isEnabled = enable
        btnScissors.isEnabled = enable
        btnRandom.isEnabled = enable
    }
    
    private func checkForWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id,
              let opponentUser = game.players.filter( { $0.id != localUserId } ).first,
              let opponentUserId = opponentUser.id else { return }
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        
        if myMove == .idle  && otherMove == .idle {
            //Both haven't picked move yet
        } else if myMove == .idle {
            //still waiting
        } else if otherMove == .idle {
            // still waiting
        } else {
            // we have both picks
            if let mMove = myMove, let oMove = otherMove {
                if mMove > oMove {
                    //winner is mMove
                } else {
                    //winner is oMove
                }
            }
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
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else {
            return
        }
        let choises: [Moves] = Moves.allCases.filter( { $0 != .idle } )
       // let choises: [Moves] = [.paper,.rock,.scissors]
        let move = choises.randomElement()
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        
        //More swifty way
//      game.moves[localUserId] = Moves.allCases.filter { $0 != .idle }.randomElements()

        
    }
    @IBAction func onRock(_ sender: Any) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else {
            return
        }
        game.moves[localUserId] = .rock
        DataStore.shared.updateGameMoves(game: game)
    }
    
    @IBAction func onPaper(_ sender: Any) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else {
            return
        }
        game.moves[localUserId] = .paper
        DataStore.shared.updateGameMoves(game: game)
    }
    
    @IBAction func onScissors(_ sender: Any) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else {
            return
        }
        game.moves[localUserId] = .scissors
        DataStore.shared.updateGameMoves(game: game)
    }
}
