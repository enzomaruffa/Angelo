//
//  WeightedListTests.swift
//  Angelo_Tests
//
//  Created by Enzo Maruffa Moreira on 27/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Angelo

class WeightedListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // ======== Weighted List tests
    func testWeightedListCreationIsEmpty() {
        let list = WeightedList<Int>()
        XCTAssertEqual(list.count, 0)
    }
    
    func testWeightedListAddOne() {
        let list = WeightedList<Int>()
        list.add(1)
        XCTAssertEqual(list.count, 1)
    }
    
    func testWeightedListAddRandom() {
        let random = Int.random(in: 30...50)
        
        let list = WeightedList<Int>()
        (0..<random).forEach({ list.add($0) })
        
        XCTAssertEqual(list.count, random)
    }
    
    func testWeightedListAddInvalidProbability() {
        let list = WeightedList<Int>()
        XCTAssertThrowsError(try list.add(1, weight: -1))
    }
    
    func testWeightedListRandomSingleElement() {
        let list = WeightedList<Int>()
        list.add(20)
        let element = list.randomElement()
        
        XCTAssertEqual(element, 20)
    }
    
    // NOTE: This test might fail due to stochastic reasons
    func testWeightedListBigDifferenceProbability() {
        let list = WeightedList<Int>()
        
        let elementToSelect = 1000
        
        try? list.add(1, weight: 1)
        try? list.add(1000, weight: 1000)
        
        let elements = (Int(0)..<elementToSelect).map({ _ in list.randomElement() })
        
        var occurences = 0
        for element in elements {
            if element == 1 {
                occurences += 1
            }
        }
        
        XCTAssertLessThan(occurences, 5)
    }
    
    // NOTE: This test might fail due to stochastic reasons
    func testWeightedListSimilarProbability() {
        let list = WeightedList<Int>()
        
        let elementToAddCount = 10
        let elementToSelect = 1000
        
        (Int(0)..<elementToAddCount).forEach({ list.add($0) })
        
        let elements = (Int(0)..<elementToSelect).map({ _ in list.randomElement() })
        
        let occurenceForElement = (Int(0)..<elementToAddCount).map({ element in
            elements.filter({ $0 == element }).count
        })
        
        let ratios = occurenceForElement.map({ $0/elementToSelect })
        
        guard let minRatio = ratios.min(),
              let maxRatio = ratios.max() else {
            XCTAssertNotNil(ratios.min())
            XCTAssertNotNil(ratios.max())
            return
        }
        
        XCTAssertLessThan(maxRatio, 200)
        XCTAssertLessThan(minRatio, 50)
    }
    
    func testWeightedListRemoveAll() {
        let list = WeightedList<Int>()
        
        list.add(1)
        list.add(2)
        list.add(3)
        
        list.removeAll()
        
        XCTAssertTrue(list.isEmpty)
    }
}
