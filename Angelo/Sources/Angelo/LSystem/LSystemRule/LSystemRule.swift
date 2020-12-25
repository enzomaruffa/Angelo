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
    
    convenience init(input: LSystemElement, outputs: [LSystemElement]) {
        self.init(input: input, outputs: outputs, weight: 1)
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parametricComponent = nil
    }
    
    init(input: LSystemElement, outputs: [LSystemElement], weight: Double, parametricComponent: LSystemRuleParametricComponent) {
        self.input = input
        self.outputs = outputs
        self.weight = weight
        self.parametricComponent = parametricComponent
    }
}
