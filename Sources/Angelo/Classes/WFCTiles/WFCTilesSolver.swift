//
//  WFCTilesSolver.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesSolver {
    
    var grid: [[WFCTilesSolverNode]]
    
    var nodesToCollapse: Int
    
    var rules: WFCTilesAdjacencyRules
    var frequency: WFCTilesFrequencyRules
    
    internal init(grid: [[WFCTilesSolverNode]], nodesToCollapse: Int, rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules) {
        self.grid = grid
        self.nodesToCollapse = nodesToCollapse
        self.rules = rules
        self.frequency = frequency
    }
    
    
    public func solve(rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules, outputSize: (Int, Int)) -> [[Int]] {
        return [[0]]
    }
    
//    internal func chooseNode() -> (i: Int, j: Int) {
//
//    }

    internal func collapseNode(at: (i: Int, j: Int)) {
    }

    internal func propagate() {
        
    }

    // roughly the same as the empty sudoku solver
//    internal func run() {
//        while nodesToCollapse > 0 {
//            let (i, j) = self.chooseNode()
//            collapseNode(at: (i, j))
//            propagate()
//            nodesToCollapse -= 1
//        }
//    }
}

public enum WFCErrors: Error {
    case InvalidDataProviderForImage
}
