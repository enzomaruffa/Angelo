//
//  LSystemElementParametricComponent.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

struct LSystemElementParametricComponent {
    var parameters: [String: Any]
    
    func getParameter(_ name: String) -> Any? {
        return parameters[name]
    }
}

extension LSystemElementParametricComponent: Equatable {
    static func == (lhs: LSystemElementParametricComponent, rhs: LSystemElementParametricComponent) -> Bool {
        lhs.parameters.keys.sorted() == rhs.parameters.keys.sorted()
    }
}
