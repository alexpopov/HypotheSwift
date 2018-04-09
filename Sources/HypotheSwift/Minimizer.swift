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

  func minimizeFirst<T>() -> [Arguments] where Arguments: SupportsOneArgument,
    T == Arguments.FirstArgument, T: MinimizableArgumentType {
    return minimize(arguments.firstArgument, through: Arguments.firstArgumentLens)
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
  static func minimizer(arguments: Arguments, constraints: [ArgumentConstraint<Arguments>]) -> Minimizer<Arguments> {
    return Minimizer(arguments: arguments, constraints: constraints)
  }

  func minimizeFirst() -> [Arguments] {
    return minimize(arguments.firstArgument, through: Arguments.firstArgumentLens)
  }
}

extension Minimizer where Arguments: SupportsTwoArguments,
Arguments.SecondArgument: MinimizableArgumentType {
  func minimizeSecond() -> [Arguments] {
    return minimize(arguments.secondArgument, through: Arguments.secondArgumentLens)
  }
}

extension Minimizer where Arguments: SupportsThreeArguments,
Arguments.ThirdArgument: MinimizableArgumentType {
  func minimizeThird() -> [Arguments] {
    return minimize(arguments.thirdArgument, through: Arguments.thirdArgumentLens)
  }
}

extension Minimizer where Arguments: SupportsFourArguments,
Arguments.FourthArgument: MinimizableArgumentType {
  func minimizeFourth() -> [Arguments] {
    return minimize(arguments.fourthArgument, through: Arguments.fourthArgumentLens)
  }
}
