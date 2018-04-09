//
//  MultiArgumentConstraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation
import Prelude

public struct MultiArgumentConstraint<Arguments> where Arguments: ArgumentEnumerable {
  
  public func not(_ combination: Arguments.TupleRepresentation) -> ArgumentConstraint<Arguments> {
    let rejector = { $0 == Arguments(tuple: combination) }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
  public func not(_ predicate: @escaping (Arguments.TupleRepresentation) -> Bool) -> ArgumentConstraint<Arguments> {
    let rejector: (Arguments) -> Bool = { $0.asTuple |> predicate }
    return ArgumentConstraint(rejector: rejector, generatorConstraint: id)
  }
  
}

