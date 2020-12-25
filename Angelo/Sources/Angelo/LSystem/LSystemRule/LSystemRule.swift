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
    
    let input: LSystemElement
    let outputs: [LSystemElement]
    
    let weight: Double
    
    let canApplyByParameters: ParametericFunction
    let canApplyByContext: ContextAwareFunction
    
    convenience init(input: LSystemElement, output: LSystemElement) {
        self.init(input: input, outputs: [output], weight: 1)
    }
    
    convenience init(input: LSystemElement, outputs: [LSystemElement]) {
        self.init(input: input, outputs: outputs, weight: 1)
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double) {
        self.init(input: input, outputs: [output], weight: weight)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.canApplyByParameters = nil
        self.canApplyByContext = nil
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double, canApplyByParameters: ParametericFunction) {
        self.init(input: input, outputs: [output], weight: weight, canApplyByParameters: canApplyByParameters)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, canApplyByParameters: ParametericFunction) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.canApplyByParameters = canApplyByParameters
        self.canApplyByContext = nil
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double, canApplyByContext: ContextAwareFunction) {
        self.init(input: input, outputs: [output], weight: weight, canApplyByContext: canApplyByContext)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, canApplyByContext: ContextAwareFunction) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.canApplyByParameters = nil
        self.canApplyByContext = canApplyByContext
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double, canApplyByParameters: ParametericFunction, canApplyByContext: ContextAwareFunction) {
        self.init(input: input, outputs: [output], weight: weight, canApplyByParameters: canApplyByParameters, canApplyByContext: canApplyByContext)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, canApplyByParameters: ParametericFunction, canApplyByContext: ContextAwareFunction) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.canApplyByParameters = canApplyByParameters
        self.canApplyByContext = canApplyByContext
    }
    
    func isValid(forInputElement inputElement: LSystemElement, contextAwareComponentSource: LSystemRuleContextAwareSource? = nil) throws -> Bool {
        if inputElement != input {
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
    
    func apply(inputElement: LSystemElement) throws -> [LSystemElement] {
        return try apply(inputElement: inputElement, transitions: [])
    }
    
    func apply(inputElement: LSystemElement, transitions: [LSystemParametersTransition]) throws -> [LSystemElement] {
        
        if !(try isValid(forInputElement: inputElement)) {
            throw LSystemErrors.InvalidRuleApplication
        }
        
        var outputs = [LSystemElement]()
        for output in self.outputs {
            
            if let firstValidTransition =
                transitions.first(where: {
                                    $0.isValid(
                                        forInput: inputElement.string,
                                        output: output.string)})
            {
                outputs.append(firstValidTransition.performTransition(input: inputElement))
            } else {
                outputs.append(LSystemElement(output.string))
            }
        }
        
        return outputs
    }
}
