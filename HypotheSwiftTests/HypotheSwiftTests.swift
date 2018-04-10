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
    testThat(helper.unaryFunctionAddingOne, will: "always be positive for non-negative inputs")
      .withConstraint {
        $0.firstArgument.must(beIn: (0...Int.max))
      }
      .proving(that: { $0 > 0 })
      .minimumNumberOfTests(count: 10)
      .run(onFailure: fail)
  }
  
  func testMeasureUnaryAdditionWithoutHypotheSwift() {
    self.measure {
      for count in (0..<1000) {
        helper.unaryFunctionAddingOne(count)
      }
    }
  }
  
  func testMeasureUnaryAdditionWithHypotheSwift() {
    self.measure {
      testThat(helper.unaryFunctionAddingOne, will: "always be positive for non-negative inputs")
        .withConstraint {
          $0.firstArgument.must(beIn: (0...1000))
        }
        .proving(that: { $0 > 0 })
        .minimumNumberOfTests(count: 1000)
        .run(onFailure: fail)
    }
  }
  
  func testMeasureUnaryAdditionWithoutHypotheSwiftOnce() {
    self.measure {
      for count in (0..<1) {
        _ = helper.unaryFunctionAddingOne(count)
      }
    }
  }
  
  func testMeasureSortingFunctionWithoutHypotheSwift() {
    self.measure {
      for count in (0..<100) {
        let array = [Int](randomCount: 100, in: (0..<1000), using: &Xoroshiro.default)
        let sortedArray = array.sorted()
        XCTAssertEqual(sortedArray, sortedArray.sorted())
      }
    }
  }
  
  func testMeasureSortingFunctionWithHypotheSwift() {
    self.measure {
      testThat(Array<Int>.sorted, will: "produce an identical array if sorted again")
        .withConstraint(that: {
          $0.firstArgument.produced(by: Gen(generator: {
            return [Int](randomCount: 100, in: (0..<1000), using: &Xoroshiro.default)
          }))
        })
        .proving { $0.sorted() == $0 }
        .minimumNumberOfTests(count: 100)
        .run(onFailure: fail)
    }
  }
  
  func testMeasureSortingFunctionWithoutHypotheSwiftThousand() {
    self.measure {
      for count in (0..<1000) {
        let array = [Int](randomCount: 100, in: (0..<1000), using: &Xoroshiro.default)
        let sortedArray = array.sorted()
        XCTAssertEqual(sortedArray, sortedArray.sorted())
      }
    }
  }
  
  func testMeasureSortingFunctionWithHypotheSwiftThousand() {
    self.measure {
      testThat(Array<Int>.sorted, will: "produce an identical array if sorted again")
        .withConstraint(that: {
          $0.firstArgument.produced(by: Gen(generator: {
            return [Int](randomCount: 100, in: (0..<1000), using: &Xoroshiro.default)
          }))
        })
        .proving { $0.sorted() == $0 }
        .minimumNumberOfTests(count: 1000)
        .run(onFailure: fail)
    }
  }

  
  func testMeasureUnaryAdditionWithHypotheSwiftOnce() {
    self.measure {
      testThat(helper.unaryFunctionAddingOne, will: "always be positive for non-negative inputs")
        .withConstraint {
          $0.firstArgument.must(beIn: (0...1000))
        }
        .proving(that: { $0 > 0 })
        .minimumNumberOfTests(count: 1)
        .run(onFailure: fail)
    }
  }
  func testBinaryFunctionReturns() {
    testThat(self.helper.additionFunction, will: "make the result bigger than, or equal to, the original two arguments")
      .withConstraints {
        [
          $0.firstArgument.must(beIn: (0...100)),
          $0.secondArgument.must(beIn: (0...100))
        ]
      }
      .proving { arguments, result in
        let firstIsSmaller = arguments.0 <= result
        let secondIsSmaller = arguments.1 <= result
        return firstIsSmaller && secondIsSmaller
      }
      .minimumNumberOfTests(count: 1000)
      .run(onFailure: fail)
  }
  
  func testArrayReverse() {
    testThat(Array<Int>.reversed, will: "produce an identical array when reversed again")
      .proving(that: { initialArray, reversedArray in reversedArray.reversed() == initialArray })
      .minimumNumberOfTests(count: 1000)
      .run(onFailure: { XCTFail($0) })
  }
  
  func testStringReverse() {
    testThat(String.reversed, will: "produce an identical string when reversed again")
      .withConstraint(that: {
        $0.firstArgument.randomized(by: { $0.random(from: "abc", using: &Xoroshiro.default) ?? "abc" })
      })
      .proving { (initialString, reversedString) -> Bool in
        return String(reversedString.reversed()) == initialString
      }
      .minimumNumberOfTests(count: 100)
      .run(onFailure: { XCTFail($0) })
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
