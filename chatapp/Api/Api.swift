//
//  Api.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/2/22.
//

import Foundation

protocol Endpoint {
  var httpBody: Data? { get throws }
  var httpMethod: HttpMethod { get }
  var path: String { get }
  
  func invoke()
}

extension Endpoint {
  var serverBase: String { "localhost:8000" }
  
  func invoke() {
    guard let url = URL(string: path) else { fatalError("Path is not a valid URL") }
    
    var request = URLRequest(url: url)
    request.httpBody = httpBody
    request.httpMethod = httpMethod.rawValue
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
      // TODO (dittmar)
    }
    task.resume()
  }
}

enum HttpMethod: String {
  case DELETE
  case GET
  case POST
  case PUT
}

enum UserEndpoint: Endpoint {
  case login(username: String)
  
  var httpBody: Data? {
    get throws {
      switch self {
      case let .login(username):
        return try JSONEncoder().encode(["username": username])
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
      return "/users/login"
    }
  }
}
