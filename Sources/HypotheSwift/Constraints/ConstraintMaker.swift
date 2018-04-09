//
//  ConstraintMaker.swift
//  HypotheSwift
//
//  Created by Alex Popov on 2018-04-09.
//

import Foundation

public struct ConstraintMaker<Arguments> where Arguments: ArgumentEnumerable {
  // nothing here... 🤔
  // 
  // look in extensions
}

extension ConstraintMaker where Arguments: SupportsOneArgument {
  
  public var firstArgument: SingleArgumentConstraint<Arguments, Arguments.FirstArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.firstArgumentLens)
  }
  
}

extension ConstraintMaker where Arguments: SupportsTwoArguments {
  
  public var secondArgument: SingleArgumentConstraint<Arguments, Arguments.SecondArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.secondArgumentLens)
  }
  
  public var allArguments: MultiArgumentConstraint<Arguments> {
    return MultiArgumentConstraint<Arguments>()
  }
  
}

extension ConstraintMaker where Arguments: SupportsThreeArguments {
  
  public var thirdArgument: SingleArgumentConstraint<Arguments, Arguments.ThirdArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.thirdArgumentLens)
  }
  
}

extension ConstraintMaker where Arguments: SupportsFourArguments {
  
  public var fourthArgument: SingleArgumentConstraint<Arguments, Arguments.FourthArgument> {
    return SingleArgumentConstraint(argumentLens: Arguments.fourthArgumentLens)
  }
}
