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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerNotifications()
    setUpMessageTable()
    try! viewModel.loadGlobalMessages()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    updateCurrentUserLabel()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  @IBAction private func didTapMainRoom(_ sender: Any) {
    try! viewModel.loadGlobalMessages()
  }
  
  
  @IBAction private func didTapFriends(_ sender: Any) {
  
  }
  
  
  @IBAction private func didTapLogin(_ sender: Any) {
    performSegue(withIdentifier: "showLogin", sender: nil)
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
  func didLoadMessages() {
    DispatchQueue.main.async { [weak self] in
      self?.messageTableView.reloadData()
    }
  }
  
  func shouldShowError(_ error: ApiError) {
    showErrorAlert(apiError: error)
  }
}

extension ChatRoomViewController: UITableViewDelegate {
  
}

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
