//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude

struct Maker {
  static func make<T, R>(for function: @escaping (T) -> R)
    -> ConstraintMaker<UnaryFunction<T, R>>
    where T: ArbitrarilyGeneratable {
      let unaryFunction = UnaryFunction(function)
      return ConstraintMaker<UnaryFunction<T, R>>(function: unaryFunction)
  }
}

struct ConstraintMaker<Fun: FunctionType> {

  let function: Fun

  init(function: Fun) {
    self.function = function
  }

  func constrain<T>(_ argument: Fun.Signature.Arguments.ArgumentPosition, as: T) -> SimpleConstraint<Fun, T> {
    return Fun.Signature.Arguments.constraint
  }

}

struct SimpleConstraint<Fun: FunctionType, T> {

  let parent: ConstraintMaker<Fun>

  init(parent: ConstraintMaker<Fun>) {
    self.parent = parent
  }
}
