//
//  String+Utilities.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation
import RandomKit

extension String {

  func removing(at index: Index) -> String {
    var copy = self
    copy.remove(at: index)
    return copy
  }

}
