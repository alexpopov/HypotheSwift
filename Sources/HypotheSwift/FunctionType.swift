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
    precondition(array.isEmpty == false)
    return Gen<T>(generator: {
      let index = (arc4random() |> Int.init(_:)) % array.count
      return array[index]
    })
  }

  static func from<T>(_ range: CountableClosedRange<T>) -> Gen<T> {
    precondition(range.isEmpty == false)
    return Gen<T>.from(Array(range))
  }

  func getAnother() -> Value {
    return generator()
  }

  func generate(count: Int) -> [Value] {
    return (0..<count).map { _ in () }
      .map(getAnother)
  }

  func map<T>(_ mapping: @escaping (Value) -> T) -> Gen<T> {
    return Gen<T>(generator: generator >>> mapping)
  }

  func combine<T>(_ other: Gen<T>) -> Gen<(Value, T)> {
    return Gen<(Value, T)>(generator: { (self.getAnother(), other.getAnother()) })
      .map(flattenTuple)
  }
}

func unit<T>(_ object: T) -> T { return object }

func flattenTuple<T, U>(_ tuple: (T, U)) -> (T, U) {
  return unit(tuple)
}

func flattenTuple<T, U, V>(_ tuple: ((T, U), V)) -> (T, U, V) {
  return (tuple.0.0, tuple.0.1, tuple.1)
}

protocol Function {
  associatedtype Arguments: ArgumentEnumerable
  associatedtype Return
  var function: (Arguments.TupleRepresentation) -> Return { get }
}

extension Function {
  func runTests() {
    // here we run our logic to create a bunch of arguments
    // and filter out the ones that don't meet the constraints

  }
}

protocol AllCasesProviding {
  static var allCases: [Self] { get } 
}

protocol ArgumentEnumerable: ArgumentType {
  associatedtype Position: AllCasesProviding
  associatedtype TupleRepresentation

  var asTuple: TupleRepresentation { get }
}

protocol SupportsOneArgument: ArgumentEnumerable {
  associatedtype FirstArgument: ArgumentType
}

struct OneArgument<T>: SupportsOneArgument where T: ArgumentType {
  typealias FirstArgument = T
  typealias TupleRepresentation = (T)

  enum Position: AllCasesProviding {
    case first

    static var allCases: [OneArgument<T>.Position] { return [.first] }
  }
  let firstArgument: T

  var asTuple: (T) { return firstArgument }

  static var gen: Gen<OneArgument<T>> {
    return T.gen.map(OneArgument<T>.init(firstArgument:))
  }
}

protocol SupportsTwoArguments: SupportsOneArgument {
  associatedtype SecondArgument: ArgumentType
}

struct TwoArgument<T, U>: SupportsTwoArguments where T: ArgumentType, U: ArgumentType {
  typealias FirstArgument = T
  typealias SecondArgument = U
  typealias TupleRepresentation = (T, U)

  enum Position: AllCasesProviding {
    case first
    case second

    static var allCases: [TwoArgument<T, U>.Position] { return [.first, .second] }
  }

  let firstArgument: T
  let secondArgument: U

  var asTuple: (T, U) { return (firstArgument, secondArgument) }

  static var gen: Gen<TwoArgument<T, U>> {
    return T.gen
      .combine(U.gen)
      .map(TwoArgument<T, U>.init(firstArgument:secondArgument:))
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
  typealias Arguments = TwoArgument<T, U>
  typealias Return = R
  typealias FirstArgument = T
  typealias SecondArgument = U

  var function: ((T, U)) -> R

  init(_ function: @escaping (T, U) -> R) {
    self.function = function
  }
}

extension SupportsOneArgument {
  static func generateFirstArgument(number: Int) -> AnyCollection<FirstArgument> {
    return Array(repeating: (), count: number)
      .lazy
      .map(FirstArgument.gen.getAnother)
      .typeErase()
  }
}

extension SupportsTwoArguments {
  static func generateSecondArgument(number: Int) -> AnyCollection<SecondArgument> {
    return (0..<number).lazy
      .map { _ in SecondArgument.gen.getAnother() }
      .typeErase()
  }
}

extension Collection {
  func typeErase() -> AnyCollection<Element> {
    return AnyCollection(self)
  }
}
