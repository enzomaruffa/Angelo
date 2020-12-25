//
//  LSystemRuleContextAwareComponent.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemRuleContextAwareComponent {
    typealias ApplyFunction = ((LSystemRuleContextAwareComponentSource) -> Bool)
    
    var canBeApplied: ApplyFunction
    
    init(canBeApplied: @escaping ApplyFunction) {
        self.canBeApplied = canBeApplied
    }
    
    func isValid(source: LSystemRuleContextAwareComponentSource) throws -> Bool  {
        return canBeApplied(source)
    }
}
