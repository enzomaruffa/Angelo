//
//  HeapTests.swift
//  Angelo_Tests
//
//  Created by Enzo Maruffa Moreira on 31/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Angelo

class HeapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // ======== Heap tests
    func testHeapCreationIsEmpty() {
        let heap = Heap<Int>(priorityFunction: >)
        XCTAssertEqual(heap.count, 0)
    }
    
    func testHeapAddOne() {
        let heap = Heap<Int>(priorityFunction: >)
        heap.enqueue(1)
        XCTAssertEqual(heap.count, 1)
        XCTAssertEqual(heap.peek()!, 1)
    }
    
    func testHeapAddRandom() {
        let random = Int.random(in: 30...50)
        
        let heap = Heap<Int>(priorityFunction: >)
        (0..<random).forEach({ heap.enqueue($0) })
        
        XCTAssertEqual(heap.count, random)
    }
    
    func testHeapFullTests() {
        let heap = Heap<Int>(elements: [1, 2, 3, 4, 5], priorityFunction: >)
        
        XCTAssertEqual(heap.count, 5)
        XCTAssertEqual(heap.peek(), 5)
        
        heap.enqueue(10)
        
        XCTAssertEqual(heap.count, 6)
        XCTAssertEqual(heap.peek(), 10)
        
        let ten = heap.dequeue()
        XCTAssertEqual(ten, 10)
        
        XCTAssertEqual(heap.count, 5)
        XCTAssertEqual(heap.peek(), 5)
    }
}
