//
//  ChatRoomViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import UIKit

final class ChatRoomViewController: UIViewController {
  private let messageTextFieldBottomPadding: CGFloat = 10.0
  private lazy var viewModel = ChatRoomViewModel(delegate: self)
  
  @IBOutlet private weak var currentUserLabel: UILabel!
  @IBOutlet private weak var messageTableView: UITableView! {
    didSet {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardIfNecessary))
      messageTableView.addGestureRecognizer(tapGestureRecognizer)
    }
  }
  
  @IBOutlet private weak var messageTextField: UITextField!
  
  @IBOutlet private weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerNotifications()
    setUpMessageTable()
    do {
      try viewModel.loadGlobalMessages()
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    updateCurrentUserLabel()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showFriendsList",
       let friendsListViewController = segue.destination as? FriendsListViewController {
      friendsListViewController.delegate = self
    }
  }
  
  @IBAction private func didTapMainRoom(_ sender: Any) {
    do {
      try viewModel.loadGlobalMessages()
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  
  @IBAction private func didTapFriends(_ sender: Any) {
    // Redirect to login screen if you tap friends without being logged in
    if LocalStorage.user == nil {
      didTapLogin(self)
    } else {
      performSegue(withIdentifier: "showFriendsList", sender: nil)
    }
  }
  
  
  @IBAction private func didTapLogin(_ sender: Any) {
    performSegue(withIdentifier: "showLogin", sender: nil)
  }
  
  @IBAction func sendMessage(_ sender: Any) {
    guard let message = messageTextField.text else { return }
    
    // If we don't have a user, divert them to the login
    if LocalStorage.user == nil {
      didTapLogin(self)
      return
    }
    
    do {
      try viewModel.sendMessage(receiverId: viewModel.selectedFriendId, message: message)
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(didUpdateUser), name: Notification.didUpdateUser.name, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didShowKeyboard(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didHideKeyboard), name: UIApplication.keyboardWillHideNotification, object: nil)
  }
  
  @objc private func didHideKeyboard() {
    messageTextFieldBottomConstraint.constant = messageTextFieldBottomPadding
  }
  
  @objc private func didShowKeyboard(_ notification: NSNotification) {
    guard let userInfo = notification.userInfo,
          let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height else { return }
    
    messageTextFieldBottomConstraint.constant = keyboardHeight + messageTextFieldBottomPadding
    scrollToBottom()
  }
  
  @objc private func didUpdateUser() {
    do {
      try viewModel.reset()
    } catch {
      // TODO (dittmar): handle error
    }
    updateCurrentUserLabel()
  }
  
  @objc private func dismissKeyboardIfNecessary() {
    view.endEditing(true)
  }
  
  private func scrollToBottom() {
    messageTableView.setContentOffset(CGPoint(x: 0, y: self.messageTableView.contentSize.height), animated: true)
  }
  
  private func setUpMessageTable() {
    messageTableView.register(
      UINib(nibName: String(describing: MessageTableViewCell.self), bundle: .main),
      forCellReuseIdentifier: String(describing: MessageTableViewCell.self))
    messageTableView.delegate = self
    messageTableView.dataSource = self
  }
  
  private func updateCurrentUserLabel() {
    DispatchQueue.main.async { [weak self] in
      self?.currentUserLabel.text = self?.viewModel.currentUsername
    }
  }
}

extension ChatRoomViewController: ChatRoomViewModelDelegate {
  func didSendMessage() {
    DispatchQueue.main.async { [weak self] in
      self?.messageTextField.text = nil
      self?.scrollToBottom()
    }
    
    do {
      try viewModel.refreshMessages()
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  func shouldShowLogin() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      self.didTapLogin(self)
    }
  }
  
  func didLoadMessages() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.messageTableView.reloadData()
      self.scrollToBottom()
    }
  }
  
  func shouldShowError(_ error: ApiError) {
    showErrorAlert(apiError: error)
  }
}

extension ChatRoomViewController: FriendsListViewControllerDelegate {
  func didTapFriend(friendId: Int) {
    guard let senderId = LocalStorage.user?.id else { return }
    do {
      try viewModel.loadDirectMessages(senderId: senderId, receiverId: friendId)
    } catch {
      // TODO (dittmar): handle error
    }
  }
}

extension ChatRoomViewController: UITableViewDelegate {}

extension ChatRoomViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageTableViewCell.self)) as? MessageTableViewCell else {
      fatalError("Could not dequeue expected cell")
    }
    
    if indexPath.row > viewModel.messages.count {
      return cell
    }
    cell.setUp(message: viewModel.messages[indexPath.row])
    return cell
  }
}
