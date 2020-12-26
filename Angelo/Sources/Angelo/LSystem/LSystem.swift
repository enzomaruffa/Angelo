//
//  LSystem.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystem {
    var rules: [LSystemRule]
    var transitions: [LSystemParametersTransition]
    
    var noRuleBehavior: LSystemNoRuleBehavior = .keep
    
    init(rules: [LSystemRule], transitions: [LSystemParametersTransition]) {
        self.rules = rules
        self.transitions = transitions
    }
    
    convenience init() {
        self.init(rules: [], transitions: [])
    }
    
    func add(rule: LSystemRule) {
        rules.append(rule)
    }
    
    func add(transition: LSystemParametersTransition) {
        transitions.append(transition)
    }
    
    func addTransition(input: String, output: String, transition: @escaping ([String: Any]) -> ([String: Any])) {
        
        let transition = LSystemParametersTransition(referenceInputString: input, referenceOutputString: output, transition: transition)
        
        add(transition: transition)
    }
    
    internal func getAvailableRules(forInputElement inputElement: LSystemElement, elementIndex: Int, contextAwareComponentSource: LSystemRuleContextAwareSource?) -> [LSystemRule] {
        let availableRules = rules.filter { (rule) -> Bool in
            rule.isValid(forInputElement: inputElement,
                         elementIndex: elementIndex,
                         contextAwareComponentSource: contextAwareComponentSource)
        }
        return availableRules
    }
    
    func iterate(input: LSystemResult) throws ->  LSystemResult {
        let output = LSystemResult(initialElement: input.inputElement)
        output.iterationsPerformed = input.iterationsPerformed + 1
        
        var outputs = [LSystemElement]()
        
        for (index, element) in input.outputElements.enumerated() {
            let availableRules = getAvailableRules(forInputElement: element, elementIndex: index, contextAwareComponentSource: input)
            
            let list = WeightedList<LSystemRule>()
            try availableRules.forEach { (rule) in
                try list.add(rule, weight: rule.weight)
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
    
    func produceOutput(input: String, iterations: Int)  throws -> LSystemResult {
        return try produceOutput(inputElement: LSystemElement(input), iterations: iterations)
    }
    
    func produceOutput(inputElement: LSystemElement, iterations: Int)  throws -> LSystemResult {
        var output = LSystemResult(initialElement: inputElement)
        output.outputElements = [inputElement]
        
        for _ in 0..<iterations {
            output = try iterate(input: output)
        }
        
        return output
    }
}

enum LSystemNoRuleBehavior {
    case keep
    case remove
}

enum LSystemErrors: Error {
    case RuleWithInvalidWeight
}
