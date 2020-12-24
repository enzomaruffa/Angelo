import XCTest
@testable import Angelo

final class AngeloTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Angelo().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
