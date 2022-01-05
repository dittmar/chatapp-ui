//
//  AddFriendParam.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/5/22.
//

import Foundation

struct AddFriendParam: Encodable {
  let userId: Int
  let friendName: String
}
