//
//  MinimizableArgumentType.swift
//  HypotheSwift iOS
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation
import RandomKit

struct AnyMinimizableArgument<T: ArgumentType> {
  fileprivate let _minimizationSize: () -> Int
  fileprivate let _minimizationStrategies: () -> [(T) -> T]

  init(_ argument: T) {
    _minimizationSize = always(0)
    _minimizationStrategies = always([])
  }

  var minimizationSize: Int { return _minimizationSize() }
  func minimizationStrategies() -> [(T) -> T] {
    return _minimizationStrategies()
  }
}

extension AnyMinimizableArgument where T: MinimizableArgumentType {
  init(minimizable argument: T) {
    self._minimizationSize = always(argument.minimizationSize)
    self._minimizationStrategies = always(argument.minimizationStrategies())
  }
}

public protocol MinimizableArgumentType: ArgumentType {
  typealias Minimization = (Self) -> Self
  var minimizationSize: Int { get }
  func minimizationStrategies() -> [Minimization]

}

extension String: MinimizableArgumentType {
  public var minimizationSize: Int { return count }

  public func minimizationStrategies() -> [Minimization] {
    guard self.isEmpty == false else { return [] }
    let maximumIndicesToRemove = indices.count < 20 ? indices.count : indices.count / 2
    let randomIndices = Array(indices).randomSlice(count: maximumIndicesToRemove, using: &Xoroshiro.default)
    let removeRandomCharacters: [Minimization] = randomIndices.map { index in { $0.removing(at: index) } }
    return removeRandomCharacters
  }
}
