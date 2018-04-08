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

public protocol Function {
  associatedtype Arguments: ArgumentEnumerable
  associatedtype Return
  var function: (Arguments.TupleRepresentation) -> Return { get }
}

extension Function {
  func call(with arguments: Arguments) -> Return {
    return function(arguments.asTuple)
  }
}

public struct UnaryFunction<T, R>: Function where T: ArgumentType {

  public typealias Arguments = OneArgument<T>
  public typealias Return = R

  public let function: ((T)) -> R

  init(_ function: @escaping (T) -> R) {
    self.function = function
  }
}

public struct BinaryFunction<T, U, R>: Function where T: ArgumentType, U: ArgumentType {
  public typealias Arguments = TwoArguments<T, U>
  public typealias Return = R

  public var function: ((T, U)) -> R

  init(_ function: @escaping (T, U) -> R) {
    self.function = function
  }
}

public struct TernaryFunction<T, U, V, R>: Function
  where T: ArgumentType, U: ArgumentType, V: ArgumentType {
  public typealias Arguments = ThreeArguments<T, U, V>
  public typealias Return = R

  public var function: ((T, U, V)) -> R

  init(_ function: @escaping ((T, U, V)) -> R) {
    self.function = function
  }
}

public struct QuaternaryFunction<T, U, V, W, R>: Function
where T: ArgumentType, U: ArgumentType, V: ArgumentType, W: ArgumentType {
  public typealias Arguments = FourArguments<T, U, V, W>
  public typealias Return = R

  public var function: ((T, U, V, W)) -> R

  public init(_ function: @escaping (Arguments.TupleRepresentation) -> R) {
    self.function = function
  }
}
