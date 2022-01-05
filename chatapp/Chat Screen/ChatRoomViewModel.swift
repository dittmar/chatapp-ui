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
  func didSendMessage()
  func shouldShowLogin()
  func shouldShowError(_ error: ApiError)
}

class ChatRoomViewModel {
  private enum RoomType {
    case direct
    case global
  }
  
  private weak var delegate: ChatRoomViewModelDelegate?
  private var selectedRoomType = RoomType.global
  
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
      self?.selectedRoomType = .direct
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
  
  func loadGlobalMessages() throws {
    try MessageEndpoint.listMessagesGlobal.invoke(onSuccess: { [weak self] response in
      self?.updateMessages(response)
      self?.selectedRoomType = .global
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
  
  func refreshMessages() throws {
    if selectedRoomType == .global {
      try loadGlobalMessages()
    }
  }
  
  func sendMessage(receiverId: Int? = nil, message: String) throws {
    guard let senderId = LocalStorage.user?.id else {
      delegate?.shouldShowLogin()
      return
    }
    
    try NoContentEndpoint.sendMessage(senderId: senderId, receiverId: receiverId, message: message).invoke(onSuccess: { [weak self] _ in
      self?.delegate?.didSendMessage()
    }, onError: { error in
      // TODO (dittmar): handle error
    })
  }
  
  private func updateMessages(_ messages: [Message]) {
    self.messages = messages
    delegate?.didLoadMessages()
  }
}
