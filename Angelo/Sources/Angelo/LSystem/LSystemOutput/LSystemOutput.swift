//
//  LSystemOutput.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemOutput {
    let initialElement: LSystemElement
    
    var iterationsPerformed = 0
    var currentOutput: [LSystemElement] = []
    
    init(initialElement: LSystemElement) {
        self.initialElement = initialElement
    }
}

extension LSystemOutput: LSystemRuleContextAwareSource {
    var iterations: Int {
        iterationsPerformed
    }
    
    var currentStringRepresentation: String {
        currentOutput.map { $0.string }.joined(separator: "")
    }
}
