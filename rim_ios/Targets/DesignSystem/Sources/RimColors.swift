import SwiftUI

/// The active color scheme for the app.
///
/// Distinct from SwiftUI's `ColorScheme` because the RIM scheme is
/// **user-overridable** (via the Drawer theme toggle in a later issue) and
/// persistence-ready — it is not merely "follow system".
public enum RimColorScheme: String, CaseIterable, Sendable {
    case dark
    case light
}

/// Semantic color tokens resolved for a given `RimColorScheme`.
///
/// Values are the exact dark/light hexes from `DESIGN_SYSTEM.md §1.2`.
public struct RimColors: Sendable {
    public let primary: Color
    public let secondary: Color
    public let background: Color
    public let surface: Color
    public let error: Color

    public let onPrimary: Color
    public let onSecondary: Color
    public let onBackground: Color
    public let onSurface: Color
    public let onError: Color

    public let textPrimary: Color
    public let textSecondary: Color
    public let textDisabled: Color

    /// Resolves the semantic palette for the given scheme.
    public static func resolve(for scheme: RimColorScheme) -> RimColors {
        switch scheme {
        case .dark:
            return RimColors(
                primary: Color(rimHex: 0x34E27A),
                secondary: Color(rimHex: 0x9B53D6),
                background: Color(rimHex: 0x0E1B1F),
                surface: Color(rimHex: 0x16272B),
                error: Color(rimHex: 0xE5484D),
                onPrimary: Color(rimHex: 0x0B1618),
                onSecondary: Color(rimHex: 0xEAF6EC),
                onBackground: Color(rimHex: 0xEAF6EC),
                onSurface: Color(rimHex: 0xEAF6EC),
                onError: Color(rimHex: 0xEAF6EC),
                textPrimary: Color(rimHex: 0xEAF6EC),
                textSecondary: Color(rimHex: 0x9DB5B1),
                textDisabled: Color(rimHex: 0x9DB5B1, opacity: 0.5)
            )
        case .light:
            return RimColors(
                primary: Color(rimHex: 0x28C76F),
                secondary: Color(rimHex: 0x9B53D6),
                background: Color(rimHex: 0xF3F4F6),
                surface: Color(rimHex: 0xFFFFFF),
                error: Color(rimHex: 0xE5484D),
                onPrimary: Color(rimHex: 0xFFFFFF),
                onSecondary: Color(rimHex: 0xFFFFFF),
                onBackground: Color(rimHex: 0x0E1B1F),
                onSurface: Color(rimHex: 0x0E1B1F),
                onError: Color(rimHex: 0xFFFFFF),
                textPrimary: Color(rimHex: 0x0E1B1F),
                textSecondary: Color(rimHex: 0x6B7280),
                textDisabled: Color(rimHex: 0x9CA3AF)
            )
        }
    }
}
