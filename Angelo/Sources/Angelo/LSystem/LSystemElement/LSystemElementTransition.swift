//
//  LSystemElementTransition.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

struct LSystemElementTransition {
    internal let referenceInput: LSystemElement
    internal let referenceOutput: LSystemElement
    internal let transition: (LSystemElement) -> (LSystemElement)
    
    func valid(forInput input: LSystemElement, output: LSystemElement) -> Bool {
        return input == referenceInput && output == referenceOutput
    }
    
    func performTransition(input: LSystemElement) -> LSystemElement {
        return transition(input)
    }
}
