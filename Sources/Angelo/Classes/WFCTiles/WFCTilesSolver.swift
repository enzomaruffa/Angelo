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
    
    var entropyHeap: Heap<WFCTilesNodeHeapElement>
    
    var nodeRemovalQueue: [WFCTilesRemovalUpdate]
    
    public init(outputSize: (Int, Int), rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules) {
        self.nodesToCollapse = outputSize.0 * outputSize.1
        self.rules = rules
        self.frequency = frequency
        
        entropyHeap = Heap<WFCTilesNodeHeapElement>(priorityFunction: >)
        
        grid = []
        nodeRemovalQueue = []
        
        let possibleElements = frequency.keys
        let possibleElementsBools = possibleElements.map({ _ in true })
        
        // Initialize solverNodeEnablers
        let solverNodeEnablers = createSolverNodeEnablers(elementsCount: possibleElements.count, adjacency: rules)
        
        // Initialize the grid and the nodes
        for _ in 0..<outputSize.0 {
            var gridRow = [WFCTilesSolverNode]()
            for _ in 0..<outputSize.1 {
                let node = WFCTilesSolverNode(possibleElements: possibleElementsBools, solverNodeEnablers: solverNodeEnablers, frequency: frequency)
                gridRow.append(node)
            }
        }
        
        // Start the heap with a single random element:
        let randomCoord = (i: Int.random(in: 0..<grid.count), j: Int.random(in: 0..<grid[0].count))
        
        let node = grid[randomCoord.i][randomCoord.j]
        let entropy = node.calculateEntropy(frequency: frequency)
        
        let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: randomCoord)
        
        entropyHeap.enqueue(heapElement)
    }
    
    func createSolverNodeEnablers(elementsCount: Int, adjacency: WFCTilesAdjacencyRules) -> [WFCTilesSolverNodeEnabler] {
        
        var enablers = [WFCTilesSolverNodeEnabler]()
        
        for elementID in 0..<elementsCount {
            var baseEnabler = WFCTilesSolverNodeEnabler()
            
            for direction in baseEnabler.byDirection.keys {
                for aID in adjacency.allElements(canAppearRelativeTo: elementID, inDirection: direction) {
                    baseEnabler.byDirection[direction] = baseEnabler.byDirection[direction]! + 1
                }
            }
            
            enablers.append(baseEnabler)
        }
       
        return enablers
    }
    
    public func solve(rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules, outputSize: (Int, Int)) -> [[Int]] {
//        
//        self.nodesToCollapse = outputSize.0 * outputSize.1
//        self.rules = rules
//        self.frequency = frequency
//        
//        entropyHeap = Heap<WFCTilesNodeHeapElement>(priorityFunction: >)
//        
//        grid = []
//        nodeRemovalQueue = []
//        
//        let possibleElements = frequency.keys
//        let possibleElementsBools = possibleElements.map({ _ in true })
//        
//        // Initialize solverNodeEnablers
//        let solverNodeEnablers = createSolverNodeEnablers(elementsCount: possibleElements.count, adjacency: rules)
//        
//        // Initialize the grid and the nodes
//        for _ in 0..<outputSize.0 {
//            var gridRow = [WFCTilesSolverNode]()
//            for _ in 0..<outputSize.1 {
//                let node = WFCTilesSolverNode(possibleElements: possibleElementsBools, solverNodeEnablers: solverNodeEnablers, frequency: frequency)
//                gridRow.append(node)
//            }
//        }
//        
//        // Start the heap with a single random element:
//        let randomCoord = (i: Int.random(in: 0..<grid.count), j: Int.random(in: 0..<grid[0].count))
//        
//        let node = grid[randomCoord.i][randomCoord.j]
//        let entropy = node.calculateEntropy(frequency: frequency)
//        
//        let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: randomCoord)
//        
//        entropyHeap.enqueue(heapElement)

    }
    
    internal func chooseNode() throws -> (i: Int, j: Int) {
        while let element = entropyHeap.dequeue() {
            let coord = element.coord
            let node = grid[coord.i][coord.j]
            if !node.collapsed {
                return coord
            }
        }
        
        throw WFCErrors.EmptyHeap
    }

    internal func collapseNode(at: (i: Int, j: Int)) {
        let node = grid[at.i][at.j]
        let elementID = node.chooseTile(frequency: frequency)
        
        node.collapsed = true
        
        // remove all other possibilities
        node.possibleElements.enumerated().forEach { (tuple) in
            if tuple.offset != elementID {
                // Disabling the element explicitely in the array to prevent a new entropy calculation (not needed since the cell is collapsed by now)
                node.possibleElements[tuple.offset] = false
                
                self.nodeRemovalQueue.append(WFCTilesRemovalUpdate(elementID: tuple.offset, coord: at))
            }
        }
        
    }
    
    internal func getNeighbourCoord(coord: (i: Int, j: Int), direction: WFCTilesDirection) -> (i: Int, j: Int)? {
        switch direction {
        case .up:
            if coord.i-1 < 0 {
                return nil
            }
            return (coord.i-1, coord.j)
        case .left:
            if coord.j-1 < 0 {
                return nil
            }
            return (coord.i, coord.j-1)
        case .right:
            if coord.j+1 >= grid.count {
                return nil
            }
            return (coord.i, coord.j+1)
        case .down:
            if coord.i+1 >= grid[0].count {
                return nil
            }
            return (coord.i+1, coord.j)
        }
    }

    internal func propagate() throws {
        while !nodeRemovalQueue.isEmpty {
            let nodeRemoval = nodeRemovalQueue.removeFirst()
            
            for direction in WFCTilesDirection.allCases {
                let nodeCoord = nodeRemoval.coord
                
                guard let neighbourCoord = getNeighbourCoord(coord: nodeCoord, direction: direction) else {
                    continue
                }
                
                let neighbourNode = grid[neighbourCoord.i][neighbourCoord.j]
                
                for compatibleTile in rules.allElements(canAppearRelativeTo: nodeRemoval.elementID, inDirection: direction) {
//                    let oppositeDirection = direction.opposite
                    
                    // look up the count of enablers for this tile
                    var enablerCounts = neighbourNode.solverNodeEnablers[compatibleTile]
                    
                    // check if we're about to decrement this to 0
                    if enablerCounts.byDirection[direction] == 1 {
                        if !enablerCounts.containsAnyZero {
                            neighbourNode.removeTile(elementID: compatibleTile, frequency: frequency)
                            
                            // check for contradiction
                            if neighbourNode.possibleElementsCount == 0 {
                                throw WFCErrors.ImpossibleSolution
                            }
                            
                            // Add to the heap
                            let entropy = neighbourNode.calculateEntropy(frequency: frequency)
                            let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: neighbourCoord)
                            entropyHeap.enqueue(heapElement)
                            
                            // add the update to the stack
                            nodeRemovalQueue.append(WFCTilesRemovalUpdate(elementID: compatibleTile, coord: neighbourCoord))
                        }
                    }
                    
                    enablerCounts.byDirection[direction] = enablerCounts.byDirection[direction]! - 1
                }
            }
        }
    }

    internal func run() throws {
        while nodesToCollapse > 0 {
            let (i, j) = try self.chooseNode()
            collapseNode(at: (i, j))
            
            try propagate()
            
            nodesToCollapse -= 1
        }
    }
}

public enum WFCErrors: Error {
    case InvalidDataProviderForImage
    case EmptyHeap
    case ImpossibleSolution
}

struct WFCTilesNodeHeapElement: Comparable {
    var entropy: Double
    var coord: (i: Int, j: Int)
    
    static func < (lhs: WFCTilesNodeHeapElement, rhs: WFCTilesNodeHeapElement) -> Bool {
        lhs.entropy < rhs.entropy
    }
    
    static func == (lhs: WFCTilesNodeHeapElement, rhs: WFCTilesNodeHeapElement) -> Bool {
        lhs.entropy == rhs.entropy
    }
}

struct WFCTilesRemovalUpdate {
    var elementID: Int
    var coord: (i: Int, j: Int)
}
