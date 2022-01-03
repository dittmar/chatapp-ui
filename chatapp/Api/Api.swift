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

enum UserEndpoint: Endpoint {
  typealias Response = User
  
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
      return "\(serverBase)/users/login"
    }
  }
}

/*
enum MessageEndpoint: Endpoint {
  struct Response: Decodable {
    let message: String
    let receiver: String?
    let sender: String
  }
}
*/

enum NoContentEndpoint: Endpoint {
  struct Response: Decodable {}
  
  case createUser(username: String)
  
  var httpBody: Data? {
    get throws {
      switch self {
      case let .createUser(username):
        return try JSONEncoder().encode(["username": username])
      }
    }
  }
  
  var httpMethod: HttpMethod {
    switch self {
    case .createUser:
      return .POST
    }
  }
  
  var path: String {
    switch self {
    case .createUser:
      return "\(serverBase)/users/create"
    }
  }
}

