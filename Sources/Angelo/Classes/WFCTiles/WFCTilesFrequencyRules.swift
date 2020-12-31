//
//  WFCTilesFrequencyRules.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesFrequencyRules {
    var frequency: [Int: Int] = [:]
    
    var keys: [Int] {
        frequency.keys.map({ $0 })
    }
    
    var totalWeight: Int {
        frequency.values.reduce(0, { $0 + $1 })
    }
    
    public func addOccurence(elementID: Int) {
        guard let val = frequency[elementID] else {
            frequency[elementID] = 1
            return
        }
        
        frequency[elementID] = val + 1
    }
    
    public func getFrequency(forElementID elementID: Int) -> Int? {
        return frequency[elementID]
    }
}
