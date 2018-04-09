//
//  PropertyTestConvenience.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-08.
//

import Foundation
import Prelude

// MARK: - Unary Functions
public func testThat<T, R>(_ function: @escaping (T) -> R,
                           will invariant: String,
                           testName: String = #function) -> PropertyTest<UnaryFunction<T, R>>
  where T: ArgumentType {
    let unaryTest = UnaryFunction(function)
    return PropertyTest(test: unaryTest, invariant: invariant, testName: testName)
}

public func testThat<T, R>(_ function: @escaping (T) -> () -> R,
                           will invariant: String,
                           testName: String = #function)
  -> PropertyTest<UnaryFunction<T, R>> where T: ArgumentType {
    let unaryTest = UnaryFunction<T, R>({ t in function(t)() })
    return PropertyTest(test: unaryTest, invariant: invariant, testName: testName)
}

// MARK: - Binary Functions

public func testThat<T, U, R>(_ function: @escaping (T, U) -> R,
                              will invariant: String,
                              testName: String = #function)
  -> PropertyTest<BinaryFunction<T, U, R>> {
    let binaryTest = BinaryFunction(function)
    return PropertyTest(test: binaryTest, invariant: invariant, testName: testName)
}

public func testThat<T, U, R>(_ function: @escaping (T) -> (U) -> R,
                              will invariant: String,
                              testName: String = #function)
  -> PropertyTest<BinaryFunction<T, U, R>> {
    let binaryTest = BinaryFunction({ t, u in function(t)(u) })
    return PropertyTest(test: binaryTest, invariant: invariant, testName: testName)
}

// MARK: - Ternary Functions

public func testThat<T, U, V, R>(_ function: @escaping (T, U, V) -> R,
                              will invariant: String,
                              testName: String = #function)
  -> PropertyTest<TernaryFunction<T, U, V, R>> {
    let ternaryTest = TernaryFunction(function)
    return PropertyTest(test: ternaryTest, invariant: invariant, testName: testName)
}

public func testThat<T, U, V, R>(_ function: @escaping (T) -> (U, V) -> R,
                                 will invariant: String,
                                 testName: String = #function)
  -> PropertyTest<TernaryFunction<T, U, V, R>> {
    let ternaryTest = TernaryFunction({ t, u, v in function(t)(u, v) })
    return PropertyTest(test: ternaryTest, invariant: invariant, testName: testName)
}

// MARK: - Quaternary Functions

public func testThat<T, U, V, W, R>(_ function: @escaping (T, U, V, W) -> R,
                                 will invariant: String,
                                 testName: String = #function)
  -> PropertyTest<QuaternaryFunction<T, U, V, W, R>> {
    let quaternaryTest = QuaternaryFunction(function)
    return PropertyTest(test: quaternaryTest, invariant: invariant, testName: testName)
}

public func testThat<T, U, V, W, R>(_ function: @escaping (T) -> (U, V, W) -> R,
                                    will invariant: String,
                                    testName: String = #function)
  -> PropertyTest<QuaternaryFunction<T, U, V, W, R>> {
    let quaternaryTest = QuaternaryFunction({ t, u, v, w in function(t)(u, v, w) })
    return PropertyTest(test: quaternaryTest, invariant: invariant, testName: testName)
}

// MARK: - Generic Specialization

public func specialize<T, R>(_ function: @escaping (T) -> R, as: T.Type) -> (T) -> R {
  return function
}

public func specialize<T, U, R>(_ function: @escaping (T, U) -> R, as: (T.Type, U.Type)) -> (T, U) -> R {
  return function
}

public func specialize<T, U, V, R>(_ function: @escaping (T, U, V) -> R,
                                   as: (T.Type, U.Type, V.Type)) -> (T, U, V) -> R {
  return function
}

public func specialize<T, U, V, W, R>(_ function: @escaping (T, U, V, W) -> R,
                                      as: (T.Type, U.Type, V.Type, W.Type)) -> (T, U, V, W) -> R {
  return function
}
