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
}

extension Int: ArgumentType {
  public static var gen: Gen<Int> { return Gen<Int>.random() }
}

extension Float: ArgumentType {
  public static var gen: Gen<Float> { return Gen<Float>.random() }
}

extension Double: ArgumentType {
  public static var gen: Gen<Double> {
    return Gen<Double>.random()
  }
}

extension Bool: ArgumentType {
  public static var gen: Gen<Bool> { return Gen<Bool>.random() }
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
}

extension String: ArgumentType {
  public static var gen: Gen<String> {
    return Gen<String>(generator: {
      return String.random(using: &Xoroshiro.default)
    })
  }
}
