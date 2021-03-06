//
//  MinimizerTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-09.
//

import XCTest
@testable import HypotheSwift
import RandomKit

class MinimizerTests: XCTestCase {

  func testStringMinimizationWorks() {
    testThat(MinimizerTests.stringMinimizerCreator, will: "find a minimized case with 3 characters or less")
      .withConstraint(that: {
        $0.firstArgument.randomized(by: { $0.random(using: &Xoroshiro.default) + "f" })
      })
      .proving(that: { $0.firstArgument.count <= 2 })
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func testMeaseStringMinimization10() {
    self.measure {
      testThat(MinimizerTests.stringMinimizerCreator, will: "find a minimized case with 3 characters or less")
        .withConstraint(that: {
          $0.firstArgument.randomized(by: { $0.random(using: &Xoroshiro.default) + "f" })
        })
        .proving(that: { $0.firstArgument.count <= 2 })
        .minimumNumberOfTests(count: 1)
        .run(onFailure: fail)
    }
  }
  
  func testMeaseStringMinimization100() {
    self.measure {
      testThat(MinimizerTests.stringMinimizerCreator, will: "find a minimized case with 3 characters or less")
        .withConstraint(that: {
          $0.firstArgument.randomized(by: { $0.random(ofLength: 100, using: &Xoroshiro.default) + "f" })
        })
        .proving(that: { $0.firstArgument.count <= 4 })
        .minimumNumberOfTests(count: 1)
        .run(onFailure: fail)
    }
  }

  func testMeaseStringMinimization1000() {
    self.measure {
      testThat(MinimizerTests.stringMinimizerCreator, will: "find a minimized case with 3 characters or less")
        .withConstraint(that: {
          $0.firstArgument.randomized(by: { $0.random(ofLength: 1000, using: &Xoroshiro.default) + "f" })
        })
        .proving(that: { $0.firstArgument.count <= 4 })
        .minimumNumberOfTests(count: 1)
        .run(onFailure: fail)
    }
  }
  
  func testStringMinimizationWorksOnLargeStrings() {
    testThat(MinimizerTests.stringMinimizerCreator, will: "generate a sufficiently small minimized case")
      .withConstraint(that: { constraintMaker in
        constraintMaker.firstArgument.randomized(by: { string in
          return string.random(using: &Xoroshiro.default) + "f"
        })
          .labeled("Random 100-length strings with the letter appended 'f'")
      })
      .proving(that: { $0.firstArgument.minimizationSize <= 5 })
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func testStringMinimizationPercentages() {
    var in2 = 0
    var in3 = 0
    var in4 = 0
    testThat(MinimizerTests.stringMinimizerCreator, will: "generate a sufficiently small minimized case")
      .withConstraint(that: { constraintMaker in
        constraintMaker.firstArgument.randomized(by: { string in
          return string.random(ofLength: 49, using: &Xoroshiro.default) + "f"
        })
          .labeled("Random 100-length strings with the letter appended 'f'")
      })
      .proving(that: {
        if $0.firstArgument.count <= 2 {
          in2 += 1
        }
        if $0.firstArgument.count <= 3 {
          in3 += 1
        }
        if $0.firstArgument.count <= 4 {
          in4 += 1
        }
        return $0.firstArgument.count <= 2
      })
      .minimumNumberOfTests(count: 5000)
      .log(level: .none)
      .minimizeFailingCases(false)
      .continueAfterFailure()
      .run(onFailure: fail)
    NSLog("In 2: \(in2), In3: \(in3), In4: \(in4)")
  }
  
  func testGeneratorConstraintsRespected() {
    let range = (32...100)
    testThat(MinimizerTests.integerMinimizerCreator(left:right:), will: "keep its minimized arguments between 33 and 1000")
      .withConstraints {
        [
          $0.firstArgument.must(beIn: range),
          $0.secondArgument.must(beIn: range)
        ]
      }
      .proving(that: {
        let firstInRange = range.contains($0.firstArgument)
        let secondInRange = range.contains($0.secondArgument)
        return firstInRange && secondInRange
      })
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }

  private static func brokenStringReverser(input: String) -> String {
    if input.contains("f") {
      return input
    } else {
      return String(input.reversed())
    }
  }

  private static func stringMinimizerCreator(argument: String) -> OneArgument<String> {
    let test: (OneArgument<String>) -> Bool = {
      brokenStringReverser(input: $0.firstArgument) == String($0.firstArgument.reversed())
    }
    let constraint = ConstraintMaker<OneArgument<String>>().firstArgument.must(meet: { $0.contains("f") })
    let minimizer = Minimizer<OneArgument<String>>(test: test,
                                                   arguments: OneArgument(tuple: argument),
                                                   constraints: [constraint],
                                                   maxDepth: 4)
    return minimizer.minimize()
  }
  
  private static func brokenAddition(left: Int, right: Int) -> Int {
    if left > 30 || left < 50 {
      return left + right + 1
    } else {
      return left + right
    }
  }
  
  private static func integerMinimizerCreator(left: Int, right: Int) -> TwoArguments<Int, Int> {
    let test: (TwoArguments<Int, Int>) -> Bool = {
      brokenAddition(left: $0.firstArgument, right: $0.secondArgument) == $0.firstArgument + $0.secondArgument
    }
    let constraintMaker = ConstraintMaker<TwoArguments<Int, Int>>()
    let constraints = [
      constraintMaker.firstArgument.must(beIn: (32...100)).labeled("first arg 32...100"),
      constraintMaker.secondArgument.must(beIn: (32...100)).labeled("Second arg 32...100")
    ]
    let minimizer = Minimizer<TwoArguments<Int, Int>>(test: test,
                                                      arguments: TwoArguments(tuple: (left, right)),
                                                      constraints: constraints,
                                                      maxDepth: 4,
                                                      logLevel: .none)
    return minimizer.minimize()
  }

}
