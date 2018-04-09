//
//  Minimizer.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-08.
//

import Foundation
import Prelude
import RandomKit

struct Minimizer<Arguments> where Arguments: ArgumentEnumerable {
  typealias Constraint = ArgumentConstraint<Arguments>

  let test: (Arguments) -> Bool
  let maxDepth: Int
  let arguments: Arguments
  let constraints: [Constraint]

  init(test: @escaping (Arguments) -> Bool,
       arguments: Arguments,
       constraints: [ArgumentConstraint<Arguments>],
       maxDepth: Int) {
    self.test = test
    self.arguments = arguments
    self.constraints = constraints
    self.maxDepth = maxDepth
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

  func minimize() -> Arguments {
    let allMinimizedArgs = minimizeRecursively(depth: 0, arguments: arguments)
    let smallestMinimizedArgs = allMinimizedArgs
      .keepOnlySmallest()
    return smallestMinimizedArgs
      .random(using: &Xoroshiro.default) ?? arguments
  }

  func minimizeRecursively(depth: Int, arguments: Arguments) -> [Arguments] {
    guard depth < maxDepth else {
      return [arguments]
    }
    let minimizedArguments = minimize(argument: arguments)
    let stillFailingArguments = minimizedArguments
      .filter( { test($0) == false })
      .filter { $0.minimizationSize < arguments.minimizationSize }
      .lazy
    let smallestFailingArguments = stillFailingArguments
      .keepOnlySmallest()
    // if we have no smaller arguments recurse, increasing recursion depth
    //
    // if we only have one smaller failing argument, just return that one, since it might even be the smallest
    //
    // but if we DO have smaller arguments, just keep rolling with those without increasing depth
    // since we know we're moving in the right direction
    if smallestFailingArguments.isEmpty {
      if stillFailingArguments.isEmpty {
        return minimizeRecursively(depth: depth + 1, arguments: arguments)
      } else {
        return stillFailingArguments.flatMap { minimizeRecursively(depth: depth + 1, arguments: $0) }
      }
    } else if smallestFailingArguments.count == 1 {
      return minimizeRecursively(depth: depth + 1, arguments: smallestFailingArguments[0])
    } else {
      // don't recurse out of control; there's no point if we have smaller arguments
      // randomly choose some reasonable `n` out of the smallest test cases
      return smallestFailingArguments
        .randomSlice(count: depth + 1, using: &Xoroshiro.default)
        .flatMap { minimizeRecursively(depth: depth, arguments: $0) }
    }
  }
  
}

extension Collection where Element: ArgumentType {
  func keepOnlySmallest() -> [Element] {
    guard self.isEmpty == false else { return [] }
    let smallestSize = self
      .sorted(by: { $0.minimizationSize < $1.minimizationSize })
      .first!.minimizationSize
    return self.filter { $0.minimizationSize <= smallestSize }
  }
}
