//
//  Arguments.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude

protocol ArgumentEnumerable: ArgumentType {
  associatedtype TupleRepresentation
  init(tuple: TupleRepresentation)

  var asTuple: TupleRepresentation { get }
}

protocol SupportsOneArgument: ArgumentEnumerable {
  associatedtype FirstArgument: ArgumentType
  var firstArgument: FirstArgument { get set }
}

protocol SupportsTwoArguments: SupportsOneArgument {
  associatedtype SecondArgument: ArgumentType
  var secondArgument: SecondArgument { get set }
}

protocol SupportsThreeArguments: SupportsTwoArguments {
  associatedtype ThirdArgument: ArgumentType
  var thirdArgument: ThirdArgument { get set }
}

protocol SupportsFourArguments: SupportsThreeArguments {
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

struct OneArgument<T>: SupportsOneArgument where T: ArgumentType {

  typealias FirstArgument = T
  typealias TupleRepresentation = (T)

  var firstArgument: T

  var asTuple: (T) { return firstArgument }

  init(tuple: TupleRepresentation) {
    self.firstArgument = tuple
  }

  static var gen: Gen<OneArgument<T>> {
    return T.gen.map(OneArgument<T>.init(tuple:))
  }

  static func == (lhs: OneArgument<T>, rhs: OneArgument<T>) -> Bool {
    return lhs.firstArgument == rhs.firstArgument
  }

}

struct TwoArguments<T, U>: SupportsTwoArguments where T: ArgumentType, U: ArgumentType {

  typealias FirstArgument = T
  typealias SecondArgument = U
  typealias TupleRepresentation = (T, U)

  var firstArgument: T
  var secondArgument: U

  var asTuple: (T, U) { return (firstArgument, secondArgument) }

  init(tuple: TupleRepresentation) {
    self.firstArgument = tuple.0
    self.secondArgument = tuple.1
  }

  static var gen: Gen<TwoArguments<T, U>> {
    return T.gen.combine(U.gen).map(TwoArguments<T, U>.init(tuple:))
  }

  static func == (lhs: TwoArguments<T, U>, rhs: TwoArguments<T, U>) -> Bool {
    return lhs.asTuple == rhs.asTuple
  }

}

struct ThreeArguments<T, U, V>: SupportsThreeArguments
where T: ArgumentType, U: ArgumentType, V: ArgumentType {
  typealias FirstArgument = T
  typealias SecondArgument = U
  typealias ThirdArgument = V
  typealias TupleRepresentation = (T, U, V)

  var firstArgument: T
  var secondArgument: U
  var thirdArgument: V

  var asTuple: (T, U, V) { return (firstArgument, secondArgument, thirdArgument) }

  init(tuple: TupleRepresentation) {
    self.firstArgument = tuple.0
    self.secondArgument = tuple.1
    self.thirdArgument = tuple.2
  }

  static var gen: Gen<ThreeArguments<T, U, V>> {
    return T.gen
      .combine(U.gen)
      .combine(V.gen)
      .map(ThreeArguments<T, U, V>.init(tuple:))
  }
}

struct FourArguments<T, U, V, W>: SupportsFourArguments
where T: ArgumentType, U: ArgumentType, V: ArgumentType, W: ArgumentType {
  typealias FirstArgument = T
  typealias SecondArgument = U
  typealias ThirdArgument = V
  typealias FourthArgument = W

  var firstArgument: T
  var secondArgument: U
  var thirdArgument: V
  var fourthArgument: W

  var asTuple: (T, U, V, W) { return (firstArgument, secondArgument, thirdArgument, fourthArgument) }

  init(tuple: TupleRepresentation) {
    self.firstArgument = tuple.0
    self.secondArgument = tuple.1
    self.thirdArgument = tuple.2
    self.fourthArgument = tuple.3
  }

  static var gen: Gen<FourArguments<T, U, V, W>> {
    return T.gen
      .combine(U.gen)
      .combine(V.gen)
      .combine(W.gen)
      .map(FourArguments.init)
  }
}
