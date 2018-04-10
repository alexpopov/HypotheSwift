//
//  Minimizer.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-08.
//

import Foundation
import Prelude
import RandomKit

internal struct Minimizer<Arguments> where Arguments: ArgumentEnumerable {
  
  typealias Constraint = ArgumentConstraint<Arguments>

  private let test: (Arguments) -> Bool
  private let maxDepth: Int
  private let arguments: Arguments
  private let constraints: [Constraint]
  private let logLevel: LoggingLevel

  internal init(test: @escaping (Arguments) -> Bool,
                arguments: Arguments,
                constraints: [ArgumentConstraint<Arguments>],
                maxDepth: Int,
                logLevel: LoggingLevel = .none) {
    self.test = test
    self.arguments = arguments
    self.constraints = constraints
    self.maxDepth = maxDepth
    self.logLevel = logLevel
  }
  
  private func minimize(argument: Arguments) -> [Arguments] {
    let strategies = argument.minimizationStrategies()
    let possibleArguments = strategies
      .lazy
      .map { $0(argument) }
      .filter { ConstraintUtils.does($0, pass: self.constraints) }
      // removing duplicates
      .reduce([Arguments](), { $0.contains($1) ? $0 : $0.appending($1) })
      .filter { $0.minimizationSize < argument.minimizationSize }
      // try to only leave those that are smaller
    return possibleArguments
  }

  internal func minimize() -> Arguments {
    let allMinimizedArgs = minimizeRecursively(depth: 0, arguments: arguments)
    let smallestMinimizedArgs = allMinimizedArgs
      .keepOnlySmallest()
    return smallestMinimizedArgs
      .random(using: &Xoroshiro.default) ?? arguments
  }

  private func minimizeRecursively(depth: Int, arguments: Arguments) -> [Arguments] {
    log("Minimizing \(arguments.asTuple)", at: depth, as: .all)
    guard depth < maxDepth else {
      log("Reached max depth", at: depth, as: .all)
      return [arguments]
    }
    let minimizedArguments = minimize(argument: arguments)
    let stillFailingArguments = minimizedArguments
      .lazy
      .filter( { self.test($0) == false })
//      .filter { $0.minimizationSize < arguments.minimizationSize }
    log("Minimized arguments: \(minimizedArguments.map { $0.asTuple })",
      at: depth, as: .all)
    let smallestFailingArguments = stillFailingArguments
      .filter { $0.minimizationSize < arguments.minimizationSize }
      .keepOnlySmallest()
    log("Removed large arguments: \(smallestFailingArguments.map { $0.asTuple })",
      at: depth, as: .all)
    // if we have no smaller arguments recurse, increasing recursion depth
    //
    // if we only have one smaller failing argument, just return that one, since it might even be the smallest
    //
    // but if we DO have smaller arguments, just keep rolling with those without increasing depth
    // since we know we're moving in the right direction
    if smallestFailingArguments.isEmpty {
      if stillFailingArguments.isEmpty {
        log("We need to go deeper.", at: depth, as: .all)
        return minimizeRecursively(depth: depth + 1, arguments: arguments)
      } else {
        log("We will recurse deeper.", at: depth, as: .all)
        return stillFailingArguments.flatMap { minimizeRecursively(depth: depth + 1, arguments: $0) }
      }
    } else if smallestFailingArguments.count == 1 {
      log("We've got good arguments: \(smallestFailingArguments[0])", at: depth, as: .all)
      return minimizeRecursively(depth: depth + 1, arguments: smallestFailingArguments[0])
    } else {
      // don't recurse out of control; there's no point if we have smaller arguments
      // randomly choose some reasonable `n` out of the smallest test cases
      let bestRandomArguments = smallestFailingArguments
        .randomSlice(count: depth + 1, using: &Xoroshiro.default)
      log("Our best chance to recurse with: \(bestRandomArguments.map { $0.asTuple })", at: depth, as: .all)
      return bestRandomArguments.flatMap { minimizeRecursively(depth: depth, arguments: $0) }
    }
  }
  
  private func log(_ message: String, at depth: Int, as level: LoggingLevel) {
    guard level <= logLevel else { return }
    let indent = Array(repeating: "  ", count: depth).joined()
    print(indent + message)
  }
  
}

fileprivate extension Collection where Element: ArgumentType {
  func keepOnlySmallest() -> [Element] {
    guard self.isEmpty == false else { return [] }
    let smallestSize = self
      .sorted(by: { $0.minimizationSize < $1.minimizationSize })
      .first!.minimizationSize
    return self.filter { $0.minimizationSize <= smallestSize }
  }
}
