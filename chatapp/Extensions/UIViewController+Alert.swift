//
//  UIViewController+Alert.swift
//  chatapp
//
//  Created by Kevin Dittmar on 1/4/22.
//

import Foundation
import UIKit

extension UIViewController {
  func showErrorAlert(apiError: ApiError) {
    DispatchQueue.main.async { [weak self] in
      let alert = UIAlertController(title: "Error", message: apiError.message, preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(alertAction)
      
      self?.present(alert, animated: true, completion: nil)
    }
  }
}
