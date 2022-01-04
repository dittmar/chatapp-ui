//
//  MessageTableViewCell.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/4/22.
//

import UIKit

final class MessageTableViewCell: UITableViewCell {
  @IBOutlet private weak var usernameLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  
  func setUp(username: String, message: String) {
    usernameLabel.text = username
    messageLabel.text = message
  }
}
