//
//  Boolean+Extensions.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation

extension Bool {
  static func areAll(_ bool: Bool, in args: Bool...) -> Bool {
    for arg in args {
      guard arg == bool else { return false }
    }
    return true
  }

  static func isAny(_ bool: Bool, in args: Bool...) -> Bool {
    for arg in args {
      if arg == bool { return true }
    }
    return false
  }
  
  static func negate<T>(_ bool: @escaping (T) -> Bool) -> (T) -> Bool {
    return { !bool($0) }
  }

}
