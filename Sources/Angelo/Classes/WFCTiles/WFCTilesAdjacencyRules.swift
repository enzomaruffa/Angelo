//
//  WFCATilesAdjacencyRules.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesAdjacencyRules {
    var rules: [WFCTilesAdjacencyRule: Bool] = [:]
    
    public func addRule(aID: Int, canAppearRelativeToB bID: Int, inDirection direction: WFCTilesDirection) {
        let rule = WFCTilesAdjacencyRule(aID: aID, bID: bID, direction: direction)
        
        if rules[rule] == nil {
            rules[rule] = true
        }
    }
    
    public func checkRule(aID: Int, canAppearRelativeToB bID: Int, inDirection direction: WFCTilesDirection) -> Bool {
        let rule = WFCTilesAdjacencyRule(aID: aID, bID: bID, direction: direction)
        
        if rules[rule] != nil {
            return true
        }
        return false
    }
}

struct WFCTilesAdjacencyRule: Hashable {
    let aID: Int
    let bID: Int
    let direction: WFCTilesDirection
}

public enum WFCTilesDirection: CaseIterable {
    case up
    case left
    case right
    case down
}
