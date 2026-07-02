import ComposableArchitecture
import XCTest

@testable import Features

final class ShellReducerTests: XCTestCase {
    @MainActor
    func test_signOutDelegatesLogout() async {
        let store = TestStore(initialState: ShellReducer.State()) {
            ShellReducer()
        }

        await store.send(.signOutTapped)
        await store.receive(\.delegate.logout)
    }
}
