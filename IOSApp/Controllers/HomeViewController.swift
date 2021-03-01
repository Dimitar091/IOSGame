//
//  HomeViewController.swift
//  IOSApp
//
//  Created by Dimitar on 1.2.21.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var tableHolderView: UIView!
    @IBOutlet weak var tableHolderBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var holderImageNameView: UIView!
    
    
    var users = [User]()
    var loadingView: LoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPushNotifications()
        title = "Welcome " + (DataStore.shared.localUser?.username ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveGameRequest(_:)), name: Notification.Name("DidReviveGameRequestNotification"), object: nil)
        getUsers()
        setupTableView()
        setupAvatarView()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataStore.shared.setUsersListener { [weak self] in
            guard let self = self else {return}
            self.getUsers()
        }
        DataStore.shared.setGameRequestListener()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataStore.shared.removeUsersListener()
        DataStore.shared.removeGameRequestListener()
    }
    
    @objc private func didReciveGameRequest(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:GameRequest] else { return }
        guard let gameRequest = userInfo["GameRequest"] else { return }
        
        let fromUsername = gameRequest.fromUsername ?? ""
        let alert = UIAlertController(title: "Game Request",
                                      message: "\(fromUsername) invited you for a game" ,
                                      preferredStyle: .alert)
        let accept = UIAlertAction(title: "Accept", style: .default) { _ in
            self.acceptGameRequest(gameRequest)
        }
        let decline = UIAlertAction(title: "Decline", style: .cancel) { _ in
            self.declineRequest(gameRequest: gameRequest)
        }
        alert.addAction(accept)
        alert.addAction(decline)
        present(alert, animated: true, completion: nil)
    }
    
    private func declineRequest(gameRequest: GameRequest) {
        DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
    }
    
    func acceptGameRequest(_ gameRequest: GameRequest) {
        guard let localUser = DataStore.shared.localUser else { return }
        DataStore.shared.getUserWithId(id: gameRequest.from) { [weak self] (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let user = user {
                DataStore.shared.createGame(players: [localUser,user]) { (game, error) in
                    DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let game = game {
                        self?.enterGame(game)
                    }
                }
            }
        }
    }
    
    private func enterGame(_ game: Game,_ shouldUpdateGame: Bool = false) {
        DataStore.shared.removeGameListener()
        if shouldUpdateGame {
            var newGame = game
            newGame.state = .inprogress
            DataStore.shared.updateGameStatus(game: newGame, newState: Game.GameState.inprogress.rawValue)
            performSegue(withIdentifier: "gameSegue", sender: newGame)
        } else {
            performSegue(withIdentifier: "gameSegue", sender: game)
        }
    }
    
    private func requestPushNotifications() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.requestNotificationsPermission()
    }
    
    func setupAvatarView() {
        let avatarView = AvatarView(state: .imageAndName)
        holderImageNameView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        avatarView.username = DataStore.shared.localUser?.username
        avatarView.image = DataStore.shared.localUser?.avatarImage
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }

    private func getUsers() {
        DataStore.shared.getAllUsers { [weak self] (users, error) in
            guard let self = self else {return}
            if let users = users {
                self.users = users.filter({ $0.id != DataStore.shared.localUser?.id })
                self.tableView.reloadData()
            }
        }
    }
    @IBAction func btnExpand(_ sender: Any) {
        
        let isExpanded = tableHolderBottomConstraint.constant == 0
        
        self.btnExpand.setImage(UIImage(named: isExpanded ? "up" : "dropdown"), for: .normal)
        
        tableHolderBottomConstraint.constant = isExpanded ?  tableHolderView.frame.height : 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            //Animating frames instead of constraints
           //self.tableHolderView.frame.origin =
            //CGPoint(x: self.tableHolderView.frame.origin.x, y:-self.tableHolderView.frame.size.height)
            
        } completion: { completed in
            if completed {
                //animation is completed
                
            }
        }

    }
    func showErrorAlert(username: String) {
        let alert = UIAlertController(title: "", message: "\(username) already in game", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}
//MARK: - Navigation
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "gameSegue" else { return }
        
        let gameController = segue.destination as! GameViewController
        gameController.game = sender as? Game
    }
}
// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier ) as! UserCell
        let user = users[indexPath.row]
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        cell.setData(user: user)
        cell.delegate = self
        return cell
    }
}
// MARK: - UITableViewDataDelegate
extension HomeViewController: UserCellDelegate {
    func requestGameWith(user: User) {
        guard let userId = user.id,
              let localUser = DataStore.shared.localUser,
              let localUserId = DataStore.shared.localUser?.id else { return }
        
        DataStore.shared.checkForExistingGameRequset(toUser: userId, fromUser: localUserId) { (exists, error) in
            if let error = error {
                print(error.localizedDescription)
                print("Error checking for game, try again later")
                return
            }
            if !exists {
                self.checkForOngoaingGame(userId: userId, localUser: localUser, opponent: user)
           }
        }
    }
    func checkForOngoaingGame(userId: String, localUser: User, opponent: User) {
        let username = opponent.username
        DataStore.shared.checkForOnGoiaingGameWith(userId: userId) { [weak self] (userInGame, error) in
            if !userInGame {
                self?.sendGameRequestTo(userId: userId, localUser: localUser, opponent: opponent)
            }else {
                self?.showErrorAlert(username: "\(username ?? "already in game")" )
            }
        }
    }
    
    func sendGameRequestTo(userId: String, localUser: User, opponent: User) {
        DataStore.shared.startGameRequest(userId: userId) { [weak self] (request, error) in
            if request != nil {
                self?.setupLoadingView(me: localUser, opponent: opponent, requset: request)
                DataStore.shared.setGameRequestDelitionListener()
            }
    }
  }
}
// MARK: LoadingViewHandling
extension HomeViewController {
    
    func setupLoadingView(me: User, opponent: User, requset: GameRequest?) {
        if loadingView != nil {
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
        loadingView = LoadingView(me: me, opponent: opponent, requset: requset)
        
        loadingView?.gameAccepted = { [weak self] game in
            self?.enterGame(game, true)
            
        }
        
        view.addSubview(loadingView!)
        loadingView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    
    func hideLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
}

