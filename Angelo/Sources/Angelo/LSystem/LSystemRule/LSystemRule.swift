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
    
    let parametricComponent: LSystemRuleParametricComponent?
    let contextAwareComponent: LSystemRuleContextAwareComponent?
    
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
}
