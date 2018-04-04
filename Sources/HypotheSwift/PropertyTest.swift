//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude
import Focus

func testThat<T, R>(_ function: @escaping (T) -> R, will invariant: String)
  -> PropertyTest<UnaryFunction<T, R>>
  where T: ArgumentType {
    let unaryTest = UnaryFunction(function)
    return PropertyTest(test: unaryTest, invariant: invariant)
}

protocol Constrainable {
  associatedtype Arguments: ArgumentEnumerable
}

extension Constrainable where Arguments: SupportsOneArgument {
  func assumingFirst(not value: Arguments.FirstArgument) -> Self {
    print("First argument will never be \(value)")
    return self
  }
}

extension Constrainable where Arguments: SupportsTwoArguments {
  func assumingSecond(not value: Arguments.SecondArgument) -> Self {
    print("Second argument will never be \(value)")
    return self
  }
}

struct PropertyTest<Test: Function>: Constrainable {

  typealias Arguments = Test.Arguments

  let invariantDeclaration: String
  let test: Test

  fileprivate var numberOfArguments = 0

  init(test: Test, invariant: String) {
    self.test = test
    self.invariantDeclaration = invariant
  }

  func shouldTest(count: Int) -> PropertyTest<Test> {
    return PropertyTest<Test>.numberOfArgumentsLens.set(self, count)
  }

  private func generateArguments(count: Int) -> [Arguments] {
    return Arguments.gen.generate(count: count)
  }

  static var numberOfArgumentsLens: SimpleLens<PropertyTest, Int> {
    return SimpleLens(keyPath: \PropertyTest.numberOfArguments)
  }

  func createConstraints(_ method: @escaping (ConstraintMaker<Test.Arguments>) -> ()) -> PropertyTest<Test> {
    // TODO: update
    return self
  }

  func runTests() {

  }

}

class ConstraintMaker<Arguments: ArgumentEnumerable> {
  var constraints: [ConstraintProtocol] = []
}

class SingleArgumentConstraint<T>: ConstraintProtocol {

  var constraint: SingleValueConstraint<T> = .incomplete

  func not(_ some: T) {
    self.constraint = .not(some)
  }
}

class MultiArgumentConstraint<Arguments: ArgumentEnumerable>: ConstraintProtocol {
  var constraint: MultiValueConstraint<Arguments> = .incomplete

  func not(_ combination: Arguments.TupleRepresentation) {
    self.constraint = .not(combination)
  }
}

extension ConstraintMaker where Arguments: SupportsOneArgument {
  func constrainFirst(as: SingleValueConstraint<Arguments.FirstArgument>) -> ConstraintMaker<Arguments> {
    return self
  }

  var first: SingleArgumentConstraint<Arguments.FirstArgument> {
    let constraint = SingleArgumentConstraint<Arguments.FirstArgument>()
    constraints.append(constraint)
    return constraint
  }
}

extension ConstraintMaker where Arguments: SupportsTwoArguments {

  var second: SingleArgumentConstraint<Arguments.SecondArgument> {
    let constraint = SingleArgumentConstraint<Arguments.SecondArgument>()
    constraints.append(constraint)
    return constraint
  }

  var all: MultiArgumentConstraint<Arguments> {
    let constraint = MultiArgumentConstraint<Arguments>()
    constraints.append(constraint)
    return constraint
  }

}

protocol ConstraintProtocol {

}

enum SingleValueConstraint<T>: ConstraintProtocol {
  case incomplete
  case not(T)
  case noneMatching((T) -> Bool)
}

enum MultiValueConstraint<Arguments: ArgumentEnumerable>: ConstraintProtocol {
  case incomplete
  case not(Arguments.TupleRepresentation)
  case noneMatching((Arguments.TupleRepresentation) -> Bool)
  case enforce((Arguments.TupleRepresentation) -> Bool)
}
