import ComposableArchitecture
import XCTest

@testable import Features

final class LoginReducerTests: XCTestCase {
    @MainActor
    func test_namedSignIn() async {
        let store = TestStore(initialState: LoginReducer.State(name: "Morty")) {
            LoginReducer()
        } withDependencies: {
            $0.tokenStore = .test()
        }

        await store.send(.signInTapped) {
            $0.isSubmitting = true
        }

        await store.receive(\.saveTokenResponse) {
            $0.isSubmitting = false
        }
        await store.receive(\.delegate.loginFinished)
    }

    @MainActor
    func test_emptyNameUsesGuest() async {
        let store = TestStore(initialState: LoginReducer.State(name: "")) {
            LoginReducer()
        } withDependencies: {
            $0.tokenStore = .test()
        }

        await store.send(.signInTapped) {
            $0.isSubmitting = true
        }

        await store.receive(\.saveTokenResponse) {
            $0.isSubmitting = false
        }
        await store.receive(\.delegate.loginFinished)
    }

    @MainActor
    func test_whitespaceNameUsesGuest() async {
        let store = TestStore(initialState: LoginReducer.State(name: "   ")) {
            LoginReducer()
        } withDependencies: {
            $0.tokenStore = .test()
        }

        await store.send(.signInTapped) {
            $0.isSubmitting = true
        }

        await store.receive(\.saveTokenResponse) {
            $0.isSubmitting = false
        }
        await store.receive(\.delegate.loginFinished)
    }

    @MainActor
    func test_secondTapWhileSubmittingIsIgnored() async {
        let store = TestStore(initialState: LoginReducer.State(name: "Rick", isSubmitting: true)) {
            LoginReducer()
        }

        await store.send(.signInTapped)
    }
}
