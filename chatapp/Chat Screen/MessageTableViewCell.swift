//
//  MessageTableViewCell.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/4/22.
//

import UIKit

final class MessageTableViewCell: UITableViewCell {
  @IBOutlet private weak var senderLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  
  func setUp(message: Message) {
    senderLabel.text = message.sender
    messageLabel.text = message.message
  }
}
