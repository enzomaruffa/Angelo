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
    
    
    // LSystemElement Tests
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
        
        XCTAssertEqual(output, elementTransition.performTransition(input: input))
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
        
        XCTAssertEqual(output, elementTransition.performTransition(input: input))
        XCTAssertEqual(10, elementTransition.performTransition(input: input).getParameter(named: "weight") as! Int)
    }
    
    
    // LSystemRule tests
    func testLSystemRuleCreationSucceeds() {
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"))
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNil(rule.canApplyByParameters)
        XCTAssertNil(rule.canApplyByContext)
    }
    
    func testLSystemRuleCreationWithParametricComponent() {
        let canApplyByParameters: (([String: Any]) -> Bool) = { (parameters) -> Bool in
            let weight = parameters["weight"] as! Int
            return weight > 5
        }
        
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"), weight: 1, canApplyByParameters: canApplyByParameters)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNotNil(rule.canApplyByParameters)
        XCTAssertNil(rule.canApplyByContext)
    }
    
    func testLSystemRuleCreationWithContextAwareComponent() {
        let canApplyByContext: ((LSystemRuleContextAwareSource) -> Bool) = { (source) -> Bool in
            true
        }
        
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"), weight: 1, canApplyByContext: canApplyByContext)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNil(rule.canApplyByParameters)
        XCTAssertNotNil(rule.canApplyByContext)
    }
    
    func testLSystemRuleFullCreation() {
        let canApplyByParameters: (([String: Any]) -> Bool) = { (parameters) -> Bool in
            let weight = parameters["weight"] as! Int
            return weight > 5
        }
        
        let canApplyByContext: ((LSystemRuleContextAwareSource) -> Bool) = { (source) -> Bool in
            true
        }
        
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"), weight: 1, canApplyByParameters: canApplyByParameters, canApplyByContext: canApplyByContext)
        
        XCTAssertNotNil(rule)
        XCTAssertNotNil(rule.input)
        XCTAssertEqual(rule.outputs.count, 1)
        XCTAssertEqual(rule.weight, 1)
        XCTAssertNotNil(rule.canApplyByParameters)
        XCTAssertNotNil(rule.canApplyByContext)
    }
    
    func testLSystemRuleValid() {
        let rule = LSystemRule(input: LSystemElement("a"), output: LSystemElement("b"))
        
        XCTAssertTrue(try! rule.isValid(forInputElement: LSystemElement("a")))
        XCTAssertFalse(try! rule.isValid(forInputElement: LSystemElement("b")))
    }
    
    // With parametric component to test if returns as valid
    func testLSystemRuleParametricValid() {
        let canApplyByParameters: (([String: Any]) -> Bool) = { (parameters) -> Bool in
            let weight = parameters["weight"] as! Int
            return weight > 5
        }
        
        let parameters = ["weight": 20]
        let inputElement = LSystemElement("a", parameters: parameters)
        
        let rule = LSystemRule(input: inputElement, output: LSystemElement("b"), weight: 1, canApplyByParameters: canApplyByParameters)
        
        let parameters2 = ["weight": 1]
        let inputElement2 = LSystemElement("a", parameters: parameters2)
        
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
            input: LSystemElement("a"),
            output: LSystemElement("b")
        )
        
        let transition = LSystemParametersTransition(
            referenceInputString: "a",
            referenceOutputString: "b")
        { (parameters) -> ([String : Any]) in
            let aHeight = parameters["height"] as! Int
            return ["weight": aHeight * 10]
        }
        
        let input = LSystemElement("a", parameters: ["height": 1])
        
        XCTAssertTrue(try! rule.isValid(forInputElement: input))
        
        let outputs = try! rule.apply(inputElement: input, transitions: [transition])
        let referenceOutput = LSystemElement("b", parameters: ["weight": 10])
        
        XCTAssertEqual(1, outputs.count)
        XCTAssertEqual(referenceOutput, outputs.first!)
        XCTAssertEqual(referenceOutput.getParameter(named: "weight") as! Int, outputs.first?.getParameter(named: "weight") as! Int)
    }
    
    // LSystem
    func testLSystemCreation() {
        let system = LSystem()
        
        XCTAssertEqual(0, system.rules.count)
        XCTAssertEqual(0, system.transitions.count)
        
        let rule = LSystemRule(
            input: LSystemElement("a", parameters: ["height": 1]),
            output: LSystemElement("b", parameters: ["weight": 10])
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
        let rule1 = LSystemRule(input: LSystemElement("a"), outputs: [LSystemElement("a"), LSystemElement("b")])
        let rule2 = LSystemRule(input: LSystemElement("a"), outputs: [LSystemElement("a"), LSystemElement("c")])
        let rule3 = LSystemRule(input: LSystemElement("b"), outputs: [LSystemElement("d"), LSystemElement("b")])
        
        let system = LSystem(rules: [rule1, rule2, rule3], transitions: [])
        
        XCTAssertEqual(3, system.rules.count)
    }
    
    func testLSystemProducing() {
        let system = LSystem()
        
        system.addRule(input: "a", outputs: ["a", "b"])
        
        let output = try! system.produceOutput(initialElement: LSystemElement("a"), iterations: 5)
        
        XCTAssertEqual(output.iterationsPerformed, 5)
        XCTAssertEqual(output.currentStringRepresentation, "abbbbb")
    }
    
    func testLSystemProducingWithContextAware() {
        let system = LSystem()
        
        let rule = LSystemRule(
            input: LSystemElement("a"),
            outputs: [LSystemElement("a"), LSystemElement("b")],
            weight: 1,
            canApplyByContext: { (source) -> Bool in
                source.currentStringRepresentation.filter({$0 == "b"}).count < 3
            })
        system.add(rule: rule)
        
        let output = try! system.produceOutput(initialElement: LSystemElement("a"), iterations: 5)
        
        XCTAssertEqual(output.iterationsPerformed, 5)
        XCTAssertEqual(output.currentStringRepresentation, "abbb")
    }
    
    func testLSystemProducingWithParametric() {
        let system = LSystem()
        
        let rule = LSystemRule(
            input: LSystemElement("a"),
            outputs: [LSystemElement("a"), LSystemElement("b")],
            weight: 1,
            canApplyByParameters: { (parameters) -> Bool in
                let number = parameters["number"] as! Int
                return number < 5
            })
        
        let rule2 = LSystemRule(
            input: LSystemElement("a"),
            outputs: [LSystemElement("a"), LSystemElement("c")],
            weight: 1,
            canApplyByParameters: { (parameters) -> Bool in
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
        
        let output = try! system.produceOutput(initialElement: LSystemElement("a", parameters: ["number": 0]), iterations: 10)
        
        print(output)
        
        XCTAssertEqual(output.iterationsPerformed, 10)
        XCTAssertEqual(output.currentStringRepresentation, "acccccbbbbb")
        XCTAssertEqual(output.currentOutput.first?.getParameter(named: "number") as! Int, 10)
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
