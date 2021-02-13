//
//  HomeViewController.swift
//  IOSApp
//
//  Created by Dimitar on 1.2.21.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    var loadingView: LoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome " + (DataStore.shared.localUser?.username ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveGameRequest(_:)), name: Notification.Name("DidReviveGameRequestNotification"), object: nil)
        getUsers()
        setupTableView()
    
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
            self.declineRequest(gameRequest: gameRequest)
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
    
    func setupTableView() {
        tableView.separatorStyle = .singleLine
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
}
// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier ) as! UserCell
        let user = users[indexPath.row]
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
        
        DataStore.shared.checkForExistingGame(toUser: userId, fromUser: localUserId) { (exists, error) in
            if let error = error {
                print(error.localizedDescription)
                print("Error checking for game, try again later")
                return
            }
            if !exists {
                DataStore.shared.startGameRequest(userId: userId) { [weak self] (request, error) in
                    if request != nil {
                        self?.setupLoadingView(me: localUser, opponent: user)
                        DataStore.shared.setGameRequestDelitionListener()
                 }
              }
           }
        }
    }
}
// MARK: LoadingViewHandling
extension HomeViewController {
    
    func setupLoadingView(me: User, opponent: User) {
        if loadingView != nil {
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
        loadingView = LoadingView(me: me, opponent: opponent)
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
