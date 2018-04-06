//
//  ArgumentType.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude
import RandomKit

protocol ArgumentType: Equatable {
  static var gen: Gen<Self> { get }
}

extension Int: ArgumentType {
  static var gen: Gen<Int> {
    let range = (Int.min...Int.max)
    return Gen<Int>.from(range)
  }
}

extension Float: ArgumentType {
  static var gen: Gen<Float> {
    return Gen<Float>(generator: {
      return Float.random(using: &Xoroshiro.default)
    })
  }
}

