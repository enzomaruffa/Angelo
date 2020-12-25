//
//  LSystemElement.swift
//  
//
//  Created by Enzo Maruffa Moreira on 24/12/20.
//

import Foundation

class LSystemElement {
    let string: String
    
    let parametricComponent: LSystemElementParametricComponent?
    
    init(_ string: String) {
        self.string = string
        self.parametricComponent = nil
    }
    
    init(_ string: String, parametricComponent: LSystemElementParametricComponent) {
        self.string = string
        self.parametricComponent = parametricComponent
    }
}

extension LSystemElement: Equatable {
    static func == (lhs: LSystemElement, rhs: LSystemElement) -> Bool {
        lhs.string == rhs.string && lhs.parametricComponent == rhs.parametricComponent
    }
}
