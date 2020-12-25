//
//  LSystemElementTransition.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

struct LSystemParametersTransition {
    internal let referenceInputString: String
    internal let referenceOutputString: String
    internal let transition: ([String: Any]) -> ([String: Any])
    
    func isValid(forInput input: String, output: String) -> Bool {
        return input == referenceInputString
            && output == referenceOutputString
    }
    
    func performTransition(input: LSystemElement) -> LSystemElement {
        guard let parameters = input.parameters else {
            return LSystemElement(referenceOutputString)
        }
        
        let newParameters = transition(parameters)
        return LSystemElement(referenceOutputString, parameters: newParameters)
    }
}
