//
//  LSystemRule.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemRule {
    let input: LSystemElement
    let outputs: [LSystemElement]
    
    let weight: Double
    
    internal let parametricComponent: LSystemRuleParametricComponent?
    internal var contextAwareComponent: LSystemRuleContextAwareComponent?
    
    convenience init(input: LSystemElement, output: LSystemElement) {
        self.init(input: input, outputs: [output], weight: 1)
    }
    
    convenience init(input: LSystemElement, outputs: [LSystemElement]) {
        self.init(input: input, outputs: outputs, weight: 1)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parametricComponent = nil
        self.contextAwareComponent = nil
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double, parametricComponent: LSystemRuleParametricComponent) {
        self.init(input: input, outputs: [output], weight: weight, parametricComponent: parametricComponent)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, parametricComponent: LSystemRuleParametricComponent) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parametricComponent = parametricComponent
        self.contextAwareComponent = nil
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double, contextAwareComponent: LSystemRuleContextAwareComponent) {
        self.init(input: input, outputs: [output], weight: weight, contextAwareComponent: contextAwareComponent)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, contextAwareComponent: LSystemRuleContextAwareComponent) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parametricComponent = nil
        self.contextAwareComponent = contextAwareComponent
    }
    
    convenience init(input: LSystemElement, output: LSystemElement, weight: Double, parametricComponent: LSystemRuleParametricComponent, contextAwareComponent: LSystemRuleContextAwareComponent) {
        self.init(input: input, outputs: [output], weight: weight, parametricComponent: parametricComponent, contextAwareComponent: contextAwareComponent)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, parametricComponent: LSystemRuleParametricComponent, contextAwareComponent: LSystemRuleContextAwareComponent) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parametricComponent = parametricComponent
        self.contextAwareComponent = contextAwareComponent
    }
    
    func isValid(forInputElement inputElement: LSystemElement, contextAwareComponentSource: LSystemRuleContextAwareComponentSource? = nil) throws -> Bool {
        if inputElement != input {
            return false
        }
        
        if let ruleParametricComponent = self.parametricComponent,
           let elementParametricComponent = inputElement.parametricComponent,
           !ruleParametricComponent.canBeApplied(elementParametricComponent) {
            return false
        }
        
        if let ruleContextAwareComponent = self.contextAwareComponent,
           let source = contextAwareComponentSource,
           !(try ruleContextAwareComponent.isValid(source: source)) {
            return false
        }
        
        return true
    }
    
    func apply(inputElement: LSystemElement) throws -> [LSystemElement] {
        return try apply(inputElement: inputElement, transitions: [])
    }
    
    func apply(inputElement: LSystemElement, transitions: [LSystemElementTransition]) throws -> [LSystemElement] {
        
        if !(try isValid(forInputElement: inputElement)) {
            throw LSystemErrors.InvalidRuleApplication
        }
        
        var outputs = [LSystemElement]()
        for output in self.outputs {
            if output.parametricComponent != nil {
                guard let firstValidTransition = transitions.first(where: { $0.isValid(forInput: inputElement, output: output)}) else {
                    throw LSystemErrors.NoAvailableTransition
                }
                
                outputs.append(firstValidTransition.performTransition(input: inputElement))
            } else {
                outputs.append(LSystemElement(output.string))
            }
        }
        
        return outputs
    }
}
