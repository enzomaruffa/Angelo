//
//  LSystemRule.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

/// A rule that describes in what each element in the L-System is transformed into
public class LSystemRule {
    /// A typealias for the function that checks the parameter from an `LSystemElement`
    public typealias ParameterCheck = ((_ parameters: [String: Any]) -> Bool)?
    /// A typealias for the function that checks the context from a `LSystemRuleContextAwareSource` and the index of the element that is being evaluated
    public typealias ContextAwareCheck = ((_ source: LSystemRuleContextAwareSource, _ index: Int) -> Bool)?
    
    /// The input that this rule applies to
    public let input: String
    
    /// The outputs this rule generates
    public let outputs: [String]
    
    /// The weight of this rule in the L-System
    public let weight: Double
    
    /// The function used to check if this rule is valid for a given input element 
    public let parameterCheck: ParameterCheck
    /// The function used to check if this rule is valid for the current result context (iterations, string)
    public let contextAwareCheck: ContextAwareCheck
    
    
    /// Creates a new rule based on an input and output
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - output: The output this rule generates
    public convenience init(input: String, output: String) {
        self.init(input: input, outputs: [output])
    }
    
    /// Creates a new rule based on an input and outputs
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - outputs: The outputs this rule generates
    public convenience init(input: String, outputs: [String]) {
        try! self.init(input: input, outputs: outputs, weight: 1)
    }
    
    /// Creates a new rule based on an input, an output and a weight
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - output: The output this rule generates
    ///   - weight: The weight this rule should have
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, output: String, weight: Double) throws {
        try self.init(input: input, outputs: [output], weight: weight)
    }
    
    /// Creates a new rule based on an input, outputs and a weight
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - outputs: The outputs this rule generates
    ///   - weight: The weight this rule should have
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, outputs: [String], weight: Double) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: nil, contextAwareCheck: nil)
    }
    
    /// Creates a new rule based on an input, an output, a weight and a parameter check
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - output: The output this rule generates
    ///   - weight: The weight this rule should have
    ///   - parameterCheck: The function used to check if this rule is valid for a given input element
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, output: String, weight: Double, parameterCheck: ParameterCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, parameterCheck: parameterCheck)
    }
    
    /// Creates a new rule based on an input, outputs, a weight and a parameter check
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - outputs: The outputs this rule generates
    ///   - weight: The weight this rule should have
    ///   - parameterCheck: The function used to check if this rule is valid for a given input element
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, outputs: [String], weight: Double, parameterCheck: ParameterCheck) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: parameterCheck, contextAwareCheck: nil)
    }
    
    /// Creates a new rule based on an input, an output, a weight and a context-aware check
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - output: The output this rule generates
    ///   - weight: The weight this rule should have
    ///   - contextAwareCheck: The function used to check if this rule is valid for the current result context (iterations, string)
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, output: String, weight: Double, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, contextAwareCheck: contextAwareCheck)
    }
    
    /// Creates a new rule based on an input, an output, a weight and a context-aware check
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - outputs: The outputs this rule generates
    ///   - weight: The weight this rule should have
    ///   - contextAwareCheck: The function used to check if this rule is valid for the current result context (iterations, string)
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, outputs: [String], weight: Double, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: outputs, weight: weight, parameterCheck: nil, contextAwareCheck: contextAwareCheck)
    }
    
    /// Creates a new rule based on an input, an output, a weight, a parameter check and a context-aware check
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - output: The output this rule generates
    ///   - weight: The weight this rule should have
    ///   - parameterCheck: The function used to check if this rule is valid for a given input element
    ///   - contextAwareCheck: The function used to check if this rule is valid for the current result context (iterations, string)
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
    public convenience init(input: String, output: String, weight: Double, parameterCheck: ParameterCheck, contextAwareCheck: ContextAwareCheck) throws {
        try self.init(input: input, outputs: [output], weight: weight, parameterCheck: parameterCheck, contextAwareCheck: contextAwareCheck)
    }
    
    /// Creates a new rule based on an input, outputs, a weight, a parameter check and a context-aware check
    /// - Parameters:
    ///   - input: The input that this rule applies to
    ///   - outputs: The outputs this rule generates
    ///   - weight: The weight this rule should have
    ///   - parameterCheck: The function used to check if this rule is valid for a given input element
    ///   - contextAwareCheck: The function used to check if this rule is valid for the current result context (iterations, string)
    /// - Throws: Throws an `LSystemErrors.RuleWithInvalidWeight` if the weight is `<= 0`
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
    
    /// Checks if a rule is valid given an input element
    /// - Parameters:
    ///   - inputElement: The input element to use in the validation
    ///   - elementIndex: The index of the input element
    ///   - contextAwareComponentSource: The source that the context-aware check should be used
    /// - Returns: Returns `true` if the rule is valid. Returns `false` if not.
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
    
    /// Applies the rule given an input element
    /// - Parameter inputElement: The element used to apply the rule
    /// - Returns: The outputs generated
    public func apply(inputElement: LSystemElement) -> [LSystemElement] {
        return apply(inputElement: inputElement, transitions: [])
    }
    
    /// Applies the rule given an input element and a list of transitions
    /// - Parameters:
    ///   - inputElement: The element used to apply the rule
    ///   - transitions: The transitions the rule should use when generating the outputs
    /// - Returns: The outputs generated
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
