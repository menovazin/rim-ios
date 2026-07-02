import XCTest
@testable import Models

final class ModelsTests: XCTestCase {
    func test_moduleName() {
        XCTAssertEqual(ModelsModule.name, "Models")
    }
}
