//
//  FunctionType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude
import Darwin

protocol ArgumentType: Equatable {
  static var gen: Gen<Self> { get }
}

extension Int: ArgumentType {
  static var gen: Gen<Int> {
    let range = (Int.min...Int.max)
    return Gen<Int>.from(range)
  }

  static func fromRandomInt(_ int: Int) -> Int {
    return int
  }
}

extension Float: ArgumentType {
  static var gen: Gen<Float> {
    return Gen<Float>(generator: {
      let floatMemoryLayout = MemoryLayout<Float>.self
      let buffer = UnsafeMutableRawPointer.allocate(bytes: floatMemoryLayout.size, alignedTo: 0)
      arc4random_buf(buffer, floatMemoryLayout.size)
      return buffer.assumingMemoryBound(to: Float.self).pointee
    })
  }
}


func unit<T>(_ object: T) -> T { return object }

func flattenTuple<T, U>(_ tuple: (T, U)) -> (T, U) {
  return unit(tuple)
}

func flattenTuple<T, U, V>(_ tuple: ((T, U), V)) -> (T, U, V) {
  return (tuple.0.0, tuple.0.1, tuple.1)
}

func flattenTuple<T>(_ tuple: T) -> T {
  return unit(tuple)
}

func always<T, U>(_ just: U) -> (T) -> U {
  return { _ in just }
}

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

protocol AllCasesProviding {
  static var allCases: [Self] { get } 
}

protocol ArgumentEnumerable: ArgumentType {
  associatedtype Position: AllCasesProviding
  associatedtype TupleRepresentation
  init(tuple: TupleRepresentation)

  var asTuple: TupleRepresentation { get }
}

protocol SupportsOneArgument: ArgumentEnumerable {
  associatedtype FirstArgument: ArgumentType
  var firstArgument: FirstArgument { get set }
}

extension SupportsOneArgument {
  static var firstArgumentLens: SimpleLens<Self, FirstArgument> {
    return SimpleLens(keyPath: \Self.firstArgument)
  }
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
  
  enum Position: AllCasesProviding {
    case first
    
    static var allCases: [OneArgument<T>.Position] { return [.first] }
  }
  
}

protocol SupportsTwoArguments: SupportsOneArgument {
  associatedtype SecondArgument: ArgumentType
  var secondArgument: SecondArgument { get set }
}

extension SupportsTwoArguments {
  static var secondArgumentLens: SimpleLens<Self, SecondArgument> {
    return SimpleLens(keyPath: \Self.secondArgument)
  }
}
struct TwoArgument<T, U>: SupportsTwoArguments where T: ArgumentType, U: ArgumentType {

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

  static var gen: Gen<TwoArgument<T, U>> {
    return T.gen.combine(U.gen).map(TwoArgument<T, U>.init(tuple:))
  }
  
  static func == (lhs: TwoArgument<T, U>, rhs: TwoArgument<T, U>) -> Bool {
    return lhs.asTuple == rhs.asTuple
  }
  
  enum Position: AllCasesProviding {
    case first
    case second
    
    static var allCases: [TwoArgument<T, U>.Position] { return [.first, .second] }
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

extension Collection where Self: Collection, Self.Indices: Collection, Self.SubSequence: Collection, Self.SubSequence.Indices: Collection{
  func typeErase() -> AnyCollection<Self.Iterator.Element> {
    return AnyCollection<Self.Iterator.Element>.init(self)
  }
}
