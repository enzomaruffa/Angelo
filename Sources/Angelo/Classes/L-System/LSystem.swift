//
//  LSystem.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public class LSystem {
    public var rules: [LSystemRule]
    public var transitions: [LSystemParametersTransition]
    
    public var noRuleBehavior: LSystemNoRuleBehavior = .keep
    
    public init(rules: [LSystemRule], transitions: [LSystemParametersTransition]) {
        self.rules = rules
        self.transitions = transitions
    }
    
    public convenience init() {
        self.init(rules: [], transitions: [])
    }
    
    public func add(rule: LSystemRule) {
        rules.append(rule)
    }
    
    public func add(transition: LSystemParametersTransition) {
        transitions.append(transition)
    }
    
    internal func getAvailableRules(forInputElement inputElement: LSystemElement, elementIndex: Int, contextAwareComponentSource: LSystemRuleContextAwareSource?) -> [LSystemRule] {
        let availableRules = rules.filter { (rule) -> Bool in
            rule.isValid(forInputElement: inputElement,
                         elementIndex: elementIndex,
                         contextAwareComponentSource: contextAwareComponentSource)
        }
        return availableRules
    }
    
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
    
    public func produceOutput(input: String, iterations: Int) -> LSystemResult {
        return produceOutput(inputElement: LSystemElement(input), iterations: iterations)
    }
    
    public func produceOutput(inputElement: LSystemElement, iterations: Int) -> LSystemResult {
        var output = LSystemResult(initialElement: inputElement)
        output.outputElements = [inputElement]
        
        for _ in 0..<iterations {
            output = iterate(input: output)
        }
        
        return output
    }
}

public enum LSystemNoRuleBehavior {
    case keep
    case remove
}

enum LSystemErrors: Error {
    case RuleWithInvalidWeight
}
