//
//  ArrayExtensions.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-04.
//

import Foundation

extension Array {

  func updating(_ value: Iterator.Element, at index: Int) -> Array<Iterator.Element> {
    var copy = self
    copy[index] = value
    return copy
  }

  func appending(_ value: Iterator.Element) -> Array<Iterator.Element> {
    var copy = self
    copy.append(value)
    return copy
  }

  func removing(at index: Int) -> Array<Element> {
    var copy = self
    copy.remove(at: index)
    return copy
  }

}
