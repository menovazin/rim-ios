import ComposableArchitecture
import DesignSystem
import Foundation

// MARK: - ThemeStore dependency

/// Persists the active `RimColorScheme` (`UserDefaults` key `"theme"`).
///
/// Mirrors the canonical Flutter `ThemeService` which saves the active theme
/// in `SharedPreferences` under key `"theme"`. This is intentionally separate
/// from `RimThemeController` so persistence can be mocked in tests.
@DependencyClient
public struct ThemeStore: Sendable {
    var load: @Sendable () -> RimColorScheme?
    var save: @Sendable (RimColorScheme) -> Void
}

extension ThemeStore: TestDependencyKey {
    /// Default test value traps on use, surfacing missing wiring in tests.
    public static let testValue = ThemeStore()
    /// In-memory test client for previews and tests that don't care about persistence.
    public static let previewValue = ThemeStore(
        load: { nil },
        save: { _ in }
    )
}

extension DependencyValues {
    public var themeStore: ThemeStore {
        get { self[ThemeStore.self] }
        set { self[ThemeStore.self] = newValue }
    }
}

// MARK: - In-memory test helpers

extension ThemeStore {
    /// Returns a deterministic in-memory test client seeded with a scheme.
    ///
    /// Tests inject this so they never touch `UserDefaults`:
    /// ```swift
    /// let store = TestStore(initialState: ...) { ShellReducer() }
    /// store.dependencies.themeStore = .test(scheme: .light)
    /// ```
    public static func test(scheme: RimColorScheme? = nil) -> ThemeStore {
        let box = Box(initial: scheme)
        return ThemeStore(
            load: { box.current },
            save: { box.current = $0 }
        )
    }

    /// Returns an in-memory client with no stored scheme.
    public static var inMemory: ThemeStore { .test(scheme: nil) }

    private final class Box: @unchecked Sendable {
        var current: RimColorScheme?
        init(initial: RimColorScheme?) { self.current = initial }
    }
}

// MARK: - UserDefaults live implementation

private enum ThemeStoreConstants {
    static let key = "theme"
}

extension ThemeStore {
    /// Production (live) `ThemeStore` backed by `UserDefaults`.
    public static let live: ThemeStore = {
        ThemeStore(
            load: {
                guard let raw = UserDefaults.standard.string(forKey: ThemeStoreConstants.key) else { return nil }
                return RimColorScheme(rawValue: raw)
            },
            save: { scheme in
                UserDefaults.standard.set(scheme.rawValue, forKey: ThemeStoreConstants.key)
            }
        )
    }()
}
