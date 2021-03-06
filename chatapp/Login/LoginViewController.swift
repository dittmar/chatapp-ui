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
  @IBOutlet private weak var headerLabel: UILabel!
  
  @IBOutlet private var mainView: UIView!{
    didSet {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardIfNecessary))
      mainView.addGestureRecognizer(tapGestureRecognizer)
    }
  }
  
  @IBOutlet private weak var usernameTextField: UITextField!
  @IBOutlet private weak var passwordTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    headerLabel.text = NSLocalizedString("LoginScreenHeader", comment: "Log in to be able...")
  }
  
  @IBAction private func login(_ sender: Any) {
    guard let username = usernameTextField.text,
          let password = passwordTextField.text else { return }
    
    logIn(username: username, password: password)
  }
  
  @IBAction private func createUser(_ sender: Any) {
    guard let username = usernameTextField.text,
          let password = passwordTextField.text else { return }
    
    do {
      try NoContentEndpoint.createUser(username: username, password: password).invoke(onSuccess: { response in
        DispatchQueue.main.async { [weak self] in
          self?.logIn(username: username, password: password)
        }
      }, onError: { [weak self] error in
        self?.showErrorAlert(apiError: error)
      })
    } catch {
      fatalError("Caught an unexpected error")
    }
  }
  
  @IBAction func didTapReturnUserTextField(_ sender: Any) {
    passwordTextField.becomeFirstResponder()
  }
  
  @IBAction func didTapReturnPasswordTextField(_ sender: Any) {
    login(sender)
  }
  
  @objc private func dismissKeyboardIfNecessary() {
    view.endEditing(true)
  }
  
  private func logIn(username: String, password: String) {
    do {
      try UserEndpoint.login(username: username, password: password).invoke(onSuccess: { response in
        // This isn't a secure way of identifying a user.  We should be storing
        // data in the keychain instead of local storage, and we should be using something
        // like OAuth 2.0 for managing auth with an access token/refresh token pair to
        // persist auth across app installs securely over time
        LocalStorage.user = response
        DispatchQueue.main.async { [weak self] in
          self?.dismiss(animated: true, completion: nil)
        }
      }, onError: { [weak self] error in
        self?.showErrorAlert(apiError: error)
      })
    } catch {
      fatalError("Caught an unexpected error")
    }
  }
}
