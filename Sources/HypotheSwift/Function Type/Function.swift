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

/// Metatype representing a Function with Arguments and a Return.
///
/// Functionally, this is conformed to, in order to wrap functions
/// provide the ability to deal with them as a first-class type, the way it's
/// done in Scala. Swift simply doesn't allow us the freedoms we need.
///
/// There are down-sides to this architecture; representing functions and
/// arguments as protocols and types means we strictly limit ourselves to what
/// we can do. In the long run, I'm happy I did this instead of having
/// absurdly long function heads with a dozen constraints.
public protocol Function {
  /// Argument metatype representing the function's inputs
  associatedtype Arguments: ArgumentEnumerable
  /// Return metatype representing the function's output
  associatedtype Return
  /// Underlying function
  var function: (Arguments.TupleRepresentation) -> Return { get }
}

extension Function {
  /// Convenience method for calling the underlying function
  func call(with arguments: Arguments) -> Return {
    return function(arguments.asTuple)
  }
}

/// Function type with a single argument
public struct UnaryFunction<T, R>: Function where T: ArgumentType {

  public typealias Arguments = OneArgument<T>
  public typealias Return = R

  public let function: ((T)) -> R

  init(_ function: @escaping (T) -> R) {
    self.function = function
  }
}

/// Function type with two arguments
public struct BinaryFunction<T, U, R>: Function where T: ArgumentType, U: ArgumentType {
  public typealias Arguments = TwoArguments<T, U>
  public typealias Return = R

  public var function: ((T, U)) -> R

  init(_ function: @escaping (T, U) -> R) {
    self.function = function
  }
}

/// Function type with three arguments
public struct TernaryFunction<T, U, V, R>: Function
  where T: ArgumentType, U: ArgumentType, V: ArgumentType {
  public typealias Arguments = ThreeArguments<T, U, V>
  public typealias Return = R

  public var function: ((T, U, V)) -> R

  init(_ function: @escaping ((T, U, V)) -> R) {
    self.function = function
  }
}

/// Function type with four arguments
public struct QuaternaryFunction<T, U, V, W, R>: Function
where T: ArgumentType, U: ArgumentType, V: ArgumentType, W: ArgumentType {
  public typealias Arguments = FourArguments<T, U, V, W>
  public typealias Return = R

  public var function: ((T, U, V, W)) -> R

  public init(_ function: @escaping (Arguments.TupleRepresentation) -> R) {
    self.function = function
  }
}
