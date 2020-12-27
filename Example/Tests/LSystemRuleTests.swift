//
//  LSystemRuleTests.swift
//  Angelo_Tests
//
//  Created by Enzo Maruffa Moreira on 27/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Angelo

class LSystemRuleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // LSystemRule tests
    func testLSystemRuleCreationSucceeds() {
        let rule = LSystemRule(input: "a", output: "b")
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNil(rule.parameterCheck)
        XCTAssertNil(rule.contextAwareCheck)
    }

    func testLSystemRuleCreationThrows() {
        XCTAssertThrowsError(try LSystemRule(input: "a", output: "b", weight: -1))
        XCTAssertThrowsError(try LSystemRule(input: "a", output: "b", weight: 0))
    }

    func testLSystemRuleCreationWithParametricComponent() {
        let parameterCheck: (([String: Any]) -> Bool) = { (parameters) -> Bool in
            let weight = parameters["weight"] as! Int
            return weight > 5
        }
        
        let rule = try! LSystemRule(input: "a", output: "b", weight: 1, parameterCheck: parameterCheck)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNotNil(rule.parameterCheck)
        XCTAssertNil(rule.contextAwareCheck)
    }

    func testLSystemRuleCreationWithContextAwareComponent() {
        let contextAwareCheck: ((LSystemRuleContextAwareSource, Int) -> Bool) = { (source, index) -> Bool in
            true
        }
        
        let rule = try! LSystemRule(input: "a", output: "b", weight: 1, contextAwareCheck: contextAwareCheck)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNil(rule.parameterCheck)
        XCTAssertNotNil(rule.contextAwareCheck)
    }

    func testLSystemRuleFullCreation() {
        let parameterCheck: (([String: Any]) -> Bool) = { (parameters) -> Bool in
            let weight = parameters["weight"] as! Int
            return weight > 5
        }
        
        let contextAwareCheck: ((LSystemRuleContextAwareSource, Int) -> Bool) = { (source, index) -> Bool in
            true
        }
        
        let rule = try! LSystemRule(input: "a", output: "b", weight: 1, parameterCheck: parameterCheck, contextAwareCheck: contextAwareCheck)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNotNil(rule.parameterCheck)
        XCTAssertNotNil(rule.contextAwareCheck)
    }

    func testLSystemRuleValid() {
        let rule = LSystemRule(input: "a", output: "b")
        
        XCTAssertTrue(rule.isValid(forInputElement: LSystemElement("a"), elementIndex: 0))
        XCTAssertFalse(rule.isValid(forInputElement: LSystemElement("b"), elementIndex: 0))
    }

    // With parametric component to test if returns as valid
    func testLSystemRuleParametricValid() {
        let parameterCheck: (([String: Any]) -> Bool) = { (parameters) -> Bool in
            let weight = parameters["weight"] as! Int
            return weight > 5
        }
        
        let parameters = ["weight": 20]
        let inputElement = LSystemElement("a", parameters: parameters)
        
        let rule = try! LSystemRule(input: inputElement.string, output: "b", weight: 1, parameterCheck: parameterCheck)
        
        let parameters2 = ["weight": 1]
        let inputElement2 = LSystemElement("a", parameters: parameters2)
        
        XCTAssertTrue(rule.isValid(forInputElement: inputElement, elementIndex: 0))
        XCTAssertFalse(rule.isValid(forInputElement: inputElement2, elementIndex: 0))
    }

    // Rule with no components
    func testLSystemRuleSimpleApply() {
        let rule = LSystemRule(input: "a", output: "b")
        let input = LSystemElement("a")
        
        XCTAssertTrue(rule.isValid(forInputElement: input, elementIndex: 0))
        
        let outputs = rule.apply(inputElement: input)
        
        XCTAssertEqual(1, outputs.count)
        XCTAssertNotNil(outputs.first)
        XCTAssertEqual(LSystemElement("b"), outputs.first!)
    }

    // Rule with parametric components
    func testLSystemRuleSimpleApplyWithParameters() {
        let rule = LSystemRule(input: "a", output: "b")
        
        let transition = LSystemParametersTransition(
            referenceInputString: "a",
            referenceOutputString: "b")
        { (parameters) -> ([String : Any]) in
            let aHeight = parameters["height"] as! Int
            return ["weight": aHeight * 10]
        }
        
        let input = LSystemElement("a", parameters: ["height": 1])
        
        XCTAssertTrue(rule.isValid(forInputElement: input, elementIndex: 0))
        
        let outputs = rule.apply(inputElement: input, transitions: [transition])
        let referenceOutput = LSystemElement("b", parameters: ["weight": 10])
        
        XCTAssertEqual(1, outputs.count)
        XCTAssertEqual(referenceOutput, outputs.first!)
        XCTAssertEqual(referenceOutput.getParameter(named: "weight") as! Int, outputs.first?.getParameter(named: "weight") as! Int)
    }
    
}
