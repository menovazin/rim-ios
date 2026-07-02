import XCTest
@testable import Features

final class FeaturesTests: XCTestCase {
    func test_moduleName() {
        XCTAssertEqual(FeaturesModule.name, "Features")
    }
}
