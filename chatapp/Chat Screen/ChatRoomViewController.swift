//
//  ChatRoomViewController.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import UIKit

final class ChatRoomViewController: UIViewController {
  private lazy var viewModel = ChatRoomViewModel(delegate: self)
  
  @IBOutlet private weak var currentUserLabel: UILabel!
  @IBOutlet private weak var messageTableView: UITableView!
  @IBOutlet private weak var messageTextField: UITextField!
  
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
    
  }
  
  @IBAction private func didTapMainRoom(_ sender: Any) {
    do {
      try viewModel.loadGlobalMessages()
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  
  @IBAction private func didTapFriends(_ sender: Any) {
  
  }
  
  
  @IBAction private func didTapLogin(_ sender: Any) {
    performSegue(withIdentifier: "showLogin", sender: nil)
  }
  
  @IBAction func sendMessage(_ sender: Any) {
    guard let message = messageTextField.text else { return }
    
    do {
      try viewModel.sendMessage(message: message)
    } catch {
      // TODO (dittmar): handle error
    }
  }
  
  private func registerNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentUserLabel), name: Notification.didUpdateUser.name, object: nil)
  }
  
  private func setUpMessageTable() {
    messageTableView.register(
      UINib(nibName: String(describing: MessageTableViewCell.self), bundle: .main),
      forCellReuseIdentifier: String(describing: MessageTableViewCell.self))
    messageTableView.delegate = self
    messageTableView.dataSource = self
  }
  
  @objc private func updateCurrentUserLabel() {
    DispatchQueue.main.async { [weak self] in
      self?.currentUserLabel.text = self?.viewModel.currentUsername
    }
  }
}

extension ChatRoomViewController: ChatRoomViewModelDelegate {
  func didSendMessage() {
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
      self.messageTableView.setContentOffset(CGPoint(x: 0, y: self.messageTableView.contentSize.height), animated: true)
    }
  }
  
  func shouldShowError(_ error: ApiError) {
    showErrorAlert(apiError: error)
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
    cell.setUp(message: viewModel.messages[indexPath.row])
    return cell
  }
}
