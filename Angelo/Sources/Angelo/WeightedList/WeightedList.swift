//
//  WeightedList.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class WeightedList<Element> {
    
    var count: Int {
        elements.count
    }
    
    var isEmpty: Bool {
        count == 0
    }
    
    var totalWeight: Double {
        elements.reduce(Double(0), { $0 + $1.weight })
    }
    
    internal var elements: [(element: Element, weight: Double)]
    
    init() {
        elements = []
    }
    
    internal func sortByWeight() {
        elements.sort(by: { $0.weight < $1.weight })
    }
    
    func add(_ element: Element) {
        try! add(element, weight: 1)
    }
    
    func add(_ element: Element, weight: Double) throws {
        guard weight > 0 else { throw WeightedListErrors.InvalidWeight }
        elements.append((element: element, weight: weight))
        
        // Keep the list sorted
        sortByWeight()
    }
    
    func randomElement() -> Element? {
        guard !isEmpty else {
            return nil
        }
        
        let totalWeight = self.totalWeight
        let randomWeight = Double.random(in: 0..<totalWeight)
        
        var currentWeight = Double(0)
        
        for element in elements {
            // Add the weight for the first element before veryfing if the total weight so far is bigger than the random weight.
            currentWeight += element.weight
            
            if currentWeight > randomWeight {
                return element.element
            }
        }
        return nil
    }
    
    func removeAll() {
        elements.removeAll()
    }
}

enum WeightedListErrors: Error {
    case InvalidWeight
}
