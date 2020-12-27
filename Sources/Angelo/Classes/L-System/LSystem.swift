//
//  LSystem.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

/// An L-System that supports both basic L-Systems  as well as rules with weights and checks and elements with parameters
public class LSystem {
    
    /// The current rules this `LSystem` will use when transforming a `LSystemResult`
    public var rules: [LSystemRule]
    
    /// The transitions this `LSystem` can use when applying rules
    public var transitions: [LSystemParametersTransition]
    
    /// How the `LSystem` should behave when no rules are available for an input element
    /// - Note: Defaults to .keep
    public var noRuleBehavior: LSystemNoRuleBehavior = .keep
    
    /// Creates a new `LSystem`
    /// - Parameters:
    ///   - rules: The rules this `LSystem` uses
    ///   - transitions: The transitions this `LSystem` uses
    public init(rules: [LSystemRule], transitions: [LSystemParametersTransition]) {
        self.rules = rules
        self.transitions = transitions
    }
    
    /// Creates an empty `LSystem`
    public convenience init() {
        self.init(rules: [], transitions: [])
    }
    
    /// Adds a rule into the `LSystem`
    /// - Parameter rule: The rule to be added
    public func add(rule: LSystemRule) {
        rules.append(rule)
    }
    
    /// Adds a transition into the `LSystem`
    /// - Parameter transition: The transition to be added
    public func add(transition: LSystemParametersTransition) {
        transitions.append(transition)
    }
    
    /// Gets all rules that are available for a specific input element
    /// - Parameters:
    ///   - inputElement: The input element to use when checking if a rule is valid
    ///   - elementIndex: The index of the `inputElement` in the current `LSystemResult`
    ///   - contextAwareComponentSource: The source that context-aware checks should use
    /// - Returns: A list of rules that are available for the conditions above
    internal func getAvailableRules(forInputElement inputElement: LSystemElement, elementIndex: Int, contextAwareComponentSource: LSystemRuleContextAwareSource?) -> [LSystemRule] {
        let availableRules = rules.filter { (rule) -> Bool in
            rule.isValid(forInputElement: inputElement,
                         elementIndex: elementIndex,
                         contextAwareComponentSource: contextAwareComponentSource)
        }
        return availableRules
    }
    
    /// Applies an iteration into an `LSystemResult`
    /// - Parameter input: The `LSystemResult` that will be iterated on the current `LSystem`
    /// - Returns: A new `LSystemResult` after one iteration
    public func iterate(input: LSystemResult) ->  LSystemResult {
        let output = LSystemResult(initialElement: input.inputElement)
        output.iterationsPerformed = input.iterationsPerformed + 1
        
        var outputs = [LSystemElement]()
        
        for (index, element) in input.outputElements.enumerated() {
            let availableRules = getAvailableRules(forInputElement: element, elementIndex: index, contextAwareComponentSource: input)
            
            let list = WeightedList<LSystemRule>()
            
            availableRules.forEach { (rule) in
                do {
                    try list.add(rule, weight: rule.weight)
                } catch {
                    print("Error adding rule to list: [\(error.localizedDescription)]")
                }
            }
            
            if let selectedRule = list.randomElement() {
                let ruleOutputs = selectedRule.apply(inputElement: element, transitions: transitions)
                outputs.append(contentsOf: ruleOutputs)
                continue
            }
        
            switch noRuleBehavior {
            case .keep:
                outputs.append(element)
            case .remove:
                break
            }
        }
        
        output.outputElements = outputs
        return output
    }
    
    /// Produces an `LSystemResult` based on a input string and a set number of iterations
    /// - Parameters:
    ///   - input: The input the `LSystem` will use
    ///   - iterations: The amount of iterations that should be performed
    /// - Returns: An `LSystemResult` based on the input and amount of iterations
    public func produceOutput(input: String, iterations: Int) -> LSystemResult {
        return produceOutput(inputElement: LSystemElement(input), iterations: iterations)
    }
    
    
    /// Produces an `LSystemResult` based on a input element (which might have parameters) and a set number of iterations
    /// - Parameters:
    ///   - inputElement: The input element that will be used
    ///   - iterations: The amount of iterations that should be performed
    /// - Returns: An `LSystemResult` based on the input and amount of iterations
    public func produceOutput(inputElement: LSystemElement, iterations: Int) -> LSystemResult {
        var output = LSystemResult(initialElement: inputElement)
        output.outputElements = [inputElement]
        
        for _ in 0..<iterations {
            output = iterate(input: output)
        }
        
        return output
    }
}

/// Describes how an `LSystem` should behave when no rules are available for an element
public enum LSystemNoRuleBehavior {
    case keep
    case remove
}

/// The errors that the `LSystem` can throw
enum LSystemErrors: Error {
    case RuleWithInvalidWeight
}
