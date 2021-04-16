//
//  GameViewController.swift
//  IOSApp
//
//  Created by Dimitar on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var myHandHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentHandHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentTopHandConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomHandConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentHandImage: UIImageView!
    @IBOutlet weak var btnScissors: UIButton!
    @IBOutlet weak var myHandImage: UIImageView!
    @IBOutlet weak var btnPaper: UIButton!
    @IBOutlet weak var btnRock: UIButton!
    @IBOutlet weak var btnRandom: UIButton!
    @IBOutlet weak var lblGameStatus: UILabel!
    @IBOutlet weak var bloodImageView: UIImageView!
    
    var game: Game?


    override func viewDidLoad() {
        super.viewDidLoad()
        bloodImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        setGameStatusListener()
        setConstraintsForSmalerDevices()
        lblGameStatus.text = game?.state.rawValue
            if let game = game {
                shouldEnableButtons(enable: (game.state == .inprogress))
            }
    }
    
    private func setConstraintsForSmalerDevices() {
        // 420 Height for iphone X
        
        if DeviceType.isIphone8OrSmaller {
            myHandHeightConstraint.constant = 320
            opponentHandHeightConstraint.constant = 320
        } else if DeviceType.isIphoneXOrBigger {
            myHandHeightConstraint.constant = 420
            opponentHandHeightConstraint.constant = 420
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
        animateMoves(game: updatedGame)
//        checkForWinner(game: updatedGame)
//        if updatedGame.state  == Game.GameState.finished && game?.winner == nil {
//            DataStore.shared.removeGameListener()
//            game?.winner = updatedGame.players.filter({ $0.id == DataStore.shared.localUser?.id }).first
//            DataStore.shared.updateGameMoves(game: self.game!)
//            continueToResults()
//        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        btnRock.isEnabled = enable
        btnPaper.isEnabled = enable
        btnScissors.isEnabled = enable
        btnRandom.isEnabled = enable
    }
    
    private func animateMoves(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id,
              let opponentUser = game.players.filter( { $0.id != localUserId } ).first,
              let opponentUserId = opponentUser.id else { return }
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        
        if myMove != .idle && otherMove != .idle {
            animateHandTo(move: myMove, isMyHand: true)
            animateHandTo(move: otherMove, isMyHand: false)
            //we will animate both hands at the same time back on board
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.opponentTopHandConstraint.constant = Moves.mimimumY(isOpponent: true)
                self.bottomHandConstraint.constant = Moves.mimimumY(isOpponent: false)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { finished in
                    //Homework
                    if finished {
                        self.checkForWinner(game: game)
                    }
                }
            }
            return
        }
    }
    
    private func setWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            DataStore.shared.removeGameListener()
            self.game?.winner = game.players.filter({ $0.id == localUserId }).first
            self.game?.state = .finished
            DataStore.shared.updateGameMoves(game: self.game!)
            self.continueToResults()
        }
    }
    
    private func animateHandTo(move: Moves?, isMyHand: Bool) {
        guard let move = move, move != .idle else { return }

        if isMyHand {
            bottomHandConstraint.constant = Moves.maximumY
        } else {
            opponentTopHandConstraint.constant = Moves.maximumY
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        } completion: { finished in
            if finished {
                if isMyHand {
                    self.myHandImage.image = UIImage(named: move.imageName(isOpponent: !isMyHand))
                } else {
                    self.opponentHandImage.image = UIImage(named: move.imageName(isOpponent: true))
                }
            }
        }
    }
    private func animateFinalMove(game: Game ,space: CGFloat, animatingImageView: UIImageView) {
        UIView.animate(withDuration: 0.5) {
            animatingImageView.transform = CGAffineTransform(translationX: 0, y: space)
        } completion: { finished in
            if finished {
                UIView.animate(withDuration: 0.5) {
                    self.bloodImageView.transform = .identity
                    self.myHandImage.transform = .identity
                } completion: { finished in
                    if finished {
                        self.setWinner(game: game)
                        if animatingImageView == self.myHandImage {
                            self.setWinner(game: game)
                        } else {
                            if self.game?.winner != nil {
                                self.continueToResults()
                            }
                        }
                    }
                }
            }
        }
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
                if mMove == oMove {
                    self.game?.state = .finished
                    DataStore.shared.updateGameMoves(game: self.game!)
                    self.continueToResults()
                    return
                }
                let space = abs((opponentHandImage.frame.origin.y + opponentHandImage.frame.height) - myHandImage.frame.origin.y)
                if mMove > oMove {
                    //winner is mMove
                    animateFinalMove(game: game, space: -space, animatingImageView: myHandImage)
                } else if oMove > mMove {
                    animateFinalMove(game: game, space: space, animatingImageView: opponentHandImage)
                } else {
                    //draw
                }
            }
        }
    }
    
    func continueToResults() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        controller.game = game
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
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
    
    @IBAction func onRandom(_ sender: UIButton) {
        let choises: [Moves] = Moves.allCases.filter( { $0 != .idle } )
       // let choises: [Moves] = [.paper,.rock,.scissors]
        if let move = choises.randomElement() {
            gameChoices(choice: move)
            selectButtonForMove(move: move)
        }
        
        //More swifty way
//      game.moves[localUserId] = Moves.allCases.filter { $0 != .idle }.randomElements()

    }
    @IBAction func onRock(_ sender: UIButton) {
        sender.isSelected = true
        gameChoices(choice: .rock)
    }
    
    @IBAction func onPaper(_ sender: UIButton) {
        sender.isSelected = true
        gameChoices(choice: .paper)
    }
    
    @IBAction func onScissors(_ sender: UIButton) {
        sender.isSelected = true
        gameChoices(choice: .scissors)
    }
    func gameChoices(choice: Moves) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else {
            return
        }
        game.moves[localUserId] = choice
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
    }
    private func selectButtonForMove(move: Moves) {
        switch move {
        case .idle:
            return
        case .paper:
            btnPaper.isSelected = true
        case .rock:
            btnRock.isSelected = true
        case .scissors:
            btnScissors.isSelected = true
        }
    }
}
