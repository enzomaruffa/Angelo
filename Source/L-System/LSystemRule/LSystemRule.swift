//
//  LSystemRule.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public class LSystemRule {
    public typealias ParameterCheck = ((_ parameters: [String: Any]) -> Bool)?
    public typealias ContextAwareCheck = ((_ source: LSystemRuleContextAwareSource, _ index: Int) -> Bool)?
    
    public let input: String
    public let outputs: [String]
    
    public let weight: Double
    
    public let parameterCheck: ParameterCheck
    public let contextAwareCheck: ContextAwareCheck
    
    public convenience init(input: String, output: String) {
        self.init(input: input, outputs: [output])
    }
    
    public convenience init(input: String, outputs: [String]) {
        try! self.init(input: input, outputs: outputs, weight: 1)
    }
    
    public convenience init(input: String, output: String, weight: Double) throws {
        try self.init(input: input, outputs: [output], weight: weight)
    }
    
    public convenience init(input: String, outputs: [String], weight: Double) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: nil, contextAwareCheck: nil)
    }
    
    public convenience init(input: String, output: String, weight: Double, parameterCheck: ParameterCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, parameterCheck: parameterCheck)
    }
    
    public convenience init(input: String, outputs: [String], weight: Double, parameterCheck: ParameterCheck) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: parameterCheck, contextAwareCheck: nil)
    }
    
    public convenience init(input: String, output: String, weight: Double, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, contextAwareCheck: contextAwareCheck)
    }
    
    public convenience init(input: String, outputs: [String], weight: Double, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: nil, contextAwareCheck: contextAwareCheck)
    }
    
    public convenience init(input: String, output: String, weight: Double, parameterCheck: ParameterCheck, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, parameterCheck: parameterCheck, contextAwareCheck: contextAwareCheck)
    }
    
    public init(input: String, outputs: [String], weight: Double, parameterCheck: ParameterCheck, contextAwareCheck: ContextAwareCheck) throws {
        guard weight > 0 else {
            throw LSystemErrors.RuleWithInvalidWeight
        }
        
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parameterCheck = parameterCheck
        self.contextAwareCheck = contextAwareCheck
    }
    
    public func isValid(forInputElement inputElement: LSystemElement, elementIndex: Int, contextAwareComponentSource: LSystemRuleContextAwareSource? = nil) -> Bool {
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
    
    public func apply(inputElement: LSystemElement) -> [LSystemElement] {
        return apply(inputElement: inputElement, transitions: [])
    }
    
    public func apply(inputElement: LSystemElement, transitions: [LSystemParametersTransition])  -> [LSystemElement] {
        
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
