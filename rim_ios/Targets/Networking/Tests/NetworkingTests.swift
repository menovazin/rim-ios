import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    func test_moduleName() {
        XCTAssertEqual(NetworkingModule.name, "Networking")
    }
}
