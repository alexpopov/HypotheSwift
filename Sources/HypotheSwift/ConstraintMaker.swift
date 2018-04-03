//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude

public struct Maker {
  static func make<T, R>(for function: @escaping (T) -> R)
    -> ConstraintMaker<UnaryFunction<T, R>>
    where T: ArbitrarilyCreatable {
      let unaryFunction = UnaryFunction(function)
      return ConstraintMaker<UnaryFunction<T, R>>(function: unaryFunction)
  }
}

public struct ConstraintMaker<Fun: FunctionType> {

  let function: Fun

  init(function: Fun) {
    self.function = function
  }

  func constraintArgument(

}

