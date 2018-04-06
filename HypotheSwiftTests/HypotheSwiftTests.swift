//
//  HypotheSwiftTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-03.
//

import XCTest
@testable import HypotheSwift

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
      .createConstraints {
        $0.first.not { $0 < 0 }
      }
      .proving(that: { $0 > 0 })
      .log()
      .minimumNumberOfTests(count: 100)
      .run()
  }
  
  func testBinaryFunctionReturns() {
    testThat(helper.binaryFunctionAdd, will: """
        Make the result bigger than the original two arguments
      """)
      .createConstraints {
        $0.first.not { $0 < 0 }
        $0.second.not { $0 < 0 }
      }
      .proving { (arguments, result) -> Bool in
        let firstArgSmaller = arguments.0 < result
        let secondArgSmaller = Int(arguments.1) < result
        return firstArgSmaller && secondArgSmaller
      }
      .log()
      .run()
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
  
  func binaryFunctionAdd(_ left: Int, right: Float) -> Int {
    return left + Int(right)
  }
}
