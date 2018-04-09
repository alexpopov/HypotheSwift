//
//  MinimizerTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-09.
//

import XCTest
@testable import HypotheSwift

class MinimizerTests: XCTestCase {

  func testFailStringMinimizationWorks() {
    testThat(MinimizerTests.brokenStringReverser(input:), will: "always properly reverse the string")
      .proving(that: { arguments, result in return String(result.reversed()) == arguments })
      .minimizeFirstArgumentIfPossible()
      .run(onFailure: fail)
  }

  private static func brokenStringReverser(input: String) -> String {
    if input.contains("f") {
      return input
    } else {
      return String(input.reversed())
    }
  }

}
