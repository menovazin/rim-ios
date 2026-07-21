import ComposableArchitecture
import DesignSystem
import Foundation

// MARK: - ThemeStore dependency

/// Persists the user `RimThemePreference` (`UserDefaults` key `"theme"`).
@DependencyClient
public struct ThemeStore: Sendable {
    var load: @Sendable () -> RimThemePreference?
    var save: @Sendable (RimThemePreference) -> Void
}

extension ThemeStore: DependencyKey {
    public static let liveValue = ThemeStore.live
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
    /// Returns a deterministic in-memory test client seeded with a preference.
    ///
    /// Tests inject this so they never touch `UserDefaults`:
    /// ```swift
    /// store.dependencies.themeStore = .test(preference: .light)
    /// ```
    public static func test(preference: RimThemePreference? = nil) -> ThemeStore {
        let box = Box(initial: preference)
        return ThemeStore(
            load: { box.current },
            save: { box.current = $0 }
        )
    }

    /// Returns an in-memory client with no stored preference.
    public static var inMemory: ThemeStore { .test(preference: nil) }

    private final class Box: @unchecked Sendable {
        var current: RimThemePreference?
        init(initial: RimThemePreference?) { self.current = initial }
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
                guard let raw = UserDefaults.standard.string(forKey: ThemeStoreConstants.key) else {
                    return nil
                }
                return RimThemePreference(rawValue: raw)
            },
            save: { preference in
                UserDefaults.standard.set(preference.rawValue, forKey: ThemeStoreConstants.key)
            }
        )
    }()
}
