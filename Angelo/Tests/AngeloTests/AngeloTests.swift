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
        
        XCTAssertTrue(elementTransition.isValid(forInput: input, output: output))
    }
    
    func testLSystemElementTransitionInvalid() {
        let input = LSystemElement("a")
        let output = LSystemElement("b")
        
        let elementTransition = LSystemElementTransition(referenceInput: input, referenceOutput: output) { (element) -> (LSystemElement) in
            return LSystemElement("b")
        }
        
        XCTAssertFalse(elementTransition.isValid(forInput: input, output: input))
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
        let component = LSystemRuleContextAwareComponent() { (source) -> Bool in
            source.iterations > 5
        }
        
        XCTAssertNotNil(component)
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
        let component = LSystemRuleContextAwareComponent() { (source) -> Bool in
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
        
        let contextAwareComponent = LSystemRuleContextAwareComponent() { (source) -> Bool in
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
    
    func testLSystemRuleValid() {
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"))
        
        XCTAssertTrue(try! rule.isValid(forInputElement: LSystemElement("a")))
        XCTAssertFalse(try! rule.isValid(forInputElement: LSystemElement("b")))
    }
    
    // With parametric component to test if returns as valid
    func testLSystemRuleParametricValid() {
        let parametricComponent = LSystemRuleParametricComponent { (elementComponent) -> Bool in
            let weight = elementComponent.getParameter("weight") as! Int
            return weight > 5
        }
        
        let elementParametricComponent = LSystemElementParametricComponent(parameters: ["weight": 20])
        let inputElement = LSystemElement("a", parametricComponent: elementParametricComponent)
        
        let rule = LSystemRule(input: inputElement, output: LSystemElement("b"), weight: 1, parametricComponent: parametricComponent)
        
        let elementParametricComponent2 = LSystemElementParametricComponent(parameters: ["weight": 2])
        let inputElement2 = LSystemElement("a", parametricComponent: elementParametricComponent2)
        
        XCTAssertTrue(try! rule.isValid(forInputElement: inputElement))
        XCTAssertFalse(try! rule.isValid(forInputElement: inputElement2))
    }
    
    // Rule with no components
    func testLSystemRuleSimpleApply() {
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"))
        let input = LSystemElement("a")
        
        XCTAssertTrue(try! rule.isValid(forInputElement: input))
        
        let outputs = try! rule.apply(inputElement: input)
        
        XCTAssertEqual(1, outputs.count)
        XCTAssertNotNil(outputs.first)
        XCTAssertEqual(LSystemElement("b"), outputs.first!)
    }
    
    // Rule with parametric components
    func testLSystemRuleSimpleApplyWithParameters() {
        let rule = LSystemRule(
            input: LSystemElement("a",
                                  parametricComponent:
                                    LSystemElementParametricComponent(
                                        parameters: ["height": 1])),
            output: LSystemElement("b",
                                   parametricComponent:
                                    LSystemElementParametricComponent(
                                        parameters: ["weight": 10]))
        )
        
        let transition = LSystemElementTransition(
            referenceInput: LSystemElement("a",
                                           parametricComponent:
                                            LSystemElementParametricComponent(
                                                parameters: ["height": 1])),
            referenceOutput: LSystemElement("b",
                                            parametricComponent:
                                                LSystemElementParametricComponent(
                                                    parameters: ["weight": 1])))
        { (input) -> (LSystemElement) in
            let aHeight = input.parametricComponent?.getParameter("height") as! Int
            return LSystemElement("b", parametricComponent: LSystemElementParametricComponent(parameters: ["weight": aHeight * 10]))
        }
        
        let input = LSystemElement("a", parametricComponent:
                                    LSystemElementParametricComponent(
                                        parameters: ["height": 1]))
        
        XCTAssertTrue(try! rule.isValid(forInputElement: input))
        
        let outputs = try! rule.apply(inputElement: input, transitions: [transition])
        
        let referenceOutput = LSystemElement("b",
                                             parametricComponent:
                                                LSystemElementParametricComponent(
                                                    parameters: ["weight": 10]))
        XCTAssertEqual(1, outputs.count)
        XCTAssertEqual(referenceOutput, outputs.first!)
        XCTAssertEqual(referenceOutput.parametricComponent?.getParameter("weight") as! Int, outputs.first?.parametricComponent?.getParameter("weight") as! Int)
    }
    
    // LSystem
    func testLSystemCreation() {
        let system = LSystem()
        
        XCTAssertEqual(0, system.rules.count)
        XCTAssertEqual(0, system.transitions.count)
        
        let rule = LSystemRule(
            input: LSystemElement("a",
                                  parametricComponent:
                                    LSystemElementParametricComponent(
                                        parameters: ["height": 1])),
            output: LSystemElement("b",
                                   parametricComponent:
                                    LSystemElementParametricComponent(
                                        parameters: ["weight": 10]))
        )
        
        system.add(rule: rule)
        XCTAssertEqual(1, system.rules.count)
        
        let transition = LSystemElementTransition(
            referenceInput: LSystemElement("a",
                                           parametricComponent:
                                            LSystemElementParametricComponent(
                                                parameters: ["height": 1])),
            referenceOutput: LSystemElement("b",
                                            parametricComponent:
                                                LSystemElementParametricComponent(
                                                    parameters: ["weight": 1])))
        { (input) -> (LSystemElement) in
            let aHeight = input.parametricComponent?.getParameter("height") as! Int
            return LSystemElement("b", parametricComponent: LSystemElementParametricComponent(parameters: ["weight": aHeight * 10]))
        }
        
        system.add(transition: transition)
        XCTAssertEqual(1, system.transitions.count)
    }
    
    func testLSystemSimpleCreation() {
        let rule1 = LSystemRule(input: LSystemElement("a"), outputs: [LSystemElement("a"), LSystemElement("b")])
        let rule2 = LSystemRule(input: LSystemElement("a"), outputs: [LSystemElement("a"), LSystemElement("c")])
        let rule3 = LSystemRule(input: LSystemElement("b"), outputs: [LSystemElement("d"), LSystemElement("b")])
        
        let system = LSystem(rules: [rule1, rule2, rule3], transitions: [])
        
        XCTAssertEqual(3, system.rules.count)
    }
    
    func testLSystemProducing() {
        let rule1 = LSystemRule(input: LSystemElement("a"), outputs: [LSystemElement("a"), LSystemElement("b")])
        
        let system = LSystem(rules: [rule1], transitions: [])
        
        let output = try! system.produceOutput(initialElement: LSystemElement("a"), iterations: 5)
        
        XCTAssertEqual(output.iterationsPerformed, 5)
        XCTAssertEqual(output.currentStringRepresentation, "abbbbb")
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
