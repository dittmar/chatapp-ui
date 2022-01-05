//
//  Message.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/4/22.
//

import Foundation

struct Message: Codable {
  let message: String
  let receiver: String?
  let sender: String
}
