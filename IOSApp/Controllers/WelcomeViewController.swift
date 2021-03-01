//
//  WelcomeViewController.swift
//  IOSApp
//
//  Created by Dimitar on 1.2.21.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var txtUsername: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtUsername.layer.cornerRadius = 10
        txtUsername.layer.masksToBounds = true
        txtUsername.returnKeyType = .continue
        txtUsername.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUsername.becomeFirstResponder()
    }
        

    @IBAction func onContinue(_ sender: Any) {
        guard let username = txtUsername.text?.lowercased() else { return }
        
        DataStore.shared.checkForExistingUsername(username) { (exists, _) in
            if exists {
                self.showErrorAlert(username: username)
                return
            }
            
            DataStore.shared.continueWithGuest(username: username) { [weak self] (user, error) in
                guard let self = self else {return}
                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                }
            }
        }
      
    }
    func showErrorAlert(username: String) {
        let alert = UIAlertController(title: "Error", message: "\(username) already exists", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
