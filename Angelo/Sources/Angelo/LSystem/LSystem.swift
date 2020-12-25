//
//  LSystem.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystem {
    var elements: [LSystemElement]
    var rules: [LSystemRule]
    var transitions: [LSystemElementTransition]
    
    var noTransitionBehavior: LSystemNoTransitionBehavior = .keep
    
    init(elements: [LSystemElement], rules: [LSystemRule], transitions: [LSystemElementTransition]) {
        self.elements = elements
        self.rules = rules
        self.transitions = transitions
    }
    
    convenience init() {
        self.init(elements: [], rules: [], transitions: [])
    }
}

extension LSystem: LSystemRuleContextAwareComponentDelegate {
    var iterations: Int {
        0
    }
    
    var currentStringRepresentation: String {
        ""
    }
}

enum LSystemNoTransitionBehavior {
    case keep
    case remove
}

enum LSystemErrors: Error {
    case NoContextDelegate
}
