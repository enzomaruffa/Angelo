//
//  LSystemRuleContextAwareSource.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

protocol LSystemRuleContextAwareSource: class {
    var iterations: Int { get }
    var currentStringRepresentation: String { get }
}
