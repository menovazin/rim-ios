import ComposableArchitecture
import XCTest

@testable import Features

final class AppRootTests: XCTestCase {
    @MainActor
    func test_coldLaunchWithToken_routesToShell() async {
        let store = TestStore(initialState: AppRoot.State()) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .test(token: "fake_x")
        }

        await store.send(.onAppear) {
            $0.hasAppeared = true
        }

        await store.receive(\.routeResolved) {
            $0.destination = .shell(ShellReducer.State())
        }
    }

    @MainActor
    func test_coldLaunchWithoutToken_routesToLogin() async {
        let store = TestStore(initialState: AppRoot.State()) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
        }

        await store.send(.onAppear) {
            $0.hasAppeared = true
        }

        await store.receive(\.routeResolved) {
            $0.destination = .login(LoginReducer.State())
        }
    }

    @MainActor
    func test_loginFinished_routesToShellWithoutReReadingToken() async {
        let store = TestStore(
            initialState: AppRoot.State(
                destination: .login(LoginReducer.State()),
                hasAppeared: true
            )
        ) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
        }

        await store.send(.destination(.presented(.login(.delegate(.loginFinished))))) {
            $0.destination = .shell(ShellReducer.State())
        }
    }

    @MainActor
    func test_logout_clearsTokenAndRoutesToLogin() async {
        let store = TestStore(
            initialState: AppRoot.State(
                destination: .shell(ShellReducer.State()),
                hasAppeared: true
            )
        ) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .test(token: "to_be_cleared")
        }

        await store.send(.destination(.presented(.shell(.delegate(.logout))))) {
            $0.destination = nil
        }

        await store.receive(\.routeResolved) {
            $0.destination = .login(LoginReducer.State())
        }
    }

    @MainActor
    func test_secondOnAppearDoesNotFlipDestination() async {
        var getTokenCount = 0
        let store = TestStore(
            initialState: AppRoot.State(
                destination: .login(LoginReducer.State()),
                hasAppeared: true
            )
        ) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = TokenStore(
                saveToken: { _ in },
                getToken: { getTokenCount += 1; return nil },
                clearToken: {}
            )
        }

        await store.send(.onAppear)
        XCTAssertEqual(getTokenCount, 0)
    }
}
