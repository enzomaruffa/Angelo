//
//  WeightedList.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

/// A list in which elements can have different weights
public class WeightedList<Element> {
    
    /// The count of elements in the list
    public var count: Int {
        elements.count
    }
    
    /// A `Bool` that returns if the list is empty
    public var isEmpty: Bool {
        count == 0
    }
    
    /// The sum of the weight of all elements in th list
    public var totalWeight: Double {
        elements.reduce(Double(0), { $0 + $1.weight })
    }
    
    /// The list of elements with its respective weights
    internal var elements: [(element: Element, weight: Double)]
    
    /// Creates an empty list
    public init() {
        elements = []
    }
    
    /// Sorts the internal elements list by weight
    internal func sortByWeight() {
        elements.sort(by: { $0.weight < $1.weight })
    }
    
    /// Adds a new element into the `WeightedList`
    /// - Parameter element: The element to be added
    /// - Note: The weight, in this case, defaults to 1
    public func add(_ element: Element) {
        try! add(element, weight: 1)
    }
    
    /// Adds a new element into the `WeightedList`
    /// - Parameters:
    ///   - element: The element to be added
    ///   - weight: The weight of the element
    /// - Throws: Throws a `WeightedListErrors.InvalidWeight` if the weight is `<= 0`
    public func add(_ element: Element, weight: Double) throws {
        guard weight > 0 else { throw WeightedListErrors.InvalidWeight }
        elements.append((element: element, weight: weight))
        
        // Keep the list sorted
        sortByWeight()
    }
    
    
    /// Gets a random element from the list
    /// - Returns: A randomly selected element from the list
    public func randomElement() -> Element? {
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
    
    /// Removes all elements from the list
    public func removeAll() {
        elements.removeAll()
    }
}

/// The errors that the `WeightedList` can throw
enum WeightedListErrors: Error {
    /// Error thrown if an element with invalid weight is added into the list
    case InvalidWeight
}
