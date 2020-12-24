import XCTest

import AngeloTests

var tests = [XCTestCaseEntry]()
tests += AngeloTests.allTests()
tests += WeightedListTests.allTests()
XCTMain(tests)
