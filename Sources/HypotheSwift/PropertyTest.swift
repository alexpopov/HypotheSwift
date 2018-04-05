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

func testThat<T, U, R>(_ function: @escaping (T, U) -> R, will invariant: String)
  -> PropertyTest<BinaryFunction<T, U, R>> {
    let binaryTest = BinaryFunction(function)
    return PropertyTest(test: binaryTest, invariant: invariant)
}

struct PropertyTest<Test: Function> {

  typealias Arguments = Test.Arguments

  let invariantDeclaration: String
  let test: Test
  
  let constraints = ConstraintMaker<Test.Arguments>()

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

  func createConstraints(_ constraintCreator: (ConstraintMaker<Test.Arguments>) -> ()) -> PropertyTest<Test> {
    constraintCreator(constraints)
    return self
  }

  func runTests() {

  }

}

class ConstraintMaker<Arguments: ArgumentEnumerable> {
  var constraints: [ConstraintProtocol] = []
}


