//
//  FunctionType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude

protocol ArgumentType: Equatable {
  static var gen: Gen<Self> { get }
}

extension Int: ArgumentType {
  static var gen: Gen<Int> {
    let range = (Int.min...Int.max)
    return Gen<Int>.from(range)
  }
}

struct Gen<Value> {

  let generator: () -> Value

  static func just<T>(_ value: T) -> Gen<T> {
    return Gen<T>(generator: { return value })
  }

  static func from<T>(_ array: Array<T>) -> Gen<T> {
    return Gen<T>(generator: {
      let index = (arc4random() |> Int.init(_:)) % array.count
      return array[index]
    })
  }

  static func from<T>(_ range: CountableClosedRange<T>) -> Gen<T> {
    return Gen<T>.from(Array(range))
  }

  func getAnother() -> Value {
    return generator()
  }
}

protocol Function {
  associatedtype Arguments: ArgumentEnumerable
  associatedtype Return
}

protocol ArgumentEnumerable: SupportsOneArgument { }

protocol SupportsOneArgument {
  associatedtype FirstArgument: ArgumentType
}

enum OneArgument<T>: SupportsOneArgument where T: ArgumentType {
  typealias FirstArgument = T
  case first
}

protocol SupportsSecondArgument: SupportsOneArgument {
  associatedtype SecondArgument: ArgumentType
}

enum TwoArgument<T, U>: SupportsSecondArgument where T: ArgumentType, U: ArgumentType {
  typealias FirstArgument = T
  typealias SecondArgument = U
  case first
  case second
}

struct UnaryFunction<T, R>: Function where T: ArgumentType {
  typealias Arguments = OneArgument<T>
  typealias Return = R
  typealias FirstArgument = T

  let function: (T) -> R

  init(_ function: @escaping (T) -> R) {
    self.function = function
  }
}

