//
//  LSystemElement.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

public class LSystemElement {
    public let string: String
    
    internal let parameters: [String: Any]?
    
    public init(_ string: String) {
        self.string = string
        self.parameters = nil
    }
    
    public init(_ string: String, parameters: [String: Any]) {
        self.string = string
        self.parameters = parameters
    }
    
    public func getParameter(named name: String) -> Any? {
        guard let parameters = parameters else { return nil }
        return parameters[name]
    }
    
    public func parameterKeys() -> [String]? {
        guard let parameters = parameters else { return nil }
        return parameters.keys.map({ $0 })
    }
    
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
    public static func == (lhs: LSystemElement, rhs: LSystemElement) -> Bool {
        lhs.string == rhs.string
    }
}
