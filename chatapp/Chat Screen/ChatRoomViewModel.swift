//
//  ChatRoomViewModel.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/4/22.
//

import Foundation
import UIKit

protocol ChatRoomViewModelDelegate: AnyObject {
  func didLoadMessages()
  func shouldShowError(_ error: ApiError)
}

class ChatRoomViewModel {
  private weak var delegate: ChatRoomViewModelDelegate?
  
  var currentUsername: String {
    String(format: NSLocalizedString("CurrentUserLabelFormat", comment: "Current user: "), LocalStorage.user?.username ?? NSLocalizedString("NoUser", comment: "anonymous"))
  }
  
  var messages = [Message]()
  
  init(delegate: ChatRoomViewModelDelegate?) {
    self.delegate = delegate
  }
  
  func loadDirectMessages(senderId: Int, receiverId: Int) throws {
    try MessageEndpoint.listMessagesDirect(senderId: senderId, receiverId: receiverId).invoke(onSuccess: { [weak self] response in
      self?.updateMessages(response)
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
  
  func loadGlobalMessages() throws {
    try MessageEndpoint.listMessagesGlobal.invoke(onSuccess: { [weak self] response in
      self?.updateMessages(response)
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
  
  private func updateMessages(_ messages: [Message]) {
    self.messages = messages
    delegate?.didLoadMessages()
  }
}
