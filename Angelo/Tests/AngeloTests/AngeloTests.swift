import XCTest
@testable import Angelo

final class AngeloTests: XCTestCase {
    // Weighted List tests
    func testCreationIsEmpty() {
        let list = WeightedList<Int>()
        XCTAssertEqual(list.count, 0)
    }
    
    func testAddOne() {
        let list = WeightedList<Int>()
        list.add(1)
        XCTAssertEqual(list.count, 1)
    }
    
    func testAddRandom() {
        let random = Int.random(in: 30...50)
        
        let list = WeightedList<Int>()
        (0..<random).forEach({ list.add($0) })
        
        XCTAssertEqual(list.count, random)
    }
    
    func testAddInvalidProbability() {
        let list = WeightedList<Int>()
        XCTAssertThrowsError(try list.add(1, weight: -1))
    }
    
    func testRandomSingleElement() {
        let list = WeightedList<Int>()
        list.add(20)
        let element = list.randomElement()
        
        XCTAssertEqual(element, 20)
    }
    
    // NOTE: This test might fail due to stochastic reasons
    func testBigDifferenceProbability() {
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
    func testSimilarProbability() {
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
    
    func testRemoveAll() {
        let list = WeightedList<Int>()
        
        list.add(1)
        list.add(2)
        list.add(3)
        
        list.removeAll()
        
        XCTAssertTrue(list.isEmpty)
    }

    static var allTests = [
        ("testCreation", testCreationIsEmpty),
        ("testAddOne", testAddOne),
        ("testAddRandom", testAddRandom),
        ("testAddInvalidProbability", testAddInvalidProbability),
        ("testRandomSingleElement", testRandomSingleElement),
        ("testBigDifferenceProbability", testBigDifferenceProbability),
        ("testSimilarProbability", testSimilarProbability),
        ("testRemoveAll", testRemoveAll)
    ]
}
