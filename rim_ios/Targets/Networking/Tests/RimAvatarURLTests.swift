import XCTest
@testable import Networking

final class RimAvatarURLTests: XCTestCase {
    func test_fixing_prependsApiBase_forRelativePath() {
        let relative = "/character/avatar/1.jpeg"
        XCTAssertEqual(
            RimAvatarURL.fixing(relative),
            "\(ApiConstants.baseUrl)\(relative)"
        )
    }

    func test_fixing_returnsAbsoluteURL_unchanged() {
        let url = "\(ApiConstants.baseUrl)/character/avatar/1.jpeg"
        XCTAssertEqual(RimAvatarURL.fixing(url), url)
    }

    func test_fixing_returnsEmptyString_unchanged() {
        XCTAssertEqual(RimAvatarURL.fixing(""), "")
    }

    func test_fromId_buildsURL_fromApiBase() {
        XCTAssertEqual(
            RimAvatarURL.fromId(42),
            URL(string: "\(ApiConstants.characterEndpoint)/avatar/42.jpeg")
        )
    }
}
