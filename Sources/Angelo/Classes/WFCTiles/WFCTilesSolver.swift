//
//  WFCTilesSolver.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesSolver {
    
    /// All properties from the solver are set on the `solve()` method
    var grid: [[WFCTilesSolverNode]]? = nil
    
    var nodesToCollapse: Int? = nil
    
    var rules: WFCTilesAdjacencyRules? = nil
    var frequency: WFCTilesFrequencyRules? = nil
    
    var entropyHeap: Heap<WFCTilesNodeHeapElement>? = nil
    
    var nodeRemovalQueue: [WFCTilesRemovalUpdate]? = nil
    
    public init() { }
    
    // Creates the node enablers
    func createSolverNodeEnablers(elementsCount: Int, adjacency: WFCTilesAdjacencyRules) -> [WFCTilesSolverNodeEnabler] {
        
        var enablers = [WFCTilesSolverNodeEnabler]()
        
        // For each element we have
        for elementID in 0..<elementsCount {
            var baseEnabler = WFCTilesSolverNodeEnabler()
            
            // And for each direction
            for direction in baseEnabler.byDirection.keys {
                
                // Check each element that can appear in that direction relative to this one
                for _ in adjacency.allElements(canAppearRelativeTo: elementID, inDirection: direction) {
                    
                    // Since an element can appear on that direction, that means that element "enables" this element
                    baseEnabler.byDirection[direction] = baseEnabler.byDirection[direction]! + 1
                }
            }
            
            enablers.append(baseEnabler)
        }
       
        return enablers
    }
    
    internal func createOutputGrid() -> [[Int]] {
        var outputGrid = [[Int]]()
        
        for i in 0..<grid![0].count {
            var outputGridRow = [Int]()
            
            for j in 0..<grid![0].count {
                let node = grid![i][j]
                
                // Creates an output grid, but if an element has no element possible it returns -1
                guard let element = node.onlyPossibleElement else {
                    outputGridRow.append(-1)
                    continue
                }
                
                outputGridRow.append(element)
            }
            
            outputGrid.append(outputGridRow)
        }
        
        return outputGrid
    }
    
    public func solve(rules: WFCTilesAdjacencyRules, frequency: WFCTilesFrequencyRules, outputSize: (Int, Int)) throws -> [[Int]] {

        // Initializes the values from the solver
        self.nodesToCollapse = outputSize.0 * outputSize.1
        self.rules = rules
        self.frequency = frequency
        
        entropyHeap = Heap<WFCTilesNodeHeapElement>(priorityFunction: <)
        
        grid = []
        nodeRemovalQueue = []
        
        let possibleElements = frequency.keys
        let possibleElementsBools = possibleElements.map({ _ in true })
        
        // Creates the enablers (will be copied for each node)
        let solverNodeEnablers = createSolverNodeEnablers(elementsCount: possibleElements.count, adjacency: rules)
        
        // Initialize the grid and the nodes
        for _ in 0..<outputSize.0 {
            var gridRow = [WFCTilesSolverNode]()
            for _ in 0..<outputSize.1 {
                let node = WFCTilesSolverNode(possibleElements: possibleElementsBools, solverNodeEnablers: solverNodeEnablers, frequency: frequency)
                gridRow.append(node)
            }
            grid?.append(gridRow)
        }
        
        // Start the heap with a single random element:
        let randomCoord = (i: Int.random(in: 0..<grid!.count), j: Int.random(in: 0..<grid![0].count))
        
        let node = grid![randomCoord.i][randomCoord.j]
        let entropy = node.calculateEntropy(frequency: frequency)
        
        let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: randomCoord)
        
        entropyHeap!.enqueue(heapElement)
        
        // Run the algorithm
        try run()
        
        // Transform the grid in a elementID grid
        let outputGrid = createOutputGrid()
        
        return outputGrid
    }
    
    internal func chooseNode() throws -> (i: Int, j: Int) {
        while let element = entropyHeap!.dequeue() {
            let coord = element.coord
            let node = grid![coord.i][coord.j]
            
            if !node.collapsed {
                return coord
            }
        }
        
        // TODO: This might happen if the first randomly select element doesn't change the entropy (in other words, removes no possible element) from the neighbours. A possible solution is to select another random element
        throw WFCErrors.EmptyHeap
    }

    internal func collapseNode(at: (i: Int, j: Int)) {
        let node = grid![at.i][at.j]
        let elementID = node.chooseTile(frequency: frequency!)
        
        node.collapsed = true
        
        // Removes all other possibilities
        node.possibleElements
            .enumerated()
            .filter({ $0.element }) // Only considers the ones that are possible to prevent double removal
            .forEach { (tuple) in
                if tuple.offset != elementID {
                    // Disabling the element explicitely in the array to prevent a new entropy calculation (not needed since the cell is collapsed by now)
                    node.possibleElements[tuple.offset] = false
                    
                    nodeRemovalQueue!.append(WFCTilesRemovalUpdate(elementID: tuple.offset, coord: at))
            }
        }
        
    }
    
    internal func getNeighbourCoord(coord: (i: Int, j: Int), direction: WFCTilesDirection) -> (i: Int, j: Int)? {
        
        // Gets the neighbour coordinates from the original element
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
            if coord.j+1 >= grid!.count {
                return nil
            }
            return (coord.i, coord.j+1)
        case .down:
            if coord.i+1 >= grid![0].count {
                return nil
            }
            return (coord.i+1, coord.j)
        }
    }

    internal func propagate() throws {
        
        // While an update hasn't been processed
        while !nodeRemovalQueue!.isEmpty {
            let nodeRemoval = nodeRemovalQueue!.removeFirst()
            
            for direction in WFCTilesDirection.allCases {
                let nodeCoord = nodeRemoval.coord
                
                guard let neighbourCoord = getNeighbourCoord(coord: nodeCoord, direction: direction) else {
                    continue
                }
                
                let neighbourNode = grid![neighbourCoord.i][neighbourCoord.j]
                
                for compatibleTile in rules!.allElements(canAppearRelativeTo: nodeRemoval.elementID, inDirection: direction) {
                    
                    // Look up the count of enablers for this tile
                    var enablerCounts = neighbourNode.solverNodeEnablers[compatibleTile]
                    
                    // Change to the opposite direction (we are now looking from the perspective of the neighbour
                    let oppositeDirection = direction.opposite
                    
                    // Check if we're about to decrement this to 0
                    if enablerCounts.byDirection[oppositeDirection] == 1 {
                        
                        // We only need to discard this element from this direction if it hasn't been discarded yet by another direction
                        if !enablerCounts.containsAnyZero {
                            neighbourNode.removeTile(elementID: compatibleTile, frequency: frequency!)
                            
                            // Check for contradiction
                            if neighbourNode.possibleElementsCount == 0 {
//                                let outputGrid = createOutputGrid()
//
//                                for row in outputGrid {
//                                    print(row)
//                                }
//
                                // TODO: Return the matrix as a enum property
                                throw WFCErrors.ImpossibleSolution
                            }
                            
                            // Add to the heap
                            let entropy = neighbourNode.calculateEntropy(frequency: frequency!)
                            let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: neighbourCoord)
                            entropyHeap!.enqueue(heapElement)
                            
                            // If our neighbour is not collapsed, add the element removal to the queue
                            // TODO: Check if doing this verification sooner isn't already ok
                            if !neighbourNode.collapsed {
                                nodeRemovalQueue!.append(WFCTilesRemovalUpdate(elementID: compatibleTile, coord: neighbourCoord))
                            }
                        }
                    }
                    
                    enablerCounts.byDirection[oppositeDirection] = enablerCounts.byDirection[oppositeDirection]! - 1
                    
                    // Return the enabler to the node (Swift copies since it's a struct)
                    neighbourNode.solverNodeEnablers[compatibleTile] = enablerCounts
                }
            }
        }
    }

    internal func run() throws {
        while nodesToCollapse! > 0 {
            let (i, j) = try self.chooseNode()
            
            collapseNode(at: (i, j))
            
            try propagate()
            
            nodesToCollapse! -= 1
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

struct WFCTilesRemovalUpdate: Hashable {
    var elementID: Int
    var coord: (i: Int, j: Int)
    
    static func == (lhs: WFCTilesRemovalUpdate, rhs: WFCTilesRemovalUpdate) -> Bool {
        lhs.elementID == rhs.elementID && lhs.coord == rhs.coord
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(elementID)
        hasher.combine(coord.i)
        hasher.combine(coord.j)
    }
}
