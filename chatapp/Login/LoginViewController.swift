//
//  LoginViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import UIKit

final class LoginViewController: UIViewController {
  @IBOutlet private weak var usernameTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  
  @IBAction private func login(_ sender: Any) {
    guard let username = usernameTextField.text else { return }
    do {
      try UserEndpoint.login(username: username).invoke(onSuccess: { response in
        let user = response
      }, onError: { error in
        let x = error.code
      })
    } catch {
      // TODO (dittmar): handle error
      fatalError("Caught an error")
    }
  }
}
