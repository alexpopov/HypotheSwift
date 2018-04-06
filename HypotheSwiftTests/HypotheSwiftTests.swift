//
//  HypotheSwiftTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-03.
//

import XCTest
@testable import HypotheSwift
import RandomKit

class HypotheSwiftTests: XCTestCase {

  let helper = TestsHelper()

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testUnaryFunctionReturningTwo() {
    testThat(helper.unaryFunctionAddingOne, will: """
      always be positive for non-negative inputs
    """)
      .withConstraint {
        $0.firstArgument.must(beIn: (0...Int.max))
      }
      .proving(that: { $0 > 0 })
      .log(level: .failures)
      .minimumNumberOfTests(count: 10)
      .run()
  }
  
  func testBinaryFunctionReturns() {
    self.measure {
      testThat(self.helper.additionFunction, will: """
        Make the result bigger than the original two arguments
      """)
        .withConstraints {
          [
            $0.firstArgument.must(beIn: (1...100)),
            $0.secondArgument.must(beIn: (1...100))
          ]
        }
        .proving { arguments, result in
          let firstIsSmaller = arguments.0 < result
          let secondIsSmaller = arguments.1 < result
          return firstIsSmaller && secondIsSmaller
        }
        .minimumNumberOfTests(count: 1000)
        .log(level: .failures)
        .run()
    }
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}

class TestsHelper {
  func unaryFunctionAddingOne(_ addTo: Int) -> Int {
    return addTo + 1
  }
  
  func additionFunction(_ left: Int, right: Int) -> Int {
    return left + right
  }
}
