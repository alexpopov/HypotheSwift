//
//  Constraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation
import Prelude
import RandomKit

struct ConstraintMaker<Arguments: ArgumentEnumerable> {
  private(set) var constraints: [ArgumentConstraint<Arguments>] = []
  
  static var constraintsLens: SimpleLens<ConstraintMaker<Arguments>, [ArgumentConstraint<Arguments>]> {
    return SimpleLens(keyPath: \ConstraintMaker<Arguments>.constraints)
  }
}

protocol ConstraintProtocol {
  associatedtype ConstraintTarget
  typealias Rejector = (ConstraintTarget) -> Bool
  var rejector: Rejector { get }
}

struct ArgumentConstraint<Arguments>: ConstraintProtocol where Arguments: ArgumentEnumerable {
  typealias ConstraintTarget = Arguments
  let rejector: (Arguments) -> Bool
  let generatorConstraint: (Arguments) -> Arguments

  var label: String? = nil

  init(rejector: @escaping Rejector, generatorConstraint: @escaping (Arguments) -> Arguments) {
    self.rejector = rejector
    self.generatorConstraint = generatorConstraint
  }
  
  func labeled(_ string: String) -> ArgumentConstraint<Arguments> {
    return ArgumentConstraint.labelLens.set(self, label)
  }
  
  private static var labelLens: SimpleLens<ArgumentConstraint<Arguments>, String?> {
    return SimpleLens(keyPath: \ArgumentConstraint.label)
  }
}

struct SingleArgumentConstraint<Arguments, T>
  where T: ArgumentType, Arguments: ArgumentEnumerable {
  
  typealias ConstraintTarget = T
  
  let argumentLens: SimpleLens<Arguments, T>

  var noopRejector: (Arguments) -> Bool {
    return argumentLens.get >>> always(false)
  }

  init(argumentLens: SimpleLens<Arguments, T>) {
    self.argumentLens = argumentLens
  }
  
  func not(_ some: T) -> ArgumentConstraint<Arguments> {
    let rejector = argumentLens.get >>> { some == $0 }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
  func not(_ predicate: @escaping (T) -> Bool) -> ArgumentConstraint<Arguments> {
    let rejector = argumentLens.get >>> predicate
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }

  func must(be value: T) -> ArgumentConstraint<Arguments> {
    let generator: (Arguments) -> Arguments = { self.argumentLens.set($0, value) }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: generator)
  }
  
}

extension SingleArgumentConstraint where T: Strideable, T: RandomInClosedRange {
  func must(beIn range: ClosedRange<T>) -> ArgumentConstraint<Arguments> {
    let generator: (Arguments) -> Arguments = { oldArgs in
      let newTInRange = Gen<T>.from(range).getAnother()
      return self.argumentLens.set(oldArgs, newTInRange)
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: generator)
  }

}

extension SingleArgumentConstraint where T: Strideable, T.Stride: SignedInteger, T: RandomInClosedRange {

  func must(beIn range: CountableClosedRange<T>) -> ArgumentConstraint<Arguments> {
    let generator: (Arguments) -> Arguments = { oldArgs in
      let newTInRange = Gen<T>.from(range).getAnother()
      return self.argumentLens.set(oldArgs, newTInRange)
    }
    return ArgumentConstraint(rejector: noopRejector, generatorConstraint: generator)
  }

}

struct MultiArgumentConstraint<Arguments>
  where Arguments: ArgumentEnumerable {

  func not(_ combination: Arguments.TupleRepresentation) -> ArgumentConstraint<Arguments> {
    let rejector = { $0 == Arguments(tuple: combination) }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
  func not(_ predicate: @escaping (Arguments.TupleRepresentation) -> Bool) -> ArgumentConstraint<Arguments> {
    let rejector: (Arguments) -> Bool = { $0.asTuple |> predicate }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
}

extension ConstraintMaker where Arguments: SupportsOneArgument {
  var first: SingleArgumentConstraint<Arguments, Arguments.FirstArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.firstArgumentLens)
  }
}

extension ConstraintMaker where Arguments: SupportsTwoArguments {
  
  var second: SingleArgumentConstraint<Arguments, Arguments.SecondArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.secondArgumentLens)
  }
  
  var all: MultiArgumentConstraint<Arguments> {
    return MultiArgumentConstraint<Arguments>()
  }
  
}


