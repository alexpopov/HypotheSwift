//
//  ArgumentType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude
import RandomKit

public protocol ArgumentType: Equatable {
  static var gen: Gen<Self> { get }
  typealias Minimization = (Self) -> Self
  var minimizationSize: Int { get }
  func minimizationStrategies() -> [Minimization]
}

extension Int: ArgumentType {
  public static var gen: Gen<Int> { return Gen<Int>.random() }
  public var minimizationSize: Int { return Int(log2(Float(self))) }
  public func minimizationStrategies() -> [(Int) -> Int] {
    return []
  }
}

extension Float: ArgumentType {
  public static var gen: Gen<Float> { return Gen<Float>.random() }
  public var minimizationSize: Int { return Int(log2(self)) }
  public func minimizationStrategies() -> [(Float) -> Float] {
    return []
  }
}

extension Double: ArgumentType {
  public static var gen: Gen<Double> { return Gen<Double>.random() }
  public var minimizationSize: Int { return Int(log2(self)) }
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
    return []
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
