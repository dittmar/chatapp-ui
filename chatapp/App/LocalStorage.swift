//
//  LocalStorage.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import Foundation

struct LocalStorage {
  enum Key: String {
    case user
  }
  
  static var user: User? {
    get {
      guard let data = UserDefaults.standard.data(forKey: Key.user.rawValue) else { return nil }
      
      return try? JSONDecoder().decode(User.self, from: data)
    }
    set {
      // If the new user is nil, purge it
      guard let newUser = newValue else {
        UserDefaults.standard.set(nil, forKey: Key.user.rawValue)
        return
      }
      
      // If the new user won't encode, do nothing
      guard let data = try? JSONEncoder().encode(newUser) else { return }
      
      UserDefaults.standard.set(data, forKey: Key.user.rawValue)
      NotificationCenter.default.post(name: Notification.didUpdateUser.name, object: nil)
    }
  }
}
