//
//  Gen.swift
//  HypotheSwift iOS
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude
import RandomKit

struct Gen<Value> {

  let generator: () -> Value

  // MARK: - Static initializers

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

  // MARK: Instance Methods

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

  func flatMap<T>(_ mapping: @escaping (Value) -> Gen<T>) -> Gen<T> {
    return Gen<Gen<T>>(generator: generator >>> mapping)
      .map { $0.getAnother() }
  }

  func combine<T>(_ other: Gen<T>) -> Gen<(Value, T)> {
    return Gen<(Value, T)>(generator: { (self.getAnother(), other.getAnother()) })
      .map(flattenTuple)
  }

  static func from<T>(_ range: CountableClosedRange<T>) -> Gen<T> where T: RandomInClosedRange {
    precondition(range.isEmpty == false)
    return Gen<T>(generator: {
      return T.random(in: range, using: &Xoroshiro.default)
    })
  }

  static func from<T>(_ range: ClosedRange<T>) -> Gen<T> where T: RandomInClosedRange {
    precondition(range.isEmpty == false)
    return Gen<T>(generator: {
      return T.random(in: range, using: &Xoroshiro.default)
    })
  }

}

extension Gen where Value: RandomInClosedRange {


}
