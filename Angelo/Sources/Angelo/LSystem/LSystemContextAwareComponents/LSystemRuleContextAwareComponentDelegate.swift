//
//  LSystemRuleContextAwareComponentDelegate.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

protocol LSystemRuleContextAwareComponentDelegate: class {
    var iterations: Int { get }
    var currentStringRepresentation: String { get }
}
