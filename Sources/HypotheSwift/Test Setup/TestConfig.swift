//
//  TestConfig.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation

struct TestConfig {
  var numberOfTests: Int = 100
  var loggingLevel: LoggingLevel = .failures
  var maximumMinimizationLevel: Int = 3
  var continueAfterFailure: Bool = false
  var shouldMinimize: Bool = true
  
  init() { }
  
  static let numberOfTestsLens = SimpleLens(keyPath: \TestConfig.numberOfTests)
  static let loggingLevelLens = SimpleLens(keyPath: \TestConfig.loggingLevel)
  static let maximumMinimizationLevelLens = SimpleLens(keyPath: \TestConfig.maximumMinimizationLevel)
  static let continueAfterFailureLens = SimpleLens(keyPath: \TestConfig.continueAfterFailure)
  static let shouldMinimizeLens = SimpleLens(keyPath: \TestConfig.shouldMinimize)
}

public enum LoggingLevel: Int, Comparable {
  public static func < (lhs: LoggingLevel, rhs: LoggingLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
  
  case none
  case failures
  case successes
  case all
  
  var shouldLog: Bool {
    if case .none = self {
      return false
    } else {
      return true
    }
  }
}
