//
//  LSystemRuleContextAwareSource.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public protocol LSystemRuleContextAwareSource: class {
    var iterations: Int { get }
    var string: String { get }
}
