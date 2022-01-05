//
//  FriendsListViewModel.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/5/22.
//

import Foundation

protocol FriendsListViewModelDelegate: AnyObject {
  func didAddFriend(_ friend: Friend)
  func didDeleteFriend(_ friendId: Int)
  func didUpdateFriends(_ friends: [Friend])
  func shouldShowError(_ error: ApiError)
}

class FriendsListViewModel {
  private weak var delegate: FriendsListViewModelDelegate?
  
  init(delegate: FriendsListViewModelDelegate) {
    self.delegate = delegate
  }
  
  func addFriend(friendName: String) throws {
    guard let userId = LocalStorage.user?.id else { return }
    
    try FriendEndpoint.addFriend(userId: userId, friendName: friendName).invoke(onSuccess: { [weak self] response in
      self?.delegate?.didAddFriend(response)
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
  
  func getFriends() throws {
    guard let userId = LocalStorage.user?.id else { return }
    
    try FriendsEndpoint.listFriends(userId: userId).invoke(onSuccess: { [weak self] response in
      self?.delegate?.didUpdateFriends(response)
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
  
  func deleteFriend(friendId: Int) throws {
    guard let userId = LocalStorage.user?.id else { return }
    
    try NoContentEndpoint.deleteFriend(userId: userId, friendId: friendId).invoke(onSuccess: { [weak self] _ in
      self?.delegate?.didDeleteFriend(friendId)
    }, onError: { [weak self] error in
      self?.delegate?.shouldShowError(error)
    })
  }
}
