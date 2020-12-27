//
//  LSystemElementTests.swift
//  Angelo_Tests
//
//  Created by Enzo Maruffa Moreira on 27/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Angelo

class LSystemElementTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLSystemElementCreation() {
        let str = "a"
        let element = LSystemElement(str)
        XCTAssertEqual(element.string, str)
    }

    func testLSystemElementParameterCreation() {
        let originalHeight = 1
        
        let str = "a"
        let parameters = ["height": originalHeight]
        let element = LSystemElement(str, parameters: parameters)
        
        let height = element.getParameter(named: "height") as? Int
        XCTAssertEqual(originalHeight, height!)
    }

    func testLSystemElementEquals() {
        let element = LSystemElement("a")
        let element2 = LSystemElement("a")
        
        XCTAssertTrue(element == element2)
    }

    func testLSystemElementDifferent() {
        let element = LSystemElement("a")
        let element2 = LSystemElement("b")
        
        XCTAssertFalse(element == element2)
    }
    
}
