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
        $0.first.must(beIn: (0...Int.max))
      }
      .proving(that: { $0 > 0 })
      .log()
      .minimumNumberOfTests(count: 10)
      .run()
  }
  
  func testBinaryFunctionReturns() {
    testThat(helper.binaryFunctionAdd, will: """
        Make the result bigger than the original two arguments
      """)
      .withConstraints {
        [
          $0.first.must(beIn: (0...100)),
          $0.second.must(beIn: (0...100))
        ]
      }
      .proving { arguments, result in
        let firstIsSmaller = arguments.0 < result
        let secondIsSmaller = Int(arguments.1) < result
        return firstIsSmaller && secondIsSmaller
      }
      .minimumNumberOfTests(count: 10)
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
