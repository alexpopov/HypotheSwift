//
//  Constraint.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation

class SingleArgumentConstraint<T>: ConstraintProtocol {
  
  var constraint: SingleValueConstraint<T> = .incomplete
  
  func not(_ some: T) {
    self.constraint = .not(some)
  }
  
  func not(_ predicate: @escaping (T) -> Bool) {
    self.constraint = .noneMatching(predicate)
  }
}

class MultiArgumentConstraint<Arguments: ArgumentEnumerable>: ConstraintProtocol {
  var constraint: MultiValueConstraint<Arguments> = .incomplete
  
  func not(_ combination: Arguments.TupleRepresentation) {
    self.constraint = .not(combination)
  }
  
  func not(_ predicate: @escaping (Arguments.TupleRepresentation) -> Bool) {
    self.constraint = .noneMatching(predicate)
  }
  
}

extension ConstraintMaker where Arguments: SupportsOneArgument {
  var first: SingleArgumentConstraint<Arguments.FirstArgument> {
    let constraint = SingleArgumentConstraint<Arguments.FirstArgument>()
    constraints.append(constraint)
    return constraint
  }
}

extension ConstraintMaker where Arguments: SupportsTwoArguments {
  
  var second: SingleArgumentConstraint<Arguments.SecondArgument> {
    let constraint = SingleArgumentConstraint<Arguments.SecondArgument>()
    constraints.append(constraint)
    return constraint
  }
  
  var all: MultiArgumentConstraint<Arguments> {
    let constraint = MultiArgumentConstraint<Arguments>()
    constraints.append(constraint)
    return constraint
  }
  
}

protocol ConstraintProtocol {
  
}

enum SingleValueConstraint<T>: ConstraintProtocol {
  case incomplete
  case not(T)
  case noneMatching((T) -> Bool)
}

enum MultiValueConstraint<Arguments: ArgumentEnumerable>: ConstraintProtocol {
  case incomplete
  case not(Arguments.TupleRepresentation)
  case noneMatching((Arguments.TupleRepresentation) -> Bool)
  case enforce((Arguments.TupleRepresentation) -> Bool)
}

protocol ConstraintExtendable {
  associatedtype Value
  
  var value: Value { get }

  func zip<C>(_ other: C) -> SingleConstraint<(Value, C.Value)>
    where C: ConstraintExtendable
}

struct SingleConstraint<Value>: ConstraintExtendable {

  let value: Value
  
  func zip<C>(_ other: C) -> SingleConstraint<(Value, C.Value)> where C : ConstraintExtendable {
    return SingleConstraint<(Value, C.Value)>(value: (value, other.value))
  }
  
  func map<T>(_ transform: (Value) -> T) -> SingleConstraint<T> {
    return SingleConstraint<T>(value: transform(value))
  }

}
