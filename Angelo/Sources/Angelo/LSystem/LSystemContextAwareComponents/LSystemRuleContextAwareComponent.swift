//
//  LSystemRuleContextAwareComponent.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

struct LSystemRuleContextAwareComponent {
    weak var delegate: LSystemRuleContextAwareComponentDelegate?
    var canBeApplied: ((LSystemRuleContextAwareComponentDelegate) -> Bool)
}
