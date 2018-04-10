//
//  Arguments.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude

public protocol ArgumentEnumerable: ArgumentType {
  associatedtype TupleRepresentation

  init(tuple: TupleRepresentation)

  var asTuple: TupleRepresentation { get }
}

public protocol SupportsOneArgument: ArgumentEnumerable {
  associatedtype FirstArgument: ArgumentType
  var firstArgument: FirstArgument { get set }
}

public protocol SupportsTwoArguments: SupportsOneArgument {
  associatedtype SecondArgument: ArgumentType
  var secondArgument: SecondArgument { get set }
}

public protocol SupportsThreeArguments: SupportsTwoArguments {
  associatedtype ThirdArgument: ArgumentType
  var thirdArgument: ThirdArgument { get set }
}

public protocol SupportsFourArguments: SupportsThreeArguments {
  associatedtype FourthArgument: ArgumentType
  var fourthArgument: FourthArgument { get set }
}

extension SupportsOneArgument {
  static var firstArgumentLens: SimpleLens<Self, FirstArgument> { return SimpleLens(keyPath: \Self.firstArgument) }
}

extension SupportsTwoArguments {
  static var secondArgumentLens: SimpleLens<Self, SecondArgument> { return SimpleLens(keyPath: \Self.secondArgument) }
}

extension SupportsThreeArguments {
  static var thirdArgumentLens: SimpleLens<Self, ThirdArgument> { return SimpleLens(keyPath: \Self.thirdArgument) }
}

extension SupportsFourArguments {
  static var fourthArgumentLens: SimpleLens<Self, FourthArgument> { return SimpleLens(keyPath: \Self.fourthArgument) }
}

public struct OneArgument<T>: SupportsOneArgument where T: ArgumentType  {

  public typealias FirstArgument = T
  public typealias TupleRepresentation = (T)

  public var firstArgument: T

  public var asTuple: (T) { return firstArgument }

  public init(tuple: TupleRepresentation) {
    self.firstArgument = tuple
  }

  public static var gen: Gen<OneArgument<T>> {
    return T.gen.map(OneArgument<T>.init(tuple:))
  }

  public static func == (lhs: OneArgument<T>, rhs: OneArgument<T>) -> Bool {
    return lhs.firstArgument == rhs.firstArgument
  }

  public var minimizationSize: Int {
    return firstArgument.minimizationSize
  }

  public func minimizationStrategies() -> [(OneArgument<T>) -> OneArgument<T>] {
    return firstArgument.minimizationStrategies()
      .map { $0(firstArgument) }
      .map { OneArgument.firstArgumentLens.setting($0) }
  }

}

public struct TwoArguments<T, U>: SupportsTwoArguments where T: ArgumentType, U: ArgumentType {

  public typealias FirstArgument = T
  public typealias SecondArgument = U
  public typealias TupleRepresentation = (T, U)

  public var firstArgument: T
  public var secondArgument: U

  public var asTuple: (T, U) { return (firstArgument, secondArgument) }

  public init(tuple: TupleRepresentation) {
    self.firstArgument = tuple.0
    self.secondArgument = tuple.1
  }

  public static var gen: Gen<TwoArguments<T, U>> {
    return T.gen.combine(U.gen).map(TwoArguments<T, U>.init(tuple:))
  }

  public static func == (lhs: TwoArguments<T, U>, rhs: TwoArguments<T, U>) -> Bool {
    return lhs.asTuple == rhs.asTuple
  }

  public var minimizationSize: Int { return firstArgument.minimizationSize + secondArgument.minimizationSize }
  public func minimizationStrategies() -> [(TwoArguments<T, U>) -> TwoArguments<T, U>] {
    let firstArgumentMinimization = firstArgument.minimizationStrategies()
      .map { $0(firstArgument) }
      .map(TwoArguments.firstArgumentLens.setting)
    let secondArgumentMinimization = secondArgument.minimizationStrategies()
      .map { $0(secondArgument) }
      .map(TwoArguments.secondArgumentLens.setting)
    return firstArgumentMinimization + secondArgumentMinimization
  }

}

public struct ThreeArguments<T, U, V>: SupportsThreeArguments
where T: ArgumentType, U: ArgumentType, V: ArgumentType {
  public typealias FirstArgument = T
  public typealias SecondArgument = U
  public typealias ThirdArgument = V
  public typealias TupleRepresentation = (T, U, V)

  public var firstArgument: T
  public var secondArgument: U
  public var thirdArgument: V

  public var asTuple: (T, U, V) { return (firstArgument, secondArgument, thirdArgument) }

  public init(tuple: TupleRepresentation) {
    self.firstArgument = tuple.0
    self.secondArgument = tuple.1
    self.thirdArgument = tuple.2
  }

  public static var gen: Gen<ThreeArguments<T, U, V>> {
    return T.gen
      .combine(U.gen)
      .combine(V.gen)
      .map(ThreeArguments<T, U, V>.init(tuple:))
  }
  
  public static func ==<T, U, V>(lhs: ThreeArguments<T, U, V>, rhs: ThreeArguments<T, U, V>) -> Bool {
    return lhs.asTuple == rhs.asTuple
  }

  public var minimizationSize: Int { return 0 }
  public func minimizationStrategies() -> [(ThreeArguments<T, U, V>) -> ThreeArguments<T, U, V>] {
    return []
  }
}

public struct FourArguments<T, U, V, W>: SupportsFourArguments
where T: ArgumentType, U: ArgumentType, V: ArgumentType, W: ArgumentType {
  public typealias FirstArgument = T
  public typealias SecondArgument = U
  public typealias ThirdArgument = V
  public typealias FourthArgument = W
  public typealias TupleRepresentation = (T, U, V, W)

  public var firstArgument: T
  public var secondArgument: U
  public var thirdArgument: V
  public var fourthArgument: W

  public var asTuple: (T, U, V, W) { return (firstArgument, secondArgument, thirdArgument, fourthArgument) }

  public init(tuple: TupleRepresentation) {
    self.firstArgument = tuple.0
    self.secondArgument = tuple.1
    self.thirdArgument = tuple.2
    self.fourthArgument = tuple.3
  }

  public static var gen: Gen<FourArguments<T, U, V, W>> {
    return T.gen
      .combine(U.gen)
      .combine(V.gen)
      .combine(W.gen)
      .map(FourArguments.init)
  }
  
  public static func ==<T, U, V, W>(lhs: FourArguments<T, U, V, W>, rhs: FourArguments<T, U, V, W>) -> Bool {
    return lhs.asTuple == rhs.asTuple
  }

  public var minimizationSize: Int { return 0 }
  public func minimizationStrategies() -> [(FourArguments<T, U, V, W>) -> FourArguments<T, U, V, W>] {
    return []
  }
}
