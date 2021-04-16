//
//  AlertPresenter.swift
//  IOSApp
//
//  Created by Dimitar on 5.3.21.
//

import Foundation
import UIKit

protocol AlertPresenter {
    func showAlertWith(title: String,msg: String)
    func showGameRequestDeclinedAlert()
    func showErrorAlert(msg: String)
}

extension AlertPresenter where Self: UIViewController {
    func showAlertWith(title: String,msg: String) {
        showAlert(title: title, msg: msg)
    }
    func showErrorAlert(msg: String) {
        showAlert(title: "Error", msg: msg)
    }

    func showGameRequestDeclinedAlert() {
        showAlert(title: nil, msg: "Your game request was declined")
    }
    
    private func showAlert(title: String?, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
