//
//  FriendTableViewCell.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/5/22.
//

import UIKit

final class FriendTableViewCell: UITableViewCell {
  @IBOutlet private weak var friendNameLabel: UILabel!
  
  func setUp(friendName: String) {
    friendNameLabel.text = friendName
  }
}
