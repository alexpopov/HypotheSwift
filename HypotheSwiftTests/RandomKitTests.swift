//
//  RandomKitTests.swift
//  HypotheSwiftTests
//
//  Created by Alex Popov on 2018-04-09.
//

import XCTest
import RandomKit
import HypotheSwift

class RandomKitTests: XCTestCase {
  
  func testRandomStringLength() {
    testThat({ (int: Int) -> String in return String.random(ofLength: int, using: &Xoroshiro.default)},
             will: "always produce a string of the specified length")
      .withConstraint(that: { $0.firstArgument.must(beIn: 0...200) })
      .proving(that: { $1.count == $0 })
      .minimizeFailingCases(false)
      .minimumNumberOfTests(count: 10000)
      .continueAfterFailure()
      .run(onFailure: fail)
  }
  
  func testRandomIntegerInRange() {
    testThat({ Int.random(in: (0...$0), using: &Xoroshiro.default) }, will: "produce integers in range")
      .withConstraint(that: { $0.firstArgument.must(beIn: (0...1_000)) })
      .proving(that: { (0...$0).contains($1) })
      .minimizeFailingCases(false)
      .minimumNumberOfTests(count: 10_000)
      .continueAfterFailure()
      .run(onFailure: fail)
  }
  
  func testQuickSort() {
    testThat(specialize(quicksort, as: [Int].self), will: "work twice")
      .proving { self.quicksort($0) == $0 }
      .minimizeFailingCases(false)
      .continueAfterFailure()
      .minimumNumberOfTests(count: 100)
      .run(onFailure: fail)
  }
  
  func quicksort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }
    
    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    
    // Uncomment this following line to see in detail what the
    // pivot is in each step and how the subarrays are partitioned.
    //print(pivot, less, equal, greater)  return quicksort(less) + equal + quicksort(greater)
    return quicksort(less) + equal + quicksort(greater)
  }
}
