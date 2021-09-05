//
//  WFCATilesAdjacencyRules.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesAdjacencyRules {
    var rules: [WFCTilesAdjacencyRule: Bool] = [:]
    
    var indexedRules: [WFCTilesAdjacencyRuleIndex: [Int]] = [:]
    
    public func addRule(aID: Int, canAppearRelativeToB bID: Int, inDirection direction: WFCTilesDirection) {
        let rule = WFCTilesAdjacencyRule(aID: aID, bID: bID, direction: direction)
        
        if rules[rule] == nil {
            rules[rule] = true
//            print("Added rule: \(aID) can appear to the \(direction) of \(bID)")
        }
        
        let index = WFCTilesAdjacencyRuleIndex(bID: bID, direction: direction)
        if indexedRules[index] != nil {
            indexedRules[index]?.append(aID)
        } else {
            indexedRules[index] = [aID]
        }
    }
    
    public func checkRule(aID: Int, canAppearRelativeToB bID: Int, inDirection direction: WFCTilesDirection) -> Bool {
        let rule = WFCTilesAdjacencyRule(aID: aID, bID: bID, direction: direction)
        
        if rules[rule] != nil {
            return true
        }
        return false
    }
    
    public func allElements(canAppearRelativeTo bID: Int, inDirection direction: WFCTilesDirection) -> [Int] {
        indexedRules[WFCTilesAdjacencyRuleIndex(bID: bID, direction: direction)]!
    }
}

class WFCTilesAdjacencyRule: Hashable {
    let aID: Int
    let bID: Int
    let direction: WFCTilesDirection
    
    internal init(aID: Int, bID: Int, direction: WFCTilesDirection) {
        self.aID = aID
        self.bID = bID
        self.direction = direction
    }
    
    static func == (lhs: WFCTilesAdjacencyRule, rhs: WFCTilesAdjacencyRule) -> Bool {
        lhs.aID == rhs.aID
        && lhs.bID == rhs.bID
        && lhs.direction == rhs.direction
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(aID)
        hasher.combine(bID)
        hasher.combine(direction)
    }
}

class WFCTilesAdjacencyRuleIndex: Hashable {
    let bID: Int
    let direction: WFCTilesDirection
    
    internal init(bID: Int, direction: WFCTilesDirection) {
        self.bID = bID
        self.direction = direction
    }
    
    static func == (lhs: WFCTilesAdjacencyRuleIndex, rhs: WFCTilesAdjacencyRuleIndex) -> Bool {
        lhs.bID == rhs.bID
        && lhs.direction == rhs.direction
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bID)
        hasher.combine(direction)
    }
}

public enum WFCTilesDirection: CaseIterable {
    case up
    case left
    case right
    case down
    
    var opposite: WFCTilesDirection {
        switch self {
        case .up:
            return .down
        case .down:
            return .up
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}
