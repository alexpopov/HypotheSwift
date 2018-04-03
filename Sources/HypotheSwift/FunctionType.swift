//
//  FunctionType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation

public protocol FunctionType {
  associatedtype Signature: FunctionSignature
  var function: (Signature.Arguments) -> Signature.Return { get }
}

public protocol FunctionSignature {
  associatedtype Arguments: FunctionArguments
  associatedtype Return
}

public protocol FunctionArguments {
}

public struct NoArguments: FunctionArguments {
}

public struct OneArgument<T>: FunctionArguments where T: ArbitrarilyCreatable {
  var arg: T.Type { return T.self }
}

// currently unused
struct Return<T> {

}

public protocol ArbitrarilyCreatable {
  static var arbitrary: ArbitraryGenerator<Self> { get }
}

public struct ArbitraryGenerator<T> {
  typealias Argument = T

  private let generate: () -> T

  static func just<T>(returning value: T) -> ArbitraryGenerator<T> {
    return ArbitraryGenerator<T>(generate: { return value })
  }

  func next() -> T {
    return generate()
  }
}

public struct NullaryFunctionSignature<R>: FunctionSignature {
  public typealias Arguments = NoArguments
  public typealias Return = R
}

public struct UnaryFunctionSignature<T, R>: FunctionSignature where T: ArbitrarilyCreatable {
  public typealias Arguments = OneArgument<T>
  public typealias Return = R
}

public struct NullaryFunction<R>: FunctionType {
  public typealias Signature = NullaryFunctionSignature<R>
  public var function: (NoArguments) -> R

  init(_ function: @escaping () -> R) {
    self.function = { _ in return function() }
  }
}

public struct UnaryFunction<T, R>: FunctionType where T: ArbitrarilyCreatable {
  public typealias Signature = UnaryFunctionSignature<T, R>
  public var function: (OneArgument<T>) -> R

  init(_ function: @escaping (T) -> R) {
    self.function = { (arg: OneArgument<T>) in return function(arg.arg.arbitrary.next()) }
  }
}

extension Int: ArbitrarilyCreatable {
  public static var arbitrary: ArbitraryGenerator<Int> {
    return ArbitraryGenerator<Int>.just(returning: 1)
  }
}
