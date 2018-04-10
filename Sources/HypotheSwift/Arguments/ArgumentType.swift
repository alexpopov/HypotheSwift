//
//  ArgumentType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude
import RandomKit

/// Metatype representing a single argument to some function.
///
/// The conforming type must be (at least) pseudo-randomly generatable
///
/// Conformers also have the option of providing `minimizationSize` and
/// `minimizationStrategies` though those are optionally required for
/// failing test case minimization. `0` and `[]` are adequate no-op values.
public protocol ArgumentType: Hashable {
  /// Generator for creating values of Self
  static var gen: Gen<Self> { get }
  typealias Minimization = (Self) -> Self
  /// Size of self, on an absolute scale, relative to other Selfs
  var minimizationSize: Int { get }
  /// Homomorphic mappings for reducing the `size` of self.
  ///
  /// Think of this as a way of simplying your value, e.g. removing
  /// characters from a String or reducing an Integer, with the intent of
  /// identifying the minimal test case which will fail the test.
  func minimizationStrategies() -> [Minimization]
}

extension Int: ArgumentType {
  public static var gen: Gen<Int> { return Gen<Int>.random() }
  public var minimizationSize: Int { return abs(self) }
  public func minimizationStrategies() -> [(Int) -> Int] {
    return [
      { $0 / 2 },
      { $0 - 1}
    ]
  }
}

extension Float: ArgumentType {
  public static var gen: Gen<Float> { return Gen<Float>.random() }
  public var minimizationSize: Int { return Int(self) }
  public func minimizationStrategies() -> [(Float) -> Float] {
    return []
  }
}

extension Double: ArgumentType {
  public static var gen: Gen<Double> { return Gen<Double>.random() }
  public var minimizationSize: Int { return Int(self) }
  public func minimizationStrategies() -> [(Double) -> Double] {
    return []
  }
}

extension Bool: ArgumentType {
  public static var gen: Gen<Bool> { return Gen<Bool>.random() }
  public var minimizationSize: Int { return 0 }
  public func minimizationStrategies() -> [(Bool) -> Bool] {
    return []
  }
}

extension Array: Hashable where Element: Hashable {
  public var hashValue: Int { return reduce(1_006_879) { $0 ^ $1.hashValue } }
}

extension Array: ArgumentType where Element: ArgumentType {
  public static var gen: Gen<Array<Element>> {
    return Gen<Array<Element>>(generator: {
      let zero = 0
      let arrayLength = Int.random(in: (0..<10), using: &Xoroshiro.default) ?? 10
      return (zero..<arrayLength)
        .map { _ in Element.gen.getAnother() }
    })
  }
  public var minimizationSize: Int { return count }
  public func minimizationStrategies() -> [(Array<Element>) -> Array<Element>] {
    let maximumIndicesToRemove = Int(log2(Float(indices.count)))
    let randomIndices = (0...maximumIndicesToRemove).map { _ in Int.random(in: indices, using: &Xoroshiro.default) ?? 0 }
    let removeRandomElements: [Minimization] = randomIndices.map { index in { $0.removing(at: index) } }
    return removeRandomElements
  }
}

extension String: ArgumentType {
  public static var gen: Gen<String> {
    return Gen<String>.random()
  }

  public var minimizationSize: Int { return count }

  public func minimizationStrategies() -> [Minimization] {
    guard self.isEmpty == false else { return [] }
    let maximumIndicesToRemove = Int(log2(Float(indices.count)))
    let randomIndices = Array(indices).randomSlice(count: maximumIndicesToRemove, using: &Xoroshiro.default)
    let removeRandomCharacters: [Minimization] = randomIndices.map { index in { $0.removing(at: index) } }
    return removeRandomCharacters
  }

}
