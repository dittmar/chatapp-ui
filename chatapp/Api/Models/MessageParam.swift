//
//  MessageParam.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/4/22.
//

import Foundation

struct MessageParam: Encodable {
  let message: String
  let receiverId: Int?
  let senderId: Int
}
