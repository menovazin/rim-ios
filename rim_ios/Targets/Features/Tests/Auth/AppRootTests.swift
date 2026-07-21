import ComposableArchitecture
import DesignSystem
import XCTest

@testable import Features

final class AppRootTests: XCTestCase {
    @MainActor
    func test_coldLaunchWithToken_routesToShell() async {
        let store = TestStore(initialState: AppRoot.State()) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .test(token: "fake_x")
            $0.themeStore = .inMemory
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
            $0.themeStore = .inMemory
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
            $0.themeStore = .inMemory
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
            $0.themeStore = .inMemory
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
            $0.themeStore = .inMemory
        }

        await store.send(.onAppear)
        XCTAssertEqual(getTokenCount, 0)
    }

    // MARK: - Theme preference

    @MainActor
    func test_onAppear_loadsPreferenceFromThemeStore() async {
        let store = TestStore(initialState: AppRoot.State(themePreference: .system)) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
            $0.themeStore = .test(preference: .light)
        }

        await store.send(.onAppear) {
            $0.hasAppeared = true
            $0.themePreference = .light
        }

        await store.receive(\.routeResolved) {
            $0.destination = .login(LoginReducer.State())
        }
    }

    @MainActor
    func test_onAppear_defaultsToSystemWhenThemeStoreEmpty() async {
        let store = TestStore(initialState: AppRoot.State(themePreference: .light)) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
            $0.themeStore = .inMemory
        }

        await store.send(.onAppear) {
            $0.hasAppeared = true
            $0.themePreference = .system
        }

        await store.receive(\.routeResolved) {
            $0.destination = .login(LoginReducer.State())
        }
    }

    @MainActor
    func test_onAppear_loadsSystemPreference() async {
        let store = TestStore(initialState: AppRoot.State(themePreference: .dark)) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
            $0.themeStore = .test(preference: .system)
        }

        await store.send(.onAppear) {
            $0.hasAppeared = true
            $0.themePreference = .system
        }

        await store.receive(\.routeResolved) {
            $0.destination = .login(LoginReducer.State())
        }
    }

    @MainActor
    func test_themeToggle_fromDarkToLightAndSaves() async {
        var saved: RimThemePreference?
        let store = TestStore(
            initialState: AppRoot.State(
                destination: .shell(ShellReducer.State()),
                hasAppeared: true,
                themePreference: .dark
            )
        ) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
            $0.themeStore = ThemeStore(
                load: { .dark },
                save: { saved = $0 }
            )
        }

        await store.send(.destination(.presented(.shell(.delegate(.themeToggleTapped))))) {
            $0.themePreference = .light
        }

        XCTAssertEqual(saved, .light)
    }

    @MainActor
    func test_themeToggle_fromLightToDark() async {
        var saved: RimThemePreference?
        let store = TestStore(
            initialState: AppRoot.State(
                destination: .shell(ShellReducer.State()),
                hasAppeared: true,
                themePreference: .light
            )
        ) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
            $0.themeStore = ThemeStore(
                load: { .light },
                save: { saved = $0 }
            )
        }

        await store.send(.destination(.presented(.shell(.delegate(.themeToggleTapped))))) {
            $0.themePreference = .dark
        }

        XCTAssertEqual(saved, .dark)
    }

    @MainActor
    func test_themeToggle_fromSystemToDark() async {
        var saved: RimThemePreference?
        let store = TestStore(
            initialState: AppRoot.State(
                destination: .shell(ShellReducer.State()),
                hasAppeared: true,
                themePreference: .system
            )
        ) {
            AppRoot()
        } withDependencies: {
            $0.tokenStore = .inMemory
            $0.themeStore = ThemeStore(
                load: { .system },
                save: { saved = $0 }
            )
        }

        await store.send(.destination(.presented(.shell(.delegate(.themeToggleTapped))))) {
            $0.themePreference = .dark
        }

        XCTAssertEqual(saved, .dark)
    }
}
