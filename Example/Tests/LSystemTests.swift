//
//  LSystemTests.swift
//  Angelo_Tests
//
//  Created by Enzo Maruffa Moreira on 27/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Angelo

class LSystemTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    } 

    // LSystem
    func testLSystemCreation() {
        let system = LSystem()
        
        XCTAssertEqual(0, system.rules.count)
        XCTAssertEqual(0, system.transitions.count)
        
        let rule = LSystemRule(
            input: "a",
            output: "b"
        )
        
        system.add(rule: rule)
        XCTAssertEqual(1, system.rules.count)
        
        let transition = LSystemParametersTransition(
            referenceInputString: "a",
            referenceOutputString: "b")
        { (parameters) -> ([String : Any]) in
            let aHeight = parameters["height"] as! Int
            return ["weight": aHeight * 10]
        }
        
        system.add(transition: transition)
        XCTAssertEqual(1, system.transitions.count)
    }

    func testLSystemSimpleCreation() {
        let rule1 = LSystemRule(input: "a", outputs: ["a", "b"])
        let rule2 = LSystemRule(input: "a", outputs: ["a", "c"])
        let rule3 = LSystemRule(input: "b", outputs: ["d", "b"])
        
        let system = LSystem(rules: [rule1, rule2, rule3], transitions: [])
        
        XCTAssertEqual(3, system.rules.count)
    }

    func testLSystemProducing() {
        let system = LSystem()
        
        system.add(rule: LSystemRule(input: "a", outputs: ["a", "b"]))
        
        let output = try! system.produceOutput(inputElement: LSystemElement("a"), iterations: 5)
        
        XCTAssertEqual(output.iterations, 5)
        XCTAssertEqual(output.string, "abbbbb")
    }

    func testLSystemProducingWithContextAware() {
        let system = LSystem()
        
        let rule = try! LSystemRule(
            input: "a",
            outputs: ["a", "b"],
            weight: 1,
            contextAwareCheck: { (source, index) -> Bool in
                source.string.filter({$0 == "b"}).count < 3
            })
        system.add(rule: rule)
        
        let output = try! system.produceOutput(inputElement: LSystemElement("a"), iterations: 5)
        
        XCTAssertEqual(output.iterations, 5)
        XCTAssertEqual(output.string, "abbb")
    }

    func testLSystemProducingWithParametric() {
        let system = LSystem()
        
        let rule = try! LSystemRule(
            input: "a",
            outputs: ["a", "b"],
            weight: 1,
            parameterCheck: { (parameters) -> Bool in
                let number = parameters["number"] as! Int
                return number < 5
            })
        
        let rule2 = try! LSystemRule(
            input: "a",
            outputs: ["a", "c"],
            weight: 1,
            parameterCheck: { (parameters) -> Bool in
                let number = parameters["number"] as! Int
                return number >= 5
            })
        
        system.add(rule: rule)
        system.add(rule: rule2)
        
        system.addTransition(input: "a", output: "a") { (parameters) -> ([String : Any]) in
            let number = parameters["number"] as! Int
            return ["number": number + 1]
        }
        
        system.addTransition(input: "a", output: "b") { (parameters) -> ([String : Any]) in
            let number = parameters["number"] as! Int
            return ["humour": number*10]
        }
        
        let output = try! system.produceOutput(inputElement: LSystemElement("a", parameters: ["number": 0]), iterations: 10)
        
        XCTAssertEqual(output.iterations, 10)
        XCTAssertEqual(output.string, "acccccbbbbb")
        XCTAssertEqual(output.outputElements.first?.getParameter(named: "number") as! Int, 10)
        XCTAssertEqual(output.stringWithParameters, "a(number;10)cccccb(humour;40)b(humour;30)b(humour;20)b(humour;10)b(humour;0)")
    }

    func testLSystemProducingAlgae() {
        let system = LSystem()
        
        system.add(rule: LSystemRule(input: "a", outputs: ["a", "b"]))
        system.add(rule: LSystemRule(input: "b", output: "a"))

        var output = try! system.produceOutput(input: "a", iterations: 1)
        
        XCTAssertEqual(output.iterations, 1)
        XCTAssertEqual(output.string, "ab")
        
        output = try! system.iterate(input: output)
        
        XCTAssertEqual(output.iterations, 2)
        XCTAssertEqual(output.string, "aba")
        
        output = try! system.iterate(input: output)
        
        XCTAssertEqual(output.iterations, 3)
        XCTAssertEqual(output.string, "abaab")
        
        output = try! system.iterate(input: output)
        
        XCTAssertEqual(output.iterations, 4)
        XCTAssertEqual(output.string, "abaababa")
    }

}
