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
    
    internal func getAvailableRules(forInputElement inputElement: LSystemElement, contextAwareComponentSource: LSystemRuleContextAwareSource?) -> [LSystemRule] {
        let availableRules = rules.filter { (rule) -> Bool in
            rule.isValid(forInputElement: inputElement, contextAwareComponentSource: contextAwareComponentSource)
        }
        return availableRules
    }
    
    func iterate(input: LSystemOutput) throws ->  LSystemOutput {
        let output = LSystemOutput(initialElement: input.initialElement)
        output.iterationsPerformed = input.iterationsPerformed + 1
        
        var outputs = [LSystemElement]()
        
        for element in input.outputElements {
            let availableRules = getAvailableRules(forInputElement: element, contextAwareComponentSource: input)
            
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
    
    func produceOutput(initialElementString: String, iterations: Int)  throws -> LSystemOutput {
        return try produceOutput(initialElement: LSystemElement(initialElementString), iterations: iterations)
    }
    
    func produceOutput(initialElement: LSystemElement, iterations: Int)  throws -> LSystemOutput {
        var output = LSystemOutput(initialElement: initialElement)
        output.outputElements = [initialElement]
        
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
