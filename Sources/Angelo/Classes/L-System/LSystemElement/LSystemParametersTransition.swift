//
//  LSystemElementTransition.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public struct LSystemParametersTransition {
    public let input: String
    public let output: String
    public let transition: ([String: Any]?) -> ([String: Any])
    
    public init(input: String,
                output: String,
                transition: @escaping ([String: Any]?) -> ([String: Any])) {
        self.input = input
        self.output = output
        self.transition = transition
    }
    
    public func isValid(forInput input: String, output: String) -> Bool {
        return input == self.input
            && output == self.output
    }
    
    public func performTransition(inputElement: LSystemElement) -> LSystemElement {
        let newParameters = transition(inputElement.parameters)
        return LSystemElement(output, parameters: newParameters)
    }
}
