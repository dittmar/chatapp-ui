//
//  Notifications.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import Foundation

enum Notification: String {
  case didUpdateUser
  
  var name: NSNotification.Name {
    NSNotification.Name(rawValue: rawValue)
  }
}
