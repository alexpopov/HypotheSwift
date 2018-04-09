//
//  RunnablePropertyTest.swift
//  HypotheSwift iOS
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation
import Prelude
import Result

// MARK: - Runnable Property Test
public struct RunnablePropertyTest<Test: Function> {
  
  // MARK: Internal State
  private let test: Test
  private let testName: String
  private let constraints: [ArgumentConstraint<Test.Arguments>]
  private let invariant: ProvableInvariant
  private let invariantDescription: String
  
  private var config = TestConfig()
  
  private static var configLens: SimpleLens<RunnablePropertyTest<Test>, TestConfig> {
    return SimpleLens(keyPath: \RunnablePropertyTest.config)
  }
  
  private var configLens: SimpleLens<RunnablePropertyTest<Test>, TestConfig> {
    return RunnablePropertyTest.configLens
  }
  
  // MARK: Init
  internal init(test: Test,
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
  
  // MARK: Public Mutation Functions
  
  public func log(level: LoggingLevel = .failures) -> RunnablePropertyTest<Test> {
    return RunnablePropertyTest.configLens.looking(at: TestConfig.loggingLevelLens).set(self, level)
  }
  
  public func minimumNumberOfTests(count: Int) -> RunnablePropertyTest<Test> {
    return configLens.looking(at: TestConfig.numberOfTestsLens).set(self, count)
  }
  
  public func maximumMinimalizationDepth(recurse times: Int) -> RunnablePropertyTest<Test> {
    return configLens.looking(at: TestConfig.maximumMinimizationLevelLens).set(self, times)
  }
  
  public func continueAfterFailure() -> RunnablePropertyTest<Test> {
    return configLens.looking(at: TestConfig.continueAfterFailureLens).set(self, true)
  }
  
  public func minimizeFailingCases(_ shouldMinimize: Bool) -> RunnablePropertyTest<Test> {
    return configLens.looking(at: TestConfig.shouldMinimizeLens).set(self, shouldMinimize)
  }
  
  // MARK: - Run Tests
  
  public func run(onSuccess: (String) -> ()) {
    if run(onFailure: { _ in }) {
      onSuccess("\(testName) did not fail to \(invariantDescription)")
    }
  }
  
  @discardableResult
  public func run(onFailure failure: (String) -> ()) -> Bool {
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
          // we skip the `testsRan + 1` line and go
          continue
        case .returnFailedInvariant(_, let arguments, let invariantDescription):
          if config.shouldMinimize {
            let minimizedArguments = minimizeFailingTestCase(arguments: arguments)
            let resultForMinimizedArguments = test.call(with: minimizedArguments)
            failure("\n\nTest \(testName) failed; \(minimizedArguments.asTuple) -> \(resultForMinimizedArguments)"
              + " did not \(invariantDescription)\n\n")
          }
          if config.continueAfterFailure == false {
            return false
          }
        }
      }
      testsRan += 1
      guard testsRan < minimumTests else {
        log("\n\nTest \(testName) completed successfully", for: .successes)
        return true
      }
    }
    let failedToGenerateArgumentsTitle = "\n\nTest \(testName) failed; "
      + "could not generate enough arguments even after \(maximumTests) attempts."
    let failedToGenerateArgumentsMessage = """
    Please consider relaxing your constraints or defining them more specifically; use the `produced(by:)` method on
    an argument to provide your own `Gen` with the existing constraints do not meet your needs.
    """
    failure([failedToGenerateArgumentsTitle, failedToGenerateArgumentsMessage].joined(separator: "\n"))
    return false
  }
  
  // MARK: - Private Functions

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
  
  private func minimizeFailingTestCase(arguments: Test.Arguments) -> Test.Arguments {
    log("Minimizing test case...\n", for: .failures)
    let test: (Test.Arguments) -> Bool = { generatedArguments in
      return self.resultPasses(self.test.call(with: generatedArguments),
                               with: generatedArguments,
                               against: self.invariant)
    }
    return Minimizer(test: test,
                     arguments: arguments,
                     constraints: constraints,
                     maxDepth: config.maximumMinimizationLevel)
      .minimize()
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
  
  private enum TestRunError: Error {
    case argumentRejectedByConstraint(Test.Arguments, ArgumentConstraint<Test.Arguments>)
    case returnFailedInvariant(Test.Return, Test.Arguments, String)
  }
  
  private func resultPasses(_ result: Test.Return,
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
  
  internal enum ProvableInvariant {
    case returnOnly((Test.Return) -> Bool)
    case all((Test.Arguments.TupleRepresentation, Test.Return) -> Bool)
  }
  
}
