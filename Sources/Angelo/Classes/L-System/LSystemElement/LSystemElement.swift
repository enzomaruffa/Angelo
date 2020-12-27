//
//  LSystemElement.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

/// An element that can be used in an LSystem
public class LSystemElement {
    
    /// The element's string representation
    public let string: String
    
    /// The parameters from the element
    internal let parameters: [String: Any]?

    /// Creates a new LSystemElement
    /// - Parameter string: The string representation of this element
    /// - Note: The parameters dict is set to nil in this case
    public init(_ string: String) {
        self.string = string
        self.parameters = nil
    }
    
    /// Creates a new LSystemElement
    /// - Parameters:
    ///   - string: The string representation of this element
    ///   - parameters: The intial parameters dictionary for this element
    public init(_ string: String, parameters: [String: Any]) {
        self.string = string
        self.parameters = parameters
    }
    
    /// Returns the value of a parameter in the dictionary
    /// - Parameter name: The parameter index in the dictionary
    /// - Returns: The value in the dictionary "named" index
    public func getParameter(named name: String) -> Any? {
        guard let parameters = parameters else { return nil }
        return parameters[name]
    }
    
    /// Returns the keys of the parameters dictionary
    /// - Returns: A list of strings if the dictionary exists. Nil if element has no parameters dictionary
    public func parameterKeys() -> [String]? {
        guard let parameters = parameters else { return nil }
        return parameters.keys.map({ $0 })
    }
    
    
    /// Transform an LSystemElement, with its parameters, into a String
    /// - Parameters:
    ///   - startDelimiter: The delimiter that preceds the element parameters
    ///   - keyValueSeparator: The separator to use between key and value in the parameters
    ///   - separator: The separator to use between each parameter
    ///   - endDelimiter: The delimiter that marks the end of the element parameters
    /// - Returns: The string of an LSystemElement with it's parameters
    public func stringWithParameters(startDelimiter: String,
                                     keyValueSeparator: String,
                                     separator: String,
                                     endDelimiter: String) -> String {
        guard let parameterKeys = parameterKeys() else {
            return string
        }
        
        guard !parameterKeys.compactMap({ getParameter(named: $0) as? CustomStringConvertible }).isEmpty else {
            return string
        }
        
        var returnString = string + startDelimiter
        
        for key in parameterKeys {
            guard let convertible = getParameter(named: key) as? CustomStringConvertible else { continue }
            returnString += key
            returnString += keyValueSeparator
            returnString += convertible.description
            
            if key != parameterKeys.last {
                returnString += separator
            }
        }
        
        returnString += endDelimiter
        
        return returnString
    }
}

extension LSystemElement: Equatable {
    
    /// Checks if two LSystemElements are equal
    /// - Parameters:
    ///   - lhs: An LSystemElement
    ///   - rhs: Another LSystemElement
    /// - Returns: True if both have the same String representation. False if they are different.
    public static func == (lhs: LSystemElement, rhs: LSystemElement) -> Bool {
        lhs.string == rhs.string
    }
}
