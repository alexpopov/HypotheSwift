//
//  Function.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude
import Darwin
import RandomKit

protocol Function {
  associatedtype Arguments: ArgumentEnumerable
  associatedtype Return
  var function: (Arguments.TupleRepresentation) -> Return { get }
}

extension Function {
  func call(with arguments: Arguments) -> Return {
    return function(arguments.asTuple)
  }
}

struct UnaryFunction<T, R>: Function where T: ArgumentType {

  typealias Arguments = OneArgument<T>
  typealias Return = R
  typealias FirstArgument = T

  let function: ((T)) -> R

  init(_ function: @escaping (T) -> R) {
    self.function = function
  }
}

struct BinaryFunction<T, U, R>: Function where T: ArgumentType, U: ArgumentType {
  typealias Arguments = TwoArguments<T, U>
  typealias Return = R
  typealias FirstArgument = T
  typealias SecondArgument = U

  var function: ((T, U)) -> R

  init(_ function: @escaping (T, U) -> R) {
    self.function = function
  }
}
