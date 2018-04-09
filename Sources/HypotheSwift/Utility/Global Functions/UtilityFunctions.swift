//
//  UtilityFunctions.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-06.
//

import Foundation
import Prelude

// 2 + 1
func flattenTuple<T, U, V>(_ tuple: ((T, U), V)) -> (T, U, V) {
  return (tuple.0.0, tuple.0.1, tuple.1)
}

// 3 + 1
func flattenTuple<T, U, V, W>(_ tuple: ((T, U, V), W)) -> (T, U, V, W) {
  return (tuple.0.0, tuple.0.1, tuple.0.2, tuple.1)
}

func always<T, U>(_ just: U) -> (T) -> U {
  return { _ in just }
}
