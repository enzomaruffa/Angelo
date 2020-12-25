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
    
    func addRule(input: String, output: String) {
        let rule = LSystemRule(input: LSystemElement(input), output: LSystemElement(output))
        add(rule: rule)
    }
    
    func addRule(input: String, output: String, weight: Double) {
        let rule = LSystemRule(input: LSystemElement(input), output: LSystemElement(output), weight: weight)
        add(rule: rule)
    }
    
    func addRule(input: String, outputs: [String]) {
        let outputsElements = outputs.map({ LSystemElement($0) })
        let rule = LSystemRule(input: LSystemElement(input), outputs: outputsElements)
        add(rule: rule)
    }
    
    func addRule(input: String, outputs: [String], weight: Double) {
        let outputsElements = outputs.map({ LSystemElement($0) })
        let rule = LSystemRule(input: LSystemElement(input), outputs: outputsElements, weight: weight)
        add(rule: rule)
    }
    
    func add(transition: LSystemParametersTransition) {
        transitions.append(transition)
    }
    
    func addTransition(input: String, output: String, transition: @escaping ([String: Any]) -> ([String: Any])) {
        
        let transition = LSystemParametersTransition(referenceInputString: input, referenceOutputString: output, transition: transition)
        
        add(transition: transition)
    }
    
    internal func getAvailableRules(forInputElement inputElement: LSystemElement, contextAwareComponentSource: LSystemRuleContextAwareSource?) throws -> [LSystemRule] {
        let availableRules = try rules.filter { (rule) -> Bool in
            try rule.isValid(forInputElement: inputElement, contextAwareComponentSource: contextAwareComponentSource)
        }
        return availableRules
    }
    
    func iterate(input: LSystemOutput) throws ->  LSystemOutput {
        let output = LSystemOutput(initialElement: input.initialElement)
        output.iterationsPerformed = input.iterationsPerformed + 1
        
        var outputs = [LSystemElement]()
        
        for element in input.currentOutput {
            let availableRules = try getAvailableRules(forInputElement: element, contextAwareComponentSource: input)
            
            let list = WeightedList<LSystemRule>()
            try availableRules.forEach { (rule) in
                try list.add(rule, weight: rule.weight)
            }
            
            guard let selectedRule = list.randomElement() else {
                switch noRuleBehavior {
                case .keep:
                    outputs.append(element)
                    continue
                case .remove:
                    continue
                }
            }
            
            let ruleOutputs = try selectedRule.apply(inputElement: element, transitions: transitions)
            outputs.append(contentsOf: ruleOutputs)
        }
        
        output.currentOutput = outputs
        return output
    }
    
    func produceOutput(initialElement: LSystemElement, iterations: Int)  throws -> LSystemOutput {
        var output = LSystemOutput(initialElement: initialElement)
        output.currentOutput = [initialElement]
        
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
    case InvalidRuleApplication
    case NoAvailableTransition
}
