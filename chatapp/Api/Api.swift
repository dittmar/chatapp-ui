//
//  Api.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import Foundation

protocol Endpoint {
  associatedtype Response: Decodable
  
  var httpBody: Data? { get throws }
  var httpMethod: HttpMethod { get }
  var path: String { get }
  
  func invoke(onSuccess: ((Response) -> Void)?,
              onError: ((ApiError) -> Void)?) throws
}

extension Endpoint {
  var serverBase: String { "http://127.0.0.1:8000" }
  
  func invoke(onSuccess: ((Response) -> Void)? = nil, onError: ((ApiError) -> Void)? = nil) throws {
    guard let url = URL(string: path) else { fatalError("Path is not a valid URL") }
    
    var request = URLRequest(url: url)
    request.httpBody = try httpBody
    request.httpMethod = httpMethod.rawValue
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
      if let error = error {
        onError?(ApiError(code: (error as NSError).code, message: "something went wrong"))
        return
      }
      
      guard let data = data else {
        fatalError("No data when data expected")
      }

      do {
        // If it's a no-content response, we just have to call the completion handler
        if self.self is NoContentEndpoint, data.count == 0 {
          onSuccess?(NoContentEndpoint.Response() as! Self.Response)
          return
        }
        let responseData = try JSONDecoder().decode(Response.self, from: data)
        onSuccess?(responseData)
      } catch {
        onError?(ApiError(code: (error as NSError).code, message: String(data: data, encoding: .utf8) ?? "No data"))
      }
    }
    task.resume()
  }
}

struct ApiError {
  let code: Int
  let message: String
}

enum HttpMethod: String {
  case DELETE
  case GET
  case POST
  case PUT
}

enum FriendEndpoint: Endpoint {
  typealias Response = Friend
  
  case addFriend(userId: Int, friendName: String)
  
  var httpBody: Data? {
    get throws {
      switch self {
      case let .addFriend(userId, friendName):
        return try JSONEncoder().encode(AddFriendParam(userId: userId, friendName: friendName))
      }
    }
  }
  
  var httpMethod: HttpMethod {
    switch self {
    case .addFriend:
      return .POST
    }
  }
  
  var path: String {
    switch self {
    case .addFriend:
      return "\(serverBase)/friends/add"
    }
  }
}

enum FriendsEndpoint: Endpoint {
  typealias Response = [Friend]
  
  case listFriends(userId: Int)
  
  var httpBody: Data? { nil }
  
  var httpMethod: HttpMethod { .GET }
  
  var path: String {
    switch self {
    case let .listFriends(userId):
      return "\(serverBase)/friends/list/\(userId)"
    }
  }
}

enum MessageEndpoint: Endpoint {
  typealias Response = [Message]
  
  case listMessagesGlobal
  case listMessagesDirect(senderId: Int, receiverId: Int)
  
  var httpBody: Data? {
    get throws {
      switch self {
      case .listMessagesGlobal:
        return nil
      case let .listMessagesDirect(senderId, receiverId):
        return try JSONEncoder().encode(["senderId": senderId, "receiverId": receiverId])
      }
    }
  }
  
  var httpMethod: HttpMethod {
    switch self {
    case .listMessagesGlobal, .listMessagesDirect:
      return .POST
    }
  }
  
  var path: String {
    switch self {
    case .listMessagesGlobal, .listMessagesDirect:
      return "\(serverBase)/messages/list"
    }
  }
}

enum NoContentEndpoint: Endpoint {
  struct Response: Decodable {}
  
  case deleteFriend(userId: Int, friendId: Int)
  case createUser(username: String, password: String)
  case sendMessage(senderId: Int, receiverId: Int? = nil, message: String)
  
  var httpBody: Data? {
    get throws {
      switch self {
      case let .deleteFriend(userId, friendId):
        return try JSONEncoder().encode(["userId": userId, "friendId": friendId])
      case let .createUser(username, password):
        return try JSONEncoder().encode(["username": username, "password": password])
      case let .sendMessage(senderId, receiverId, message):
        let messageParam = MessageParam(message: message, receiverId: receiverId, senderId: senderId)
        return try JSONEncoder().encode(messageParam)
      }
    }
  }
  
  var httpMethod: HttpMethod {
    switch self {
    case .createUser, .sendMessage:
      return .POST
    case .deleteFriend:
      return .DELETE
    }
  }
  
  var path: String {
    switch self {
    case .createUser:
      return "\(serverBase)/users/create"
    case .deleteFriend:
      return "\(serverBase)/friends/delete"
    case .sendMessage:
      return "\(serverBase)/messages/send"
    }
  }
}

enum UserEndpoint: Endpoint {
  typealias Response = User
  
  case login(username: String, password: String)
  
  var httpBody: Data? {
    get throws {
      switch self {
      case let .login(username, password):
        return try JSONEncoder().encode(["username": username, "password": password])
      }
    }
  }
  
  var httpMethod: HttpMethod {
    switch self {
    case .login:
      return .POST
    }
  }
  
  var path: String {
    switch self {
    case .login:
      return "\(serverBase)/users/login"
    }
  }
}
