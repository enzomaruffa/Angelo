//
//  LSystemRuleContextAwareComponentSource.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

protocol LSystemRuleContextAwareComponentSource: class {
    var iterations: Int { get }
    var currentStringRepresentation: String { get }
}
