//
//  LSystemRuleContextAwareSource.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

/// Describes something that can be seen as a source of context for context-aware rules
public protocol LSystemRuleContextAwareSource: class {
    
    /// The amount of iterations that have been performed so far
    var iterations: Int { get }
    
    /// The string of the previous iteration output
    var string: String { get }
}
