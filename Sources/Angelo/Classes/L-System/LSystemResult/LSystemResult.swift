//
//  LSystemOutput.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public class LSystemResult {
    public let inputElement: LSystemElement
    
    internal var iterationsPerformed = 0
    public var outputElements: [LSystemElement] = []
    
    public var parameterSeparator = ";"
    public var parameterStartDelimiter = "("
    public var parameterEndDelimiter = ")"
    
    public var stringWithParameters: String {
        outputElements
            .map { $0.stringWithParameters(
                    startDelimiter: parameterStartDelimiter,
                    separator: parameterSeparator,
                    endDelimiter: parameterEndDelimiter)
                }
            .joined(separator: "")
    }
    
    public init(initialElement: LSystemElement) {
        self.inputElement = initialElement
    }
}

extension LSystemResult: LSystemRuleContextAwareSource {
    public var iterations: Int {
        iterationsPerformed
    }
    
    public var string: String {
        outputElements.map { $0.string }.joined(separator: "")
    }
}
