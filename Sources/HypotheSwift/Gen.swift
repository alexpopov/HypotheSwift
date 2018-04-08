//
//  Gen.swift
//  HypotheSwift iOS
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude
import RandomKit

public struct Gen<Value> {

  let generator: () -> Value

  // MARK: - Static initializers

  public static func just<T>(_ value: T) -> Gen<T> {
    return Gen<T>(generator: { return value })
  }

  public static func from<T>(_ array: Array<T>) -> Gen<T> {
    precondition(array.isEmpty == false)
    return Gen<T>(generator: {
      let index = (arc4random() |> Int.init(_:)) % array.count
      return array[index]
    })
  }

  // MARK: Instance Methods

  public func getAnother() -> Value {
    return generator()
  }

  public func generate(count: Int) -> [Value] {
    return (0..<count).map { _ in () }
      .map(getAnother)
  }

  public func map<T>(_ mapping: @escaping (Value) -> T) -> Gen<T> {
    return Gen<T>(generator: generator >>> mapping)
  }

  public func flatMap<T>(_ mapping: @escaping (Value) -> Gen<T>) -> Gen<T> {
    return Gen<Gen<T>>(generator: generator >>> mapping)
      .map { $0.getAnother() }
  }
  
  public func selfMap<T>(_ mapping: @escaping (Gen<Value>) -> Gen<T>) -> Gen<T> {
    return mapping(self)
  }

  public func combine<T>(_ other: Gen<T>) -> Gen<(Value, T)> {
    return Gen<(Value, T)>(generator: { (self.getAnother(), other.getAnother()) })
  }

  public func combine<T, U, V>(_ other: Gen<V>) -> Gen<(T, U, V)> where Value == (T, U) {
    return Gen<(T, U, V)>(generator: {
      return (self.getAnother(), other.getAnother()) |> flattenTuple
    })
  }

  public func combine<T, U, V, W>(_ other: Gen<W>) -> Gen<(T, U, V, W)> where Value == (T, U, V) {
    return Gen<(T, U, V, W)>(generator: {
      return (self.getAnother(), other.getAnother()) |> flattenTuple
    })
  }
  
  public static func random<T>() -> Gen<T> where T: Random {
    return Gen<T>(generator: {
      return T.random(using: &Xoroshiro.default)
    })
  }

  public static func from<T>(_ range: CountableClosedRange<T>) -> Gen<T> where T: RandomInClosedRange {
    precondition(range.isEmpty == false)
    return Gen<T>(generator: {
      return T.random(in: range, using: &Xoroshiro.default)
    })
  }

  public static func from<T>(_ range: ClosedRange<T>) -> Gen<T> where T: RandomInClosedRange {
    precondition(range.isEmpty == false)
    return Gen<T>(generator: {
      return T.random(in: range, using: &Xoroshiro.default)
    })
  }
  
  public static func from<T>(_ range: CountableRange<T>) -> Gen<T> where T: RandomInRange {
    precondition(range.isEmpty == false)
    return Gen<T>(generator: {
      return T.random(in: range, using: &Xoroshiro.default)!
    })
  }

}

