//
//  LSystemRule.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemRule {
    typealias ParameterCheck = ((_ parameters: [String: Any]) -> Bool)?
    typealias ContextAwareCheck = ((_ source: LSystemRuleContextAwareSource, _ index: Int) -> Bool)?
    
    let input: String
    let outputs: [String]
    
    let weight: Double
    
    let parameterCheck: ParameterCheck
    let contextAwareCheck: ContextAwareCheck
    
    convenience init(input: String, output: String) throws {
        try self.init(input: input, outputs: [output])
    }
    
    convenience init(input: String, outputs: [String]) throws {
        try self.init(input: input, outputs: outputs, weight: 1)
    }
    
    convenience init(input: String, output: String, weight: Double) throws {
        try self.init(input: input, outputs: [output], weight: weight)
    }
    
    convenience init(input: String, outputs: [String], weight: Double) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: nil, contextAwareCheck: nil)
    }
    
    convenience init(input: String, output: String, weight: Double, parameterCheck: ParameterCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, parameterCheck: parameterCheck)
    }
    
    convenience init(input: String, outputs: [String], weight: Double, parameterCheck: ParameterCheck) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: parameterCheck, contextAwareCheck: nil)
    }
    
    convenience init(input: String, output: String, weight: Double, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, contextAwareCheck: contextAwareCheck)
    }
    
    convenience init(input: String, outputs: [String], weight: Double, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: nil, contextAwareCheck: contextAwareCheck)
    }
    
    convenience init(input: String, output: String, weight: Double, parameterCheck: ParameterCheck, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, parameterCheck: parameterCheck, contextAwareCheck: contextAwareCheck)
    }
    
    init(input: String, outputs: [String], weight: Double, parameterCheck: ParameterCheck, contextAwareCheck: ContextAwareCheck) throws {
        guard weight > 0 else {
            throw LSystemErrors.RuleWithInvalidWeight
        }
        
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parameterCheck = parameterCheck
        self.contextAwareCheck = contextAwareCheck
    }
    
    func isValid(forInputElement inputElement: LSystemElement, elementIndex: Int, contextAwareComponentSource: LSystemRuleContextAwareSource? = nil) -> Bool {
        if inputElement.string != input {
            return false
        }
        
        if let parameterCheck = self.parameterCheck,
           let parameters = inputElement.parameters,
           !parameterCheck(parameters) {
            return false
        }
        
        if let contextAwareCheck = self.contextAwareCheck,
           let source = contextAwareComponentSource,
           !(contextAwareCheck(source, elementIndex)) {
            return false
        }
        
        return true
    }
    
    func apply(inputElement: LSystemElement) -> [LSystemElement] {
        return apply(inputElement: inputElement, transitions: [])
    }
    
    func apply(inputElement: LSystemElement, transitions: [LSystemParametersTransition])  -> [LSystemElement] {
        
        var outputs = [LSystemElement]()
        for output in self.outputs {
            if let firstValidTransition =
                transitions.first(where: {
                                    $0.isValid(
                                        forInput: inputElement.string,
                                        output: output)})
            {
                outputs.append(firstValidTransition.performTransition(inputElement: inputElement))
            } else {
                outputs.append(LSystemElement(output))
            }
        }
        
        return outputs
    }
}
