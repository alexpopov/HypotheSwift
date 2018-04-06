//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude

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
  private(set) var constraints: [ArgumentConstraint<Test.Arguments>] = []
  
  static var constraintsLens: SimpleLens<PropertyTest<Test>, [ArgumentConstraint<Test.Arguments>]> {
    return SimpleLens(keyPath: \PropertyTest.constraints)
  }
  

  init(test: Test, invariant: String) {
    self.test = test
    self.invariantDeclaration = invariant
  }

  func createConstraints(_ constraintCreator: (ConstraintMaker<Test.Arguments>) -> ([ArgumentConstraint<Test.Arguments>]))
    -> PropertyTest<Test> {
      let constraints = ConstraintMaker<Test.Arguments>() |> constraintCreator
      return PropertyTest.constraintsLens.set(self, constraints)
  }
  
  func proving(that predicate: @escaping (Test.Return) -> Bool) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest<Test>(constraints: constraints,
                                       invariant: .returnOnly(predicate),
                                       description: invariantDeclaration)
  }
  
  func proving(that predicate: @escaping (Test.Arguments.TupleRepresentation, Test.Return) -> Bool) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest<Test>(constraints: constraints,
                                       invariant: .all(predicate),
                                       description: invariantDeclaration)
  }

}

struct FinalizedPropertyTest<Test: Function> {
  fileprivate let constraints: [ArgumentConstraint<Test.Arguments>]
  fileprivate let invariant: ProvableInvariant
  fileprivate let invariantDescription: String
  
  fileprivate var numberOfTests: Int = 100
  fileprivate var shouldLog = false
  
  static var shouldLogLens: SimpleLens<FinalizedPropertyTest<Test>, Bool> {
    return SimpleLens(keyPath: \FinalizedPropertyTest.shouldLog)
  }
  
  static var numberOfTests: SimpleLens<FinalizedPropertyTest<Test>, Int> {
    return SimpleLens(keyPath: \FinalizedPropertyTest.numberOfTests)
  }
  

  init(constraints: [ArgumentConstraint<Test.Arguments>],
       invariant: ProvableInvariant,
       description: String) {
    self.constraints = constraints
    self.invariant = invariant
    self.invariantDescription = description
  }
  
  func log() -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest.shouldLogLens.set(self, true)
  }
  
  func minimumNumberOfTests(count: Int) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest.numberOfTests.set(self, count)
  }
  
  func run() {
    // two orders of magnitude, until we get smarter generation capabilities
    let maximumTests = numberOfTests * 100
    for currentTest in (0..<maximumTests) {
      // create args
      let args = Test.Arguments.gen.getAnother()
      // see if args pass constraints
      
      // `continue` if not; actually continue if they do
    }
  }
  
  enum ProvableInvariant {
    case returnOnly((Test.Return) -> Bool)
    case all((Test.Arguments.TupleRepresentation, Test.Return) -> Bool)
  }
  
  // TODO: use later
  enum LoggingLevel {
    case all
    case failures
  }
  
}

class ConstraintSolver<Test: Function> {
  let arguments: Test.Arguments
  
  init(arguments: Test.Arguments, constraints: [ArgumentConstraint<Test.Arguments>]) {
    fatalError()
  }
}
