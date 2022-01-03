//
//  ChatRoomViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import UIKit

final class ChatRoomViewController: UIViewController {
  @IBOutlet private weak var currentUserLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    title = "Chat App"
    updateCurrentUserLabel()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  @IBAction private func didTapMainRoom(_ sender: Any) {
  
  }
  
  
  @IBAction private func didTapFriends(_ sender: Any) {
  
  }
  
  
  @IBAction private func didTapLogin(_ sender: Any) {
    performSegue(withIdentifier: "showLogin", sender: nil)
  }
  
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentUserLabel), name: Notification.didUpdateUser.name, object: nil)
  }
  
  @objc private func updateCurrentUserLabel() {
    DispatchQueue.main.async { [weak self] in
      self?.currentUserLabel.text = String(format: NSLocalizedString("CurrentUserLabelFormat", comment: "Current user: "), LocalStorage.user?.username ?? NSLocalizedString("NoUser", comment: "anonymous"))
    }
  }
}

