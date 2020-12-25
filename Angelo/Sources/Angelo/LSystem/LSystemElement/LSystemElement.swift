//
//  LSystemElement.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemElement {
    let string: String
    
    internal let parameters: [String: Any]?
    
    init(_ string: String) {
        self.string = string
        self.parameters = nil
    }
    
    init(_ string: String, parameters: [String: Any]) {
        self.string = string
        self.parameters = parameters
    }
    
    func getParameter(named name: String) -> Any? {
        guard let parameters = parameters else { return nil }
        return parameters[name]
    }
    
    func parameterKeys() -> [String]? {
        guard let parameters = parameters else { return nil }
        return parameters.keys.map({ $0 })
    }
}

extension LSystemElement: Equatable {
    static func == (lhs: LSystemElement, rhs: LSystemElement) -> Bool {
        lhs.string == rhs.string
    }
}
