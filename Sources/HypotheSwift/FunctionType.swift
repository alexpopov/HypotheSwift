//
//  FunctionType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation

protocol FunctionType {
  associatedtype Signature: FunctionSignature
  var function: (Signature.Arguments) -> Signature.Return { get }
}

protocol FunctionSignature {
  associatedtype Arguments: FunctionArguments
  associatedtype Return
}

protocol FunctionArguments {
  associatedtype ArgumentPosition

  static func constraint<Fun: FunctionType, T>(for position: ArgumentPosition)
    -> SimpleConstraint<Fun, T>
    where Fun.Signature.Arguments == Self
}

struct OneArgument<T>: FunctionArguments where T: ArbitrarilyGeneratable {
  typealias ArgumentPosition = Position
  var arg: T.Type { return T.self }

  enum Position {
    case first
  }

  static func constraint<Fun, T>(for position: OneArgument<T>.Position, in parent: ConstraintMaker<Fun>)
    -> SimpleConstraint<Fun, T>
    where OneArgument<T> == Fun.Signature.Arguments, Fun: FunctionType {
    return SimpleConstraint<Fun, T>(parent: parent)
  }
}

// currently unused
struct Return<T> {

}

protocol ArbitrarilyGeneratable {
  static var arbitrary: ArbitraryGenerator<Self> { get }
}

struct ArbitraryGenerator<T> {
  typealias Argument = T

  private let generate: () -> T

  static func just<T>(returning value: T) -> ArbitraryGenerator<T> {
    return ArbitraryGenerator<T>(generate: { return value })
  }

  func next() -> T {
    return generate()
  }
}

struct UnaryFunctionSignature<T, R>: FunctionSignature where T: ArbitrarilyGeneratable {
  typealias Arguments = OneArgument<T>
  typealias Return = R
}

struct UnaryFunction<T, R>: FunctionType where T: ArbitrarilyGeneratable {
  typealias Signature = UnaryFunctionSignature<T, R>
  var function: (OneArgument<T>) -> R

  init(_ function: @escaping (T) -> R) {
    self.function = { (arg: OneArgument<T>) in return function(arg.arg.arbitrary.next()) }
  }
}

extension Int: ArbitrarilyGeneratable {
  static var arbitrary: ArbitraryGenerator<Int> {
    return ArbitraryGenerator<Int>.just(returning: 1)
  }
}
