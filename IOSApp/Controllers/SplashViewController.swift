//
//  SplashViewController.swift
//  IOSApp
//
//  Created by Dimitar on 22.2.21.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUsers()

    }
    func checkForUsers() {
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid {
            DataStore.shared.getUserWithId(id: id) { (user, error) in
                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                    return
                }
                do {
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "welcomeSegue", sender: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            self.performSegue(withIdentifier: "welcomeSegue", sender: nil)
        }
    }
    
}
