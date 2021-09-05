//
//  WFCTilesSolverNode.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesSolverNode {
    
    var possibleElements: [Bool]
    
    var possibleElementsCount = 0
    
    var hasAPossibleElement: Bool {
        possibleElementsCount != 0
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
        possibleElementsCount = possibleElements.filter({ $0 }).count
        
        self.solverNodeEnablers = solverNodeEnablers
        
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
    
    public func disableElement(at position: Int) {
        if (possibleElements[position]) {
            possibleElementsCount -= 1
        }
        
        possibleElements[position] = false
    }
    
    public func calculateEntropy(frequency: WFCTilesFrequencyRules) -> Double {
        return log2(totalWeight) - (sumOfWeightLogWeight / totalWeight) + entropyNoise
    }
    
    public func chooseTile(frequency: WFCTilesFrequencyRules) -> Int {
        let list = WeightedList<Int>()
        
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
        disableElement(at: elementID)
        
        let relativeFrequency = Double(frequency.getFrequency(forElementID: elementID)!)
        
        totalWeight -= relativeFrequency
        sumOfWeightLogWeight -= relativeFrequency * log2(relativeFrequency)
    }
}

class WFCTilesSolverNodeEnabler: NSObject, NSCopying {
    var byDirection = [WFCTilesDirection: Int]()
    
    private var zeroCount = 0
    
    var containsAnyZero: Bool {
        zeroCount > 0
    }
    
    override init() {
        for direction in WFCTilesDirection.allCases {
            byDirection[direction] = 0
        }
        
        zeroCount = byDirection.values.filter({ $0 == 0 }).count
        
        super.init()
    }
    
    init(byDirection: [WFCTilesDirection: Int], zeroCount: Int) {
        self.byDirection = byDirection
        self.zeroCount = zeroCount
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WFCTilesSolverNodeEnabler(byDirection: byDirection, zeroCount: zeroCount)
        return copy
    }
    
    func updateDirection(_ direction: WFCTilesDirection, to value: Int) {
        byDirection[direction] = value
    }
    
    func updateZeroCount() {
        zeroCount = byDirection.values.filter({ $0 == 0 }).count
    }
    
    func decrementEnabler(inDirection direction: WFCTilesDirection) {
        let previousValue = byDirection[direction]!
        let newValue = previousValue - 1
        
        updateDirection(direction, to: newValue)
        
        if (newValue == 0) {
            zeroCount += 1
        }
    }
    
    func incrementEnabler(inDirection direction: WFCTilesDirection) {
        let previousValue = byDirection[direction]!
        updateDirection(direction, to: previousValue + 1)
    }
}
