//
//  WFCTilesSolverNode.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesSolverNode {
    
    var possibleElements: [Bool]
    
    var possibleElementsCount: Int {
        possibleElements.filter({ $0 }).count
    }
    
    var onlyPossibleElement: Int? {
        possibleElements
            .enumerated()
            .first { (tuple) -> Bool in
                tuple.element
            }?.offset
    }
    
    var totalWeight: Double
    var sumOfWeightLogWeight: Double
    
    // Add a small noise to avoid using random number generators every time
    var entropyNoise: Double = Double.random(in: 0.01...0.1)
    
    var collapsed = false
    
    var solverNodeEnablers: [WFCTilesSolverNodeEnabler]
    
    init(possibleElements: [Bool], solverNodeEnablers: [WFCTilesSolverNodeEnabler], frequency: WFCTilesFrequencyRules) {
        self.possibleElements = possibleElements
        
        totalWeight = 0
        sumOfWeightLogWeight = 0
        
        self.solverNodeEnablers = solverNodeEnablers
        
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
//        print(" Current total weight: \(totalWeight)")
//        print(" Calculated entropy: \(log2(totalWeight) - (sumOfWeightLogWeight / totalWeight) + entropyNoise)")
        return log2(totalWeight) - (sumOfWeightLogWeight / totalWeight) + entropyNoise
    }
    
    public func chooseTile(frequency: WFCTilesFrequencyRules) -> Int {
        let list = WeightedList<Int>()
        
//        print("     Possible elements to choose: \(possibleElements)")
        
        // TODO: Proper error handling
        possibleElements.enumerated()
            .filter({ $0.element })
            .forEach { (tile) in
                // Tile is still possible
                if tile.element {
                    let elementID = tile.offset
                    try! list.add(elementID, weight: Double(frequency.getFrequency(forElementID: elementID)!))
                }
        }
        
        return list.randomElement()!
    }
    
    public func removeTile(elementID: Int, frequency: WFCTilesFrequencyRules) {
        possibleElements[elementID] = false
        
        let relativeFrequency = Double(frequency.getFrequency(forElementID: elementID)!)
        
        totalWeight -= relativeFrequency
        sumOfWeightLogWeight -= relativeFrequency * log2(relativeFrequency)
    }
}

struct WFCTilesSolverNodeEnabler {
    var byDirection = [WFCTilesDirection: Int]()
    
    var containsAnyZero: Bool {
        byDirection.values.filter({ $0 == 0 }).first != nil
    }
    
    init() {
        for direction in WFCTilesDirection.allCases {
            byDirection[direction] = 0
        }
    }
}
