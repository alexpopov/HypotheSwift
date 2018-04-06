//
//  Constraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation
import Prelude

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
  var label: String? = nil
  
  init(rejector: @escaping Rejector) {
    self.rejector = rejector
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
  
  let promoter: (Arguments) -> T
  
  init(promoter: @escaping (Arguments) -> T) {
    self.promoter = promoter
  }
  
  func not(_ some: T) -> ArgumentConstraint<Arguments> {
    return (promoter >>> { some == $0 })
      |> ArgumentConstraint.init
  }
  
  func not(_ predicate: @escaping (T) -> Bool) -> ArgumentConstraint<Arguments> {
    return (promoter >>> predicate) |> ArgumentConstraint.init
  }
  
}

struct MultiArgumentConstraint<Arguments>
  where Arguments: ArgumentEnumerable {

  func not(_ combination: Arguments.TupleRepresentation) -> ArgumentConstraint<Arguments> {
    return { $0 == Arguments(tuple: combination) }
      |> ArgumentConstraint.init
  }
  
  func not(_ predicate: @escaping (Arguments.TupleRepresentation) -> Bool) -> ArgumentConstraint<Arguments> {
    return { $0.asTuple |> predicate }
      |> ArgumentConstraint.init
  }
  
}

extension ConstraintMaker where Arguments: SupportsOneArgument {
  var first: SingleArgumentConstraint<Arguments, Arguments.FirstArgument> {
    return SingleArgumentConstraint(promoter: Arguments.firstArgumentLens.get)
  }
}

extension ConstraintMaker where Arguments: SupportsTwoArguments {
  
  var second: SingleArgumentConstraint<Arguments, Arguments.SecondArgument> {
    return SingleArgumentConstraint(promoter: Arguments.secondArgumentLens.get)
  }
  
  var all: MultiArgumentConstraint<Arguments> {
    return MultiArgumentConstraint<Arguments>()
  }
  
}


