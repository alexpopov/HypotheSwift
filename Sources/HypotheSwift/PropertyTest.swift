//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude

func testThat<T, R>(_ function: @escaping (T) -> R, will invariant: String)
  -> PropertyTest<UnaryFunction<T, R>>
  where T: ArgumentType {
    let unaryTest = UnaryFunction(function)
    return PropertyTest(test: unaryTest, invariant: invariant)
}

protocol Constrainable {
  associatedtype Arguments: ArgumentEnumerable
}

extension Constrainable where Arguments: SupportsOneArgument {
  func assumingFirst(not value: Arguments.FirstArgument) -> Self {
    print("First argument will never be \(value)")
  }
}

extension Constrainable where Arguments: SupportsSecondArgument {
  func assumingSecond(not value: Arguments.SecondArgument) -> Self {
    print("Second argument will never be \(value)")
  }
}

struct PropertyTest<Test: Function>: Constrainable {

  typealias Arguments = Test.Arguments

  let invariantDeclaration: String
  let test: Test

  init(test: Test, invariant: String) {
    self.test = test
    self.invariantDeclaration = invariant
  }

}
