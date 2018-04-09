//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude
import Result
import RandomKit

public struct PropertyTest<Test: Function> {

  typealias Arguments = Test.Arguments

  let invariantDeclaration: String
  let test: Test
  let testName: String
  private(set) var constraints: [ArgumentConstraint<Test.Arguments>] = []

  static var constraintsLens: SimpleLens<PropertyTest<Test>, [ArgumentConstraint<Test.Arguments>]> {
    return SimpleLens(keyPath: \PropertyTest.constraints)
  }

  init(test: Test, invariant: String, testName: String) {
    self.test = test
    self.invariantDeclaration = invariant
    self.testName = testName
  }

  func withConstraints(that constraintMaker: (ConstraintMaker<Test.Arguments>) -> ([ArgumentConstraint<Test.Arguments>]))
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
                                       testName: testName,
                                       constraints: constraints,
                                       invariant: .returnOnly(predicate),
                                       description: invariantDeclaration)
  }
  
  func proving(that predicate: @escaping (Test.Arguments.TupleRepresentation, Test.Return) -> Bool) -> FinalizedPropertyTest<Test> {
    return FinalizedPropertyTest<Test>(test: test,
                                       testName: testName,
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
  private let testName: String
  fileprivate let constraints: [ArgumentConstraint<Test.Arguments>]
  private let invariant: ProvableInvariant
  private let invariantDescription: String

  fileprivate var config = TestConfig<Test>()

  static var configLens: SimpleLens<FinalizedPropertyTest<Test>, TestConfig<Test>> {
    return SimpleLens(keyPath: \FinalizedPropertyTest.config)
  }

  var configLens: SimpleLens<FinalizedPropertyTest<Test>, TestConfig<Test>> {
    return FinalizedPropertyTest.configLens
  }

  init(test: Test,
       testName: String,
       constraints: [ArgumentConstraint<Test.Arguments>],
       invariant: ProvableInvariant,
       description: String) {
    self.test = test
    self.testName = testName
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
  
  func run(onFailure failure: (String) -> ()) {
    // two orders of magnitude, until we get smarter generation capabilities
    let minimumTests = config.numberOfTests
    let maximumTests = minimumTests * 100 // two orders of magnitude in case constraints are super specific
    let generator = constrainingGenerator(Test.Arguments.gen, with: constraints)
    var testsRan = 0
    for currentTest in (0..<maximumTests) {
      let arguments = generator.getAnother()
      if let error = run(test: test,
                         number: currentTest,
                         with: arguments,
                         and: constraints,
                         proving: invariant,
                         failureReporter: failure) {
        logError(error)
        switch error {
        case .argumentRejectedByConstraint:
          // we skip the `testsRan + 1` line
          continue
        case .returnFailedInvariant(_, let arguments, let invariantDescription):
          log("Minimizing test case...\n", for: .failures)
          let minimizedArguments = minimizeFailingTestCase(arguments: arguments)
          let resultForMinimizedArguments = test.call(with: minimizedArguments)
          failure("\n\nTest \(testName) failed; \(minimizedArguments.asTuple) -> \(resultForMinimizedArguments)"
            + " did not \(invariantDescription)\n\n")
          return
        }
      }
      testsRan += 1
      guard testsRan < minimumTests else {
        log("\n\nTest \(testName) completed successfully", for: .successes)
        return
      }
    }
    let failedToGenerateArgumentsTitle = "\n\nTest \(testName) failed; "
     + "could not generate enough arguments even after \(maximumTests) attempts."
    let failedToGenerateArgumentsMessage = """
    Please consider relaxing your constraints or defining them more specifically; use the `produced(by:)` method on
    an argument to provide your own `Gen` with the existing constraints do not meet your needs.
    """
    failure([failedToGenerateArgumentsTitle, failedToGenerateArgumentsMessage].joined(separator: "\n"))
  }
  
  func minimizeFailingTestCase(arguments: Test.Arguments) -> Test.Arguments {
    return minimizeRecursively(depth: 0, arguments: arguments)
      .random(using: &Xoroshiro.default) ?? arguments
  }
  
  func minimizeRecursively(depth: Int, arguments: Test.Arguments) -> [Test.Arguments] {
    guard depth < 8 else { return [arguments] }
    let minimizer = Minimizer(arguments: arguments, constraints: constraints)
    let minimizedArguments = minimizer.minimize()
    let stillFailingArguments = minimizedArguments
      .filter { arguments in
        let result = test.call(with: arguments)
        return resultPasses(result, with: arguments, against: invariant) == false
      }
    guard stillFailingArguments.isEmpty == false else { return [arguments] }
    let recursiveCalls = stillFailingArguments
      .flatMap { minimizeRecursively(depth: depth + 1, arguments: $0) }
    return recursiveCalls
  }

  private func run(test: Test,
                   number: Int,
                   with arguments: Test.Arguments,
                   and constraints: [ArgumentConstraint<Test.Arguments>],
                   proving provableInvariant: ProvableInvariant,
                   failureReporter: (String) -> ()) -> TestRunError? {
    log("Running \(testName) #\(number)", for: .all)
    log("Generated arguments: \(arguments.asTuple)", for: .all)
    // see if args pass constraints
    let argumentConstraintsResult = argumentsAreRejected(arguments, by: constraints)
    guard case .success(let validArguments) = argumentConstraintsResult else {
      logError(argumentConstraintsResult.error)
      return argumentConstraintsResult.error!
    }
    // pass arguments to function
    log("Calling function \(Test.Arguments.TupleRepresentation.self) -> \(Test.Return.self)", for: .all)
    let result = test.call(with: validArguments)
    log("Produced: \(result)", for: .all)
    let passes = resultPasses(result, with: arguments, against: provableInvariant)
    if passes {
      log("Test \(testName) passed on \(validArguments.asTuple) -> \(result)!", for: .successes)
    } else {
      return TestRunError.returnFailedInvariant(result, arguments, invariantDescription)
    }
    return nil
  }

  private func logError(_ error: TestRunError?) {
    guard let error = error else { return }
    switch error {
    case .argumentRejectedByConstraint(let arguments, let constraint):
      var statement = "\(arguments.asTuple) rejected by constraint"
      if let label = constraint.label {
        statement += " labeled: `\(label)`"
      }
      log(statement, for: .all)
    case .returnFailedInvariant(let result, let arguments, let invariantDescription):
      log("Test \(testName) failed; \(arguments.asTuple) returned \(result) which did not \(invariantDescription)", for: .failures)
    }
  }

  private func constrainingGenerator(_ gen: Gen<Test.Arguments>, with constraints: [ArgumentConstraint<Test.Arguments>])
    -> Gen<Test.Arguments> {
      return constraints
        .map { $0.generatorConstraint }
        .reduce(gen, { $1 |> $0.selfMap })
  }

  private func argumentsAreRejected(_ arguments: Test.Arguments, by constraints: [ArgumentConstraint<Test.Arguments>])
    -> Result<Test.Arguments, TestRunError> {
    for constraint in constraints {
      let isRejected = constraint.rejector(arguments)
      if isRejected { return Result(error: .argumentRejectedByConstraint(arguments, constraint))
      }
      continue
    }
    return Result(value: arguments)
  }
  
  enum TestRunError: Error {
    case argumentRejectedByConstraint(Test.Arguments, ArgumentConstraint<Test.Arguments>)
    case returnFailedInvariant(Test.Return, Test.Arguments, String)
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
