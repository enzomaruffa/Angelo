import XCTest
@testable import Angelo

final class AngeloTests: XCTestCase {
    
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
    
    // ======== L-System tests
    
    // LSystemElementParametricComponent Tests
    func testLSystemElementParametricComponentCreation() {
        let originalHeight = 1
        
        let component = LSystemElementParametricComponent(parameters: ["height": originalHeight])
        
        let height = component.getParameter("height") as? Int
        
        XCTAssertEqual(originalHeight, height)
    }
    
    func testLSystemElementParametricComponentNotExists() {
        let component = LSystemElementParametricComponent(parameters: [:])
        
        XCTAssertNil(component.getParameter("height"))
    }
    
    func testLSystemElementParametricComponentEquals() {
        let component = LSystemElementParametricComponent(parameters: ["height": 1])
        let component2 = LSystemElementParametricComponent(parameters: ["height": 2])
        
        XCTAssertTrue(component == component2)
    }
    
    func testLSystemElementParametricComponentDifferent() {
        let component = LSystemElementParametricComponent(parameters: ["height": 1])
        let component2 = LSystemElementParametricComponent(parameters: ["weight": 1])
        
        XCTAssertFalse(component == component2)
    }
    
    
    // LSystemElement Tests
    func testLSystemElementCreation() {
        let str = "a"
        let element = LSystemElement(str)
        XCTAssertEqual(element.string, str)
    }
    
    func testLSystemElementParameterCreation() {
        let originalHeight = 1
        
        let str = "a"
        let parametricComponent = LSystemElementParametricComponent(parameters: ["height": originalHeight])
        let element = LSystemElement(str, parametricComponent: parametricComponent)
        
        let height = element.parametricComponent?.getParameter("height")
        XCTAssertEqual(originalHeight, height as! Int)
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
    
    // LSystemElementTransition Tests
    func testLSystemElementTransitionCreation() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemElementTransition(referenceInput: input, referenceOutput: output) { (element) -> (LSystemElement) in
            return LSystemElement("b")
        }
        
        XCTAssertEqual(input.string, elementTransition.referenceInput.string)
        XCTAssertEqual(output.string, elementTransition.referenceOutput.string)
    }
    
    func testLSystemElementTransitionValid() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemElementTransition(referenceInput: input, referenceOutput: output) { (element) -> (LSystemElement) in
            return LSystemElement("b")
        }
        
        XCTAssertTrue(elementTransition.valid(forInput: input, output: output))
    }
    
    func testLSystemElementTransitionInvalid() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemElementTransition(referenceInput: input, referenceOutput: output) { (element) -> (LSystemElement) in
            return LSystemElement("b")
        }
        
        XCTAssertFalse(elementTransition.valid(forInput: input, output: input))
    }
    
    func testLSystemElementTransitionResult() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemElementTransition(referenceInput: input, referenceOutput: output) { (element) -> (LSystemElement) in
            return LSystemElement("b")
        }
        
        XCTAssertEqual(output, elementTransition.performTransition(input: input))
    }
    
    func testLSystemElementTransitionResult2() {
        let input = LSystemElement("a", parametricComponent: LSystemElementParametricComponent(parameters: ["height": 1]))
        let output = LSystemElement("b", parametricComponent: LSystemElementParametricComponent(parameters: ["weight": 10]))
        
        let elementTransition = LSystemElementTransition(referenceInput: input, referenceOutput: output) { (element) -> (LSystemElement) in
            let height = element.parametricComponent?.getParameter("height") as! Int
            let weight = height * 10
            let parametricComponent = LSystemElementParametricComponent(parameters: ["weight": weight])
            return LSystemElement("b", parametricComponent: parametricComponent)
        }
        
        XCTAssertEqual(output, elementTransition.performTransition(input: input))
    }
    
    // LSystemRuleParametricComponent tests
    func testLSystemRuleParametricComponentCreation() {
        let component = LSystemRuleParametricComponent { (component) -> Bool in
            let height = component.getParameter("height") as! Int
            return height < 5
        }
        
        XCTAssertNotNil(component)
    }
    
    // LSystemRuleContextAwareComponent tests
    func testLSystemRuleContextAwareComponentCreation() {
        let component = LSystemRuleContextAwareComponent(delegate: nil) { (delegate) -> Bool in
            delegate.iterations > 5
        }
        
        XCTAssertNotNil(component)
    }
    
    func testLSystemRuleContextAwareComponentThrows() {
        let component = LSystemRuleContextAwareComponent(delegate: nil) { (delegate) -> Bool in
            delegate.iterations > 5
        }
        
        XCTAssertThrowsError(try component.isValid())
    }
    
    // LSystemRule tests
    func testLSystemRuleCreationSucceeds() {
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"))
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNil(rule.parametricComponent)
        XCTAssertNil(rule.contextAwareComponent)
    }
    
    func testLSystemRuleCreationWithParametricComponent() {
        let component = LSystemRuleParametricComponent { (elementComponent) -> Bool in
            let weight = elementComponent.getParameter("weight") as! Int
            return weight > 5
        }
        
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"), weight: 1, parametricComponent: component)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNotNil(rule.parametricComponent)
        XCTAssertNil(rule.contextAwareComponent)
    }
    
    func testLSystemRuleCreationWithContextAwareComponent() {
        let component = LSystemRuleContextAwareComponent(delegate: nil) { (delegate) -> Bool in
            true
        }
        
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"), weight: 1, contextAwareComponent: component)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNil(rule.parametricComponent)
        XCTAssertNotNil(rule.contextAwareComponent)
    }
    
    func testLSystemRuleFullCreation() {
        let parametricComponent = LSystemRuleParametricComponent { (elementComponent) -> Bool in
            let weight = elementComponent.getParameter("weight") as! Int
            return weight > 5
        }
        
        let contextAwareComponent = LSystemRuleContextAwareComponent(delegate: nil) { (delegate) -> Bool in
            true
        }
        
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"), weight: 1, parametricComponent: parametricComponent, contextAwareComponent: contextAwareComponent)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNotNil(rule.parametricComponent)
        XCTAssertNotNil(rule.contextAwareComponent)
    }
    
    // With parametric component
    func testLSystemRuleParametricValid() {

    }
    
    // No components
    func testLSystemRuleSimpleApply() {

    }
    
    // No components
    func testLSystemRuleSimpleApplyWithParameters() {

    }
    
    static var allTests = [
        // ====== Weighted List tests
        ("testWeightedListCreation", testWeightedListCreationIsEmpty),
        ("testWeightedListAddOne", testWeightedListAddOne),
        ("testWeightedListAddRandom", testWeightedListAddRandom),
        ("testWeightedListAddInvalidProbability", testWeightedListAddInvalidProbability),
        ("testWeightedListRandomSingleElement", testWeightedListRandomSingleElement),
        ("testWeightedListBigDifferenceProbability", testWeightedListBigDifferenceProbability),
        ("testWeightedListSimilarProbability", testWeightedListSimilarProbability),
        ("testWeightedListRemoveAll", testWeightedListRemoveAll),
        
        // ===== L-System tests
        
    ]
}
