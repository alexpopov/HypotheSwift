//
//  Minimizer.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-08.
//

import Foundation

struct Minimizer<Arguments> where Arguments: ArgumentEnumerable {
  typealias Constraint = ArgumentConstraint<Arguments>

  let arguments: Arguments
  let constraints: [Constraint]

  init(arguments: Arguments, constraints: [ArgumentConstraint<Arguments>]) {
    self.arguments = arguments
    self.constraints = constraints
  }
  
  fileprivate func minimize<T>(_ argument: T,
                   through lens: SimpleLens<Arguments, T>) -> [Arguments]
    where T: ArgumentType {
      let strategies = argument.minimizationStrategies()
      let possibleArguments = strategies
        .map { $0(argument) }
        .map { lens.set(arguments, $0) }
        .filter { ConstraintUtils.does($0, pass: constraints) }
        // we only leave in those that are equal in size or smaller
        .filter { lens.get($0).minimizationSize <= argument.minimizationSize }
      return possibleArguments
  }

  fileprivate func minimize(argument: Arguments) -> [Arguments] {
    let strategies = argument.minimizationStrategies()
    let possibleArguments = strategies
      .map { $0(argument) }
      .filter { ConstraintUtils.does($0, pass: constraints) }
    // try to only leave those that are smaller
    let evenSmallerArguments = possibleArguments
      .filter { $0.minimizationSize < argument.minimizationSize }
    if evenSmallerArguments.isEmpty == false {
      return evenSmallerArguments
    } else {
      return possibleArguments
    }
  }

  func minimize() -> [Arguments] {
    return minimize(argument: arguments)
  }
  
}
