//
//  Minimizer.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-08.
//

import Foundation

protocol MinimizableArgumentType: ArgumentType {
  var minimizationSize: Int { get }
  func minimizationStrategies() -> [(Self) -> (Self)]
}

struct Minimizer<Arguments> where Arguments: ArgumentEnumerable {
  typealias Constraint = ArgumentConstraint<Arguments>
  
  let arguments: Arguments
  let constraints: [Constraint]
  
  init(arguments: Arguments, constraints: [Constraint]) {
    self.arguments = arguments
    self.constraints = constraints
  }
  
  fileprivate func minimize<T>(_ argument: T,
                   through lens: SimpleLens<Arguments, T>) -> [Arguments]
    where T: MinimizableArgumentType {
      let strategies = argument.minimizationStrategies()
      let possibleArguments = strategies
        .map { $0(argument) }
        .map { lens.set(arguments, $0) }
        .filter { ConstraintUtils.does($0, pass: constraints) }
        // we only leave in those that are equal in size or smaller
        .filter { lens.get($0).minimizationSize <= argument.minimizationSize }
      return possibleArguments
  }
  
  func minimizeFirst() -> [Arguments] {
    return []
  }
  
  func minimizeSecond() -> [Arguments] {
    return []
  }
  
  func minimizeThird() -> [Arguments] {
    return []
  }
  
  func minimizeFourth() -> [Arguments] {
    return []
  }
  
  func minimize() -> [Arguments] {
    return minimizeFirst() + minimizeSecond() + minimizeThird() + minimizeFourth()
  }
  
}

extension Minimizer where Arguments: SupportsOneArgument,
Arguments.FirstArgument: MinimizableArgumentType {
  func minimizeFirst() -> [Arguments] {
    return minimize(arguments.firstArgument, through: Test.Arguments.firstArgumentLens)
  }
}

extension Minimizer where Arguments: SupportsTwoArguments,
Arguments.SecondArgument: MinimizableArgumentType {
  func minimizeSecond() -> [Arguments] {
    return minimize(arguments.secondArgument, through: Test.Arguments.secondArgumentLens)
  }
}

extension Minimizer where Arguments: SupportsThreeArguments,
Arguments.ThirdArgument: MinimizableArgumentType {
  func minimizeThird() -> [Arguments] {
    return minimize(arguments.thirdArgument, through: Test.Arguments.thirdArgumentLens)
  }
}

extension Minimizer where Arguments: SupportsFourArguments,
Arguments.FourthArgument: MinimizableArgumentType {
  func minimizeFourth() -> [Arguments] {
    return minimize(arguments.fourthArgument, through: Test.Arguments.fourthArgumentLens)
  }
}
