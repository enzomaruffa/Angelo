//
//  WFCTilesSolverNode.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesSolverNode {
    
    var possibleElements: [Bool]
    
    var totalWeight: Double
    var sumOfWeightLogWeight: Double
    
    // Add a small noise to avoid using random number generators every time
    var entropyNoise: Double = Double.random(in: 0.01...0.9)
    
    public init(possibleElements: [Bool], frequency: WFCTilesFrequencyRules) {
        self.possibleElements = possibleElements
        
        totalWeight = 0
        sumOfWeightLogWeight = 0
        
        // Calculating the actual values
        
        totalWeight = Double(calculateTotalWeight(frequency: frequency))
        
        sumOfWeightLogWeight = possibleElements.enumerated()
            .map { (tuple) -> Double in
                if tuple.element {
                    let relativeFrequency = Double(frequency.getFrequency(forElementID: tuple.offset)!)
                    return relativeFrequency * log2(relativeFrequency)
                }
                return 0
            }.reduce(0, { $0 + $1})
    }
    
    internal func calculateTotalWeight(frequency: WFCTilesFrequencyRules) -> Int {
        possibleElements.enumerated().reduce(0, {
            $1.element ? $0 + frequency.getFrequency(forElementID: $1.offset)! : $0
        })
    }
    
    public func calculateEntropy(frequency: WFCTilesFrequencyRules) -> Double {
        return log2(totalWeight) - (sumOfWeightLogWeight / totalWeight) + entropyNoise
    }
    
    public func removeTile(elementID: Int, frequency: WFCTilesFrequencyRules) {
        possibleElements[elementID] = false
        
        let relativeFrequency = Double(frequency.getFrequency(forElementID: elementID)!)
        
        totalWeight -= relativeFrequency
        sumOfWeightLogWeight -= relativeFrequency * log2(relativeFrequency)
    }
}
