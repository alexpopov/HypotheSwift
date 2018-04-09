//
//  FunctionTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-08.
//

import XCTest
@testable import HypotheSwift
import Prelude

extension XCTestCase {
  func fail(_ message: String) {
    XCTFail(message)
  }

  func succeed(_ message: String) {
    XCTAssertTrue(true, message)
  }
}

class FunctionTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testUnaryIdentityFunctionReturnsSame() {
    let unaryFunction = UnaryFunction<Int, Int>.init(FunctionTests.unaryIdentityFunction).function
    testThat(unaryFunction, will: "return the same thing as the original function when given the same argument")
      .proving(that: { args, result in
        FunctionTests.unaryIdentityFunction(identity: args) == result
      })
      .run(onFailure: fail)
  }
  
  static func unaryIdentityFunction<T>(identity: T) -> T {
    return identity
  }
  
  func testBinaryIdentityFunctionReturnsSame() {
    let binaryFunction = BinaryFunction(FunctionTests.binaryAdditionFunction(left:right:)).function
    testThat(binaryFunction, will: "return the same thing as the original function when given the same arguments")
      .withConstraints(that: {
        [
          // prevent overflows
          $0.firstArgument.must(beIn: 0..<Int.max / 2),
          $0.secondArgument.must(beIn: 0..<Int.max / 2)
        ]
      })
      .proving(that: { args, result in
        FunctionTests.binaryAdditionFunction(left: args.0, right: args.1) == result
      })
      .minimumNumberOfTests(count: 10)
      .run(onFailure: fail)
  }

  static func binaryAdditionFunction(left: Int, right: Int) -> Int {
    return left + right
  }
  
  func testTernaryAdditionFunctionReturnsSame() {
    let ternaryFunction = TernaryFunction(FunctionTests.ternaryAdditionFunction).function
    testThat(ternaryFunction, will: "return the same thing as the original function when given the same arguments")
      .proving(that: { args, result in
        FunctionTests.ternaryAdditionFunction(args.0, args.1, args.2) == result
      })
      .minimumNumberOfTests(count: 10)
      .run(onFailure: fail)
  }
  
  static func ternaryAdditionFunction(_ a: Int, _ b: Int, _ c: Int) -> Int {
    return a.addingReportingOverflow(b).partialValue.addingReportingOverflow(c).partialValue
  }
  
  func testQuaternaryAdditionFunctionReturnsSame() {
    let quaternaryFunction = QuaternaryFunction(FunctionTests.quaternaryAdditionFunction).function
    testThat(quaternaryFunction, will: "return the same thing as the original function when given the same arguments")
      .proving(that: { args, result in
        FunctionTests.quaternaryAdditionFunction(args.0, args.1, args.2, args.3) == result
      })
      .minimumNumberOfTests(count: 10)
      .run(onFailure: fail)
  }
  
  static func quaternaryAdditionFunction(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Int {
    return a.addingReportingOverflow(b).partialValue
      .addingReportingOverflow(c).partialValue
      .addingReportingOverflow(d).partialValue
  }
  
  func testUnaryProperlyGeneric() {
    testThat(FunctionTests.unaryFloatToInt, will: "have an integer result and a float argument")
      .proving(that: { _ in true  }) // if this ever stopped compiling, we'd have an issue
      .minimumNumberOfTests(count: 1)
      .run(onFailure: fail)
  }
  
  static func unaryFloatToInt(_ float: Float) -> Int {
    return Int(float)
  }
  
  func testBinaryProperlyGeneric() {
    testThat(FunctionTests.binaryFloatIntAddition, will: "be generic")
      .proving(that: { _ in return true }) // if it compiles, it works
      .minimumNumberOfTests(count: 1)
      .run(onFailure: fail)
  }
  
  static func binaryFloatIntAddition(_ float: Float, _ int: Int) -> Double {
    return Double(float + Float(int))
  }
  
  func testTernaryProperlyGeneric() {
    testThat({ (a: Int, b: Float, c: Double) -> Bool in
      return (a + Int(b) + Int(c)) % 2 == 0
    }, will: "be generic")
      .proving(that: { _ in return true }) // if it compiles, it works
      .minimumNumberOfTests(count: 1)
      .run(onFailure: fail)
  }
  
  func testQuaternaryProperlyGeneric() {
    testThat({ (a: Int, b: Float, c: Double, d: Bool) -> Bool in
      return d
    }, will: "be generic")
      .proving(that: { _ in return true }) // if it compiles, it works
      .minimumNumberOfTests(count: 1)
      .run(onFailure: fail)
  }
  
}
