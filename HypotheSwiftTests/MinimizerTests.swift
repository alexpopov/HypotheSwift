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

  func testFailStringMinimizationWorks() {
    let test: (OneArgument<String>) -> Bool = {
      MinimizerTests.brokenStringReverser(input: $0.firstArgument) == String($0.firstArgument.reversed())
    }
    let minimizer: (String) -> OneArgument<String> = {
      let minimizer = Minimizer<OneArgument<String>>(test: test, arguments: OneArgument(tuple: $0), constraints: [], maxDepth: 4)
      return minimizer.minimize()
    }
    testThat(minimizer, will: "find a minimized case with 3 characters or less")
      .withConstraint(that: {
        $0.firstArgument.randomized(by: { $0.random(using: &Xoroshiro.default) + "f" })
      })
      .proving(that: { $0.firstArgument.count <= 3 })
      .run(onFailure: fail)
  }

  func testFailStringMinimizationWorksOnLargeStrings() {
    testThat(MinimizerTests.minimizerCreator, will: "generate a sufficiently small minimized case")
      .withConstraint(that: { constraintMaker in
        constraintMaker.firstArgument.randomized(by: { string in
          return string.random(ofLength: 100, using: &Xoroshiro.default)
        })
      })
      .proving(that: { $0.firstArgument.minimizationSize <= 5 })
      .run(onFailure: fail)
  }

  private static func brokenStringReverser(input: String) -> String {
    if input.contains("f") {
      return input
    } else {
      return String(input.reversed())
    }
  }

  private static func minimizerCreator(argument: String) -> OneArgument<String> {
    let test: (OneArgument<String>) -> Bool = {
      brokenStringReverser(input: $0.firstArgument) == String($0.firstArgument.reversed())
    }
    let minimizer = Minimizer<OneArgument<String>>(test: test,
                                                   arguments: OneArgument(tuple: argument),
                                                   constraints: [],
                                                   maxDepth: 4)
    return minimizer.minimize()
  }

}
