//
//  LSystemElementTransitionTests.swift
//  Angelo_Tests
//
//  Created by Enzo Maruffa Moreira on 27/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Angelo

class LSystemElementTransitionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // LSystemElementTransition Tests
    func testLSystemElementTransitionCreation() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemParametersTransition(referenceInputString: input.string, referenceOutputString: output.string) { (parameters) -> ([String : Any]) in
            return [:]
        }
        
        XCTAssertEqual(input.string, elementTransition.referenceInputString)
        XCTAssertEqual(output.string, elementTransition.referenceOutputString)
    }
    
    func testLSystemElementTransitionValid() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemParametersTransition(referenceInputString: input.string, referenceOutputString: output.string) { (parameters) -> ([String: Any]) in
            return [:]
        }
        
        XCTAssertTrue(elementTransition.isValid(forInput: input.string, output: output.string))
    }
    
    func testLSystemElementTransitionInvalid() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemParametersTransition(referenceInputString: input.string, referenceOutputString: output.string) { (parameters) -> ([String: Any]) in
            return [:]
        }
        
        XCTAssertFalse(elementTransition.isValid(forInput: input.string, output: input.string))
    }
    
    func testLSystemElementTransitionResult() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemParametersTransition(referenceInputString: input.string, referenceOutputString: output.string) { (parameters) -> ([String: Any]) in
            let number = parameters["int"] as! Int * 5
            return ["int": number]
        }
        
        XCTAssertEqual(output, elementTransition.performTransition(inputElement: input))
    }
    
    func testLSystemElementTransitionResult2() {
        let input = LSystemElement("a", parameters: ["height": 1])
        let output = LSystemElement("b", parameters: ["weight": 10])
        
        let elementTransition = LSystemParametersTransition(referenceInputString: input.string, referenceOutputString: output.string) { (parameters) -> ([String : Any]) in
            let height = parameters["height"] as! Int
            let weight = height * 10
            let newParameters = ["weight": weight]
            return newParameters
        }
        
        XCTAssertEqual(output, elementTransition.performTransition(inputElement: input))
        XCTAssertEqual(10, elementTransition.performTransition(inputElement: input).getParameter(named: "weight") as! Int)
    }
    
}

