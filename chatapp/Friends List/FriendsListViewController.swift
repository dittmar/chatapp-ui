//
//  FriendsListViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/5/22.
//
//  Handles friends list management for the app as
//  well as starting direct messages with friends
import UIKit

protocol FriendsListViewControllerDelegate: AnyObject {
  func didTapFriend(friendId: Int)
}

final class FriendsListViewController: UIViewController {
  weak var delegate: FriendsListViewControllerDelegate?
  
  private var friends = [Friend]()
  private lazy var friendsListViewModel = FriendsListViewModel(delegate: self)
  
  @IBOutlet private weak var friendsTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpFriendsTable()
    do {
      try friendsListViewModel.getFriends()
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  @IBAction func tappedAddFriend(_ sender: Any) {
    let alert = UIAlertController(title: NSLocalizedString("AddFriendAlertTitle", comment: "Add a new friend?"),
                                  message: NSLocalizedString("AddFriendAlertMessage", comment: "Would you like to..."),
                                  preferredStyle: .alert)
    alert.addTextField { textField in
      textField.placeholder = "username"
    }
    
    let alertAction = UIAlertAction(title: NSLocalizedString("AddFriendAlertButtonTitle", comment: "Add friend"), style: .default) { [weak self] _ in
      guard let friendName = alert.textFields?[0].text else { return }
      do {
        try self?.friendsListViewModel.addFriend(friendName: friendName)
      } catch {
        // TODO (dittmar): handle error
      }
    }
    alert.addAction(alertAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  private func setUpFriendsTable() {
    friendsTableView.register(
      UINib(nibName: String(describing: FriendTableViewCell.self), bundle: .main),
      forCellReuseIdentifier: String(describing: FriendTableViewCell.self))
    friendsTableView.delegate = self
    friendsTableView.dataSource = self
  }
}

extension FriendsListViewController: FriendsListViewModelDelegate {
  func didAddFriend(_ friend: Friend) {
    friends.append(friend)
    
    DispatchQueue.main.async { [weak self] in
      self?.friendsTableView.reloadData()
    }
  }
  
  func didDeleteFriend(_ friendId: Int) {
    if let index = (friends.firstIndex { $0.friendId == friendId }) {
      friends.remove(at: index)
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.friendsTableView.reloadData()
    }
  }
  
  func didUpdateFriends(_ friends: [Friend]) {
    self.friends = friends
    
    DispatchQueue.main.async { [weak self] in
      self?.friendsTableView.reloadData()
    }
  }
  
  func shouldShowError(_ error: ApiError) {
    showErrorAlert(apiError: error)
  }
}

extension FriendsListViewController: UITableViewDelegate {}

extension FriendsListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return friends.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendTableViewCell.self)) as? FriendTableViewCell else {
      fatalError("Unable to dequeue FriendTableViewCell")
    }
    cell.setUp(friendName: friends[indexPath.row].username)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.didTapFriend(friendId: friends[indexPath.row].friendId)
  }
}
