import Observation
import SwiftUI

/// Observable holder for the app's active color scheme.
///
/// The active scheme is **user-overridable** (via the Drawer theme toggle in a
/// later issue) rather than "follow system", and is structured so it can be
/// hydrated from and written back to persisted settings later. Lives at the
/// composition root and drives the injected `RimTheme`.
@MainActor
@Observable
public final class RimThemeController {
    public var scheme: RimColorScheme {
        didSet { theme = RimTheme(scheme: scheme) }
    }

    /// The currently resolved theme for the active scheme.
    public private(set) var theme: RimTheme

    public init(scheme: RimColorScheme = .dark) {
        self.scheme = scheme
        self.theme = RimTheme(scheme: scheme)
    }

    /// Overrides the active scheme.
    public func setScheme(_ scheme: RimColorScheme) {
        self.scheme = scheme
    }

    /// Toggles between dark and light.
    public func toggle() {
        scheme = (scheme == .dark) ? .light : .dark
    }
}
