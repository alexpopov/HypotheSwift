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

  func withConstraints(_ constraintMaker: (ConstraintMaker<Test.Arguments>) -> ([ArgumentConstraint<Test.Arguments>]))
    -> PropertyTest<Test> {
      let constraints = ConstraintMaker<Test.Arguments>() |> constraintMaker
      return PropertyTest.constraintsLens.set(self, constraints)
  }

  func withConstraint(that constraintMaker: (ConstraintMaker<Test.Arguments>) -> ArgumentConstraint<Test.Arguments>)
    -> PropertyTest<Test> {
      let newConstraint = ConstraintMaker<Test.Arguments>() |> constraintMaker
      return PropertyTest.constraintsLens.over { $0.appending(newConstraint) }
        <| self
  }
  
  func proving(that predicate: @escaping (Test.Return) -> Bool) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest<Test>(test: test,
                                       constraints: constraints,
                                       invariant: .returnOnly(predicate),
                                       description: invariantDeclaration)
  }
  
  func proving(that predicate: @escaping (Test.Arguments.TupleRepresentation, Test.Return) -> Bool) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest<Test>(test: test,
                                       constraints: constraints,
                                       invariant: .all(predicate),
                                       description: invariantDeclaration)
  }

}

struct TestConfig<Test: Function> {
  var numberOfTests: Int = 100
  var loggingLevel: LoggingLevel = .failures

  init() {

  }

  static var numberOfTestsLens: SimpleLens<TestConfig<Test>, Int> {
    return SimpleLens(keyPath: \TestConfig.numberOfTests)
  }

  static var loggingLevelLens: SimpleLens<TestConfig<Test>, LoggingLevel> {
    return SimpleLens(keyPath: \TestConfig.loggingLevel)
  }

}

enum LoggingLevel: Int, Comparable {
  static func < (lhs: LoggingLevel, rhs: LoggingLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  case none
  case failures
  case successes
  case all

  var shouldLog: Bool {
    if case .none = self {
      return false
    } else {
      return true
    }
  }
}

struct FinalizedPropertyTest<Test: Function> {
  private let test: Test
  private let constraints: [ArgumentConstraint<Test.Arguments>]
  private let invariant: ProvableInvariant
  private let invariantDescription: String

  fileprivate var numberOfTests: Int = 100

  fileprivate var config = TestConfig<Test>()

  static var configLens: SimpleLens<FinalizedPropertyTest<Test>, TestConfig<Test>> {
    return SimpleLens(keyPath: \FinalizedPropertyTest.config)
  }

  var configLens: SimpleLens<FinalizedPropertyTest<Test>, TestConfig<Test>> {
    return FinalizedPropertyTest.configLens
  }

  init(test: Test,
       constraints: [ArgumentConstraint<Test.Arguments>],
       invariant: ProvableInvariant,
       description: String) {
    self.test = test
    self.constraints = constraints
    self.invariant = invariant
    self.invariantDescription = description
  }
  
  func log(level: LoggingLevel = .failures) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest.configLens.looking(at: TestConfig.loggingLevelLens).set(self, level)
  }
  
  func minimumNumberOfTests(count: Int) -> FinalizedPropertyTest<Test> {
    return configLens.looking(at: TestConfig.numberOfTestsLens).set(self, count)
  }
  
  func run() {
    // two orders of magnitude, until we get smarter generation capabilities
    let maximumTests = numberOfTests
    let generator = constrainingGenerator(Test.Arguments.gen, with: constraints)
    for currentTest in (0..<maximumTests) {
      let arguments = generator.getAnother()
      run(test: test, number: currentTest, with: arguments, and: constraints, proving: invariant)
    }
  }

  private func run(test: Test,
                   number: Int,
                   with arguments: Test.Arguments,
                   and constraints: [ArgumentConstraint<Test.Arguments>],
                   proving provableInvariant: ProvableInvariant) {
    log("Running test #\(number)", for: .all)
    log("Generated args: \(arguments)", for: .all)
    // see if args pass constraints
    guard argumentsAreRejected(arguments, by: constraints) == false else {
      log("Arguments \(arguments) where rejected by a constraint", for: .all)
      // `continue` iterating if not; actually continue if they do
      return
    }
    // pass arguments to function
    let result = test.call(with: arguments)
    log("Which yielded: \(result)", for: .all)
    let passes = resultPasses(result, with: arguments, against: provableInvariant)
    if passes {
      log("Test #\(number) passed!", for: .successes)
    } else {
      log("Test #\(number) failed; did not pass invariant with: \(arguments)", for: .failures)
    }
  }

  func constrainingGenerator(_ gen: Gen<Test.Arguments>, with constraints: [ArgumentConstraint<Test.Arguments>])
    -> Gen<Test.Arguments> {
      return constraints
        .map { $0.generatorConstraint }
        .reduce(gen, { $1 |> $0.map })
  }

  func argumentsAreRejected(_ arguments: Test.Arguments, by constraints: [ArgumentConstraint<Test.Arguments>]) -> Bool {
    return constraints.map { $0.rejector }
      .reduce(false) { $0 || $1(arguments) }
  }

  func resultPasses(_ result: Test.Return,
                    with arguments: Test.Arguments,
                    against provableInvariant: ProvableInvariant) -> Bool {
    switch provableInvariant {
    case .returnOnly(let pureInvariant):
      return pureInvariant(result)
    case .all(let relativeInvariant):
      return relativeInvariant(arguments.asTuple, result)
    }
  }


  private func log(_ event: String, for loggingLevel: LoggingLevel) {
    guard loggingLevel <= config.loggingLevel else { return }
    print(event)
  }
  
  enum ProvableInvariant {
    case returnOnly((Test.Return) -> Bool)
    case all((Test.Arguments.TupleRepresentation, Test.Return) -> Bool)
  }
  

}

class ConstraintSolver<Test: Function> {
  let arguments: Test.Arguments
  
  init(arguments: Test.Arguments, constraints: [ArgumentConstraint<Test.Arguments>]) {
    fatalError()
  }
}
