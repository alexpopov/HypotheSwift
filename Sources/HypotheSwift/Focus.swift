//
//  Focus.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation
import Prelude

/// Protocol describing an object which provides lenses over its fields.
///
/// You don't have to use lenses but they're more convenient in functional
/// programming.
///
/// Lenses are accessed via the `focus` property.
public protocol FocusExtensionsProvider { }

extension FocusExtensionsProvider {

  /// A proxy which hosts static lens extensions for the type of `self`.
  public static var focus: Focus<Self>.Type {
    return Focus<Self>.self
  }
}

/// Lens-providing proxy on objects.
public struct Focus<Base> {
  public let base: Base

  fileprivate init(_ base: Base) {
    self.base = base
  }
}

public extension Lens where S == T, A == B {
  /// Partially apply the setter.
  ///
  /// - Parameter value: value to set
  ///
  /// - Returns: An automorphism returning a copy with the lens's
  /// field updates to `value`.
  public func partial(for value: A) -> (S) -> S {
    return { a in self.set(a, value) }
  }
}

extension Array {

  /// Provides a lens to a particular index of an Array.
  ///
  /// - Note: for most use-cases `lens(to index:)` is more convenient.
  ///
  /// - Parameter index: Index to provide a lens to.
  ///
  /// - Returns: A Lens to the value in the Array at `index`.
  public static func indexLens(to index: Array.Index) -> ArrayLens<Iterator.Element> {
    return Lens<[Iterator.Element], [Iterator.Element], Iterator.Element, (Iterator.Element, Int)>(get:
      { array in
      return array[index]
    }, set: { (array: [Iterator.Element], elementIndexPair: (Iterator.Element, Int)) in
      return array.updating(elementIndexPair.0, at: elementIndexPair.1)
    })
  }

  /// Provides a lens to a particular index of an Array
  ///
  /// - Parameter index: Index to provide a lens to.
  ///
  /// - Returns: A Lens to the value in the Array at `index`
  public static func lens(to index: Array.Index) -> SimpleLens<[Iterator.Element], Iterator.Element> {
    return indexLens(to: index).applying(index)
  }

}

/// Lens that produces an Array from an Array.
///
/// The setter is an index and an element and the getter is the element at that
/// index.
public typealias ArrayLens<T> = Lens<[T], [T], T, (T, Int)>

public extension Lens where S: RandomAccessCollection, T == S {

  /// Implementation detail of `indexLens` and `lens(to index:)`.
  ///
  /// This applies the index to simplify the lens.
  ///
  /// - Parameter index: Index to apply
  ///
  /// - Returns: A Simple lens that does not require the Index to be specified.
  func applying<Element, Index>(_ index: Index) -> SimpleLens<S, A>
    where Element == S.Element, B == (A, Index) {
      let getter: (S) -> A = { self.get($0) }
      let setter: (S, A) -> S = { self.set($0, ($1, index)) }
      return SimpleLens<S, A>.init(get: getter, set: setter)
  }

}

public extension Lens where A == B, A: RandomAccessCollection & MutableCollection, S == T {
  /// Convenience function to focus in on an element in an Array based on a
  /// search function.
  ///
  /// - Parameter indexOf: Search function which must yield a valid index due
  /// to lens semantics.
  ///
  /// - Returns: A Simple Lens to the element at the received index.
  public func looking(at indexOf: @escaping (A) -> A.Index) -> SimpleLens<S, A.Element> {
    return SimpleLens<S, A.Element>.init(get: { whole in
      let array = self.get(whole)
      let index = indexOf(array)
      return array[index]
    }, set: { whole, part in
      var array = self.get(whole)
      let index = indexOf(array)
      array[index] = part
      return self.set(whole, array)
    })
  }

  /// Convenience function to focus in on an element in an Array at a particular
  /// index.
  ///
  /// - Parameter index: Index to focus in on.
  ///
  /// - Returns: A Simple Lens focusing in on the element at the Index.
  public func looking(at index: A.Index) -> SimpleLens<S, A.Element> {
    return looking(at: { _ in index })
  }
}

extension Lens {
  /// Composes a Lens with the receiver.
  public func looking<X, Y>(at other: Lens<Target, AltTarget, X, Y>) -> Lens<Source, AltSource, X, Y> {
    return self • other
  }
  
}

extension Lens {

  /// Convenience function to apply a new value directly.
  ///
  /// - Parameter newValue: newValue to set.
  ///
  /// - Returns: An automorphism that sets the `newValue`.
  public func over(just newValue: B) -> (S) -> T {
    return over { _ in newValue }
  }
}

extension Lens where S == T, A == B {

  /// Zip two lenses together in order update the whole from two parts
  /// simultaneously.
  ///
  /// - Parameter other: lens to compose with.
  ///
  /// - Returns: A Simple Lens which sets two values simultaneously.
  public func zip<X>(_ other: SimpleLens<S, X>) -> SimpleLens<S, (A, X)> {
    return SimpleLens<S, (A, X)>.init(get: { (whole) -> (A, X) in
      return (self.get(whole), other.get(whole))
    }, set: { (whole, parts) -> S in
      return other.set(self.set(whole, parts.0), parts.1)
    })
  }

  /// Initialize a Lens with a Writable Key Path
  ///
  /// - Parameter keyPath: Writable Key Path for setting/getting a property.
  public init(keyPath: WritableKeyPath<S, A>) {
    self.init(get: { $0[keyPath: keyPath] }, set: {
      var copy = $0
      copy[keyPath: keyPath] = $1
      return copy
    })
  }

}
