//
//  ValueConstraintManager.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-03.
//

import Foundation
import Prelude
import Result
import RandomKit

public struct PropertyTest<Test: Function> {

  typealias Arguments = Test.Arguments

  private let invariantDeclaration: String
  private let test: Test
  private let testName: String
  private var constraints: [ArgumentConstraint<Test.Arguments>] = []

  private static var constraintsLens: SimpleLens<PropertyTest<Test>, [ArgumentConstraint<Test.Arguments>]> {
    return SimpleLens(keyPath: \PropertyTest.constraints)
  }

  internal init(test: Test, invariant: String, testName: String) {
    self.test = test
    self.invariantDeclaration = invariant
    self.testName = testName
  }

  public func withConstraints(that constraintMaker: (ConstraintMaker<Test.Arguments>) -> ([ArgumentConstraint<Test.Arguments>]))
    -> PropertyTest<Test> {
      let constraints = ConstraintMaker<Test.Arguments>() |> constraintMaker
      return PropertyTest.constraintsLens.set(self, constraints)
  }

  public func withConstraint(that constraintMaker: (ConstraintMaker<Test.Arguments>) -> ArgumentConstraint<Test.Arguments>)
    -> PropertyTest<Test> {
      let newConstraint = ConstraintMaker<Test.Arguments>() |> constraintMaker
      return PropertyTest.constraintsLens.over { $0.appending(newConstraint) }
        <| self
  }
  
  public func proving(that predicate: @escaping (Test.Return) -> Bool) -> RunnablePropertyTest<Test> {
    return RunnablePropertyTest<Test>(test: test,
                                       testName: testName,
                                       constraints: constraints,
                                       invariant: .returnOnly(predicate),
                                       description: invariantDeclaration)
  }
  
  public func proving(that predicate: @escaping (Test.Arguments.TupleRepresentation, Test.Return) -> Bool) -> RunnablePropertyTest<Test> {
    return RunnablePropertyTest<Test>(test: test,
                                       testName: testName,
                                       constraints: constraints,
                                       invariant: .all(predicate),
                                       description: invariantDeclaration)
  }

}
