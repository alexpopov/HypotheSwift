//
//  SingleArgumentConstraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation
import Prelude
import RandomKit

public struct SingleArgumentConstraint<Arguments, T>
where T: ArgumentType, Arguments: ArgumentEnumerable {
  
  typealias ConstraintTarget = T
  typealias Rejector = (Arguments) -> Bool
  typealias GeneratorConstraint = (Gen<Arguments>) -> Gen<Arguments>
  
  fileprivate let argumentLens: SimpleLens<Arguments, T>
  
  fileprivate var noopRejector: (Arguments) -> Bool {
    return argumentLens.get >>> always(false)
  }
  
  internal init(argumentLens: SimpleLens<Arguments, T>) {
    self.argumentLens = argumentLens
  }
  
  public func not(_ some: T) -> ArgumentConstraint<Arguments> {
    let rejector = argumentLens.get >>> { some == $0 }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
  public func not(_ predicate: @escaping (T) -> Bool) -> ArgumentConstraint<Arguments> {
    let rejector = argumentLens.get >>> predicate
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
  public func must(be value: T) -> ArgumentConstraint<Arguments> {
    let generator: GeneratorConstraint = { $0.map { self.argumentLens.set($0, value) } }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: generator)
  }
  
  public func must(meet predicate: @escaping (T) -> Bool) -> ArgumentConstraint<Arguments> {
    let rejector: Rejector = { (self.argumentLens.get($0) |> predicate) == false  }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
  public func produced(by generator: Gen<T>) -> ArgumentConstraint<Arguments> {
    let generator: GeneratorConstraint = { $0.map { oldArgs in
      let customT = generator.getAnother()
      return self.argumentLens.set(oldArgs, customT)
      }
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: generator)
  }
  
}

extension SingleArgumentConstraint where T: Strideable, T: RandomInClosedRange {
  
  public func must(beIn range: ClosedRange<T>) -> ArgumentConstraint<Arguments> {
    let generator: (Arguments) -> Arguments = { oldArgs in
      let newTInRange = Gen<T>.from(range).getAnother()
      return self.argumentLens.set(oldArgs, newTInRange)
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: { $0.map(generator) })
  }
}

extension SingleArgumentConstraint where T: Random {
  
  public func randomized(by randomGenerator: @escaping (T.Type) -> T) -> ArgumentConstraint<Arguments> {
    let generator: (Arguments) -> Arguments = { oldArgs in
      let randomT = randomGenerator(T.self)
      return self.argumentLens.set(oldArgs, randomT)
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: { $0.map(generator) })
  }
}

extension SingleArgumentConstraint where T: Strideable, T.Stride: SignedInteger, T: RandomInClosedRange {
  
  public func must(beIn range: CountableClosedRange<T>) -> ArgumentConstraint<Arguments> {
    let generator: (Arguments) -> Arguments = { oldArgs in
      let newTInRange = Gen<T>.from(range).getAnother()
      return self.argumentLens.set(oldArgs, newTInRange)
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: { $0.map(generator) })
  }
  
}

extension SingleArgumentConstraint
where T: Strideable, T: RandomInRange, T.Stride: SignedInteger {
  
  public func must(beIn range: CountableRange<T>) -> ArgumentConstraint<Arguments> {
    let generator: GeneratorConstraint = { $0.map { oldArgs in
      let newTInRange = Gen<T>.from(range).getAnother()
      return self.argumentLens.set(oldArgs, newTInRange)
      }
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: generator)
  }
}
