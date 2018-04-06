//
//  Constraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation
import Prelude
import RandomKit

struct ArgumentConstraint<Arguments> where Arguments: ArgumentEnumerable {
  typealias ConstraintTarget = Arguments
  typealias Rejector = (Arguments) -> Bool
  typealias GeneratorConstraint = (Arguments) -> Arguments

  let rejector: Rejector
  let generatorConstraint: GeneratorConstraint

  var label: String? = nil

  init(rejector: @escaping Rejector, generatorConstraint: @escaping GeneratorConstraint) {
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

struct ConstraintMaker<Arguments: ArgumentEnumerable> {
  private(set) var constraints: [ArgumentConstraint<Arguments>] = []

  static var constraintsLens: SimpleLens<ConstraintMaker<Arguments>, [ArgumentConstraint<Arguments>]> {
    return SimpleLens(keyPath: \ConstraintMaker<Arguments>.constraints)
  }
}

extension ConstraintMaker where Arguments: SupportsOneArgument {
  var firstArgument: SingleArgumentConstraint<Arguments, Arguments.FirstArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.firstArgumentLens)
  }
}

extension ConstraintMaker where Arguments: SupportsTwoArguments {
  
  var secondArgument: SingleArgumentConstraint<Arguments, Arguments.SecondArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.secondArgumentLens)
  }
  
  var allArguments: MultiArgumentConstraint<Arguments> {
    return MultiArgumentConstraint<Arguments>()
  }
  
}

extension ConstraintMaker where Arguments: SupportsThreeArguments {

  var thirdArgument: SingleArgumentConstraint<Arguments, Arguments.ThirdArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.thirdArgumentLens)
  }

}

extension ConstraintMaker where Arguments: SupportsFourArguments {

  var fourthArgument: SingleArgumentConstraint<Arguments, Arguments.FourthArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.fourthArgumentLens)
  }
}
