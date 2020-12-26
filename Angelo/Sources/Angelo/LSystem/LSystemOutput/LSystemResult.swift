//
//  LSystemOutput.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemResult {
    let inputElement: LSystemElement
    
    internal var iterationsPerformed = 0
    var outputElements: [LSystemElement] = []
    
    var parameterSeparator = ";"
    var parameterStartDelimiter = "("
    var parameterEndDelimiter = ")"
    
    var stringWithParameters: String {
        outputElements
            .map { $0.stringWithParameters(
                    startDelimiter: parameterStartDelimiter,
                    separator: parameterSeparator,
                    endDelimiter: parameterEndDelimiter)
                }
            .joined(separator: "")
    }
    
    init(initialElement: LSystemElement) {
        self.inputElement = initialElement
    }
}

extension LSystemResult: LSystemRuleContextAwareSource {
    var iterations: Int {
        iterationsPerformed
    }
    
    var string: String {
        outputElements.map { $0.string }.joined(separator: "")
    }
}
