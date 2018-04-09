//
//  GenTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-08.
//

import XCTest
@testable import HypotheSwift
import Prelude

class GenTests: XCTestCase {
  
  func testTwoGensDontGenerateSameValues() {
    testThat({ (count: Int) -> ([Int], [Int]) in
      let leftGen = Int.gen
      let rightGen = Int.gen
      let leftGenerated = (0..<count).map { _ in leftGen.getAnother() }
      let rightGenerated = (0..<count).map { _ in rightGen.getAnother() }
      return (leftGenerated, rightGenerated)
    }, will: "not create the same values given two different generators")
      .withConstraint(that: {
        $0.firstArgument.must(beIn: (10...20))
      })
      .proving { $0 != $1 }
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func testSameGenDoesntGenerateSameValues() {
    testThat({ (count: Int) -> ([Int], [Int]) in
      let gen = Int.gen
      let leftGenerated = (0..<count).map { _ in gen.getAnother() }
      let rightGenerated = (0..<count).map { _ in gen.getAnother() }
      return (leftGenerated, rightGenerated)
    }, will: "not create the same values on the same generator" )
      .withConstraint(that: { $0.firstArgument.must(beIn: (10...20)) })
      .proving(that: (!=))
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func testRangeConstraintsWork() {
    let range = (10...20)
    testThat(specialize(id, as: Int.self), will: "only create values within the range constraint")
      .withConstraint(that: { $0.firstArgument.must(beIn: range) })
      .proving(that: { range.contains($0) })
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func testMustConstraintWillBeMet() {
    let valueToSet = 5
    testThat(specialize(id, as: Int.self), will: "always produce 5")
      .withConstraint(that: { $0.firstArgument.must(be: valueToSet) })
      .proving(that: { $0 == valueToSet })
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func testLastRangeConstraintWillBeMet() {
    let goodRange = (10...20)
    let badRange = (0..<9)
    testThat(specialize(id, as: Int.self), will: "only create values")
      .withConstraints(that: {
        [
          $0.firstArgument.must(beIn: badRange),
          $0.firstArgument.must(beIn: goodRange)
        ]
      })
      .proving(that: { goodRange.contains($0) })
      .run(onFailure: fail)
  }
  
  func testSingleValueNotConstraintWillBeMet() {
    let skipValue = false
    testThat(specialize(id, as: Bool.self), will: "never create the skipValue")
      .withConstraint(that: { $0.firstArgument.not(skipValue) })
      .proving(that: { $0 != skipValue })
      .run(onFailure: fail)
  }
  
  func testPredicatedConstraintWillBeMet() {
    let isEven: (Int) -> Bool = { return $0 % 2 == 0 }
    testThat(specialize(id, as: Int.self), will: "only produce odd values")
      .withConstraint(that: { $0.firstArgument.not(isEven) })
      .proving(that: { isEven($0) == false })
      .run(onFailure: fail)
  }
  
  func testFailOnImpossibleConstraints() {
    let isFalse: (Bool) -> Bool = { return $0 == false }
    let isTrue = specialize(id, as: Bool.self)
    testThat(specialize(id, as: Bool.self), will: "fail")
      .withConstraints(that: {
        [
          $0.firstArgument.not(isFalse).labeled("cannot be false"),
          $0.firstArgument.not(isTrue).labeled("cannot be true")
        ]
      })
      .proving(that: { _ in return true })
      .run(onFailure: fail)
    
  }

}
