//
//  LSystem.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystem {
    var rules: [LSystemRule]
    var transitions: [LSystemElementTransition]
    
    var noRuleBehavior: LSystemNoRuleBehavior = .keep
    
    init(rules: [LSystemRule], transitions: [LSystemElementTransition]) {
        self.rules = rules
        self.transitions = transitions
    }
    
    convenience init() {
        self.init(rules: [], transitions: [])
    }
    
    func add(rule: LSystemRule) {
        rules.append(rule)
    }
    
    func add(transition: LSystemElementTransition) {
        transitions.append(transition)
    }
    
    internal func iterate(input: LSystemOutput) throws ->  LSystemOutput {
        
        let output = LSystemOutput(initialElement: input.initialElement)
        output.iterationsPerformed = input.iterationsPerformed + 1
        
        var outputs = [LSystemElement]()
        
        for element in input.currentOutput {
            let availableRules = try rules.filter { (rule) -> Bool in
                try rule.isValid(forInputElement: element, contextAwareComponentSource: input)
            }
            
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
            
            let ruleOutputs = try selectedRule.apply(inputElement: element)
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
