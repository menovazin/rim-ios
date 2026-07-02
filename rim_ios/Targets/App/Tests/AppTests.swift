import ComposableArchitecture
import XCTest

@testable import App
@testable import Features

final class AppTests: XCTestCase {
    func test_appCompilesAndLinks() {
        // Smoke test: the App target and its TCA/DesignSystem dependencies link.
        XCTAssertTrue(true)
    }

    func test_appRootRendersBeforeRouting() {
        // The AppRoot store initializes with no destination.
        let state = AppRoot.State()
        XCTAssertNil(state.destination)
        XCTAssertFalse(state.hasAppeared)
    }
}
