//
//  WFCTilesSolver.swift
//  Angelo
//
//  Created by Enzo Maruffa Moreira on 30/12/20.
//

import Foundation

public class WFCTilesSolver {
    
    var grid: [[WFCTilesSolverNode]]? = nil
    
    var nodesToCollapse: Int? = nil
    
    var rules: WFCTilesAdjacencyRules? = nil
    var frequency: WFCTilesFrequencyRules? = nil
    
    var entropyHeap: Heap<WFCTilesNodeHeapElement>? = nil
    
    var nodeRemovalQueue: [WFCTilesRemovalUpdate]? = nil
    
    public init() {
        
    }
    
    func createSolverNodeEnablers(elementsCount: Int, adjacency: WFCTilesAdjacencyRules) -> [WFCTilesSolverNodeEnabler] {
        
        var enablers = [WFCTilesSolverNodeEnabler]()
        
        for elementID in 0..<elementsCount {
//            print("Checking element with ID \(elementID)")
            var baseEnabler = WFCTilesSolverNodeEnabler()
            
            for direction in baseEnabler.byDirection.keys {
                for aID in adjacency.allElements(canAppearRelativeTo: elementID, inDirection: direction) {
//                    print("     aID \(aID) can appear to the \(direction) of \(elementID)")
                    baseEnabler.byDirection[direction] = baseEnabler.byDirection[direction]! + 1
                }
            }
//            print(" Final enabler for \(elementID): \(baseEnabler.byDirection)")
            
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

        self.nodesToCollapse = outputSize.0 * outputSize.1
        self.rules = rules
        self.frequency = frequency
        
        entropyHeap = Heap<WFCTilesNodeHeapElement>(priorityFunction: <)
        
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
            grid?.append(gridRow)
        }
        
        // Start the heap with a single random element:
        let randomCoord = (i: Int.random(in: 0..<grid!.count), j: Int.random(in: 0..<grid![0].count))
        
        let node = grid![randomCoord.i][randomCoord.j]
        let entropy = node.calculateEntropy(frequency: frequency)
        
        let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: randomCoord)
        
        entropyHeap!.enqueue(heapElement)
        
        // Run the algorithm
//        print("Prepared to run...")
        try run()
        
        // Transform the grid in a elementID grid
//        print("Creating output grid...")
        var outputGrid = createOutputGrid()
        
        return outputGrid
    }
    
    internal func chooseNode() throws -> (i: Int, j: Int) {
        while let element = entropyHeap!.dequeue() {
//            print(" Choosing node at \(element.coord)")
//            print("         Entropy: \(element.entropy)")
            let coord = element.coord
            let node = grid![coord.i][coord.j]
//            print("         Collapsed? \(node.collapsed)")
            if !node.collapsed {
                return coord
            }
        }
        
        throw WFCErrors.EmptyHeap
    }

    internal func collapseNode(at: (i: Int, j: Int)) {
        let node = grid![at.i][at.j]
        let elementID = node.chooseTile(frequency: frequency!)
        
//        print("Selected element with id \(elementID) at \(at)")
        
        node.collapsed = true
        
        // remove all other possibilities
        node.possibleElements
            .enumerated()
            .filter({ $0.element })
            .forEach { (tuple) in
                if tuple.offset != elementID {
                    // Disabling the element explicitely in the array to prevent a new entropy calculation (not needed since the cell is collapsed by now)
                    node.possibleElements[tuple.offset] = false
                    
                    nodeRemovalQueue!.append(WFCTilesRemovalUpdate(elementID: tuple.offset, coord: at))
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
        while !nodeRemovalQueue!.isEmpty {
//            print("nodeRemovalQueue has \(nodeRemovalQueue?.count) nodes")
            
            let nodeRemoval = nodeRemovalQueue!.removeFirst()
//            print("====\nAnalyzing \(nodeRemoval.elementID), \(nodeRemoval.coord) removal")
            
            for direction in WFCTilesDirection.allCases {
                let nodeCoord = nodeRemoval.coord
                
                guard let neighbourCoord = getNeighbourCoord(coord: nodeCoord, direction: direction) else {
                    continue
                }
                
//                print("Neighbour node is \(neighbourCoord)")
                
                let neighbourNode = grid![neighbourCoord.i][neighbourCoord.j]
                
//                print("Neighbour node has \(neighbourNode.possibleElementsCount) possible elements")
                
//                print("  Compatible tiles in the neighbour with \(nodeRemoval.elementID): \(rules!.allElements(canAppearRelativeTo: nodeRemoval.elementID, inDirection: direction))")
                for compatibleTile in rules!.allElements(canAppearRelativeTo: nodeRemoval.elementID, inDirection: direction) {
                    
                    // look up the count of enablers for this tile
                    var enablerCounts = neighbourNode.solverNodeEnablers[compatibleTile]
                    
                    let oppositeDirection = direction.opposite
                    
                    // check if we're about to decrement this to 0
                    if enablerCounts.byDirection[oppositeDirection] == 1 {
//                        print("     Enabler for \(compatibleTile) in direction \(oppositeDirection) only had 1 enabler to go! Disabling it...")
                        
                        if !enablerCounts.containsAnyZero {
                            neighbourNode.removeTile(elementID: compatibleTile, frequency: frequency!)
                            
                            // check for contradiction
                            if neighbourNode.possibleElementsCount == 0 {
                                
                                let outputGrid = createOutputGrid()
                                
                                for row in outputGrid {
                                    print(row)
                                }
                                
                                throw WFCErrors.ImpossibleSolution
                            }
                            
                            // Add to the heap
                            let entropy = neighbourNode.calculateEntropy(frequency: frequency!)
                            let heapElement = WFCTilesNodeHeapElement(entropy: entropy, coord: neighbourCoord)
                            entropyHeap!.enqueue(heapElement)
//                            print("     Adding node at \(neighbourCoord) with entropy \(entropy)")
                            
                            // If our neighbour is not collapsed, add the element removal to the queue
                            if !neighbourNode.collapsed {
//                                print("     Pushing \(compatibleTile), \(neighbourCoord) removal")
                                nodeRemovalQueue!.append(WFCTilesRemovalUpdate(elementID: compatibleTile, coord: neighbourCoord))
                            }
                        }
                    }
                    
//                    print("     Enabler for \(compatibleTile) had \(enablerCounts.byDirection[oppositeDirection]!). Now it has \(enablerCounts.byDirection[oppositeDirection]! - 1)")
                    enablerCounts.byDirection[oppositeDirection] = enablerCounts.byDirection[oppositeDirection]! - 1
                    
                    neighbourNode.solverNodeEnablers[compatibleTile] = enablerCounts
                }
                
//                print("Neighbour node still has \(neighbourNode.possibleElementsCount) possible elements")
            }
        }
    }

    internal func run() throws {
        while nodesToCollapse! > 0 {
//            print("Still \(nodesToCollapse!) nodesToCollapse...")
            
            let (i, j) = try self.chooseNode()
            
//            print("Collapsing node at (\(i), \(j))")
            collapseNode(at: (i, j))
            
//            print("Propagating...")
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
