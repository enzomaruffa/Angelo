//
//  LSystemElementTransition.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public struct LSystemParametersTransition {
    public let referenceInputString: String
    public let referenceOutputString: String
    public let transition: ([String: Any]) -> ([String: Any])
    
    public init(referenceInputString: String,
                referenceOutputString: String,
                transition: @escaping ([String: Any]) -> ([String: Any])) {
        self.referenceInputString = referenceInputString
        self.referenceOutputString = referenceOutputString
        self.transition = transition
    }
    
    public func isValid(forInput input: String, output: String) -> Bool {
        return input == referenceInputString
            && output == referenceOutputString
    }
    
    public func performTransition(inputElement: LSystemElement) -> LSystemElement {
        guard let parameters = inputElement.parameters else {
            return LSystemElement(referenceOutputString)
        }
        
        let newParameters = transition(parameters)
        return LSystemElement(referenceOutputString, parameters: newParameters)
    }
}
