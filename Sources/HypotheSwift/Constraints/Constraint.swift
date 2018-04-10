//
//  Constraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation
import Prelude
import RandomKit

internal enum ConstraintUtils {
  static func does<Arguments>(_ argument: Arguments,
                              pass constraints: [ArgumentConstraint<Arguments>]) -> Bool
    where Arguments: ArgumentEnumerable {
      let isRejected = constraints.flatMap {
        return $0.rejector(argument) || $0.generatorConstraintType.rejects(arguments: argument)
      }
        .reduce(false) { $0 || $1 }
      return !isRejected
  }
}

enum GeneratorConstraintType<Arguments> where Arguments: ArgumentEnumerable {
  case none
  case mustBe((Arguments) -> Bool)
  case inRange((Arguments) -> Bool)
  
  func rejects(arguments: Arguments) -> Bool {
    switch self {
    case .none:
      return false
    case .mustBe(let predicate):
      return predicate(arguments) == false
    case .inRange(let predicate):
      return predicate(arguments) == false
    }
  }
}

public struct ArgumentConstraint<Arguments> where Arguments: ArgumentEnumerable {
  typealias ConstraintTarget = Arguments
  typealias Rejector = (Arguments) -> Bool
  typealias GeneratorConstraint = (Gen<Arguments>) -> Gen<Arguments>

  let rejector: Rejector
  let generatorConstraint: GeneratorConstraint
  let generatorConstraintType: GeneratorConstraintType<Arguments>

  private(set) var label: String? = nil

  internal init(rejector: @escaping Rejector,
                generatorConstraint: @escaping GeneratorConstraint = id,
                generatorType: GeneratorConstraintType<Arguments> = .none) {
    self.rejector = rejector
    self.generatorConstraint = generatorConstraint
    self.generatorConstraintType = generatorType
  }
  
  public func labeled(_ string: String) -> ArgumentConstraint<Arguments> {
    return ArgumentConstraint.labelLens.set(self, string)
  }
  
  private static var labelLens: SimpleLens<ArgumentConstraint<Arguments>, String?> {
    return SimpleLens(keyPath: \ArgumentConstraint.label)
  }
  
}
