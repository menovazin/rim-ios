import SwiftUI

/// The resolved design theme for the active color scheme.
///
/// Bundles the resolved `RimColors` (and the ramp accessor `RimTypography`,
/// which is scheme-independent) so views read all tokens from a single value
/// injected through the SwiftUI `Environment`.
public struct RimTheme: Sendable {
    public let scheme: RimColorScheme
    public let colors: RimColors

    public init(scheme: RimColorScheme) {
        self.scheme = scheme
        self.colors = RimColors.resolve(for: scheme)
    }

    /// The SwiftUI `ColorScheme` matching this theme, for `.preferredColorScheme`.
    public var colorScheme: ColorScheme {
        scheme == .dark ? .dark : .light
    }
}
