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
      let isRejected = constraints.map { $0.rejector(argument) }
        .reduce(false) { $0 || $1 }
      return !isRejected
  }
}

public struct ArgumentConstraint<Arguments> where Arguments: ArgumentEnumerable {
  typealias ConstraintTarget = Arguments
  typealias Rejector = (Arguments) -> Bool
  typealias GeneratorConstraint = (Gen<Arguments>) -> Gen<Arguments>

  let rejector: Rejector
  let generatorConstraint: GeneratorConstraint

  private(set) var label: String? = nil

  internal init(rejector: @escaping Rejector, generatorConstraint: @escaping GeneratorConstraint) {
    self.rejector = rejector
    self.generatorConstraint = generatorConstraint
  }
  
  public func labeled(_ string: String) -> ArgumentConstraint<Arguments> {
    return ArgumentConstraint.labelLens.set(self, string)
  }
  
  private static var labelLens: SimpleLens<ArgumentConstraint<Arguments>, String?> {
    return SimpleLens(keyPath: \ArgumentConstraint.label)
  }
}
