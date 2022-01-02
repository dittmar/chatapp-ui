//
//  ChatRoomViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import UIKit

final class ChatRoomViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
}

