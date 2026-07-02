import Observation
import SwiftUI

/// Persistence interface for the active color scheme.
///
/// Implemented by the app/feature layer (e.g. a `UserDefaults`-backed store
/// or an in-memory test double) and injected into `RimThemeController`.
public protocol RimThemePersistence: Sendable {
    func load() -> RimColorScheme?
    func save(_ scheme: RimColorScheme)
}

/// A no-op persistence layer for previews/tests that don't need persistence.
public struct RimThemeNoOpPersistence: RimThemePersistence {
    public init() {}
    public func load() -> RimColorScheme? { nil }
    public func save(_ scheme: RimColorScheme) {}
}

/// Observable holder for the app's active color scheme.
///
/// The active scheme is **user-overridable** via the Drawer theme toggle, is
/// hydrated from the injected persistence on creation, and written back through
/// it on every change. Lives at the composition root and drives the injected
/// `RimTheme`.
@MainActor
@Observable
public final class RimThemeController {
    public var scheme: RimColorScheme {
        didSet {
            theme = RimTheme(scheme: scheme)
            persistence.save(scheme)
        }
    }

    /// The currently resolved theme for the active scheme.
    public private(set) var theme: RimTheme

    private let persistence: any RimThemePersistence

    public init(
        scheme: RimColorScheme? = nil,
        persistence: any RimThemePersistence = RimThemeNoOpPersistence()
    ) {
        self.persistence = persistence
        let initialScheme = scheme ?? persistence.load() ?? .dark
        self.theme = RimTheme(scheme: initialScheme)
        self.scheme = initialScheme
    }

    /// Overrides the active scheme and persists it.
    public func setScheme(_ scheme: RimColorScheme) {
        self.scheme = scheme
    }

    /// Toggles between dark and light and persists the result.
    public func toggle() {
        scheme = (scheme == .dark) ? .light : .dark
    }
}
