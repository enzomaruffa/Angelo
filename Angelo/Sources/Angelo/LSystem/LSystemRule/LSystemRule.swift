//
//  LSystemRule.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemRule {
    typealias ParametericFunction = (([String: Any]) -> Bool)?
    typealias ContextAwareFunction = ((LSystemRuleContextAwareSource) -> Bool)?
    
    let input: String
    let outputs: [String]
    
    let weight: Double
    
    let canApplyByParameters: ParametericFunction
    let canApplyByContext: ContextAwareFunction
    
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
        try self.init(input: input, outputs: outputs, weight: weight, canApplyByParameters: nil, canApplyByContext: nil)
    }
    
    convenience init(input: String, output: String, weight: Double, canApplyByParameters: ParametericFunction) throws {
        try self.init(input: input, outputs: [output], weight: weight, canApplyByParameters: canApplyByParameters)
    }
    
    convenience init(input: String, outputs: [String], weight: Double, canApplyByParameters: ParametericFunction) throws {
        try self.init(input: input, outputs: outputs, weight: weight, canApplyByParameters: canApplyByParameters, canApplyByContext: nil)
    }
    
    convenience init(input: String, output: String, weight: Double, canApplyByContext: ContextAwareFunction) throws {
        try self.init(input: input, outputs: [output], weight: weight, canApplyByContext: canApplyByContext)
    }
    
    convenience init(input: String, outputs: [String], weight: Double, canApplyByContext: ContextAwareFunction) throws {
        try self.init(input: input, outputs: outputs, weight: weight, canApplyByParameters: nil, canApplyByContext: canApplyByContext)
    }
    
    convenience init(input: String, output: String, weight: Double, canApplyByParameters: ParametericFunction, canApplyByContext: ContextAwareFunction) throws {
        try self.init(input: input, outputs: [output], weight: weight, canApplyByParameters: canApplyByParameters, canApplyByContext: canApplyByContext)
    }
    
    init(input: String, outputs: [String], weight: Double, canApplyByParameters: ParametericFunction, canApplyByContext: ContextAwareFunction) throws {
        guard weight > 0 else {
            throw LSystemErrors.RuleWithInvalidWeight
        }
        
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.canApplyByParameters = canApplyByParameters
        self.canApplyByContext = canApplyByContext
    }
    
    func isValid(forInputElement inputElement: LSystemElement, contextAwareComponentSource: LSystemRuleContextAwareSource? = nil) -> Bool {
        if inputElement.string != input {
            return false
        }
        
        if let canApplyByParameters = self.canApplyByParameters,
           let parameters = inputElement.parameters,
           !canApplyByParameters(parameters) {
            return false
        }
        
        if let canApplyByContext = self.canApplyByContext,
           let source = contextAwareComponentSource,
           !(canApplyByContext(source)) {
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
                outputs.append(firstValidTransition.performTransition(input: inputElement))
            } else {
                outputs.append(LSystemElement(output))
            }
        }
        
        return outputs
    }
}
