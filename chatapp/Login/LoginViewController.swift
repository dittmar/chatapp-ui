//
//  LoginViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//
//  Handles the user management screen, which includes "logging in" and
//  creating new users.  Both actions end with the user being changed.
import UIKit

final class LoginViewController: UIViewController {
  @IBOutlet private weak var usernameTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  
  @IBAction private func login(_ sender: Any) {
    guard let username = usernameTextField.text else { return }
    
    logIn(username: username)
  }
  
  @IBAction private func createUser(_ sender: Any) {
    guard let username = usernameTextField.text else { return }
    
    do {
      try NoContentEndpoint.createUser(username: username).invoke(onSuccess: { response in        
        DispatchQueue.main.async { [weak self] in
          self?.logIn(username: username)
        }
      }, onError: { error in
        DispatchQueue.main.async { [weak self] in
          self?.showErrorAlert(error)
        }
      })
    } catch {
      fatalError("Caught an unexpected error")
    }
  }
  
  private func logIn(username: String) {
    do {
      try UserEndpoint.login(username: username).invoke(onSuccess: { response in
        // This isn't a secure way of identifying a user.  We should be storing
        // data in the keychain instead of local storage, and we should be using something
        // like OAuth 2.0 for managing auth with an access token/refresh token pair to
        // persist auth across app installs securely over time
        LocalStorage.user = response
        DispatchQueue.main.async { [weak self] in
          self?.dismiss(animated: true, completion: nil)
        }
      }, onError: { error in
        DispatchQueue.main.async { [weak self] in
          self?.showErrorAlert(error)
        }
      })
    } catch {
      fatalError("Caught an unexpected error")
    }
  }
  
  private func showErrorAlert(_ apiError: ApiError) {
    let alert = UIAlertController(title: "Error", message: apiError.message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(alertAction)
    
    present(alert, animated: true, completion: nil)
  }
}
